%%%
%%% EVENT HANDLING
%%% Events are actions taken by characters (including ourself) or
%%% or sensory events like collisions.
%%%

%% on_event(+Event, +Type, +Qud, -Handler)
%  Handler is the handler specified by Qud for Event, Type is Qud's type.
%  Important: on_event is not an imperative.  Rules for on_event should not
%  change the character's state.  However, the purpose of on_event is to generate
%  the list of handlers, and handlers are by definition imperatives.  Put your
%  state changes in the handlers, not in on_event.
:- external on_event/4.
:- higher_order on_event(0, 0, 0, 1).

%% log_events(+Event)
%  True if occurances of Event should be logged.
:- external log_events/1.

%% notify_event(+Event)
%  IMPERATIVE
%  Called by SimController component to inform Prolog of an event.
%  DO NOT CALL THIS YOURSELF!!!

:- public notify_event/1.

notify_event(Event) :-
   ignore(maybe_remember_event(Event)),
   findall(Handler,
	   event_handler(Event, _Type, _Qud, Handler), 
	   Handlers),
   maybe_log_event(Event, Handlers),
   forall(member(Handler, Handlers),
	  unless(Handler,
		 log(handler_failed(Handler)))).

%% event_handler(+Event, ?Type, ?Qud, -Handler)
%  Handler is Qud's handler for some construal of Event
%  and Type is its type.
event_handler(Event, Type, Qud, Handler) :-
    generate_unique(Construal, construal(Event, Construal)),
    qud(Qud, Type),
    on_event(Construal, Type, Qud, Handler).

%% maybe_log_event(+Event, +Handlers)
%  IMPERATIVE
%  Log Event and Handlers to Unity console, if log_events(Event) is true.
%  Always succeeds.
maybe_log_event(Event, Handlers) :-
    log_events(Event),
    log(event($me, Event, Handlers)).
maybe_log_event(_, _).

%%%
%%% EVENT CONSTRUAL
%%%

%% construe(+Event, +Construal)
%  Declares that Construal can be directly inferred as a construal
%  of Event.
%
%  This is the non-transitive version of construal.  Declare
%  your construal information using construe/2, not using construal/2.
:- external construe/2.
:- multifile construe/2.

%% construals(+Event, -ConstrualSet)
%  ConstrualSet is a list of all possible construals of Event,
%  without duplications.

:- public construals/2.

construals(Event, ConstrualList) :-
    all(Construal, construal(Event, Construal), ConstrualList).

%% construal(+Event, -Construal)
%  Transitive closure of construe/2.
%  Construal is a possible construal of Event.
construal(Event, Event).
construal(Event, Construal) :-
   construe(Event, C), construal(C, Construal).

construe(assertion(_, _, LF, _, _), mention(C)) :-
   mentions(LF, C).
construe(question(_, _, LF, _, _), mention(Concept)) :-
   mentions(LF, Concept).
construe(command(_, _, Command), mention(Concept)) :-
   mentions(Command, Concept).



%=autodoc
%% mentions( ?ARG1, ?Concept) is semidet.
%
% Mentions.
%
mentions(Concept, Concept) :-
   nonvar(Concept).
mentions(Term, Subterm) :-
   compound(Term),
   Term =.. List,
   member(Sub, List),
   mentions(Sub, Subterm).
