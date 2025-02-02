#!/bin/bash -x

# Installs with 
#   source <(curl -sS https://logicmoo.org/gitlab/logicmoo/logicmoo_workspace/-/raw/master/web_install.sh)
#   source <(curl -sS https://raw.githubusercontent.com/logicmoo/logicmoo_workspace/master/web_install.sh)
#   https://colab.research.google.com/drive/12HyHjC-1tIWqkfKkelH3YZzGA7yBK-mW#scrollTo=rTF_JGGrA9lJ
if git --version &>/dev/null; then
   echo "Found Git"; 
else
echo ""
   echo ""
   echo -e "\e[1;31mERROR Require git but it's not installed. use: apt install git   Aborting. \e[0m"
   echo ""
   return 1 2>/dev/null
   exit 1
fi

mkdir -p /opt

cd /opt
if [[ ! -d "logicmoo_workspace" ]]; then
  export SSLWAS=$(git config --global http.sslVerify)
  git config --global http.sslVerify false
  git clone --no-checkout https://github.com/logicmoo/logicmoo_workspace.git  
  git config --global http.sslVerify $SSLWAS
fi
(cd logicmoo_workspace
if [[ ! -d ".git/modules/prologmud_server/" ]]; then
   ( set +x
   ggID='1KhXSv4vq_a82ctGg74GcVBO4fArldVou'
   ggURL='https://drive.google.com/uc?export=download'
   filename="$(curl -sc /tmp/gcokie "${ggURL}&id=${ggID}" | grep -o '="uc-name.*</span>' | sed 's/.*">//;s/<.a> .*//')"
   getcode="$(awk '/_warning_/ {print $NF}' /tmp/gcokie)"
   curl -Lb /tmp/gcokie "${ggURL}&confirm=${getcode}&id=${ggID}" -o "${filename}"
   mkdir -p .git/modules/
   mkdir -p /opt/logicmoo_workspace/prologmud_server
   tar xfz "${filename}" -C /opt/logicmoo_workspace/prologmud_server
   cd /opt/logicmoo_workspace/prologmud_server
   # git remote add origin https://logicmoo.org:2082/gitlab/logicmoo/prologmud_server.git
   echo "Checking out master"
   git checkout master .
   echo "Switching to master"   
   git checkout master
   echo "Pulling changes from https://logicmoo.org:2082/gitlab/logicmoo/prologmud_server.git"
   git pull https://logicmoo.org:2082/gitlab/logicmoo/prologmud_server.git master
   echo "Now moving prologmud_server into submodule"
   mv /opt/logicmoo_workspace/prologmud_server/.git /opt/logicmoo_workspace/.git/modules/prologmud_server
   echo "Back into logicmoo_workspace..."
   cd /opt/logicmoo_workspace/
   git checkout master .
   git checkout master
   git pull --recurse-submodules
   git submodule update --init --recursive
)
fi
)

# ls logicmoo_workspace
cd logicmoo_workspace
export LOGICMOO_WS=`pwd`
git fetch --recurse-submodules
git pull -f --verbose
echo maybe: git submodule update --recursive --remote
#git status -s
echo source ./INSTALL.md
source ./INSTALL.md

echo -e "\e[1;32m Ensure Docker and SCREEN are installed: apt install docker.io screen
         then $LOGICMOO_WS/runFromDocker.sh\e[0m"


