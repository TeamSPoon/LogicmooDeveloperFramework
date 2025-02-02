%%%
%%%                  Noun Phrases
%%%




%% test_file( ?TestName, -Filename) is semidet.
%
% Test File.
%
test_file(generate(np, _), "NL/np_tests").
test_file(complete(np, _), "NL/np_tests").
test_file(parse(np, _), "NL/np_tests").

:- indexical selectional_constraints=[].

:- discontiguous nnp//6.


%% autocomplete_kinds( ?Kind) is semidet.
%
% Autocomplete Kinds.
%
autocomplete_kinds(Kind):- leaf_kind(Kind), Kind \== kind, (\+ \+ iz_a(_,Kind)),  subkinds(abstract,X), \+ member(Kind,X).
autocomplete_kinds(person).



%% kind_noun_s( ?X, +Kind, +Singular, ?A, ?B) is semidet.
%
% Kind Noun Supplimental.
%
kind_noun_s(X, Kind, Singular, [A|S], B) :-
    ( (\+ var(A), \+ var(X)) -> true; (var(Kind) -> autocomplete_kinds(Kind) ; true)),
    kind_noun(Kind, Singular, [A|S], B),
    %Kind\==kind,    
    log(v(kind_noun(Kind, singular,A,B))).


%% impose_selectional_constraint( ?Var, ?Type) is semidet.
%
% Impose Selectional Constraint.
%
impose_selectional_constraint(Var, Type) :-
   bind(selectional_constraints, [Var:Type | $selectional_constraints]).




%% selectional_constraint( ?Var, ?Type) is semidet.
%
% Selectional Constraint.
%
selectional_constraint(Var, Type) :-
   memberchk(Var:Type, $selectional_constraints),
   !.
selectional_constraint(_, entity).

%:- randomizable nnp//6.

%np( ((X^LFIn)^LFOut), _Case, _Agreement, GapInOut, GapInOut, S, E) :- noun_phrase(_SO, X, LFIn, LFOut,S,E).
np_chat( Meaning, Case, Agreement, GapIn, GapOut, S, E) :- nnp0(_X, Meaning, Case, Agreement, GapIn, GapOut, S, E).

  %(nonvar(X)->trace;true),
nnp0(X, Meaning, Case, Agreement, GapIn, GapOut, S, E):- nnp(X,Meaning, Case, Agreement, GapIn, GapOut, S, E).

nnp0(X, ((X^LF)^(of_np(X,Subj),LF)), _Case, _Agreement, _, nogap, S, E) :- call(parser_chat80:subj(Subj,_Agmt,_Type,S,E,[],[])).

%% nnp( X, ?Meaning, ?Case, ?Agreement, +GapIn, -GapOut)
%
%  Noun phrases

% Gaps
nnp( X, (X^S)^S, _C, _Agreement, np( X), nogap) -->
   [ ].


% GENERATE ONLY
% "a KIND" from unbound variables with declared discourse_variables as types
nnp( X, (X^S)^S, _, third:singular, Gap, Gap) -->    
  ( {var(X)}  ,
    theTextM1(a), 
    {discourse_variable_type(X, Kind)}, 
    kind_noun_s(X, Kind, singular)).

% Pronouns
nnp(_X, NP, Case, Agreement, Gap, Gap) -->
   pronoun(Case, Agreement, NP).

% Demonstrative pronouns
nnp( X, (X^S)^S, _Case, third:singular, Gap, Gap) -->  
  ( {var(X)}  ,
    theTextM1(Demonstrative), 
    { input_from_player, 
      demonstrative_pronoun(Demonstrative), 
      /perception/mouse_selection:X }).

% Proper names
nnp( X, (X^S)^S, Case, third:Number, Gap, Gap) -->
   { \+ bound_discourse_variable(X) },
   proper_name(X, Number),
   opt_genitive(Case).

% PARSE ONLY
nnp( X, (X^S)^S, Case, third:Number, Gap, Gap) -->
   { \+ bound_discourse_variable(X) },
   { input_from_player },  % filter for parse mode
   proper_name_without_the(X, Number),
   opt_genitive(Case).




%% opt_genitive( ?ARG1) is semidet.
%
% Opt Genitive.
%
opt_genitive(subject) --> [].
opt_genitive(object) --> [].
opt_genitive(genitive)-->theTextM(['\'', s]).

% Possessive constructions (parse only right now).
nnp( X, (X^S)^S, _, third:Number, Gap, Gap) -->
   not_generating_or_completing,
   possessive_np(X, Number).

:- public not_generating_or_completing/2, not_completing/3.



%% not_generating_or_completing( +IN1, +In) is semidet.
%
% Not Generating Or Completing.
%
not_generating_or_completing(In, In) :-
   nonvar(In).
   


%% not_completing( ?LF, ?Number, ?ARG3) is semidet.
%
% Not Completing.
%
not_completing(LF, _, _) :-
   nonvar(LF),
   !.
not_completing(_, In, In) :-
   nonvar(In).
   
