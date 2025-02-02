:-module(parser_lgp, 
 [
  test_lgp/0,
  test_lgp/1,
  test_lgp/2,
  test_lgp/1,
  test_lgp_parse1_broken/0,
  test_lgp_parse2/0,  
  lgp_stream/2,
  text_to_lgp_pos/2,
  text_to_lgp_sents/2,
  text_to_lgp_segs/2,
  lgp_parse/2]).

:- set_module(class(library)).
:- set_module(base(system)).
:- use_module(library(logicmoo_utils)).
:- use_module(library(logicmoo_nlu/parser_penn_trees)).
:- use_module(library(logicmoo_nlu/parser_tokenize)).
:- use_module(library(logicmoo_nlu/parser_spacy)).

:- dynamic(tmp:existing_lgp_stream/3).
:- volatile(tmp:existing_lgp_stream/3).
lgp_stream(In,Out):- tmp:existing_lgp_stream(_,In,Out),!,clear_lgp_pending(Out).
lgp_stream(In,Out):-
  process_create(path('link-parser'), ['-verbosity=0','-graphics=0','-morphology=1','-walls=1','-constituents=1'],
    [ stdin(pipe(In)),stdout(pipe(Out)), stderr(null), process(FFid)]),
  assert(tmp:existing_lgp_stream(FFid,In,Out)),
  writeln(In,'Test 1 2 3'),
  clear_lgp_pending(Out).

clear_lgp_pending(Out):- read_pending_codes(Out,Codes,[]),dmsg(clear_lgp_pending=Codes).

tokenize_lgp_string(Text,Str):- 
  parser_tokenize:into_acetext(Text,String),
  tokenize_atom(String,Toks),
  atomics_to_string(Toks,' ',Str),!.

lgp_parse(Text, Lines) :-
  tokenize_lgp_string(Text,String),
  sformat(S,'echo ~q | link-parser -verbosity=0 -graphics=0 -morphology=0 -walls=0 -constituents=1 ',[String]),
  nop(writeln(S)),
    process_create(path(bash), ['-c', S], [ stdout(pipe(Out))]),!,
  read_lgp_lines(Out, Lines).

lgp_parse(Text, Lines) :-
  tokenize_lgp_string(Text,String),
  lgp_stream(In,Out),
  format(In,'~w\n',[String]),
  read_lgp_lines(Out, Lines),!.

test_lgp_parse1_broken :-
 Text = "Can the can do the Can Can?",
  lgp_stream(In,Out),
  format(In,'~w\n',[Text]),
  read_lgp_lines(Out, Lines),
  pprint_ecp_cmt(yellow,test_lgp_parse1=Lines).

test_lgp_parse2 :-
  Text = "Can the can do the Can Can?",
  lgp_parse(Text,Lines),
  pprint_ecp_cmt(yellow,test_lgp_parse2=Lines).

test_lgp_parse3 :-
  Text = "Can the can do the Can Can?",
  text_to_lgp_pos(Text,Lines),
  pprint_ecp_cmt(yellow,test_lgp_parse2=Lines).

read_lgp_lines(Out, Result) :-
  read_line_to_string(Out, StringIn),
  read_lgp_lines(StringIn, Out, Lines),
  into_lgp_result(Lines,Result).

into_lgp_result(Lines,Result):- sub_string(Lines,B,1,_,'(') -> B>2, sub_string(Lines,B,_,0,After),!,into_lgp_result(After,Result).
%into_lgp_result(Lines,Result):- sub_string(Lines,B,_,_,'\nBye.\n'), sub_string(Lines,0,B,_,After),!,string(After)=Result.
into_lgp_result(Lines,Result):- sub_string(Lines,_,_, A,')\n\n')-> A>0, sub_string(Lines,0,_,A,After),!,into_lgp_result(After,Result).
into_lgp_result(Lines,Result):- string(Lines)=Result,!.

read_lgp_lines(end_of_file, _, "") :- !.
read_lgp_lines(StringIn, Out, AllCodes) :-  
  read_line_to_string(Out, Line2),
  read_lgp_lines(Line2, Out, Lines),
  atomics_to_string([StringIn,'\n',Lines],AllCodes).

   
lgp_pos_info(Text,PosW2s,Info,LExpr):-
  text_to_lgp_sents(Text,LExpr),
  tree_to_lexical_segs(LExpr,SegsF),
  segs_retain_w2(SegsF,Info,PosW2s),!.
  
text_to_lgp_pos(Text,PosW2s):- lgp_pos_info(Text,PosW2s0,_Info,_LExpr),guess_pretty(PosW2s0),!,PosW2s=PosW2s0.

text_to_lgp_segs(Text,Segs):-
  text_to_lgp_tree(Text,LExpr),
  tree_to_lexical_segs(LExpr,Segs).

