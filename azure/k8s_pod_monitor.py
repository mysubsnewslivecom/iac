#!/usr/bin/env python3
"""
Kubernetes Pod Monitor
Collects pod status and logs, then sends to Helix for analysis.
"""

import subprocess
# import requests
import json
import os
import sys
import logging
from typing import List, Tuple, Optional


# Configure logging
logging.basicConfig(format="%(levelname)s: %(message)s", level=logging.INFO)


def get_pod_list(namespace: Optional[str] = None) -> List[dict]:
    """Get list of pods with detailed info using JSON output."""
    cmd = ["kubectl", "get", "pods", "-o", "json"]
    if namespace:
        cmd.extend(["-n", namespace])

    try:
        output = subprocess.check_output(cmd, timeout=30).decode("utf-8")
        data = json.loads(output)
        return data["items"]
    except subprocess.CalledProcessError as e:
        logging.error(f"Error getting pod list: {e}")
        sys.exit(1)
    except subprocess.TimeoutExpired:
        logging.error("Timeout while getting pod list")
        sys.exit(1)


def get_pod_logs(pod_name: str, container: str, namespace: Optional[str] = None) -> str:
    """Get last 10 lines of logs for a specific pod/container."""
    cmd = ["kubectl", "logs", "--tail=10", "--timestamps", pod_name, "-c", container]
    if namespace:
        cmd.extend(["-n", namespace])

    try:
        logs = subprocess.check_output(
            cmd, stderr=subprocess.PIPE, timeout=30
        ).decode("utf-8")
        return logs
    except subprocess.CalledProcessError as e:
        error_msg = e.stderr.decode("utf-8") if e.stderr else "Unknown error"
        return f"Error getting logs: {error_msg}"
    except subprocess.TimeoutExpired:
        return "Error: Timeout while fetching logs"
    except Exception as e:
        return f"Unexpected error: {str(e)}"


def build_message(pods: List[dict], namespace: Optional[str] = None) -> str:
    """Build a detailed message of pod statuses and logs."""
    namespace_info = f" in namespace '{namespace}'" if namespace else ""
    message = f"Current status of Kubernetes pods{namespace_info}:\n\n"

    # Summary Table
    message += "Pod Summary:\n```\n"
    message += f"{'POD':<40} {'STATUS':<12} {'RESTARTS':<8} {'AGE':<10}\n"
    message += "-" * 75 + "\n"

    for pod in pods:
        metadata = pod.get("metadata", {})
        status = pod.get("status", {})
        pod_name = metadata.get("name", "unknown")
        phase = status.get("phase", "unknown")
        restarts = sum(c.get("restartCount", 0) for c in status.get("containerStatuses", []))
        age = metadata.get("creationTimestamp", "unknown")

        message += f"{pod_name:<40} {phase:<12} {restarts:<8} {age:<10}\n"

    message += "```\n\nDetailed pod logs:\n\n"

    for pod in pods:
        pod_name = pod["metadata"]["name"]
        pod_status = pod["status"]["phase"]
        containers = [c["name"] for c in pod["spec"]["containers"]]

        for container in containers:
            message += f"## Pod: {pod_name} | Container: {container} (Status: {pod_status})\n"
            logs = get_pod_logs(pod_name, container, namespace)
            message += f"Last 10 log lines:\n```\n{logs}```\n\n"

    return message


def send_to_helix(message: str) -> str:
    """Send the message to Helix and return the session URL."""
    required_env_vars = ["HELIX_URL", "HELIX_API_KEY", "APP_ID"]
    missing = [var for var in required_env_vars if not os.getenv(var)]

    if missing:
        logging.error(f"Missing environment variables: {', '.join(missing)}")
        for var in missing:
            print(f"  export {var}='your_value_here'")
        sys.exit(1)

    HELIX_URL = os.getenv("HELIX_URL").rstrip("/")
    HELIX_API_KEY = os.getenv("HELIX_API_KEY")
    APP_ID = os.getenv("APP_ID")

    payload = {
        "app_id": APP_ID,
        "session_id": "",
        "messages": [
            {
                "role": "user",
                "content": {
                    "content_type": "text",
                    "parts": [message]
                }
            }
        ]
    }

    try:
        response = requests.post(
            url=f"{HELIX_URL}/api/v1/sessions/chat",
            headers={
                "Authorization": f"Bearer {HELIX_API_KEY}",
                "Content-Type": "application/json"
            },
            json=payload,
            timeout=30
        )
        response.raise_for_status()
        session_data = response.json()
        session_id = session_data.get("id")

        if not session_id:
            logging.error("No session ID returned from Helix")
            logging.error(json.dumps(session_data, indent=2))
            sys.exit(1)

        return f"{HELIX_URL}/session/{session_id}"

    except requests.exceptions.RequestException as e:
        logging.error(f"Error communicating with Helix: {e}")
        if e.response is not None:
            logging.error(f"Response status: {e.response.status_code}")
            logging.error(f"Response body: {e.response.text}")
        sys.exit(1)
    except json.JSONDecodeError as e:
        logging.error(f"Error parsing Helix response: {e}")
        sys.exit(1)


def main():
    import argparse

    parser = argparse.ArgumentParser(description="Monitor Kubernetes pods and send to Helix")
    parser.add_argument("-n", "--namespace", help="Kubernetes namespace to monitor")
    parser.add_argument("--dry-run", action="store_true", help="Print message without sending to Helix")
    args = parser.parse_args()

    logging.info("Gathering pod information...")
    pods = get_pod_list(args.namespace)

    if not pods:
        logging.warning("No pods found.")
        sys.exit(0)

    logging.info(f"Found {len(pods)} pods. Collecting logs...")
    message = build_message(pods, args.namespace)

    if args.dry_run:
        print("=== DRY RUN - Message that would be sent to Helix ===\n")
        print(message)
        return

    logging.info("Sending data to Helix...")
    # session_url = send_to_helix(message)
    print(f"✅ Data sent to Helix. Session URL: {session_url}")


if __name__ == "__main__":
    main()
