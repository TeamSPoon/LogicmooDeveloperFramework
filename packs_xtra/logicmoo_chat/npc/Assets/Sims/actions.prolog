%%%
%%% Reasoning about low-level actions
%%%

%% action(?Task)
%  True if Task is an action (i.e. something executable by the C# code).
action(T) :-
   nonvar(T),
   functor(T, F, A),
   action_functor(F, A).
action(T) :-
   var(T),
   action_functor(F, A),
   functor(T, F, A).

%% action_functor(?Functor, ?Arity)
%  True when any structor with the specified Functor and Arity
%  is a primitive action.
:- external action_functor/2.

%% precondition(?Action, ?P)
%  P is a precondition of Action.
:- external precondition/2.
:- higher_order(precondition(0,1)).

%% postcondition(?Action, ?P)
%  P is a postcondition of Action.
:- external postcondition/2.
:- higher_order(postcondition(0,1)).

%%
%% Builtin primitive actions handled in SimController.cs
%%

action_functor(pickup, 1).
precondition(pickup(X),
	     present(X)).
precondition(pickup(X),
	     docked_with(X)).
postcondition(pickup(X), t(location, X, $me)) :-  
  X\= $me.

action_functor(putdown, 2).
precondition(putdown(Object, _Dest), t(location, Object, $me)).
precondition(putdown(_Object, Dest),
	     docked_with(Dest)).
postcondition(putdown(Object, Dest), t(location, Object, Dest)) :- 
  Dest\= $me, 
  Object\= $me.

action_functor(face, 1).
action_functor(ingest, 1).
action_functor(get_in, 1).
precondition(ingest(Edible), t(location, Edible, $me)) :- 
  \+iz_a(Edible, person), 
  Edible\= $me.
precondition(ingest(Edible),
	     docked_with(Edible)) :-
   iz_a(Edible, person),
   Edible \= $me.
precondition(ingest(Edible),
	     present(Edible)).
postcondition(ingest(X),
	      ~present(X)).

action_functor(flash, 4).

action_functor(end_quest, 1).

%% runnable(+Action) is det
%  True if Action can be executed now.
runnable(Action) :-
   \+ blocking(Action, _).

%% blocking(+Action, ?Precondition) is det
%  Action cannot be run because Precondition is an unsatisfied precondition of P.
blocking(Action, P) :-
   precondition(Action, P),
   \+ P.

%% true_after(+Action, ?Condition)
%  True if Condition is expected to be true after execution of Action.
true_after(Action, Condition) :-
   postcondition(Action, Condition).
true_after(Action, Condition) :-
   all(PC, postcondition(Action, PC), AllPCs),
   follows_from(Condition, AllPCs).



%=autodoc
%% follows_from( ?A, ?L) is semidet.
%
% Follows Converted From.
%
follows_from( (A, B) , L) :- nonvar(A),
   follows_from(A, L),
   follows_from(B, L).
follows_from(P, L) :-
   member(P, L).
follows_from(P, L) :- 
   member(~P, L), nonvar(P), !, fail.
follows_from(P, _) :- callable(P),
   P.
follows_from(P, L) :-
   inferrable_postcondition(P),
   clause(P, C),
   follows_from(C, L).



%=autodoc
%% inferrable_postcondition( ?ARG1) is semidet.
%
% Inferrable Postcondition.
%
inferrable_postcondition(here(_)).
inferrable_postcondition(away(_)).