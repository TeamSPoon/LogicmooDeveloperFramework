 
/*************************************************************************

         name: lexicon_player_english.pl 
	 date: 2004-10-25
       author: Andreas Wallentin
 
*************************************************************************/

:- module( lexicon_player_english, [output_form/2,
				    input_form/2,
				    yn_answer/1]).

:- multifile synset/2.
:- discontiguous output_form/2, input_form/2.

resource_of_type(lexicon).

:- use_module( library(lists), [ member/2, select/3, append/3, is_list/1 ] ).
%%:- use_module( library(charsio), [ format_to_chars/3 ] ).

%% f�r mer variation av output
:- use_module( library(random) ).

%:- use_module( dbase ).
:- ensure_loaded( digits_svenska_player ).
:- ensure_loaded( semsort_player ).
%:- ensure_loaded( groups ).


/*----------------------------------------------------------------------
     output_form( +Move, -String )
     -- Canned output
----------------------------------------------------------------------*/
/*
F�r mer variation i output, slumpas olika fraser fram.
Samma f�r avsluten.
*/
greetings(['The music application is ready to use.','Welcome to the audio player']).
byes(['Good bye!','Hope you enjoyed the stay','Bye bye']).

% getNoXInList(+VilketIOrdning, +Lista, -UtvaltSvar).
getNoNInList(1,[X|_],X).
getNoNInList(Num, [_|Xs], Svar):-
	N is Num-1,
	getNoNInList(N,Xs,Svar).


output_form( A, _ ):-
	format('output form for ~w\n',[A]),
	fail.

output_form( action(top), ['top'] ).

%% Called the first time the program is running
%%
output_form( greet, [Greeting] ):-
	random(1,3,N),
	greetings(List),
	getNoNInList(N,List,Greeting).

output_form( quit, [Ends] ):-
	random(1,4,N),
	byes(List),
	getNoNInList(N,List,Ends).


% ask-moves
output_form( ask(X^(action(X))), ['What can I do for you?'] ).

output_form( ask(action(T)), Str ):-
	output_form(action(T), StrT ),
	append( ['Do you want to  '], StrT, Str0 ),
	append( Str0, ['?'], Str).


%% ta reda p� saker fr�n anv�ndaren
output_form( ask(X^playlist(X)),
	     ['Which playlist do you want to open?'] ).
output_form( ask(X^itemAdd(X)),
	     ['What song do you want to add to the playlist?'] ).
output_form( ask(X^itemRem(X)),
	     ['What song(index no) do you want to remove from the playlist?'] ).
output_form( ask(X^groupToAdd(X)),
	     ['What group do you mean?'] ).
output_form( ask(X^station(X)),
	     ['What radio station do you want to listen to?'] ).
output_form( ask(X^listenTo(X)),
	     ['Do you want to listen to radio or songs?'] ).
output_form( ask(X^artist(X)),
	     ['What artist do you mean?'] ).
output_form( ask(X^song(X)),
	     ['What song do you mean?'] ).
output_form( ask(X^album(X)),
	     ['What album do you mean?'] ).
output_form( ask(X^song_artist(X)),
	     ['What group do you mean?'] ).

output_form( ask(X^group(X)),
	     ['What group do you mean?'] ).
output_form( ask(X^item(X)),
	     ['What song do you mean?'] ).

output_form( ask(X^what_to_play(X)),
	     ['What song in the playlist do you want to listen to?'] ).

output_form( answer(path(Path)),                Ans ):-
	( Path = ''
	->
	    Ans = ['There is no path that matches the search criterion.']
	;
	    Ans = ['The path to the song is:',Path]
	).


output_form( answer(fail(Path^path(Path),no_matches)),                Ans ):-
	Ans = ['The path to the song is not:',Path].

output_form( answer(artists_song(Artist)),      ['The following artists have done it:',Artist] ).
output_form( answer(artists_album(Artist)),     ['The album was made by',Artist] ).
output_form( answer(albums_by_artist(Albums)),  Answer ):-
	( Albums = ''
	-> Answer = ['There are no albums']
	; Answer = ['These albums exist:',Albums]
	).
