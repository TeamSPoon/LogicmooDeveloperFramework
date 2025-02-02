

% swipl  % 396,814,768 inferences, 62.415 CPU in 62.434 seconds (100% CPU, 6357653 Lips)
% XSB 5 seconds
% dra-intrerp 

:- use_module(library(dra)).
:- dra_table(tc/2).

tc(X,Y):- adj(X,Y).
tc(X,Z):- tc(X,Y), tc(Y,Z).

adj(1,2).
adj(2,3).
adj(3,4).
adj(4,5).
adj(5,6).
adj(6,7).
adj(7,8).
adj(8,9).
adj(9,10).
adj(10,11).
adj(11,12).
adj(12,13).
adj(13,14).
adj(14,15).
adj(15,16).
adj(16,17).
adj(17,18).
adj(18,19).
adj(19,20).
adj(20,21).
adj(21,22).
adj(22,23).
adj(23,24).
adj(24,25).
adj(25,26).
adj(26,27).
adj(27,28).
adj(28,29).
adj(29,30).
adj(30,31).
adj(31,32).
adj(32,33).
adj(33,34).
adj(34,35).
adj(35,36).
adj(36,37).
adj(37,38).
adj(38,39).
adj(39,40).
adj(40,1).

:- use_module(library(statistics)).
:- statistics(cputime,X),assert(load_time(X)).
:- time(findall(_,tc(_X,_Y),_)).
:- statistics(cputime,X),retract(load_time(LT)), Time is X-LT,write(time_was(Time)).


% ISSUE: https://github.com/logicmoo/logicmoo_workspace/issues/381 
% EDIT: https://github.com/logicmoo/logicmoo_workspace/edit/master/packs_sys/pfc/t/sanity_base/nldm40_dra.pl 
% JENKINS: https://jenkins.logicmoo.org/job/logicmoo_workspace/lastBuild/testReport/logicmoo.pfc.test.sanity_base/NLDM40_DRA/logicmoo_pfc_test_sanity_base_NLDM40_DRA_JUnit/ 
% ISSUE_SEARCH: https://github.com/logicmoo/logicmoo_workspace/issues?q=is%3Aissue+label%3ANLDM40_DRA 

