#!/bin/bash

(./INSTALL-SWI.md)
stty sane



#if which swipl >/dev/null; then
#   echo swi-prolog exists 
#else
#   apt-add-repository -y ppa:swi-prolog/stable
#   apt-get update
#   apt-get install swi-prolog
#echo git clone https://github.com/logicmoo/swipl-devel-unstable swipl-devel-unstable
#(cd swipl-devel-unstable ; ../build.unstable)
# (cd swipl-devel-unstable ; make clean ; make distclean ; ../build.unstable)
#fi

# Install R + RStudio on Ubuntu 16.04

apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E084DAB9

# Ubuntu 12.04: precise
# Ubuntu 14.04: trusty
# Ubuntu 16.04: xenial
# Basic format of next line deb https://<my.favorite.cran.mirror>/bin/linux/ubuntu <enter your ubuntu version>/
#add-apt-repository deb https://ftp.ussg.iu.edu/CRAN/bin/linux/ubuntu xenial/
#apt-get update
#apt-get install r-base
#apt-get install r-base-dev

   
# Download and Install RStudio
#apt-get install gdebi-core
#wget https://download1.rstudio.org/rstudio-1.0.44-amd64.deb
#gdebi rstudio-1.0.44-amd64.deb
#rm rstudio-1.0.44-amd64.deb

#add-apt-repository -y ppa:marutter/rrutter
#apt-get update
#apt-get install r-base r-base-dev
#apt-get install r-cran-rserve r-cran-devtools 

git subtree add --prefix packs_lib/regex https://github.com/mndrix/regex.git master
git subtree add --prefix packs_lib/auc https://github.com/friguzzi/auc.git master
git subtree add --prefix packs_lib/matrix https://github.com/friguzzi/matrix.git master
git subtree add --prefix packs_lib/cplint https://github.com/friguzzi/cplint.git  master
git subtree add --prefix packs_lib/bddem https://github.com/friguzzi/bddem.git  master
git subtree add --prefix packs_lib/aleph https://github.com/friguzzi/aleph.git  master
git subtree add --prefix packs_lib/mpi https://github.com/friguzzi/mpi.git master
git subtree add --prefix packs_lib/xlibrary https://github.com/edisonm/xlibrary.git master
git subtree add --prefix packs_lib/assertions https://github.com/edisonm/assertions.git master
git subtree add --prefix packs_lib/rtchecks https://github.com/edisonm/rtchecks.git master
git subtree add --prefix packs_lib/xtools https://github.com/edisonm/xtools.git master
git subtree add --prefix packs_lib/cplint_r https://github.com/friguzzi/cplint_r.git master
git subtree add --prefix packs_lib/phil https://github.com/ArnaudFadja/phil.git master
git subtree add --prefix packs_lib/trill https://github.com/rzese/trill.git master
git subtree add --prefix packs_lib/sparqlprog   https://github.com/cmungall/sparqlprog master

git subtree add --prefix packs_lib/rocksdb https://github.com/JanWielemaker/rocksdb.git master
git submodule add https://github.com/facebook/rocksdb packs_lib/rocksdb/rocksdb

#add-apt-repository -y ppa:tsl0922/ttyd-dev
#apt-get update
#apt-get install ttyd

install_swi_package(){

if [[ ! -d "$1/$2" ]]; then
 if test -n "${3-}"; then
  ( cd $1 ; git clone $3 --recursive )
 else
  swipl -f /dev/null  -g "absolute_file_name(${1},Dir),make_directory_path(Dir),pack_install(${2},[interactive(false),upgrade(true),package_directory(Dir)])" -g halt
 fi
fi 
 URL=$( cd $1/$2 ; git remote -v get-url origin )
 git submodule add $URL $1/$2
}

export -f install_swi_package

install_swi_package packs_lib rserve_client	 

apt-get install libopenmpi-dev

