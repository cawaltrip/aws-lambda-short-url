#!/usr/bin/env python3

import argparse
import requests
from pathlib import Path
import sys
import configparser

def main():
    parser = argparse.ArgumentParser(
                    prog = 'shorten',
                    description = 'Shorten a URL',
                    epilog = 'Yock dehay!')
    parser.add_argument('-a', '--api-key', required=False, dest="key", help="API key for CloudFront site")
    parser.add_argument('-p', '--profile', default="~/.aws/skellies-credentials", required=False, 
                        help="Location where API key is stored (use `api_key` as key)")
    parser.add_argument('-u', '--url', required=True, dest="input", help="URL to shorten")
    parser.add_argument('-s', '--short-name', required=False, dest="token", help="Short name to use (default is random)")
    parser.add_argument('-c', '--cloudfront', dest="domain", help="CloudFront domain name")

    args = parser.parse_args()

    if args.key is None:
        if args.profile is not None:
            p = Path(args.profile).expanduser()
            if p.exists():
                config = configparser.ConfigParser()
                config.read(p)
                conf = config['DEFAULT']
                if "admin_api_key" in conf.keys():
                    args.key = conf['admin_api_key']
                if "cloudfront_domain_name" in conf.keys():
                    args.domain = conf['cloudfront_domain_name']
        
    if args.key is None:
        print(f"No API key specified!")
        sys.exit(1)
    if args.domain is None:
        print(f"No CloudFront domain specified!")
        sys.exit(1)
    
    headers = {
        'x-api-key': args.key
    }

    data = {
        'url': args.input
    }
    if args.token is not None:
        data['custom_url'] = args.token
    
    try:
        test_response = requests.head(args.input)
        if test_response.status_code == 404:
            print(f"Website not found! ({test_response.url})")
            sys.exit(1)
    except:
        print(f"Website not formatted correctly! ({args.input})")
        sys.exit(1)

    r = requests.post(
        url=f"https://{args.domain}/admin",
        headers=headers,
        json=data
    )
    print(f"Status code: {r.status_code}")
    try:
        response = r.json()
        if "short_url" in response.keys():
            print(f"Short URL: {response['short_url']}")
    except:
        response = r.text
        print(f"r.text = {r.text}")


if __name__ == '__main__':
    main()