output_form( answer(current_song([A,B])),           Answer ):-
	Answer = ['You are listening to',A,'-',B].

output_form( answer(songs_by_artist(Songs)),    ['They have made:'|Str] ):-
	lexsem(S,Songs),
	append(S,['.'],Str).



output_form( issue(path(_)),                   ['ask about the path of a song'] ).

output_form( action(handle_player),     ['handle the player'] ).
output_form( action(handle_playlist),   ['handle playlists'] ).
output_form( action(handle_stations),   ['handle radio stations'] ). 

output_form( action(start),             ['start the player'] ).
output_form( action(start_specific),    ['play a specific song'] ).
output_form( action(stop),              ['stop the player'] ).
output_form( action(pause),             ['pause the music'] ).
output_form( action(resume),            ['resume the music'] ).
output_form( action(fast_rewind),       ['rewind'] ).
output_form( action(start_playlist),    ['play a certain playlist'] ).
output_form( action(fast_forward),      ['wind'] ).
output_form( action(rewind),            ['rewind'] ).
output_form( action(next_song),         ['to next'] ).
output_form( action(previous_song),     ['to previous'] ).

output_form( action(playlist_add),      ['add a song to the playlist'] ).
output_form( action(playlist_del_specific),      ['remove a song from the playlist'] ).
output_form( action(playlist_del),      ['delete the playlist'] ).
output_form( action(playlist_shuffle),  ['shuffle the playlist'] ).
output_form( action(show_list),         ['show the playlist'] ).

%%% confirming actions
output_form( confirm(handle_player),    ['done handling player'] ).
output_form( confirm(handle_playlist),  ['done handling playlist'] ).
output_form( confirm(handle_stations),  ['done handling stations'] ).

output_form( confirm(start),            ['Starting the music'] ).
output_form( confirm(start_specific),    ['Starting the music'] ).
output_form( confirm(stop),             ['The music is stopped'] ).
output_form( confirm(pause),            ['Pausing the player'] ).
output_form( confirm(resume),           ['Resuming the music'] ).
%output_form( confirm(fast_rewind),      ['soplar �t n�t h�ll'] ).
output_form( confirm(start_playlist),    ['Playing playlist'] ).
output_form( confirm(fast_forward),     ['Winding'] ).
output_form( confirm(rewind),           ['Rewinding'] ).

output_form( confirm(playlist_add),     ['The playlist is increased'] ).
output_form( confirm(playlist_del_specific),     ['The playlist is reduced'] ).
output_form( confirm(playlist_del),     ['The playlist is cleared'] ).
output_form( confirm(playlist_shuffle), ['The playlist is shuffled'] ). 
output_form( confirm(show_list),        ['The playlist is shown'] ).

output_form( confirm(vol_up),           ['Increasing volume'] ).
output_form( confirm(vol_down),         ['Lowering volume'] ).
output_form( confirm(next_song),        ['To next song'] ).
output_form( confirm(previous_song),    ['To previous song'] ).

output_form( report('PlaylistAdd', failed(G,S)), Ans ):-
	lexsem(Glex,G),
	lexsem(Slex,S),
	append(['Sorry,'],Slex,A0),
	append(A0,[by],A1),
	append(A1,Glex,A2),
	append(A2,['does not exist'],Ans).

output_form( report('Resume', failed(Status) ),
	     ['Could not resume since the player is',Status]).
output_form( report('Start', failed(Status) ), %%% spelare p� paus
	     ['Could not play since the player is',Status]).


altlist2altstr_and( [D], Str ):-
	alt2altstr( D, Str1 ),
	append( " and ", Str1, Str ).
altlist2altstr_and( [D|Ds], Str ):-
	alt2altstr( D, Str1 ),
	altlist2altstr_and( Ds, Str2 ),
	append( Str1, ", ", Str3 ),
	append(Str3, Str2, Str ).

altlist2altstr_or( [D], Str ):-
	alt2altstr( D, Str1 ),
	append( " or ", Str1, Str ).
