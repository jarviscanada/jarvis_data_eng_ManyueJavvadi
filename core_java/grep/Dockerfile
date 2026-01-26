FROM eclipse-temurin:8-jre-alpine

COPY target/grep-1.0-SNAPSHOT-shaded.jar /usr/local/app/grep/lib/grep.jar

ENTRYPOINT ["java","-jar","/usr/local/app/grep/lib/grep.jar"]
