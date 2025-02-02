%%
%% Driver code
%% This is the code that talks to action_selection.prolog
%%

%% poll_tasks
%  Polls all tasks of all quds.
poll_tasks :-
   begin(bind_default_task_indexicals,
	 forall(qud(Task, task),
		once((poll_task(Task)->
		        true
		        ;
		        begin(Task/type:task:T,
			      log($me:poll_task_failed(Task, T))))))).

%% poll_task(+Task)
%  Attempts to make forward progress on Task's current step.
poll_task(T) :-
   T/monitor/Condition:Continuation,
   Condition,
   !,
   within_task(T, invoke_continuation(Continuation)).
poll_task(T) :-
   begin((T/current:A)>>ActionNode,
	 poll_task_action(T, A, ActionNode)).


%=autodoc
%% poll_task_action( ?T, ?Breakpoint2, ?ARG3) is semidet.
%
% Poll Task Action.
%
poll_task_action(T, start, _) :-
   % The task was just created and has yet to start.
   begin(assert(T/current:starting),
	 T/type:task:Task,
	 within_task(T, switch_to_task(Task))).
poll_task_action(T, starting, _) :-
   % The task is in the middle of trying to start.
   begin(T/type:task:Goal,
	 log($me:polling_task_that_never_finished_starting(T, Goal)),
	 save_log(T, "task never finished starting"),
	 stop_task(T)).
poll_task_action(T, completing_timeout, _) :-
   % The task in in the middle of trying to complete a timeout.
   begin(T/type:task:Goal,
	 log($me:polling_task_that_never_finished_completing_timeout(T, Goal)),
	 save_log(T, "task never finished completing timeout"),
	 stop_task(T)).
poll_task_action(T, completing_wait, _) :-
   % The task is in the middle of trying to complete a wait operation.
   begin(T/type:task:Goal,
	 log($me:polling_task_that_never_finished_completing_wait(T, Goal)),
	 save_log(T, "task never finished completing wait"),
	 stop_task(T)).
poll_task_action(T, restarting, _) :-
   % The task is in the middle of trying to restart.
   begin(T/type:task:Goal,
	 log($me:polling_task_that_never_finished_restart(T, Goal)),
	 save_log(T, "task never finished restart"),
	 restart_task(T)).
poll_task_action(T, exiting, _) :-
   % The task is in the middle of trying to exit.
   begin(T/type:task:Goal,
	 log($me:polling_task_that_already_exited(T, Goal)),
	 save_log(T, "task stopped twice"),
	 stop_task(T)).
poll_task_action(_, breakpoint, _).  % do nothing.
poll_task_action(T, A, ActionNode) :-
   % Check if the task is in the middle of an action.
   call_with_step_limit(10000, ((ActionNode:action) -> poll_action(T, A))).
poll_task_action(T, A, _) :-
   % The task is in the middle of a polled builtin.
   call_with_step_limit(10000, poll_builtin(T, A)).



%=autodoc
%% poll_action( ?T, ?A) is semidet.
%
% Poll Action.
%
poll_action(T, A) :-
   % Make sure it's still runnable
   runnable(A) ; interrupt_step(T, achieve(runnable(A))).



%=autodoc
%% poll_builtin( ?T, ?Yield) is semidet.
%
% Poll Builtin.
%
poll_builtin(T, yield) :-
   % Task had yielded, so let it run now.
   !,
   step_completed(T).
poll_builtin(T, wait_condition(Condition)) :-
   !,
   (Condition -> step_completed(T) ; true).
poll_builtin(_, wait_event(_)).   % nothing to do.
poll_builtin(T, wait_event(_, Timeout)) :-  
  ( $now>Timeout ->  
      begin(assert(T/current:completing_timeout), step_completed(T)) ; true).



%=autodoc
%% bind_default_task_indexicals is semidet.
%
% Bind Default Task Indexicals.
%
bind_default_task_indexicals :-
   default_addressee(A),
   bind(addressee, A).
   
%%
%%  Interface to mundane action selection
%%

propose_action(A, task, T) :-
   T/current:A:action.

score_action(A, task, T, Score) :-
   T/current:X:action,
   A=X,
   T/priority:Score.

on_event(E, task, T, wait_event_completed(T, E)) :-
   task_waiting_for(T, E).



%=autodoc
%% task_waiting_for( ?T, ?E) is semidet.
%
% Task Waiting For.
%
task_waiting_for(T, E) :-
   T/current:X,
   (X=E ; X=wait_event(E) ; X=wait_event(E,_)).



%=autodoc
%% wait_event_completed( ?T, ?E) is semidet.
%
% Wait Event Completed.
%
wait_event_completed(T, E) :-
   % Check to make sure that we're still waiting for this event.
   task_waiting_for(T, E),
   assert(T/current:completing_wait),
   bind_default_task_indexicals,
   step_completed(T).
wait_event_completed(_,_).

%%
%% Debug display
%%

character_debug_display(Character,
			[table([[bold("Task"), bold("Status"), bold("Current operation")]
			       | Tasks]),
			 line("")]) :-
   findall([Task, Status, Current],
	   Character::(qud(T, task),
		       T/type:task:Task,
		       (qud_status(T, Status) -> true ; (Status=null)),
		       T/current:Current),
	   Tasks).
