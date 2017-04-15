#!/bin/bash

declare -a FORMAT_LIST
declare -a RESOLUTION_LIST
declare -a INTERLACED_MODE

FORMAT_LIST=([0]="nv12")
RESOLUTION_LIST=([0]="1920x1080")
INTERLACED_MODE=([0]="false")

# Usage for cases insensitive to resolution
DEFAULT_RESULITON_INDEX=0