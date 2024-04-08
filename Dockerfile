FROM ubuntu:22.04

# Installing necessary dependencies
RUN apt update
RUN apt install -y curl git unzip openjdk-21-jdk wget
RUN apt install -y build-essential lib32stdc++6 clang cmake ninja-build pkg-config libgtk-3-dev

# Arguments and environment variables
ARG BUILD_TOOLS_VERSION=34.0.0
ARG PLATFORM_VERSION=34
ARG COMMAND_LINE_VERSION=latest

# Prepare environment
ENV ANDROID_HOME $HOME_USER/Android/sdk
ENV ANDROID_SDK_TOOLS $ANDROID_HOME/tools

# Configuring the working directory and user to use
ARG USER=root
ARG HOME_USER=/home/$USER
USER $USER
WORKDIR $HOME_USER

# Creating Android directories
RUN mkdir -p $ANDROID_HOME
RUN mkdir -p /root/.android && touch /root/.android/repositories.cfg

# Download Android SDK
RUN wget -O sdk-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
RUN unzip sdk-tools.zip && rm sdk-tools.zip
RUN cp -r cmdline-tools $ANDROID_HOME
RUN mv cmdline-tools/* $ANDROID_HOME

# Download Flutter SDK
RUN git clone https://github.com/flutter/flutter.git

# Download sdk build tools and platform tools
WORKDIR $ANDROID_HOME/bin
RUN yes | ./sdkmanager --sdk_root=${ANDROID_HOME} --licenses
RUN ./sdkmanager --sdk_root=${ANDROID_HOME} "build-tools;${BUILD_TOOLS_VERSION}" "platform-tools" "platforms;android-${PLATFORM_VERSION}" "sources;android-${PLATFORM_VERSION}"
RUN ./sdkmanager --sdk_root=${ANDROID_HOME} --install "cmdline-tools;${COMMAND_LINE_VERSION}"

# Setup PATH environment variable
ENV PATH $PATH:/home/$USER/$ANDROID_HOME/platform-tools:/home/$USER/flutter/bin

# Verify the status licenses
RUN yes | flutter doctor --android-licenses

# Start the adb daemon
#RUN ${ANDROID_SDK_TOOLS}/bin/Android/sdk/tools/platform-tools/adb start-server
RUN ${ANDROID_HOME}/platform-tools/adb start-server
#/home/root/Android/sdk/tools/bin/Android/sdk/tools/platform-tools
