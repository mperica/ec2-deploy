#!/usr/bin/env bash



[[ -z $SSH_HOST ]] && { echo "SSH_HOST variable is not set."; exit 1; }
[[ -z $SSH_USER ]] && { echo "SSH_USER variable is not set."; exit 1; }
[[ -z $SSH_KEY_PATH ]] && { echo "SSH_KEY_PATH variable is not set."; exit 1; }
[[ -z $DEPLOY_DIR ]] && { echo "DEPLOY_DIR variable is not set."; exit 1; }
[[ -z $DEPLOY_ARTIFACT ]] && { echo "DEPLOY_ARTIFACT variable is not set."; exit 1; }

cat <<"EOF"

-------------------------------------------------------------------------
                        EC2 Deploy script
-------------------------------------------------------------------------

EOF

# Colors
cred="\e[31m"
cgreen="\e[32m"
cnormal="\e[0m"

# Functions
function check() {
  # Check last command status code
  if [ $? -eq 0 ]; then
    echo -e "[ ${cgreen}OK${cnormal} ]"
  else
    echo -e "[ ${cred}Failed${cnormal} ]"
    exit 1
  fi
}

echo
echo " SSH_HOST        = $SSH_HOST"
echo " SSH_PORT        = $SSH_PORT"
echo " SSH_USER        = $SSH_USER"
echo " DEPLOY_DIR      = $DEPLOY_DIR"
echo " DEPLOY_ARTIFACT = $DEPLOY_ARTIFACT"
echo

function ssh_cmd() {
  echo "# Running: $1"
  ssh \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -o LogLevel=ERROR \
    -i $SSH_KEY_PATH \
    $SSH_USER@$SSH_HOST -p $SSH_PORT $1
  check
}

function scp_cmd() {
  local local_path=$1
  local remote_path=$2
  echo "# Sending $local_path file to destination $remote_path"
  scp -q \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -o LogLevel=ERROR \
    -i $SSH_KEY_PATH \
    -P $SSH_PORT \
    $local_path $SSH_USER@$SSH_HOST:$remote_path
  check
}

if [ "$SSH_KEY" != "" ];then
  echo -e "${SSH_KEY}" > /tmp/sshkey.pem
  chmod 400 /tmp/sshkey.pem
fi

ssh_cmd "mkdir -p .deploy"
scp_cmd /app/${DEPLOY_ARTIFACT} .deploy
ssh_cmd "sudo tar xzf .deploy/${DEPLOY_ARTIFACT} -C ${DEPLOY_DIR}"
ssh_cmd "rm -rf /home/$SSH_USER/.deploy"

# Cleanup
[[ -w $SSH_KEY_PATH ]] && rm -f $SSH_KEY_PATH

echo -e "\nDeployment to the $SSH_HOST host has been done successfully"

exit 0


# EOF #
# vim: ft=sh ts=2 sw=2 et
