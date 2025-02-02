%%%
%%% Knowledge representation langauge used in the KB
%%% Kinds, types, properties, relations, defaults, and iz_a.
%%%

:- public iz_a/2, kind_of/2.
:- public kind/1, leaf_kind/1.
:- public property_value/3, related/3.
:- public process_kind_hierarchy/0.
:- public property_type/3, relation_type/3.
:- public kind_lub/3, kind_glb/3.
:- public implies_relation/2, inverse_relation/2.
:- external declare_value/3, default_value/3, declare_related/3, symmetric/1.

:- dynamic(superkind_array/2).


%% test_file( ?Test, ?Filename) is semidet.
%
% Test File.
%
test_file(integrity(_), "Ontology/integrity_checks").



%=autodoc
%% nonvar_ref( ?V) is semidet.
%
% Nonvar Ref.
%
nonvar_ref(V):- atomic(V),!.
nonvar_ref(V):- nonvar(V), V='#'(_).


:- randomizable declared_kind/2.

%%%
%%% iz_a
%%% Tests for what entities are of what kinds.
%%%

%% iz_a(?Object, ?Kind)
%  Object is of kind Kind.
%  Kinds are simple atoms, and exist in a lattice with entity at the me.

%iz_a(Object, entity) :-
%   var(Object),
%   throw(error(enumerating_entities)).
iz_a(Object, Kind) :-
   var(Object),
   var(Kind),
   throw(error("iz_a/2 called with neither argument instantiated")).
% This is needed to prevent iz_a(4, entity) from failing, which gets
% generated by what questions that sometimes have answers that aren't
% objects with kinds.
iz_a(X, entity) :-
   (number(X) ; string(X) ; is_list(X)),
   !.
iz_a(Object, Kind) :- atom(Object),(var(Kind);atom(Kind)),atom_concat('unknown_',Kind,Object).

iz_a(Object, Kind) :-
   nonvar_ref(Object),
   assertion(valid_kind(Kind), "Invalid kind"),
   is_a_aux(Object, ImmediateKind),
   superkind_array(ImmediateKind, Supers),
   array_member(Kind, Supers).
iz_a(Object, Kind) :-
   var(Object),
   assertion(valid_kind(Kind), "Invalid kind"),
   subkind_array(Kind, Subs),
   array_member(Sub, Subs),
   is_a_aux(Object, Sub).



%=autodoc
%% is_a_aux( ?Object, +Kind) is semidet.
%
% If Is A A Aux.
%
is_a_aux(Object, Kind) :-
   /remote_control/Object/kind/Kind.
is_a_aux(Object, Kind) :-
   \+ /remote_control/Object/kind,
   declared_kind(Object, Kind).

%% base_kind(+Object, -Kind)
%  Kind is the most specific type for Object
%  (technically a most specific type, since there might be more than one).
base_kind(Object, Kind) :-
   nonvar_ref(Object),
   is_a_aux(Object, Kind).

%%%
%%% Kinds and the kind hierarchy
%%%



%=autodoc
%% valid_kind( ?Kind) is semidet.
%
% Valid Kind.
%
valid_kind(Kind) :-
   var(Kind),
   !.
valid_kind(Kind) :-
   nonvar_ref(Kind),
   kind(Kind).
valid_kind(number).
valid_kind(string).
valid_kind(_TODO).



%=autodoc
%% kind_of( ?ARG1, ?K) is semidet.
%
% Kind Of.
%
kind_of(K, K).
kind_of(Sub, Super) :-
   nonvar_ref(Sub),
   superkind_array(Sub, Supers),
   array_member(Super, Supers).
kind_of(Sub, Super) :-
   nonvar_ref(Super),
   var(Sub),
   subkind_array(Super, Subs),
   array_member(Sub, Subs).



%=autodoc
%% subkind_of( ?Sub, ?Super) is semidet.
%
% Subkind Of.
%
subkind_of(Sub, Super) :-
   kind_of(Sub, Super),
   Sub \= Super.

:- public immediate_superkind_of/2.



%=autodoc
%% immediate_superkind_of( ?K, ?Sub) is semidet.
%
% Immediate Superkind Of.
%
immediate_superkind_of(K, Sub) :-
   immediate_kind_of(Sub, K).



%=autodoc
%% superkinds( +Kind, +Superkinds) is semidet.
%
% Superkinds.
%
superkinds(Kind, Superkinds) :-
   nonvar_ref(Kind),
   topological_sort([Kind], immediate_kind_of, Superkinds).



