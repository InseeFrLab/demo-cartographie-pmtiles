# https://github.com/felt/tippecanoe?tab=readme-ov-file#installation
#apt-get update --yes
# dépendances tippecanoe
#apt-get install git build-essential libsqlite3-dev zlib1g-dev --yes
# install tippecanoe
git clone https://github.com/felt/tippecanoe.git && cd tippecanoe && make -j && make install