altlist2altstr_or( [D|Ds], Str ):-
	alt2altstr( D, Str1 ),
	altlist2altstr_or( Ds, Str2 ),
	append( Str1, ", ", Str3 ),
	append(Str3, Str2, Str ).

alt2altstr( D, Str ):-
	output_form( D, Str ).

alt2altstr( D, Str ):-
	name( D, Str ).




%%% used in output_form/2 with ask(set(...))
altlist2alts_or( [Alt], ['or'|OutputAlt] ):-
	output_form(Alt, OutputAlt ).
altlist2alts_or( [Alt|Alts], [','|Output] ):-
	output_form(Alt, OutputAlt ),
	altlist2alts_or(Alts, AltsOr),
	append( OutputAlt, AltsOr, Output).


% object-level clarification and groundnig questions
output_form( ask(C), Output  ):-
	output_form( icm:und*pos:_*C, IcmPos ),
	append( IcmPos0,['.'],IcmPos),
	append( IcmPos0, [', is that correct?'], Output ).



output_form( ask(set([Alt0|Alts])), Output):-
	output_form(Alt0, Alt0out),
	altlist2alts_or( Alts, AltsOr ),
	append(['Do you want '|Alt0out], AltsOr, Output0 ),
	append(Output0, ['?'], Output).

output_form( Alt, OutputAlt ):-
	input_form( OutputAlt, answer( Alt ) ).

output_form( answer(notexist(X,Q)), ['Sorry, there is nothing matching your request about '|InputQDot]):-
	input_form( InputQ, ask(X^Q) ),
	append( InputQ, ['.'], InputQDot ).
output_form( answer(unknown(Q)), ['Sorry, there is nothing matching your request about '|InputQDot]):-
	input_form( InputQ, ask(Q) ),
	append( InputQ, ['.'], InputQDot ).

% for asking metaissue clarification question
output_form( issue(Q), ['to ask about'|Out] ):-
	input_form( Out, ask( Q ) ).



% for asking metaissue clarification question
%output_form( action(Action), ['to '|Out] ):-
%	input_form( Out, request( Action ) ).

% ICM

% contact
output_form( icm:con*neg, ['Hello?'] ).


% perception
output_form( icm:per*int, ['Pardon?'] ).
output_form( icm:per*int, ['What did you say?'] ).
output_form( icm:per*neg, ['Sorry, I didnt hear what you said.'] ).

output_form( icm:per*pos:String, ['I heard you say',Name,'. '] ):-
	name( Name, String ).

output_form( icm:sem*int, ['What do you mean'] ).
output_form( icm:sem*neg, ['Sorry, I dont understand.'] ).
output_form( icm:sem*pos:Move, InputDot ):-
	input_form( Input, Move ),
	append( Input, ['.'], InputDot ).



% understanding(pragmatic)
output_form( icm:und*neg, ['I dont quite understand.']  ).

% first clause added 021120 SL
output_form( icm:und*pos:usr*issue(Q), ['You want to know '|AnsPDot]  ):-
	output_form( Q, AnsP ),
	append(AnsP,['.'],AnsPDot).

output_form( icm:und*pos:usr*issue(Q), ['You want to know about'|AnsPDot]  ):-
	input_form( AnsP, ask( Q ) ),
	append(AnsP,['.'],AnsPDot).
output_form( icm:und*pos:usr*(not issue(Q)), ['You did not ask about'|AnsPDot]  ):-
	input_form( AnsP, ask( Q ) ),
	append(AnsP,['.'],AnsPDot).


output_form( icm:und*pos:usr*(not P), AnsNotPDot  ):-
	output_form( icm:und*pos:usr*P, AnsPDot  ),
	append( ['not'],AnsPDot,AnsNotPDot ).

output_form( icm:und*pos:usr*P, AnsPDot  ):-
	( output_form(P, AnsP);
	    input_form( AnsP, answer(P) ) ),
	append(AnsP,['.'],AnsPDot).

% special cases; could make use of isa-hierarchy
%output_form( icm:und*pos:usr*channel_to_store(X), IcmPos  ):-
%	output_form( icm:und*pos:usr*channel(X), IcmPos ).
%output_form( icm:und*pos:usr*new_channel(X), IcmPos  ):-
%	output_form( icm:und*pos:usr*channel(X), IcmPos ).