%=autodoc
%% subkinds( +Kind, +Subkinds) is semidet.
%
% Subkinds.
%
subkinds(Kind, Subkinds) :-
   nonvar_ref(Kind),
   topological_sort([Kind], immediate_superkind_of, Subkinds).



%=autodoc
%% superkind_array( ?Kind, ?Array) is semidet.
%
% Superkind Array.
%
superkind_array(Kind, Array) :-
   call_with_step_limit(10000, superkinds(Kind, List)),
   list_to_array(List, Array),
   asserta( ( $global::superkind_array(Kind, Array) :- ! ) ),
   % Don't even think about trying to reexecute this.
   !.

:- dynamic(subkind_array/2).



%=autodoc
%% subkind_array( ?Kind, ?Array) is semidet.
%
% Subkind Array.
%
subkind_array(Kind, Array) :-
   call_with_step_limit(10000, subkinds(Kind, List)),
   list_to_array(List, Array),
   asserta( ( $global::subkind_array(Kind, Array) :- ! ) ),
   % Don't even think about trying to reexecute this
   !.

% This version handles multiple LUBs, but then it turned out the hierarchy doesn't currently have multiple lubs.
% lub(Kind1, Kind2, LUB) :-
%    nonvar_ref(Kind1),
%    nonvar_ref(Kind2),
%    superkind_array(Kind1, A1),
%    superkind_array(Kind2, A2),
%    lub_not_including(A1, A2, LUB, []).

% lub_not_including(A1, A2, LUB, AlreadyFound) :-
%    array_member(Candidate, A1),
%    array_member(Candidate, A2),
%    \+ (member(Previous, AlreadyFound), kind_of(Previous, Candidate)),
%    !,
%    (LUB = Candidate ; lub_not_including(A1, A2, LUB, [Candidate | AlreadyFound])).



%=autodoc
%% kind_lub( +Kind1, +Kind2, ?LUB) is semidet.
%
% Kind Lub.
%
kind_lub(Kind1, Kind2, LUB) :-
   nonvar_ref(Kind1),
   nonvar_ref(Kind2),
   superkind_array(Kind1, A1),
   superkind_array(Kind2, A2),
   array_member(LUB, A1),
   array_member(LUB, A2),
   !.



%=autodoc
%% kind_glb( +Kind1, +Kind2, ?GLB) is semidet.
%
% Kind Glb.
%
kind_glb(Kind1, Kind2, GLB) :-
   nonvar_ref(Kind1),
   nonvar_ref(Kind2),
   subkind_array(Kind1, A1),
   subkind_array(Kind2, A2),
   array_member(GLB, A1),
   array_member(GLB, A2),
   !.

%%%
%%% Types
%%% This is a kluge, similar to the one in Java and C# that distinguish
%%% between types and classes.  We essentially want everything in the KB
%%% to be described in terms of kinds.
%%%
%%% The one exception is that some properties have types like string
%%% or number and iz_a doesn't understand strings and numbers to be
%%% kinds.  So when checking the type of a property, we need a richer
%%% notion of types than the kind system above.  Hence "types" as an
%%% adjunct to kinds.
%%%
%%% Arguably, we should just change iz_a to thing that number is a kind.
%%% The two arguments against that are that (1) it adds more special cases
%%% to iz_a, and slows it down a little.  More importantly, (2), with iz_a
%%% the way it is now, you can always call it with a variable for its first
%%% argument and a kind as its second, and it will start enumerating objects
%%% of that kind.  We don't want to any code that tries to enumerate all the
%%% integers, nor do we want iz_a to word for enumerating objects for most
%%% kinds but not all kinds (too dblushous).
%%%
%%% Note: the one exception to the behavior of iz_a is that it's been hacked
%%% to accept strings and numbers as entities because the parser just really
%%% needs that.
%%%

%% is_type(?Object, ?Type)
%  Object is of type Type.
%  Types are a super-set of kinds.
is_type(Object, number) :-
   number(Object), !.
is_type(Object, string) :-
   string(Object), !.
is_type(Object, List) :-
   is_list(List),
   member(Object, List).
is_type(Object, kind) :-
   kind(Object).
is_type(Object, Kind) :- compound(Object),Object='#'(Var),Var=Kind.
is_type(Object, kind_of(Kind)) :-
   kind_of(Object, Kind).
