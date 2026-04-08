#!/bin/bash
# Returns short month name in uppercase
date '+%b' | tr '[:lower:]' '[:upper:]'