text_to_lgp_sents(Text,Sent):-
  text_to_lgp_segs(Text,Segs),!,
  lgp_segs_to_sentences(Segs,Sent),!.

lgp_segs_to_sentences(Segs,sentence(0,W2,Info)):-
  segs_retain_w2(Segs,Info,W2).

text_to_lgp_tree(Text,LExpr):-
  lgp_parse(Text, String),
  nop(dmsg(lgp_parse=String)),
  lxpr_to_list(String, LExpr0),
  nop(print_tree(lgp=LExpr0)),
  correct_lgp_tree(LExpr0,LExpr).

is_upper_lgp_letters_atom(S):- atom(S),upcase_atom(S,S), \+ downcase_atom(S,S).

correct_lgp_tree(I,O):- correct_lgp_tree('LGP',I,O).

correct_lgp_tree(P,LExpr,LExprO):- atom(LExpr), correct_lgp_atom(P,LExpr,LExprM),!,
  (LExpr==LExprM-> LExpr=LExprO ; correct_lgp_tree(P,LExprM,LExprO)).
correct_lgp_tree(P,[S|LExpr],LExprO):- select(E,[S|LExpr],LExprM),unused_lgp(E),!,correct_lgp_tree(P,LExprM,LExprO).
correct_lgp_tree(_,[S|LExpr],[S|LExprO]):- is_upper_lgp_letters_atom(S), !, maplist(correct_lgp_tree(S),LExpr,LExprO).
correct_lgp_tree(_,LExpr,LExpr).

unused_lgp('{\'}').
unused_lgp('{!}').
unused_lgp('}').
unused_lgp('{').

correct_lgp_atom(S,A,O):- \+ atom(A),!,correct_lgp_tree(S,A,O).
correct_lgp_atom(S,A,O):- correct_lgp_atom0(S,A,M),correct_lgp_atom1(S,M,O).
%correct_lgp_atom(S,A,[UP,WordO]):- atomic_list_concat([Word,POS],'.',A),atomic_list_concat([S,POS],'-',U),upcase_atom(U,UP),correct_lgp_sub_atom(POS,Word,WordO).
correct_lgp_atom0(_,A,[UP,WordO]):- atomic_list_concat([Word,POS],'.',A),Word\=='',POS\=='',upcase_atom(POS,UP0),atomic_list_concat([UP0,'w'],'-',UP),correct_lgp_sub_atom(POS,Word,WordO).
correct_lgp_atom0(PT,A,[UP,WordO]):- atomic_list_concat([PT,'w'],'-',UP),correct_lgp_sub_atom(PT,A,WordO).

correct_lgp_atom1(_,['S-w','.'],['.','.']):-!.
correct_lgp_atom1(_,O,O).

correct_lgp_sub_atom(POS,Word,WordO):- unused_lgp(X),atomic_list_concat([W1,W2|Ws],X,Word),atomic_list_concat([W1,W2|Ws],'',WordM),WordM\=='',correct_lgp_sub_atom(POS,WordM,WordO).
correct_lgp_sub_atom(_POS,Word,Word).

:- if( \+ getenv('keep_going','-k')).
:- use_module(library(editline)).
:- add_history((call(make),call(test_lgp1))).
:- endif.

baseKB:regression_test:- test_lgp(1,X),!,test_lgp(X).
baseKB:sanity_test:- make, forall(test_lgp(1,X),test_lgp(X)).
baseKB:feature_test:- test_lgp.

test_lgp0:- 
  Txt = "PERSON1 asks : Hey , what 's going on XVAR. < p >. PERSON2 said : Not a whole lot . . < p >. PERSON2 said : I 'm looking forward to the weekend , though . . < p >. PERSON1 asks : Do you have any big plans XVAR. < p >. PERSON2 said : Yes . . < p >. PERSON2 said : I 'm going to Wrigley Field on Saturday . . < p >. PERSON1 asks : Aren 't the Cubs out of town XVAR. < p >. PERSON2 said : Yes , but there 's a big concert at Wrigley this weekend . . < p >. PERSON1 said : Oh nice . . < p >. PERSON1 asks : Who 's playing XVAR. < p >. PERSON2 said : Pearl Jam is headlining the Saturday night show . . < p >. PERSON1 said : Wow , Pearl Jam . . < p >. PERSON1 said : I remeber when I got their first CD , Ten , at the record store at Harlem and Irving Plaza . . < p >. PERSON2 said : Oh right . . < p >. PERSON2 said : I remember that record store . . < p >. PERSON1 said : It was called Rolling Stone , and they went out of business many years ago . . < p >. PERSON2 said : Oh that 's too bad . . < p >. PERSON2 said : I really loved taking the bus to Harlem and Irving and visiting that store . . < p >. PERSON1 said : Me too . . < p >. PERSON1 said : We did n't have the internet back then and had to discover new music the hard way . . < p >. PERSON2 said : Haha yes . . < p >. PERSON2 said : I remember discovering ' ' Nirvana before they got famous . . < p >. PERSON1 said : Those were the good old days . . < p >. PERSON2 said : Yes they were . . < p >. PERSON2 said : I need to dig up my old Sony disc player and pop in an old CD . . < p >. PERSON1 asks : Where did the time go XVAR. < p >. PERSON1 said : Pearl Jam is 25 years old already . . < p >. PERSON2 said : It seems like only yesterday that the grunge music movement took over . . < p >. PERSON1 said : Right . . < p >. PERSON1 said : I bet everyone at the concert will be in their forty 's . . < p >. PERSON2 said : No doubt . . < p >. PERSON2 said : Well , I hope you have a great time at the concert . . < p > .",
  test_lgp(Txt),
  ttyflush,writeln(('\n test_lgp0.')),!.

