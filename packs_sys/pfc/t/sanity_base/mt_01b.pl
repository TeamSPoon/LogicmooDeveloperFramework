/* <module>
%
%  PFC is a language extension for prolog.
%
%  It adds a new type of module inheritance
%
% Dec 13, 2035
% Douglas Miles
*/
%  was_module(header_sane,[]).

:- include(library(logicmoo_test_header)).

:- expects_dialect(pfc).

loves(sally,joe).

:- mpred_test(clause_u(header_sane:loves(_,_))).

:- mpred_test(\+clause_u(baseKB:loves(_,_))).


end_of_file.


%TODO Make a test to show new inheretence 

inheritableRelation(a/1).

nonInheritableRelation(a/1).

kb1:a(1).
kb2:a(2).
kb3:a(3).

:- import_module(kb2,kb1).

kb2: ?- a(W).

W=2.
% feaurta added
W=1.


% ISSUE: https://github.com/logicmoo/logicmoo_workspace/issues/389 
% EDIT: https://github.com/logicmoo/logicmoo_workspace/edit/master/packs_sys/pfc/t/sanity_base/mt_01b.pl 
% JENKINS: https://jenkins.logicmoo.org/job/logicmoo_workspace/lastBuild/testReport/logicmoo.pfc.test.sanity_base/MT_01B/logicmoo_pfc_test_sanity_base_MT_01B_JUnit/ 
% ISSUE_SEARCH: https://github.com/logicmoo/logicmoo_workspace/issues?q=is%3Aissue+label%3AMT_01B 

