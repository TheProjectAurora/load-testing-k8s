FROM openjdk:8-jdk-slim
		
ARG JMETER_VERSION=5.4.1
		
RUN apt-get clean && \
apt-get update && \
apt-get -qy install \
wget \
telnet \
iputils-ping \
unzip \
curl \
procps
RUN   mkdir /jmeter \
&& cd /jmeter/ \
&& wget –q https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-$JMETER_VERSION.tgz || true
RUN   cd /jmeter/ \
&& tar -xzf apache-jmeter-$JMETER_VERSION.tgz \
&& rm apache-jmeter-$JMETER_VERSION.tgz

RUN cd /jmeter/apache-jmeter-$JMETER_VERSION/ && wget -q -O /tmp/JMeterPlugins-Standard-1.4.0.zip https://jmeter-plugins.org/downloads/file/JMeterPlugins-Standard-1.4.0.zip && unzip -n /tmp/JMeterPlugins-Standard-1.4.0.zip && rm /tmp/JMeterPlugins-Standard-1.4.0.zip

RUN wget -q -O /jmeter/apache-jmeter-$JMETER_VERSION/lib/ext/pepper-box-1.0.jar https://github.com/raladev/load/blob/master/JARs/pepper-box-1.0.jar?raw=true

RUN cd /jmeter/apache-jmeter-$JMETER_VERSION/ && wget -q -O /tmp/bzm-parallel-0.10.zip https://jmeter-plugins.org/files/packages/bzm-parallel-0.10.zip && unzip -n /tmp/bzm-parallel-0.10.zip && rm /tmp/bzm-parallel-0.10.zip

RUN cd /jmeter/apache-jmeter-$JMETER_VERSION/ && wget -q -O /tmp/jpgc-casutg-2.9.zip  https://jmeter-plugins.org/files/packages/jpgc-casutg-2.9.zip && unzip -n /tmp/jpgc-casutg-2.9.zip && rm /tmp/jpgc-casutg-2.9.zip

ENV JMETER_HOME /jmeter/apache-jmeter-$JMETER_VERSION/
		
ENV PATH $JMETER_HOME/bin:$PATH