% 020702 SL
output_form( icm:und*pos:usr*PX, IcmPos ):-
	PX =.. [P,X],
	isa( P, P1 ),
	P1X =.. [P1,X],
	output_form( icm:und*pos:usr*P1X, IcmPos ).



output_form( icm:und*int:usr*C, IcmInt  ):-
	output_form( ask(C), IcmInt ).
	%output_form( icm:und*pos:C, IcmPos ),
	%append( IcmPos0,['.'],IcmPos),
	%append( IcmPos0, [', is that correct?'], IcmInt ).

%output_form( icm:und*int:usr*C, IcmInt  ):-
%	input_form( answer(C), IcmInt ).


output_form( icm:und*int:usr*C, Output  ):-
	output_form( icm:und*pos:_*C, IcmPos ),
	append( IcmPos0,['.'],IcmPos),
	append( IcmPos0, [', is that correct?'], Output ).




% clarification question
output_form( icm:und*int:usr*AltQ, Output):-
	output_form( ask(AltQ), Output).



% "acceptance"/integration

% icm-Type(-Polarity(-Args))
output_form( icm:acc*pos, ['Okay.'] ).

% reject(issue(Q))
output_form( icm:acc*neg:issue(Q), ['Sorry, I cannot answer questions about'|InputQDot]):-
	input_form( InputQ, ask(Q) ),
	append( InputQ, ['.'], InputQDot ).

% reject proposition P
output_form( icm:acc*neg:P, ['Sorry, '|Rest]):-
	input_form( InputP, answer(P) ),
	append( InputP, [' is not a valid parameter.'], Rest ).

% indicate loading a plan (pushed by findPlan)
%output_form( icm:loadplan, ['I need some information.'] ).
output_form( icm:loadplan, ['Lets see.'] ).


% reraise issue explicitly (feedback on user reraise, or system-initiated)
output_form( icm:reraise:Q, ['Returning to the issue of '|InputQDot]):-
	( input_form( InputQ, ask(Q) ); output_form( ask(Q), InputQ ) ),
	append( InputQ, ['.'], InputQDot ).

% reraise action explicitly (feedback on user reraise, or system-initiated)
output_form( icm:reraise:A, ['Returning to '|InputQDot]):-
	( input_form( InputQ, request(A) ); output_form( action(A), InputQ ) ),
	append( InputQ, ['.'], InputQDot ).

% reraise issue (system-initiated, where question follows immediately after)
output_form( icm:reraise, ['So,']).

% accommodation
output_form( icm:accommodate:_, ['Alright.']  ).

output_form( icm:reaccommodate:Q, ['Returning to the issue of'|AnsPDot]  ):-
	input_form( AnsP, ask( Q ) ),
	append(AnsP,['.'],AnsPDot).



output_form( not C, ['Not'|S] ):- output_form( C, S ).



%

/*----------------------------------------------------------------------
     input_form( +Phrase, -Move )
     -- Almost canned input
----------------------------------------------------------------------*/

input_form( [not|S], answer(not(C))):- input_form(S,answer(C)).

input_form( [yes], answer(yes) ).
input_form( [no], answer(no) ).


% simple stuff

input_form( [hello], greet ).
input_form( [good,bye], quit ).
input_form( [quit], quit ).
input_form( [abort], quit ).

			% ICM

input_form( [sorry], icm:per*neg ).
input_form( [okey], icm:acc*pos ).
input_form( [ok], icm:acc*pos ).

input_form( [dont,know], icm:acc*neg:issue ).


/******************************
            ACTIONS
******************************/


%%%%%  Requests  %%%%%


input_form( [restart],   request(restart) ).
input_form( [top],        request(top) ).
input_form( [go,up],   request(up) ).

input_form( S, request(handle_player) ) :-
	S = [handle,the,player];
	S = [the,player].

input_form( S, request(handle_playlist) ):-
	S = [handle,playlists];
%	S = [the,playlist];
	S = [the,playlists];
	S = [the,list]. 
	
