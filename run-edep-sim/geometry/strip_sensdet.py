#!/usr/bin/env python3

import argparse


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('infile')
    args = ap.parse_args()

    for line in open(args.infile):
        magic = '<auxiliary auxtype="SensDet" auxvalue="'
        if line.strip().startswith(magic):
            assert line.strip().endswith('/>')
            continue
        print(line, end='')


if __name__ == '__main__':
    main()
