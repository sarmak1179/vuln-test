#!/bin/sh

echo "Downloading latest container-structure-test binary..."

wget -O container-structure-test -nv "${CONTAINER_STRUCTURE_TEST_DOWNLOAD_URL}" \
  && mv container-structure-test /usr/local/bin \
  && chmod +x /usr/local/bin/container-structure-test \
  && export PATH=$PATH:/usr/local/bin

container-structure-test $@
