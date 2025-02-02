/** <module> LPS Compatibility module

This  module  provides  compatibility  to   LPS  through  the  directive
expects_dialect/1:

	==
	:- expects_dialect(lps)
	==

@tbd this module meeds

	* Implement system predicates available in LPS we do not yet or
	do not wish to support in SWI-Prolog.  Export these predicates.

	* Provide lps_<name>(...) predicates for predicates that exist
	both in LPS and SWI-Prolog and define goal_expansion/2 rules to
	map calls to these predicates to the lps_<name> version.
	Export these predicates.

	* Alter the library search path, placing dialect/lps *before*
	the system libraries.

	* Allow for =|.lps|= extension as extension for Prolog files.
	If both a =|.pl|= and =|.lps|= is present, the =|.lps|= file
	is loaded if the current environment expects LPS.

@tbd	The dialect-compatibility packages are developed in a
	`demand-driven' fashion.  Please contribute to this package. Fill it in!
@author Douglas R. Miles
*/

:- module(lps, [pop_lps_dialect/0,push_lps_dialect/0,dialect_input_stream/1,load_lps/0,calc_load_module_lps/1]).
% :- asserta(swish:is_a_module).


		 /*******************************
		 *	     EXPANSION		*
		 *******************************/

:- multifile
	user:goal_expansion/2,
	user:file_search_path/2,
	user:prolog_file_type/2,
	lps_dialect_expansion/2.
	
:- dynamic
	user:goal_expansion/2,
	user:file_search_path/2,
	user:prolog_file_type/2.

% :- notrace(system:ensure_loaded(library(operators))).
swish:fakeout_swish.
:- notrace(lps_repl:ensure_loaded(library(lps_corner))).
%:- notrace(logicmoo_planner:ensure_loaded(library(logicmoo_planner))).
:- notrace(ec:ensure_loaded(library(ec_planner/ec_planner_dmiles))).


lps_debug(Info):- ignore(notrace((debug(lps(dialect),'~N% ~p.',[Info])))).
% lps_debug(X):- format(user_error,'~N% LPS_DEBUG: ~q.~n',[X]),flush_output(user_error).

%%	lps_dialect_expansion(+In, +Out)
%
%	goal_expansion rules to emulate LPS behaviour in SWI-Prolog. The
%	expansions  below  maintain  optimization    from   compilation.
%	Defining them as predicates would loose compilation.

lps_dialect_expansion(expects_dialect(Dialect), Out):- 
   % in case it is used more than once
   swi \== Dialect -> 
       Out = debug(lps(term_expansion),'~q.',[(expects_dialect(Dialect))])
     ; Out=pop_lps_dialect.
/*
lps_dialect_expansion(eval_arith(Expr, Result),
	      Result is Expr).

lps_dialect_expansion(if(Goal, Then),
	      (Goal *-> Then; true)).
lps_dialect_expansion(if(Goal, Then, Else),
	      (Goal *-> Then; Else)).
lps_dialect_expansion(style_check(Style),
	      lps_style_check(Style)).

*/

		 /*******************************
		 *	    LIBRARY SETUP	*
		 *******************************/

%	Pushes searching for  dialect/lps  in   front  of  every library
%	directory that contains such as sub-directory.

:-      
   exists_source(library(dialect/lps)) -> true;
   (prolog_load_context(directory, ThisDir),
   absolute_file_name('..', Dir,
          [ file_type(directory),
            access(read),
            relative_to(ThisDir),
            file_errors(fail)
          ]),
   asserta((user:file_search_path(library, Dir)))).
/*
:- prolog_load_context(directory, ThisDir),
   absolute_file_name('lps_autoload', Dir,
			       [ file_type(directory),
				 access(read),
                                 relative_to(ThisDir),
				 file_errors(fail)
			       ]),
      asserta((user:file_search_path(library, Dir) :-
	prolog_load_context(dialect, lps))).
*/
:- user:file_search_path(lps_library, Dir) -> true;
    (prolog_load_context(directory, ThisDir),
         absolute_file_name('../..', Dir,
			       [ file_type(directory),
				 access(read),
                                 relative_to(ThisDir),
				 file_errors(fail)
			       ]),
	    asserta((user:file_search_path(lps_library, Dir)))).



%%	push_lps_file_extension
%
%	Looks for .lps files before looking for .pl files if the current
%	dialect is =lps=.

