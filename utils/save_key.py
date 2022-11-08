#!/usr/bin/env python3

from subprocess import run
import json
import configparser
import sys
import argparse
from pathlib import Path


def main():

    CONFIG_SECTION = "DEFAULT"
    API_KEY_NAME = "admin_api_key"
    CLOUDFRONT_KEY_NAME = "cloudfront_domain_name"

    parser = argparse.ArgumentParser(
                    prog = 'save_key',
                    description = 'Save Admin API Key from Terraform output',
                    epilog = 'Yock dehay!')
    parser.add_argument('-p', '--profile', 
                        default="~/.aws/skellies-api-key", required=False, 
                        help=("Location where API key is stored"
                              "(use `api_key` as key)"))
    
    args = parser.parse_args()

    # Get the secret API key from Terraform
    result = run(["terraform", "output", "-json"], capture_output=True, cwd="../infra/site")
    if result.returncode != 0:
        print(f"Failed to retrieve terraform output")
        sys.exit(1)
    output = json.loads(result.stdout)
    if (API_KEY_NAME not in output.keys() and 
            'value' not in output[API_KEY_NAME].keys()):
        print(f"Admin API Key not in output")
        sys.exit(1)
    if (CLOUDFRONT_KEY_NAME not in output.keys() and 
            'value' not in output[CLOUDFRONT_KEY_NAME].keys()):
        print(f"CloudFront domain name not in output")
        sys.exit(1)

    # Try to write the config file.
    p = Path(args.profile).expanduser()
    config = configparser.ConfigParser()
    config[CONFIG_SECTION][API_KEY_NAME] = output[API_KEY_NAME]['value']
    config[CONFIG_SECTION][CLOUDFRONT_KEY_NAME] = output[CLOUDFRONT_KEY_NAME]['value']
    try:
        with open(p, 'w') as fp:
            config.write(fp)
    except:
        print(f"Could not write API key to file")
        sys.exit(1)

    # Try to lock down the file.
    try:
        from os import chmod
        chmod(path=p, mode=0o600)
    except (OSError, PermissionError):
        # If OSError, probably on a Windows system
        # If PermissionError, then on a Linux/macOS system, but
        # still had a problem.  Regardless, warn and move on.
        print(f"WARNING: Created API key file, but "
                "could not restrict access.  Fix manually")

if __name__ == '__main__':
    main()
    