%input_form( [choose],      request(listen_to) ).

input_form( [play|X],    [request(start_specific),answer(index(C))] ):-
	lexsem(X,C),
	sem_sort(C,index).
input_form( [play|Group], [request(start),request(playlist_add),answer(group(C))] ):-
	lexsem(Group,C),
	sem_sort(C,group).
	
input_form( [play|Song], [request(start),request(playlist_add),answer(item(Song))] ):-
	sem_sort(Song,item).

input_form( S, request(handle_stations) ) :-
	S = [listen,to,radio],
	S = [radio,stations];
	S = [radio,station];
	S = [stations].

input_form( S, request(start) ):-
	S = [start,the,player];
	S = [play];
	S = [start].


input_form( S, request(stop) ) :-
	S = [stop,the,player];
	S = [stop].

input_form( S, request(pause) ):-
	S = [pause,the,music];
	S = [pause].

input_form( S , request(resume) ) :-
	S = [resume,the,music];
	S = [resume].

input_form( [rewind],      request(fast_rewind) ).
input_form( [back],      request(rewind) ).
input_form( [fast,forward],     request(fast_forward) ).
input_form( [forward],     request(fast_forward) ).
input_form( [next],      request(next_song) ).
input_form( [previous], request(previous_song) ).

input_form( [play,playlist],  request(start_playlist) ).
input_form( [play,a,certain,playlist],  request(start_playlist) ).
input_form( [a,playlist],     request(start_playlist) ).
input_form( [add],       request(playlist_add) ).
input_form( [add,a,song,to,the,playlist], request(playlist_add) ).

%input_form( [l�gg,till],        request(playlist_add) ).
input_form( [listen,to],         request(playlist_add) ).
input_form( [show,the,list],      request(show_list) ).
input_form( [show,the,playlist],  request(show_list) ).

%input_form( [h�ra,p�],    request(listen_to) ).
%input_form( [want,to,hear],  request(listen_to) ).
input_form( [shuffle],     request(playlist_shuffle) ).


input_form( [clear],  request(playlist_del) ).
%input_form( [List],       request(playlist_del) )      :- lexsem(List,list).
%input_form( [l�t],        request(playlist_del_specific) ).

%% ny plan som fr�gar vad man vill ta bort
%input_form( [ta,bort],    request(remove) ).
input_form( [remove,the,playlist],   request(playlist_del) ).
input_form( [delete,the,playlist],     request(playlist_del) ).

input_form( [remove], request(playlist_del_specific)).
input_form( [delete], request(playlist_del_specific)).
input_form( [remove|X],   [request(playlist_del_specific),
			    answer(index(C)) ] ):-
	lexsem(X,C),
	sem_sort(C,index).

input_form( [delete|X],   [request(playlist_del_specific),
			    answer(index(C)) ] ):-
	lexsem(X,C),
	sem_sort(C,index).

input_form( [remove,a,song],   request(playlist_del_specific) ).
	  
input_form( S, request(vol_up) ) :-
	S = [increase,the,volume];
	S = [increase].

input_form( S , request(vol_down) ) :-
	S = [decrease,the,volume];
	S = [lower,the,volume];
	S = [lower];
	S = [decrease].



%%%%%  Answers  %%%%%
%input_form( X,            answer(index(X)) ):-            sem_sort(X,index).
input_form(N, answer(index(C))):-
	lexsem(N, C),
	sem_sort(C, index).


%input_form( Station,      answer(station(Station)) ):-    sem_sort(Station,station).
input_form( Station, answer(station(C))):-
	lexsem(Station,C),
	sem_sort(C,station).

%input_form( Group,        answer(group(Group)) ):-        sem_sort(Group,group).
input_form( Group,        answer(group(C)) ):-
	lexsem(Group,C),
	sem_sort(C,group).


%input_form( Playlist,     answer(playlist(Playlist)) ):-  sem_sort(Playlist,playlist).
input_form( Playlist,     answer(playlist(C)) ):-
	lexsem(Playlist,C),
	sem_sort(C,playlist).


