#!/usr/bin/env lmoo-junit
%
%  PFC is a language extension for prolog.. there is so much that can be done in this language extension to Prolog
%
% Dec 13, 2035
% Douglas Miles

% Tests if Finin Backchaining memo idea is working


%  was_module(bc_01,[]).

:- include(library(logicmoo_test_header)).


:- dynamic(cond_POST/1).
:- dynamic(cond_PRE/1).

cond_PRE ==> cond_POST.
cond_PRE.

cond_PRE ==> child_POST.
cond_PRE_D ==> cond_POST.

:- mpred_why(cond_POST).

:- mpred_trace_exec.

aaa.

bbbb.

:- pp_DB.

:- mpred_reset.

:- pp_DB.


% ISSUE: https://github.com/logicmoo/logicmoo_workspace/issues/338 
% EDIT: https://github.com/logicmoo/logicmoo_workspace/edit/master/packs_sys/pfc/t/sanity_base/reset_db_01.pfc.pl 
% JENKINS: https://jenkins.logicmoo.org/job/logicmoo_workspace/lastBuild/testReport/logicmoo.pfc.test.sanity_base/RESET_DB_01/ 
% ISSUE_SEARCH: https://github.com/logicmoo/logicmoo_workspace/issues?q=is%3Aissue+label%3ARESET_DB_01 

