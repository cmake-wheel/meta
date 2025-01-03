FROM quay.io/pypa/manylinux_2_28_x86_64 as main

ADD https://github.com/mozilla/sccache/releases/download/v0.7.2/sccache-v0.7.2-x86_64-unknown-linux-musl.tar.gz /
RUN tar xf /sccache-v0.7.2-x86_64-unknown-linux-musl.tar.gz \
 && chmod +x /sccache-v0.7.2-x86_64-unknown-linux-musl/sccache \
 && mv /sccache-v0.7.2-x86_64-unknown-linux-musl/sccache /usr/local/bin \
 && rm -rf /sccache-v0.7.2-x86_64-unknown-linux-musl

WORKDIR /src
ARG PYTHON=python3.12
ENV PYTHON=${PYTHON} URL="git+https://github.com/cmake-wheel"
RUN --mount=type=cache,target=/root/.cache ${PYTHON} -m pip install simple503

ENV SCCACHE_REDIS=redis://asahi CMAKE_C_COMPILER_LAUNCHER=sccache CMAKE_CXX_COMPILER_LAUNCHER=sccache
ENV CMEEL_TEMP_DIR=/ws CTEST_PARALLEL_LEVEL=6
ENV CMEEL_JOBS=16

FROM main as cmeel

ADD cmeel .
RUN --mount=type=cache,target=/root/.cache sccache -s \
 && ${PYTHON} -m pip wheel --extra-index-url file:///wh -w /wh .

FROM main as cmeel-example

COPY --from=cmeel /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD cmeel-example .
RUN --mount=type=cache,target=/root/.cache sccache -s \
 && ${PYTHON} -m pip install --extra-index-url file:///wh /wh/*.whl \
 && ${PYTHON} -m pip wheel --no-build-isolation --extra-index-url file:///wh -w /wh .

FROM main as eigen

COPY --from=cmeel /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD cmeel-eigen .
RUN --mount=type=cache,target=/root/.cache sccache -s \
 && ${PYTHON} -m pip install --extra-index-url file:///wh /wh/*.whl \
 && ${PYTHON} -m pip wheel --no-build-isolation --extra-index-url file:///wh -w /wh .

FROM main as boost

COPY --from=cmeel /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD cmeel-boost .
RUN --mount=type=cache,target=/root/.cache sccache -s \
 && ${PYTHON} -m pip install --extra-index-url file:///wh /wh/*.whl \
 && ${PYTHON} -m pip wheel --no-build-isolation --extra-index-url file:///wh -w /wh .

FROM main as eigenpy

COPY --from=eigen /wh /wh
COPY --from=boost /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD eigenpy .
RUN --mount=type=cache,target=/root/.cache sccache -s \
 && ${PYTHON} -m pip install --extra-index-url file:///wh /wh/*.whl \
 && ${PYTHON} -m pip wheel --no-build-isolation --extra-index-url file:///wh -w /wh .

FROM main as assimp

COPY --from=cmeel /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD cmeel-assimp .
RUN --mount=type=cache,target=/root/.cache sccache -s \
 && ${PYTHON} -m pip install --extra-index-url file:///wh /wh/*.whl \
 && ${PYTHON} -m pip wheel --no-build-isolation --extra-index-url file:///wh -w /wh .

FROM main as octomap

COPY --from=cmeel /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD cmeel-octomap .
RUN --mount=type=cache,target=/root/.cache sccache -s \
 && ${PYTHON} -m pip install --extra-index-url file:///wh /wh/*.whl \
 && ${PYTHON} -m pip wheel --no-build-isolation --extra-index-url file:///wh -w /wh .

FROM main as qhull

COPY --from=cmeel /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD cmeel-qhull .
RUN --mount=type=cache,target=/root/.cache sccache -s \
 && ${PYTHON} -m pip install --extra-index-url file:///wh /wh/*.whl \
 && ${PYTHON} -m pip wheel --no-build-isolation --extra-index-url file:///wh -w /wh .

FROM main as coal

COPY --from=assimp /wh /wh
COPY --from=octomap /wh /wh
COPY --from=eigenpy /wh /wh
COPY --from=qhull /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD coal .
RUN --mount=type=cache,target=/root/.cache sccache -s \
 && ${PYTHON} -m pip install --extra-index-url file:///wh /wh/*.whl \
 && ${PYTHON} -m pip wheel --no-build-isolation --extra-index-url file:///wh -w /wh .

FROM main as urdfdom-headers

COPY --from=cmeel /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD cmeel-urdfdom-headers .
RUN --mount=type=cache,target=/root/.cache sccache -s \
 && ${PYTHON} -m pip install --extra-index-url file:///wh /wh/*.whl \
 && ${PYTHON} -m pip wheel --no-build-isolation --extra-index-url file:///wh -w /wh .


FROM main as console-bridge

