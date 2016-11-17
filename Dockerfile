FROM debian:sid

MAINTAINER Patrick Sier <pjsier@gmail.com>

RUN \
  apt-get update && \
  apt-get install -y openjdk-8-jre wget

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

RUN \
  mkdir -p /var/otp && \
  wget -O /var/otp/otp.jar http://maven.conveyal.com.s3.amazonaws.com/org/opentripplanner/otp/1.0.0-SNAPSHOT/otp-1.0.0-20160907.171847-43-shaded.jar && \
  wget -O /var/otp/jython.jar http://search.maven.org/remotecontent?filepath=org/python/jython-standalone/2.7.0/jython-standalone-2.7.0.jar

ENV OTP_BASE /var/otp
ENV OTP_GRAPHS /var/otp/graphs

RUN \
  mkdir -p /var/otp/scripting && \
  mkdir -p /var/otp/graphs/newark && \
  wget -O /var/otp/graphs/newark/nj-bus.zip http://mapzen.github.io/transitland-internal/gtfs-archives-not-for-redistribution/nj-transit-bus.zip && \
  wget -O /var/otp/graphs/newark/nj-rail.zip http://mapzen.github.io/transitland-internal/gtfs-archives-not-for-redistribution/nj-transit-rail.zip && \
  wget -P /var/otp/graphs/newark https://s3.amazonaws.com/metro-extracts.mapzen.com/new-york_new-york.osm.pbf && \
  java -Xmx8G -jar /var/otp/otp.jar --build /var/otp/graphs/newark

EXPOSE 8080
EXPOSE 8081
ENTRYPOINT [ "java", "-Xmx6G", "-Xverify:none", "-cp", "/var/otp/otp.jar:/var/otp/jython.jar", "org.opentripplanner.standalone.OTPMain" ]

CMD [ "--help" ]
