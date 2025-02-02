/*
 _________________________________________________________________________
|       Copyright (C) 1982                                               |
|                                                                         |
|       David Warren,                                                     |
|               SRI International, 333 Ravenswood Ave., Menlo Park,       |
|               California 94025, USA;                                    |
|                                                                         |
|       Fernando Pereira,                                                 |
|               Dept. of Architecture, University of Edinburgh,           |
|               20 Chambers St., Edinburgh EH1 1JZ, Scotland              |
|                                                                         |
|       This program may Be used, copied, altered or included in other    |
|       programs only for academic purposes and provided that the         |
|       authorship of the initial program is aknowledged.                 |
|       Use for commercial purposes without the previous written          |
|       agreement of the authors is forbidden.                            |
|_________________________________________________________________________|

*/

:- op(400, xfy, &).
% :- op(300, fx, '`'  ).


commbine(if-then,_,_,LHSB,RHSB,LHSB=>RHSB).
commbine(true-if,_,_,LHSB,RHSB,RHSB=>LHSB).
commbine(Preds,_,_,LHSB,RHSB,cond_pred80(Preds,LHSB,RHSB)).

clausify80(question80(V0, P),OUT) :- 
  clausify80_qa(V0,P,V,B),!,
  OUT = (answer80(V):-B).

clausify80(imp80(U,Ve,P),OUT) :- !,
  clausify80_qa([],P,V,B),!,
  OUT = (run80(U,Ve,V):-B).


clausify80(assertion80(P),OUT) :- 
  clausify80_qa([],P,V,B),!,
  OUT = (answer80(V):-B).
clausify80(P,OUT) :- 
  clausify80_qa([],P,V,B),!,
  OUT = (run80(V):-B).
clausify80((S1,S2),(G1,G2)):- !, clausify80(S1,G1), clausify80(S2,G2).
clausify80(P,error_in_clausify80(P)):- nop(dumpST),!,fail.

clausify80_qa(V0,P,V,BO):- 
 %print_tree_nl(p=P),
 clausify80_qab(V0,P,V,B),
 %print_tree_nl(in=B),
 code_smell(B,BO),!,
 reguess_vars(V,B,BO,_VO).
 
%reguess_vars(V,BO,VO):-
reguess_vars(Vs,B,BO,Vs):- B==BO,!.
reguess_vars(Vs,_B,BO,Bs):-
  % print_tree_nl(out=BO),
  term_variables(Vs+BO,Bs).
  

code_smell(B,B):- !.
code_smell(B,B):- var(B),!.
code_smell(^(V,B),BO):- V==[],!,code_smell(B,BO).
code_smell((A,B),BO):- !, code_sniff(A,B,BO).
code_smell(B,B).

code_sniff(A,B,BO):- A == true,!,code_smell(B,BO).
code_sniff(B,A,BO):- A == true,!,code_smell(B,BO).
code_sniff(P,setOf(A:_,B,L),setOf(AVs,Es^BOO,L)):-  
  term_variables(P,Vs),
  push_pull_variables(A,Vs,[L],AVs),
  code_smell(B,BO),
  code_sniff(P,BO,BOO),
  term_variables(BOO,Ys),term_variables(AVs,Xs),remove_each_eq(Ys,Xs,Es).
code_sniff(P,(Q,B),BO):- 
  code_sniff(P,Q,PQ),
  code_sniff(PQ,B,BO).
code_sniff(A,B,(A,B)):- \+ contains_setOf(A), \+ contains_setOf(B),!.
code_sniff(P,^(A,B),^(A,BO)):- !, code_sniff(P,B,BO).
code_sniff(A,BB,(A,BB)).

contains_setOf(B):-sub_term(E,B),compound(E),E=setOf(_,_,_).

push_pull_variables(A,[],[],A):-!.
push_pull_variables(A,[],[L|LL],AVs):- subst(A,L,[],AVs),!,push_pull_variables(A,[],LL,AVs),!.
push_pull_variables(A,[V|Vs],L,AVs):- contains_var(V,A), !, push_pull_variables(A,Vs,L,AVs).
push_pull_variables(A,[V|Vs],L,AVs):- push_pull_variables(A:V,Vs,L,AVs).
 

clausify80_qab(V0,cond_pred(IF,LHSP,RHSP),V2,OUT) :- 
 clausify80_qa(V0,LHSP,V1,LHSB),
 clausify80_qa(V1,RHSP,V2,RHSB),
 commbine(IF,LHSP,RHSP,LHSB,RHSB,OUT),!.

