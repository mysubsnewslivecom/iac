#!/usr/bin/env python3
"""
Kubernetes Pod Monitor with Helix Integration
Collects pod status and logs, then sends to Helix for analysis.
"""

import subprocess
import requests
import json
import os
import sys
from typing import List, Tuple, Optional


def get_pod_logs(pod_name: str, namespace: Optional[str] = None) -> str:
    """Get the last 10 lines of logs for a specific pod."""
    try:
        cmd = ["kubectl", "logs", "--tail=10", pod_name]
        if namespace:
            cmd.extend(["-n", namespace])

        logs = subprocess.check_output(
            cmd,
            stderr=subprocess.PIPE,
            timeout=30
        ).decode("utf-8")
        return logs
    except subprocess.CalledProcessError as e:
        error_msg = e.stderr.decode("utf-8") if e.stderr else "Unknown error"
        return f"Error getting logs: {error_msg}"
    except subprocess.TimeoutExpired:
        return "Error: Timeout while fetching logs"
    except Exception as e:
        return f"Unexpected error: {str(e)}"


def get_pod_list(namespace: Optional[str] = None) -> Tuple[str, List[List[str]]]:
    """Get list of pods and their information."""
    try:
        cmd = ["kubectl", "get", "pod", "--no-headers=false"]
        if namespace:
            cmd.extend(["-n", namespace])

        k_output = subprocess.check_output(cmd, timeout=30).decode("utf-8")

        # Parse pod information
        pod_lines = k_output.splitlines()[1:]  # Skip header
        pods = []
        for line in pod_lines:
            if line.strip():  # Skip empty lines
                pods.append(line.split())

        return k_output, pods
    except subprocess.CalledProcessError as e:
        print(f"Error getting pod list: {e}", file=sys.stderr)
        sys.exit(1)
    except subprocess.TimeoutExpired:
        print("Timeout while getting pod list", file=sys.stderr)
        sys.exit(1)


def build_message(k_output: str, pods: List[List[str]], namespace: Optional[str] = None) -> str:
    """Build the message to send to Helix with pod information and logs."""
    namespace_info = f" in namespace '{namespace}'" if namespace else ""
    message = f"Current status of Kubernetes pods{namespace_info}:\n\n"
    message += "Pod List:\n```\n" + k_output + "```\n\n"
    message += "Detailed pod logs:\n\n"

    for pod_info in pods:
        if len(pod_info) < 3:
            continue  # Skip malformed pod info

        pod_name = pod_info[0]
        pod_status = pod_info[2]

        message += f"## Pod: {pod_name} (Status: {pod_status})\n"
        logs = get_pod_logs(pod_name, namespace)
        message += f"Last 10 log lines:\n```\n{logs}```\n\n"

    return message


def send_to_helix(message: str) -> str:
    """Send the message to Helix and return the session URL."""
    # Validate required environment variables
    required_env_vars = ["HELIX_URL", "HELIX_API_KEY", "APP_ID"]
    missing_vars = [var for var in required_env_vars if not os.getenv(var)]

    if missing_vars:
        print(f"Error: Missing required environment variables: {', '.join(missing_vars)}", file=sys.stderr)
        print("Please set the following environment variables:")
        for var in missing_vars:
            print(f"  export {var}='your_value_here'")
        sys.exit(1)

    HELIX_URL = os.getenv("HELIX_URL").rstrip('/')  # Remove trailing slash
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
                "Authorization": f"Bearer {HELIX_API_KEY}",  # Fixed: removed extra colon
                "Content-Type": "application/json"
            },
            json=payload,
            timeout=30
        )
        response.raise_for_status()

        session_data = response.json()
        session_id = session_data.get("id")

        if not session_id:
            print("Error: No session ID returned from Helix", file=sys.stderr)
            print(f"Response: {json.dumps(session_data, indent=2)}")
            sys.exit(1)

        return f"{HELIX_URL}/session/{session_id}"

    except requests.exceptions.RequestException as e:
        print(f"Error communicating with Helix: {e}", file=sys.stderr)
        if hasattr(e, 'response') and e.response is not None:
            print(f"Response status: {e.response.status_code}")
            print(f"Response body: {e.response.text}")
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"Error parsing Helix response: {e}", file=sys.stderr)
        sys.exit(1)


def main():
    """Main function to orchestrate the pod monitoring and Helix integration."""
    import argparse

    parser = argparse.ArgumentParser(description="Monitor Kubernetes pods and send to Helix")
    parser.add_argument("-n", "--namespace", help="Kubernetes namespace to monitor")
    parser.add_argument("--dry-run", action="store_true", help="Print message without sending to Helix")
    args = parser.parse_args()

    # Get pod information
    print("Gathering pod information...", file=sys.stderr)
    k_output, pods = get_pod_list(args.namespace)

    if not pods:
        print("No pods found", file=sys.stderr)
        sys.exit(0)

    # Build message
    print(f"Found {len(pods)} pods, collecting logs...", file=sys.stderr)
    message = build_message(k_output, pods, args.namespace)

    if args.dry_run:
        print("=== DRY RUN - Message that would be sent to Helix ===")
        print(message)
        return

    # Send to Helix
    # print("Sending to Helix...", file=sys.stderr)
    # session_url = send_to_helix(message)
    # print(session_url)


if __name__ == "__main__":
    main()
