#!/bin/bash

set -e

if [ -f "/opt/ros/humble/setup.bash" ]; then
  source /opt/ros/humble/setup.bash
fi
if [ -f "/workspace/colcon_ws/install/setup.bash" ]; then
  source /workspace/colcon_ws/install/setup.bash
fi

if [ -f "/ros_env_vars.sh" ]; then
  source /ros_env_vars.sh
fi

exec "$@"