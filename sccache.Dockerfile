FROM quay.io/pypa/manylinux_2_24_x86_64 as main

ADD https://github.com/mozilla/sccache/releases/download/v0.3.0/sccache-v0.3.0-x86_64-unknown-linux-musl.tar.gz /
RUN tar xf /sccache-v0.3.0-x86_64-unknown-linux-musl.tar.gz \
 && chmod +x /sccache-v0.3.0-x86_64-unknown-linux-musl/sccache \
 && mv /sccache-v0.3.0-x86_64-unknown-linux-musl/sccache /usr/local/bin \
 && rm -rf /sccache-v0.3.0-x86_64-unknown-linux-musl

WORKDIR /src
ARG PYTHON=python3.10
ENV PYTHON=${PYTHON} URL="git+https://github.com/cmake-wheel"
RUN --mount=type=cache,target=/root/.cache ${PYTHON} -m pip install simple503

ENV CMEEL_TEMP_DIR=/ws CMAKE_CXX_COMPILER_LAUNCHER=sccache SCCACHE_REDIS=redis://asahi

FROM main as cmeel

ADD cmeel .
RUN --mount=type=cache,target=/root/.cache sccache -s \
 && ${PYTHON} -m pip wheel --extra-index-url file:///wh -w /wh .

FROM main as cmeel-example

COPY --from=cmeel /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD cmeel-example .
RUN --mount=type=cache,target=/root/.cache sccache -s \
 && ${PYTHON} -m pip install --extra-index-url file:///wh \
    cmeel \
 && ${PYTHON} -m pip wheel --no-build-isolation --extra-index-url file:///wh -w /wh .

FROM main as eigen

COPY --from=cmeel /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD cmeel-eigen .
RUN --mount=type=cache,target=/root/.cache sccache -s \
 && ${PYTHON} -m pip install --extra-index-url file:///wh \
    cmeel \
 && ${PYTHON} -m pip wheel --no-build-isolation --extra-index-url file:///wh -w /wh .

FROM main as boost

COPY --from=cmeel /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD cmeel-boost .
RUN --mount=type=cache,target=/root/.cache sccache -s \
 && ${PYTHON} -m pip install --extra-index-url file:///wh \
    cmeel \
 && ${PYTHON} -m pip wheel --no-build-isolation --extra-index-url file:///wh -w /wh .

FROM main as eigenpy

COPY --from=cmeel /wh /wh
COPY --from=eigen /wh /wh
COPY --from=boost /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD eigenpy .
RUN --mount=type=cache,target=/root/.cache sccache -s \
 && ${PYTHON} -m pip install --extra-index-url file:///wh \
    cmeel-eigen \
    cmeel-boost \
 && ${PYTHON} -m pip wheel --no-build-isolation --extra-index-url file:///wh -w /wh .

FROM main as assimp

COPY --from=cmeel /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD cmeel-assimp .
RUN --mount=type=cache,target=/root/.cache sccache -s \
 && ${PYTHON} -m pip install --extra-index-url file:///wh \
    cmeel \
 && ${PYTHON} -m pip wheel --no-build-isolation --extra-index-url file:///wh -w /wh .

FROM main as octomap

COPY --from=cmeel /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD cmeel-octomap .
RUN --mount=type=cache,target=/root/.cache sccache -s \
 && ${PYTHON} -m pip install --extra-index-url file:///wh \
    cmeel \
 && ${PYTHON} -m pip wheel --no-build-isolation --extra-index-url file:///wh -w /wh .

FROM main as hpp-fcl

COPY --from=assimp /wh /wh
COPY --from=octomap /wh /wh
COPY --from=eigenpy /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD hpp-fcl .
RUN --mount=type=cache,target=/root/.cache sccache -s \
 && ${PYTHON} -m pip install --extra-index-url file:///wh \
    cmeel-assimp \
    cmeel-eigen \
    cmeel-octomap \
    eigenpy \
 && ${PYTHON} -m pip wheel --no-build-isolation --extra-index-url file:///wh -w /wh .

FROM main as urdfdom-headers

COPY --from=cmeel /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD cmeel-urdfdom-headers .
RUN --mount=type=cache,target=/root/.cache sccache -s \
 && ${PYTHON} -m pip install --extra-index-url file:///wh \
    cmeel \
 && ${PYTHON} -m pip wheel --no-build-isolation --extra-index-url file:///wh -w /wh .


FROM main as console-bridge

COPY --from=cmeel /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD cmeel-console-bridge .
RUN --mount=type=cache,target=/root/.cache sccache -s \
 && ${PYTHON} -m pip install --extra-index-url file:///wh \
    cmeel \
 && ${PYTHON} -m pip wheel --no-build-isolation --extra-index-url file:///wh -w /wh .

FROM main as tinyxml

COPY --from=cmeel /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD cmeel-tinyxml .
RUN --mount=type=cache,target=/root/.cache sccache -s \
 && ${PYTHON} -m pip install --extra-index-url file:///wh \
    cmeel \
 && ${PYTHON} -m pip wheel --no-build-isolation --extra-index-url file:///wh -w /wh .

FROM main as urdfdom

COPY --from=urdfdom-headers /wh /wh
COPY --from=tinyxml /wh /wh
COPY --from=console-bridge /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD cmeel-urdfdom .
RUN --mount=type=cache,target=/root/.cache sccache -s \
 && ${PYTHON} -m pip install --extra-index-url file:///wh \
    cmeel-urdfdom-headers \
    cmeel-tinyxml \
    cmeel-console-bridge \
 && ${PYTHON} -m pip wheel --no-build-isolation --extra-index-url file:///wh -w /wh .

FROM main as pinocchio

COPY --from=hpp-fcl /wh /wh
COPY --from=urdfdom /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD pinocchio .
RUN --mount=type=cache,target=/root/.cache sccache -s \
 && ${PYTHON} -m pip install --extra-index-url file:///wh \
    cmeel-eigen \
    cmeel-console-bridge \
    cmeel-tinyxml \
    cmeel-urdfdom \
    cmeel-urdfdom-headers \
    hpp-fcl \
 && ${PYTHON} -m pip wheel --no-build-isolation --extra-index-url file:///wh -w /wh .

FROM main as example-robot-data

COPY --from=pinocchio /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD example-robot-data .
RUN ln -s /src /example-robot-data
RUN --mount=type=cache,target=/root/.cache sccache -s \
 && ${PYTHON} -m pip install --extra-index-url file:///wh \
    cmeel-eigen \
    cmeel-urdfdom-headers \
    pin \
 && ${PYTHON} -m pip wheel --no-build-isolation --extra-index-url file:///wh -w /wh .

FROM main as wh

COPY --from=cmeel-example /wh /wh
COPY --from=example-robot-data /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh

FROM python:3.10

COPY --from=wh /wh /wh
ENV PYTHON=python
RUN --mount=type=cache,target=/root/.cache ${PYTHON} -m pip install --extra-index-url file:///wh example-robot-data
RUN ${PYTHON} -c "import example_robot_data"
RUN assimp