is_type(Object, subkind_of(Kind)) :-
   subkind_of(Object, Kind).
is_type(Object, Kind) :-
   atom_or_var(Kind),
   iz_a(Object, Kind).


%%%
%%% Properties
%%%

%% property_type(+Property, ?ObjectType, ?ValueType)
%  Property applies to objects of type ObjectType and its values are of type ValueType.

%% property_nondefault_value(?Object, ?Property, ?Value)
%  Object has this property value explicitly declared, rather than inferred.
property_nondefault_value(Object, Property, Value) :-
  clause(t(Property, Object, Value), G), without_backchain(G).

asserted_t(P,X,Y):- property_nondefault_value(X,P,Y).

without_backchain(true).
without_backchain((X,Y)):- !, without_backchain(X), without_backchain(Y).
without_backchain(getvar(X,Y)):- !, getvar(X,Y).

%% property_value(?Object, ?Property, ?Value)
%  Object has this value for this property.
/*
t(Property, Object, Value) :- 
  nonvar_ref(Property),  !, 
  lookup_property_value(Object, Property, Value).
*/

%% t( ?Pred, ?Arg1, ?Arg2) is semidet.
%
% True Structure.
%

t(Property, Object, Value) :- 
  var(Property), (nonvar(Object); nonvar(Value)),
 (nonvar(Object) -> iz_a(Object, Kind) ; true),
 (nonvar(Value) -> iz_a(Value, ValueType) ; true),
  property_type(Property, Kind, ValueType),
  t(Property, Object, Value).
  %lookup_property_value(Object, Property, Value).



%% unique_answer( ?Value, ?Condition) is semidet.
%
% Unique Answer.
%
unique_answer(Value, t(Property, Object, Value)) :- 
  var(Value), 
  nonvar_ref(Object), 
  nonvar_ref(Property).


%% lookup_property_value( ?Object, ?Property, ?Value) is semidet.
%
% Lookup Property Value.
%

lookup_property_value(Object, Property, Value) :-
  t(Property, Object, Value).
lookup_property_value(Object, Property, Value) :-
   nonvar_ref(Object),
  \+t(Property, Object, _), 
   iz_a(Object, Kind),
   default_value(Kind, Property, Value).

%% valid_property_value(?Property, ?Value)
%  True if Value is a valid value for Property.
valid_property_value(P, V) :-
   property_type(P, _OType, VType),
   is_type(V, VType).

%%%
%%% Relations
%%%

%% relation_type(+Relation, ?ObjectType, ?RelatumType)
%  Relation relates objects of type ObjectType to objects of type RelatumType

%% related_nondefault(?Object, ?Relation, ?Relatum)
%  Object and Relatum are related by Relation through an explicit declaration.
related_nondefault(Object, Relation, Relatum) :-
   decendant_relation(D, Relation),
   related_nondefault_aux(Object, D, Relatum).



%=autodoc
%% related_nondefault_aux( ?Object, ?D, ?Relatum) is semidet.
%
% Related Nondefault Aux.
%
related_nondefault_aux(Object, D, Relatum) :-
   declare_related(Object, D, Relatum).
related_nondefault_aux(Object, D, Relatum) :-
   symmetric(D),
   declare_related(Relatum, D, Object).

%% related(?Object, ?Relation, ?Relatum)
%  Object and Relatum are related by Relation.
t(Relation, Object, Relatum) :-  
  /remote_control/relations/Object/Relation/Relatum.
t(Relation, Object, Relatum) :-
   % This relation is canonically stored as its inverse
   inverse_relation(Relation, Inverse) *-> t(Inverse, Relatum, Object);
   % This relation has no inverse or is the canonical form.
   related_nondefault(Object, Relation, Relatum).
t(Relation, Object, Relatum) :- 
  var(Relation), 
  declare_related(Object, D, Relatum), 
  decendant_relation(D, Relation).


%=autodoc
%% decendant_relation( ?ARG1, ?R) is semidet.
%
% Decendant Relation.
%
decendant_relation(R, R).
decendant_relation(D, R) :-
   implies_relation(I, R),
   decendant_relation(D, I).



%=autodoc
%% ancestor_relation( ?ARG1, ?R) is semidet.
%
% Ancestor Relation.
%
ancestor_relation(R,R).
ancestor_relation(A, R) :-
   implies_relation(R, I),
   ancestor_relation(A, I).
