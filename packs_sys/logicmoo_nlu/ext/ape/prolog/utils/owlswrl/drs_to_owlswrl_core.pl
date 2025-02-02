% This file is part of the Attempto Parsing Engine (APE).
% Copyright 2008-2013, Kaarel Kaljurand <kaljurand@gmail.com>.
%
% The Attempto Parsing Engine (APE) is free software: you can redistribute it and/or modify it
% under the terms of the GNU Lesser General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any later version.
%
% The Attempto Parsing Engine (APE) is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
% PURPOSE. See the GNU Lesser General Public License for more details.
%
% You should have received a copy of the GNU Lesser General Public License along with the Attempto
% Parsing Engine (APE). If not, see http://www.gnu.org/licenses/.


:- module(drs_to_owlswrl_core, [
		condlist_to_dlquery/2,
		condition_oneof/3,
		condlist_axiomlist_with_cheat/3,
		condlist_and/4,
		is_toplevel/3,
		get_entity/3,
		has_dom_for_member/3,
		is_object_with_generalized_quantifier/1,
		dataitem_datavalue_datatypeuri/3
	]).


/** <module> Attempto DRS to OWL 2/SWRL translator

Translate an Attempto DRS into Web Ontology Language (OWL 2),
or if this fails then to Semantic Web Rule Language (SWRL).

If the translation fails then we search for errors by traversing
the respective structure (e.g. implication) again. Note that the error
capture is not completely implemented. Sometimes the translation simply
fails and no explanatory messages are asserted.

@author Kaarel Kaljurand
@version 2013-04-08
@license LGPLv3

*/

:- use_module('../../logger/error_logger', [
		add_error_message/4
	]).

:- use_module(implication_to_swrl, [
		implication_to_swrl/3
	]).

:- use_module(simplify_axiom, [
		simplify_axiom/2
	]).

:- use_module(illegal_conditions, [
		illegal_condition/1,
		illegal_conditions/1
	]).


% Operators used in the DRS.
:- op(400, fx, -).
:- op(500, xfx, =>).
:- op(500, xfx, v).


%% condition_oneof(+Condition:term, -Ref:term, -ObjectOneOf:term) is semidet.
%
% Note that this rule is only called for the top-level DRS conditions.
%
% @param Condition is a DRS (top-level) object-condition
% @param Ref is a discourse referent
% @param ObjectOneOf is OWL's ObjectOneOf construct that corresponds to the condition
%
% @bug Fix comments, we also return genquant/4 now
%
condition_oneof(object(X, Name, countable, na, QType, QNum)-_, X, genquant(X, Name, QType, QNum)) :-
	is_object_with_generalized_quantifier(object(_, Name, countable, na, QType, QNum)-_),
	!.

condition_oneof(object(X, Name, countable, na, _, _)-_, X, 'ObjectOneOf'([nodeID(X)])) :-
	Name \= na.

condition_oneof(object(X, something, dom, na, _, _)-_, X, 'ObjectOneOf'([nodeID(X)])).


%% is_object_with_generalized_quantifier(+Condition:term) is semidet.
%
% Succeeds if the condition is an object-condition with certain QType and QNum arguments.
%
% Note: "Name \= na" is there to reject NP conjunctions.
%
% @param Condition is a DRS condition
%
is_object_with_generalized_quantifier(object(_, Name, countable, na, QType, QNum)-_) :-
	Name \= na,
	(
		QNum > 1
	;
		QNum = 1, QType = exactly
	;
		QNum = 1, QType = leq
	;
		QNum = 1, QType = less
	;
		QNum = 1, QType = greater
	).


%% condlist_axiomlist_with_cheat(+ConditionList:list, +RefList:list, -AxiomList:list) is semidet.
%
% Mapping from the DRS conditions' list to OWL axioms.
%
% @param ConditionList is a list of DRS conditions
% @param RefList is a list of top-level discourse referents
% @param AxiomList is a list of OWL axioms
%
% @bug We first cheat a bit, e.g. in case the DRS consists of
% certain conditions then they are mapped immediately to a
% class assertion. This avoids the anonymous individuals
% that are generated by the general solution.
%
% @bug Also, sentences like "There are exactly 4 continents." are handled here.

% Try to roll up the complete DRS if contains a toplevel predicate with
% a proper name as an argument.
% E.g. John likes a woman.
% E.g. There is a woman that likes John and that owns a cat.
% E.g. John owns at least 2 fast cars.
%
% @tbd "A man owns at least 2 cars that a woman likes."
% i.e. toplevel DRS which does not contain proper names.
% Maybe it's better to do it using the 'there are...' technique.
condlist_axiomlist_with_cheat(
	CondList,
	_RefList,
	[SimplerAxiom]
) :-
	member(predicate(_, _, X1, X2)-_, CondList),
	(named(Name) = X1 ; named(Name) = X2),
	get_entity(named_individual, Name, Individual),
	condlist_and(named(Name), CondList, [], And),
	!,
	simplify_axiom('ClassAssertion'(And, Individual), SimplerAxiom).