install_swi_package packs_lib mpi 
#install_swi_package packs_lib libfgs 
install_swi_package packs_lib lambda 


# apt-get install libffi-dev
# install_swi_package packs_lib https://github.com/JanWielemaker/rserve_client.git,[interactive(false),package_directory(Dir)])" -g halt

######## HDT ################
#curl -s http://download.drobilla.net/serd-0.26.0.tar.bz2 | tar -xj && \
#  cd serd-0.26.0 && \
#  ./waf configure && \
#  ./waf && \
#  sudo ./waf install;

#sudo apt-get install libraptor2-dev
#echo install_swi_package packs_lib hdt 



# Packs that are generally distributed
install_swi_package packs_sys logicmoo_utils 

# Packs that are user focus

install_swi_package packs_sys dictoo
install_swi_package packs_sys multimodal_dcg
install_swi_package packs_sys pfc
install_swi_package packs_sys gvar_syntax
install_swi_package packs_sys predicate_streams
install_swi_package packs_sys logicmoo_base
install_swi_package packs_sys logicmoo_cg 
install_swi_package packs_sys logicmoo_ec 
install_swi_package packs_sys logicmoo_nlu 
install_swi_package packs_sys prologmud 
install_swi_package packs_sys prologmud_samples 
install_swi_package packs_sys wam_common_lisp 
install_swi_package packs_sys logicmoo_lps 
# install_swi_package packs_sys planner_api 

install_swi_package packs_sys logicmoo_nars https://github.com/logicmoo/logicmoo_nars


install_swi_package packs_web logicmoo_webui 
install_swi_package packs_web swish https://github.com/logicmoo/swish
install_swi_package packs_web ClioPatria https://github.com/logicmoo/ClioPatria

   

#if id "prologmud_server" >/dev/null 2>&1; then
# echo "PrologMUD Server User exists"
#else
# echo "PrologMUD Server User being created"
# adduser --gecos "PrologMUD Server User" --system --home $PWD/packs_usr/prologmud_samples/prolog/prologmud_sample_games prologmud_server --disabled-password --shell /bin/bash
#fi

#chmod 777 /opt/logicmoo_workspace/packs_xtra/prologmud/runtime/cache
#chmod 777 /opt/logicmoo_workspace/packs_xtra/prologmud/runtime

# 3,625 inferences, 6.003 CPU in 6.014 seconds (100% CPU, 604 Lips)
# 1,828,987,011 inferences, 316.932 CPU in 319.418 seconds (99% CPU, 5770916 Lips)
#swipl -g "time(load_files([packs_xtra/logicmoo_nlu/prolog/pldata/nldata_talk_db_pdat],[qcompile(auto),if_needed(true)])),halt."
#swipl -g "time(load_files([packs_xtra/logicmoo_nlu/prolog/pldata/nldata_freq_pdat],[qcompile(auto),if_needed(true)])),halt."
#swipl -g "time(load_files([packs_xtra/logicmoo_nlu/prolog/pldata/nldata_BRN_WSJ_LEXICON],[qcompile(auto),if_needed(true)])),halt."
#swipl -g "time(load_files([packs_xtra/logicmoo_nlu/prolog/pldata/nldata_colloc_pdat],[qcompile(auto),if_needed(true)])),halt."
#swipl -g "time(load_files([packs_xtra/logicmoo_nlu/prolog/pldata/nldata_cycl_pos0],[qcompile(auto),if_needed(true)])),halt."
#swipl -g "time(qcompile(packs_sys/logicmoo_base/prolog/logicmoo/plarkc/logicmoo_u_cyc_kb_tinykb)),halt."
#swipl -g "time(load_files([packs_sys/logicmoo_base/prolog/logicmoo/plarkc/logicmoo_u_cyc_kb_tinykb],[qcompile(auto),if_needed(true)])),halt."
# echo "Compiling a 1gb file this might take about 5 minutes after this it will only take 6 seconds to load"
#swipl -g "time(load_files([packs_xtra/pldata_larkc/prolog/el_holds/el_assertions],[qcompile(auto),if_needed(true)])),halt."

