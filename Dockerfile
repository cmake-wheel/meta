FROM quay.io/pypa/manylinux_2_24_x86_64 as main

WORKDIR /src
ARG PYTHON=python3.10
ENV PYTHON=${PYTHON} URL="git+https://github.com/cmake-wheel"
RUN --mount=type=cache,target=/root/.cache ${PYTHON} -m pip install simple503

ENV CTEST_PARALLEL_LEVEL=6

FROM main as cmeel

ADD https://api.github.com/repos/cmake-wheel/cmeel/commits/main .
RUN --mount=type=cache,target=/root/.cache ${PYTHON} -m pip wheel --extra-index-url file:///wh -w /wh ${URL}/cmeel

FROM main as cmeel-example

COPY --from=cmeel /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD https://api.github.com/repos/cmake-wheel/cmeel-example/commits/main .
RUN --mount=type=cache,target=/root/.cache ${PYTHON} -m pip wheel --extra-index-url file:///wh -w /wh ${URL}/cmeel-example

FROM main as eigen

COPY --from=cmeel /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD https://api.github.com/repos/cmake-wheel/cmeel-eigen/commits/main .
RUN --mount=type=cache,target=/root/.cache ${PYTHON} -m pip wheel --extra-index-url file:///wh -w /wh ${URL}/cmeel-eigen

FROM main as boost

COPY --from=cmeel /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD https://api.github.com/repos/cmake-wheel/cmeel-boost/commits/main .
RUN --mount=type=cache,target=/root/.cache ${PYTHON} -m pip wheel --extra-index-url file:///wh -w /wh ${URL}/cmeel-boost

FROM main as eigenpy

COPY --from=eigen /wh /wh
COPY --from=boost /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD https://api.github.com/repos/cmake-wheel/eigenpy/commits/cmeel .
RUN --mount=type=cache,target=/root/.cache ${PYTHON} -m pip wheel --extra-index-url file:///wh -w /wh ${URL}/eigenpy

FROM main as assimp

COPY --from=cmeel /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD https://api.github.com/repos/cmake-wheel/cmeel-assimp/commits/main .
RUN --mount=type=cache,target=/root/.cache ${PYTHON} -m pip wheel --extra-index-url file:///wh -w /wh ${URL}/cmeel-assimp

FROM main as octomap

COPY --from=cmeel /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD https://api.github.com/repos/cmake-wheel/cmeel-octomap/commits/main .
RUN --mount=type=cache,target=/root/.cache ${PYTHON} -m pip wheel --extra-index-url file:///wh -w /wh ${URL}/cmeel-octomap

FROM main as hpp-fcl

COPY --from=assimp /wh /wh
COPY --from=octomap /wh /wh
COPY --from=eigenpy /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD https://api.github.com/repos/cmake-wheel/hpp-fcl/commits/cmeel .
RUN --mount=type=cache,target=/root/.cache ${PYTHON} -m pip wheel --extra-index-url file:///wh -w /wh ${URL}/hpp-fcl

FROM main as urdfdom-headers

COPY --from=cmeel /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD https://api.github.com/repos/cmake-wheel/cmeel-urdfdom-headers/commits/main .
RUN --mount=type=cache,target=/root/.cache ${PYTHON} -m pip wheel --extra-index-url file:///wh -w /wh ${URL}/cmeel-urdfdom-headers


FROM main as console-bridge

COPY --from=cmeel /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD https://api.github.com/repos/cmake-wheel/cmeel-console-bridge/commits/main .
RUN --mount=type=cache,target=/root/.cache ${PYTHON} -m pip wheel --extra-index-url file:///wh -w /wh ${URL}/cmeel-console-bridge

FROM main as tinyxml

COPY --from=cmeel /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD https://api.github.com/repos/cmake-wheel/cmeel-tinyxml/commits/main .
RUN --mount=type=cache,target=/root/.cache ${PYTHON} -m pip wheel --extra-index-url file:///wh -w /wh ${URL}/cmeel-tinyxml

FROM main as urdfdom

COPY --from=urdfdom-headers /wh /wh
COPY --from=tinyxml /wh /wh
COPY --from=console-bridge /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD https://api.github.com/repos/cmake-wheel/cmeel-urdfdom/commits/main .
RUN --mount=type=cache,target=/root/.cache ${PYTHON} -m pip wheel --extra-index-url file:///wh -w /wh ${URL}/cmeel-urdfdom

FROM main as pinocchio

COPY --from=hpp-fcl /wh /wh
COPY --from=urdfdom /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD https://api.github.com/repos/cmake-wheel/pinocchio/commits/cmeel .
RUN --mount=type=cache,target=/root/.cache ${PYTHON} -m pip wheel --extra-index-url file:///wh -w /wh ${URL}/pinocchio

FROM main as example-robot-data

COPY --from=pinocchio /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD https://api.github.com/repos/cmake-wheel/example-robot-data/commits/cmeel .
RUN --mount=type=cache,target=/root/.cache ${PYTHON} -m pip wheel --extra-index-url file:///wh -w /wh ${URL}/example-robot-data

FROM main as eiquadprog

COPY --from=eigen /wh /wh
COPY --from=boost /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD https://api.github.com/repos/cmake-wheel/eiquadprog/commits/cmeel .
RUN --mount=type=cache,target=/root/.cache ${PYTHON} -m pip wheel --extra-index-url file:///wh -w /wh ${URL}/eiquadprog

FROM main as tsid

COPY --from=eiquadprog /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD https://api.github.com/repos/cmake-wheel/tsid/commits/cmeel .
RUN --mount=type=cache,target=/root/.cache ${PYTHON} -m pip wheel --extra-index-url file:///wh -w /wh ${URL}/tsid

FROM main as crocoddyl

COPY --from=example-robot-data /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
ADD https://api.github.com/repos/cmake-wheel/crocoddyl/commits/cmeel .
RUN --mount=type=cache,target=/root/.cache ${PYTHON} -m pip wheel --extra-index-url file:///wh -w /wh ${URL}/crocoddyl

FROM main as wh

COPY --from=cmeel-example /wh /wh
COPY --from=crocoddyl /wh /wh
COPY --from=tsid /wh /wh
RUN ${PYTHON} -m simple503 -B file:///wh /wh
RUN --mount=type=cache,target=/root/.cache ${PYTHON} -m pip install --extra-index-url file:///wh example-robot-data

FROM python:3.10

COPY --from=wh /wh /wh
ENV PYTHON=python
RUN --mount=type=cache,target=/root/.cache ${PYTHON} -m pip install --extra-index-url file:///wh example-robot-data
RUN ${PYTHON} -c "import tsid"
RUN ${PYTHON} -c "import crocoddyl"
RUN assimp
