:- public show_decomposition/1.
:- external trace_reduction/1.

%%
%% Goal reduction
%%



%=autodoc
%% task_reduction( ?Task, ?Reduction) is semidet.
%
% Task Reduction.
%
task_reduction(Task, Reduction) :-
   begin(canonical_form_of_task(Task, Canonical),
	 reduce_canonical_form(Canonical, Reduction)).


%=autodoc
%% reduce_canonical_form( ?ARG1, ?Task) is semidet.
%
% Reduce Canonical Form.
%
reduce_canonical_form(Task, Task) :-
   primitive_task(Task),
   !.
reduce_canonical_form(Canonical, Reduction) :-
   begin(maybe_trace_reduction(Canonical),
	 matching_strategies(Strategies, Canonical),
	 selected_reduction_with_before_after(Canonical, Strategies, Reduction)).

% Select method and attach befor and after
selected_reduction_with_before_after(Canonical, Strategies, Joined) :-
   begin(selected_reduction(Canonical, Strategies, Selected),
	 all(Method,
	     before(Canonical, Method),
	     BeforeMethods),
	 all(Method,
	     after(Canonical, Method),
	     AfterMethods),
	 append_task_lists(BeforeMethods, [Selected], AfterMethods,
			   Joined)).

%=autodoc
%% selected_reduction_with_before_after( ?Canonical, ?Strategies, +Joined) is semidet.
%
% Selected Reduction Using Before After.
%


% Select the reduced method from available methods.
selected_reduction(_, [S], S).

%=autodoc
%% selected_reduction( ?ARG1, ?UPARAM2, ?S) is semidet.
%
% Selected Reduction.
%

selected_reduction(Task, [ ], resolve_match_failure(Task)) :-
   emit_grain("match fail", 10).
selected_reduction(Task, Strategies, resolve_conflict(Task, Strategies)) :-
   emit_grain("match conflict", 10).

%%
%% Canonical forms
%%

%:- external trace_normalization/2.
canonical_form_of_task(Task, Canon) :-
   % when(trace_normalization($me, Task),
   % 	log($me:start_normalization(Task)),
   % 	trace(contained_in/2)),
   normalize_task(Task, Normalized),
   canonical_form_of_task(Normalized, Canon),
   !.

%=autodoc
%% canonical_form_of_task( ?Task, ?Canon) is semidet.
%
% Canonical Form Of Task.
%

   % when(trace_normalization($me, Task),
   % 	log($me:normalize_task(Task, Canon))).

canonical_form_of_task(Task, Task).

%%
%% Standard normalizations
%%



%=autodoc
%% normalize_task( ?Status, ?Task) is semidet.
%
% Normalize Task.
%
normalize_task(if(Condition, Then, _Else),
	  Then) :-
   Condition,
   !.
normalize_task(if(_, _, Else),
	  Else).
normalize_task(cases(CaseList),
	       S) :-
   member(C:S, CaseList),
   C,
   !.
normalize_task(unless(Condition, Action),
	       S) :-
   Condition -> (S=null) ; (S=Action).
normalize_task(unless(Condition, Action1, Action2),
	       S) :-
   Condition -> (S=null) ; (S=(Action1, Action2)).
normalize_task(unless(Condition, Action1, Action2, Action3, Action4),
	       S) :-
   Condition -> (S=null) ; (S=(Action1, Action2, Action3, Action4)).
normalize_task(unless(Condition, Action1, Action2, Action3, Action4, Action5),
	       S) :-
   Condition -> (S=null) ; (S=(Action1, Action2, Action3, Action4, Action5)).

normalize_task(when(Condition, Action),
	       S) :-
   Condition -> (S=Action) ; (S=null).
normalize_task(when(Condition, Action1, Action2),
	       S) :-
   Condition -> S=(Action1, Action2) ; (S=null).
normalize_task(when(Condition, Action1, Action2, Action3, Action4),
	       S) :-
   Condition -> S=(Action1, Action2, Action3, Action4) ;  (S=null).
normalize_task(when(Condition, Action1, Action2, Action3, Action4, Action5),
	       S) :-
   Condition -> S=(Action1, Action2, Action3, Action4, Action5) ; (S=null).

normalize_task({X}, X).
normalize_task(begin(A, B),
	       (A, B)).
