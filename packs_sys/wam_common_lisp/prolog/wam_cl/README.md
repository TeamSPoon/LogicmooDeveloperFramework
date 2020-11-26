````
root@gitlab:/home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl# swipl repl.pl
Installed packages (38):

i clause_attvars@1.1.118    - An alternate interface to the clause database to allow attributed variables to be asserted
i dictoo@1.1.118            - Dict-like OO Syntax
i each_call_cleanup@1.1.118 - Each Call Redo Setup and Cleanup
i eggdrop@1.1.118           - Hook up to an existing IRC Client called an Eggdrop
i file_scope@1.1.118        - File local scoped efects
i fluxplayer-prolog-engine@0.0.1 - Prolog interface to Slack http://www.slack.com
i gvar_syntax@1.1.118       - Global Variable Syntax
i hook_hybrid@1.1.118       - Hook assert retract call of *specific* predicates
i instant_prolog_docs@1.1.118 - Magically document prolog source files based on predicate and variable naming conventions
i lib_atts@1.1.118          - Common atts.pl interface like https://sicstus.sics.se/sicstus/docs/4.0.0/html/sicstus/lib_002datts.html
i logicmoo_base@1.1.118     - LogicMOO - Extends Prolog Programming to support Dynamic Epistemic Logic (DEL) with Constraints
i logicmoo_experimental@1.1.118 - Various experimental packages - warning: HUGE amount of test data
i logicmoo_nlu@1.1.114      - Various English to Logic Convertors - warning: HUGE amount of test data
i logicmoo_packages@1.1.118 - Various packages - warning: HUGE amount of test data
i logicmoo_planner@1.1.118  - Various PDDLish planners - warning: HUGE amount of test data
i logicmoo_planners@1.1.118 - Various Hybrid HTN Planners speaking PDDLish and OCLh
i logicmoo_utils@1.1.118    - Common predicates used by external Logicmoo Utils and Base
i loop_check@1.1.118        - New simple loop checking
i mpi@1.0                   - Porting of the LAMMPI library of Yap Prolog to SWI-Prolog
i multimodal_dcg@1.1.118    - Reduce floundering of DCGs by constraining and narrowing search
i multivar@1.1.118          - User defined datatypes
i must_trace@1.1.118        - Trace with your eyeballs instead of your fingers
i no_repeats@1.1.118        - New ways to avoid duplicate solutions
i pfc@1.1.118               - Pfc -- a package for forward chaining in Prolog
i predicate_streams@1.1.118 - Implement your own Abstract Predicate Streams
i prologmud@1.1.118         - Online text adventure game - MUD Server
i prologmud_samples@1.1.118 - Online text adventure game - Sample
i s_expression@1.1.118      - Utilities for Handling of S-Expression Lisp/Scheme-Like forms and parsing of KIF, GDL, PDDL, CLIF
i slack_prolog@1.1.118      - Prolog interface to Slack http://www.slack.com
i subclause_expansion@1.1.118 - More use specific versions of term/goal expansion hooks
i tabling_dra@1.1.118       - SWI-Prolog interface to Table-handling procedures for the "dra" interpreter. Written by Feliks Kluzniak at UTD (March 2009)
i transpiler@0.1            - A universal translator for programming languages
i trill@4.1.0               - A tableau probabilistic reasoner in three different versions
i wam_common_lisp@1.1.118   - ANSI Common Lisp implemented in Prolog
i with_open_options@1.1.118 - Utilities to open various objects for read/write
i with_thread_local@1.1.118 - Call a Goal with local assertions
i xlisting@1.1.118          - Selective Interactive Non-Deterministic Tracing
i xlisting_web@1.1.118      - Manipulate and browse prolog runtime over www

__        ___    __  __        ____ _
\ \      / / \  |  \/  |      / ___| |
 \ \ /\ / / _ \ | |\/| |_____| |   | |
  \ V  V / ___ \| |  | |_____| |___| |___
   \_/\_/_/   \_\_|  |_|      \____|_____|

