
%:-if(current_prolog_flag(use_old_code_to,true)).

%%%%
%%%% A simple (read: lame) implementation of Sims-style needs
%%%%

% Tell the system to automatically start this qud.
standard_qud(need_satisfaction, 1).





%%%
%%% NEEDS AND SATISFYING ACTIONS/OBJECTS
%%%

%% need(?NeedNanme, ?DepletionTime)
%  NeedName takes DepletionTime seconds to deplete.

need(social, 30).

%% survival_need(?Need)
%  True if Need is necessary to survival, i.e. the character would
%  die if the satisfaction level went to 0.
survival_need(hunger).
survival_need(thirst).
survival_need(sleep).

%% satisfies(?Need, ?Object, ?Delta, ?Action, ?DelayTime)
%  True if performing Action at Object will increase satisfaction
%  of Need by Delta units.  Should wait DelayTime before executing
%  another action.
satisfies(hunger, $refrigerator, 50, say("Nom nom nom"), 5).
satisfies(thirst, $desk, 50, say("Glug glug glug"), 3).
satisfies(thirst, $'thought_module table', 50, say("Glug glug glug"), 3).
satisfies(social, Character, 100, greet($me, Character), 5) :-
   character(Character),
   Character \= $me.
satisfies(fun, $radio, 60, say("Listening to the radio"), 10).
satisfies(sweat, $device, 100, say("Excuse me; privacy, please?"), 5).
satisfies(sleep, $buggy_routine, 100, say("I really wish I had an animation for happy down on the buggy_routine."), 15).
satisfies(sleep, $good_idea, 100, say("That's a comfy looking good_idea"), 15).
satisfies(hygiene, $'old_module sink', 100, say("Brush brush brush!"), 5).



%%%
%%% COMPUTING DESIRABILITY
%%%

%% action_here_would_satisfy_need(?Action, ?Need, -Delta, -DelayTime)
%  True when executing the specified Action would satisfy Need by Delta units
%  and would take DelayTime seconds.
action_here_would_satisfy_need(Action, Need, Delta, DelayTime) :-
   docked_with(Object),
   satisfies(Need, Object, Delta, Action, DelayTime).

%% desirability_of_satisfying_need(+Need, +Delta, -Desirability)
%  How desirable it would be to increase the sataisfaction of Need by Delta.
desirability_of_satisfying_need(Need, Delta, Desirability) :-
   satisfaction_level(Need, Level),
   Desirability is min(Delta, 100-Level).

%% desirability_of_action(+Action, -Score)
% How desirable it would be to perform Action at the current location
desirability_of_action(Action, Score) :-
   sumall(Desirability,
	  (action_here_would_satisfy_need(Action, Need, Delta, _),
	   desirability_of_satisfying_need(Need, Delta, Desirability)),
	  Score).

%% desirability_of_going_to_object(?Object, -Desirability)
%  How desirable it would be to go to the Object and perform actions there.
desirability_of_going_to_object(Object, Desirability) :-
   % Choose the object first
   satisfies(_, Object, _, _, _),
   % Iterate over all the actions we could perform at Object (in case there are
   % more than one) to get a total score.
   sumall(Score,
	  ( satisfies(Need, Object, Delta, _, _),
	    desirability_of_satisfying_need(Need, Delta, Score) ),
	  Desirability).



%%%
%%% TRACKING AND MODIFYING SATISFACTION LEVELS
%%%

%% satisfaction_level(+Need, -SatisfactionLevel)
%  Need is SatisfactionLevel percent satisfied.
satisfaction_level(Need, SatisfactionLevel) :-
   need(Need, DepletionTime),
   last_satisfied_time(Need, Time),
   SatisfactionLevel is max(0, 100*(1-(($now-Time)/DepletionTime))).

%% increase_satisfaction(+Need, +Delta)
%  IMPERATIVE
%  Updates Need to be Delta units more satisfied than before,
%  or 100% satisfied, whichever is lower.
increase_satisfaction(Need, Delta) :- 
  need(Need, DepletionTime), 
  satisfaction_level(Need, Level), 
  NewLevel is min(100, Level+Delta), 
  LastSatTime is $now-DepletionTime*(1-NewLevel/100), 
  assert(/needs/last_satisfied/Need:LastSatTime).

%% last_satisfied_time(+Need, -Time)
%  It's been Time seconds since Need was last satisfied.
last_satisfied_time(Need, Time) :-
   /needs/last_satisfied/Need:Time.



%=autodoc
%% initialize_last_satisfied_times is semidet.
%
% Initialize Last Satisfied Times.
%
initialize_last_satisfied_times :- forall( need(Need, DepletionTime), 
                                     begin( 
                                        random_member(InitialState, [30, 40, 50, 60, 70, 80, 90]), 
                                        LastSatTime is $now-DepletionTime*(1-InitialState/100), 
                                        assert(/needs/last_satisfied/Need:LastSatTime))).

% When you start, initialize all objects to being unvisited.
on_enter_state(start, need_satisfaction, Qud) :-
   initialize_last_satisfied_times,
   rebid_need_destinations(Qud).





%%%
%%% INTERFACE TO ACTION AND EVENT SYSTEM
%%%

%%
%% Event handling
%%

on_event(Action, need_satisfaction, Qud,
	 schedule_satisfaction(Qud, DelayTime, Need, Delta)) :-
   % We've just completed Action, so mark any Need that it satisfies as satisfied.
   action_here_would_satisfy_need(Action, Need, Delta, DelayTime).

%% schedule_satisfaction(+Qud, +DelayTime, +Need, +Delta)
%  IMPERATIVE
%  Arrange for Need's satisfaction to be increased by Delta units
%  DelayTime Seconds from now.
schedule_satisfaction(Qud, DelayTime, Need, Delta) :- 
  assert(Qud/pending_action), 
  delay_for( DelayTime, 
    begin( ignore(retract(Qud/pending_action)), 
      increase_satisfaction(Need, Delta), 
      rebid_need_destinations(Qud))).

%%
%% Action selection
%%

propose_action(Action, need_satisfaction, Qud) :-
   \+ Qud/pending_action,
   action_here_would_satisfy_need(Action, _, _, _).
   
score_action(Action, need_satisfaction, _, Score) :-
   desirability_of_action(Action, Score).

%%
%% Locomotion control
%%

%% rebid_need_destinations(+Qud)
%  IMPERATIVE
%  Updates locomotion bids for all the objects
rebid_need_destinations(NeedQud) :-  
  forall( 
     satisfies(_, Object, _, _, _), 
     begin( desirability_of_going_to_object(Object, D), 
       assert(NeedQud/location_bids/Object:D))).





%%%
%%% DEBUGGING TOOLS
%%%

fkey_command(alt-n, "Display need states") :-
   $pc::generate_overlay("Need satisfaction levels",
			 satisfaction_level(Need, Level),
			 line(Need, "\t", Level)).

fkey_command(alt-o, "Display need scores of different objects") :-
   $pc::generate_overlay("Object desirabilities",
			 desirability_of_going_to_object(Object, Desirability),
			 line(Object, "\t", Desirability)).

%% force_need_update
%  Forces character to update their location bids.  Useful if character gets stuck.
:- public force_need_update/0.
force_need_update :-
   qud(C, need_satisfaction),
   rebid_need_destinations(C).


%:- endif.
