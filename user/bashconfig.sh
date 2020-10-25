alias ll='ls -alh'
export PATH=$PATH:~/.composer/vendor/bin:./bin:./vendor/bin:./node_modules/.bin
source ~/.git-completion.bash
source ~/.git-prompt.sh

CONTAINER_ID=$(basename $(cat /proc/1/cpuset))
export HOST_DISPLAY_NAME=$HOSTNAME

if [[ $CONTAINER_ID != ${HOSTNAME}* ]] ; then
  export HOST_DISPLAY_NAME=$HOSTNAME
fi

PS1='\033]2;'$(pwd)'\007\[\e[0;36m\][\[\e[1;31m\]\u\[\e[0;36m\]@\[\e[1;34m\]$HOST_DISPLAY_NAME\[\e[0;36m\]: \[\e[0m\]\w\[\e[0;36m\]]\[\e[0m\]\$\[\e[1;32m\]\s\[\e[0;33m\]$(__git_ps1)\[\e[0;36m\]> \[\e[0m\]\n$ ';

# Run SSH Agent and add key 7d
if [ -z "$SSH_AUTH_SOCK" ] ; then
  ssh-add -t 604800 ~/.ssh/id_rsa
fi

function listEnvs() {
  env | grep "^${1}" | cut -d= -f1
}

function getEnvVar() {
  awk "BEGIN {print ENVIRON[\"$1\"]}"
}

function restartPhp() {
  $SUDO supervisorctl -c /opt/docker/supervisord.conf restart php-fpm:php-fpm
}

iniChanged=false;
for ENV_VAR in $(listEnvs "php\."); do
  env_key=${ENV_VAR#php.}
  env_val=$(getEnvVar "$ENV_VAR")
  iniChanged=true

  echo "$env_key = ${env_val}" >> /usr/local/etc/php/conf.d/x.override.php.ini
done

[ $iniChanged = true ] && restartPhp
