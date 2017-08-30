FROM ubuntu:14.04
MAINTAINER kavemun <kahmun.chow@gmail.com>

ENV DISTRO ubuntu
ENV CODENAME trusty
 
# Add R list
RUN echo 'deb http://cran.rstudio.com/bin/linux/ubuntu trusty/' | \
    sudo tee -a /etc/apt/sources.list.d/r.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9

# Add mesos repository
RUN echo 'deb http://repos.mesosphere.com/ubuntu trusty main' | \
    sudo tee /etc/apt/sources.list.d/mesosphere.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF

# packages
RUN apt-get update && apt-get install -yq --no-install-recommends --force-yes \
    wget \
    git \
    openjdk-7-jdk \
    maven \
    libjansi-java \
    libsvn1 \
    libcurl3 \
    libsasl2-modules\
    python \
    python-dev \
    python-pip \
    mesos && \
    rm -rf /var/lib/apt/lists/*

# install python packages
RUN pip install -U 'requests' 'setuptools' 'flake8' 'flaky'

# Overall ENV vars
ENV SPARK_VERSION 2.1.1
ENV MESOS_BUILD_VERSION 0.28.0-2.0.16
ENV LIVY_BUILD_VERSION livy-server-0.4.0-SNAPSHOT

# Set install path for Livy
ENV LIVY_APP_PATH /apps/$LIVY_BUILD_VERSION

# Set build path for Livy
ENV LIVY_BUILD_PATH /apps/build/livy

# Set Hadoop config directory
ENV HADOOP_CONF_DIR /etc/hadoop/conf

# Set Spark home directory
ENV SPARK_HOME /usr/local/spark

# Set native Mesos library path
ENV MESOS_NATIVE_JAVA_LIBRARY /usr/local/lib/libmesos.so

# Spark ENV vars
ENV SPARK_VERSION_STRING spark-$SPARK_VERSION-bin-hadoop2.7
ENV SPARK_DOWNLOAD_URL https://d3kbcqa49mib13.cloudfront.net/$SPARK_VERSION_STRING.tgz 

# Download and unzip Spark
RUN wget $SPARK_DOWNLOAD_URL && \
    mkdir -p $SPARK_HOME && \
    tar xvf $SPARK_VERSION_STRING.tgz -C /tmp && \
    cp -rf /tmp/$SPARK_VERSION_STRING/* $SPARK_HOME && \
    rm -rf -- /tmp/$SPARK_VERSION_STRING && \
    rm $SPARK_VERSION_STRING.tgz

# Clone Livy repository
RUN mkdir -p /apps/build && \
    cd /apps/build && \
	git clone https://github.com/cloudera/livy.git && \
	cd $LIVY_BUILD_PATH && \
    mvn -DskipTests -Dspark.version=$SPARK_VERSION clean package && \
    unzip $LIVY_BUILD_PATH/assembly/target/$LIVY_BUILD_VERSION.zip -d /apps && \
    rm -rf $LIVY_BUILD_PATH && \
	mkdir -p $LIVY_APP_PATH/upload && \ 
        mkdir -p $LIVY_APP_PATH/logs
	
# Add custom files, set permissions
ADD entrypoint.sh .

RUN chmod +x entrypoint.sh

# Expose port
EXPOSE 8998

ENTRYPOINT ["/entrypoint.sh"]