% There are exactly 4 continents.
% <= Everything is contained by Universe. Universe contains exactly 4 continents.
% @bug: we shouldn't repeat the SubClassOf axiom, i.e. we could expect the client to contain it already.
% @bug: make 'there are' rules cover more complex DRSs, e.g. 'There are more than 3 rich men.'
% E.g. It is false that there are exactly 4 continents.
condlist_axiomlist_with_cheat(
	CondList,
	_,
	[
		'SubClassOf'(
			owl:'Thing',
			'ObjectSomeValuesFrom'(
				'ObjectInverseOf'(ObjectProperty),
				'ObjectOneOf'([Individual])
			)
		),
		'ClassAssertion'(Class, Individual)
	]
) :-
	there_are_object(CondList, PropertyRestriction, ThereAreObject, Class),
	get_universe(ThereAreObject, ObjectProperty, Individual, PropertyRestriction),
	!.



% @bug Cheating ends here, we call condlist_axiomlist/3
condlist_axiomlist_with_cheat(ConditionList, RefList, AxiomList) :-
	condlist_axiomlist(ConditionList, RefList, AxiomList).


%% condlist_axiomlist(+ConditionList:list, +RefList:list, -AxiomList:list) is semidet.
%
% Mapping from the DRS conditions' list to OWL axioms.
%
% @param ConditionList is a list of DRS conditions
% @param RefList is a list of top-level discourse referents
% @param AxiomList is a list of OWL axioms
%

% ConditionList is empty
condlist_axiomlist([], _, []).

% Condition is successfully mapped to an Axiom
condlist_axiomlist([Condition | ConditionList], RefList, [SimplerAxiom | AxiomList]) :-
	condition_axiom(Condition, RefList, Axiom),
	!,
	simplify_axiom(Axiom, SimplerAxiom),
	condlist_axiomlist(ConditionList, RefList, AxiomList).

% Condition is successfully mapped to a SWRL rule
condlist_axiomlist([Condition | ConditionList], RefList, [Axiom | AxiomList]) :-
	implication_to_swrl(Condition, RefList, Axiom),
	!,
	condlist_axiomlist(ConditionList, RefList, AxiomList).

% BUG: experimental: ignore objects that have a generalized quantifier
condlist_axiomlist([Condition | ConditionList], RefList, AxiomList) :-
	is_object_with_generalized_quantifier(Condition),
	!,
	condlist_axiomlist(ConditionList, RefList, AxiomList).

% A top-level condition that is not supported (e.g. has_part/2)
% is simply ignored, but an error message is asserted.
condlist_axiomlist([Condition | ConditionList], RefList, AxiomList) :-
	illegal_condition(Condition),
	!,
	condlist_axiomlist(ConditionList, RefList, AxiomList).

% If mapping of Condition failed and if the condition
% was an if-then condition then we search for the exact location
% of the error.
% BUG: we should do the same for negation and disjunction
condlist_axiomlist([If => Then | CondList], RefList, AxiomList) :-
	select(object(X, _Value, _, na, _, _)-_, If, CondList1),
	condlist_classlist_err(X, CondList1, RefList),
	condlist_classlist_err(X, Then, RefList),
	!,
	add_error_message(owl, '', '', 'Text could not be translated.'),
	condlist_axiomlist(CondList, RefList, AxiomList).

% If everything fails then set a general error message.
% BUG: Figure out the sentence ID at least.
condlist_axiomlist([_Condition | CondList], RefList, AxiomList) :-
	add_error_message(owl, '', '', 'Text could not be translated.'),
	condlist_axiomlist(CondList, RefList, AxiomList).


%% condition_axiom(+Condition:term, +RefList:list, -Axiom:term) is semidet.
%
% Mapping the DRS conditions to OWL axioms. Note that each top-level
% condition maps to exactly one OWL axiom. This holds for the modified
% DRS where e.g. the relation-conditions have been removed and the implication
% corresponding
% to sentences like "If somebody X writes something Y then X is a writer and
% Y is a writing." have been split into 2 implications, correspoding to:
% Everybody who writes something is a writer." and "Everything that somebody
% writes is a writing."
%
% @param Condition is a DRS condition
% @param RefList is a list of top-level discourse referents
% @param Axiom is an OWL axiom
%

% Sublist
% E.g. John owns at most 2 cars.
condition_axiom(
	[Condition | ConditionList],
	RefList,
	'ClassAssertion'(SubListClass, Individual)
) :-
	condlist_and(D, [Condition | ConditionList], RefList, SubListClass),
	is_toplevel(D, RefList, 'ObjectOneOf'([Individual])).