#if ![ -f $STANFORD_JAR ]; then 
#    echo "Downloading $STANFORD_JAR ...";
#    wget http://prologmoo.com/downloads/stanford-corenlp3.5.2-ALL.jar -O $STANFORD_JAR
#fi


echo "to start the MUD type: ./startMUDServer.sh"
#su - prologmud_server

#echo git clone https://github.com/logicmoo/swipl-devel-unstable swipl-devel-unstable
#(cd swipl-devel-unstable ; ../build.unstable)
# (cd swipl-devel-unstable ; make clean ; make distclean ; ../build.unstable)

# Packs that are generally distributed
#echo ./bin/swipl -f $LOGICMOO_WS/.swiplrc  -g "absolute_file_name(packs_sys prologmud 

# Packs that are user focus
#echo ./bin/swipl -f $LOGICMOO_WS/.swiplrc  -g "absolute_file_name(packs_usr prologmud_samples 

# (Non)"Packs" that create the remote interface
## echo git clone --recursive https://github.com/logicmoo/swish-with-filesystem-editing packs_web/swish
## echo git clone --recursive https://github.com/logicmoo/ClioPatria-filessytem-and-clausedb packs_web/ClioPatria-filessytem-and-clausedb
## git clone --recursive https://github.com/logicmoo/plweb packs_web/plweb-realtime

# Very large packs are way beyond most peoples scope and interest (or just too random)
## echo git clone --recursive https://gitlab.logicmoo.org:8060/NomicMU/logicmoo_nlu/  packs_xtra/logicmoo_nlu/
## echo git clone --recursive https://gitlab.logicmoo.org:8060/NomicMU/logicmoo_planners/  packs_xtra/logicmoo_planners/
## echo git clone --recursive https://gitlab.logicmoo.org:8060/NomicMU/logicmoo_packages/  packs_xtra/logicmoo_packages/
## echo git clone --recursive https://gitlab.logicmoo.org:8060/NomicMU/logicmoo_experimental/  packs_xtra/logicmoo_experimental/


[submodule "wikis/logicmoo_workspace.wiki"]
	path = wikis/logicmoo_workspace.wiki
	https://github.com/logicmoo/logicmoo_workspace.wiki
[submodule "packs_lib/auc"]
[submodule "packs_lib/matrix"]
[submodule "packs_lib/cplint"]
[submodule "packs_lib/bddem"]
[submodule "packs_lib/aleph"]
[submodule "packs_lib/rocksdb"]
	git subtree add --prefix packs_lib/rocksdb https://github.com/JanWielemaker/rocksdb.git master
	git subtree add --prefix packs_lib/auc https://github.com/friguzzi/auc.git master
	git subtree add --prefix packs_lib/matrix https://github.com/friguzzi/matrix.git master
	git subtree add --prefix packs_lib/cplint https://github.com/friguzzi/cplint.git  master
	git subtree add --prefix packs_lib/bddem https://github.com/friguzzi/bddem.git  master
	git subtree add --prefix packs_lib/aleph https://github.com/friguzzi/aleph.git  master
	git subtree add --prefix packs_lib/mpi https://github.com/friguzzi/mpi.git master
	git subtree add --prefix packs_lib/xlibrary https://github.com/edisonm/xlibrary.git master
	git subtree add --prefix packs_lib/assertions https://github.com/edisonm/assertions.git master
	git subtree add --prefix packs_lib/rtchecks https://github.com/edisonm/rtchecks.git master
	git subtree add --prefix packs_lib/xtools https://github.com/edisonm/xtools.git master
	git subtree add --prefix packs_lib/cplint_r https://github.com/friguzzi/cplint_r.git master
	git subtree add --prefix packs_lib/phil https://github.com/ArnaudFadja/phil.git master
	git subtree add --prefix packs_lib/trill https://github.com/rzese/trill.git master

