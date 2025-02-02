/* <module>
%
%  PFC is a language extension for prolog.
%
%  It adds a new type of module inheritance
%
% Dec 13, 2035
% Douglas Miles
*/
%  was_module(mt_01,[]).

:- include(library(logicmoo_test_header)).



:- expects_dialect(pfc).

:- set_defaultAssertMt(myMt).

baseKB:mtHybrid(socialMt).

socialMt:loves(sally,joe).

:- set_defaultAssertMt(myMt).

:- mpred_test(clause_u(socialMt:loves(_,_))).
:- mpred_test(\+clause_u(myMt:loves(_,_))).
:- mpred_test(\+clause_u(header_sanity:loves(_,_))).




% EDIT: https://github.com/logicmoo/logicmoo_workspace/edit/master/packs_sys/pfc/t/sanity_base/mt_01.pl 
% JENKINS: https://jenkins.logicmoo.org/job/logicmoo_workspace/lastBuild/testReport/logicmoo.pfc.test.sanity_base/MT_01/ 
% ISSUE_SEARCH: https://github.com/logicmoo/logicmoo_workspace/issues?q=is%3Aissue+label%3AMT_01 

% ISSUE: https://github.com/logicmoo/logicmoo_workspace/issues/576
