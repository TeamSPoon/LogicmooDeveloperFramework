%%
%% Top-level strategies for responding to different kinds of dialog acts
%%

%%
%% Uninterpretable inputs
%%

default_strategy(respond_to_dialog_act(Act),
		 speech(["huh?"])) :-
   asserta($global::not_understood($me, Act)).

%%
%% Greetings and closings
%%


%% strategy( ?Addressee, ?Conversation, ?Me) is semidet.
%
% Strategy.
%
strategy( 
   respond_to_dialog_act(greet($addressee, $me)), 
   assert(Conversation/greeted), greet($me, $addressee)) :- 
  parent_qud_of($task, Conversation), 
  \+Conversation/greeted.
strategy(respond_to_dialog_act(greet($addressee, $me)),
	 null) :-
   parent_qud_of($task, Conversation),
   Conversation/greeted.

strategy( 
   respond_to_dialog_act(parting(Them, $me)), 
   begin( assert(Parent/generated_parting), 
     parting($me, Them), pause(1), call(stop_qud(Parent)))) :- 
  parent_qud_of($task, Parent), 
  \+Parent/generated_parting.

strategy(respond_to_dialog_act(parting(_Them, $me)),
	 call(stop_qud(Parent))) :-
   parent_qud_of($task, Parent),
   Parent/generated_parting.

strategy(respond_to_dialog_act(excuse_self(Them, $me)),
	 call(stop_qud(Parent))) :-
   $task/partner/Them,
   parent_qud_of($task, Parent).

%%
%% Discourse increments
%%

strategy(respond_to_dialog_act(discourse_increment(_Sender, _Receiver, [ ])),
	 null).
strategy(respond_to_dialog_act(discourse_increment(Sender, Receiver,
						   [ Act | Acts])),
	 begin(respond_to_increment(Sender, Receiver, Act),
	       respond_to_dialog_act(discourse_increment(Sender, Receiver, Acts)))).

default_strategy(respond_to_increment(_, _, _),
		 null).
strategy(respond_to_increment(Speaker, Addressee, s(LF)),
	 respond_to_dialog_act(assertion(Speaker, Addressee, LF, present, simple))).
strategy(respond_to_increment(Speaker, Addressee, question_answer(LF)),
	 respond_to_dialog_act(question_answer(Speaker, Addressee, LF))).
strategy(respond_to_increment(_Speaker, _Addressee, _String:Markup),
	 respond_to_quip_markup(Markup)).

%%
%% Agreement/disagreement
%%

strategy(respond_to_dialog_act(agree(_, _,_, _)),
	 null).

%%
%% Automatic commands
%%

strategy(respond_to_dialog_act(automa_command(_, $me, LF, present, simple)),
	 do_automatically_believe(LF)).

strategy(do_automatically_believe(LF),
	 begin(flash(Yellow, Green, 0.3, 1.5),
	       emote(automatized),
	       discourse_increment($me, Partner, [ uninterpreted_s(LF) ]),
	       emote(automatized))) :-
   automatically_believe(LF),
   Yellow is $'Color'.yellow,
   Green is $'Color'.green,
   $task/partner/Partner.

default_strategy(do_automatically_believe(_LF),
		 % No effect
		 null).

%%
%% Offers
%%

strategy(respond_to_dialog_act(offer(Offerer, $me, TheirAct, MyAct)),
	 Response) :-
   acceptable_offer(Offerer, TheirAct, MyAct) ->
   Response = (acceptance($me, Offerer, TheirAct, MyAct),
	       call(add_pending_task(on_behalf_of(Offerer, MyAct))))
      ;
      Response = rejection($me, Offerer, TheirAct, MyAct).



%=autodoc
%% acceptable_offer( ?ARG1, ?ARG2, ?ARG3) is semidet.
%
% Acceptable Offer.
%
acceptable_offer(_, _, _).

strategy(respond_to_dialog_act(acceptance(Acceptor, $me, MyAct, _TheirAct)),
	 call(add_pending_task(on_behalf_of(Acceptor, MyAct)))).

strategy(respond_to_dialog_act(rejection(_Acceptor, $me, _MyAct, _TheirAct)),
	 null).
