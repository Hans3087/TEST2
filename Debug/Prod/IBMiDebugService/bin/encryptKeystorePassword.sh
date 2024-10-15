#!/bin/sh
#
#  		Licensed Materials - Property of IBM
#  		(C) Copyright IBM Corporation 2022. All rights reserved.
#  		US Government Users Restricted Rights - Use, duplication or disclosure
#  		restricted by GSA ADP Schedule Contract with IBM Corp.
#
#  The source code for this program is not published or otherwise
#  divested of its trade secrets, irrespective of what has been
#  deposited with the U.S. Copyright Office.
#
# Shell script to encrypt the keystore password
#
# Beginning of user settings
#
# A Java 8 JRE is required to run this application.
# Uncomment the following line to set your own JRE; otherwise the JRE is picked up from the
# JAVA_HOME environment variable.
# MY_JAVA_HOME=/QOpenSys/QIBM/ProdData/JavaVM/jdk80/64bit

# End of user settings (do not modify anything after this line)

PARENT_PATH=$(dirname "$0")

# The main environment configuration file
DBGSVR_ENVFILE=${PARENT_PATH}/DebugService.env

# Execute the environment configuration file to set global environment variables.
if [ -r "$DBGSVR_ENVFILE" ]; then
  . "$DBGSVR_ENVFILE"
else
  echo "The installation configuration file defined in environment variable DBGSVR_ENVFILE is missing or unreadable."
  echo DBGSVR_ENVFILE=$DBGSVR_ENVFILE
  exit 1
fi

# JRE is picked up from MY_JAVA_HOME if it is set, otherwise from JAVA_HOME.
if [ -n "${MY_JAVA_HOME}" ]; then	
  JAVA_HOME=$MY_JAVA_HOME	
fi

if test -x "$JAVA_HOME/bin/java"
then
   $JAVA_HOME/bin/java -version
else
  echo "Environment variable JAVA_HOME is not set or is set faulty."
  echo JAVA_HOME=$JAVA_HOME
  exit 1
fi

# Check whether the JRE version is Java 8.
check_java8_result=`$JAVA_HOME/bin/java -version 2>&1 | grep "java version \"1.8"`
if [ -z "${check_java8_result}" ]; then
    echo "Incorrect Java version. Java 8 JRE is required."
    exit 1
fi

if [ -z "${DEBUG_SERVICE_KEYSTORE_PASSWORD}" ]; then
	echo "Environment variable DEBUG_SERVICE_KEYSTORE_PASSWORD is not set."
	exit 1
fi

$JAVA_HOME/bin/java -classpath ${PARENT_PATH} EncryptPassword ${DEBUG_SERVICE_KEYSTORE_PASSWORD} ${DBGSRV_WRK_DIR}/key.properties
