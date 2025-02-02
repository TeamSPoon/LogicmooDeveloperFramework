

%=autodoc
%% reduction_clause( :GoalGoal, ?Reduction) is semidet.
%
% Reduction Clause.
%
reduction_clause(beat_start_task(Beat), StartTask) :-
   beat_start_task(Beat, _, StartTask).
reduction_clause(beat_idle_task(Beat), IdleTask) :-
   beat_idle_task(Beat, _, IdleTask).
reduction_clause(beat_tasks(Beat), Task) :-
   beat_dialog(Beat, _, _, TaskList),
   member(Task, TaskList),
   \+ string(Task).
reduction_clause(beat_tasks(Beat), Task) :-
   beat_monolog(Beat, _, TaskList),
   member(Task, TaskList),
   \+ string(Task).

% Strip markup from dialog tasks.
reduction_clause(_::Goal, Goal).
reduction_clause(Goal:_, Goal).

reduction_clause(Goal, quip) :-
   character(C),
   C::clause(quip(Goal, _QuipName, _), _),
   nonvar(Goal).
reduction_clause(Goal, quip) :-
   character(C),
   C::clause(quip(Goal, _), _),
   nonvar(Goal).



%=autodoc
%% ignore_undeclared_task( ?Quip1, :GoalGOAL2) is semidet.
%
% Ignore Undeclared Task.
%
ignore_undeclared_task(quip,0).