#!/bin/bash

function usage {
  echo usage: `basename "$0"` db-user password [db-name]
  echo "       db-name defaults to: $DB"
  exit 12
}

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
#Be careful when using other driver versions as it may corrupt the database
DRIVER=h2-1.4.193.jar
DB=njams
TARGET=target
TEMPFILE=export.zip
CONSOLELOG=1
USER=
PWD=

if [ -z "$1" ]; then
  usage
else
  USER=$1
fi
if [ -z "$2" ]; then
  usage
else
  PWD=$2
fi
if [ ! -z "$3" ]; then
  DB=$3
fi
DBFILE=${DB}.mv.db

if [ ! -f "$DIR/$DRIVER" ]; then
  echo JDBC driver $DRIVER not found.
  exit 2
fi

if [ ! -f "$DIR/$DBFILE" ]; then
  echo Database file $DBFILE not found.
  exit 2
fi


if [ ! -d "$DIR/$TARGET" ]; then
  mkdir $DIR/$TARGET
fi


if [ -f "$DIR/$TARGET/$DBFILE" ]; then
  echo Target database already exist in: $DIR/$TARGET
  echo Please remove the files.
  exit 10
fi

if [ -z "$JAVA_HOME" ]; then
  JAVA=java
else
  JAVA=$JAVA_HOME/bin/java
fi

echo Exporting current database... Please be patient...
$JAVA -cp $DRIVER org.h2.tools.Script -url "jdbc:h2:$DIR/$DB;MVCC=true;DB_CLOSE_ON_EXIT=TRUE;AUTO_SERVER=TRUE;TRACE_LEVEL_FILE=2;TRACE_LEVEL_SYSTEM_OUT=$CONSOLELOG" -user $USER -password $PWD -script $TEMPFILE -options compression zip
EC=$?
if [ "$EC" -ne "0" ]; then
  echo Database export failed with code $EC
  if [ -f "$TEMPFILE" ]; then
    rm $TEMPFILE
  fi
  exit $EC
fi

echo Creating fresh database... Please be patient...
$JAVA -cp $DRIVER org.h2.tools.RunScript -url "jdbc:h2:$DIR/$TARGET/$DB;MVCC=true;DB_CLOSE_ON_EXIT=TRUE;AUTO_SERVER=TRUE;TRACE_LEVEL_FILE=2;TRACE_LEVEL_SYSTEM_OUT=$CONSOLELOG" -user $USER -password $PWD -script $TEMPFILE -options compression zip
EC=$?
if [ "$EC" -ne "0" ]; then
  echo Database import failed with code $EC
  exit $EC
fi

echo Database $DB successfully created in $DIR/$TARGET
rm $TEMPFILE





