%%
%% Responding to imperatives
%%

strategy(respond_to_dialog_act(command(Requestor, $me, Task)),
	 follow_command(Requestor, Task, RequestStatus)) :-
   request_status(Requestor, Task, RequestStatus).



%=autodoc
%% request_status( ?Requestor, ?Task, ?Combinatoric) is semidet.
%
% Request Status.
%
request_status(_Requestor, Task, combinatoric) :-
   @combinatoric(Task),
   !.
request_status(_Requestor, Task, non_normative) :-
   \+ well_typed(Task, action, _),
   !.
request_status(_Requestor, Task, unachievable(Reason)) :-
   \+ have_strategy(Task),
   once(diagnose(Task, Reason)),
   !.
request_status(Requestor, Task, incriminating(P)) :-
   guard_condition(Task, P),
   pretend_truth_value(Requestor, P, Value),
   Value \= true,
   !.
request_status(_Requestor, _Task, normal).

strategy(follow_command(Requestor, Task, normal),
	 if(dialog_task(Task),
	    Task,
	    if(Task=halt($me),
	       call(stop_current_everyday_life_task),
	       call(add_pending_task(on_behalf_of(Requestor, Task)))))).

:- public dialog_task/1.


%=autodoc
%% dialog_task( ?ARG1) is semidet.
%
% Dialog Task.
%
dialog_task(tell_about(_,_,_)).

strategy(follow_command(_, _, combinatoric),
	 say_string("That would be combinatoric.")).
strategy(follow_command(_, _, non_normative),
	 say_string("That would be weird.")).
strategy(follow_command(_, _, unachievable(Reason)),
	 explain_failure(Reason)).
strategy(follow_command(_, _, incriminating(_)),
	 say_string("Sorry, I can't.")).



%=autodoc
%% diagnose( ?Task, ?Precondition) is semidet.
%
% Diagnose.
%
diagnose(Task, ~Precondition) :-
   unsatisfied_task_precondition(Task, Precondition).

default_strategy(explain_failure(_),
		 say_string("I don't know how.")).
strategy( 
   explain_failure(~know(X, t(location, Object, X))), 
   speech(["I don't know where", np(Object), "is"])).

strategy(explain_failure(~ready_to_hand(Object)),
	 speech([np(Object), "isn't ready to hand."])).

default_strategy(tell_about($me, _, Topic),
		 describe(Topic, general, null)).
strategy(tell_about($me, Who, Topic),
	 add_conversation_task(Who, tell_about($me, Who, Topic))) :-
   Who \= $addressee.

strategy(tell($me, Who, What),
	 add_conversation_task(Who, assertion($me, Who, What, present, simple))).



%% normalize_task( ?Status, ?Task) is semidet.
%
% Normalize Task.
%
normalize_task(go($me, Location),
	       goto(Location)).
normalize_task(take($me, Patient, _),
	       pickup(Patient)).
normalize_task(put($me, Patient, Destination),
	      move($me, Patient, Destination)) :-
   nonvar(Destination).

strategy(talk($me, $addressee, Topic),
	 describe(Topic, introduction, null)) :-
   nonvar(Topic).

strategy(talk($me, ConversationalPartner, Topic),
	 add_conversation_topic(ConversationalPartner, Topic)) :-
   ConversationalPartner \= $addressee.

strategy(end_quest(_,_), end_quest(null)).

%%%
%%% Converstation topic queue
%%%

:- multifile(todo/2).


%% todo( ?Person, :PRED11) is semidet.
%
% Todo.
%
todo(engage_in_conversation(Person), 1) :-
   \+ currently_in_conversation,
   /pending_conversation_topics/Person/_.

strategy(add_conversation_topic(Person, Topic),
	 tell(/pending_conversation_topics/Person/ask_about($me,
							    Person,
							    Topic))) :-
   var(Topic) -> Topic = Person ; true.

strategy(add_conversation_task(Person, Task),
	 tell(/pending_conversation_topics/Person/Task)) :-
   true. % var(Topic) -> Topic = Person ; true.
