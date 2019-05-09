ARG PYTHON_VERSION=${PYTHON_VERSION:-latest}
FROM astroconda/datb-tc-python:${PYTHON_VERSION}

# Declare environment
ENV OPT=/opt \
    HOME=/home/jenkins \
    PYTHONUNBUFFERED=1

# Toolchain
RUN yum update -y && yum install -y \
        bzip2-devel \
        curl \
        git \
        glibc-devel.i686 \
        glibc-devel \
        hg \
        java-1.8.0-openjdk-devel \
        kernel-devel \
        libX11-devel \
        mesa-libGL \
        mesa-libGLU \
        ncurses-devel \
        openssh-server \
        subversion \
        sudo \
        wget \
        zlib-devel \
    && yum clean all

# SSH Server configuration
# Create 'jenkins' user
# Configure sudoers
RUN sed -i 's|#UseDNS.*|UseDNS no|' /etc/ssh/sshd_config \
    && ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa \
    && ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa \
    && groupadd jenkins \
    && useradd -g jenkins -m -d $HOME -s /bin/bash jenkins \
    && echo "jenkins:jenkins" | chpasswd \
    && echo "jenkins ALL=(ALL)    NOPASSWD: ALL" >> /etc/sudoers \
    && chown -R jenkins:jenkins ${TOOLCHAIN}


# Inject custom handlers
RUN curl -L https://github.com/krallin/tini/releases/download/v0.18.0/tini-static-amd64 > /usr/bin/tini \
    && chmod +x /usr/bin/tini

ADD with_env /usr/local/bin
ADD spawner.sh /usr/local/bin

WORKDIR ${HOME}

EXPOSE 22
ENTRYPOINT ["tini", "-g", "--", "spawner.sh"]
CMD ["/bin/bash"]