% Negation.
% E.g. John is not Mary., John does not like a man who owns at most 2 cars.
condition_axiom(
	-Not,
	RefList,
	'ClassAssertion'('ObjectComplementOf'(NotClass), Individual)
) :-
	condlist_and(D, Not, RefList, NotClass),
	is_toplevel(D, RefList, 'ObjectOneOf'([Individual])).

% Disjunction
% E.g. John likes Mary or likes Bill.
condition_axiom(
	Or1 v Or2,
	RefList,
	'ClassAssertion'('ObjectUnionOf'([Or1Class, Or2Class]), Individual)
) :-
	condlist_and(D, Or1, RefList, Or1Class),
	condlist_and(D, Or2, RefList, Or2Class),
	is_toplevel(D, RefList, 'ObjectOneOf'([Individual])).

% object/6 where Count = "dom" or "countable"
% and which is created during preprocessing, e.g.
%
% object(named('John'), man, countable, na, eq, 1)-_
%
condition_axiom(
	object(named(ProperName), Name, Count, na, QType, QNum)-_,
	_,
	'ClassAssertion'(NamedClass, Individual)
) :-
	memberchk(Count, [countable, dom]),
	memberchk(QType, [eq, geq, na]),
	memberchk(QNum, [1, na]),
	get_entity(named_individual, ProperName, Individual),
	get_entity(class, Name, NamedClass).

% object/6 where Count = "dom" or "countable"
% E.g. man ...
% Common nouns are mapped to
% OWL anonymous individuals identified by Ref and typed by Name.
condition_axiom(
	object(Ref, Name, Count, na, QType, QNum)-_,
	_,
	'ClassAssertion'(NamedClass, nodeID(Ref))
) :-
	memberchk(Count, [countable, dom]),
	memberchk(QType, [eq, geq, na]),
	memberchk(QNum, [1, na]),
	get_entity(class, Name, NamedClass).

% Property between an Individual and a Literal (DataProperty).
% E.g.: John's age is 30., John's address is "Poland".
condition_axiom(
	predicate(_, Predicate, Ref, DataItem)-_,
	RefList,
	'DataPropertyAssertion'(DataProperty, Name, '^^'(DataValue, DataTypeUri))
) :-
	is_toplevel(Ref, RefList, 'ObjectOneOf'([Name])),
	get_entity(data_property, Predicate, DataProperty),
	dataitem_datavalue_datatypeuri(DataItem, DataValue, DataTypeUri).

% predicate(_, be, Ref1, Ref2)
%
% The copula-predicate maps to the SameIndividual-axiom.
%
% E.g. John is Mary.
condition_axiom(
	predicate(_, be, Ref1, Ref2)-_,
	RefList,
	'SameIndividual'([Name1, Name2])
) :-
	is_toplevel(Ref1, RefList, 'ObjectOneOf'([Name1])),
	is_toplevel(Ref2, RefList, 'ObjectOneOf'([Name2])).

% predicate(_, _, Ref1, Ref2)
%
% All the remaining predicates map to ObjectPropertyAssertion.
%
% E.g. John likes Mary.
%
condition_axiom(
	predicate(_, Predicate, Ref1, Ref2)-_,
	RefList,
	'ObjectPropertyAssertion'(ObjectProperty, Name1, Name2)
) :-
	Predicate \= be,
	get_entity(object_property, Predicate, ObjectProperty),
	is_toplevel(Ref1, RefList, 'ObjectOneOf'([Name1])),
	is_toplevel(Ref2, RefList, 'ObjectOneOf'([Name2])).

% predicate(_, _, Ref1, Ref2) with generalized quantifier
% E.g. A man owns at least 2 cars.
% BUG: incorrectly handles: A man owns at least 2 cars that a woman likes.
condition_axiom(
	predicate(_, Predicate, Ref1, Ref2)-_,
	RefList,
	'ClassAssertion'(PropertyRestriction, Name1)
) :-
	Predicate \= be,
	is_toplevel(Ref1, RefList, 'ObjectOneOf'([Name1])),
	is_toplevel(Ref2, RefList, genquant(_, Name, QType, QNum)),
	get_entity(class, Name, NamedClass),
	get_entity(object_property, Predicate, ObjectProperty),
	make_restr(QType, QNum, ObjectProperty, NamedClass, PropertyRestriction).

% Implication that maps to a SubObjectProperty-axiom
%
% E.g. If somebody X loves somebody Y then X likes Y.
%
% BUG: add: then-part contains inverse. (Not needed really, but maybe adds readability.)
%
% Note: the chain must not be empty!
condition_axiom(
	If => [predicate(_, Predicate, Ref1, RefN)-_],
	_,
	'SubObjectPropertyOf'('ObjectPropertyChain'(SubObjectPropertyChain), ObjectProperty)
) :-
	Predicate \= be,
	has_dom_for_member(Ref1, If, CondList1),
	is_chain(Ref1, RefN, CondList1, SubObjectPropertyChain),
	SubObjectPropertyChain = [_ | _],
	get_entity(object_property, Predicate, ObjectProperty).

