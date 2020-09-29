FROM lizongti/lime:base

RUN yum install -y -q openssh-server && ssh-keygen -A && sed -n 's/#PermitRootLogin/PermitRootLogin/g' /etc/ssh/sshd_config && echo 'root:root' | chpasswd
ENTRYPOINT ["/usr/sbin/sshd", "-D"]