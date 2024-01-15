#!/bin/bash

rosdep keys --from-paths /umd2_ws/src --ignore-src --rosdistro ${INPUT_ROS_DISTRO} | \
  xargs rosdep resolve --rosdistro ${INPUT_ROS_DISTRO} | \
  awk '/#apt/{getline; print}' > /rosdep_requirements.txt

apt update 
apt install -y --no-install-recommends $(cat /rosdep_requirements.txt)
apt install -y --no-install-recommends python3-pip dpkg-dev debhelper dh-python ${INPUT_LIST_BINARIES}
# ln -snf /usr/lib/x86_64-linux-gnu/libopus.a /usr/local/lib
pip3 install rosdep bloom
echo "yaml file:///rosdep.yaml" >> /etc/ros/rosdep/sources.list.d/50-my-packages.list
cp ${INPUT_PATH_CUSTOM_RESOURCES} /

# store the current dir
CUR_DIR=$(pwd)
echo ${CUR_DIR}

# Update ROS deps
rosdep update

# PACKAGE_LIST=(
#             psdk_ros2/psdk_interfaces \
#             psdk_ros2/psdk_wrapper
# )

for PACKAGE in ${INPUT_LIST_PACKAGES[@]}; do
    echo ""
    echo "Creating debian for $PACKAGE..."

    # We have to go to the ROS package parent directory
    cd $PACKAGE;
    bloom-generate rosdebian --ros-distro ${INPUT_ROS_DISTRO}
    debian/rules "binary --parallel --dpkg-shlibdeps-params=--ignore-missing-info"

    cd ..
    DEB_FILE=$(find *.deb);
    if ! [[ $? -eq 0 ]]; then 
        exit 1
    fi
    dpkg -i $DEB_FILE
    rm *.deb *.ddeb
    cd $CUR_DIR

done

echo "Complete!"
