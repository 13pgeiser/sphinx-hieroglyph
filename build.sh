#!/bin/bash
set -ex
source bash-helpers/helpers.sh
docker_setup "sphinx-hieroglyph"
dockerfile_create
dockerfile_setup_python
echo "RUN python3 -m pip install --no-cache-dir markdown2" >>"$DOCKERFILE"
dockerfile_switch_to_user
docker_build_image_and_create_volume
run_shfmt_and_shellcheck
if [ $# -eq 0 ]; then
	$DOCKER_RUN_I python3 -m pip wheel . -w dist
	$DOCKER_RUN_I /bin/bash -s - <<EOF
cd dist
find . -type f -printf '[%P](%p)  \n' >index.md
python3 -m markdown2 index.md >index.html
EOF
else
	$DOCKER_RUN_IT "$@"
fi
