FROM openjdk:8-jre
MAINTAINER Anu krishnan<a4anukrishnan@gmail.com>

# Set home
ENV HADOOP_HOME=/usr/local/hadoop-2.8.0

# Install dependencies
RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install \
    -yq --no-install-recommends netcat \
  && apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# Install Hadoop
RUN mkdir -p "${HADOOP_HOME}" \
  && curl -sSL https://mirrors.ocf.berkeley.edu/apache/hadoop/common/hadoop-2.8.0/hadoop-2.8.0.tar.gz | \
    tar -xz -C $HADOOP_HOME --strip-components 1 \
  && rm -rf hadoop-2.8.0.tar.gz

# HDFS volume
VOLUME /opt/hdfs

# Set paths
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop \
  HADOOP_LIBEXEC_DIR=$HADOOP_HOME/libexec \
  PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

# Copy and fix configuration files
COPY /conf/*.xml $HADOOP_CONF_DIR/
RUN sed -i.bak "s/hadoop-daemons.sh/hadoop-daemon.sh/g" \
    $HADOOP_HOME/sbin/start-dfs.sh \
  && rm -f $HADOOP_HOME/sbin/start-dfs.sh.bak \
  && sed -i.bak "s/hadoop-daemons.sh/hadoop-daemon.sh/g" \
    $HADOOP_HOME/sbin/stop-dfs.sh \
  && rm -f $HADOOP_HOME/sbin/stop-dfs.sh.bak

# HDFS
EXPOSE 8020 14000 50070 50470

# MapReduce
EXPOSE 10020 13562	19888

# Fix environment for other users
RUN echo "export HADOOP_HOME=$HADOOP_HOME" > /etc/bash.bashrc.tmp \
  && echo 'export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin'>> /etc/bash.bashrc.tmp \
  && cat /etc/bash.bashrc >> /etc/bash.bashrc.tmp \
  && mv -f /etc/bash.bashrc.tmp /etc/bash.bashrc
