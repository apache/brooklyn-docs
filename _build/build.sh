#!/usr/bin/env bash
#
# this generates the site in _site
# override --url /myMountPoint  (as an argument to this script) if you don't like the default set in /_config.yml

if [ ! -x _build/build.sh ] ; then
  echo ERROR: script must be run in root of docs dir
  exit 1
fi

function help() {
  echo ""
  echo "This will build the documentation in _site/."
  echo ""
  echo "Usage:  _build/build.sh MODE [ARGS]"
  echo ""
  echo "where MODE can be any of:"
  echo "* website-root  : to build the website only, in the root"
  echo ""
  echo "and supported ARGS are:"
  echo "* --serve : serve files from _site after building (for testing)"
  echo "* --install : install files from _site to the appropriate place in "'$'"BROOKLYN_SITE_DIR (or ../../brooklyn-site-public)"
  echo "* --skip-htmlproof : skip the HTML Proof run on _site"
  echo "* --quick-htmlproof : do a fast HTML Proof run on _site (not checking external links)"
  echo ""
}

function parse_mode() {
  case $1 in
  help)
    help
    exit 0 ;;
  website-root)
    JEKYLL_CONFIG=_config.yml,_build/config-production.yml
    STYLE_SUBDIR=style
    INSTALL_RSYNC_OPTIONS="--exclude v"
    INSTALL_RSYNC_SUBDIR=""
    SUMMARY="website files in the root"
    HTMLPROOF_OPTS=--ignore-v-refs
    ;;
  "")
    echo "ERROR: mode is required; try 'help'"
    exit 1 ;;
  *)
    echo "ERROR: invalid mode '$1'; try 'help'"
    exit 1 ;;
  esac
  SUMMARY="$SUMMARY of `pwd`/_site"
}

function parse_arguments() {
  while (( "$#" )); do
    case $1 in
    "--serve")
      SERVE_AFTERWARDS=true
      shift
      ;;
    "--install")
      INSTALL_AFTERWARDS=true
      shift
      ;;
    "--skip-htmlproof")
      SKIP_HTMLPROOF=true
      shift
      ;;
    "--quick-htmlproof")
      QUICK_HTMLPROOF=true
      shift
      ;;
    *)
      echo "ERROR: invalid argument '"$1"'"
      exit 1
      ;;
    esac
  done
}

# Runs htmlproof against _site
function test_site() {
  if [ "$SKIP_HTMLPROOF" == "true" ]; then
    return
  fi
  echo "Running htmlproof on _site"
  mkdir -p _build/target
  HTMLPROOF_LOG="_build/target/htmlproof.log"
  if [ "$QUICK_HTMLPROOF" == "true" ]; then
    HTMLPROOF_OPTS="$HTMLPROOF_OPTS --disable_external"
  fi
  _build/htmlproof-brooklyn.sh $HTMLPROOF_OPTS 2>&1 | tee $HTMLPROOF_LOG
}

function make_jekyll() {
  BROOKLYN_BIN=../brooklyn-dist/dist/target/brooklyn-dist/brooklyn/bin/brooklyn
  if [ -f $BROOKLYN_BIN ]; then
    ITEMS_JS=style/js/catalog/items.js
    echo "Generating catalog items in $ITEMS_JS"
    echo -n "var items = " > "$ITEMS_JS"
    JAVA_OPTS='-Dlogback.configurationFile=_build/list-objects-logback.xml' $BROOKLYN_BIN \
      list-objects >> "$ITEMS_JS"
    echo ";" >> "$ITEMS_JS"
    echo "Generating catalog items completed"
  else
    echo "Could not find brooklyn to generate items.js"
    if [ "$INSTALL_AFTERWARDS" == "true" ]; then
      echo "ERROR: aborting if can't make items.js for install build"
      exit 1
    fi
  fi

  echo JEKYLL running with: jekyll build $JEKYLL_CONFIG
  jekyll build --config $JEKYLL_CONFIG || return 1
  echo JEKYLL completed

  # normally we exclude things but we can also set TARGET as long_grass and it will get destroyed
  rm -rf _site/long_grass
}

function make_install() {
  if [ "$INSTALL_AFTERWARDS" != "true" ]; then
    return
  fi
  if [ -d _site/website ]; then
    echo "ERROR: _site/website dir exists, not installing as files may be corrupted; is there a jekyll already watching?"
    return 1
  fi
  if [ -d _site/guide ]; then
    echo "ERROR: _site/guide dir exists, not installing as files may be corrupted; is there a jekyll already watching?"
    return 1
  fi

  SITE_DIR=${BROOKLYN_SITE_DIR-../../brooklyn-site-public}
  ls $SITE_DIR/style/img/apache-brooklyn-logo-244px-wide.png > /dev/null || { echo "ERROR: cannot find brooklyn-site-public; set BROOKLYN_SITE_DIR" ; return 1 ; }
  if [ -z ${INSTALL_RSYNC_OPTIONS+SET} ]; then echo "ERROR: --install not supported for this build" ; return 1 ; fi
  if [ -z ${INSTALL_RSYNC_SUBDIR+SET} ]; then echo "ERROR: --install not supported for this build" ; return 1 ; fi
  
  RSYNC_COMMAND_BASE="rsync -rvi --delete --exclude .svn"
  
  RSYNC_COMMAND="$RSYNC_COMMAND_BASE $INSTALL_RSYNC_OPTIONS ./_site/$INSTALL_RSYNC_SUBDIR $SITE_DIR/$INSTALL_RSYNC_SUBDIR"
  echo INSTALLING to local site svn repo with: $RSYNC_COMMAND
  $RSYNC_COMMAND | tee _build/target/rsync.log || return 1

  echo RSYNC changed files:
  grep -v f\\.\\.T\\.\\.\\.\\.\\.\\.\\. _build/target/rsync.log || echo "(none)"
  echo

  if [ ! -z "$HTMLPROOF_LOG" ]; then
    echo HTMLPROOF log:
    cat $HTMLPROOF_LOG
    echo
  fi
    
  SUMMARY="$SUMMARY, installed to $SITE_DIR"
}


rm -rf _site

parse_mode $@
shift
parse_arguments $@

# prep
if [ ! -f style/js/zeroclipboard/ZeroClipboard.swf ] ; then 
  echo downloading ZeroClipboard.swf
  curl -L -o style/js/zeroclipboard/ZeroClipboard.swf http://cdnjs.cloudflare.com/ajax/libs/zeroclipboard/1.3.5/ZeroClipboard.swf
fi

make_jekyll || { echo ERROR: failed jekyll docs build in `pwd` ; exit 1 ; }

test_site

# TODO build catalog

# TODO install

if [ "$INSTALL_AFTERWARDS" == "true" ]; then
  make_install || { echo ERROR: failed to install ; exit 1 ; }
fi

echo FINISHED: $SUMMARY 

if [ "$SERVE_AFTERWARDS" == "true" ]; then
  _build/serve-site.sh
fi