clausify80_qab(V0,P,V,B):-
   quantify(P, Quants, [], R0),
   split_quants(question80(V0), Quants, HQuants, [], BQuants, []),
   chain_apply(BQuants, R0, R1),
   head_vars(HQuants, B, R1, V, V0).



:- export(clausify80/2).
:- system:import(clausify80/2).

quantify(quantS(Det, X, Head, Pred, Args, Y), Above, Right, true) :-
   debug_chat80_if_fail((close_tree(Pred, P2),
   quantify_args(Args, AQuants, P1),
   split_quants(Det, AQuants, Above, [Q|Right], Below, []),
   pre_apply(Head, Det, X, P1, P2, Y, Below, Q))).

quantify(conj(Conj, LPred, LArgs, RPred, RArgs), Up, Up, P) :-
   debug_chat80_if_fail((close_tree(LPred, LP0),
   quantify_args(LArgs, LQs, LP1),
   chain_apply(LQs,(LP0, LP1), LP),
   close_tree(RPred, RP0),
   quantify_args(RArgs, RQs, RP1),
   chain_apply(RQs,(RP0, RP1), RP),
   conj_apply(Conj, LP, RP, P))).

quantify(pred(Subj, Op, Head, Args), Above, Right, P) :-
   debug_chat80_if_fail((quantify(Subj, SQuants, [], P0),
   quantify_args(Args, AQuants, P1),
   split_quants(Op, AQuants, Up, Right, Here, []),
   append(SQuants, Up, Above),
   chain_apply(Here,(P0, Head, P1), P2),
   op_apply(Op, P2, P))).

quantify('`'(P), Q, Q, P).

quantify(P&Q, Above, Right,(S, T)) :- !,
   quantify(Q, Right0, Right, T),
   quantify(P, Above, Right0, S).

quantify(P, Q, Q, P).


head_vars([], P, P, L, L0) :-
   strip_types(L0, L).

head_vars([Quant|Quants],(P, R0), R, [X|V], V0) :-
   extract_var(Quant, P, X),
   head_vars(Quants, R0, R, V, V0).


strip_types([], []).

strip_types([_-X|L0], [X|L]) :-
   strip_types(L0, L).


extract_var(quantU(_, _-X, P, _-X), P, X).


chain_apply(Q0, P0, P) :-
   sort_quants(Q0, Q, []),
   chain_apply0(Q, P0, P).


chain_apply0([], P, P).

chain_apply0([Q|Quants], P0, P) :-
   chain_apply0(Quants, P0, P1),
   det_apply(Q, P1, P).


quantify_args([], [], true).

quantify_args([Arg|Args], Quants,Out) :- !,
   quantify_args(Args, Quants0, Q),
   quantify(Arg, Quants, Quants0, P),
   Out = (P, Q).

pre_apply('`'(Head), set(I), X, P1, P2, Y, Quants, Quant) :-
   debug_chat80_if_fail((indices(Quants, I, Indices, RestQ),
   chain_apply(RestQ,(Head, P1), P),
   setify(Indices, X,(P, P2), Y, Quant))).

pre_apply('`'(Head), Det, X, P1, P2, Y, Quants, Out) :- 
 
 (unit_det(Det);
   index_det(Det, _)),!,
 debug_chat80_if_fail(( chain_apply(Quants,(Head, P1), P))),
   Out = quantU(Det, X,(P, P2), Y).

pre_apply('`'(Head), Det, X, P1, P2, Y, Quants, Out) :- !,
 debug_chat80_if_fail((
   chain_apply(Quants,(Head, P1), P))),
   Out = quantU(Det, X,(P, P2), Y).

pre_apply(apply80(F, P0), Det, X, P1, P2, Y,
      Quants0, Out) :-
  debug_chat80_if_fail(( but_last(Quants0, quantU(lambdaV, Z, P0, Z), Quants),
   chain_apply(Quants,(F, P1), P3))),
   Out = quantU(Det, X,(P3, P2), Y).

pre_apply(aggr(F, Value, L, Head, Pred), Det, X, P1, P2, Y, Quants, Out) :- 
 debug_chat80_if_fail((
   close_tree(Pred, R),
   complete_aggr(L, Head,(R, P1), Quants, P, Range, Domain))),
 Out =
   quantU(Det, X,
            (S^(setOf(Range:Domain, P, S),
                aggregate80(F, S, Value)), P2), Y).


but_last([X|L0], Y, L) :-
   but_last0(L0, X, Y, L).


but_last0([], X, X, []).

but_last0([X|L0], Y, Z, [Y|L]) :-
   but_last0(L0, X, Z, L).