%%input_form( [Year],       answer(year(Year)) ):-          sem_sort(Year,year).
%input_form( SongRadio,    answer(item(SongRadio)) ):-     sem_sort(SongRadio,item).
input_form(Item, answer(item(C))):-
	lexsem(Item,C),
	sem_sort(C,item).



%input_form( Album,        answer(album(Album)) ):-        sem_sort(Album,album).
input_form( Album,        answer(album(C)) ):-
	lexsem(Album,C),
	sem_sort(C,album).

%input_form( Station,      answer(station(IP)) ):-
% 	longNum(Station,IP),
% 	sem_sort(IP,station).

input_form( Station,      answer(station(C)) ):-
	lexsem(Station,C),
	sem_sort(C,station).

%%%%%  Questions to DB  %%%%%

input_form( [what,album],          ask(A^albums_by_artist(A)) ).
input_form( [search,albums],     ask(A^albums_by_artist(A)) ).
input_form( [current,song],  ask(X^current_song(X)) ).


input_form( [who,made,the,album], ask(A^artists_album(A)) ).
input_form( [who,made,the,song],   ask(A^artists_song(A)) ).
input_form( [what,search,path], ask(A^path(A)) ).

%%% f�r mer explicit input
input_form( [who,made,the,song|Song],  [ask(A^artists_song(A)),answer(item(C))] ):-
	lexsem(Song,C),
   	sem_sort(C,item).


input_form( [who,made,the,album|Album], [ask(A^artists_album(A)),answer(album(C))] ):-
	lexsem(Album,C),
   	sem_sort(C,album).

%%% mer generellt
input_form( [who,wrote|Song],  [ask(A^artists_song(A)),answer(item(C))] ):-
	lexsem(Song,C),
   	sem_sort(C,item).
input_form( [who,made|Song],    [ask(A^artists_song(A)),answer(item(C))] ):-
	lexsem(Song,C),
   	sem_sort(C,item).
input_form( [who,wrote|Album], [ask(A^artists_album(A)),answer(album(C))] ):-
	lexsem(Album,C),
   	sem_sort(C,album).
   
input_form( [who,made|Album],   [ask(A^artists_album(A)),answer(album(C))] ):-	
	lexsem(Album,C),
   	sem_sort(C,album).

input_form( [what,songs],           ask(Songs^songs_by_artist(Songs)) ).
input_form( [xxxxxd], ask(X^what_to_play(X)) ).
%%% input_form( [vilka,grupper],           ask(Groups^all_groups(Groups)) ).



/*

Kommande predikat...
  
input_form( [med,Group],  answer(group(Group)) ):- sem_sort(Group,group).
input_form( [n�gonting,med], request(find_group) ).

*/

/*----------------------------------------------------------------------
     yn_answer( ?YN )
----------------------------------------------------------------------*/

yn_answer(A):-
	A = 'yes';
	A = 'no'.


/*----------------------------------------------------------------------
     lexsem( ?Word, ?Concept )
     -- Lexical semantics
----------------------------------------------------------------------*/

% use semantics as surface forms (only possible for english)
lexsem( Word, Concept ):-
	synset( Words, Concept ),
	member( Word, Words ).



