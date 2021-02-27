## build and install zmq
cd /usr/src/
VERSION="4.2.0"
curl -O -J -L https://github.com/zeromq/libzmq/releases/download/v4.2.0/zeromq-${VERSION}.tar.gz
tar xvzf zeromq-${VERSION}.tar.gz
apt-get update && apt-get install -y vim run	
cd zeromq-${VERSION}
./configure
make && make install
ldconfig
ldconfig -p | grep zmq

## build and install zmq php module
cd /usr/src/
git clone git://github.com/mkoppanen/php-zmq.git
cd php-zmq/
phpize
./configure
make && make install
