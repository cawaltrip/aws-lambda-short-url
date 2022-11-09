#!/usr/bin/env python3

from subprocess import run
import json
import configparser
import sys
import argparse
from pathlib import Path
import tomlkit


def main():

    CONFIG_SECTION = "DEFAULT"
    API_KEY_NAME = "admin_api_key"
    CLOUDFRONT_KEY_NAME = "cloudfront_domain_name"
    PUBLISHER_ACCESS_KEY = "iam_publish_access_key"
    PUBLISHER_SECRET_KEY = "iam_publish_secret_key"
    CLOUDFRONT_DIST_ID = "cf_distribution_id"
    HUGO_S3_BUCKET = "s3_bucket_url"
    
    required_keys = [
        API_KEY_NAME,
        CLOUDFRONT_KEY_NAME,
        PUBLISHER_ACCESS_KEY,
        PUBLISHER_SECRET_KEY,
        CLOUDFRONT_DIST_ID,
        HUGO_S3_BUCKET
    ]

    parser = argparse.ArgumentParser(
                    prog = 'save_key',
                    description = 'Save Admin API Key from Terraform output',
                    epilog = 'Yock dehay!')
    parser.add_argument('-p', '--profile', 
                        default="~/.aws/skellies-credentials", required=False, 
                        help=("Location where API key is stored"
                              "(use `api_key` as key)"))
    parser.add_argument('-a', '--aws-creds-file',
                        default="~/.aws/credentials", required=False,
                        help="AWS Credentials file location")
    parser.add_argument('-c', '--hugo-config',
                        default="../site/config.toml", required=False,
                        help="Location of Hugo site's config file.")
    
    args = parser.parse_args()

    # Get the secret API key from Terraform
    result = run(["terraform", "output", "-json"], capture_output=True, cwd="../infra/site")
    if result.returncode != 0:
        print(f"Failed to retrieve terraform output")
        sys.exit(1)
    output = json.loads(result.stdout)

    for key in required_keys:
        if (key not in output.keys() and 
                'value' not in output[key].keys()):
            print(f"Missing {key} from output.")
            sys.exit(1)

    # Try to write the config file.
    p = Path(args.profile).expanduser()
    config = configparser.ConfigParser()
    if CONFIG_SECTION not in output.keys():
        config[CONFIG_SECTION] = {}
    config[CONFIG_SECTION][API_KEY_NAME] = output[API_KEY_NAME]['value']
    config[CONFIG_SECTION][CLOUDFRONT_KEY_NAME] = output[CLOUDFRONT_KEY_NAME]['value']
    config[CONFIG_SECTION][CLOUDFRONT_DIST_ID] = output[CLOUDFRONT_DIST_ID]['value']
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

    # Time to write the AWS keys to file.
    p = Path(args.aws_creds_file).expanduser()
    config = configparser.ConfigParser()
    config.read(p)
    if "publish" not in config.keys():
        config["publish"] = {}
    config["publish"]["aws_access_key_id"] = output[PUBLISHER_ACCESS_KEY]['value']
    config["publish"]["aws_secret_access_key"] = output[PUBLISHER_SECRET_KEY]['value']
    try:
        with open(p, 'w') as fp:
            config.write(fp)
    except:
        print(f"Could not write AWS credentials to file")
        sys.exit(1)

    # Write the info Hugo needs to file
    p = Path(args.hugo_config).expanduser().resolve()
    config = tomlkit.loads(p.read_text())
    if "deployment" not in config.keys():
        config['deployment'] = {}
        try:
            with open(p, "w") as fp:
                fp.write(tomlkit.dumps(config))
        except:
            print(f"Could not write Hugo config to file.")
            sys.exit(1)

    new_conf = {
        'targets': [{
            'name': "S3",
            'URL': output[HUGO_S3_BUCKET]['value'], 
            'cloudFrontDistributionID': output[CLOUDFRONT_DIST_ID]['value']}]}
    config['deployment'] = new_conf

    try:
        with open(p, "w") as fp:
            fp.write(tomlkit.dumps(config))
    except:
        print(f"Could not write Hugo config to file.")
        sys.exit(1)


if __name__ == '__main__':
    main()
    