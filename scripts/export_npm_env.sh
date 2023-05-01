#!/bin/bash -e

npm_package_config_V8=${npm_package_config_V8:-$(node -p 'require("./package.json").config.V8')}

if [[ ${CIRCLECI} ]]; then
  echo "export V8_VERSION=${npm_package_config_V8}" >> $BASH_ENV
elif [[ ${GITHUB_ACTIONS} ]]; then
  sudo sh -c "chmod 777 $GITHUB_ENV"
  echo "V8_VERSION=${npm_package_config_V8}" >> $GITHUB_ENV
else
  export V8_VERSION=${npm_package_config_V8}
fi