% Implication that maps to a DisjointObjectProperties-axiom
%
% E.g. If somebody X loves somebody Y then it is false that X hates Y.
%
% Note: the chain must contain exactly 1 element.
condition_axiom(
	If => [-[predicate(_, Property2, Ref1, RefN)-_]],
	_,
	'DisjointObjectProperties'([Property1, ObjectProperty])
) :-
	Property2 \= be,
	has_dom_for_member(Ref1, If, CondList1),
	get_entity(object_property, Property2, ObjectProperty),
	is_chain(Ref1, RefN, CondList1, [Property1]).

% Implication that maps to a SubClassOf-axiom
%
% Examples:
%
% Every man is an animal and likes a dog and ...
% Every man who owns a car is a driver.
%
% This is by far the most complicated case to handle.
condition_axiom(
	If => Then,
	RefList,
	'SubClassOf'(IfClass, ThenClass)
) :-
	condlist_if(X, If, RefList, IfClass),
	condlist_and(X, Then, RefList, ThenClass).


%% is_chain(+Ref1:nvar, +RefN:nvar, +CondList:list, -SubObjectPropertyChain:list) is semidet.
%
% @param Ref1 is a discourse referent of the first object in the chain
% @param RefN is a discourse referent of the last object in the chain
% @param CondList is a list of DRS conditions
% @param SubObjectPropertyChain is a list of OWL property descriptions in the chain-order
%
is_chain(Ref, Ref, [], []).

is_chain(Ref1, RefN, CondList, [ObjectProperty | Chain]) :-
	select(predicate(_, Property, Ref1, Tmp)-_, CondList, CondList1),
	Property \= be,
	get_entity(object_property, Property, ObjectProperty),
	has_dom_for_member(Tmp, CondList1, CondList2),
	is_chain(Tmp, RefN, CondList2, Chain).

is_chain(Ref1, RefN, CondList, ['ObjectInverseOf'(ObjectProperty) | Chain]) :-
	select(predicate(_, Property, Tmp, Ref1)-_, CondList, CondList1),
	Property \= be,
	get_entity(object_property, Property, ObjectProperty),
	has_dom_for_member(Tmp, CondList1, CondList2),
	is_chain(Tmp, RefN, CondList2, Chain).


%% has_dom_for_member(+Ref:nvar, +CondListIn:list, -CondListOut:list) is nondet.
%
% Given a discourse referent, selects its corresponding
% object condition, given that it corresponds to an indefinite pronoun
% ('somebody' or 'something') or the noun 'thing'.
%
% @param Ref is a discourse referent
% @param CondListIn is a list of DRS conditions
% @param CondListOut is the remaining list of DRS conditions (after select/3)
%
has_dom_for_member(Ref, CondListIn, CondListOut) :-
	select(object(Ref, Name, Count, na, QType, QNum)-_, CondListIn, CondListOut),
	(
		Name = something, Count = dom
	;
		Name = somebody, Count = countable
	;
		Name = thing, Count = countable, QType = eq, QNum = 1
	).


%% condlist_if(+D:nvar, +CondList:list, +RefList:list, -If:term) is nondet.
%
% Rolling up the IF-box. Before the actual rolling starts we select the
% distinguished variable which can be either a proper name or
% the object/6 variable.
%
% Example (where only a proper name is distinguished):
%
%==
% If there is a protein that activates Met then Met follows a gene.
%==
%
% @param D is a distinguished discourse referent (the "subject" of an if-then sentence)
% @param CondList is a list of DRS conditions in the if-part
% @param RefList is a list of top-level discourse referents
% @param If is an OWL class description which is the left-side element of the resulting SubClassOf-axiom
%
condlist_if(D, CondList, RefList, If) :-
	member(predicate(_, _, X1, X2)-_, CondList),
	(D = X1 ; D = X2),
	is_toplevel(D, RefList, 'ObjectOneOf'([Individual])),
	condlist_and(D, CondList, RefList, 'ObjectOneOf'([Individual]), If).


condlist_if(D, CondListIn, RefList, If) :-
	select(object(D, Name, _, na, QType, QNum)-_, CondListIn, CondListOut),
	get_entity(class, Name, NamedClass),
	(
		QType = eq, QNum = 1
	;
		QType = na, QNum = na
	),
	condlist_and(D, CondListOut, RefList, NamedClass, If).


