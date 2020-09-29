FROM centos:7

RUN \
    # Repo
    rpm -ivh https://mirrors.ustc.edu.cn/epel/epel-release-latest-7.noarch.rpm && \
    yum update -y && \
    # Development
    yum groupinstall -y "Development tools" && \
    yum install -y cmake && \
    # Common
    yum install -y jemalloc-devel && \
    yum install -y libuv-devel && \
    yum install -y boost-devel && \
    # Http
    yum install -y libcurl-devel && \
    yum install -y libmicrohttpd-devel && \
    # MessageQueue
    yum install -y cppzmq-devel && \
    yum install -y librabbitmq-devel && \
    yum install -y librdkafka-devel && \
    yum install -y activemq-cpp-devel && \
    yum install -y mosquitto-devel && \
    # Database   
    yum install -y mysql-devel && \
    yum install -y mysql++-devel && \
    yum install -y hiredis-devel && \
    yum install -y mongo-cxx-driver-devel  && \
    # Log
    yum install -y log4cplus-devel && \
    yum install -y spdlog-devel && \
    yum install -y glog-devel && \
    yum install -y syslog-ng-devel && \
    # Serialization
    yum install -y rapidjson-devel && \
    yum install -y protobuf-devel && \
    yum install -y msgpack-devel && \
    yum install -y cereal-devel && \
    yum install -y capnproto-devel && \
    yum install -y thrift-devel && \
    # Configuration
    yum install -y yaml-cpp-devel && \
    yum install -y tinyxml2-devel && \
    yum install -y iniparser-devel && \
    # VirtualMachine
    yum install -y luajit-devel && \
    yum install -y tolua++-devel && \
    yum install -y v8-devel && \
    yum install -y pypy-devel
