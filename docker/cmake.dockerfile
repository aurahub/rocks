FROM lizongti/lime:base

COPY /docker/cmake.sh /
ENTRYPOINT ["sh", "cmake.sh"]