#!/bin/bash
if [ "$EUID" -ne 0 ]; then
  echo "Usage: pkexec $0"
  echo "Forces NVIDIA GPU out of P8 idle state"
  echo "Only needed if NVreg_DynamicPowerManagement=0x02 alone isn't enough"
  exit 1
fi

nvidia-smi -pm 1
echo on > /sys/bus/pci/devices/0000:01:00.0/power/control
echo "GPU forced to active state"
nvidia-smi -q -d CLOCK | grep -E "(Graphics|Memory)" | head -4