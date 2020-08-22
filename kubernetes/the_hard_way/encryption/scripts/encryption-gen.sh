#!/bin/bash
ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)
