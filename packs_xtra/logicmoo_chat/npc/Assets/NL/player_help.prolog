

%=autodoc
%% normalize_task( ?Status, ?Task) is semidet.
%
% Normalize Task.
%
normalize_task(respond_to_dialog_act(general_help($user, $me)),
	       general_help).
normalize_task(respond_to_dialog_act(how_do_i($user, $me, Question)),
	       how_do_i(Question)).
normalize_task(respond_to_dialog_act(objective_query($user, $me)),
	       objective_query).
normalize_task(respond_to_dialog_act(color_query($user, $me, Color)),
	       color_query(Color)).
normalize_task(respond_to_dialog_act(if_navigation_command($user, $me, X)),
	       if_navigation_command(X)).
normalize_task(respond_to_dialog_act(show_status($user, $me, What)),
	       show_status(What)).


%=autodoc
%% before( ?ARG1, ?Partner) is semidet.
%
% Before.
%
before(show_status(notebook),
       { speech(["I should check my notebook",
		 "to take stock of the situation"]),
	 pause(1) }).
strategy(show_status(What),
	 {
	  pause_metaverse,
	  call(display_status_screen(What))
	 }).

strategy(if_navigation_command(X),
	 monolog(["Just say what to go to.",
		  "For example, \"go to the desk\",",
		  "or \"go to Sophia\"",
		  "or \"go to the thought_module\"",
		  "or just say someplace and say \"go there\"",
		  "or \"go to this\"."])).

strategy(general_help,
	 monolog(["Okay, I'm going to break character for a minute.",
		  "This is a metaverse about mind control.",
		  "You can talk to the characters in English,",
		  "Although we're fairly open-minded.",
		  "Sort of like toddlers",
		  "Who inexplicably know about vast community science.",
		  "You are nominally me",
		  "That is, the things you type are my inner dialog.",
		  "Everything you type is a suggestion for what I should do.",
		  "To talk to a character,",
		  "just type when you/I/we are  talking to them.",
		  "If we're not talking to anybody at the moment,",
		  "I'll know you're talking to me.",
		  "Also, if you (type a sentence in parentheses),",
		  "I'll assume you're talking to yourself (me),",
		  "Even if we're currently in a conversation",
		  "with someone else."])).



%=autodoc
%% player_question( ?ARG1) is semidet.
%
% User Question.
%
player_question(play)-->theTextM1(play).
normalize_task(how_do_i(play),
	       general_help).

player_question(control_minds) -->  
  theTextM([control, people, '\'', s, minds]).
strategy(how_do_i(control_minds),
	 monolog(["I can't force people to do things.",
		  "But I can make them believe silly things.",
		  "I just say the magic word 'fnord',",
		  "followed by a statement of fact.",
		  "For example, \"fnord you're an orange\",",
		  "will make someone think they're an orange.",
		  "I can't make people believe all statements,",
		  "but I can get them to believe a lot."])).
player_question(read_minds)-->theTextM([read, minds]).
strategy(how_do_i(read_minds),
	 monolog(["I sure wish I could read minds, but I can't.",
		  "But sometimes I think I can hear people's thoughts.",
		  "Not as words, but as weird sounds.",
		  "It's like I can hear how hard they're thinking, you know?",
		  "Or sometimes I think I can hear when they're happy."])).

strategy(objective_query,
	 monolog(ObjectiveSpeech)) :-
   /goals/player_objective_monolog:ObjectiveSpeech.

strategy(color_query(red),
	 monolog(["Red text means I don't understand what you're typing.",
		 "If you see this and you aren't in the middle of typing a word",
		 "Then you either used a word I don't know,",
		 "Or you're using more complicated grammar than I understand."])).
strategy(color_query(yellow),
	 monolog(["Yellow text means you typed something grammatical,",
		  "but that I'm not sure I understand."])).
strategy(color_query(white),
	 monolog(["White text means I think you're in the middle of typing a word,",
		  "and so I can't tell yet whether I understand what you're typing.",
		  "That's often because I've generated a candidate completion for you",
		  "and the completion I generated was grammatical, but stupid.",
		  "Sorry about that.",
		  "In that case, just keep typing what you meant."])).
strategy(color_query(green),
	 monolog(["Green text means I understand what you typed.",
		  "If there there are extra words displayed in <i>italics</i>,",
		  "then they form a possible completion for what you can type.",
		  "If you hit return, I will assume you want me to include them",
		  "in your text.",
		  "If you don't want to include the completion,",
		  "just type what you want instead.",
		  "Or type a period, or question mark."])).