test_lgp1:- 
  %Txt = "Rydell used his straw to stir the foam and ice remaining at the bottom of his tall plastic cup, as though he were hoping to find a secret prize.",
  Txt = "The Norwegian dude lives happily in the first house.",
  test_lgp(Txt),
  ttyflush,writeln(('\n test_lgp1.')),!.
test_lgp2:- 
  Txt = "Rydell used his straw to stir the foam and ice remaining at the bottom of his tall plastic cup, as though he were hoping to find a secret prize.",
  %Txt = "The Norwegian dude lives happily in the first house.",
  test_lgp(Txt),
  ttyflush,writeln(('\n test_lgp2.')),!.

test_lgp:- 
  Txt = "Rydell was a big quiet Tennessean with a sad shy grin, cheap sunglasses, and a walkie-talkie screwed permanently into one ear.",
  test_lgp(Txt),
  ttyflush,writeln(('\n test_lgp.')),!,
  fail.
test_lgp:- forall(test_lgp(X),test_lgp(X)).

test_1lgp(Text):- 
  format('~N?- ~p.~n',[test_lgp(Text)]),
  text_to_lgp_tree(Text,W),
  print_tree(W),
  !.

test_lgp(N):- number(N),!, forall(test_lgp(N,X),test_1lgp(X)). 
test_lgp(X):- test_lgp(_,X),nop(lex_info(X)).

test_lgp(_,X):- nonvar(X), !, once(test_1lgp(X)).

test_lgp(1,".\nThe Norwegian lives in the first house.\n.").

test_lgp(1,"Rydell used his straw to stir the foam and ice remaining at the bottom of his tall plastic cup, as though he were hoping to find a secret prize.").


test_lgp(2,Each):- test_lgp(3,Atom),atomic_list_concat(List,'\n',Atom), member(Each,List).

test_lgp(3,
'There are 5 houses with five different owners.
 These five owners drink a certain type of beverage, smoke a certain brand of cigar and keep a certain pet.
 No owners have the same pet, smoke the same brand of cigar or drink the same beverage.
 The man who smokes Blends has a neighbor who drinks water.
 A red cat fastly jumped onto the table which is in the kitchen of the house.
 After Slitscan, Laney heard about another job from Rydell, the night security man at the Chateau.
 Rydell was a big quiet Tennessean with a sad shy grin, cheap sunglasses, and a walkie-talkie screwed permanently into one ear.
 Concrete beams overhead had been hand-painted to vaguely resemble blond oak.
 The chairs, like the rest of the furniture in the Chateau\'s lobby, were oversized to the extent that whoever sat in them seemed built to a smaller scale.
 Rydell used his straw to stir the foam and ice remaining at the bottom of his tall plastic cup, as though he were hoping to find a secret prize.
 A book called, "A little tribute to Gibson".
 "You look like the cat that swallowed the canary, " he said, giving her a puzzled look.').


test_lgp(4,".
The Brit lives in the red house.
The Swede keeps dogs as pets.
The Dane drinks tea.
The green house is on the immediate left of the white house.
The green house's owner drinks coffee.
The owner who smokes Pall Mall rears birds.
The owner of the yellow house smokes Dunhill.
The owner living in the center house drinks milk.
The Norwegian lives in the first house.
The owner who smokes Blends lives next to the one who keeps cats.
The owner who keeps the horse lives next to the one who smokes Dunhills.
The owner who smokes Bluemasters drinks beer.
The German smokes Prince.
The Norwegian lives next to the blue house.
The owner who smokes Blends lives next to the one who drinks water.").

:- add_history(test_lgp).
:- fixup_exports.