push_lps_file_extension :-
	asserta((user:prolog_file_type(lps, prolog) :-
		    prolog_load_context(dialect, lps))).


:- push_lps_file_extension.


:- multifile
	prolog:message//1.

prolog:message(lps_unsupported(Goal)) -->
	[ 'LPS emulation (lps.pl): unsupported: ~p'-[Goal] ].


:- use_module(library(pengines),[pengine_self/1]). 

calc_load_module_lps(OM):- pengine_self(OM),!.
calc_load_module_lps(OM):- 
     '$current_typein_module'(TM), 
     prolog_load_context(module,Load),strip_module(_,Strip,_),
     context_module(Ctx),'$current_source_module'(SM),
     ((SM==Load,SM\==user)-> Module = SM ;
     ((TM\==Load,TM\==user) -> Module = TM ; (Module = SM))),
     OM=Load,
     lps_debug([ti=TM,load=Load,strip=Strip,ctx=Ctx,sm=SM,lps=Module,using=OM]),!.     

calc_load_module_lps(Module):- 
    (member(Call,[
     prolog_load_context(module,Module),
     pengine_self(Module),
     '$current_source_module'(Module),
     '$current_typein_module'(Module),
     interpreter:lps_program_module(Module),
     strip_module(_,Module,_),
     context_module(Module),
     source_location(Module,_)]),
    call(Call),
    lps_debug(calc_load_module_lps(Call)),
    \+ likely_reserved_module(Module)); interpreter:must_lps_program_module(Module).

get_lps_program_module(Module):- 
  load_lps,
  interpreter:lps_program_module(Module).

set_lps_program_module(Module):- interpreter:must_lps_program_module(Module).

likely_reserved_module(Module):- Module=user; 
  module_property(Module,P), member(P,[class(library),class(system),exported_operators([_|_]),exports([_|_])]).
  



    :- volatile(tmp:module_dialect_lps/4).
:- thread_local(tmp:module_dialect_lps/4).


:- lps:export(lps:push_lps_dialect/0). 
:- system:import(lps:push_lps_dialect/0). 

:- system:module_transparent(lps:setup_dialect/0). 
:- system:module_transparent(lps:pop_lps_dialect/0).
:- system:module_transparent(lps:push_lps_dialect/0).
%:- system:module_transparent(lps:lps_expects_dialect/2).

lps:setup_dialect:- 
    lps_debug(push_lps_dialect),lps_debug(ops),
    (push_lps_dialect->true;(trace,push_lps_dialect)),
    lps_debug(continue_lps_dialect),lps_debug(ops).

:- system:module_transparent(prolog_dialect:expects_dialect/1). 
%:- prolog_dialect:import(lps:push_lps_dialect/0). 



% :- prolog_dialect:asserta((())).
% :- thread_local(interpreter:lps_program_module/1).


get_lps_alt_user_module(_User,LPS_USER):- interpreter:lps_program_module(LPS_USER),!.
get_lps_alt_user_module( user, db):-!.
get_lps_alt_user_module( User,LPS_USER):- is_lps_alt_user_module(User,LPS_USER),!.
%get_lps_alt_user_module(_User,LPS_USER):- interpreter:lps_program_module(LPS_USER),!.

% is_lps_alt_user_module(user,db):-!.
is_lps_alt_user_module(_User,Out):- gensym(lps, Out).

% is_lps_alt_user_module(db).


