%% step_completed
%  Current task has completed its current step; run continuation.
step_completed :-
   $task/continuation:K,
   invoke_continuation(K).

%% step_completed(+TaskConcern)
%  TaskConcern has completed its current step; tell it to run
%  its comtinuation.
step_completed(TaskConcern) :-
   within_task(TaskConcern, step_completed).

%% invoke_continuation(+Task)
%  Switch to current task's continuation, which is Task.
invoke_continuation( (First, Rest) ) :-
   !,
   begin(assert($task/continuation:Rest),
	 switch_to_task(First)).
invoke_continuation(K) :-
   begin(assert($task/continuation:done),
	 switch_to_task(K)).

invoke_continuation(TaskConcern, K) :-
   within_task(TaskConcern, invoke_continuation(K)).

restart_or_kill_task :-
   % Poor being's flow: task achievement -> positive affect
   affective_reaction(0.2, 0.05, 0, 0),
   ($task/repeating_task ->
      begin($task/type:task:Goal,
	    ignore(retract($task/log)),
	    invoke_continuation(Goal))
      ;
      kill_task($task)).

kill_task(T) :-
   begin(assert(T/current:exiting),
	 maybe_save_log(T),
	 kill_concern(T)).

%% restart_task(+TaskConcern)
%  Restarts a repeating task
restart_task(TaskConcern) :-
   begin(perform_restart_retractions(TaskConcern),
	 assertion(TaskConcern/repeating_task, "Attempt to restart a non-repeating task"),
	 assert(TaskConcern/current:restarting),
	 TaskConcern/type:task:Goal,
	 invoke_continuation(TaskConcern, Goal)).

perform_restart_retractions(Task) :-
   forall(retract_on_restart(Task, Assertion),
	  ignore(retract(Assertion))).

retract_on_restart(Task, Task/location_bids).
retract_on_restart(Task, Task/monitor).

%%
%% Interrupts
%%

%% interrupt_step(TaskConcern, +InterruptingTask)
%  Executes InterruptingTask, then returns to previous step.
interrupt_step(TaskConcern, InterruptingTask) :-
   within_task(TaskConcern,
	       begin([TaskConcern/current:C,
		     TaskConcern/continuation:K,
		     assert(TaskConcern/continuation:(C,K)),
		     switch_to_task(InterruptingTask)])).
