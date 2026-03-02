# Multi-stage headless build (no Pangolin / OpenGL dependencies)

# ---- Stage 1: Builder ----
FROM ubuntu:22.04 AS builder

ENV TZ=America/Los_Angeles
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential cmake \
    libeigen3-dev \
    libopencv-dev \
    libboost-dev libboost-serialization-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

COPY . /ORB_SLAM3

RUN cd /ORB_SLAM3 && bash build.sh

# ---- Stage 2: Runtime ----
FROM ubuntu:22.04

ENV TZ=America/Los_Angeles
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    libopencv-core4.5d libopencv-imgcodecs4.5d libopencv-imgproc4.5d \
    libopencv-calib3d4.5d libopencv-features2d4.5d libopencv-videoio4.5d \
    libopencv-highgui4.5d libopencv-objdetect4.5d \
    libopencv-contrib4.5d \
    libboost-serialization1.74.0 \
    libssl3 libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Copy built artifacts
COPY --from=builder /ORB_SLAM3/lib /ORB_SLAM3/lib
COPY --from=builder /ORB_SLAM3/Thirdparty/DBoW2/lib /ORB_SLAM3/Thirdparty/DBoW2/lib
COPY --from=builder /ORB_SLAM3/Thirdparty/g2o/lib /ORB_SLAM3/Thirdparty/g2o/lib
COPY --from=builder /ORB_SLAM3/Vocabulary /ORB_SLAM3/Vocabulary
COPY --from=builder /ORB_SLAM3/Examples /ORB_SLAM3/Examples

WORKDIR /ORB_SLAM3
