#Currently we are always caching the build, but if you want to check for a difference gen
#a signature

# besides git-rev md5sum of a tar of all the assets could be an option which is set
# in a file before hand
create_signature() {
  cd $BUILD_DIR
  echo "$(cat git-rev)"
}

save_signature() {
  mkdir -p $CACHE_DIR/assets
  echo "$(create_signature)" > $CACHE_DIR/assets/signature
}

load_signature() {
  mkdir -p $CACHE_DIR/assets
  if test -f $CACHE_DIR/assets/signature; then
    cat $CACHE_DIR/assets/signature
  else
    echo ""
  fi
}

signature_changed() {
  if ! [ "$(create_signature)" == "$(load_signature)" ]; then
    return 1
  else
    return 0
  fi
}

get_cache_status() {
  if ! ${ASSETS_MODULES_CACHE:-true}; then
    echo "disabled"
  elif signature_changed; then
    echo "invalidated"
  else
    echo "valid"
  fi
}

get_cache_directories() {
  local dirs1=( "$CACHE_DIR/assets/ASSETS_CACHE_DIRECTORY" )

  echo "dirs1"
}

restore_cache_directories() {
  local build_dir=${1:-}
  local cache_dir=${2:-}

  for cachepath in ${@:3}; do
    if [ -e "$build_dir/$cachepath" ]; then
      echo "- $cachepath (exists - skipping)"
    else
      if [ -e "$cache_dir/assets/$cachepath" ]; then
        echo "- $cachepath"
        mkdir -p $(dirname "$build_dir/$cachepath")
        mv "$cache_dir/assets/$cachepath" "$build_dir/$cachepath"
      else
        echo "- $cachepath (not cached - skipping)"
      fi
    fi
  done
}

clear_cache() {
  rm -rf $CACHE_DIR/assets
}

save_cache_directories() {
  local build_dir=${1:-}
  local cache_dir=${2:-}

  for cachepath in ${@:3}; do
    if [ -e "$build_dir/$cachepath" ]; then
      echo "- $cachepath"
      mkdir -p "$cache_dir/assets/$cachepath"
      cp -a "$build_dir/$cachepath" $(dirname "$cache_dir/assets/$cachepath")
    else
      echo "- $cachepath (nothing to cache)"
    fi
  done
}
