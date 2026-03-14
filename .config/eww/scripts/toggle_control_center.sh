#!/bin/bash

state=$(eww get open_control_center)

[[ "$state" == "true" ]] && \
    eww update open_control_center=false || \
    { eww open control_center; eww update open_control_center=true; }