:- dynamic(kind_noun//2).




%% possessive_np( ?ARG1, ?Number) is semidet.
%
% Possessive Noun Phrase.
%
possessive_np(X, Number) -->  
  ( theTextM1(your)  ,
    kind_noun_s(X, Kind, Number), 
    {iz_a(X, Kind), t(owner, $addressee, X)}).

possessive_np(X, Number) -->  
  ( theTextM1(my)  ,
    kind_noun_s(X, Kind, Number), 
    { iz_a(X, Kind), 
      possessive_pronoun_referrent($speaker, Owner), 
      t(owner, Owner, X) }).

possessive_np(X, Number) -->  
  ( proper_name(Owner, singular)  ,
    theTextM(['\'', s]), 
    kind_noun_s(X, Kind, Number), 
    {iz_a(X, Kind), t(owner, Owner, X)}).



%% possessive_pronoun_referrent( ?ARG1, ?Number) is semidet.
%
% Possessive Pronoun Referrent.
%
possessive_pronoun_referrent($user, $pc) :- !.
possessive_pronoun_referrent(X, X).

% PARSE/COMPLETE ONLY
% "a KIND" from unbound variables with declared types
nnp( X, LF, _, third:singular, Gap, Gap) -->  
  ( {var(LF)}  ,
    theTextM1(a), 
    kind_noun_s(X, Kind, singular), 
    {LF=(X^S)^(S, iz_a(X, Kind))}).

% PARSE ONLY
% "the NOUN"
nnp( X, (X^S)^S, _C, third:singular, Gap, Gap) --> %{trace},
   [ the ],
   { var(X),
     input_from_player},	% filter for parsing
   kind_noun_s(X, Kind, singular),
   { resolve_definite_description(X, (nop(parse_only([the_noun])),iz_a(X, Kind))) }.

% PARSE ONLY
% "NOUN" (not grammatical English but common in IF text 
nnp( X, (X^S)^S, _C, third:singular, Gap, Gap) -->
   { var(X),
     input_from_player},	% filter for parsing
   kind_noun_s(X, Kind, singular),
   { resolve_definite_description(X, (nop(parse_only([noun])),iz_a(X, Kind))) }.

% GENERATE ONLY
% "the NOUN"
nnp( X, (X^S)^S, _C, third:singular, Gap, Gap) -->
    { nonvar(X), 
     % If it has a proper name or a bound variable, then don't use this rule.
     \+ proper_name(X, _),
     base_kind(X, Kind) },
   [the], % fail,
   kind_noun_s(X, Kind, singular).

% COMPLETE ONLY
% "the NOUN"
nnp( X, (X^S)^S, _C, third:singular, Gap, Gap) -->
   % If we're generating (nonvar(X)) rather than completing (var(X)),
   % don't generate something that has a proper name.
   [the],
   { var(X),
     %input_from_player,
     \+ bound_discourse_variable(X) },
   kind_noun_s(X, Kind, singular),
   { leaf_kind(Kind),
     object_matching_selectional_constraint(X, Kind) }.

% COMPLETE ONLY
% "the NOUN"
nnp( X, (X^S)^S, _C, third:singular, Gap, Gap) -->
   % If we're generating (nonvar(X)) rather than completing (var(X)),
   % don't generate something that has a proper name.
   [the],
   { var(X),
     input_from_player,
     \+ bound_discourse_variable(X) },
   kind_noun_s(X, Kind, singular),
   {  leaf_kind(Kind),
     (X = Kind) }.




%% object_matching_selectional_constraint( ?X, +Kind) is semidet.
%
% Object Matching Selectional Constraint.
%
object_matching_selectional_constraint(X, Kind) :-
   selectional_constraint(X, ConstraintKind),
   kind_of(Kind, ConstraintKind),
   iz_a(X, Kind).

% GENERATE ONLY
% Fixed strings.
nnp( _, (String^S)^S, _, _, Gap, Gap) -->  
  {string(String)}, theTextM1(String).

% GENERATE ONLY
% Numbers.
nnp( _, (Number^S)^S, _, _, Gap, Gap) -->  
  {number(Number)}, theTextM1(Number).


% kind_noun_s(X, Kind, singular)--> kind_noun(Kind, singular), {log(kind_noun(Kind, singular))}.

%% resolve_definite_description( ?Object, +Constraint) is semidet.
%
% Resolve Definite Description.
%
resolve_definite_description(Object, Constraint):-
  limit(4,resolve_definite_description0(Object, Constraint)),
  log(ap(resolve_definite_description(Object, Constraint))).

resolve_definite_description0(X, Constraint) :-
   nonvar(X),
   !,
   Constraint.
resolve_definite_description0(Object, iz_a(Object, Kind)) :-
   kind_of(Kind, module),
   !,
   iz_a(Object, Kind).
resolve_definite_description0(Object, Constraint) :-
   % This rule will fail in the test suite b/c the global environment has no metaverseobject.
   \+ running_tests,
   % Pick the nearest one, if it's something that nearest works on.
   nearest(Object, Constraint),
   !.
resolve_definite_description0(_Object, Constraint) :-
   % Punt, and choose whatever Prolog gives us first.
   Constraint.


%% property_value_nnp( X,  ?Prop, ?Value) is semidet.
%
% Realizing property values Noun Phrase
%
property_value_np(_Property, Value)-->theTextM1(Value).