close_tree(T, P) :-
   debug_chat80_if_fail((quantify(T, Q, [], P0),
   chain_apply(Q, P0, P))).


meta_apply('`'(G), R, Q, G, R, Q).

meta_apply(apply80(F,(R, P)), R, Q0, F, true, Q) :-
   but_last(Q0, quantU(lambdaV, Z, P, Z), Q).


indices([], _, [], []).

indices([Q|Quants], I, [Q|Indices], Rest) :-
   open_quant(Q, Det, _, _, _),
   index_det(Det, I),
   indices(Quants, I, Indices, Rest).

indices([Q|Quants], I, Indices, [Q|Rest]) :-
   open_quant(Q, Det, _, _, _),
   unit_det(Det),
   indices(Quants, I, Indices, Rest).


setify([], Type-X, P, Y, quantU(set_ov, Type-([]:X), true:P, Y)).

setify([Index|Indices], X, P, Y, Quant) :-
   pipe(Index, Indices, X, P, Y, Quant).


pipe(quantU(wh_det3(_Kind,_, Z), Z, P1, Z),
      Indices, X, P0, Y, quantU(det(a), X, P, Y)) :-
   chain_apply(Indices,(P0, P1), P).

pipe(quantU(index(_), _-Z, P0, _-Z), Indices, Type-X, P, Y,
      quantU(set_ov, Type-([Z|IndexV]:X),(P0, P1):P, Y)) :-
   index_vars(Indices, IndexV, P1).


index_vars([], [], true).

index_vars([quantU(index(_), _-X, P0, _-X)|Indices],
      [X|IndexV],(P0, P)) :-
   index_vars(Indices, IndexV, P).


complete_aggr([Att, X], '`'(G), R, Quants,(P, R), Att, X) :-
   chain_apply(Quants, G, P).

complete_aggr([Att], Head, R0, Quants0,(P1, P2, R), Att, X) :-
   meta_apply(Head, R0, Quants0, G, R, Quants),
   set_vars(Quants, X, Rest, P2),
   chain_apply(Rest, G, P1).

complete_aggr([], '`'(G), R, [quantU(set_ov, _-(X:Att), S:T, _)],
  (G, R, S, T), Att, X).


set_vars([quantU(set_ov, _-(I:X), P:Q, _-X)], [X|I], [],(P, Q)).

set_vars([], [], [], true).

set_vars([Q|Qs], [I|Is], R,(P, Ps)) :-
   open_quant(Q, Det, X, P, Y),
   set_var(Det, X, Y, I), !,
   set_vars(Qs, Is, R, Ps).

set_vars([Q|Qs], I, [Q|R], P) :-
   set_vars(Qs, I, R, P).


set_var(Det, _-X, _-X, X) :-
   setifiable(Det).


sort_quants([], L, L).

sort_quants([Q|Qs], S, S0) :-
   open_quant(Q, Det, _, _, _),
   split_quants(Det, Qs, A, [], B, []),
   sort_quants(A, S, [Q|S1]),
   sort_quants(B, S1, S0).


split_quants(_, [], A, A, B, B).

split_quants(Det0, [Quant|Quants], Above, Above0, Below, Below0) :-
   compare_dets(Det0, Quant, Above, Above1, Below, Below1),
   split_quants(Det0, Quants, Above1, Above0, Below1, Below0).


compare_dets(Det0, Q, [quantU(Det, X, P, Y)|Above], Above, Below, Below) :-
   open_quant(Q, Det1, X, P, Y),
   governs_lex(Det1, Det0), !,
   bubble(Det0, Det1, Det).

compare_dets(Det0, Q0, Above, Above, [Q|Below], Below) :-
   lower(Det0, Q0, Q).


open_quant(quantU(Det, X, P, Y), Det, X, P, Y).


% =================================================================
% Determiner Properties

index_det(index(I), I).
index_det(wh_det3(_Kind,I, _), I).

unit_det(set_ov).
unit_det(lambdaV).
unit_det(quantV(_, _)).
unit_det(det(_)).
unit_det(question80(_)).
unit_det(identityQ(_Modalz)).
unit_det(voidQ(_ModalQ)).
unit_det(voidQ).
unit_det(notP(_Modalz)).
unit_det(generic).
unit_det(wh_det(_Kind,_)).
unit_det(proportion(_)).
% unit_det(some).

det_apply(quantU(Det, Type-X, P, _-Y), Q0, Q) :-
   apply80(Det, Type, X, P, Y, Q0, Q).


apply80(generic, _, X, P, X, Q, X^(P, Q)).

