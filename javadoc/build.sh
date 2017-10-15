#!/usr/bin/env bash

JAVADOC_TARGET=./../_book/misc/javadoc

if [ ! -x build.sh ]; then
  echo "This command must be run from the _build directory, not its parent."
  exit 1
fi

if [ -z "$BROOKLYN_JAVADOC_SOURCE_PATHS" ]; then
  echo "Detecting source paths for javadoc ..."
  export SOURCE_PATHS=`find ../.. -name java | grep "src/main/java$" | grep -v "^../../sandbox" | tr "\\n" ":"`
else
  echo "Using pre-defined source paths: $BROOKLYN_JAVADOC_SOURCE_PATHS"
  export SOURCE_PATHS=$BROOKLYN_JAVADOC_SOURCE_PATHS
fi

mkdir -p $JAVADOC_TARGET

export YEARSTAMP=`date "+%Y"`
export DATESTAMP=`date "+%Y-%m-%d"`
export SHA1STAMP=`git rev-parse HEAD`

# BROOKLYN_VERSION_BELOW
export BROOKLYN_JAVADOC_CLASSPATH=$( mvn -f ../../pom.xml --projects :brooklyn-all dependency:build-classpath | grep -E -v '^\[[A-Z]+\]' )

echo "Building javadoc at $DATESTAMP from:
$SOURCE_PATHS"

javadoc -sourcepath $SOURCE_PATHS \
  -public \
  -d $JAVADOC_TARGET \
  -subpackages "org.apache.brooklyn:io.brooklyn:brooklyn" \
  -classpath "$BROOKLYN_JAVADOC_CLASSPATH" \
  -doctitle "Apache Brooklyn" \
  -windowtitle "Apache Brooklyn" \
  -notimestamp \
  -stylesheetfile stylesheet.css \
  -overview overview.html \
  -header '<a href="/" class="brooklyn-header">Apache Brooklyn</a>' \
  -footer '<strong>Apache Brooklyn - Multi-Cloud Application Management</strong> <br/> <a href="https://brooklyn.apache.org" target="_top">brooklyn.apache.org</a>. Apache License. &copy; '$YEARSTAMP'.' \
2>&1 1>/dev/null | tee javadoc.log

if ((${PIPESTATUS[0]})); then
  echo "WARNING: javadoc process exited non-zero";
fi

if [ ! -f $JAVADOC_TARGET/org/apache/brooklyn/api/entity/Entity.html ]; then
  echo "ERROR: missing expected content. Are the paths right?";
  exit 1;
fi

if [ ! -z "`grep warnings javadoc.log`" ]; then
  echo "WARNINGs occurred during javadoc build. See javadoc.log for more information.";
fi

sed -i.bak s/'${DATESTAMP}'/"${DATESTAMP}"/ $JAVADOC_TARGET/overview-summary.html
sed -i.bak s/'${SHA1STAMP}'/"${SHA1STAMP}"/ $JAVADOC_TARGET/overview-summary.html
rm $JAVADOC_TARGET/*.bak