normalize_task(begin(A, B, C),
	       (A, B, C)).
normalize_task(begin(A, B, C, D),
	       (A, B, C, D)).
normalize_task(begin(A, B, C, D, E),
	       (A, B, C, D, E)).
normalize_task(begin(A, B, C, D, E, F),
	       (A, B, C, D, E, F)).

% Translate wait_event_with_timeout into wait_event/2,
% which has a deadline rather than a timeout period.
normalize_task(wait_event_with_timeout(E, TimeoutPeriod),
	       wait_event(E, Deadline)) :-
   Deadline is $now + TimeoutPeriod.

%%
%% Matching strategies to tasks
%%



%=autodoc
%% matching_strategies( ?Strategies, ?Task) is semidet.
%
% Matching Strategies.
%
matching_strategies(Strategies, Task) :-
   all(S,
       matching_strategy(S, Task),
       Strategies).

%% matching_strategy(-S, +Task)
%  S is a strategy for Task.
matching_strategy(S, Task) :-
   (personal_strategy(Task, S) ; strategy(Task, S)),
   emit_grain("Default", 3),
   \+ veto_strategy(Task).



%=autodoc
%% maybe_trace_reduction( ?Canonical) is semidet.
%
% Maybe Trace Reduction.
%
maybe_trace_reduction(Canonical) :- 
  trace_reduction(Canonical), 
  forall( 
     ( clause(strategy(Task, Reduction), Body)  ,
       copy_term( Task:Reduction:Body, 
         CTask:CReduction:CBody), 
       Canonical=CTask), 
     if( CBody, 
       assert($task/log/match(Canonical, strategy(Task, Reduction), CReduction)), 
       assert($task/log/fail_match(Canonical, strategy(Task, Reduction))))).   
maybe_trace_reduction(_).

%%
%% Debugging tools
%%

%% show_decomposition(+Task)
%  Prints the series of decompositions of Task until it reaches a point where
%  it's not further decomposable, or the decomposition is non-unique.
show_decomposition(Task) :-
   writeln(Task),
   task_reduction(Task, Reduced),
   show_decomposition_aux(Reduced).



%=autodoc
%% show_decomposition_aux( ?ARG1) is semidet.
%
% Show Decomposition Aux.
%
show_decomposition_aux(resolve_match_failure(_)) :-
   writeln('-> no further decompositions possible').
show_decomposition_aux(resolve_conflict(_, ListOfReductions)) :-
   writeln('->'),
   forall(member(R, ListOfReductions),
	  begin(write('   '),
		writeln(R))).
show_decomposition_aux(UniqueDecomposition) :-
   write('-> '),
   writeln(UniqueDecomposition),
   task_reduction(UniqueDecomposition, Reductions),
   show_decomposition_aux(Reductions).

%%%
%%% General utilities
%%%



%=autodoc
%% commafy_task_list( ?ARG1, ?ARG2) is semidet.
%
% Commafy Task List.
%
commafy_task_list([], null).
commafy_task_list([Singleton], Singleton).
commafy_task_list([First | Rest], (First, CommafiedRest)) :-
   commafy_task_list(Rest, CommafiedRest).



%=autodoc
%% append_task_lists( ?ARG1, ?ARG2, ?ARG3, +Singleton) is semidet.
%
% Append Task Lists.
%
append_task_lists([ ], [Singleton], [ ], Singleton).  % fast path
append_task_lists(X, Y, Z, Joined) :-
   append(Y, Z, Intermediate),
   append(X, Intermediate, FullList),
   commafy_task_list(FullList, Joined).



%=autodoc
%% reduce_to_primitive( ?Task, ?Primitive) is semidet.
%
% Reduce Converted To Primitive.
%
reduce_to_primitive( (Task, _), Primitive) :-
   !,
   reduce_to_primitive(Task, Primitive).
reduce_to_primitive(Primitive, Primitive) :-
   primitive_task(Primitive),
   !.
reduce_to_primitive(resolve_match_failure(resolve_match_failure(resolve_match_failure(_))), _) :-
   !,
   fail.
reduce_to_primitive(Task, Primitive) :-
   task_reduction(Task, Reduced),
   reduce_to_primitive(Reduced, Primitive).