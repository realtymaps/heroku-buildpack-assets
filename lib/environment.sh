create_default_env() {
  local build_dir="$1"
  export ASSETS_CONFIG_PRODUCTION=${ASSETS_CONFIG_PRODUCTION:-true}
  export ASSETS_MODULES_CACHE=${ASSETS_MODULES_CACHE:-true}
  export ASSETS_CACHE_DIRECTORY=${ASSETS_CACHE_DIRECTORY:-"_public"}
  export ASSETS_COMPILE_CMD=${ASSETS_COMPILE_CMD:-"npm run gulp prod"}
  ASSETS_DEPS=${ASSETS_DEPS:-"$build_dir/.profile.d/nodejs.sh"}
  export ASSETS_DEPS=( $ASSETS_DEPS )
}

compile_assets(){
  header "Syncing DB Variables"
  $build_dir/scripts/app/syncVars
  header "Compiling Assets"
  $ASSETS_COMPILE_CMD
  save_signature
}

load_dependencies(){
  local deps=$1
  for i in "${deps[@]}"
  do
	   echo $i
     source $i
   done
}

list_assets_config() {
  echo ""
  printenv | grep ^ASSETS_ || true
}

export_env_dir() {
  local env_dir=$1
  if [ -d "$env_dir" ]; then
    local whitelist_regex=${2:-''}
    local blacklist_regex=${3:-'^(PATH|GIT_DIR|CPATH|CPPATH|LD_PRELOAD|LIBRARY_PATH)$'}
    if [ -d "$env_dir" ]; then
      for e in $(ls $env_dir); do
        echo "$e" | grep -E "$whitelist_regex" | grep -qvE "$blacklist_regex" &&
        export "$e=$(cat $env_dir/$e)"
        :
      done
    fi
  fi
}
