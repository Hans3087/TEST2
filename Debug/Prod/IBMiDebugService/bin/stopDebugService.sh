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
# Shell script to start IBM i Debug Service
#
# Beginning of user settings
#
# A Java 8 JRE is required to run IBM i Debug Service as a headless Eclipse application.
# Uncomment the following line to set your own JRE; otherwise the JRE is picked up from the 
# JAVA_HOME environment variable.
# MY_JAVA_HOME=/QOpenSys/QIBM/ProdData/JavaVM/jdk80/64bit

# Installation root and workspace directory are set in the environment file DebugService.env.
# The user can set the following variables to override the global settings.
#
# Uncomment the following line for a local IBM i Debug Service installation
# MY_DBGSVR_ROOT=/home/myid/IBMiDebugService

# Uncomment the following line to set a local workspace directory for this Eclipse instance.
# MY_STOP_DBGSVR_Workspace=$MY_DBGSVR_ROOT/workspaces/stopDebugService_workspace

# End of user settings (do not modify anything after this line)

# DebugService.env is located under the same parent directory as this shell script.
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

# Use regular expression to match the Equinox launcher jar
_launcher_jar="${PARENT_PATH}/../plugins/org.eclipse.equinox.launcher*.jar"

_launcher_class=org.eclipse.equinox.launcher.Main	
_daas_application=com.ibm.etools.iseries.daas.application

# Find the launcher jar under the plugins folder
_launcher_jar=`find ${_launcher_jar}`
if [ -z "${_launcher_jar}" ]; then	
    echo "Cannot find the jar file for the org.eclipse.equinox.launcher plugin."   
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

# If MY_DBGSVR_ROOT is set, use the local installation folder.
if [ -n "${MY_DBGSVR_ROOT}" ]; then	
  DBGSRV_ROOT=$MY_DBGSVR_ROOT
fi

# If MY_STOP_DBGSVR_Workspace is set, use the local workspace
if [ -n "${MY_STOP_DBGSVR_Workspace}" ]; then	
  STOP_DBGSVR_WRK_DIR=$MY_STOP_DBGSVR_Workspace
fi

CMDLINE_OPTS="-classpath ${_launcher_jar} ${_launcher_class}"
CMDLINE_OPTS="${CMDLINE_OPTS} -application ${_daas_application}"
CMDLINE_OPTS="${CMDLINE_OPTS} -data ${STOP_DBGSVR_WRK_DIR}"
CMDLINE_OPTS="${CMDLINE_OPTS} -shutdown=${DBGSRV_PORT}"

exec $JAVA_HOME/bin/java ${CMDLINE_OPTS} $*
