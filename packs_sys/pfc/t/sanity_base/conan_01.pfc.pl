#!/usr/bin/env lmoo-junit

%  was_module(sanity_ks_two,[]).

%# Test not present yet
:- include(library(logicmoo_test_header)).

/*

((prologHybrid(F),arity(F,A)/is_ftNameArity(F,A))<==>mpred_prop(F,A,prologHybrid)/is_ftNameArity(F,A)).

prologMultiValued(mudDescription(ftTerm,ftText), [predProxyAssert(add_description),predProxyRetract(remove_description),predProxyQuery(query_description)],prologHybrid).

prologHybrid(isEach(mudLastCommand/2,mudNamed/2, mudSpd/2,mudStr/2,typeGrid/3)).

((prologHybrid(F),arity(F,A)/is_ftNameArity(F,A))<==>mpred_prop(F,A,prologHybrid)/is_ftNameArity(F,A)).


:- ain(ttRelationType(rtFOO)).
% :- must((fully_expand( rtFOO(foo/2),O), O = (arity(foo, 2), rtFOO(foo), tPred(foo)))).

:- must((fully_expand( rtFOO(foo/2),O), sub_term(Sub,O),Sub==rtFOO(foo))).

*/





% EDIT: https://github.com/logicmoo/logicmoo_workspace/edit/master/packs_sys/pfc/t/sanity_base/conan_01.pfc.pl 
% JENKINS: https://jenkins.logicmoo.org/job/logicmoo_workspace/lastBuild/testReport/logicmoo.pfc.test.sanity_base/CONAN_01/ 
% ISSUE_SEARCH: https://github.com/logicmoo/logicmoo_workspace/issues?q=is%3Aissue+label%3ACONAN_01 

% ISSUE: https://github.com/logicmoo/logicmoo_workspace/issues/561