%% condlist_and(+D:nvar, +CondList:list, +RefList:list, -And:term) is nondet.
%% condlist_and(+D:nvar, +CondList:list, +RefList:list, -Desc:term, -And:term) is nondet.
%
% @param D is a distinguished discourse referent (the "subject" of an if-then sentence)
% @param CondList is a list of DRS conditions (under negation, disjunction, or then-box)
% @param RefList is a list of top-level discourse referents
% @param Desc is an OWL class description to be inserted into the intersection
% @param And is an OWL class description (possibly a named class)
%
condlist_and(D, CondList, RefList, And) :-
	condlist_classlist(D, CondList, RefList, DescriptionList),
	create_intersection(DescriptionList, And).

condlist_and(D, CondList, RefList, Desc, And) :-
	condlist_classlist(D, CondList, RefList, DescriptionList),
	create_intersection([Desc | DescriptionList], And).


%% condlist_classlist(+D:nvar, +CondList:list, +RefList:list, -ClassList:list) is nondet.
%
% Map *all* the conditions in the list to corresponding
% OWL classes, i.e. no condition must be left unmapped.
%
% @param D is a discourse referent
% @param CondList is a list of DRS conditions
% @param RefList is a list of top-level discourse referents
% @param ClassList is a list of OWL class descriptions
%
condlist_classlist(_D, [], _RefList, []).

condlist_classlist(D, CondList, RefList, [And1Class | And2Class]) :-
	select(Condition, CondList, CondList1),
	condlist_class(D, Condition, CondList1, RefList, And1Class, CondList2),
	condlist_classlist(D, CondList2, RefList, And2Class).


%% condlist_classlist_err(+D:nvar, +CondList:list, +RefList:list) is nondet.
%
% These rules are here solely for error capture.
%
% @param D is a discourse referent
% @param CondList is a list of DRS conditions
% @param RefList is a list of top-level discourse referents
%
% @bug This error capture is not complete, e.g. we can't see inside
% embedded DRSs.
%
condlist_classlist_err(_D, [], _RefList) :- !.

condlist_classlist_err(D, CondList, RefList) :-
	select(Condition, CondList, CondList1),
	condlist_class(D, Condition, CondList1, RefList, _, CondList2),
	!,
	condlist_classlist_err(D, CondList2, RefList).

% If condlist_class/5 failed then there must be a problem that
% we want to report.
condlist_classlist_err(_D, CondList, _RefList) :-
	illegal_conditions(CondList).



%% condlist_class(+D:nvar, Condition:term, +CondListIn:list, +RefList:list, +Class:term, -CondListOut:list) is nondet.
%
% Note that we allow inverting the arguments of copula 'be', i.e.
% we consider the following equivalent:
%
%==
% If a man likes somebody that is a person then the person owns a car.
% If a man likes a person that is a somebody then the person owns a car.
%==
%
%==
% If a man is John then the man is a person.
% If John is a man then the man is a person.
%==
%
% This is similar to inverting the arguments of regular verbs, but while
% for regular verbs the Property changes into 'ObjectInverseOf'(PropertyName),
% the copula arguments are simply switched with no trace left behind.
%
% @param D is a discourse referent
% @param Condition is a DRS condition
% @param CondListIn is a list of DRS conditions
% @param RefList is a list of top-level discourse referents
% @param Class is an OWL class description
% @param CondListOut is a list of remaining DRS conditions
%

% Copula ('be') predicate
% Every man is John.
% Every man is a human.
% Every man is something.
% All grass is some food.
% * Every man is at most 3 cars.
condlist_class(D, predicate(_, be, Subj, Obj)-_, CondList, RefList, EmbeddedClass, CondList2) :-
	(
		Subj = D, Obj = NewD
	;
		Obj = D, Subj = NewD
	),
	select_object(NewD, CondList, RefList, NamedClass, QType, QNum, CondList1),
	(
		QType = eq, QNum = 1
	;
		QType = na, QNum = na
	),
	follow_object(NewD, NamedClass, CondList1, RefList, EmbeddedClass, CondList2).

% Regular predicate with reflexive object
% Every man likes himself.
condlist_class(D, predicate(_, Property, D, D)-_, CondList, _RefList, 'ObjectHasSelf'(ObjectProperty), CondList) :-
	Property \= be,
	get_entity(object_property, Property, ObjectProperty).

% Regular predicate with data object
% Every man's age is 20.
condlist_class(D, predicate(_, Property, D, DataItem)-_, CondList, _RefList, 'DataHasValue'(DataProperty, '^^'(DataValue, DataTypeUri)), CondList) :-
	Property \= be,
	get_entity(data_property, Property, DataProperty),
	dataitem_datavalue_datatypeuri(DataItem, DataValue, DataTypeUri).

% Regular predicate with a dist. variable
% Every man likes a woman.
condlist_class(D, predicate(_, PropertyName, D, Obj)-_, CondList, RefList, Class, CondList2) :-
	PropertyName \= be,
	select_object(Obj, CondList, RefList, NamedClass, QType, QNum, CondList1),
	follow_object(Obj, NamedClass, CondList1, RefList, EmbeddedClass, CondList2),
	get_entity(object_property, PropertyName, ObjectProperty),
	make_restr(QType, QNum, ObjectProperty, EmbeddedClass, Class).

