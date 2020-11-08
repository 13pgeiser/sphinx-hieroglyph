#!/bin/bash
set -ex
if [ "$OSTYPE" == "msys" ]; then
	export MSYS_NO_PATHCONV=1
	export USER="$USERNAME"
fi
if [ -z "$USER" ]; then
	echo "USER is not set --> using host_user!"
	export USER="host_user"
fi
IMAGE_NAME="${USER}_sphinx-hieroglyph"
docker run --rm -v "$(pwd)":/mnt --user "$(id -u)":"$(id -g)" mvdan/shfmt -w /mnt/docker.sh
docker run --rm -e SHELLCHECK_OPTS="" -v "$(pwd)":/mnt koalaman/shellcheck:stable -x docker.sh
docker build -t "$IMAGE_NAME" . --build-arg UID="$(id -u)" --build-arg GID="$(id -g)" --build-arg USER="$USER"
DOCKER_RUN="docker run -i --rm -v $(pwd):/mnt --name ${IMAGE_NAME}_container $IMAGE_NAME"
if [ $# -eq 0 ]; then
	$DOCKER_RUN python3 -m pip wheel . -w dist
	$DOCKER_RUN /bin/bash -s - <<EOF
cd dist
find . -type f -printf '[%P](%p)  \n' >index.md
python3 -m markdown2 index.md >index.html
EOF
else
	$DOCKER_RUN "$@"
fi
