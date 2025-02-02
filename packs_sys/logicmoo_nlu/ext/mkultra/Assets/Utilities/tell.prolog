%%%
%%% Simple forward-chaining system
%%%

:- op(1200, xfx, '==>>').
:- external (==>>)/2.

tell(P) :- ugoal_expansion(P,PP), tellg(PP), !.

tellg(P) :- call(P), !.
tellg(P) :-
   tell_assertion(P),
   forall(when_added(P, Action),
	  begin(maybe_log_when_added_action(P, Action),
		Action)).

:- external log_when_added_action/2.

maybe_log_when_added_action(P, Action) :-
   log_when_added_action(P, Action) -> log((P ==>> Action)) ; true.

:- multifile(when_added/2).
when_added(P, tell(Q)) :-
   (P ==>> Q).

:- external tell_globally/1.
tell_assertion(P) :-
   tell_globally(P) -> assert($global::P) ; assert(P).
