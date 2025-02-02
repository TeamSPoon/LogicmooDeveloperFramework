:- indexical script_qud.

on_enter_state(start, script, C) :-  
  begin( C/initial_history:History, 
    forall(member(Event, History), assert(C/history/Event)), 
    script_update_await_list(C)).

on_event(Event, script, C, script_update(C, Event)) :-
   C/awaiting/AwaitedEvent,
   Event = AwaitedEvent.
   
propose_action(Action, script, C) :-
   /perception/nobody_speaking,
   C/awaiting/Action,
   action(Action),
   agent(Action, $me).
   %log($me:propose(Action)).



%=autodoc
%% script_update( ?C, ?Event) is semidet.
%
% Script Update.
%
script_update(C, Event) :-
   %log($me:got(Event)),
   assert(C/history/Event),
   script_update_await_list(C).



%=autodoc
%% script_update_await_list( ?C) is semidet.
%
% Script Update Await List.
%
script_update_await_list(C) :-
   begin(C/type:script:Script,
	 ignore(retract(C/awaiting)),
	 bind(script_qud, C),
	 script_history(C, History),
	 next_events(Script, History, NextSet),
	 %log($me:(History->NextSet)),
	 ( (NextSet = [ ]) ->
	     % Done; exit.
	     stop_qud(C)
	     ;
	     % Not done; write back to working memory
	     forall(member(Event, NextSet),
		    assert(C/awaiting/Event))) ).



%=autodoc
%% script_history( ?C, ?History) is semidet.
%
% Script History.
%
script_history(C, History) :-
   findall(Event, C/history/Event, History).