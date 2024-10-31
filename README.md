# Template for running ROS Noetic projects in docker container


# Using this for the first time:
1. Make a repository based on this template.
1. Add the submodules to packages folder (and remove placeholder)
1. Update the overlay and dev dependencied (apt and pip) to suit your project.
1. Update the `.env` file.
1. Make sure the entrypoint permissions are set: `chmod +x docker/entrypoint.sh`
1. Build the image (from this repositorys' root folder)
1. Start the container.


NB:
- In the overlay image the submodules (in packages folder) are copied over (from the Dockerfile)
- In the dev image the submodules (in packages folder) are a shared volume (from the docker-compose file)

# Files
- .devcontainer: vscode setup in container
- Docker: Dockerfile and entrypoint
- .env: Environment variables to be changed. Particularly important for ROS1 (ros master, nodes IP etc.)
- dependencies.repos: Repositories that are used, but not to be modified (e.g. drivers, tools etc)
- docker-compose: Compose file


# Docker (How to run docker environment)

Install docker and docker compose

Docker:
https://docs.docker.com/engine/install/

Docker compose:
https://docs.docker.com/compose/install/

Build the image:
```bash
docker compose build dev
```

Run the container:
```bash
docker compose up dev
```

Connect to the container:
```bash
docker exec -it $NAME bash
```

Remove everything, including stopped containers and all unused images (not just dangling ones):
```bash
docker system prune -a
```

# ROS

## Demo


Following script modifies transformation messages in a ROS bag file by appending `_gt` to the `child_frame_id` of transformations that have a `header.frame_id` of `/world`. This can be useful in scenarios where you need to differentiate between ground truth frames and other frames in a dataset.
```bash
python src/rtabmap_custom/src/tum_rename_world_kinect_frame.py data/TUM_ROS/rgbd_dataset_freiburg1_desk.bag
python src/rtabmap_custom/src/tum_rename_world_kinect_frame.py data/TUM_ROS/rgbd_dataset_freiburg2_xyz.bag
python src/rtabmap_custom/src/tum_rename_world_kinect_frame.py data/TUM_ROS/rgbd_dataset_freiburg3_long_office_household.bag
```

From the workspace the rtabmap and rosbg can now be started:
```bash
cd /overlay_ws
roslaunch rtabmap_custom rgbdslam_datasets.launch
rosbag play --clock data/rgbd_dataset_freiburg3_long_office_household.bag
```

## Create ROS package
Create package with launch file
```bash
catkin_create_pkg rtabmap_custom rospy std_msgs
cd rtabmap_custom
mkdir launch
```

Change permissions if a python file is created
```bash
chmod +x src/your_node_script.py
```

Build and source
```bash
cd /overlay_ws
catkin build
source devel/setup.bash
```

## ROS bag

[TUM RGB-D dataset](https://cvg.cit.tum.de/data/datasets/rgbd-dataset/download#freiburg3_long_office_household). Rosbags can be downloadet further down in the link.

Topics for TUM-dataset:
- /camera/depth/camera_info
- /camera/depth/image
- /camera/rgb/camera_info
- /camera/rgb/image_color


Play rosbag
```bash
rosbag play --clock data/demo_mapping.bag
```



# Submodules
Clone the repo with submodules:
```bash
git clone --recursive git@github.com:Lucasmogsan/ros1_template.git
```

Alternatively clone the repo and then get the submodules afterwards:

```bash
git clone git@github.com:Lucasmogsan/ros1_template.git
```

```bash
git submodule update --init --recursive
```


The main repo has references to the submodules. If these submodules are modified, then the main repo may need to update these references in order to pull the latest data.
```bash
git submodule update --remote
```

This modifies the references in the main repo, and these changes needs to be comitted and pushed.