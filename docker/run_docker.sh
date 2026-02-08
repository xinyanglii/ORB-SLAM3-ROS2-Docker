#!/bin/bash

# Ensure X11 forwarding is set up properly
XSOCK=/tmp/.X11-unix
XAUTH=/tmp/.docker.xauth

# Create xauth file if it doesn't exist
touch $XAUTH
xauth nlist "$DISPLAY" | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
chmod 777 $XAUTH

# Set up datasets path (create if doesn't exist)
# DATASETS=$(realpath -s ~/datasets 2>/dev/null || echo ~/datasets)
# DATASETS=$(realpath -s /mnt/raid0_gpu4/xinyang/datasets 2>/dev/null || echo /mnt/raid0_gpu4/xinyang/datasets)
DATASETS_DEFAULT=~/datasets
DATASETS="$DATASETS_DEFAULT"

# --datasets <path>
while [[ $# -gt 0 ]]; do
  case "$1" in
    --datasets)
      shift
      if [[ -n "$1" ]]; then
        DATASETS=$(realpath -s "$1" 2>/dev/null || echo "$1")
        shift
      else
        echo "Error: --datasets needs a path argument" >&2
        exit 1
      fi
      ;;
    --help|-h)
      echo "Usage: $0 [--datasets PATH]"
      exit 0
      ;;
    *)
      shift
      ;;
  esac
done

DATASETS=$(realpath -s "$DATASETS" 2>/dev/null || echo "$DATASETS")

mkdir -p "$DATASETS"

# Allow X11 connections from localhost
xhost +local:

echo "X11 forwarding enabled for GUI applications"
echo "Datasets directory: $DATASETS"

docker run -it \
  --rm \
  --privileged \
  --network host \
  -e DISPLAY="$DISPLAY" \
  -e XAUTHORITY=$XAUTH \
  -e QT_X11_NO_MITSHM=1 \
  -e _X11_NO_MITSHM=1 \
  -e _MITSHM=0 \
  -v $XSOCK:$XSOCK \
  -v $XAUTH:$XAUTH \
  -v "$DATASETS":/datasets \
  -v ./src:/workspace/colcon_ws/src:rw \
  -v ./ORB_SLAM3:/workspace/ORB_SLAM3:rw \
  --device=/dev/video0:/dev/video0 \
  --device=/dev/video1:/dev/video1 \
  --device=/dev/video2:/dev/video2 \
  -v /dev/bus/usb:/dev/bus/usb \
  orb-slam3-humble:22.04 \
  bash -c "cd /workspace/ORB_SLAM3 && ./build.sh && exec bash"

# Clean up X11 permissions
xhost -local: