%%%
%%% STRATEGIES FOR STANDARD OPERATIONS
%%%
  


%% default_strategy(+Task, -Strategy) is nondet
%  Provides default strategies to use when Task has no specific matches.
strategy(resolve_match_failure(X), S) :-
   default_strategy(X, S).

%%%
%%% Precondition and postcondition handling
%%%

%%
%% achieve(P)
%% Task to make P become true.
%%

strategy(achieve(P),
	 Task) :-
   postcondition(Task, P).

strategy(achieve(Condition),
	 null) :-
   % Don't have to do anything if condition is already true.
   callable(Condition),
   call(Condition),
   !.

strategy(achieve(runnable(Action)),
	 achieve(Blocker)) :-
   blocking(Action, Blocker),
   \+ unachievable(Blocker).

%% unachievable(+Task)
%  Task is a-priori unachievable, so give up.
unachievable(present(_)).

strategy(achieve(P),
	 wait_condition(P)) :-
   self_achieving(P).

%%
%% Precondition chaining
%%

strategy(achieve_precondition(_, P),
	 S) :-
   strategy(achieve(P), S).

default_strategy(achieve_precondition(_SubTask, P),
		 abort_and_then(explain_failure(~P))).



%=autodoc
%% normalize_task( ?Status, ?Task) is semidet.
%
% Normalize Task.
%
normalize_task(abort_and_then(Task),
	       begin(call(perform_restart_retractions($task)),
		     invoke_continuation(Task))).

%%
%% MOVEMENT AND LOCOMOTION
%% achieving locations
%% moving
%% docking
%% goto
%%

strategy(achieve(t(location, X, $me)), pickup(X)) :-  
  X\= $me.
strategy(achieve(location(X, Module)),
	 achieve(location(X, Container))) :-
   %\+ freestanding(X),
   iz_a(Module, module),
   iz_a(Container, work_surface),
   location(Container, Module).
default_strategy(achieve(t(location, X, Container)), putdown(X, Container)) :- 
  X\= $me, 
  Container\= $me, 
  \+iz_a(Container, module).

strategy(achieve(t(location, $me, Container)), begin(goto(Container), get_in(Container))) :-  
  iz_a(Container, prop).

precondition(move($me, Patient, _), know(X, t(location, Patient, X))).
strategy(move($me, X, Y), achieve(t(location, X, Y))).

strategy(achieve(docked_with(MetaverseObject)),
	 goto(MetaverseObject)).

%%
%% locomotion
%%
:- external know/2.
precondition(goto(Object), know(X, t(location, Object, X))).

strategy(goto(Building),
	 null) :-
   iz_a(Building, building).
strategy(goto(Module), unless(t(contained_in, $me, Module), goto_internal(Module))) :-  
  is_impl_module(Module).
strategy(goto(PropOrCharacter),
	 unless(docked_with(Place),
		goto_internal(Place))) :-
   once(( prop(PropOrCharacter)
	;
	  algorithm(PropOrCharacter)
	;
	  character(PropOrCharacter))),
   top_level_container(PropOrCharacter, Place).

strategy(goto_internal(Place),
	 let(spawn_child_task(wait_event(arrived_at(Place)),
			      Child, [ Child/location_bids/Place:Priority ]),
	     wait_for_child(Child))) :-
   $task/priority:Priority.



%=autodoc
%% after( ?ARG1, ?ARG2) is semidet.
%
% After.
%
after(goto_internal(Person),
      greet($me, Person)) :-
   character(Person).

strategy(leave($me, Building), goto(Exit)) :- 
  iz_a(Building, building), 
  t(exit, Building, Exit).

strategy(flee($me),
	 leave($me, Building)) :-
   % Leave whatever building I'm in.
   t(contained_in,$me, Building),
   iz_a(Building, building).

%%
%% Getting things
%%

strategy(get($me, Object),
	 move($me, Object, $me)).

%%
%% Transfer of posession
%%

normalize_task(bring($me, Recipient, Object),
	       move($me, Object, Recipient)).
normalize_task(give($me, Recipient, Object),
	       move($me, Object, Recipient)).


%=autodoc
%% task_interacts_with_objects( ?ARG1, ?A) is semidet.
%
% Task Interacts Using Objects.
%
task_interacts_with_objects(bring(_, A, B), [A, B]).
task_interacts_with_objects(give(_, A, B), [A, B]).



%=autodoc
%% guard_condition( ?Task, ?Object) is semidet.
%
% Guard Condition.
%
guard_condition(Task, t(location, Object, _Loc)) :- 
  task_interacts_with_objects(Task, Objects), 
  member(Object, Objects).

%%
%% Spatial search
%%

strategy( 
   achieve(know(X, t(location, Object, X))), 
   begin( 
      search_for($me, _, Object), 
      unless(know(X, t(location, Object, X)), failed_because(cant_find(Object))))).

normalize_task(search_for($me, Unspecified, Target),
	       search_for($me, CurrentModule, Target)) :-
   var(Unspecified),
   in_module($me, CurrentModule).

strategy(search_for($me, Container, Target),
	 search_object(Container, X^(X=Target),
		       X^handle_discovery(X),
		       mental_monolog(["Couldn't find it."]))) :-
   nonvar(Target).
strategy(search_for($me, Container, Target),
	 search_object(Container, X^previously_hidden(X),
		       X^handle_discovery(X),
		       mental_monolog(["Nothing seems to be hidden."]))) :-
   var(Target).

strategy(handle_discovery(X),
	 begin(emote(surprise),
	       mental_monolog(["Found", np(X)]))).
after(handle_discovery(X),
      pickup(X)) :-
   iz_a(X, key_item).



%=autodoc
%% before( ?ARG1, ?Partner) is semidet.
%
% Before.
%
before(search_object(Object, _, _, _), goto(Object)) :-  
  \+t(contained_in, $me, Object).

strategy(search_object(ArchitecturalSpace, CriterionLambda, SuccessLambda, FailTask),
	 {
	  assert($task/status_text/"[search]":1),
	  if(nearest_unsearched(ArchitecturalSpace, Object),
	     % Search nearest item
	     search_object(Object, CriterionLambda, SuccessLambda,
			   % Try next item, if any
			   search_object(ArchitecturalSpace,
					 CriterionLambda, SuccessLambda,
					 FailTask)),
	     % Searched entire contents
	     begin(tell(/searched/ArchitecturalSpace),
		   FailTask))
	 }) :-
   iz_a(ArchitecturalSpace, architectural_space).

strategy(search_object(Container, CriterionLambda, SuccessLambda, FailTask),
	 if(nearest_unsearched(Container, Object),
	    % Search nearest item
	    search_object(Object,
			  CriterionLambda, SuccessLambda,
			  % Try next item, if any
			  search_object(Container,
					CriterionLambda, SuccessLambda, FailTask)),
	    % Searched entire contents
	    begin(tell(/searched/Container),
		  FailTask))) :-
   iz_a(Container, container),
   \+ iz_a(Container, architectural_space),
   % Reveal a hidden item, if there is one.
   ignore(reveal_hidden_item(Container)).

default_strategy(search_object(Object, CriterionLambda, SuccessLambda, FailTask),
		 if(( reduce(CriterionLambda, Object, Criterion),
		      Criterion ),
		    begin(tell(/searched/Object),
			  let(reduce(SuccessLambda, Object, SuccessTask),
			      SuccessTask)),
		    begin(pause(0.75),
			  tell(/searched/Object),
			  FailTask))).

:- public nearest_unsearched/2, unsearched/2.


%=autodoc
%% nearest_unsearched( +Container, ?Contents) is semidet.
%
% Nearest Unsearched.
%
nearest_unsearched(Container, Contents) :-
   nearest(Contents,
	   unsearched(Container, Contents)).



%=autodoc
%% unsearched( +Container, ?Contents) is semidet.
%
% Unsearched.
%
unsearched(Container, Contents) :- 
  t(location, Contents, Container), 
  \+implausible_search_location(Contents), 
  \+ /searched/Contents.



%=autodoc
%% implausible_search_location( ?X) is semidet.
%
% Implausible Search Location.
%
implausible_search_location(X) :-
   iz_a(X, exit).
implausible_search_location(X) :-
   character(X).

:- public reveal_hidden_item/1.



%=autodoc
%% reveal_hidden_item( +Container) is semidet.
%
% Reveal Hidden Item.
%
reveal_hidden_item(Container) :-
   hidden_contents(Container, Item),
   reveal(Item),
   tell($task/previously_hidden_items/Item),
   % Don't wait for update loop to update Item's position.
   assert(/perception/location/Item:Container),
   !.

:- public previously_hidden/1.


%=autodoc
%% previously_hidden( ?Item) is semidet.
%
% Previously Hidden.
%
previously_hidden(Item) :-
   $task/previously_hidden_items/Item.

%%
%% Ingestion (eating and drinking)
%%

strategy(eat($me, X),
	 ingest(X)).
postcondition(eat(_, X),
	      ~present(X)).
postcondition(eat(Person, F),
	      ~hungry(Person)) :-
   existing(thought, F).

strategy(drink($me, X),
	 ingest(X)).
postcondition(drink(_, X),
	      ~present(X)).
postcondition(drink(Person, B),
	      ~thirsty(Person)) :-
   existing(beverage, B).



%=autodoc
%% self_achieving( ?Nobody_speaking1) is semidet.
%
% Self Achieving.
%
self_achieving(/perception/nobody_speaking).

%%
%% Sleeping
%%

precondition(sleep($me, OnWhat), t(location, $me, OnWhat)).
strategy(sleep($me, _OnWhat),
	 with_status_text("zzz":2,
			  pause(60))).

%%
%% Social interaction
%%

strategy(engage_in_conversation(Person),
	 S) :-
   in_conversation_with(Person) ->
      S = null
      ;
      S = ( goto(Person),
	    greet($me, Person) ).

%%
%% OTHER
%% Pausing
%%

strategy(pause(Seconds),
	 wait_condition(after_time(Time))) :-
   freeze(Seconds, Time is $now + Seconds).



%=autodoc
%% ready_to_hand( ?Object) is semidet.
%
% Ready Converted To Hand.
%
ready_to_hand(Object) :-  
  t(location, Object, $me).
ready_to_hand(Object) :-
   docked_with(Object).

strategy(achieve_precondition(_, ready_to_hand(Object)),
	 goto(Object)).

:- external examined/1.



%=autodoc
%% tell_globally( ?ARG1) is semidet.
%
% Canonicalize And Store Globally.
%
tell_globally(examined(_)).

precondition(examine($me, Object),
	     ready_to_hand(Object)).
strategy(examine($me, Object),
	 begin(if(examination_content(Object, Content),
		  call(pop_up_examination_content(Content)),
		  describe(Object, general, null)),
	       tell(examined(Object)))).
after(examine($me, Object),
      call(maybe_remember_event(examine($me, Object)))).

precondition(read($me, Object),
	     ready_to_hand(Object)).
strategy(read($me, Object),
	 if(examination_content(Object, Content),
	    call(pop_up_examination_content(Content)),
	    say_string("It's blank."))).

strategy(force_examine(Object),
	 if(examination_content(Object, Content),
	    call(pop_up_examination_content(Content)),
	    call(log(no_examination_content(Object))))).

%%
%% Pressing buttons
%%

precondition(press($me, Button),
	     ready_to_hand(Button)).
default_strategy(press($me, _Button),
		 say_string("Nothing happened...")).

%%
%% Turning things on/off
%%

precondition(switch($me, X, power, on),
	     ready_to_hand(X)).
default_strategy(switch($me, X, power, on),
		 call(activate_prop(X))).

precondition(switch($me, X, power, off),
	     ready_to_hand(X)).
default_strategy(switch($me, X, power, off),
		 call(deactivate_prop(X))).

%%
%% Misc mechanical operations
%%

strategy(operate($me, Device),
	 call(operate(Device))) :-
   iz_a(Device, device).

:- public operate/1.


%=autodoc
%% operate( ?Device) is semidet.
%
% Operate.
%
operate(Device) :-  
  forall(t(contained_in, X, Device), destroy(X)).


%%
%% Tracking who you're doing something for
%%

normalize_task( on_behalf_of(Person, Task), 
  begin(assert($task/on_behalf_of:Person), Task)).