% Regular predicate with a dist. variable, inverted case
% Every man is liked by a woman.
condlist_class(D, predicate(_, PropertyName, Subj, D)-_, CondList, RefList, Class, CondList2) :-
	PropertyName \= be,
	select_object(Subj, CondList, RefList, NamedClass, QType, QNum, CondList1),
	follow_object(Subj, NamedClass, CondList1, RefList, EmbeddedClass, CondList2),
	get_entity(object_property, PropertyName, ObjectProperty),
	make_restr(QType, QNum, 'ObjectInverseOf'(ObjectProperty), EmbeddedClass, Class).

% Sublist
% Every man owns at most 2 cars.
condlist_class(D, [Condition | ConditionList], CondList, RefList, SubListClass, CondList) :-
	condlist_and(D, [Condition | ConditionList], RefList, SubListClass).

% Negation
% Every man is not a table.
condlist_class(D, -Not, CondList, RefList, 'ObjectComplementOf'(NotClass), CondList) :-
	condlist_and(D, Not, RefList, NotClass).

% Disjunction
% Every man is policeman or is not a table.
condlist_class(D, Or1 v Or2, CondList, RefList, 'ObjectUnionOf'([Or1Class, Or2Class]), CondList) :-
	condlist_and(D, Or1, RefList, Or1Class),
	condlist_and(D, Or2, RefList, Or2Class).


%% select_object(+D:nvar, +CondListIn:list, +RefList:list, -NamedClass:term, -QType:atom, -QNum:atomic, -CondListOut:list) is nondet.
%
% @param D is a distinguished discourse referent
% @param CondListIn is a list of DRS conditions
% @param RefList is a list of top-level discourse referents
% @param NamedClass is either Class or ObjectOneOf([_])
% @param QType is in {na, eq, geq, leq, greater, less, exactly}
% @param QNum is a positive integer or 'na' (not available)
% @param CondListOut is a list of remaining DRS conditions
%
select_object(D, CondList, RefList, 'ObjectOneOf'([Individual]), eq, 1, CondList) :-
	is_toplevel(D, RefList, 'ObjectOneOf'([Individual])).

select_object(D, CondListIn, _RefList, NamedClass, QType, QNum, CondListOut) :-
	select(object(D, Name, _, na, QType, QNum)-_, CondListIn, CondListOut),
	get_entity(class, Name, NamedClass).


%% follow_object(+D:nvar, +NamedClass:atom, +CondListIn:list, +RefList:list, -Class:term, -CondListOut:list) is semidet.
%% follow_object_(+D:nvar, +CondListIn:list, +RefList:list, -ClassList:list, -CondListOut:list) is semidet.
%
% We first try to build a complete class-list (and consume all the conditions).
%
% 1. If this succeeds then the returned class-list is either empty or not.
% 1.1. In case of an empty class-list, Class is simply a named class.
% 1.2. In case of a non-empty class-list, Class is an intersection with the named class as the first element.
%
% 2. If building the complete class-list fails (i.e. some conditions are not consumed)
% then we try to build just one class description.
% 2.1 If this succeeds then we might be able to build some more, i.e. we call follow_object_/5 recursively
% 2.1.1 If building some more fails then we return the remaining conditions.
% 2.2 If building just one class description fails, then we return the named class.
%
% @param D is a distinguished discourse referent
% @param NamedClass is either Class or ObjectOneOf([_])
% @param CondListIn is a list of DRS conditions
% @param RefList is a list of top-level discourse referents
% @param Class is an OWL class expression 
% @param CondListOut is a list of remaining DRS conditions
%
follow_object(D, NamedClass, CondList, RefList, Class, CondListOut) :-
	follow_object_(D, CondList, RefList, ClassList, CondListOut),
	create_intersection([NamedClass | ClassList], Class).

follow_object_(D, CondList, RefList, ClassListOut, CondListOut) :-
	(
		condlist_classlist(D, CondList, RefList, ClassList)
	->
		ClassListOut = ClassList,
		CondListOut = []
	;
		(
			(
				select(Condition, CondList, CondList1),
				condlist_class(D, Condition, CondList1, RefList, Class1, CondList2)
			)
		->
			(
				follow_object_(D, CondList2, RefList, ClassList2, CondList3)
			->
				ClassListOut = [Class1 | ClassList2],
				CondListOut = CondList3
			;
				ClassListOut = [Class1],
				CondListOut = CondList2
			)
		;
			ClassListOut = [],
			CondListOut = CondList
		)
	).


