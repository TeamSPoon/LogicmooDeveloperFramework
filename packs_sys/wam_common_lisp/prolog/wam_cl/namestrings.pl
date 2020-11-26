/*******************************************************************
 *
 * A Common Lisp compiler/interpretor, written in Prolog
 *
 * (xxxxx.pl)
 *
 *
 * Douglas'' Notes:
 *
 * Utils to add source debugging vars with almost almost pleasant atoms names 
 *
 * *PACKAGE* becomes xx_package_xx
 * %MAKE-PACKAGE becomes pf_make_package
 *
 * @TODO:  List symbols that were named "FOO_123" might become "prefix_foo__123" (two underscores) vs one underscore 
 * so that "FOO-123" will become 'prefix_foo_123'
 *
 * (c) Douglas Miles, 2017
 *
 * The program is a *HUGE* common-lisp compiler/interpreter. It is written for YAP/SWI-Prolog .
 *
 *******************************************************************/
:- module(pnames, []).

:- include('./header').

%:- if(exists_source(library(logicmoo/portray_vars))).
%:- reexport(library(logicmoo/portray_vars)).



atom_concat_suffix('',Result,Result):-!.
atom_concat_suffix(Result,'',Result):-!.
atom_concat_suffix(Root,Suffix,Root):- atom_concat(_,Suffix,Root),!.
atom_concat_suffix(Root,Suffix,Result):- 
  atom_trim_prefix1(Suffix,'_',Suffix2),
  atom_trim_suffix1(Root,'_',Root2),
  atomic_list_concat([Root2,Suffix2],'_',Result),!.


atom_trim_prefix1(Root,Prefix,Result):- atom_concat(Prefix,Result,Root) -> true ; Result=Root.
atom_trim_suffix1(Root,Suffix,Result):- atom_concat(Result,Suffix,Root) -> true ; Result=Root.


:- fixup_exports.

end_of_file.

:- else.

atom_trim_prefix(Root,Prefix,Result):- atom_concat(Prefix,Result,Root) -> true ; Result=Root.
atom_trim_suffix(Root,Suffix,Result):- atom_concat(Result,Suffix,Root) -> true ; Result=Root.

% debug_var(_A,_Var):-!.
debug_var(X,Y):- notrace(catch(debug_var0(X,Y),_,fail)) -> true ; rtrace(debug_var0(X,Y)).

maybe_debug_var(X,Y):- notrace(maybe_debug_var0(X,Y)).
maybe_debug_var0(_,Y):- nonvar(Y),!.
maybe_debug_var0(X,_):- get_var_name(X,_),!.
maybe_debug_var0(X,Y):- (catch(debug_var0(X,Y),_,fail)) -> true ; rtrace(debug_var0(X,Y)).

debug_var(Sufix,X,Y):- notrace((flatten([X,Sufix],XS),debug_var(XS,Y))).

p_n_atom(Cmpd,UP):- sub_term(Atom,Cmpd),nonvar(Atom),\+ number(Atom), Atom\==[], catch(p_n_atom0(Atom,UP),_,fail),!.
p_n_atom(Cmpd,UP):- term_to_atom(Cmpd,Atom),p_n_atom0(Atom,UP),!.

filter_var_chars([58|X],[107, 119, 95|Y]):- filter_var_chars_trim_95(X,Y).
filter_var_chars([95|X],[95|Y]):- !, filter_var_chars_trim_95(X,Y).
filter_var_chars(X,Y):- filter_var_chars_trim_95(X,Y).



filter_var_chars_trim_95(X,Y):- filter_var_chars0(X,M),trim_95(M,Y),!.

trim_95([X],[X]).
trim_95([95|M],Y):-!, trim_95(M,Y).
trim_95([X|L],[100,X|Y]):- char_type(X,digit), trim_96(L,Y).
trim_95([X|L],[97,X|Y]):- \+ char_type(X,alpha), trim_96(L,Y).
trim_95(X,Y):- trim_96(X,Y).

trim_96([95],[]).
trim_96([],[]).
trim_96([95,95|M],Y):- trim_96([95|M],Y).
trim_96([X|M],[X|Y]):- trim_96(M,Y).



filter_var_chars0([],[]).


% WATN WHEN MAKING SYMBOLs...  `_` -> `__`

%  `-` -> `c45`
filter_var_chars0(`-`,`c45`):-!.
%  `*` -> `_xx_`
filter_var_chars0([42|T],[95,120,120,95|Rest]):-!,filter_var_chars0(T,Rest).
%  `%` -> `_pf_`
filter_var_chars0([37|T],[95,112, 102, 95| Rest]):-!,filter_var_chars0(T,Rest).
%  `-` -> `_`
filter_var_chars0([45|T],[95|Rest]):-!,filter_var_chars0(T,Rest).
%  `:` -> `_`
filter_var_chars0([42|T],[95,120,95|Rest]):-!,filter_var_chars0(T,Rest).
filter_var_chars0([H|T],[H|Rest]):-  code_type(H, prolog_identifier_continue),!,filter_var_chars0(T,Rest).
filter_var_chars0([H|T],Rest):- number_codes(H,Codes), filter_var_chars0(T,Mid),append([95, 99|Codes],[95|Mid],Rest).

