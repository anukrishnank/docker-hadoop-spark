FROM ubuntu:16.04
MAINTAINER Anu krishnan<a4anukrishnan@gmail.com>

# Install dependencies
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-8-jdk && \
    rm -rf /var/lib/apt/lists/*

# Install Hadoop
ENV HADOOP_VERSION=2.8.0
ENV HADOOP_HOME=/usr/local/hadoop

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y wget vim curl tar sudo openssh-server openssh-client && \
    wget http://archive.apache.org/dist/hadoop/core/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz && \
    apt-get remove -y wget && \
    rm -rf /var/lib/apt/lists/* && \
    tar -zxf /hadoop-$HADOOP_VERSION.tar.gz && \
    rm /hadoop-$HADOOP_VERSION.tar.gz && \
    mv hadoop-$HADOOP_VERSION /usr/local/hadoop && \
    mkdir -p /usr/local/hadoop/logs

RUN rm -f /etc/ssh/ssh_host_dsa_key /etc/ssh/ssh_host_rsa_key /root/.ssh/id_rsa
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa
RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys
RUN sudo service ssh start

# Set paths
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop \
  HADOOP_LIBEXEC_DIR=$HADOOP_HOME/libexec \
  PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

# Copy and fix configuration files
COPY /conf/* $HADOOP_CONF_DIR/

RUN mkdir -p /data/dfs/data /data/dfs/name /data/dfs/namesecondary && \
    hdfs namenode -format
VOLUME /data

EXPOSE 9000 50070 50010 50020 50075 50090
