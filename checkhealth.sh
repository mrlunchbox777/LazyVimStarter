#!/bin/bash
# Wrapper script to run nvim checkhealth and automatically quit after completion
# Usage: ./checkhealth.sh [module_name]

MODULE="${1:-}"

if [ -z "$MODULE" ]; then
    nvim -c "checkhealth" -c "norm G" -c "redraw" -c "sleep 2" -c "wqa"
else
    nvim -c "checkhealth $MODULE" -c "norm G" -c "redraw" -c "sleep 2" -c "wqa"
fi