%% create_intersection(+ClassList:list, -Intersection:term) is det.
%
% Constructs the OWL intersection expression from a given list of class expressions.
% Simplifies the expression by removing owl:Thing if possible.
% owl:Thing is expected to be in the beginning of the list.
%
% @param ClassList is a list of class expressions
% @param Intersection is an OWL intersection expression
%
create_intersection([Class], Class) :- !.

create_intersection([owl:'Thing' | ClassList], Class) :-
	!,
	create_intersection(ClassList, Class).

create_intersection(ClassList, 'ObjectIntersectionOf'(ClassList)).


%% is_toplevel(+Ref:nvar, +RefList:list, -ObjectOneOf:term)
%
% Succeeds if Ref is among the top-level referents (i.e. it corresponds to
% a proper name or to a common noun that is not under negation, disjunction,
% or implication).
%
% @param Ref is a discourse referent
% @param RefList is a list of top-level discourse referents
% @param ObjectOneOf is an OWL ObjectOneOf-class
%
is_toplevel(named(Name), _RefList, 'ObjectOneOf'([Individual])) :-
	!,
	get_entity(named_individual, Name, Individual).

is_toplevel(Ref, RefList, ObjectOneOf) :-
	memberchk(ref_oneof(Ref, ObjectOneOf), RefList).


%% make_restr(+QType:atom, +QNum:atomic, +Property:term, +Class:term, -Restriction:term) is semidet.
%
% @param QType is in {na, eq, geq, leq, greater, less, exactly}
% @param QNum is a positive integer or 'na' (not available)
% @param Property is an OWL property description
% @param Class is an OWL class description
% @param Restriction is an OWL class description built from QType, QNum, Property, and Class
%
make_restr(na, na, Property, Class, 'ObjectSomeValuesFrom'(Property, Class)).
make_restr(eq, 1, Property, Class, 'ObjectSomeValuesFrom'(Property, Class)).
make_restr(geq, 1, Property, Class, 'ObjectSomeValuesFrom'(Property, Class)).
make_restr(eq, QNum, Property, Class, 'ObjectMinCardinality'(QNum, Property, Class)) :-
	integer(QNum),
	QNum > 1.
make_restr(geq, QNum, Property, Class, 'ObjectMinCardinality'(QNum, Property, Class)) :-
	integer(QNum),
	QNum > 1.
make_restr(leq, QNum, Property, Class, 'ObjectMaxCardinality'(QNum, Property, Class)) :-
	integer(QNum).
make_restr(exactly, QNum, Property, Class, 'ObjectExactCardinality'(QNum, Property, Class)) :-
	integer(QNum).
make_restr(less, QNum, Property, Class, 'ObjectMaxCardinality'(Num, Property, Class)) :-
	integer(QNum),
	Num is QNum - 1.
make_restr(greater, QNum, Property, Class, 'ObjectMinCardinality'(Num, Property, Class)) :-
	integer(QNum),
	Num is QNum + 1.


%% get_entity(+iriName:atom, -Individual:term) is semidet.
%% get_entity(+Name:atom, +NS:atom, -Individual:term) is semidet.
%% get_entity(+Name:atom, -Individual:term) is semidet.
%
% @param Name is the name of the individual
% @param NS is a namespace identifier
% @param Individual is a named individual
%
get_entity(class, ThingWord, owl:'Thing') :-
	is_thing_word(ThingWord),
	!.

% Wordform is mapped to a full IRI
get_entity(_Type, iri(Iri), Iri) :-
	atom(Iri),
	!.

% BUG: this is a temporary solution, use iri/1 instead
get_entity(_Type, IriAsAtom, Iri) :-
	atom(IriAsAtom),
	atom_concat('iri|', Iri, IriAsAtom),
	!.

% default namespace
get_entity(Type, Name, Entity) :-
	get_entity(Type, Name, '', Entity).

% given namespace
get_entity(_Type, Name, NS, NS:Name) :-
	atom(Name).


%% is_thing_word
%
%
is_thing_word(something).
is_thing_word(somebody).
is_thing_word(thing).


%% datatype_datatypeuri(+DataType:atom, -DataTypeUri:atom) is semidet.
%
% @param DataType is a DRS datatype, currently in {integer, string, real}
% @param DataTypeUri is the corresponding XMLSchema datatype URI
%
datatype_datatypeuri(integer, 'http://www.w3.org/2001/XMLSchema#integer').
datatype_datatypeuri(string, 'http://www.w3.org/2001/XMLSchema#string').
datatype_datatypeuri(real, 'http://www.w3.org/2001/XMLSchema#double').


%% dataitem_datavalue_datatypeuri(+DataItem:term, -DataValue:term, -DataTypeUri:atom) is semidet.
%
% @param DataItem is an ACE data-item (e.g. int(10), real(3.14), string('Go!'))
% @param DataValue is an ACE data-value (e.g. 10, 3.14, 'Go!')
% @param DataTypeUri is the corresponding XMLSchema datatype URI
%
dataitem_datavalue_datatypeuri(string(DataValue), DataValue, DataTypeUri) :-
	datatype_datatypeuri(string, DataTypeUri).