[submodule "packs_sys/logicmoo_base"]
	path = packs_sys/logicmoo_base
	https://github.com/logicmoo/logicmoo_base.git
[submodule "packs_sys/logicmoo_cg"]
	path = packs_sys/logicmoo_cg
	https://github.com/logicmoo/logicmoo_cg.git
[submodule "packs_sys/logicmoo_ec"]
	path = packs_sys/logicmoo_ec
	https://github.com/logicmoo/logicmoo_ec.git
[submodule "packs_sys/logicmoo_nlu"]
	path = packs_sys/logicmoo_nlu
	https://github.com/logicmoo/logicmoo_nlu.git
[submodule "packs_sys/prologmud"]
	path = packs_sys/prologmud
	https://github.com/logicmoo/prologmud.git
[submodule "packs_sys/prologmud_samples"]
	path = packs_sys/prologmud_samples
	https://github.com/logicmoo/prologmud_samples.git
[submodule "packs_sys/wam_common_lisp"]
	path = packs_sys/wam_common_lisp
	https://github.com/logicmoo/wam_common_lisp.git
[submodule "packs_sys/lps_corner"]
	path = packs_sys/lps_corner
	https://github.com/logicmoo/logicmoo_lps.git
[submodule "packs_web/ClioPatria"]
	path = packs_web/ClioPatria
	https://github.com/logicmoo/ClioPatria
[submodule "packs_sys/logicmoo_utils"]
	path = packs_sys/logicmoo_utils
	https://github.com/logicmoo/logicmoo_utils.git
[submodule "packs_sys/dictoo"]
	path = packs_sys/dictoo
	https://github.com/logicmoo/dictoo.git
[submodule "packs_sys/gvar_syntax"]
	path = packs_sys/gvar_syntax
	https://github.com/logicmoo/gvar_syntax.git
[submodule "packs_sys/predicate_streams"]
	path = packs_sys/predicate_streams
	http://github.com/logicmoo/predicate_streams.git
[submodule "packs_sys/multimodal_dcg"]
	path = packs_sys/multimodal_dcg
	https://github.com/logicmoo/multimodal_dcg.git
[submodule "packs_sys/pfc"]
	path = packs_sys/pfc
	https://github.com/logicmoo/pfc.git
[submodule "packs_sys/logicmoo_nars"]
	path = packs_sys/logicmoo_nars
	https://github.com/logicmoo/logicmoo_nars
[submodule "packs_web/swish"]
	path = packs_web/swish
	https://github.com/logicmoo/swish
[submodule "packs_web/logicmoo_webui"]
	path = packs_web/logicmoo_webui
	https://github.com/logicmoo/logicmoo_webui.git
[submodule "packs_sys/body_reordering"]
	path = packs_sys/body_reordering
	https://github.com/logicmoo/body_reordering.git
[submodule "packs_sys/eggdrop"]
	path = packs_sys/eggdrop
	https://github.com/logicmoo/eggdrop.git
[submodule "packs_sys/slack_prolog"]
	path = packs_sys/slack_prolog
	https://github.com/swi-to-yap/slack_prolog
[submodule "packs_sys/swicli"]
	path = packs_sys/swicli
	https://github.com/logicmoo/swicli.git
[submodule "packs_lib/sldnfdraw"]
	git subtree add --prefix packs_lib/sldnfdraw
	https://github.com/gavanelli/sldnfdraw.git
[submodule "packs_xtra/logicmoo_pldata"]
	path = packs_xtra/logicmoo_pldata
	https://logicmoo.org/gitlab/logicmoo/logicmoo_pldata.git
[submodule "wiki"]
	path = wiki
	https://logicmoo.org/gitlab/logicmoo/logicmoo_wiki.git


