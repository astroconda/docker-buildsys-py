PYTHON_VERSION=${PYTHON_VERSION:-}
HUB=${HUB:-}

if [[ -n ${1} ]]; then
    PYTHON_VERSION=${1}
fi

if [[ -n ${2} ]]; then
    HUB=${2}
fi


if [[ -z ${PYTHON_VERSION} ]]; then
    echo "Missing python version (format: x.y.z)"
    exit 1
fi

if [[ -z ${HUB} ]]; then
    echo "Missing dockerhub repo (format: reponame)"
    exit 1
fi

short_version=${PYTHON_VERSION/./}
if [[ ${#short_version} < 2 ]]; then
    echo "Python version is too short. Must be in x.y.z format"
    exit 1
fi
short_version=${short_version:0:2}
IMAGE="buildsys-py${short_version}"

docker tag ${IMAGE} ${HUB}/${IMAGE}
docker push ${HUB}/${IMAGE}
