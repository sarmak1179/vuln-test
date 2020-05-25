FROM tomcat:8.0-alpine

ADD sample.war /usr/local/tomcat/webapps/

EXPOSE 8080
LABEL com.hcl.tx.manifest=$MANIFEST
LABEL vendor=vendor1 cnf=CNF-Service-1

CMD ["catalina.sh", "run"]



