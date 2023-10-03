# Use CentOS 6 as the base image
FROM centos:6

# # Set environment variables to non-interactive (this prevents some prompts)
# ENV DEBIAN_FRONTEND=noninteractive

# Update CentOS 6 to use the Vault repository
RUN curl -fsSL https://www.getpagespeed.com/files/centos6-eol.repo -o /etc/yum.repos.d/CentOS-Base.repo

# Install build tools and dependencies for Subversion, Neon, JDK, and g++
RUN yum clean all && \
    yum -y update && \
    yum install -y gcc make unzip zlib-devel curl tar apr-devel apr-util-devel httpd-devel sqlite-devel perl perl-ExtUtils-Embed java-1.8.0-openjdk-devel g++ && \
    yum clean all && \
    rm -rf /var/cache/yum

# Download, unpack, and install Neon 0.28.3
RUN cd /tmp && \
    curl -fsSL -O http://www.webdav.org/neon/neon-0.28.3.tar.gz && \
    tar xzf neon-0.28.3.tar.gz && \
    mv neon-0.28.3 /usr/local/neon && \
    cd /usr/local/neon && \
    ./configure && \
    make && \
    make install && \
    cd .. && \
    rm -rf /tmp/neon-0.28.3 && \    
    rm /tmp/neon-0.28.3.tar.gz

# Download SQLite 3.6.11 amalgamation
RUN cd /tmp && \
    curl -fsSL -O https://www.sqlite.org/2021/sqlite-amalgamation-3360000.zip && \
    unzip sqlite-amalgamation-3360000.zip && \
    cp sqlite-amalgamation-3360000/sqlite3.c . && \
    rm -rf sqlite-amalgamation-3360000 && \
    rm sqlite-amalgamation-3360000.zip

# Download, compile, and install SVN 1.6.0
RUN cd /tmp && \
    curl -fsSL -O https://archive.apache.org/dist/subversion/subversion-1.6.0.tar.gz && \
    tar xzf subversion-1.6.0.tar.gz && \
    mkdir -p subversion-1.6.0/sqlite-amalgamation/ && \
    cp sqlite3.c subversion-1.6.0/sqlite-amalgamation/sqlite3.c && \
    cd subversion-1.6.0 && \
    ./configure --with-apr=/usr/bin/apr-1-config --with-apr-util=/usr/bin/apu-1-config --with-apxs=/usr/sbin/apxs --with-neon=/usr/local/neon && \
    sed -i '45d' Makefile && \
    make && \
    make install && \
    cd .. && \
    rm -rf subversion-1.6.0 && \
    rm subversion-1.6.0.tar.gz

# # Explicitly set user to avoid running as root
# USER 1001

# Add a healthcheck (example)
HEALTHCHECK CMD svn --version || exit 1