atom_concat_some_left(L,R,LR):- atom_concat(L,R,LR),atom_length(R,Len),Len>0.
atom_concat_some_left(L,R,LR):- upcase_atom(L,L0),L\==L0,atom_concat(L0,R,LR),atom_length(R,Len),Len>0.
atom_concat_some_left(L,R,LR):- downcase_atom(L,L0),L\==L0,atom_concat(L0,R,LR),atom_length(R,Len),Len>0.

reduce_atomLR(L,R):- atom_concat_some_left('Cl_',LL,L),reduce_atomLR(LL,R).
reduce_atomLR(L,R):- atom_concat_some_left('U_',LL,L),reduce_atomLR(LL,R).
reduce_atomLR(L,R):- atom_concat_some_left('F_',LL,L),reduce_atomLR(LL,R).
reduce_atomLR(L,R):- atom_concat_some_left('Pf_',LL,L),reduce_atomLR(LL,R).
reduce_atomLR(L,R):- atom_concat_some_left('Kw_',LL,L),reduce_atomLR(LL,R).
reduce_atomLR(L,R):- atom_concat_some_left('Sys_',LL,L),reduce_atomLR(LL,R).
reduce_atomLR(L,L).

p_n_atom0(Atom,UP):- atom(Atom),!,
  reduce_atomLR(Atom,AtomR),
  name(AtomR,[C|Was]),to_upper(C,U),filter_var_chars([U|Was],CS),name(UP,CS).
p_n_atom0(String,UP):- string(String),!,string_to_atom(String,Atom),!,p_n_atom0(Atom,UP).
p_n_atom0([C|S],UP):- !,notrace(catch(atom_codes(Atom,[C|S]),_,fail)),!,p_n_atom0(Atom,UP).

debug_var0(_,NonVar):-nonvar(NonVar),!.
debug_var0([C|S],Var):- notrace(catch(atom_codes(Atom,[C|S]),_,fail)),!,debug_var0(Atom,Var).
debug_var0([AtomI|Rest],Var):-!,maplist(p_n_atom,[AtomI|Rest],UPS),atomic_list_concat(UPS,NAME),debug_var0(NAME,Var),!.
debug_var0(Atom,Var):- p_n_atom(Atom,UP),  
  check_varname(UP),
  add_var_to_env_loco(UP,Var),!.


add_var_to_env_loco(UP,Var):- var(Var), get_var_name(Var,Prev),atomic(Prev),add_var_to_env_locovs_prev(UP,Prev,Var).
add_var_to_env_loco(UP,Var):-add_var_to_env(UP,Var).

add_var_to_env_locovs_prev(UP,Prev,_Var):- UP==Prev,!.
add_var_to_env_locovs_prev(UP,_Prev,_Var):- atom_concat_or_rtrace('_',_,UP),!.
add_var_to_env_locovs_prev(UP,_Prev,_Var):- atom_concat_or_rtrace(_,'_',UP),!.
add_var_to_env_locovs_prev(UP,_Prev,Var):-add_var_to_env(UP,Var).
add_var_to_env_locovs_prev(UP,Prev,Var):- atom_concat_or_rtrace('_',_,Prev),!,add_var_to_env(UP,Var).
add_var_to_env_locovs_prev(UP,Prev,Var):- atom_concat_or_rtrace(UP,Prev,New),add_var_to_env(New,Var).
add_var_to_env_locovs_prev(UP,_Prev,Var):- add_var_to_env(UP,Var).

check_varname(UP):- name(UP,[C|_]),(char_type(C,digit)->throw(check_varname(UP));true).
                        


resolve_char_codes('','_').
resolve_char_codes('pf','%').
%resolve_char_codes(C48,C):- notrace(catch((name(C48,[99|Codes]),number_codes(N,Codes),name(C,[N])),_,fail)),!,fail.
resolve_char_codes(C48,_):- notrace(catch((name(C48,[99|Codes]),number_codes(_,Codes)),_,fail)),!,fail.
resolve_char_codes(D1,N):- atom_concat('d',N,D1),notrace(catch(atom_number(N,_),_,fail)),!.
resolve_char_codes(C,CC):- atom_concat(C,'-',CC).

into_symbol_name(Atom,UPPER):- atomic(Atom),atomic_list_concat([Pkg|HC],'_',Atom),!,into_symbol_name([Pkg|HC],UPPER).
into_symbol_name(HC,UPPER):- maplist(resolve_char_codes,HC,RHC),atomics_to_string(RHC,'',STR),
   atom_trim_suffix(STR,'-',Trimed),string_upper(Trimed,UPPER),!.

% *PACKAGE* becomes xx_package_xx
% %MAKE-PACKAGE becomes pf_make_package

prologcase_name(I,O):-notrace(prologcase_name0(I,O)),assertion(O\=='').

prologcase_name0(String,Nonvar):-nonvar(Nonvar),!,prologcase_name(String,ProposedName),!,ProposedName==Nonvar.
prologcase_name0(String,ProposedName):- 
  string_lower(String,In),string_codes(In,Was),!,filter_var_chars(Was,CS),!,name(ProposedName,CS),!.


:- endif.


