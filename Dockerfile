FROM runmymind/docker-android-sdk

WORKDIR /

RUN apt-get update && \
    apt-get install -y lcov git-core curl unzip && \
    git clone https://github.com/flutter/flutter.git && \
    apt autoremove -y && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /flutter_tracker
WORKDIR /flutter_tracker
ADD . /flutter_tracker

ENV PATH $PATH:/flutter/bin/cache/dart-sdk/bin:/flutter/bin