COPY --from=cmeel /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD cmeel-console-bridge .
RUN --mount=type=cache,target=/root/.cache sccache -s \
 && ${PYTHON} -m pip install --extra-index-url file:///wh /wh/*.whl \
 && ${PYTHON} -m pip wheel --no-build-isolation --extra-index-url file:///wh -w /wh .

FROM main as tinyxml

COPY --from=cmeel /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD cmeel-tinyxml .
RUN --mount=type=cache,target=/root/.cache sccache -s \
 && ${PYTHON} -m pip install --extra-index-url file:///wh /wh/*.whl \
 && ${PYTHON} -m pip wheel --no-build-isolation --extra-index-url file:///wh -w /wh .

FROM main as urdfdom

COPY --from=urdfdom-headers /wh /wh
COPY --from=tinyxml /wh /wh
COPY --from=console-bridge /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD cmeel-urdfdom .
RUN --mount=type=cache,target=/root/.cache sccache -s \
 && ${PYTHON} -m pip install --extra-index-url file:///wh /wh/*.whl \
 && ${PYTHON} -m pip wheel --no-build-isolation --extra-index-url file:///wh -w /wh .

FROM main as pinocchio

COPY --from=coal /wh /wh
COPY --from=urdfdom /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD pinocchio .
ENV CMEEL_JOBS=6
RUN --mount=type=cache,target=/root/.cache sccache -s \
 && ${PYTHON} -m pip install --extra-index-url file:///wh /wh/*.whl \
 && ${PYTHON} -m pip wheel --no-build-isolation --extra-index-url file:///wh -w /wh .

FROM main as example-robot-data

COPY --from=pinocchio /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
WORKDIR /example-robot-data
ADD example-robot-data .
RUN --mount=type=cache,target=/root/.cache sccache -s \
 && ${PYTHON} -m pip install --extra-index-url file:///wh /wh/*.whl \
 && ${PYTHON} -m pip wheel --no-build-isolation --extra-index-url file:///wh -w /wh .

FROM main as eiquadprog

COPY --from=eigen /wh /wh
COPY --from=boost /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD eiquadprog .
RUN --mount=type=cache,target=/root/.cache sccache -s \
 && ${PYTHON} -m pip install --extra-index-url file:///wh /wh/*.whl \
 && ${PYTHON} -m pip wheel --no-build-isolation --extra-index-url file:///wh -w /wh .

FROM main as tsid

COPY --from=eigen /wh /wh
COPY --from=eiquadprog /wh /wh
COPY --from=pinocchio /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD tsid .
RUN --mount=type=cache,target=/root/.cache sccache -s \
 && ${PYTHON} -m pip install --extra-index-url file:///wh /wh/*.whl \
 && ${PYTHON} -m pip wheel --no-build-isolation --extra-index-url file:///wh -w /wh .

FROM main as ndcurves

COPY --from=pinocchio /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD ndcurves .
RUN --mount=type=cache,target=/root/.cache sccache -s \
 && ${PYTHON} -m pip install --extra-index-url file:///wh /wh/*.whl \
 && ${PYTHON} -m pip wheel --no-build-isolation --extra-index-url file:///wh -w /wh .

FROM main as cppad

COPY --from=cmeel /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD cmeel-cppad .
RUN --mount=type=cache,target=/root/.cache sccache -s \
 && ${PYTHON} -m pip install --extra-index-url file:///wh /wh/*.whl \
 && ${PYTHON} -m pip wheel --no-build-isolation --extra-index-url file:///wh -w /wh .

FROM main as pycppad

COPY --from=eigenpy /wh /wh
COPY --from=cppad /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD pycppad .
RUN --mount=type=cache,target=/root/.cache sccache -s \
 && ${PYTHON} -m pip install --extra-index-url file:///wh /wh/*.whl \
 && ${PYTHON} -m pip wheel --no-build-isolation --extra-index-url file:///wh -w /wh .

FROM main as crocoddyl

COPY --from=example-robot-data /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD crocoddyl .
ENV CMEEL_JOBS=6
RUN --mount=type=cache,target=/root/.cache sccache -s \
 && ${PYTHON} -m pip install --extra-index-url file:///wh /wh/*.whl \
 && ${PYTHON} -m pip install scipy \
 && ${PYTHON} -m pip wheel --no-build-isolation --extra-index-url file:///wh -w /wh .

FROM main as wh

COPY --from=cmeel-example /wh /wh
COPY --from=tsid /wh /wh
COPY --from=ndcurves /wh /wh
COPY --from=cppad /wh /wh
COPY --from=crocoddyl /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh

FROM python:3.12

COPY --from=wh /wh /wh
ENV PYTHON=python
RUN ${PYTHON} -m pip install -U pip
RUN ${PYTHON} -m pip install --extra-index-url file:///wh /wh/*.whl
ADD meta/test.py .
RUN ${PYTHON} test.py
RUN assimp