dataitem_datavalue_datatypeuri(int(DataItem), DataItem, DataTypeUri) :-
	datatype_datatypeuri(integer, DataTypeUri).

dataitem_datavalue_datatypeuri(real(DataItem), DataItem, DataTypeUri) :-
	datatype_datatypeuri(real, DataTypeUri).


%% condlist_to_dlquery(+CondList:term, -ClassExpression:term) is semidet.
%
% Converts a list of DRS conditions into an OWL class expression.
% The DRS must have undergone: drs_to_sdrs, numbervars, drs_to_owldrs.
%
% @param CondList is a list of DRS conditions
% @param ClassExpression is an OWL class expression in OWL FSS (Prolog notation)
%
% Ex: John does not see what?
condlist_to_dlquery([-Conds], ClassExpression) :-
	(
		select(query(QVar, _)-_, Conds, RemainingConds)
	->
		condlist_to_dlquery(QVar, [-RemainingConds], ClassExpression)
	;
		throw(error('Yes/no queries not supported', context(condlist_to_dlquery/2, Conds)))
	),
	!.

condlist_to_dlquery(Conds, ClassExpression) :-
	(
		select(query(QVar, _)-_, Conds, RemainingConds)
	->
		condlist_to_dlquery(QVar, RemainingConds, ClassExpression)
	;
		throw(error('Yes/no queries not supported', context(condlist_to_dlquery/2, Conds)))
	),
	!.

condlist_to_dlquery(Conds, _) :-
	throw(error('Query not supported', context(condlist_to_dlquery/2, Conds))).


%% condlist_to_dlquery(+QVar:nvar, +Conds:list, -ClassExpression:term) is semidet.
%
% Converts a list of DRS conditions into an OWL class expression.
% The DRS must have undergone: drs_to_sdrs, numbervars, drs_to_owldrs.
%
% @param QVar Query variable, e.g. X in query(X, who)
% @param CondList is a list of DRS conditions
% @param ClassExpression is an OWL class expression in OWL FSS (Prolog notation)
%
condlist_to_dlquery(QVar, Conds, ClassExpression) :-
	(
		memberchk(query(Var, Lemma)-Id, Conds)
	->
		throw(error('Queries with multiple query words not supported', context(condlist_to_dlquery/3, query(Var, Lemma)-Id)))
	;
		condlist_and(QVar, Conds, [], ClassExpression)
	).


%% get_universe
%
% Constructs the convention for expressing "there are at least N ..."
%
get_universe(object(X, Noun, NotNamed, na, QType, QNum)-_,
		ObjectProperty, Individual, PropertyRestriction) :-
	is_object_with_generalized_quantifier(object(X, Noun, NotNamed, na, QType, QNum)-_),
	X \= named(_),
	get_entity(class, Noun, Class),
	get_universe(QType, QNum, Class, ObjectProperty, Individual, PropertyRestriction).


get_universe(QType, QNum, Class, ObjectProperty, Individual, PropertyRestriction) :-
	get_entity(object_property, 'contain', ace, ObjectProperty),
	get_entity(named_individual, 'Universe', ace, Individual),
	make_restr(QType, QNum, ObjectProperty, Class, PropertyRestriction).


%% there_are_object
%
% Handles simple DRSs that are derived from sentences:
%
%     [it is false that] there are (at least | at most | more than | ...) N noun .
%
there_are_object([object(X, Noun, NotNamed, na, QType, QNum)-_],
	R, object(X, Noun, NotNamed, na, QType, QNum)-_, R).
there_are_object([[object(X, Noun, NotNamed, na, QType, QNum)-_]],
	R, object(X, Noun, NotNamed, na, QType, QNum)-_, R).
there_are_object([-[object(X, Noun, NotNamed, na, QType, QNum)-_]],
	R, object(X, Noun, NotNamed, na, QType, QNum)-_, 'ObjectComplementOf'(R)).
there_are_object([-[[object(X, Noun, NotNamed, na, QType, QNum)-_]]],
	R, object(X, Noun, NotNamed, na, QType, QNum)-_, 'ObjectComplementOf'(R)).

/*
Generalize there_are_object to support 'there are at least 3 rich men that ...'.
Something like this:

	select(object(X, Noun, NotNamed, na, QType, QNum)-_, CondList, CondListRest),
	is_object_with_generalized_quantifier(object(X, Noun, NotNamed, na, QType, QNum)-_),
	condlist_and(X, CondListRest, RefList, And),
	get_universe(QType, QNum, And, ObjectProperty, Individual, PropertyRestriction),
*/
