FROM debian:sid

MAINTAINER Patrick Sier <pjsier@gmail.com>

RUN \
  apt-get update && \
  apt-get install -y openjdk-8-jre wget

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

RUN mkdir -p /var/otp && wget -O /var/otp/otp.jar http://maven.conveyal.com.s3.amazonaws.com/org/opentripplanner/otp/0.19.0/otp-0.19.0-shaded.jar

ENV OTP_BASE /var/otp
ENV OTP_GRAPHS /var/otp/graphs

RUN \
  mkdir -p /var/otp/graphs && \
  wget -P /var/otp/graphs http://data.trilliumtransit.com/gtfs/path-nj-us/path-nj-us.zip && \
  wget -P /var/otp/graphs https://s3.amazonaws.com/metro-extracts.mapzen.com/new-york_new-york.osm.pbf && \
  java -Xmx8G -jar /var/otp/otp.jar --build /var/otp/graphs

EXPOSE 8080
EXPOSE 8081

ENTRYPOINT [ "java", "-Xmx6G", "-Xverify:none", "-jar", "/var/otp/otp.jar" ]

CMD [ "--help" ]