lps_operators(Module,[
  op(900,fy,(Module:not)), 
  op(1200,xfx,(Module:then)),
  op(1185,fx,(Module:if)),
  op(1190,xfx,(Module:if)),
  op(1100,xfy,(Module:else)), 
  op(1050,xfx,(Module:terminates)),
  op(1050,xfx,(Module:initiates)),
  op(1050,xfx,(Module:updates)),
  % Rejected    (      op(1050,fx,impossible), 
  op(1050,fx,(Module:observe)),
  op(1050,fx,(Module:false)),
  op(1050,fx,(Module:initially)),
  op(1050,fx,(Module:fluents)),
  op(1050,fx,(Module:events)),
  op(1050,fx,(Module:prolog_events)),
  op(1050,fx,(Module:actions)),
  op(1050,fx,(Module:unserializable)),
  % notice ',' has priority 1000
  op(999,fx,(Module:update)),
  op(999,fx,(Module:initiate)),
  op(999,fx,(Module:terminate)),
  op(997,xfx,(Module:in)),
  op(995,xfx,(Module:at)),
  op(995,xfx,(Module:during)),
  op(995,xfx,(Module:from)), 
  op(994,xfx,(Module:to)), % from's priority higher
  op(1050,xfy,(Module:(::))),
  
  % lps.js syntax extras
  op(1200,xfx,(Module:(<-))),
  op(1050,fx,(Module:(<-))),
  % -> is already defined as 1050, xfy, which will do given that lps.js does not support if-then-elses
  op(700,xfx,((Module:(<=))))
]).

load_lps:-    
   notrace(interpreter:ensure_loaded(library('../engine/interpreter.P'))),
   notrace(lps_term_expander:ensure_loaded(library('../swish/term_expander.pl'))),
   notrace(lps_repl:ensure_loaded(library(lps_corner))).

add_lps_to_module(Module):-
   load_lps,
   %notrace(system:ensure_loaded(library(broadcast))),
   interpreter:check_lps_program_module(Module),
   Module:style_check(-discontiguous), Module:style_check(-singleton),
   db:define_lps_into_module(Module),
   !.

push_lps_dialect:-
   load_lps,
   calc_load_module_lps(Module),
   lps_expects_dialect(Module, Module).   
  
lps_expects_dialect(User, User):-  
  User==user,  
  get_lps_alt_user_module(User,LPS_USER),
  LPS_USER\==user,
  lps_debug(alt_module(User,LPS_USER)),
  '$set_source_module'(LPS_USER),!,
  lps_expects_dialect(User, LPS_USER).


lps_expects_dialect(Was, Module):-
   add_lps_to_module(Module),
   dialect_input_stream(Source),   
   lps_operators(Module, Ops),
   push_operators(Module:Ops, Undo),
   %ignore(retract(tmp:module_dialect_lps(Source,_,_,_))), 
   asserta(tmp:module_dialect_lps(Source,Was,Module,Undo)),!.

dialect_input_stream(Source):- prolog_load_context(source,Source)->true;current_input(Source).
% dialect_input_stream(Source):- prolog_load_context(stream,Source)->true;current_input(Source).

pop_lps_dialect:-
    dialect_input_stream(Source),
    retract(tmp:module_dialect_lps(Source,Was,Module,Undo)),!,
    pop_operators(Undo),
    lps_debug(pop_lps_dialect(Source,Module->Was)),
    %nop('$set_source_module'(Was)),!,
    lps_debug(ops).
pop_lps_dialect:-
    retract(tmp:module_dialect_lps(Source,Was,Module,Undo)),!,
    print_message(warning, format('~q', [warn_pop_lps_dialect_fallback(Source,Module->Was)])),
    %dumpST,
    %lps_debug(ops),
    pop_operators(Undo),    
    %nop('$set_source_module'(Was)),!,
    lps_debug(ops).
pop_lps_dialect:- 
   lps_debug(ops),
   print_message(warning, format('~q', [missing_pop_lps_dialect_fallback])).



                 /*******************************
                 *         SYNTAX HOOKS         *
                 *******************************/

:- multifile
    prolog:alternate_syntax/4.


prolog:alternate_syntax(lps, Module,
                        lps:push_lps_operators(Module),
                        lps:pop_lps_operators).


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Note that we could generalise this to deal with all included files.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

push_lps_operators :-
    '$set_source_module'(Module, Module),
    push_lps_operators(Module).

push_lps_operators(Module) :-
    lps_operators(Module, Ops),
    push_operators(Module:Ops).

pop_lps_operators :-
    pop_operators.


user:goal_expansion(In, Out) :-
    prolog_load_context(dialect, lps),
    lps_dialect_expansion(In, Out).



system:term_expansion(In, PosIn, Out, PosOut) :- 
  prolog_load_context(dialect, lps),
  In == (:- include(system('date_utils.pl'))), 
  PosIn=PosOut, 
  expects_dialect(swi),
  Out = [(:- expects_dialect(swi)),
         (:- include(system('date_utils.pl'))),
         (:- expects_dialect(lps))],!.

system:term_expansion(In, PosIn, Out, PosOut) :- In == end_of_file,
   prolog_load_context(dialect, lps),
   dialect_input_stream(Source),
   tmp:module_dialect_lps(Source,_,_,_),
   pop_lps_dialect,!,
   Out = In,
   PosIn = PosOut.
      
      

