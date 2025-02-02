#!/usr/bin/env lmoo-junit

% Tests Emulation of assertable attributed variables
:- include(library(logicmoo_test_header)).

:- if(\+ current_module(attvar_reader)).
:- use_module(library(logicmoo/attvar_reader)).
:- endif.

%:- pfc_test_feature(mt,must_not_be_pfc_file).

sk1:attr_unify_hook(_,_).

:- debug_logicmoo(_).
:- nodebug_logicmoo(http(_)).
:- debug_logicmoo(logicmoo(_)).

% :- dynamic(sk1_in/1).

:- read_attvars(true).
% :- set_prolog_flag(assert_attvars,true).

sk1_in(aVar([vn='Ex'],[sk1='SKF-666'])).

:- listing(sk1_in/1).

:- must((sk1_in(Ex),get_attr(Ex,sk1,What),What=='SKF-666')).


% EDIT: https://github.com/logicmoo/logicmoo_workspace/edit/master/packs_sys/pfc/t/sanity_base/attvar_01.pl 
% JENKINS: https://jenkins.logicmoo.org/job/logicmoo_workspace/lastBuild/testReport/logicmoo.pfc.test.sanity_base/ATTVAR_01/ 
% ISSUE_SEARCH: https://github.com/logicmoo/logicmoo_workspace/issues?q=is%3Aissue+label%3AATTVAR_01 

% ISSUE: https://github.com/logicmoo/logicmoo_workspace/issues/584
