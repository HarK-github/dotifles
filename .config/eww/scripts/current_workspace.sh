#!/bin/bash

# For Hyprland
hyprctl activeworkspace -j | jq -r '.id'