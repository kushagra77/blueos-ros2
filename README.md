<p align="center">
<a href="https://github.com/itskalvik/blueos-ros2">
<img src=".assets/logo.png" width="75%"/> 
</a></p>

The BlueOS ROS2 Extension bridges the [BlueOS](https://bluerobotics.com/blueos-conversion/) and [ROS2](https://github.com/ros2) ecosystems, enabling advanced robotic applications and research on ArduPilot-based vehicles such as the BlueBoat and BlueROV2.

This fork is a stripped down version of the original extension, with functionalities specifically designed for the open source project [OpenMantaClaus](https://github.com/kushagra77/OpenMantaClaus).

In addition, it includes a web-based terminal for convenient access to the ROS 2 environment.

<p align="center">
<img src=".assets/demo.gif" width="50%"/> 
</p>

# 🚀 Features

THIS EXTENSION IS A FORK OF THE ORIGINAL ROS2 EXTENSION, SPECIFICALLY FOR THE OPENMANTACLAUS PROJECT. IT ONLY HAS THE FOLLOWING REQUIRED PACKAGES AND ALSO HAS GIT-FRIENDLY SETUP VIA SSH LINKING, AND OTHER DEPENDENCIES SPECIFICALLY FOR THE MANTACLAUS AUV AND SAUVC 2026. 

- **[mavros_control](https://github.com/itskalvik/mavros_control)**

  A Python-based control interface using [MAVROS](https://github.com/mavlink/mavros). Supports GPS waypoint navigation (BlueBoat) and RC control (BlueROV2). Includes methods for arming/disarming, takeoff/landing, home location setting, and waypoint following. Skip the boilerplate—subclass or reuse it directly!


## 📋 Prerequisites

SAME PREREQUISITES APPLY.

- A 64-bit version of [BlueOS](https://github.com/bluerobotics/BlueOS) is required. 
Get the latest image for Raspberry Pi from [BlueOS releases](https://github.com/bluerobotics/BlueOS/releases/).


## 🧰 Installation
You can install the ROS 2 Extension directly from the BlueOS App Store.

<p align="center">
<img src=".assets/installation.gif" width="100%"/> 
</p>


## ⚙️ Usage

FOR MANTACLAUS IT IS RECOMMENDED TO USE IT THROUGH DOCKERISED VSCODE FOR THE BEST DEVELOPER EXPERIENCE.

- BlueOS automatically launches the extension on boot.

- The extension's terminal is accessible from the left-hand panel of the BlueOS interface.

- The extension mounts the host directory ```/usr/blueos/extensions/ros2/``` to the container path ```/root/persistent_ws/```
  Use this folder to store files that should persist across reboots, such as custom ROS 2 workspaces or configurations.

<p align="center">
<img src=".assets/usage.gif" width="100%"/> 
</p>

## 🛠️ Building the Docker Container Locally
To build the container for multiple architectures (`arm64`, `amd64`), follow these steps:

### 1. Set up a multi-architecture builder:

```bash
docker buildx create --name multi-arch \
  --platform "linux/arm64,linux/amd64" \
  --driver "docker-container"
docker buildx use multi-arch
```

### 2. Clone the repository and build the container:

```bash
git clone --recurse-submodules https://github.com/itskalvik/blueos-ros2
cd blueos-ros2
docker compose build
```
