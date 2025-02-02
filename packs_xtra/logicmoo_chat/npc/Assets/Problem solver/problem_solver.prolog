%%
%% Simple problem solver in the general tradition of NASL
%%



%=autodoc
%% test_file( ?ARG1, ?NL/base_grammar_test2) is semidet.
%
% Test File.
%
test_file(problem_solver(_), "Problem solver/integrity_checks").
test_file(problem_solver(_), "Problem solver/ps_tests").

%%%
%%% Interface to external code
%%% Task creation, strategy specification
%%%

:- public start_task/5, start_task/3, start_task/2.

%% start_task(+Parent, +Task, +Priority, TaskQud, +Assertions) is det
%  Adds a task to Parent's subquds.  Priority is
%  The score to be given by the task to any actions it attempts
%  to perform.
start_task(Parent, Task, Priority, TaskQud, Assertions) :- 
  begin_child_qud( Parent, 
    task, Priority, TaskQud, 
    [ TaskQud/type:task:Task, 
      TaskQud/current:start, 
      TaskQud/continuation:done]), 
  forall(member(A, Assertions), assert(A)).
%   within_task(TaskQud, switch_to_task(Task)).



%=autodoc
%% start_task( ?Parent, ?Task, ?Priority) is semidet.
%
% Start Task.
%
start_task(Parent, Task, Priority) :-
   start_task(Parent, Task, Priority, _, [ ]).


%=autodoc
%% start_task( ?Task, ?Priority) is semidet.
%
% Start Task.
%
start_task(Task, Priority) :-
   start_task($root, Task, Priority, _, [ ]).

% Problem solver state is stored in:
%   TaskQud/type:task:TopLevelTask         
%   TaskQud/current:CurrentStep     (always an action or polled_builtin)
%   TaskQud/continuation:Task       (any task)

:- indexical task=null.

:- external veto_strategy/1, personal_strategy/2, before/2, after/2.

%% within_task(+TaskQud, :Code)
%  Runs Code within the task TaskQud.
within_task(TaskQud, Code) :-
   bind(task, TaskQud),
   (TaskQud/partner/P -> bind(addressee, P) ; true),
   Code.



%=autodoc
%% primitive_task( ?T) is semidet.
%
% Primitive Task.
%
primitive_task(T) :-
   builtin_task(T) ; action(T).


%=autodoc
%% builtin_task( ?T) is semidet.
%
% Builtin Task.
%
builtin_task(T) :-
   immediate_builtin(T) ; polled_builtin(T).


%=autodoc
%% immediate_builtin( ?ARG1) is semidet.
%
% Immediate Builtin.
%
immediate_builtin(null).
immediate_builtin(done).
immediate_builtin(call(_)).
immediate_builtin(tell(_)).
immediate_builtin(assert(_)).
immediate_builtin(assert_if_unew(_)).
immediate_builtin(retract(_)).
immediate_builtin(invoke_continuation(_)).
immediate_builtin((_,_)).
immediate_builtin(let(_,_)).


%=autodoc
%% polled_builtin( ?Breakpoint1) is semidet.
%
% Polled Builtin.
%
polled_builtin(yield).
polled_builtin(wait_condition(_)).
polled_builtin(wait_event(_)).
polled_builtin(wait_event(_,_)).
polled_builtin(breakpoint).

%% strategy(+Task, -CandidateStrategy)
%  CandidateStrategy is a possible way to solve Task.
%  CandidateStrategy may be another task, null, or a sequence of tasks
%  constructed using ,/2.

%% personaly_strategy(+Task, -CandidateStrategy)
%  CandidateStrategy is a possible way to solve Task.
%  CandidateStrategy may be another task, null, or a sequence of tasks
%  constructed using ,/2.

%% have_strategy(+Task)
%  True when we have at least some candidate reduction for this task.
have_strategy(Task) :-
   task_reduction(Task, Reduct),
   !,
   have_strategy_aux(Reduct).



%=autodoc
%% have_strategy_aux( ?Task) is semidet.
%
% Have Strategy Aux.
%
have_strategy_aux(resolve_match_failure(Task)) :-
   !,
   task_reduction(resolve_match_failure(Task),
		  Default),
   Default \= resolve_match_failure(_).
have_strategy_aux(_).   