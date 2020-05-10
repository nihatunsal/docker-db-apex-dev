FROM oraclelinux:7.7

MAINTAINER Daniel Hochleitner <dhochleitner@posteo.de>

# environment variables
ENV INSTALL_APEX=true \
    INSTALL_SQLCL=true \
    INSTALL_SQLDEVWEB=true \
    INSTALL_LOGGER=true \
    INSTALL_OOSUTILS=true \
    INSTALL_AOP=true \
    INSTALL_SWAGGER=true \
    INSTALL_CA_CERTS_WALLET=true \
    DBCA_TOTAL_MEMORY=2048 \
    ORACLE_SID=orcl \
    SERVICE_NAME=orcl \
    DB_INSTALL_VERSION=19 \
    ORACLE_BASE=/u01/app/oracle \
    ORACLE_HOME12=/u01/app/oracle/product/12.2.0.1/dbhome \
    ORACLE_HOME18=/u01/app/oracle/product/18.0.0/dbhome \
    ORACLE_HOME19=/u01/app/oracle/product/19.0.0/dbhome \
    ORACLE_INVENTORY=/u01/app/oraInventory \
    PASS=oracle \
    ORDS_HOME=/u01/ords \
    JAVA_HOME=/opt/java \
    TOMCAT_HOME=/opt/tomcat \
    APEX_PASS=OrclAPEX1999! \
    APEX_ADDITIONAL_LANG= \
    TIME_ZONE=UTC

# copy all scripts
ADD scripts /scripts/

# copy all files
ADD files /files/

RUN yum update && yum install -y dos2unix

# image setup via shell script to reduce layers and optimize final disk usage
RUN dos2unix /scripts/install_main.sh && dos2unix /scripts/validations.sh && dos2unix /scripts/create_ca_wallet.sh && dos2unix /scripts/entrypoint.sh 
RUN dos2unix /scripts/image_setup.sh && dos2unix /scripts/install_aop.sh
RUN dos2unix /scripts/install_apex.sh && dos2unix /scripts/install_ca_wallet.sh
RUN dos2unix /scripts/install_java.sh && dos2unix /scripts/install_logger.sh
RUN dos2unix /scripts/install_oosutils.sh && dos2unix /scripts/install_oracle19ee.sh
RUN dos2unix /scripts/install_ords.sh && dos2unix /scripts/install_swagger.sh
RUN dos2unix /scripts/install_tomcat.sh && dos2unix /scripts/setenv.sh && dos2unix /scripts/install_ssh.sh
RUN dos2unix /scripts/entrypoint.sh

RUN /scripts/install_main.sh

# ssh, database and apex port
EXPOSE 22 1521 8080

# use ${ORACLE_BASE} without product subdirectory as data volume
VOLUME ["${ORACLE_BASE}"]

# entrypoint for database creation, startup and graceful shutdown
ENTRYPOINT ["/scripts/entrypoint.sh"]