apply80(proportion(_Type-V), _, X, P, Y, Q,
      S^(setOf(X, P, S),
         N^(numberof(Y,(one_of(S, Y), Q), N),
            M^(card(S, M), ratio(N, M, V))))).

apply80(identityQ(Modalz), _, X, P, X, Q, PQ):- maybe_modalize(scope, Modalz, (P, Q), PQ).

apply80(voidQ(_ModalQ), _, X, P, X, Q, X^(P, Q)).
apply80(voidQ, _, X, P, X, Q, X^(P, Q)).

apply80(set_ov, _, Index:X, P0, S, Q, S^(P, Q)) :-
   apply_set(Index, X, P0, S, P).

apply80(wh_det(Type,Type-X), Type, X, P, X, Q,(P, Q)).

apply80(index(_), _, X, P, X, Q, X^(P, Q)).

apply80(quantV(Op, N), Type, X, P, X, Q, R) :-
   value80(N, Type, Y),
   quant_op(Op, Z, Y, numberof(X,(P, Q), Z), R).

apply80(det(Det), A, X, P, Y, Q, R) :- !,
   apply80(Det, A, X, P, Y, Q, R).

apply80((Det), _, X, P, Y, Q, R) :-
   apply0(Det, X, P, Y, Q, R).


apply0(Some, X, P, X, Q, X^(P, Q)) :-
   some_word(Some).

apply0(All, X, P, X, Q, \+X^(P, NQ)) :- 
   all_word(All),negate_inward(Q,NQ).

apply0(no, X, P, X, Q, \+X^(P, Q)).
apply0(notall, X, P, X, Q, X^(P, NQ)) :- negate_inward(Q,NQ).

quant_op(same, X, X, P, P). %:- X = Y.
quant_op(Op, X, Y, P, X^(P, F)) :-
   measure_op(Op, X, Y, F).
/*

quant_op4(notP(Modalz)+more, X, Y, X=<Y).
quant_op4(notP(Modalz)+less, X, Y, X>=Y).
quant_op4(less, X, Y, X<Y).
quant_op4(more, X, Y, X>Y).
*/

value80(wh(Type-X), Type, X).
value80((X), _, X):- number(X).

all_word(all).
all_word(every).
all_word(each).
all_word(any).

some_word(a).
some_word(the(sg)).
some_word(some).
some_word(Many):- many_most_few(Many).

many_most_few(many).
many_most_few(most).
many_most_few(much).
many_most_few(more).
many_most_few(few).
many_most_few(little).

apply_set([], X, true:P, S, setOf(X, P, S)).

apply_set([I|Is], X, Range:P, S,
   setOf([I|Is]:V,(Range, setOf(X, P, V)), S)).


governs_lex(Det, set(J)) :-
   index_det(Det, I),
   I \== J.

governs_lex(Det0, Det) :-
   index_det(Det0, _),
 ( index_det(Det, _);
   Det=det(_);
   Det=quantV(_, _)).

governs_lex(_, voidQ(_ModalQ)).
governs_lex(_, voidQ).
governs_lex(_, lambdaV).
governs_lex(_, identityQ(_Modalz)).
governs_lex(det(each), question80([_|_])).
governs_lex(det(each), det(each)).
governs_lex(det(any), notP(_Modalz)).

governs_lex(quantV(same, wh(_)), Det) :-
   weak(Det).

governs_lex(det(Strong), Det) :-
   strong0(Strong),
   weak(Det).


strong(det(Det)) :-
   strong0(Det).


strong0(each).
strong0(any).


weak(det(Det)) :-
   weak_det(Det).
weak(quantV(_, _)).
weak(index(_)).
weak(wh_det3(_Kind,_, _)).
weak(set(_)).
weak(wh_det(_Kind,_)).
weak(generic).
weak(proportion(_)).

weak_det(no).
weak_det(a).
weak_det(all).
weak_det(some).
weak_det(every).
weak_det(the(sg)).
weak_det(notall).


lower(question80(_), Q, quantU(det(a), X, P, Y)) :-
   open_quant(Q, det(any), X, P, Y), !.
lower(_, Q, Q).

setifiable(generic).
setifiable(det(a)).
setifiable(det(all)).


% =================================================================
% Operators (currently, identity, negation and 'and')

%op_apply(identityQ(_Modalz), P, P).
%op_apply(notP(Modalz), P, \+P).
op_apply(M,P,PP):- maybe_modalize(scope,M,P,PP).

bubble(notP(_Modalz), det(any), det(every)) :- !.
bubble(_, D, D).

conj_apply(and, P, Q,(P, Q)).