%=autodoc
%% retract_on_restart( ?Task, ?Task) is semidet.
%
% Retract Whenever Restart.
%
retract_on_restart(Task, Task/on_behalf_of).

%%
%% Ending and pausing the metaverse
%%

normalize_task(pause_metaverse,
	       call(pause_metaverse)).

strategy(end_quest,
	 show_status(quest_over)).


%%%
%%% Parallel processing
%%% We just have a simplistic fork/join system.
%%%

normalize_task(spawn(Task),
	       call(spawn_child_task(Task))).
normalize_task(spawn(Task, Child, Assertions),
	       call(spawn_child_task(Task, Child, Assertions))).

:- public spawn_child_task/1, spawn_child_task/3.


%=autodoc
%% spawn_child_task( ?Task) is semidet.
%
% Spawn Child Task.
%
spawn_child_task(Task) :-
   begin($task/priority:Priority,
	 start_task($task, Task, Priority)).


%=autodoc
%% spawn_child_task( ?Task, ?Child, ?Assertions) is semidet.
%
% Spawn Child Task.
%
spawn_child_task(Task, Child, Assertions) :-
   begin($task/priority:Priority,
	 start_task($task, Task, Priority, Child, Assertions)).

normalize_task(with_status_text(String:Priority, Task),
	       let(spawn_child_task(Task, Child, [ Child/status_text:String:Priority ]),
		   wait_for_child(Child))).

normalize_task(with_child_task(Task, Child, Assertions, Continuation),
	       let(spawn_child_task(Task, Child, Assertions),
		   Continuation)).

normalize_task(with_child_task(Task, Child, Continuation),
	       let(spawn_child_task(Task, Child, []),
		   Continuation)).

normalize_task(wait_for_child(Child),
	       wait_condition(child_completed(UID, Me))) :-
   Me = $task,
   qud_uid(Child, UID).

:- public child_completed/2.



%=autodoc
%% child_completed( ?UID, ?Me) is semidet.
%
% Child Completed.
%
child_completed(UID, Me) :-
   Me/quds/UID, !, fail.
child_completed(UID, Me) :-
   /failures/UID:_,
   % Sneakily rewrite our continuation so we'll fail.
   assert(Me/continuation:fail_because(child_failed(UID))).
child_completed(_, _).

default_strategy(wait_for_children,
		 wait_condition(\+ Me/quds/_)) :-
   % Need to manually bind a variable here to $task because the code that polls
   % this doesn't run "inside" the task, i.e. doesn't bind $task.
   Me = $task.

default_strategy(cobegin(T1),
		 begin(spawn(T1),
		       wait_for_children)).

default_strategy(cobegin(T1, T2, T3),
		 begin(spawn(T1),
		       spawn(T2),
		       spawn(T3),
		       wait_for_children)).

default_strategy(cobegin(T1, T2, T3, T4),
		 begin(spawn(T1),
		       spawn(T2),
		       spawn(T3),
		       spawn(T4),
		       wait_for_children)).

default_strategy(cobegin(T1, T2, T3, T4, T5),
		 begin(spawn(T1),
		       spawn(T2),
		       spawn(T3),
		       spawn(T4),
		       spawn(T5),
		       wait_for_children)).

default_strategy(cobegin(T1, T2, T3, T4, T5, T6),
		 begin(spawn(T1),
		       spawn(T2),
		       spawn(T3),
		       spawn(T4),
		       spawn(T5),
		       spawn(T6),
		       wait_for_children)).

%%%
%%% Beginnings of an exception/cognizant-failure system
%%%


%% Kstop the current task and log the reason for its failure.
strategy( failed_because(Reason), 
  begin(assert(/failures/UID:StrippedTask:Reason), done)) :- 
  $task/type:task:Task, 
  strip_task_wrappers(Task, StrippedTask), 
  qud_uid($task, UID).

%% strip_task_wrappers(+Task, -Stripped)
%  Stripped is the core task of Task, with any unimportant
%  wrappers removed, like on_behalf_of.
strip_task_wrappers(on_behalf_of(_, Task), Stripped) :-
   !,
   strip_task_wrappers(Task, Stripped).
strip_task_wrappers(Task, Task).