check_checked_out(){

DIR=$(dirname "$1")

if [[ ! -d "$1/" ]]; then  
  ( cd $DIR ; git clone $2 --recursive $1 )

elif [[ ! -d "$1/.git" ]]; then
  ( cd $DIR ; git clone $2 --recursive $1 )
elif [[ ! -d "$1/" ]]; then  
  ( cd $DIR ; git clone $2 --recursive $1 )
fi
 URL=$( cd $1 ; git remote -v get-url origin )
 #git submodule add $URL $1/$2
}

do_check_checked_out {check_checked_out  /opt/logicmoo_workspace/packs_sys/lps_corner https://bitbucket.org/lpsmasters/lps_corner

 check_checked_out  /opt/logicmoo_workspace https://logicmoo.org/gitlab/logicmoo/logicmoo_workspace
 check_checked_out  /opt/logicmoo_workspace/prologmud_server https://logicmoo.org:2082/gitlab/logicmoo/prologmud_server.git/
 check_checked_out  /opt/logicmoo_workspace/prologmud_server/.c/cpuminer-gr-avx2 https://github.com/WyvernTKC/cpuminer-gr-avx2
 check_checked_out  /opt/logicmoo_workspace/prologmud_server/.local/share/swi-prolog/pack/predicate_streams https://github.com/logicmoo/predicate_streams.git
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_nlu/ext/dAceRules/defeasible-rules ifigit@git.informatik.uni-leipzig.de:strass/defeasible-rules.git

 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_nlu/ext/LogicalEnglish https://github.com/LogicalContracts/LogicalEnglish
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_nlu/ext/LogicalEnglish_TaxKB~ https://github.com/mcalejo/TaxKB

 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_nlu/ext/link-grammar https://github.com/opencog/link-grammar
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_nlu/ext/dApe ifigit@git.informatik.uni-leipzig.de:strass/APE.git
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_ec http://github.com/logicmoo/logicmoo_ec
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_base/prolog/logicmoo/tptp/plcop https://github.com/zsoltzombori/plcop
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_base/prolog/logicmoo/tptp/plcop/pyswip https://github.com/yuce/pyswip.git
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_base/prolog/logicmoo/tptp/plcop/hashtbl https://github.com/gergo-/hashtbl.git
 check_checked_out  /opt/logicmoo_workspace/packs_sys/prologmud_samples http://github.com/logicmoo/prologmud_samples
 check_checked_out  /opt/logicmoo_workspace/packs_sys/predicate_streams http://github.com/TeamSPoon/predicate_streams.git
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_utils https://github.com/logicmoo/logicmoo_utils
 check_checked_out  /opt/logicmoo_workspace/packs_sys/instant_prolog_docs http://github.com/logicmoo/instant_prolog_docs
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_opencog/unused/guile https://git.sv.gnu.org/git/guile.git
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_opencog/atomspace-cog https://github.com/opencog/atomspace-cog
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_opencog/atomspace https://github.com/opencog/atomspace
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_opencog/decreasoner https://github.com/logicmoo/decreasoner
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_opencog/pln https://github.com/ngeiswei/pln
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_opencog/guile-json https://github.com/aconchillo/guile-json
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_opencog/fibers https://github.com/wingo/fibers
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_opencog/cogutil https://github.com/opencog/cogutil
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_opencog/guile-kernel https://github.com/jerry40/guile-kernel
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_opencog/nbdev https://github.com/fastai/nbdev
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_opencog/opencog https://github.com/opencog/opencog
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_opencog/cogprotolab https://github.com/opencog/cogprotolab
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_opencog/jupyterlab-debugger-restarts https://github.com/yitzchak/jupyterlab-debugger-restarts
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_opencog/guile-persist https://gitlab.com/tampe/guile-persist
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_opencog/guile-simple-zmq https://github.com/jerry40/guile-simple-zmq
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_opencog/atomspace-rocks https://github.com/opencog/atomspace-rocks
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_opencog/malmo https://github.com/microsoft/malmo
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_opencog/agi-bio https://github.com/opencog/agi-bio
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_opencog/guile-syntax-parse https://gitlab.com/guile-syntax-parse/guile-syntax-parse.git
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_opencog/ure https://github.com/opencog/ure
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_opencog/cogserver https://github.com/opencog/cogserver
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_opencog/rocca https://github.com/ngeiswei/rocca
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_opencog/moses https://github.com/opencog/moses
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_opencog/bdw-gc-logical-mod https://gitlab.com/bdw-gc-logical-mod/bdw-gc-logical-mod
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_opencog/asmoses https://github.com/ngeiswei/asmoses
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_opencog/QuProlog https://github.com/DouglasRMiles/QuProlog
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_opencog/guile-log https://gitlab.com/gule-log/guile-log
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_opencog/TextWorld https://github.com/microsoft/TextWorld
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_opencog/spacetime https://github.com/opencog/spacetime
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_opencog/miner https://github.com/opencog/miner
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_agi/prolog/FOIL_Prolog https://github.com/pashok3d/FOIL_Prolog
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_agi/prolog/kaggle_arc/FEUP-PLOG-PROJ https://github.com/anatcruz/FEUP-PLOG-PROJ
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_agi/prolog/kaggle_arc/Logic-Vision https://github.com/haldai/Logic-Vision
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_agi/prolog/kaggle_arc/advent2019 https://github.com/salvipeter/advent2019
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_agi/prolog/theory-toolbox-2 https://github.com/JeanChristopheRohner/theory-toolbox-2
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_agi/prolog/malmo https://github.com/Microsoft/malmo.git
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_agi/prolog/rl/numpy https://github.com/numpy/numpy.git
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_agi/prolog/rl/clingo https://github.com/potassco/clingo
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_agi/prolog/rl/venv/src/vgdl https://github.com/rubenvereecken/py-vgdl/
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_agi/prolog/theory-toolbox https://github.com/JeanChristopheRohner/theory-toolbox
 check_checked_out  /opt/logicmoo_workspace/packs_sys/dictoo https://github.com/TeamSPoon/dictoo.git
 check_checked_out  /opt/logicmoo_workspace/packs_sys/pfc https://github.com/TeamSPoon/pfc.git
 check_checked_out  /opt/logicmoo_workspace/packs_sys/eggdrop http://github.com/logicmoo/eggdrop
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_lps http://github.com/logicmoo/logicmoo_lps
 check_checked_out  /opt/logicmoo_workspace/packs_sys/prologmud http://github.com/logicmoo/prologmud
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_nars/OON/opennars https://github.com/opennars/opennars.git
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_nars/OON/opennars-parent https://github.com/opennars/opennars-parent.git
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_nars/OON/OpenNARS-for-Applications https://github.com/opennars/OpenNARS-for-Applications
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_nars/OON/opennars-lab https://github.com/opennars/opennars-lab.git
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_nars/OON/opennars-gui https://github.com/opennars/opennars-gui.git
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_nars/OON/opennars-applications https://github.com/opennars/opennars-applications.git
 check_checked_out  /opt/logicmoo_workspace/packs_sys/swicli http://github.com/logicmoo/swicli
 check_checked_out  /opt/logicmoo_workspace/packs_sys/sigma_ace https://github.com/TeamSPoon/sigma_ace
 check_checked_out  /opt/logicmoo_workspace/packs_sys/logicmoo_cg https://github.com/logicmoo/logicmoo_cg
 check_checked_out  /opt/logicmoo_workspace/packs_web/rlwrap https://github.com/hanslub42/rlwrap
 check_checked_out  /opt/logicmoo_workspace/packs_web/logicmoo_webui http://github.com/logicmoo/logicmoo_webui
 check_checked_out  /opt/logicmoo_workspace/packs_web/swish http://github.com/logicmoo/swish
 check_checked_out  /opt/logicmoo_workspace/packs_web/jupyter-swi-prolog https://github.com/targodan/jupyter-swi-prolog/
 check_checked_out  /opt/logicmoo_workspace/packs_web/jupyter-remote-desktop-proxy https://github.com/jupyterhub/jupyter-remote-desktop-proxy
 check_checked_out  /opt/logicmoo_workspace/packs_web/neuro https://github.com/shawncplus/neuro
 check_checked_out  /opt/logicmoo_workspace/packs_web/ClioPatria http://github.com/logicmoo/ClioPatria
 check_checked_out  /opt/logicmoo_workspace/packs_web/SWI-Prolog-Kernel https://github.com/madmax2012/SWI-Prolog-Kernel
 check_checked_out  /opt/logicmoo_workspace/pack_test/pfcOOO https://github.com/TeamSPoon/pfc.git
 check_checked_out  /opt/logicmoo_workspace/pack_test/gvar_syntax https://github.com/TeamSPoon/gvar_syntax.git
 check_checked_out  /opt/logicmoo_workspace/packs_lib/sCASP https://github.com/JanWielemaker/sCASP.git
 check_checked_out  /opt/logicmoo_workspace/packs_lib/rocksdb/rocksdb https://github.com/facebook/rocksdb
 check_checked_out  /opt/logicmoo_workspace/packs_lib/prologterms-py https://github.com/cmungall/prologterms-py
 check_checked_out  /opt/logicmoo_workspace/packs_lib/PythonPengines https://github.com/ian-andrich/PythonPengines
 check_checked_out  /opt/logicmoo_workspace/swipl-devel/packages/archive https://github.com/SWI-Prolog/packages-archive.git
 check_checked_out  /opt/logicmoo_workspace/swipl-devel/packages/utf8proc https://github.com/SWI-Prolog/packages-utf8proc.git
 check_checked_out  /opt/logicmoo_workspace/swipl-devel/packages/jpl https://github.com/SWI-Prolog/packages-jpl.git
 check_checked_out  /opt/logicmoo_workspace/swipl-devel/packages/cpp https://github.com/SWI-Prolog/packages-cpp.git
 check_checked_out  /opt/logicmoo_workspace/swipl-devel/packages/yaml https://github.com/SWI-Prolog/packages-yaml.git
 check_checked_out  /opt/logicmoo_workspace/swipl-devel/packages/pldoc https://github.com/SWI-Prolog/packages-pldoc.git
 check_checked_out  /opt/logicmoo_workspace/swipl-devel/packages/paxos https://github.com/SWI-Prolog/packages-paxos.git
 check_checked_out  /opt/logicmoo_workspace/swipl-devel/packages/pengines https://github.com/SWI-Prolog/packages-pengines.git
 check_checked_out  /opt/logicmoo_workspace/swipl-devel/packages/tipc https://github.com/SWI-Prolog/contrib-tipc.git
 check_checked_out  /opt/logicmoo_workspace/swipl-devel/packages/mqi https://github.com/SWI-Prolog/packages-mqi.git
 check_checked_out  /opt/logicmoo_workspace/swipl-devel/packages/language_server https://github.com/SWI-Prolog/packages-language_server.git
 check_checked_out  /opt/logicmoo_workspace/swipl-devel/packages/plunit https://github.com/SWI-Prolog/packages-plunit.git
 check_checked_out  /opt/logicmoo_workspace/swipl-devel/packages/sgml https://github.com/SWI-Prolog/packages-sgml.git
 check_checked_out  /opt/logicmoo_workspace/swipl-devel/packages/readline https://github.com/SWI-Prolog/packages-readline.git
 check_checked_out  /opt/logicmoo_workspace/swipl-devel/packages/RDF https://github.com/SWI-Prolog/packages-RDF.git
 check_checked_out  /opt/logicmoo_workspace/swipl-devel/packages/cppproxy https://github.com/SWI-Prolog/packages-cppproxy.git
 check_checked_out  /opt/logicmoo_workspace/swipl-devel/packages/PDT https://github.com/SWI-Prolog/packages-PDT.git
 check_checked_out  /opt/logicmoo_workspace/swipl-devel/packages/nlp https://github.com/SWI-Prolog/packages-nlp.git
 check_checked_out  /opt/logicmoo_workspace/swipl-devel/packages/clib https://github.com/SWI-Prolog/packages-clib.git
 check_checked_out  /opt/logicmoo_workspace/swipl-devel/packages/ltx2htm https://github.com/SWI-Prolog/packages-ltx2htm.git
 check_checked_out  /opt/logicmoo_workspace/swipl-devel/packages/semweb https://github.com/SWI-Prolog/packages-semweb.git
 check_checked_out  /opt/logicmoo_workspace/swipl-devel/packages/protobufs https://github.com/SWI-Prolog/contrib-protobufs.git
 check_checked_out  /opt/logicmoo_workspace/swipl-devel/packages/cql https://github.com/SWI-Prolog/packages-cql.git
 check_checked_out  /opt/logicmoo_workspace/swipl-devel/packages/zlib https://github.com/SWI-Prolog/packages-zlib.git
 check_checked_out  /opt/logicmoo_workspace/swipl-devel/packages/clpqr https://github.com/SWI-Prolog/packages-clpqr.git
 check_checked_out  /opt/logicmoo_workspace/swipl-devel/packages/inclpr https://github.com/SWI-Prolog/packages-inclpr.git
 check_checked_out  /opt/logicmoo_workspace/swipl-devel/packages/redis https://github.com/SWI-Prolog/packages-redis.git
 check_checked_out  /opt/logicmoo_workspace/swipl-devel/packages/stomp https://github.com/SWI-Prolog/packages-stomp.git
 check_checked_out  /opt/logicmoo_workspace/swipl-devel/packages/pcre https://github.com/SWI-Prolog/packages-pcre.git
 check_checked_out  /opt/logicmoo_workspace/swipl-devel/packages/bdb https://github.com/SWI-Prolog/packages-bdb.git
 check_checked_out  /opt/logicmoo_workspace/swipl-devel/packages/windows https://github.com/SWI-Prolog/packages-windows.git
 check_checked_out  /opt/logicmoo_workspace/swipl-devel/packages/swipl-win https://github.com/SWI-Prolog/packages-swipl-win.git
 check_checked_out  /opt/logicmoo_workspace/swipl-devel/packages/libedit https://github.com/SWI-Prolog/packages-libedit.git
 check_checked_out  /opt/logicmoo_workspace/swipl-devel/packages/ssl https://github.com/SWI-Prolog/packages-ssl.git
 check_checked_out  /opt/logicmoo_workspace/swipl-devel/packages/http https://github.com/SWI-Prolog/packages-http.git
 check_checked_out  /opt/logicmoo_workspace/swipl-devel/packages/odbc https://github.com/SWI-Prolog/packages-odbc.git
 check_checked_out  /opt/logicmoo_workspace/swipl-devel/packages/xpce https://github.com/SWI-Prolog/packages-xpce.git
 check_checked_out  /opt/logicmoo_workspace/swipl-devel/packages/table https://github.com/SWI-Prolog/packages-table.git
 check_checked_out  /opt/logicmoo_workspace/swipl-devel/packages/chr https://github.com/SWI-Prolog/packages-chr.git
 check_checked_out  /opt/logicmoo_workspace/swipl-devel https://github.com/SWI-Prolog/swipl-devel.git
 check_checked_out  /opt/logicmoo_workspace/swipl-devel/bench https://github.com/SWI-Prolog/bench.git
 check_checked_out  /opt/logicmoo_workspace/swipl-devel/debian https://github.com/SWI-Prolog/distro-debian.git

}