%index
synset( [[next]], next).
synset( [[previous]], previous).
synset( [[one]], 1).
synset( [[two]], 2).
synset( [[three]], 3).
synset( [[four]], 4).
synset( [[five]], 5).
synset( [[six]], 6).
synset( [[seven]], 7).
synset( [[eight]], 8).
synset( [[nine]], 9).
synset( [[ten]], 10).
synset( [[eleven]],11).
synset( [[twelve]],12).
synset( [[thirteen]],13).
%album
synset( [[the,immaculate,collection]], the_immaculate_collection ).
%group
synset( [[marvin,gaye]], marvin_gaye ).
synset( [[atomic,swing]], atomic_swing ).
synset( [[madonna]], madonna ).
synset( [[enigma]], enigma ).
synset( [[europe]], europe ).
synset( [[garbage]], garbage ).
synset( [[jam],[the,jam]], jam ).
synset( [[kate,bush]],kate_bush).
synset( [[lee,morgan]],lee_morgan).
synset( [[massive_attack]],massive_attack).
synset( [[morlocks]],morlocks).
synset( [[mr,vegas]],mr_vegas).
synset( [[mudhoney]],mudhoney).
synset( [[nitzer,ebb]],nitzer_ebb).
synset( [[pain]],pain).
synset( [[pet,shop,boys]],pet_shop_boys).
synset( [[pixies],[the,pixies]],pixies).
synset( [[prodigy]],prodigy).
synset( [[project,pitchfork]],project_pitchfork).
synset( [[stephen, simmonds]],stephen_simmonds).
synset( [[the,ark],[ark]],ark).
synset( [[trance,dance]],trance_dance).
synset([[vacuum]],vacuum).
synset([[v,n,v,nation],[vnv,nation]],vnv_nation).
synset([[ace,of,base]],ace_of_base).
synset([[beborn,beton]],beborn_beton).
synset([[clash],[the,clash]],clash).
synset([[covenant]],covenant).
synset([[creeps],[the,creeps]],creeps).
synset([[cure],[the,cure]],cure).
synset([[eagle,eye,cherry]],eagle_eye_cherry).
%item
synset([[all,that,she,wants]],all_that_she_wants ).
synset([[stone,me,into,the,groove]],stone_me_into_the_groove).
synset([[another,world]],another_world ).
synset([[deeper,than,the,usual,feeling]],deeper_than_the_usual_feeling ).
synset([[london,calling]], london_calling).
synset([[should,i,stay,or,should,i,go]],should_i_stay_or_should_i_go ).
synset([[dead,stars]],dead_stars ).
synset([[figurehead]], figurehead).
synset([[leviathan]], leviathan).
synset([[like,tears,in,rain]], like_tears_in_rain).
synset([[stalker]], stalker).
synset([[oh,i,like,it]], oh_i_like_it).
synset([[friday,im,in,love]], friday_im_in_love).
synset([[save,tonight]], save_tonight).
synset([[sadness]], sadness).
synset([[the,final,countdown]], the_final_countdown ).
synset([[i,think,im,paranoid]], i_think_im_paranoid ).
synset([[in,the,city]], in_the_city).
synset([[time,for,truth]], time_for_truth).
synset([[the,man,with,the,child,in,his,eyes]], the_man_with_the_child_in_his_eyes).
synset([[totem,pole]], totem_pole).
synset([[like,a,prayer]], like_a_prayer).
synset([[lucky,star]], lucky_star).
synset([[material,girl]], material_girl).
synset([[if,i,should,die,tonight]], if_i_should_die_tonight).
synset([[angel]], angel).
synset([[sly]], sly).
synset([[teardrop]], teardrop).
synset([[ars,magica]], ars_magica).
synset([[razors,through,flesh]], razors_through_flesh).
synset([[sex,by,force]], sex_by_force ).
synset([[heads,high]], heads_high).
synset([[latest,news]], latest_news).
synset([[good,enough]], good_enough).
synset([[thorn]], thorn).
synset([[let,beauty,loose]],let_beauty_loose ).
synset([[eleanor,rigby]], eleanor_rigby).
synset([[suburbia]], suburbia).
synset([[west,end,girls]], west_end_girls).
synset([[debaser]], debaser).
synset([[poison]], poison).
synset([[existence]], existence).
synset([[tears,never,dry]], tears_never_dry).
synset([[it,takes,a,fool,to,remain,sane]], it_takes_a_fool_to_remain_sane).
synset([[youre,gonna,get,it]], youre_gonna_get_it).
synset([[i,breathe]], i_breathe).
synset([[darkangel]], darkangel).
synset([[legion]], legion).
synset([[rubicon]], rubicon).
synset([[standing]], standing).
%station
synset([[digital,gunfire]],'http://129.16.159.166:8000').
synset([[rant,radio]],'http://130.240.207.88:9090').
synset([[chat,radio]],'http://chatradio.myftp.org:10010' ).
%playlist
synset([[_,dot,m,three,u]],[a,punkt,mptreu]).





















