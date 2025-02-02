:- external explanation/2.



%=autodoc
%% before( ?ARG1, ?Partner) is semidet.
%
% Before.
%
before(goto(_),
       excuse_self($me, Partner)) :-
   in_conversation_with(Partner).



%=autodoc
%% conversation_idle_task( ?Partner, +Pending_conversation) is semidet.
%
% Conversation Idle Task.
%
conversation_idle_task(Partner, pending_conversation) :-
   /pending_conversation_topics/Partner/_.

strategy(pending_conversation,
	 begin(call(set_qud_status($task, TopicNode)),
	       retract(TopicNode),
	       if(string(Topic),
		  speech([Topic]),
		  Topic))) :-
   % Need the once to prevent it from generating all topics at once.
   once(/pending_conversation_topics/ $addressee/Topic>>TopicNode).

conversation_idle_task(Partner, do_beat_dialog(Task)) :-
   current_beat(B),
   \+ beat_waiting_for_timeout,
   dialog_task_with_partner_advances_current_beat(B, Partner, Task).

strategy(do_beat_dialog(null), null).
default_strategy(do_beat_dialog(Task),
		 begin(Task,
		       tell($global_root/beats/Beat/completed_tasks/Name))) :-
   beat_task_name(Task, Name),
   current_beat(Beat).

strategy(ask_about($me, $addressee, $addressee),
	 question($me, $addressee,
		  X:manner(be($addressee), X),
		  present, simple)).
strategy(ask_about($me, $addressee, Topic),
	 command($me, $addressee,
		 tell_about($addressee, $me, Topic))) :-
   Topic \= $addressee,
   Topic \= question(_).
strategy(ask_about($me, $addressee, question(Q)),
	 question($me, $addressee, Q, present, simple)).
strategy(ask_about($me, Who, Topic),
	 add_conversation_topic(Who, Topic)) :-
   Who \= $addressee.

strategy(ask_value($me, Who, Question),
	 add_conversation_topic(Who, question(Question))) :-
   Who \= $addressee.