Common Lisp, written in Prolog
> ( defun foo ( a ) ( 1+ a ) )
/*
:- lisp_compile([defun, foo, [a], ['1+', a]]).
*/
/*
:- assert(arglist_info(foo,
                       [a],
                       [A],
                       arginfo{ all:1,
                                allow_other_keys:0,
                                aux:0,
                                env:0,
                                key:0,
                                names:[a],
                                opt:0,
                                req:1,
                                rest:0
                              })),
   asserta(user:function_lambda(defun, foo, [a], [['1+', a]])),
   asserta((foo(A, D1_c43_Ret):-!, Env=[[bv(a, [A|_276])]], env_sym_arg_val(Env, a, A_In, A_Thru), '1+'(A_Thru, D1_c43_Ret))).
*/
foo
> ( foo 2 )
/*
:- lisp_compile([foo, 2]).
*/
/*
:- foo(2, Foo_Ret).
*/
3
> ( defmacro p ( &rest r ) ` ( print ' , r ) )
/*
:- lisp_compile([defmacro, p, ['&rest', r], ['$BQ', [print, [quote, '$COMMA'(r)]]]]).
*/
/*
:- retractall(user:macro_lambda(defmacro, p, _9932, _9934)),
   asserta(user:macro_lambda(defmacro, p, ['&rest', r], [['$BQ', [print, [quote, ['$COMMA', r]]]]])).
*/
p
> ( p car )
/*
:- lisp_compile([p, car]).
*/
/*
:- macro(macroResult(true,
                     ((true, (true, true, true), true), true),
                     [[quote, [print, [quote, [car]]]]])).
*/
/*
:- must_compile_body(ctx{argbindings:[], head:lisp_compile},
                     [[bind, bv(r, [[car]|_12762])]|toplevel],
                     _9618,
                     [eval, [progn, [quote, [print, [quote, [car]]]]]],
                     _14838),_14838.
*/
[car]
( car )
> *package*
/*
:- lisp_compile('*package*').
*/
/*
:- env_sym_arg_val(toplevel, '*package*', Xx_package_xx_In, Xx_package_xx_Thru).
*/
#< package common-lisp-user >
> (setq foo 'bar)
/*
:- lisp_compile([setq, foo, [quote, bar]]).
*/
/*
:- symbol_setter(toplevel, setq, foo, bar).
*/
bar
> foo
/*
:- lisp_compile(foo).
*/
/*
:- env_sym_arg_val(toplevel, foo, Foo_In, Foo_Thru).
*/
bar



swipl -l  repl.pl -g "qsave_program(wamcl)" -t halt



Installed packages (38):

i clause_attvars@1.1.118    - An alternate interface to the clause database to allow attributed variables to be asserted
i dictoo@1.1.118            - Dict-like OO Syntax
i each_call_cleanup@1.1.118 - Each Call Redo Setup and Cleanup
i eggdrop@1.1.118           - Hook up to an existing IRC Client called an Eggdrop
i file_scope@1.1.118        - File local scoped efects
i fluxplayer-prolog-engine@0.0.1 - Prolog interface to Slack http://www.slack.com
i gvar_syntax@1.1.118       - Global Variable Syntax
i hook_hybrid@1.1.118       - Hook assert retract call of *specific* predicates
i instant_prolog_docs@1.1.118 - Magically document prolog source files based on predicate and variable naming conventions
i lib_atts@1.1.118          - Common atts.pl interface like https://sicstus.sics.se/sicstus/docs/4.0.0/html/sicstus/lib_002datts.html
i logicmoo_base@1.1.118     - LogicMOO - Extends Prolog Programming to support Dynamic Epistemic Logic (DEL) with Constraints
i logicmoo_experimental@1.1.118 - Various experimental packages - warning: HUGE amount of test data
i logicmoo_nlu@1.1.114      - Various English to Logic Convertors - warning: HUGE amount of test data
i logicmoo_packages@1.1.118 - Various packages - warning: HUGE amount of test data
i logicmoo_planner@1.1.118  - Various PDDLish planners - warning: HUGE amount of test data
i logicmoo_planners@1.1.118 - Various Hybrid HTN Planners speaking PDDLish and OCLh
i logicmoo_utils@1.1.118    - Common predicates used by external Logicmoo Utils and Base
i loop_check@1.1.118        - New simple loop checking
i mpi@1.0                   - Porting of the LAMMPI library of Yap Prolog to SWI-Prolog
i multimodal_dcg@1.1.118    - Reduce floundering of DCGs by constraining and narrowing search
i multivar@1.1.118          - User defined datatypes
i must_trace@1.1.118        - Trace with your eyeballs instead of your fingers
i no_repeats@1.1.118        - New ways to avoid duplicate solutions
i pfc@1.1.118               - Pfc -- a package for forward chaining in Prolog
i predicate_streams@1.1.118 - Implement your own Abstract Predicate Streams
i prologmud@1.1.118         - Online text adventure game - MUD Server
i prologmud_samples@1.1.118 - Online text adventure game - Sample
i s_expression@1.1.118      - Utilities for Handling of S-Expression Lisp/Scheme-Like forms and parsing of KIF, GDL, PDDL, CLIF
i slack_prolog@1.1.118      - Prolog interface to Slack http://www.slack.com
i subclause_expansion@1.1.118 - More use specific versions of term/goal expansion hooks
i tabling_dra@1.1.118       - SWI-Prolog interface to Table-handling procedures for the "dra" interpreter. Written by Feliks Kluzniak at UTD (March 2009)
i transpiler@0.1            - A universal translator for programming languages
i trill@4.1.0               - A tableau probabilistic reasoner in three different versions
i wam_common_lisp@1.1.118   - ANSI Common Lisp implemented in Prolog
i with_open_options@1.1.118 - Utilities to open various objects for read/write
i with_thread_local@1.1.118 - Call a Goal with local assertions
i xlisting@1.1.118          - Selective Interactive Non-Deterministic Tracing
i xlisting_web@1.1.118      - Manipulate and browse prolog runtime over www
index(zip/3,[1,2,3])
index(zip_with/4,[1,2,4])
optimize(zip/3)
optimize(zip_with/4)


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/lisp_library.pl:18
% <<==(second(l), first(rest(l))).
% second(L_In, First_Ret) :- !,
%       Env=[[bv(l, [L_In|__])]],
%       sym_arg_val_env(l, L_In, L_Thru, Env),
%       rest(L_Thru, Rest_Ret),
%       first(Rest_Ret, First_Ret).
% second(L_In, First_Ret) :-
%       fail,
%       ( <<==([second, l], [first, [rest, l]])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/lisp_library.pl:21
% <<==(third(l), first(rest(rest(l)))).
% third(L_In, First_Ret) :- !,
%       Env=[[bv(l, [L_In|__])]],
%       sym_arg_val_env(l, L_In, L_Thru, Env),
%       rest(L_Thru, Rest_Ret),
%       rest(Rest_Ret, Rest_Ret5),
%       first(Rest_Ret5, First_Ret).
% third(L_In, First_Ret) :-
%       fail,
%       ( <<==([third, l], [first, [rest, [rest, l]]])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/lisp_library.pl:28
% <<==(list_1(a), cons(a, nil)).
% list_1(A_In, RET) :- !,
%       Env=[[bv(a, [A_In|__])]],
%       sym_arg_val_env(a, A_In, A_Thru, Env),
%       RET=[A_Thru].
% list_1(A_In, RET) :-
%       fail,
%       ( <<==([list_1, a], [cons, a, nil])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/lisp_library.pl:31
% <<==(list_2(a, b), cons(a, list_1(b))).
% list_2(A_In, B_In, RET) :- !,
%       Env=[[bv(a, [A_In|__]), bv(b, [B_In|__7])]],
%       sym_arg_val_env(a, A_In, A_Thru, Env),
%       sym_arg_val_env(b, B_In, B_Thru, Env),
%       list_1(B_Thru, List_1_Ret),
%       RET=[A_Thru|List_1_Ret].
% list_2(A_In, B_In, RET) :-
%       fail,
%       ( <<==([list_2, a, b], [cons, a, [list_1, b]])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/lisp_library.pl:34
% <<==(list_3(a, b, c), cons(a, list_2(b, c))).
% list_3(A_In, B_In, C_In, RET) :- !,
%       Env=[[bv(a, [A_In|__]), bv(b, [B_In|__8]), bv(c, [C_In|__11])]],
%       sym_arg_val_env(a, A_In, A_Thru, Env),
%       sym_arg_val_env(b, B_In, B_Thru, Env),
%       sym_arg_val_env(c, C_In, C_Thru, Env),
%       list_2(B_Thru, C_Thru, List_2_Ret),
%       RET=[A_Thru|List_2_Ret].
% list_3(A_In, B_In, C_In, RET) :-
%       fail,
%       ( <<==([list_3, a, b, c], [cons, a, [list_2, b, c]])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/lisp_library.pl:38
% <<==(lisp_append(l1, l2), if(null(l1), l2, cons(first(l1), lisp_append(rest(l1), l2)))).
% lisp_append(L1_In11, L2_In14, RET) :- !,
%       Env=[[bv(l1, [L1_In11|__]), bv(l2, [L2_In14|__7])]],
%       sym_arg_val_env(l1, L1_In11, L1_Thru, Env),
%       (   L1_Thru==[]
%       ->  sym_arg_val_env(l2, L2_In14, L2_Thru, Env),
%           RET=L2_Thru
%       ;   first(L1_In11, First_Ret),
%           rest(L1_In11, Rest_Ret),
%           lisp_append(Rest_Ret, L2_In14, Lisp_append_Ret),
%           _1868=[First_Ret|Lisp_append_Ret],
%           RET=_1868
%       ).
% lisp_append(L1_In11, L2_In14, RET) :-
%       fail,
%       ( <<==([lisp_append, l1, l2], [if, [null, l1], l2, [cons, [first, l1], [lisp_append, [rest, l1], l2]]])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/lisp_library.pl:46
% <<==(mapcar(func, l), if(null(l), nil, cons(lisp_apply(func, list_1(first(l))), mapcar(func, rest(l))))).
% mapcar(Func_In13, L_In16, RET) :- !,
%       Env=[[bv(func, [Func_In13|__7]), bv(l, [L_In16|__])]],
%       sym_arg_val_env(l, L_In16, L_Thru, Env),
%       (   L_Thru==[]
%       ->  RET=[]
%       ;   sym_arg_val_env(func, Func_In13, Func_Thru, Env),
%           first(L_In16, First_Ret),
%           list_1(First_Ret, List_1_Ret),
%           lisp_apply(Func_Thru, List_1_Ret, Lisp_apply_Ret),
%           rest(L_In16, Rest_Ret),
%           mapcar(Func_In13, Rest_Ret, Mapcar_Ret),
%           _1804=[Lisp_apply_Ret|Mapcar_Ret],
%           RET=_1804
%       ).
% mapcar(Func_In13, L_In16, RET) :-
%       fail,
%       ( <<==([mapcar, func, l], [if, [null, l], nil, [cons, [lisp_apply, func, [list_1, [first, l]]], [mapcar, func, [rest, l]]]])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/streams.pl:19
% <<==(stream_first(stream), first(stream)).
% stream_first(Stream_In, First_Ret) :- !,
%       Env=[[bv(stream, [Stream_In|__])]],
%       sym_arg_val_env(stream, Stream_In, Stream_Thru, Env),
%       first(Stream_Thru, First_Ret).
% stream_first(Stream_In, First_Ret) :-
%       fail,
%       ( <<==([stream_first, stream], [first, stream])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/streams.pl:22
% <<==(stream_rest(stream), lisp_apply(second(stream), [])).
% stream_rest(Stream_In, Lisp_apply_Ret) :- !,
%       Env=[[bv(stream, [Stream_In|__])]],
%       sym_arg_val_env(stream, Stream_In, Stream_Thru, Env),
%       second(Stream_Thru, Second_Ret),
%       lisp_apply(Second_Ret, [], Lisp_apply_Ret).
% stream_rest(Stream_In, Lisp_apply_Ret) :-
%       fail,
%       ( <<==([stream_rest, stream], [lisp_apply, [second, stream], []])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/streams.pl:25
% <<==(stream_cons(a, b), list_2(a, b)).
% stream_cons(A_In, B_In, List_2_Ret) :- !,
%       Env=[[bv(a, [A_In|__]), bv(b, [B_In|__7])]],
%       sym_arg_val_env(a, A_In, A_Thru, Env),
%       sym_arg_val_env(b, B_In, B_Thru, Env),
%       list_2(A_Thru, B_Thru, List_2_Ret).
% stream_cons(A_In, B_In, List_2_Ret) :-
%       fail,
%       ( <<==([stream_cons, a, b], [list_2, a, b])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/streams.pl:28
% <<==(stream_null(stream), null(stream)).
% stream_null(Stream_In, Null_Ret) :- !,
%       Env=[[bv(stream, [Stream_In|__])]],
%       sym_arg_val_env(stream, Stream_In, Stream_Thru, Env),
%       null(Stream_Thru, Null_Ret).
% stream_null(Stream_In, Null_Ret) :-
%       fail,
%       ( <<==([stream_null, stream], [null, stream])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/streams.pl:33
% <<==(stream_take(n, stream), if(or(equalp(n, 0), stream_null(stream)), [], cons(stream_first(stream), stream_take(minus(n, 1), stream_rest(stream))))).
% stream_take(N_In15, Stream_In18, RET) :- !,
%       Env=[[bv(n, [N_In15|__]), bv(stream, [Stream_In18|__8])]],
%       sym_arg_val_env(n, N_In15, N_Thru, Env),
%       equalp(N_Thru, 0, Equalp_Ret),
%       sym_arg_val_env(stream, Stream_In18, Stream_Thru, Env),
%       stream_null(Stream_Thru, Stream_null_Ret),
%       or(Equalp_Ret, Stream_null_Ret, Or_Ret),
%       (   Or_Ret\=[]
%       ->  RET=[]
%       ;   stream_first(Stream_In18, Stream_first_Ret),
%           minus(N_In15, 1, Minus_Ret),
%           stream_rest(Stream_In18, Stream_rest_Ret),
%           stream_take(Minus_Ret, Stream_rest_Ret, Stream_take_Ret),
%           _2004=[Stream_first_Ret|Stream_take_Ret],
%           RET=_2004
%       ).
% stream_take(N_In15, Stream_In18, RET) :-
%       fail,
%       ( <<==([stream_take, n, stream], [if, [or, [equalp, n, 0], [stream_null, stream]], [], [cons, [stream_first, stream], [stream_take, [minus, n, 1], [stream_rest, stream]]]])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/streams.pl:40
% <<==(stream_drop(n, stream), if(or(equalp(n, 0), stream_null(stream)), stream, stream_drop(minus(n, 1), stream_rest(stream)))).
% stream_drop(N_In14, Stream_In17, RET) :- !,
%       Env=[[bv(n, [N_In14|__]), bv(stream, [Stream_In17|__8])]],
%       sym_arg_val_env(n, N_In14, N_Thru, Env),
%       equalp(N_Thru, 0, Equalp_Ret),
%       sym_arg_val_env(stream, Stream_In17, Stream_Thru, Env),
%       stream_null(Stream_Thru, Stream_null_Ret),
%       or(Equalp_Ret, Stream_null_Ret, Or_Ret),
%       (   Or_Ret\=[]
%       ->  RET=Stream_In17
%       ;   minus(N_In14, 1, Minus_Ret),
%           stream_rest(Stream_In17, Stream_rest_Ret),
%           stream_drop(Minus_Ret, Stream_rest_Ret, Stream_drop_Ret),
%           RET=Stream_drop_Ret
%       ).
% stream_drop(N_In14, Stream_In17, RET) :-
%       fail,
%       ( <<==([stream_drop, n, stream], [if, [or, [equalp, n, 0], [stream_null, stream]], stream, [stream_drop, [minus, n, 1], [stream_rest, stream]]])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/streams.pl:47
% <<==(stream_interval(low, high), if(equalp(low, high), [], stream_cons(low, function(lambda([], stream_interval(plus(low, 1), high)))))).
% stream_interval(Low_In11, High_In14, RET) :- !,
%       Env=[[bv(low, [Low_In11|__]), bv(high, [High_In14|__7])]],
%       sym_arg_val_env(low, Low_In11, Low_Thru, Env),
%       sym_arg_val_env(high, High_In14, High_Thru, Env),
%       equalp(Low_Thru, High_Thru, Equalp_Ret),
%       (   Equalp_Ret\=[]
%       ->  RET=[]
%       ;   stream_cons(Low_In11,
%
%                       [ closure,
%                         [],
%                         [LEnv, Stream_interval_Ret]^(plus(Low_In11, 1, Plus_Ret), stream_interval(Plus_Ret, High_In14, Stream_interval_Ret)),
%                         Env
%                       ],
%                       Stream_cons_Ret),
%           RET=Stream_cons_Ret
%       ).
% stream_interval(Low_In11, High_In14, RET) :-
%       fail,
%       ( <<==([stream_interval, low, high], [if, [equalp, low, high], [], [stream_cons, low, [function, [lambda, [], [stream_interval, [plus, low, 1], high]]]]])
%       ).
Warning: /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/streams.pl:47:
        Singleton variable in branch: LEnv


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/streams.pl:54
% <<==(stream_ints_from(n), stream_cons(n, function(lambda([], stream_ints_from(plus(n, 1)))))).
% stream_ints_from(N_In4, Stream_cons_Ret) :- !,
%       Env=[[bv(n, [N_In4|__])]],
%       sym_arg_val_env(n, N_In4, N_Thru, Env),
%       stream_cons(N_Thru,
%
%                   [ closure,
%                     [],
%                     [LEnv, Stream_ints_from_Ret]^(plus(N_In4, 1, Plus_Ret), stream_ints_from(Plus_Ret, Stream_ints_from_Ret)),
%                     Env
%                   ],
%                   Stream_cons_Ret).
% stream_ints_from(N_In4, Stream_cons_Ret) :-
%       fail,
%       ( <<==([stream_ints_from, n], [stream_cons, n, [function, [lambda, [], [stream_ints_from, [plus, n, 1]]]]])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/streams.pl:59
% <<==(t1, stream_take(3, stream_interval(1, 5))).
% t1(Stream_take_Ret) :- !,
%       Env=[[]],
%       stream_interval(1, 5, Stream_interval_Ret),
%       stream_take(3, Stream_interval_Ret, Stream_take_Ret).
% t1(Stream_take_Ret) :-
%       fail,
%       ( <<==(t1, [stream_take, 3, [stream_interval, 1, 5]])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/streams.pl:62
% <<==(t2, stream_take(5, stream_drop(10, stream_ints_from(1)))).
% t2(Stream_take_Ret) :- !,
%       Env=[[]],
%       stream_ints_from(1, Stream_ints_from_Ret),
%       stream_drop(10, Stream_ints_from_Ret, Stream_drop_Ret),
%       stream_take(5, Stream_drop_Ret, Stream_take_Ret).
% t2(Stream_take_Ret) :-
%       fail,
%       ( <<==(t2, [stream_take, 5, [stream_drop, 10, [stream_ints_from, 1]]])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/tests.pl:17
% <<==(simple(x), x).
% simple(X_In, X_Thru) :- !,
%       Env=[[bv(x, [X_In|__])]],
%       sym_arg_val_env(x, X_In, X_Thru, Env).
% simple(X_In, X_Thru) :-
%       fail,
%       ( <<==([simple, x], x)
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/tests.pl:20
% <<==(lisp_append_2(l1, l2), cond([[null(l1), l2], [t, cons(first(l1), lisp_append_2(rest(l1), l2))]])).
% lisp_append_2(L1_In12, L2_In15, RET) :- !,
%       Env=[[bv(l1, [L1_In12|__]), bv(l2, [L2_In15|__8])]],
%       sym_arg_val_env(l1, L1_In12, L1_Thru, Env),
%       null(L1_Thru, Null_Ret),
%       (   Null_Ret\=[]
%       ->  sym_arg_val_env(l2, L2_In15, L2_Thru, Env),
%           RET=L2_Thru
%       ;   (   t\=[]
%           ->  first(L1_In12, First_Ret),
%               rest(L1_In12, Rest_Ret),
%               lisp_append_2(Rest_Ret, L2_In15, Lisp_append_2_Ret),
%               _1926=[First_Ret|Lisp_append_2_Ret],
%               _1924=_1926
%           ;   _1924=[]
%           ),
%           RET=_1924
%       ).
% lisp_append_2(L1_In12, L2_In15, RET) :-
%       fail,
%       ( <<==([lisp_append_2, l1, l2], [cond, [[[null, l1], l2], [t, [cons, [first, l1], [lisp_append_2, [rest, l1], l2]]]]])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/tests.pl:27
% <<==(lisp_error(x), setq(y, 5)).
% lisp_error(X, 5) :- !,
%       Env=[[bv(x, [X|_1346])]],
%       symbol_setq(y, 5, Env).
% lisp_error(X, 5) :-
%       fail,
%       ( <<==([lisp_error, x], [setq, y, 5])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/tests.pl:30
% <<==(lisp_let(), let([bind(x, 3), bind(y, 5)], progn(x, y))).
% lisp_let(Y_Thru) :- !,
%       Env=[[]],
%       LETENV=[[bv(x, [3|_1520]), bv(y, [5|_1522])]|Env],
%       sym_arg_val_env(progn, Progn_In, Progn_Thru, LETENV),
%       sym_arg_val_env(x, X_In, X_Thru, LETENV),
%       sym_arg_val_env(y, Y_In, Y_Thru, LETENV).
% lisp_let(Y_Thru) :-
%       fail,
%       ( <<==([lisp_let], [let, [[bind, x, 3], [bind, y, 5]], [progn, x, y]])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/tests.pl:34
% <<==(lisp_let1(), let([bind(x, 3), bind(y, 5)], x, y)).
% lisp_let1(Y_Thru) :- !,
%       Env=[[]],
%       LETENV=[[bv(x, [3|_1498]), bv(y, [5|_1500])]|Env],
%       sym_arg_val_env(progn, Progn_In, Progn_Thru, LETENV),
%       sym_arg_val_env(x, X_In, X_Thru, LETENV),
%       sym_arg_val_env(y, Y_In, Y_Thru, LETENV).
% lisp_let1(Y_Thru) :-
%       fail,
%       ( <<==([lisp_let1], [let, [[bind, x, 3], [bind, y, 5]], x, y])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/tests.pl:41
% <<==(mapfirst(l), mapcar(function(first), l)).
% mapfirst(L_In, Mapcar_Ret) :- !,
%       Env=[[bv(l, [L_In|__])]],
%       sym_arg_val_env(l, L_In, L_Thru, Env),
%       mapcar([function, first], L_Thru, Mapcar_Ret).
% mapfirst(L_In, Mapcar_Ret) :-
%       fail,
%       ( <<==([mapfirst, l], [mapcar, [function, first], l])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/tests.pl:45
% <<==(defvar(fred, 13)).
% :- (   special_var(fred, _12608)
%    ->  true
%    ;   assert(special_var(fred, 13))
%    ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/tests.pl:47
% <<==(defvar(george)).
% :- (   special_var(george, _20380)
%    ->  true
%    ;   assert(special_var(george, []))
%    ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/tests.pl:50
% <<==(reset_george(val), setq(george, val)).
% reset_george(Val_In, Val_Thru) :- !,
%       Env=[[bv(val, [Val_In|__])]],
%       sym_arg_val_env(val, Val_In, Val_Thru, Env),
%       symbol_setq(george, Val_Thru, Env).
% reset_george(Val_In, Val_Thru) :-
%       fail,
%       ( <<==([reset_george, val], [setq, george, val])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/tests.pl:54
% <<==(make_adder(x), function(lambda([y], plus(x, y)))).
% make_adder(X_In, [closure, [y], [LEnv, Plus_Ret]^(((sym_arg_val_env(x, X_In, avar(X_Thru, att(initState, t, [])), LEnv), sym_arg_val_env(y, avar(Y_In, att(initState, t, [])), avar(Y_Thru, att(initState, t, [])), LEnv), true), plus(avar(X_Thru, att(initState, t, [])), avar(Y_Thru, att(initState, t, [])), Plus_Ret)), true), Env]) :- !,
%       Env=[[bv(x, [X_In|__])]].
% make_adder(X_In, [closure, [y], [LEnv, Plus_Ret]^(((sym_arg_val_env(x, X_In, avar(X_Thru, att(initState, t, [])), LEnv), sym_arg_val_env(y, avar(Y_In, att(initState, t, [])), avar(Y_Thru, att(initState, t, [])), LEnv), true), plus(avar(X_Thru, att(initState, t, [])), avar(Y_Thru, att(initState, t, [])), Plus_Ret)), true), Env]) :-
%       fail,
%       ( <<==([make_adder, x], [function, [lambda, [y], [plus, x, y]]])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/tests.pl:58
% <<==(scale_list(xs, scale), let([bind(fred, function(lambda([num], times(scale, num))))], mapcar(fred, xs))).
% scale_list(Xs_In, Scale_In, Xs_Thru) :- !,
%       Env=[[bv(xs, [Xs_In|__19]), bv(scale, [Scale_In|__])]],
%       LETENV=[[bv(fred, [[closure, [num], [LEnv, Times_Ret]^(sym_arg_val_env(scale, Scale_In, Scale_Thru, LEnv), sym_arg_val_env(num, Num_In, Num_Thru, LEnv), times(Scale_Thru, Num_Thru, Times_Ret)), Env]|_1924])]|Env],
%       sym_arg_val_env(mapcar, Mapcar_In, Mapcar_Thru, LETENV),
%       sym_arg_val_env(fred, Fred_In, Fred_Thru, LETENV),
%       sym_arg_val_env(xs, Xs_In, Xs_Thru, LETENV).
% scale_list(Xs_In, Scale_In, Xs_Thru) :-
%       fail,
%       ( <<==([scale_list, xs, scale], [let, [[bind, fred, [function, [lambda, [num], [times, scale, num]]]]], [mapcar, fred, xs]])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/tests.pl:62
% <<==(make_summer(total), function(lambda([n], setq(total, plus(total, n))))).
% make_summer(Total_In, [closure, [n], [LEnv, Plus_Ret]^((((sym_arg_val_env(total, Total_In, avar(Total_Thru, att(initState, t, [])), LEnv), sym_arg_val_env(n, avar(N_In, att(initState, t, [])), avar(N_Thru, att(initState, t, [])), LEnv), true), plus(avar(Total_Thru, att(initState, t, [])), avar(N_Thru, att(initState, t, [])), Plus_Ret)), symbol_setq(total, Plus_Ret, LEnv)), true), Env]) :- !,
%       Env=[[bv(total, [Total_In|__])]].
% make_summer(Total_In, [closure, [n], [LEnv, Plus_Ret]^((((sym_arg_val_env(total, Total_In, avar(Total_Thru, att(initState, t, [])), LEnv), sym_arg_val_env(n, avar(N_In, att(initState, t, [])), avar(N_Thru, att(initState, t, [])), LEnv), true), plus(avar(Total_Thru, att(initState, t, [])), avar(N_Thru, att(initState, t, [])), Plus_Ret)), symbol_setq(total, Plus_Ret, LEnv)), true), Env]) :-
%       fail,
%       ( <<==([make_summer, total], [function, [lambda, [n], [setq, total, [plus, total, n]]]])
%       ).
% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/tests.pl:67
% [[bind, summer, [function, [lambda, [n], [setq, running_total, [plus, running_total, n]]]]], '_Ret']=error(type_error(character, bind), context(system:code_type/2, _8340)).
ERROR: /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/tests.pl:67:
        =../2: Type error: `atom' expected, found `[bind,summer,[function,[lambda,[n],[setq,running_total,[plus,running_total,n]]]]]' (a list)


% fact==lambda([n], if(n=0, 1, n*fact(sub1(n)))).
% fact(A, E) :- !,
%       B=[[bv(n, [A|_])]],
%       sym_arg_val_env(n, A, C, B),
%       =(C, 0, D),
%       (   D\=[]
%       ->  E=1
%       ;   sub1(A, F),
%           fact(F, G),
%           *(A, G, H),
%           E=H
%       ).
% fact(_, _) :-
%       fail,
%       ( <<==([fact, n], [if, [=, n, 0], 1, [*, n, [fact, [sub1, n]]]])
%       ).


% add1==lambda([n], n+1).
% add1(A, D) :- !,
%       B=[[bv(n, [A|_])]],
%       sym_arg_val_env(n, A, C, B),
%       plus(C, 1, D).
% add1(_, _) :-
%       fail,
%       ( <<==([add1, n], [+, n, 1])
%       ).


% sub1==lambda([n], n-1).
% sub1(A, D) :- !,
%       B=[[bv(n, [A|_])]],
%       sym_arg_val_env(n, A, C, B),
%       minus(C, 1, D).
% sub1(_, _) :-
%       fail,
%       ( <<==([sub1, n], [-, n, 1])
%       ).


% mapcar==lambda([f, l], if(null(l), nil, cons(f(car(l)), mapcar(f, cdr(l))))).
% mapcar1(A, B, E) :- !,
%       C=[[bv(f, [A|_]), bv(l, [B|_])]],
%       sym_arg_val_env(l, B, D, C),
%       (   D==[]
%       ->  E=[]
%       ;   car(B, F),
%           f(F, I),
%           sym_arg_val_env(f, A, G, C),
%           cdr(B, H),
%           mapcar1(G, H, J),
%           K=[I|J],
%           E=K
%       ).
% mapcar1(_, _, _) :-
%       fail,
%       ( <<==([mapcar1, f, l], [if, [null, l], nil, [cons, [f, [car, l]], [mapcar1, f, [cdr, l]]]])
%       ).


% length==lambda([l], if(null(l), 0, add1(length(cdr(l))))).
% length1(A, D) :- !,
%       B=[[bv(l, [A|_])]],
%       sym_arg_val_env(l, A, C, B),
%       (   C==[]
%       ->  D=0
%       ;   cdr(A, E),
%           length1(E, F),
%           add1(F, G),
%           D=G
%       ).
% length1(_, _) :-
%       fail,
%       ( <<==([length1, l], [if, [null, l], 0, [add1, [length1, [cdr, l]]]])
%       ).


% append==lambda([l1, l2], if(null(l1), l2, cons(car(l1), append(cdr(l1), l2)))).
% append1(A, B, E) :- !,
%       C=[[bv(l1, [A|_]), bv(l2, [B|_])]],
%       sym_arg_val_env(l1, A, D, C),
%       (   D==[]
%       ->  sym_arg_val_env(l2, B, F, C),
%           E=F
%       ;   car(A, H),
%           cdr(A, G),
%           append1(G, B, I),
%           J=[H|I],
%           E=J
%       ).
% append1(_, _, _) :-
%       fail,
%       ( <<==([append1, l1, l2], [if, [null, l1], l2, [cons, [car, l1], [append1, [cdr, l1], l2]]])
%       ).


% filter==lambda([f, s], if('emptyStream?'(s), s, if(f(head(s)), consStream(head(s), filter(f, tail(s))), filter(f, tail(s))))).
% filter1(A, B, F) :- !,
%       C=[[bv(f, [A|_]), bv(s, [B|_])]],
%       sym_arg_val_env(s, B, D, C),
%       'emptyStream?'(D, E),
%       (   E\=[]
%       ->  F=B
%       ;   head(B, G),
%           f(G, H),
%           (   H\=[]
%           ->  head(B, K),
%               sym_arg_val_env(f, A, I, C),
%               tail(B, J),
%               filter1(I, J, L),
%               consStream(K, L, M),
%               O=M
%           ;   tail(B, N),
%               filter1(A, N, P),
%               O=P
%           ),
%           F=O
%       ).
% filter1(_, _, _) :-
%       fail,
%       ( <<==([filter1, f, s], [if, ['emptyStream?', s], s, [if, [f, [head, s]], [consStream, [head, s], [filter1, f, [tail, s]]], [filter1, f, [tail, s]]]])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/lisp_compiler.pl:578
% <<==(from(n), consStream(n, from(n+1))).
% from(N_In4, ConsStream_Ret) :- !,
%       Env=[[bv(n, [N_In4|__])]],
%       sym_arg_val_env(n, N_In4, N_Thru, Env),
%       plus(N_In4, 1, Plus_Ret),
%       from(Plus_Ret, From_Ret),
%       consStream(N_Thru, From_Ret, ConsStream_Ret).
% from(N_In4, ConsStream_Ret) :-
%       fail,
%       ( <<==([from, n], [consStream, n, [from, [+, n, 1]]])
%       ).


% nthStream==lambda([s, n], if(n=1, head(s), nthStream(tail(s), n-1))).
% nthStream(A, B, G) :- !,
%       C=[[bv(s, [A|_]), bv(n, [B|_])]],
%       sym_arg_val_env(n, B, D, C),
%       =(D, 1, E),
%       (   E\=[]
%       ->  sym_arg_val_env(s, A, F, C),
%           head(F, H),
%           G=H
%       ;   tail(A, I),
%           minus(B, 1, J),
%           nthStream(I, J, K),
%           G=K
%       ).
% nthStream(_, _, _) :-
%       fail,
%       ( <<==([nthStream, s, n], [if, [=, n, 1], [head, s], [nthStream, [tail, s], [-, n, 1]]])
%       ).


% integers==from(1).
% ssip_define(integers, from(1)).


% makeCounter==lambda([], begin(counter==0, lambda([], setq(counter, 1+counter)))).
% makeCounter(G) :- !,
%       A=[[]],
%       sym_arg_val_env(counter, _, B, A),
%       ==(B, 0, C),
%       begin(C,
%
%             [ closure,
%               [],
%               [D, F]^(sym_arg_val_env(counter, _, E, D), plus(1, E, F), symbol_setq(counter, F, D)),
%               A
%             ],
%             G).
% makeCounter(_) :-
%       fail,
%       ( <<==(makeCounter, [begin, [==, counter, 0], [lambda, [], [setq, counter, [+, 1, counter]]]])
%       ).


% caaaar==lambda([x], car(car(car(car(x))))).
% caaaar(A, G) :- !,
%       B=[[bv(x, [A|_])]],
%       sym_arg_val_env(x, A, C, B),
%       car(C, D),
%       car(D, E),
%       car(E, F),
%       car(F, G).
% caaaar(_, _) :-
%       fail,
%       ( <<==([caaaar, x], [car, [car, [car, [car, x]]]])
%       ).


% caar==lambda([x], car(car(x))).
% caar(A, E) :- !,
%       B=[[bv(x, [A|_])]],
%       sym_arg_val_env(x, A, C, B),
%       car(C, D),
%       car(D, E).
% caar(_, _) :-
%       fail,
%       ( <<==([caar, x], [car, [car, x]])
%       ).


% reverse==lambda([l], if(null(l), l, append(reverse(cdr(l)), cons(car(l), nil)))).
% reverse1(A, D) :- !,
%       B=[[bv(l, [A|_])]],
%       sym_arg_val_env(l, A, C, B),
%       (   C==[]
%       ->  D=A
%       ;   cdr(A, E),
%           reverse1(E, G),
%           car(A, F),
%           H=[F],
%           append(G, H, I),
%           D=I
%       ).
% reverse1(_, _) :-
%       fail,
%       ( <<==([reverse1, l], [if, [null, l], l, [append, [reverse1, [cdr, l]], [cons, [car, l], nil]]])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/lisp_library.pl:18
% <<==(second(l), first(rest(l))).
% second(L_In, First_Ret) :- !,
%       Env=[[bv(l, [L_In|__])]],
%       sym_arg_val_env(l, L_In, L_Thru, Env),
%       rest(L_Thru, Rest_Ret),
%       first(Rest_Ret, First_Ret).
% second(L_In, First_Ret) :-
%       fail,
%       ( <<==([second, l], [first, [rest, l]])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/lisp_library.pl:21
% <<==(third(l), first(rest(rest(l)))).
% third(L_In, First_Ret) :- !,
%       Env=[[bv(l, [L_In|__])]],
%       sym_arg_val_env(l, L_In, L_Thru, Env),
%       rest(L_Thru, Rest_Ret),
%       rest(Rest_Ret, Rest_Ret5),
%       first(Rest_Ret5, First_Ret).
% third(L_In, First_Ret) :-
%       fail,
%       ( <<==([third, l], [first, [rest, [rest, l]]])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/lisp_library.pl:28
% <<==(list_1(a), cons(a, nil)).
% list_1(A_In, RET) :- !,
%       Env=[[bv(a, [A_In|__])]],
%       sym_arg_val_env(a, A_In, A_Thru, Env),
%       RET=[A_Thru].
% list_1(A_In, RET) :-
%       fail,
%       ( <<==([list_1, a], [cons, a, nil])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/lisp_library.pl:31
% <<==(list_2(a, b), cons(a, list_1(b))).
% list_2(A_In, B_In, RET) :- !,
%       Env=[[bv(a, [A_In|__]), bv(b, [B_In|__7])]],
%       sym_arg_val_env(a, A_In, A_Thru, Env),
%       sym_arg_val_env(b, B_In, B_Thru, Env),
%       list_1(B_Thru, List_1_Ret),
%       RET=[A_Thru|List_1_Ret].
% list_2(A_In, B_In, RET) :-
%       fail,
%       ( <<==([list_2, a, b], [cons, a, [list_1, b]])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/lisp_library.pl:34
% <<==(list_3(a, b, c), cons(a, list_2(b, c))).
% list_3(A_In, B_In, C_In, RET) :- !,
%       Env=[[bv(a, [A_In|__]), bv(b, [B_In|__8]), bv(c, [C_In|__11])]],
%       sym_arg_val_env(a, A_In, A_Thru, Env),
%       sym_arg_val_env(b, B_In, B_Thru, Env),
%       sym_arg_val_env(c, C_In, C_Thru, Env),
%       list_2(B_Thru, C_Thru, List_2_Ret),
%       RET=[A_Thru|List_2_Ret].
% list_3(A_In, B_In, C_In, RET) :-
%       fail,
%       ( <<==([list_3, a, b, c], [cons, a, [list_2, b, c]])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/lisp_library.pl:38
% <<==(lisp_append(l1, l2), if(null(l1), l2, cons(first(l1), lisp_append(rest(l1), l2)))).
% lisp_append(L1_In11, L2_In14, RET) :- !,
%       Env=[[bv(l1, [L1_In11|__]), bv(l2, [L2_In14|__7])]],
%       sym_arg_val_env(l1, L1_In11, L1_Thru, Env),
%       (   L1_Thru==[]
%       ->  sym_arg_val_env(l2, L2_In14, L2_Thru, Env),
%           RET=L2_Thru
%       ;   first(L1_In11, First_Ret),
%           rest(L1_In11, Rest_Ret),
%           lisp_append(Rest_Ret, L2_In14, Lisp_append_Ret),
%           _1660=[First_Ret|Lisp_append_Ret],
%           RET=_1660
%       ).
% lisp_append(L1_In11, L2_In14, RET) :-
%       fail,
%       ( <<==([lisp_append, l1, l2], [if, [null, l1], l2, [cons, [first, l1], [lisp_append, [rest, l1], l2]]])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/lisp_library.pl:46
% <<==(mapcar(func, l), if(null(l), nil, cons(lisp_apply(func, list_1(first(l))), mapcar(func, rest(l))))).
% mapcar(Func_In13, L_In16, RET) :- !,
%       Env=[[bv(func, [Func_In13|__7]), bv(l, [L_In16|__])]],
%       sym_arg_val_env(l, L_In16, L_Thru, Env),
%       (   L_Thru==[]
%       ->  RET=[]
%       ;   sym_arg_val_env(func, Func_In13, Func_Thru, Env),
%           first(L_In16, First_Ret),
%           list_1(First_Ret, List_1_Ret),
%           lisp_apply(Func_Thru, List_1_Ret, Lisp_apply_Ret),
%           rest(L_In16, Rest_Ret),
%           mapcar(Func_In13, Rest_Ret, Mapcar_Ret),
%           _1732=[Lisp_apply_Ret|Mapcar_Ret],
%           RET=_1732
%       ).
% mapcar(Func_In13, L_In16, RET) :-
%       fail,
%       ( <<==([mapcar, func, l], [if, [null, l], nil, [cons, [lisp_apply, func, [list_1, [first, l]]], [mapcar, func, [rest, l]]]])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/streams.pl:19
% <<==(stream_first(stream), first(stream)).
% stream_first(Stream_In, First_Ret) :- !,
%       Env=[[bv(stream, [Stream_In|__])]],
%       sym_arg_val_env(stream, Stream_In, Stream_Thru, Env),
%       first(Stream_Thru, First_Ret).
% stream_first(Stream_In, First_Ret) :-
%       fail,
%       ( <<==([stream_first, stream], [first, stream])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/streams.pl:22
% <<==(stream_rest(stream), lisp_apply(second(stream), [])).
% stream_rest(Stream_In, Lisp_apply_Ret) :- !,
%       Env=[[bv(stream, [Stream_In|__])]],
%       sym_arg_val_env(stream, Stream_In, Stream_Thru, Env),
%       second(Stream_Thru, Second_Ret),
%       lisp_apply(Second_Ret, [], Lisp_apply_Ret).
% stream_rest(Stream_In, Lisp_apply_Ret) :-
%       fail,
%       ( <<==([stream_rest, stream], [lisp_apply, [second, stream], []])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/streams.pl:25
% <<==(stream_cons(a, b), list_2(a, b)).
% stream_cons(A_In, B_In, List_2_Ret) :- !,
%       Env=[[bv(a, [A_In|__]), bv(b, [B_In|__7])]],
%       sym_arg_val_env(a, A_In, A_Thru, Env),
%       sym_arg_val_env(b, B_In, B_Thru, Env),
%       list_2(A_Thru, B_Thru, List_2_Ret).
% stream_cons(A_In, B_In, List_2_Ret) :-
%       fail,
%       ( <<==([stream_cons, a, b], [list_2, a, b])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/streams.pl:28
% <<==(stream_null(stream), null(stream)).
% stream_null(Stream_In, Null_Ret) :- !,
%       Env=[[bv(stream, [Stream_In|__])]],
%       sym_arg_val_env(stream, Stream_In, Stream_Thru, Env),
%       null(Stream_Thru, Null_Ret).
% stream_null(Stream_In, Null_Ret) :-
%       fail,
%       ( <<==([stream_null, stream], [null, stream])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/streams.pl:33
% <<==(stream_take(n, stream), if(or(equalp(n, 0), stream_null(stream)), [], cons(stream_first(stream), stream_take(minus(n, 1), stream_rest(stream))))).
% stream_take(N_In15, Stream_In18, RET) :- !,
%       Env=[[bv(n, [N_In15|__]), bv(stream, [Stream_In18|__8])]],
%       sym_arg_val_env(n, N_In15, N_Thru, Env),
%       equalp(N_Thru, 0, Equalp_Ret),
%       sym_arg_val_env(stream, Stream_In18, Stream_Thru, Env),
%       stream_null(Stream_Thru, Stream_null_Ret),
%       or(Equalp_Ret, Stream_null_Ret, Or_Ret),
%       (   Or_Ret\=[]
%       ->  RET=[]
%       ;   stream_first(Stream_In18, Stream_first_Ret),
%           minus(N_In15, 1, Minus_Ret),
%           stream_rest(Stream_In18, Stream_rest_Ret),
%           stream_take(Minus_Ret, Stream_rest_Ret, Stream_take_Ret),
%           _1842=[Stream_first_Ret|Stream_take_Ret],
%           RET=_1842
%       ).
% stream_take(N_In15, Stream_In18, RET) :-
%       fail,
%       ( <<==([stream_take, n, stream], [if, [or, [equalp, n, 0], [stream_null, stream]], [], [cons, [stream_first, stream], [stream_take, [minus, n, 1], [stream_rest, stream]]]])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/streams.pl:40
% <<==(stream_drop(n, stream), if(or(equalp(n, 0), stream_null(stream)), stream, stream_drop(minus(n, 1), stream_rest(stream)))).
% stream_drop(N_In14, Stream_In17, RET) :- !,
%       Env=[[bv(n, [N_In14|__]), bv(stream, [Stream_In17|__8])]],
%       sym_arg_val_env(n, N_In14, N_Thru, Env),
%       equalp(N_Thru, 0, Equalp_Ret),
%       sym_arg_val_env(stream, Stream_In17, Stream_Thru, Env),
%       stream_null(Stream_Thru, Stream_null_Ret),
%       or(Equalp_Ret, Stream_null_Ret, Or_Ret),
%       (   Or_Ret\=[]
%       ->  RET=Stream_In17
%       ;   minus(N_In14, 1, Minus_Ret),
%           stream_rest(Stream_In17, Stream_rest_Ret),
%           stream_drop(Minus_Ret, Stream_rest_Ret, Stream_drop_Ret),
%           RET=Stream_drop_Ret
%       ).
% stream_drop(N_In14, Stream_In17, RET) :-
%       fail,
%       ( <<==([stream_drop, n, stream], [if, [or, [equalp, n, 0], [stream_null, stream]], stream, [stream_drop, [minus, n, 1], [stream_rest, stream]]])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/streams.pl:47
% <<==(stream_interval(low, high), if(equalp(low, high), [], stream_cons(low, function(lambda([], stream_interval(plus(low, 1), high)))))).
% stream_interval(Low_In11, High_In14, RET) :- !,
%       Env=[[bv(low, [Low_In11|__]), bv(high, [High_In14|__7])]],
%       sym_arg_val_env(low, Low_In11, Low_Thru, Env),
%       sym_arg_val_env(high, High_In14, High_Thru, Env),
%       equalp(Low_Thru, High_Thru, Equalp_Ret),
%       (   Equalp_Ret\=[]
%       ->  RET=[]
%       ;   stream_cons(Low_In11,
%
%                       [ closure,
%                         [],
%                         [LEnv, Stream_interval_Ret]^(plus(Low_In11, 1, Plus_Ret), stream_interval(Plus_Ret, High_In14, Stream_interval_Ret)),
%                         Env
%                       ],
%                       Stream_cons_Ret),
%           RET=Stream_cons_Ret
%       ).
% stream_interval(Low_In11, High_In14, RET) :-
%       fail,
%       ( <<==([stream_interval, low, high], [if, [equalp, low, high], [], [stream_cons, low, [function, [lambda, [], [stream_interval, [plus, low, 1], high]]]]])
%       ).
Warning: /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/streams.pl:47:
        Singleton variable in branch: LEnv


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/streams.pl:54
% <<==(stream_ints_from(n), stream_cons(n, function(lambda([], stream_ints_from(plus(n, 1)))))).
% stream_ints_from(N_In4, Stream_cons_Ret) :- !,
%       Env=[[bv(n, [N_In4|__])]],
%       sym_arg_val_env(n, N_In4, N_Thru, Env),
%       stream_cons(N_Thru,
%
%                   [ closure,
%                     [],
%                     [LEnv, Stream_ints_from_Ret]^(plus(N_In4, 1, Plus_Ret), stream_ints_from(Plus_Ret, Stream_ints_from_Ret)),
%                     Env
%                   ],
%                   Stream_cons_Ret).
% stream_ints_from(N_In4, Stream_cons_Ret) :-
%       fail,
%       ( <<==([stream_ints_from, n], [stream_cons, n, [function, [lambda, [], [stream_ints_from, [plus, n, 1]]]]])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/streams.pl:59
% <<==(t1, stream_take(3, stream_interval(1, 5))).
% t1(Stream_take_Ret) :- !,
%       Env=[[]],
%       stream_interval(1, 5, Stream_interval_Ret),
%       stream_take(3, Stream_interval_Ret, Stream_take_Ret).
% t1(Stream_take_Ret) :-
%       fail,
%       ( <<==(t1, [stream_take, 3, [stream_interval, 1, 5]])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/streams.pl:62
% <<==(t2, stream_take(5, stream_drop(10, stream_ints_from(1)))).
% t2(Stream_take_Ret) :- !,
%       Env=[[]],
%       stream_ints_from(1, Stream_ints_from_Ret),
%       stream_drop(10, Stream_ints_from_Ret, Stream_drop_Ret),
%       stream_take(5, Stream_drop_Ret, Stream_take_Ret).
% t2(Stream_take_Ret) :-
%       fail,
%       ( <<==(t2, [stream_take, 5, [stream_drop, 10, [stream_ints_from, 1]]])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/tests.pl:17
% <<==(simple(x), x).
% simple(X_In, X_Thru) :- !,
%       Env=[[bv(x, [X_In|__])]],
%       sym_arg_val_env(x, X_In, X_Thru, Env).
% simple(X_In, X_Thru) :-
%       fail,
%       ( <<==([simple, x], x)
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/tests.pl:20
% <<==(lisp_append_2(l1, l2), cond([[null(l1), l2], [t, cons(first(l1), lisp_append_2(rest(l1), l2))]])).
% lisp_append_2(L1_In12, L2_In15, RET) :- !,
%       Env=[[bv(l1, [L1_In12|__]), bv(l2, [L2_In15|__8])]],
%       sym_arg_val_env(l1, L1_In12, L1_Thru, Env),
%       null(L1_Thru, Null_Ret),
%       (   Null_Ret\=[]
%       ->  sym_arg_val_env(l2, L2_In15, L2_Thru, Env),
%           RET=L2_Thru
%       ;   (   t\=[]
%           ->  first(L1_In12, First_Ret),
%               rest(L1_In12, Rest_Ret),
%               lisp_append_2(Rest_Ret, L2_In15, Lisp_append_2_Ret),
%               _1764=[First_Ret|Lisp_append_2_Ret],
%               _1762=_1764
%           ;   _1762=[]
%           ),
%           RET=_1762
%       ).
% lisp_append_2(L1_In12, L2_In15, RET) :-
%       fail,
%       ( <<==([lisp_append_2, l1, l2], [cond, [[[null, l1], l2], [t, [cons, [first, l1], [lisp_append_2, [rest, l1], l2]]]]])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/tests.pl:27
% <<==(lisp_error(x), setq(y, 5)).
% lisp_error(X, 5) :- !,
%       Env=[[bv(x, [X|_6414])]],
%       symbol_setq(y, 5, Env).
% lisp_error(X, 5) :-
%       fail,
%       ( <<==([lisp_error, x], [setq, y, 5])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/tests.pl:30
% <<==(lisp_let(), let([bind(x, 3), bind(y, 5)], progn(x, y))).
% lisp_let(Y_Thru) :- !,
%       Env=[[]],
%       LETENV=[[bv(x, [3|_1384]), bv(y, [5|_1386])]|Env],
%       sym_arg_val_env(progn, Progn_In, Progn_Thru, LETENV),
%       sym_arg_val_env(x, X_In, X_Thru, LETENV),
%       sym_arg_val_env(y, Y_In, Y_Thru, LETENV).
% lisp_let(Y_Thru) :-
%       fail,
%       ( <<==([lisp_let], [let, [[bind, x, 3], [bind, y, 5]], [progn, x, y]])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/tests.pl:34
% <<==(lisp_let1(), let([bind(x, 3), bind(y, 5)], x, y)).
% lisp_let1(Y_Thru) :- !,
%       Env=[[]],
%       LETENV=[[bv(x, [3|_1336]), bv(y, [5|_1338])]|Env],
%       sym_arg_val_env(progn, Progn_In, Progn_Thru, LETENV),
%       sym_arg_val_env(x, X_In, X_Thru, LETENV),
%       sym_arg_val_env(y, Y_In, Y_Thru, LETENV).
% lisp_let1(Y_Thru) :-
%       fail,
%       ( <<==([lisp_let1], [let, [[bind, x, 3], [bind, y, 5]], x, y])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/tests.pl:41
% <<==(mapfirst(l), mapcar(function(first), l)).
% mapfirst(L_In, Mapcar_Ret) :- !,
%       Env=[[bv(l, [L_In|__])]],
%       sym_arg_val_env(l, L_In, L_Thru, Env),
%       mapcar([function, first], L_Thru, Mapcar_Ret).
% mapfirst(L_In, Mapcar_Ret) :-
%       fail,
%       ( <<==([mapfirst, l], [mapcar, [function, first], l])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/tests.pl:45
% <<==(defvar(fred, 13)).
% :- (   special_var(fred, _17606)
%    ->  true
%    ;   assert(special_var(fred, 13))
%    ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/tests.pl:47
% <<==(defvar(george)).
% :- (   special_var(george, _1058)
%    ->  true
%    ;   assert(special_var(george, []))
%    ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/tests.pl:50
% <<==(reset_george(val), setq(george, val)).
% reset_george(Val_In, Val_Thru) :- !,
%       Env=[[bv(val, [Val_In|__])]],
%       sym_arg_val_env(val, Val_In, Val_Thru, Env),
%       symbol_setq(george, Val_Thru, Env).
% reset_george(Val_In, Val_Thru) :-
%       fail,
%       ( <<==([reset_george, val], [setq, george, val])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/tests.pl:54
% <<==(make_adder(x), function(lambda([y], plus(x, y)))).
% make_adder(X_In, [closure, [y], [LEnv, Plus_Ret]^(((sym_arg_val_env(x, X_In, avar(X_Thru, att(initState, t, [])), LEnv), sym_arg_val_env(y, avar(Y_In, att(initState, t, [])), avar(Y_Thru, att(initState, t, [])), LEnv), true), plus(avar(X_Thru, att(initState, t, [])), avar(Y_Thru, att(initState, t, [])), Plus_Ret)), true), Env]) :- !,
%       Env=[[bv(x, [X_In|__])]].
% make_adder(X_In, [closure, [y], [LEnv, Plus_Ret]^(((sym_arg_val_env(x, X_In, avar(X_Thru, att(initState, t, [])), LEnv), sym_arg_val_env(y, avar(Y_In, att(initState, t, [])), avar(Y_Thru, att(initState, t, [])), LEnv), true), plus(avar(X_Thru, att(initState, t, [])), avar(Y_Thru, att(initState, t, [])), Plus_Ret)), true), Env]) :-
%       fail,
%       ( <<==([make_adder, x], [function, [lambda, [y], [plus, x, y]]])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/tests.pl:58
% <<==(scale_list(xs, scale), let([bind(fred, function(lambda([num], times(scale, num))))], mapcar(fred, xs))).
% scale_list(Xs_In, Scale_In, Xs_Thru) :- !,
%       Env=[[bv(xs, [Xs_In|__19]), bv(scale, [Scale_In|__])]],
%       LETENV=[[bv(fred, [[closure, [num], [LEnv, Times_Ret]^(sym_arg_val_env(scale, Scale_In, Scale_Thru, LEnv), sym_arg_val_env(num, Num_In, Num_Thru, LEnv), times(Scale_Thru, Num_Thru, Times_Ret)), Env]|_1786])]|Env],
%       sym_arg_val_env(mapcar, Mapcar_In, Mapcar_Thru, LETENV),
%       sym_arg_val_env(fred, Fred_In, Fred_Thru, LETENV),
%       sym_arg_val_env(xs, Xs_In, Xs_Thru, LETENV).
% scale_list(Xs_In, Scale_In, Xs_Thru) :-
%       fail,
%       ( <<==([scale_list, xs, scale], [let, [[bind, fred, [function, [lambda, [num], [times, scale, num]]]]], [mapcar, fred, xs]])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/tests.pl:62
% <<==(make_summer(total), function(lambda([n], setq(total, plus(total, n))))).
% make_summer(Total_In, [closure, [n], [LEnv, Plus_Ret]^((((sym_arg_val_env(total, Total_In, avar(Total_Thru, att(initState, t, [])), LEnv), sym_arg_val_env(n, avar(N_In, att(initState, t, [])), avar(N_Thru, att(initState, t, [])), LEnv), true), plus(avar(Total_Thru, att(initState, t, [])), avar(N_Thru, att(initState, t, [])), Plus_Ret)), symbol_setq(total, Plus_Ret, LEnv)), true), Env]) :- !,
%       Env=[[bv(total, [Total_In|__])]].
% make_summer(Total_In, [closure, [n], [LEnv, Plus_Ret]^((((sym_arg_val_env(total, Total_In, avar(Total_Thru, att(initState, t, [])), LEnv), sym_arg_val_env(n, avar(N_In, att(initState, t, [])), avar(N_Thru, att(initState, t, [])), LEnv), true), plus(avar(Total_Thru, att(initState, t, [])), avar(N_Thru, att(initState, t, [])), Plus_Ret)), symbol_setq(total, Plus_Ret, LEnv)), true), Env]) :-
%       fail,
%       ( <<==([make_summer, total], [function, [lambda, [n], [setq, total, [plus, total, n]]]])
%       ).
% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/tests.pl:67
% [[bind, summer, [function, [lambda, [n], [setq, running_total, [plus, running_total, n]]]]], '_Ret']=error(type_error(character, bind), context(system:code_type/2, _19698)).
ERROR: /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/tests.pl:67:
        =../2: Type error: `atom' expected, found `[bind,summer,[function,[lambda,[n],[setq,running_total,[plus,running_total,n]]]]]' (a list)


% fact==lambda([n], if(n=0, 1, n*fact(sub1(n)))).
% fact(A, E) :- !,
%       B=[[bv(n, [A|_])]],
%       sym_arg_val_env(n, A, C, B),
%       =(C, 0, D),
%       (   D\=[]
%       ->  E=1
%       ;   sub1(A, F),
%           fact(F, G),
%           *(A, G, H),
%           E=H
%       ).
% fact(_, _) :-
%       fail,
%       ( <<==([fact, n], [if, [=, n, 0], 1, [*, n, [fact, [sub1, n]]]])
%       ).


% add1==lambda([n], n+1).
% add1(A, D) :- !,
%       B=[[bv(n, [A|_])]],
%       sym_arg_val_env(n, A, C, B),
%       plus(C, 1, D).
% add1(_, _) :-
%       fail,
%       ( <<==([add1, n], [+, n, 1])
%       ).


% sub1==lambda([n], n-1).
% sub1(A, D) :- !,
%       B=[[bv(n, [A|_])]],
%       sym_arg_val_env(n, A, C, B),
%       minus(C, 1, D).
% sub1(_, _) :-
%       fail,
%       ( <<==([sub1, n], [-, n, 1])
%       ).


% mapcar==lambda([f, l], if(null(l), nil, cons(f(car(l)), mapcar(f, cdr(l))))).
% mapcar2(A, B, E) :- !,
%       C=[[bv(f, [A|_]), bv(l, [B|_])]],
%       sym_arg_val_env(l, B, D, C),
%       (   D==[]
%       ->  E=[]
%       ;   car(B, F),
%           f(F, I),
%           sym_arg_val_env(f, A, G, C),
%           cdr(B, H),
%           mapcar2(G, H, J),
%           K=[I|J],
%           E=K
%       ).
% mapcar2(_, _, _) :-
%       fail,
%       ( <<==([mapcar2, f, l], [if, [null, l], nil, [cons, [f, [car, l]], [mapcar2, f, [cdr, l]]]])
%       ).


% length==lambda([l], if(null(l), 0, add1(length(cdr(l))))).
% length2(A, D) :- !,
%       B=[[bv(l, [A|_])]],
%       sym_arg_val_env(l, A, C, B),
%       (   C==[]
%       ->  D=0
%       ;   cdr(A, E),
%           length2(E, F),
%           add1(F, G),
%           D=G
%       ).
% length2(_, _) :-
%       fail,
%       ( <<==([length2, l], [if, [null, l], 0, [add1, [length2, [cdr, l]]]])
%       ).


% append==lambda([l1, l2], if(null(l1), l2, cons(car(l1), append(cdr(l1), l2)))).
% append2(A, B, E) :- !,
%       C=[[bv(l1, [A|_]), bv(l2, [B|_])]],
%       sym_arg_val_env(l1, A, D, C),
%       (   D==[]
%       ->  sym_arg_val_env(l2, B, F, C),
%           E=F
%       ;   car(A, H),
%           cdr(A, G),
%           append2(G, B, I),
%           J=[H|I],
%           E=J
%       ).
% append2(_, _, _) :-
%       fail,
%       ( <<==([append2, l1, l2], [if, [null, l1], l2, [cons, [car, l1], [append2, [cdr, l1], l2]]])
%       ).


% filter==lambda([f, s], if('emptyStream?'(s), s, if(f(head(s)), consStream(head(s), filter(f, tail(s))), filter(f, tail(s))))).
% filter2(A, B, F) :- !,
%       C=[[bv(f, [A|_]), bv(s, [B|_])]],
%       sym_arg_val_env(s, B, D, C),
%       'emptyStream?'(D, E),
%       (   E\=[]
%       ->  F=B
%       ;   head(B, G),
%           f(G, H),
%           (   H\=[]
%           ->  head(B, K),
%               sym_arg_val_env(f, A, I, C),
%               tail(B, J),
%               filter2(I, J, L),
%               consStream(K, L, M),
%               O=M
%           ;   tail(B, N),
%               filter2(A, N, P),
%               O=P
%           ),
%           F=O
%       ).
% filter2(_, _, _) :-
%       fail,
%       ( <<==([filter2, f, s], [if, ['emptyStream?', s], s, [if, [f, [head, s]], [consStream, [head, s], [filter2, f, [tail, s]]], [filter2, f, [tail, s]]]])
%       ).


% /home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl/lisp_compiler.pl:578
% <<==(from(n), consStream(n, from(n+1))).
% from(N_In4, ConsStream_Ret) :- !,
%       Env=[[bv(n, [N_In4|__])]],
%       sym_arg_val_env(n, N_In4, N_Thru, Env),
%       plus(N_In4, 1, Plus_Ret),
%       from(Plus_Ret, From_Ret),
%       consStream(N_Thru, From_Ret, ConsStream_Ret).
% from(N_In4, ConsStream_Ret) :-
%       fail,
%       ( <<==([from, n], [consStream, n, [from, [+, n, 1]]])
%       ).


% nthStream==lambda([s, n], if(n=1, head(s), nthStream(tail(s), n-1))).
% nthStream(A, B, G) :- !,
%       C=[[bv(s, [A|_]), bv(n, [B|_])]],
%       sym_arg_val_env(n, B, D, C),
%       =(D, 1, E),
%       (   E\=[]
%       ->  sym_arg_val_env(s, A, F, C),
%           head(F, H),
%           G=H
%       ;   tail(A, I),
%           minus(B, 1, J),
%           nthStream(I, J, K),
%           G=K
%       ).
% nthStream(_, _, _) :-
%       fail,
%       ( <<==([nthStream, s, n], [if, [=, n, 1], [head, s], [nthStream, [tail, s], [-, n, 1]]])
%       ).


% integers==from(1).
% ssip_define(integers, from(1)).


% makeCounter==lambda([], begin(counter==0, lambda([], setq(counter, 1+counter)))).
% makeCounter(G) :- !,
%       A=[[]],
%       sym_arg_val_env(counter, _, B, A),
%       ==(B, 0, C),
%       begin(C,
%
%             [ closure,
%               [],
%               [D, F]^(sym_arg_val_env(counter, _, E, D), plus(1, E, F), symbol_setq(counter, F, D)),
%               A
%             ],
%             G).
% makeCounter(_) :-
%       fail,
%       ( <<==(makeCounter, [begin, [==, counter, 0], [lambda, [], [setq, counter, [+, 1, counter]]]])
%       ).


% caaaar==lambda([x], car(car(car(car(x))))).
% caaaar(A, G) :- !,
%       B=[[bv(x, [A|_])]],
%       sym_arg_val_env(x, A, C, B),
%       car(C, D),
%       car(D, E),
%       car(E, F),
%       car(F, G).
% caaaar(_, _) :-
%       fail,
%       ( <<==([caaaar, x], [car, [car, [car, [car, x]]]])
%       ).


% caar==lambda([x], car(car(x))).
% caar(A, E) :- !,
%       B=[[bv(x, [A|_])]],
%       sym_arg_val_env(x, A, C, B),
%       car(C, D),
%       car(D, E).
% caar(_, _) :-
%       fail,
%       ( <<==([caar, x], [car, [car, x]])
%       ).


% reverse==lambda([l], if(null(l), l, append(reverse(cdr(l)), cons(car(l), nil)))).
% reverse2(A, D) :- !,
%       B=[[bv(l, [A|_])]],
%       sym_arg_val_env(l, A, C, B),
%       (   C==[]
%       ->  D=A
%       ;   cdr(A, E),
%           reverse2(E, G),
%           car(A, F),
%           H=[F],
%           append(G, H, I),
%           D=I
%       ).
% reverse2(_, _) :-
%       fail,
%       ( <<==([reverse2, l], [if, [null, l], l, [append, [reverse2, [cdr, l]], [cons, [car, l], nil]]])
%       ).
Welcome to SWI-Prolog (threaded, 64 bits, version 7.3.13-2174-gd865daf-DIRTY)
SWI-Prolog comes with ABSOLUTELY NO WARRANTY. This is free software.
Please run ?- license. for legal details.

For online help and background, visit http://www.swi-prolog.org
For built-in help, use ?- help(Topic). or ?- apropos(Word).

?- ^D
% halt
root@gitlab:/home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl# vi ISSUES
root@gitlab:/home/dmiles/logicmoo_workspace/packs_usr/wam_common_lisp/prolog/wam_cl#

````

