/*
 _________________________________________________________________________
|       Copyright (C) 1982                                                |
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

:- dynamic(adv_template_db/4).
:- dynamic(ditrans_lex80/13).
:- dynamic(standard_adj_db/4).
:- thread_local(t_l:current_vv/1).
foc_current_vv(VV):- t_l:current_vv(VV),!.


:- op(450,xfy,((:))).
:- op(400,xfy,((&))).
:- op(300,fx,(('`'))).
:- op(200,xfx,((--))).

must80(M:G):- !, M:must80(G).
must80((G1,G2)):- !, must80(G1), must80(G2).
%must80(G):- \+ current_prolog_flag(debug_chat80,true),!, call(G).
must80(G):- call(G)*->true;(must80_failed(G),fail).

must80_failed(G):- 
  %nop((wdmsg(failed(G)),ignore(on_x_fail(ftrace(G))))),
  \+ (term_variables(G,Vs),G=..[_,_|Vs]),
  
  G \= lf80(_,_),  fail,
  flag(chat80_reports,N,N+1), % N < 1,
  %set_prolog_flag(debug_chat80,false), % so we only get one report
  dmsg(failed(G)),fail,call(G).

% logical form checker for chat80

lf80(_Typ,G):- !,must80(G).
lf80(Conj,G):- compound(Conj), (Conj=(Type1-TypeS)),!,lf80(Type1,lf80(TypeS,G)).
lf80(Type,G):- 
  subst(G,Type,Type0,P),
  must80(P),
  ((var(Type0);var(Type)) -> Type0=Type ; (nop(writeln(Type0=Type)),must80(Type=Type0))).

sub_term_setarg(_,Term,_,_):- \+ compound(Term),!, fail.
sub_term_setarg(Arg, Term, N,Term) :- arg(N, Term, Arg).
sub_term_setarg(X, Term, O1, O2) :- arg(_, Term, Arg), sub_term_setarg(X, Arg, O1, O2).


i_subst(P2,I,O):- duplicate_term(io(I),IO),i_subst(P2,IO),!,IO=io(O).

i_subst(P2,I):- 
  append_term(P2,CCmp,P2_I),
  append_term(P2_I,R,P2_I_O),
  parser_chat80:clause(P2_I_O,Body),sub_term_setarg(Cmp,I,N,Term),
  compound(Cmp),CCmp=Cmp,
  call(Body),
  arg(N,Term,Old),
  Old\=@=R,!,
  nb_setarg(N,Term,R),
  i_subst(P2,I).
i_subst(_,_).


i_sentence(S,(G1,G2)):- compound(S), S= (S1,S2), !, i_sentence(S1,G1), i_sentence(S2,G2).
%i_sentence(S,G):- i_sentence1(S,G).
%i_sentence(S,G):- i_sentence0(S,G).
i_sentence(S,G):- i_sentence2(S,G),!.
%i_sentence(S,G):- i_subst(i_sentence2,S,M),i_subst(i_s,M,G).

%i_sentence1(I,O):- i_sentence2(I,O)*->true;I=O. %i_subst(i_sentence2,I,O).
%i_sentence1(I,O):- i_sentence2(I,O),!.

i_sentence2(q(S),question80([],P)) :- !, i_s(S,P).
i_sentence2(decl(S),assertion80(P)) :- !, i_s(S,P). 
i_sentence2(whq(X,S),question80([X],P)) :- !, i_s(S,P).
%i_sentence2(s(S),s80(P)) :- !, i_s_must(s(S),P). 
i_sentence2(imp(U,Ve,s(_,Verb,VArgs,VMods)),imp80(U,Ve,V,Args)) :-
   must80(i_verb(Verb,V,_,activeV,([]),Slots0,[],transparent)),
   i_verb_args(RefVar,VArgs,[],[],Slots0,Slots,Args,Args0,Up,-0),
   append(Up,VMods,Mods),
   must80(i_verb_mods(RefVar,Mods,_,[],Slots,Args0,Up,+0)),!.
i_sentence2(imp(U,Ve,S),imp80(U,Ve,P,[])) :-  i_s(S,P),!.


i_s(s(Subj,Verb,VArgs,VMods),P):- must80(i_s(s(Subj,Verb,VArgs,VMods),P,[],0)),!.

/*
i_s_must(S,P):- i_sentence(S,P),!.
i_s_must(S,P):- i_s(S,P),!.
i_s_must(s(Subj,Verb,VArgs,VMods),P):- P = failed((s(Subj,Verb,VArgs,VMods))).
*/
i_np(There,Y,quantS(voidQ,X,'`'(true),'`'(is_voidQ(XV,YV,There)),[],Y),[],_,_,XA,XA):- here_there(There),type_x_var(X,XV),type_x_var(Y,YV).
i_np(NP,Y,Q,Up,Id0,Index,XA0,XA) :-
   i_np_head(_Var,NP,Y,Q,Det,Det0,X,Pred,QMods,Slots0,Id0),
   held_arg(XA0,XA,Slots0,Slots,Id0,Id),
   i_np_rest(NP,Det,Det0,X,Pred,QMods,Slots,Up,Id,Index).

i_np_head(_Var,np(_,Kernel,_),Y,
      quantS(Det,T,Head,Pred0,QMods,Y),
      Det,Det0,X,Pred,QMods,Slots,_Id) :-
   lf80(Type,i_np_head0(Kernel,X,T,Det0,Head,Pred0,Pred,Slots)),
   Type-_=Y, Type-_=T.

i_np_rest(np(_,_,Mods),Det,Det0,X,Pred,QMods,Slots,Up,Id,Index) :-
   index_args(Det0,Index,Id,Det,IndexA),
   i_np_mods(Mods,X,Slots,Pred,QMods,Up,Id,IndexA).

held_arg(held_arg(Case,-Id,X),[],S0,S,Id,+Id) :-
   in_slot(S0,Case,X,Id,S,_).
held_arg(XA,XA,S,S,Id,Id).

expand_named(Name,Name):- \+ compound(Name),!.
expand_named(items(And, List),List):- And == and, !.
expand_named(Name,LF):- s80lf(Name,LF),!.
expand_named(Name,Name):- !.

% ?- c88("If an agent A1 touches the chair O2 and A1 is awake then A1 is aware that O2 is existing.").

i_np_head0(Atomic,TypeX,TypeY,IdentityQ,Head,Pred0,Pred,Slots):- \+ compound(Atomic),!,
  i_np_head0(nameOf(_Var,Atomic),TypeX,TypeY,IdentityQ,Head,Pred0,Pred,Slots).
  
% np(3+sg,nameOf(_Var,iran),[])
i_np_head0(nameOf(X,Name,Adjs),Type-X,Type-X,identityQ(_QModal),Head,Pred0,Pred,[]) :- Name == X,
  %ignore(lf80(Type,name_template_LF(Name,Type))),!,
  ignore(must80((i_adjs(Adjs,Type-X,Type-X,_,'`'(true),Head,Pred0,Pred)))),!.

i_np_head0(nameOf(X,Name,Adjs),Type-X,Type-X,identityQ(_QModal),Head,Pred0,Pred,[]) :- 
  (var(Name)->X=Name;true),!,
  ignore(lf80(Type-X,name_template_LF(Name,Type))),
  expand_named(Name,Named),
  ignore(must80((i_adjs(Adjs,Type-X,Type-X,_,'`'(bE(named,X,Named)),Head,Pred0,Pred)))),!.

i_np_head0(nameOf(Var,Name), Type1Name,Type2Name,Ident,True,Pred0,Pred,List) :- !,
  i_np_head0(nameOf(Var,Name,[]), Type1Name,Type2Name,Ident,True,Pred0,Pred,List).

i_np_head0(wh(TypeX_X),TypeX_X,TypeX_X,identityQ(_QModal),'`'(true),Pred,Pred,[]):-!.
% np(3+sg,pronoun(neut),[])
i_np_head0(Else, Type-Name,Type-Name,identityQ(_QModal),'`'(P),Pred,Pred,[]):-  Else \= np_head(_,_,_,_), !,
   lf80(Type,make_qualifiedBy(Name,i_np_head0,Name,Type,Else,P)).

i_np_head0(np_head(Var,Det,Adjs,Noun),TypeX_X,T,Det,Head0,Pred0,Pred,Slots) :-
   i_adjs(Adjs,TypeX_X,T,TypeX_X,Head0,Head,Pred0,Pred),
   i_noun(Noun,TypeX_X,Head,Slots),
   type_x_var(TypeX_X,Var).

i_np_head0(np_head(X,wh_det(_Kind,V),Adjs,Noun),
      Type-X,Type-X,Det,'`'(true),Pred,Pred,
      [slot(prep(of),Type,X,_,comparator)]) :-
   lf80(Type,comparator_LF(Noun,Type,V,Adjs,Det)).

i_np_head0(np_head(X,quantV(Op0,N),Adjs,Noun),
      Type-X,Type-X,voidQ,'`'(P),Pred,Pred,[]) :- 
   measure_LF(Noun,Type,Adjs,Units),
   lf80(Type,pos_conversion_db(N,Op0,Type,V,Op)),
   must80(measure_op(Op,X,V--Units,P)).


i_np_head0(np_head(X,generic,[],Value), Type-X,Type-X,voidQ,
  '`'(bE(same,X,Value)),Pred,Pred,[]):-!.

i_np_head0(np_head(X,Det,Adjs,Noun),TypeX-X,TypeT-T,Det0,Head0,Pred0,Pred,Slots) :- 
  i_np_head1(np_head(X,Det,Adjs,Noun),TypeX-X,TypeT-T,Det0,Head0,Pred0,Pred,Slots).

i_np_head0(Else, Type-X,Type-X,identityQ(_QModal),'`'(P),Pred,Pred,[]):- 
   lf80(Type,make_qualifiedBy(X,i_np_head0,X,Type,Else,P)).

i_np_head1(np_head(X,Det,Adjs,Noun),TypeX-X,TypeT-T,DetO,Head0,Pred0,Pred,Slots):-
   must80(i_adjs(Adjs,TypeX-X,TypeT-T,TypeX-X,Head0,Head,Pred0,Pred)),
   must80(i_noun(Noun,TypeX-X,Head,Slots)),
   xform_det(Det,DetO).

type_x_var(Var,_):- var(Var),!.
type_x_var(_Type-Var,Var).

xform_det(Det,Det):- !.
xform_det(_Det,_DetO):- !.

make_qualifiedBy(Var,PType,Name,Type,Else,P):- qualifiedBy_LF(Var,PType,Name,Type,Else,P).
make_qualifiedBy(Var,_,Name,Type,Else,P):- may_qualify(Else), P = qualifiedBy(Var,Name,Type,Else).
%may_qualify(_):- !,fail.
may_qualify(np_head(_Var,det(each),[],_)):-!,fail.
may_qualify(np_head(_Var,_,[],Act)):- atom(Act),atom_concat('actioned',_,Act), !,fail.
may_qualify(Else):- nop(wdmsg(may_qualify(Else))).

%i_np_mods([],_,[],'`'(true),[],[],_,_).
i_np_mods(Mods,_,[],'`'(true),[],Mods,_,_).
i_np_mods([Mod|Mods],X,Slots0,Pred0,QMods0,Up,Id,Index) :-
   i_np_mod(Mod,X,Slots0,Slots,
            Pred0,Pred,QMods0,QMods,Up0,-Id,Index),
   append(Up0,Mods,Mods0),
   i_np_mods(Mods0,X,Slots,Pred,QMods,Up,+Id,Index).
i_np_mods(Mods,_,[Slot|Slots],'`'(true),QMods,Mods,Id,_) :-
   i_voids_limited([Slot|Slots],QMods,Id).

proper_len(X,X,0):- \+ compound(X),!.
proper_len([_|X],O,N):- proper_len(X,O,M), N is M + 1.

%i_voids_limited(A,_,_):- proper_len(A,_,L),L>10,!,fail.
i_voids_limited(A,B,C):- proper_len(A,P,L),L>8,!,P=[],!,i_voids_limited0(A,B,C).
i_voids_limited(A,B,C):- i_voids_limited0(A,B,C).
%i_voids_limited(A,B,C):- stack_depth(D),D>500,dmsg(stack_depth(D)=i_voids(A,B,C)),!,fail,ignore((dumpST,break)),fail.
i_voids_limited0(Slots,QMods,Id):- 
  i_voids(Slots,QMods,Id),length(Slots,SL), ((SL > 20) -> (!, fail);true).

i_voids([],[],_).
i_voids(_,_,_):- ((stack_depth(D),D>1000)),!,fail,dmsg(stack_depth(D)),!,fail,ignore((dumpST,break)),fail.
i_voids([Slot|Slots],[quantS(voidQ,X,'`'(true),'`'(true),[],_)|QMods],Id) :-
   nominal_slot(Slot,X,-Id), !,
   i_voids(Slots,QMods,+Id).
i_voids([_|Slots],QMods,Id) :-
   i_voids(Slots,QMods,Id).

i_rel(rel(X,S),X,P&Pred,Pred,QMods,QMods,Up,Id) :-
   i_s(S,P,Up,Id).
i_rel(reduced_rel(X,S),X,Pred,Pred,[A|QMods],QMods,Up,Id) :-
   i_s(S,A,Up,Id).
i_rel(conj(Conj,Left,Right),X,
      conj(Conj,LPred,LQMods,RPred,RQMods)&Pred,Pred,
      QMods,QMods,Up,Id) :-
   i_rel(Left,X,LPred,'`'(true),LQMods,[],[],-Id),
   i_rel(Right,X,RPred,'`'(true),RQMods,[],Up,+Id).

i_np_mod(prep_phrase(Prep,NP),
      X,Slots0,Slots,Pred,Pred,[QMod|QMods],QMods,Up,Id0,Index0) :-
   i_np_head(_Var,NP,Y,Q,LDet,LDet0,LX,LPred,LQMods,LSlots0,Id0),
   i_bind(Prep,Slots0,Slots1,X,Y,Id0,Function,P,PSlots,XArg),
   append(PSlots,Slots1,Slots),
   i_np_modify(Function,P,Q,QMod,Index0,Index),
   held_arg(XArg,[],LSlots0,LSlots,Id0,Id),
   i_np_rest(NP,LDet,LDet0,LX,LPred,LQMods,LSlots,Up,Id,Index).
i_np_mod(Mod,X,Slots,Slots,Pred0,Pred,QMods0,QMods,Up,Id,_) :-
   i_rel(Mod,X,Pred0,Pred,QMods0,QMods,Up,Id).

i_noun(Noun,Type-X,P,Slots) :- nonvar(Noun),
   lf80(Type,noun_template(Noun,Type,X,P,Slots)).

i_bind(Prep,Slots0,Slots,_,X,Id,arg,P,[],[]) :-
   in_slot(Slots0,Case,X,Id,Slots,P),
   deepen_case(Prep,Case).
i_bind(prep(Prep),Slots,Slots,X,Y,_,adjoin,'`'(P),PSlots,XArg) :-
   i_adjoin(Prep,X,Y,PSlots,XArg,P).

i_np_modify(adjoin,P,N,N&P,_,unit).
i_np_modify(arg,F,N,N,Index0,Index) :-
   index_slot(F,Index0,Index).

in_slot([Slot|Slots],Case,X,Id,Slots,F) :-
   slot_match(Slot,Case,X,Id,F).
in_slot([Slot|Slots0],Case,X,Id,[Slot|Slots],F) :-
   in_slot(Slots0,Case,X,Id,Slots,F).

slot_match(slot(Case,Type,X,Id,F),Case,Type-X,Id,F).

i_adjs([],_X,T,T,Head,Head,Pred,Pred).
i_adjs([Adj|Adjs],X,T,T0,Head0,Head,Pred0,Pred):- 
  nop(dmsg(inn(i_adjs0([Adj|Adjs],X,T,T0,Head0,Head,Pred0,Pred)))),
  i_adjs0([Adj|Adjs],X,T,T0,Head0,Head,Pred0,Pred),
  nop(dmsg(out(i_adjs0([Adj|Adjs],X,T,T0,Head0,Head,Pred0,Pred)))).

i_adjs0([Adj|Adjs],X,T,T0,Head0,Head,Pred0,Pred) :-
   lf80(T-T1,i_adj(Adj,X,T,T1,Head0,Head1,Pred0,Pred1)),
   i_adjs(Adjs,X,T1,T0,Head1,Head,Pred1,Pred).

adj_to_p(Adj,X,P):- notrace(subst(Adj,self,X,P)),P\==Adj,!.
adj_to_p(lf(Adj),_X,Adj).

i_adj(sup(Op0,adj(Adj)),Type-X,Type-V,_,
      aggr(F,V,[Y,X],Head,'`'(P)&Pred),Head,'`'(true),Pred) :-
   must80(adj_sign_LF(Adj,Sign)),
   op_inverse(Op0,Sign,Op),
   i_sup_op(Op,F),
   lf80(Type,attribute_LF(Adj,Type,X,_,Y,P)).

i_adj(adj(Adj),_Type-X,T,T,Head,Head,'`'(P)&Pred,Pred) :-
   compound(Adj),adj_to_p(Adj,X,P),!.

i_adj(adj(Adj),Type-X,T,T,Head,Head,'`'(P)&Pred,Pred) :-
   lf80(Type,restriction_LF(Adj,Type,X,P)).
i_adj(adj(Adj),TypeX-X,TypeV-V,_,
   aggr(F,V,[X],Head,Pred),Head,'`'(true),Pred) :-
   lf80(TypeV+TypeX,aggr_adj_LF(Adj,TypeV,TypeX,F)).

i_adj(adj(Adj),TypeX-X,T,T,Head,Head,
 quantS(voidQ,TypeX-Y,'`'(P),'`'(Q)&Pred,[],_),Pred) :-
   lf80(TypeX,attribute_LF(Adj,TypeX,X,_,Y,P)),
   lf80(TypeX,l_standard_adj_LF(Adj,TypeX,Y,Q)).

l_standard_adj_LF(Adj,TypeX,Y,Q):- standard_adj_LF(Adj,TypeX,Y,Q) *-> true ; Q = ajLF(Adj,TypeX,Y).

/*i_s(s(Subj,Verb,VArgs,VMods),Pred,Up,Id) :-
  select(cond(_),VArgs,NewVargs), !,
  i_s(s(Subj,Verb,NewVargs,VMods),Pred,Up,Id).
*/

unslotted_v_args(List,NewVArgs,IntoNegs):- partition(functor_is(arg),List,NewVArgs,IntoNegs).

functor_is(F,P):- compound(P),compound_name_arity(P,F,_).

time_of(Past+Fin,Time):- Past==past,Fin\==part,Time=in_past.
time_of(_PastFin,_Time):- fail.
/*

c8("What are the continents containing a country in which contains more than two cities whose population exceeds 1 million ?")

 _92085454+[_92085460,_92085470,_92085468,_92085464,_92085462,_92085456] :-
       setOf( _92085458,
         ^( [ _92085460, _92085470,_92085468,_92085464,_92085462],
            ( d80(ti(continent,_92085458))  ,
              d80(trans_pred(thing,contain,_92085458,_92085460)) ,
              d80(ti(country,_92085462)) ,
              d80(trans_pred(thing,contain,_92085458,_92085462)) ,
              numberof( _92085466,
                ^( [_92085470,_92085468],
                  ( d80(ti(city,_92085466))  ,
                    d80(count_pred(thing,population,_92085466,_92085468)) ,
                    d80(same_values(_92085470,--(1,million))) ,
                    d80(exceeds(_92085468,_92085470)) ,
                    d80(trans_pred(thing,contain,_92085462,_92085466)))),
                _92085464) ,
              d80(exceeds(92085464,2)))),
         _92085456) ,
       d80(bE(is,_92085454,_92085456)).


        _32372516+[_32372522,_32372532,_32372530,_32372526,_32372524,_32372518] :-
       setOf( _32372520,
         ^( [ _32372522, _32372532,_32372530,_32372526,_32372524],
            ( d80(ti(continent,_32372520))  ,
              d80(trans_pred(thing,contain,_32372520,_32372522)) ,
              d80(ti(country,_32372524)) ,
              d80(trans_pred(thing,contain,_32372520,_32372524)) ,
              numberof( _32372528,
                ^( [_32372532,_32372530],
                  ( d80(ti(city,_32372528))  ,
                    d80(count_pred(thing,population,_32372528,_32372530)) ,
                    d80(same_values(_32372532,--(1,million))) ,
                    d80(exceeds(_32372530,_32372532)) ,
                    d80(trans_pred(thing,contain,_32372524,_32372528)))),
                _32372526) ,
              d80(exceeds(_32372526,2)))),
         _32372518) ,
       d80(bE(is,_32372516,_32372518)).

*/
i_s(S,lfOf(S),_Up,_Id):- var(S),!.
i_s(decl(S),Pred,Up,Id):-!,i_s(S,Pred,Up,Id).
i_s(q(S),Pred,Up,Id):-!,i_s(S,Pred,Up,Id).
/*i_s(s(Subj,Verb,VArgs,VMods),Pred,Up,Id):-
  once(repair_verb(Verb,VerbR)), Verb \=@= VerbR,!,
  i_s(s(Subj,VerbR,VArgs,VMods),Pred,Up,Id).
*/

%i_s(S,Pred,Up,Id):- dmsg(i_s(S,Pred,Up,Id)),fail.
i_s(s(Subj,verb(VerbType,Root,Voice,Tense,Aspect,Neg0),VArgs,VMods),Pred,Up,Id) :-
  unslotted_v_args(VArgs,NewVArgs,IntoNegs), IntoNegs\==[],
  add_extra_to_neg(Neg0,IntoNegs,FNewNeg),
  append([],Aspect,NewAspect),
  i_s(s(Subj,verb(VerbType,Root,Voice,Tense,NewAspect,FNewNeg),NewVArgs,VMods),Pred,Up,Id).

i_s(s(Subj,verb(VerbType,Root,Voice,Tense,Aspect,Neg0),VArgs,VMods),Pred,Up,Id) :-
  once(must(fix_mneg(Neg0,Neg))), Neg\==Neg0,
  i_s(s(Subj,verb(VerbType,Root,Voice,Tense,Aspect,Neg),VArgs,VMods),Pred,Up,Id).

i_s(s(Subj,verb(VerbType,Root,Voice,PastFin,Aspect,Neg),VArgs,VMods),Pred,Up,Id) :- 
  time_of(PastFin,Time),
  \+ contains_var(Time,Neg),
  i_s(s(Subj,verb(VerbType,Root,Voice,PastFin,Aspect,[Time|Neg]),VArgs,VMods),Pred,Up,Id).

i_s(s(Subj,verb(Mainiv,aux(be,_),[],Active,Fin+fin,[],Neg),VArgs,VMods),Pred,Up,Id) :- !,
   i_s(s(Subj,verb(Mainiv,exist,[],Active,Fin+fin,[],Neg),VArgs,VMods),Pred,Up,Id).
i_s(s(Subj,verb(Mainiv,be,[],Active,Fin+fin,[],Neg),VArgs,VMods),Pred,Up,Id) :- !,
   i_s(s(Subj,verb(Mainiv,exist,[],Active,Fin+fin,[],Neg),VArgs,VMods),Pred,Up,Id).

i_s(s(Subj,Verb,VArgs,VMods),Pred,Up,Id) :-
  select(cond(IF,S2),VMods,NewVMods),!,
  S1 = s(Subj,Verb,VArgs,NewVMods),
  i_s(S1,Pred1,Up,Id),
  debug_chat80_if_fail(deepen_pos((s80lf(S2,Pred2);i_sentence(S2,Pred2)));Pred2=lfOf(S2)),
  Pred= cond_pred(IF,Pred1,Pred2).

i_s(S,Pred,Up,Id) :- i_s_0(S,Pred,Up,Id).

i_s_0(s(Subj,Verb,VArgs,VMods),Pred,Up,Id) :-
  once(subc_member(was_framed(VV),s(VMods,VArgs,Verb,Subj));t_l:current_vv(VV);gensym('frame_',VV)),
  locally(t_l:current_vv(VV),
   i_s_1(s(Subj,Verb,VArgs,VMods),Pred,Up,Id)),!.

i_s_1(s(Subj,Verb,VArgs,VMods),Pred,Up,Id) :-
  i_s_2(s(Subj,Verb,VArgs,VMods),Pred,Up,Id)*-> true; i_s_3(s(Subj,Verb,VArgs,VMods),Pred,Up,Id).

  
i_s_3(s(Subj,Verb,VArgs,VMods),PredO,Up,Id):- fail, VMods\==[], i_s_2(s(Subj,Verb,VArgs,[]),Pred,Up,Id),
  mabye_modalize(scope,VMods,Pred,PredO).

i_s_2(s(Subj,Verb,VArgs,VMods),Pred,Up,Id) :-
 ((
   i_verb(Verb,P,Tense,Voice,DetPosNeg,Slots0,XA0,Meta),
   i_subj(RefVar,Voice,Subj,Slots0,Slots1,QSubj,SUp,'-'('-'(Id))),
   append(SUp,VArgs,TArgs),
   i_verb_args(RefVar,TArgs,XA0,XA,Slots1,Slots,Args0,Args,Up0,+(-Id)),
   append(Up0,VMods,Mods),
   i_verb_mods(RefVar,Mods,Tense,XA,Slots,Args,Up,+Id),
   reshape_pred(Meta,QSubj,DetPosNeg,P,Args0,Pred))).

/*
      i_verb(verb(VerbType,Root,[],Voice,Tense,Aspect,Neg),
      PP,Tense,Voice,Det,Slots,XArg,Meta) :-
      i_verb(verb(VerbType,Root,Voice,Tense,Aspect,Neg),
      PP,Tense,Voice,Det,Slots,XArg,Meta).

*/
/*i_verb(verb(VerbType,Root,Voice,Tense,Aspect,Neg),
      PP,Tense,Voice,Det,Slots,XArg,Meta) :-
       ignore((ExtraMods\==[],wdmsg(extra_mods(ExtraMods)),nop((dumpST,break)))),
       append(ExtraMods,XArg,ModXArgs),!,
       %append(Slots,ExtraMods,XSlots),!,
       i_verb(verb(VerbType,Root,Voice,Tense,Aspect,Neg),
      PP,Tense,Voice,Det,Slots,ModXArgs,Meta).
*/      
i_verb(verb(_VerbType,Root,Voice,Tense,_Aspect,Neg0),
      PP,Tense,Voice,DetPosNeg,Slots,XArg,Meta) :-
   must80(slot_verb_template(Root,P,Slots,XArg,Meta)),
   once((fix_mneg(Neg0,Neg),
   i_neg(Neg,DetPosNeg,E),
   maybe_modalize(slot,E,P,PP))).

add_extra_to_neg(Neg0,IntoNegs,FNewNeg):- 
  fix_mneg(Neg0,Neg),Neg=L,
  append(IntoNegs,L,NewIntoNegs),
  NewNeg=NewIntoNegs,
  fix_mneg(NewNeg,FNewNeg).

%fix_mneg(Modal,O):- var(Modal),!,O=Modal.
%fix_mneg(/*negP*/(Modal),O):- fix_modal_list(Modal,ModalF),Modal\==ModalF,fix_mneg((ModalF),O).
% fix_mneg(O,O):- is_list(Modal),select(not,Modal,ModalP),!,fix_mneg([notP(Modalz)|ModalP],O).
%dfix_mneg(I,O):- subst(I,not,true,M),I\==M,!,O=notP(M).
fix_mneg(O,O).
  
fix_modal_list(Modal,O):- is_list(Modal),!,flatten(Modal,ModalF),fix_modal_list0(ModalF,O).
fix_modal_list(Modal,O):- flatten([Modal],ModalF),fix_modal_list0(ModalF,O).

fix_modal_list0(O,[]):- O == [].
fix_modal_list0(O,[O]):- \+ compound(O),!.
fix_modal_list0([H|T],[HH|TT]):- !, fix_modal_list0(H,HH), fix_modal_list0(T,TT).
fix_modal_list0(adv(M),O):-!,fix_modal_list0(M,O).
fix_modal_list0(P,O):- arg(1,P,M),!,fix_modal_list0(M,O).

% make_pred(S,notP(M),P,A,PRED):- !, make_pred(S,identityQ(M),\+ P,A,PRED).
make_pred(S,N,P,A,PRED):- pred(S,N,P,A) = PRED.

reshape_pred(transparent,S,N,P,A,PRED):- make_pred(S,N,P,A,PRED).
reshape_pred(aux(have,_MODAL),Subj,DetPosNeg,Verb0, [QUANT|MRest], OUT) :-
   QUANT = quantS(Det,X,Head0,Pred,QArgs,Y),
    QOUT = quantS(Det,X, Head,Pred,QArgs,Y),
   make_pred(Subj,DetPosNeg,Verb,[QOUT|MRest],OUT),
   have_pred(Head0,Verb0,Head,Verb).

have_pred('`'(Head),Verb,'`'(true),(Head,Verb)).
have_pred(Head,Verb,Head,Verb) :-
   meta_head(Head).

meta_head(apply80(_,_)).
meta_head(aggr(_,_,_,_,_)).

i_neg(I,O,P):- i_neg(I,O),P=O.

i_neg(notP(X),notP(X)):-!.
i_neg(Info,notP(Modalz)):- contains_var(not,Info),subst(Info,not,true,Modalz),!.
i_neg(Info,notP(Modalz)):- sub_term(V,Info),compound(V),V=notP(X),subst(Info,V,X,Modalz),!.
i_neg(Info,notP(Modalz)):- sub_term(V,Info),compound(V),V=negP(X),subst(Info,V,X,Modalz),!.
i_neg(identityQ(Info),identityQ(Info)):-!.
i_neg(Info,identityQ(Info)).

i_subj(RefVar,Voice,Subj,Slots0,Slots,Quant,Up,Id) :-
   (active_passive_subjcase(Voice,Case)*->true;true),
   verb_slot(RefVar,arg(Case,Subj),[],[],Slots0,Slots,[Quant],[],Up,Id).

i_verb_args(RefVar,VArgs,XA0,XA,Slots0,Slots,Args0,Args,Up,Id) :-
   fill_verb(RefVar,VArgs,XA0,XA,Slots0,Slots,Args0,Args,Up,Id).

active_passive_subjcase(activeV,subjA).
active_passive_subjcase(passiveV,subjP).

fill_verb(_RefVar,[],XA,XA,Slots,Slots,Args,Args,[],_):-!.
fill_verb(RefVar,[Node|Nodes0],XA0,XA,Slots0,Slots,Args0,Args,Up,Id) :-
   verb_slot(RefVar,Node,XA0,XA1,Slots0,Slots1,Args0,Args1,Up0,-Id),
   append(Up0,Nodes0,Nodes),
   fill_verb(RefVar,Nodes,XA1,XA,Slots1,Slots,Args1,Args,Up,+Id).

verb_slot(RefVar,Node,XA0,XA1,Slots0,Slots1,Args0,Args1,Up0,Id):- !, 
  verb_slot0(RefVar,Node,XA0,XA1,Slots0,Slots1,Args0,Args1,Up0,Id).
verb_slot(RefVar,Node,XA0,XA1,Slots0,Slots1,Args0,Args1,Up0,Id):- 
  debug_chat80_if_fail((clause(verb_slot0(RefVar,Node,XA0,XA1,Slots0,Slots1,Args0,Args1,Up0,Id),Body),
   Body)).

verb_slot1(Node,XA0,XA1,Slots0,Slots1,Args0,Args1,Up0,Id):- 
  G  = verb_slot0(RefVar,Node,XA0,XA1,Slots0,Slots1,Args0,Args1,Up0,Id),
  G2 = verb_slot0(RefVar,Node,XA0,_,Slots0,_,Args0,_,Up0,_),
  copy_term(G,G2),
  call(G),
  ignore((var(Slots1),trace,G2)).
 

verb_slot0(_RefVar,prep_phrase(Prep,NP),
      XArg0,XArg,Slots0,Slots,[Q|Args],Args,Up,Id) :-
   i_np(NP,X,Q,Up,Id,unit,XArg0,XArg),
   in_slot(Slots0,Case,X,Id,Slots,_),
   deepen_case(Prep,Case).

verb_slot0(_RefVar,prep_phrase(poSS,NP),
      TXArg,TXArg,Slots0,Slots,[Q& '`'(P)|Args],Args,Up,Id0) :-  
   Prep=of,
   (((
   in_slot(Slots0,_Arg_pred,X,Id0,Slots1,_),
   i_adjoin(Prep,X,Y,PSlots,XArg,P),
   i_np_head(_Var,NP,Y,Q,LDet,LDet0,LX,LPred,LQMods,LSlots0,Id0),
   held_arg(XArg,[],LSlots0,LSlots,Id0,Id),
   i_np_rest(NP,LDet,LDet0,LX,LPred,LQMods,LSlots,Up,Id,free),
   append(PSlots,Slots1,Slots)))).

verb_slot0(_RefVar,prep_phrase(prep(Prep),NP),
      TXArg,TXArg,Slots0,Slots,[Q& '`'(P)|Args],Args,Up,Id0) :- !,
   in_slot(Slots0,arg_pred,X,Id0,Slots1,_),
   i_adjoin(Prep,X,Y,PSlots,XArg,P),
   i_np_head(_Var,NP,Y,Q,LDet,LDet0,LX,LPred,LQMods,LSlots0,Id0),
   held_arg(XArg,[],LSlots0,LSlots,Id0,Id),
   i_np_rest(NP,LDet,LDet0,LX,LPred,LQMods,LSlots,Up,Id,free),
   append(PSlots,Slots1,Slots).



verb_slot0(_RefVar,voidQ,XA,XA,Slots,Slots,Args,Args,[],_) :- !,
   in_slot(Slots,arg_pred,_,_,_,_).
verb_slot0(RefVar,adv(Adv),XA,XA,Slots0,Slots,['`'(P)|Args],Args,[],Id) :- !,
   must80(adv_template_LF(RefVar,Adv,Case,X,P)),
   must80(in_slot(Slots0,Case,X,Id,Slots,_)).
verb_slot0(_RefVar,arg(SCase,NP), 
      XArg0,XArg,Slots0,Slots,[Q|Args],Args,Up,Id) :-
   i_np(NP,X,Q,Up,Id,unit,XArg0,XArg),
   in_slot(Slots0,Case,X,Id,Slots,_),
   deepen_case(SCase,Case).
verb_slot0(RefVar,arg(ArgPred,AP),XA,XA,Slots0,Slots,Args0,Args,Up,Id) :- !, ArgPred=arg_pred,
   in_slot(Slots0,arg_pred,X,Id,Slots,_),
   must80(i_pred(RefVar,AP,X,Args0,Args,Up,Id)).
/*
verb_slot0(RefVar,(Adv),XA,XA,Slots0,Slots,['`'(P)|Args],Args,[],Id) :-
   must80(adv_template_LF(RefVar,Adv,Case,X,P)),
   in_slot(Slots0,Case,X,Id,Slots,_).
*/

i_pred(RefVar,conj(Conj,Left,Right),X,
      [conj(Conj,'`'(true),LQMods,'`'(true),RQMods)|QMods],
      QMods,Up,Id) :-
   i_pred(RefVar,Left,X,LQMods,[],[],-Id),
   i_pred(RefVar,Right,X,RQMods,[],Up,+Id).
i_pred(_RefVar,AP,T,['`'(Head)&Pred|As],As,[],_) :-
   i_adj(AP,T,_,_,Head,true,Pred,'`'(true)).
i_pred(_RefVar,value80(adj(Adj),wh(TypeY-Y)),Type-X,['`'(H)|As],As,[],_) :-
   lf80(Type,attribute_LF(Adj,Type,X,TypeY,Y,H)).

i_pred(RefVar,comp(more,adj(less),NP),X,P,As,Up,Id) :-
  i_pred(RefVar,comp(less,adj(great),NP),X,P,As,Up,Id).

i_pred(_RefVar,comp(Op0,adj(Adj),NP),X,[P1 & P2 & '`'(P3),Q|As],As,Up,Id) :-
   i_np(NP,Y,Q,Up,Id,unit,[],[]),
   must80(adj_sign_LF(Adj,Sign)),
   lf80(Type,i_measure(X,Adj,Type,U,P1)),
   lf80(Type,i_measure(Y,Adj,Type,V,P2)),
   op_inverse(Op0,Sign,Op),
   measure_op(Op,U,V,P3).
i_pred(_RefVar,prep_phrase(prep(Prep),NP),X,['`'(H),Q|As],As,Up,Id) :-
   i_np(NP,Y,Q,Up,Id,unit,[],[]),
   lf80(X-Y,adjunction_LF(Prep,X,Y,H)).

i_adjoin(with,TS-S,TV-Y,[slot(prep(of),TV,Z,_,free)],
        held_arg(poSS,-_Id,TS-S),
        Y=Z).
i_adjoin(Prep,X,Y,[],[],P) :-
   lf80(X-Y,adjunction_LF(Prep,X,Y,P)).

i_measure(Type-X,Adj,Type,X,'`'(true)) :-
   lf80(Type,units_db(Adj,Type)).
i_measure(TypeX-X,Adj,TypeY,Y,quantS(voidQ,TypeY-Y,'`'(P),'`'(true),[],_)) :-
   lf80(TypeX+TypeY,attribute_LF(Adj,TypeX,X,TypeY,Y,P)).

i_verb_mods(RefVar,Mods,_,XA,Slots0,Args0,Up,Id) :-
   fill_verb(RefVar,Mods,XA,[],Slots0,Slots,Args0,Args,Up,-Id),
   i_voids_limited(Slots,Args,+Id).

nominal_slot(slot(Kind,Type,X,Id,_),Type-X,Id) :-
   nominal_kind(Kind).

nominal_kind(prep(_)).
nominal_kind(poSS).
nominal_kind(subjA).
nominal_kind(dirO).
nominal_kind(indO).

i_sup_op(least,min).
i_sup_op(most, max).

pos_conversion_db(wh(Type-X),same,Type,X,identityQ(_QModal)).
pos_conversion_db(N,Op,_,N,Op):- number(N).
pos_conversion_db(N,Op,_,N,Op):- notrace(bind_pos('value',N)).

same_value(X,X).
same_objects(X,X).
same_objects(_,X,X).
same_values(X,X).

%measure_op(identityQ(_QModal), X,X,    true).
measure_op(identityQ(Modalz), X,Y,  P):- maybe_modalize(scope,identityQ(Modalz),same_value(X,Y), P).
measure_op(notP(Modalz)+Cond, X, Y , PP):- !, measure_op(Cond, X, Y , P),maybe_modalize(scope,notP(Modalz), P, PP).
measure_op(same, X,Y,   same_values(X,Y)).
measure_op(More, X,Y,   exceeds(X,Y)):- op_inverse2(More,_).
measure_op(Less, X,Y,   P):- op_inverse2(More,Less), measure_op(More,Y,X,P).
%measure_op(Less,      X,Y,   P):- op_inverse(Less,-,More), measure_op(More,Y,X,P).


op_inverse(X,+,X).
op_inverse(same,-,same).
op_inverse(Least,-,Most):- op_inverse1(Most,Least).
op_inverse(Most,-,Least):- op_inverse1(Most,Least).

op_inverse1(most,least).
op_inverse1(more,less).
op_inverse2(many,few).
op_inverse2(much,little).
op_inverse2(Many,Few):-op_inverse1(Many,Few).

noun_template(Noun,TypeV,V,'`'(P),
      [slot(poSS,TypeO,O,Os,index)|Slots]) :-
   property_LF(Noun,TypeV,V,TypeO,O,P,Slots,Os,_).

noun_template(Noun,TypeV,V,aggr(F,V,[],'`'(true),'`'(true)),
   [slot(prep(of),TypeS,_,_,free)]) :-
   aggr_noun_LF(Noun,TypeV,TypeS,F).

noun_template(Noun,Type,X,'`'(P),Slots) :-
   %lf80(Type,thing_LF_access(Noun,Type,X,P,Slots,_)).
   thing_LF_access(Noun,Type,X,P,Slots,_).

noun_template(Noun,TypeV,V,apply80(F,P),
      [slot(prep(Of),TypeX,X,_,apply)]) :-
   meta_noun_LF(Noun,Of,TypeV,V,TypeX,X,P,F).

noun_template(Noun,TypeV,V,'`'(P),
      [slot(poSS,TypeO,O,Os,index)|Slots]) :-
   property_LF_1(Noun,TypeV,V,TypeO,O,P,Slots,Os,_).

noun_template(Noun,Type,X,'`'(P),Slots) :-
   %lf80(Type,thing_LF_access(Noun,Type,X,P,Slots,_)).
   thing_LF_access_1(Noun,Type,X,P,Slots,_).

slot_verb_template(aux(have,MODAL),(Y=Z,aux(have,S,Y)),
                Slots,
                held_arg(poSS,-(-(+Id)),TypeS-S), aux(have,MODAL)):-
  select_slots(Slots,
                [slot(subjA,TypeS,S,-Id,free),
                 slot(dirO,TypeV,Y,_,free),
                 slot(prep(of),TypeV,Z,_,free)]).

slot_verb_template(aux(have,MODAL),(Y=Z,aux(have,S,Y)),
        Slots,
        held_arg(poSS,-(-(-(+Id))),TypeS-S), aux(have,MODAL)):-
  select_slots(Slots,
        [slot(subjA,TypeS,S,-(-(Id)),free),
         slot(dirO,TypeV,Y,_,free),
         slot(prep(as),TypeV,Z,_,free)]).

slot_verb_template(Verb,Pred, Slots,[],transparent) :-
  slot_verb_template_transparent1(Verb,Pred, Slots);slot_verb_template_transparent2(Verb,Pred, Slots).


slot_verb_template_transparent1(Verb,Pred, Slots) :-   
   (select_slots(Slots,[slot(subjA,TypeS,S,_,free)],SlotsRemaining);SlotsRemaining=Slots),
   (verb_type_lex(Verb,Kind);true),
   must80(slot_verb_kind(Kind,Verb,TypeS,S,Pred,SlotsRemaining)).

slot_verb_template_transparent2(Verb,Pred, Slots) :- fail,
   (SlotsRemaining=Slots),   
   slot_verb_kind(_Kind,Verb,_TypeS,_S,Pred,SlotsRemaining).

select_slots(Ss,Slots):- select_slots(Ss,Slots,[]),!.
%select_slots(Ss,Slots):- select_slots(Ss,Slots,_).
select_slots(X,[],X):-!.
select_slots([Slot|X],[Slot|Slots],Remaining):- 
  select_slots(X,Slots,Remaining).
/*
select_slots(X,[Slot|Slots],Remaining):- fail,
  select(Slot,X,Mid),!,
  select_slots(Mid,Slots,Remaining).
*/

slot_verb_kind(Main+More,Verb,TypeS,S,Pred,AllSlots):- 
 nonvar(Main),!,
 %dmsg(slot_verb_kind(More,Verb,TypeS,S,Pred,AllSlots)),
 slot_verb_kind(More,Verb,TypeS,S,Pred,AllSlots).

% BE
% slot_verb_kind(aux(be,_MODAL),_,TypeS,S,bE(is,A,S),[slot(dirO,TypeS,A,_,free)]).
slot_verb_kind(aux(Be,_MODAL),_,TypeS,S,bE(is,S,A),AllSlots):- Be == be,
   select_slots(AllSlots, [slot(dirO,TypeS,A,_,free)]).
slot_verb_kind(aux(Be,_MODAL),_,TypeS,S,true,AllSlots):- Be == be, !,
   select_slots(AllSlots, [slot(arg_pred,TypeS,S,_,free)]).

slot_verb_kind(_Tv,Verb,TypeS,S,Pred,AllSlots) :-
   select_slots(AllSlots,[slot(dirO,TypeD,D,SlotD,free)],Slots),
   lf80(TypeS-TypeD,trans_LF(Verb,TypeS,S,TypeD,D,Pred,Slots,SlotD,_)).

slot_verb_kind(_Iv,Verb,TypeS,S,Pred,Slots) :-
   lf80(TypeS,intrans_LF(Verb,TypeS,S,Pred,Slots,_)).

slot_verb_kind(_,aux(_,_),_TypeS,_S,_Pred,_Slots):- !, fail.

slot_verb_kind(_Tv,Verb,TypeS,S,Pred,AllSlots) :- if_search_expanded(2), 
   select_slots(AllSlots,[slot(dirO,TypeD,D,SlotD,free)],Slots),
   lf80(TypeS-TypeD,trans_LF1(Verb,TypeS,S,TypeD,D,Pred,Slots,SlotD,_)).

slot_verb_kind(Iv1,Verb,TypeS,S,Pred,Slots) :- if_search_expanded(3), 
    slot_suggester(Iv1,Slots),
   lf80(TypeS,intrans_LF_1(Iv1,Verb,TypeS,S,Pred,Slots,_)).
/*
slot_verb_kind((Prep),Verb,TypeS,S,Pred,AllSlots):- if_search_expanded(7),
  slot_suggester(Prep,AllSlots),
   select_slots(AllSlots, 
       [slot(dirO,TypeD,D,SlotD,free),
       slot(indO,TypeI,I,SlotI,free)],Slots),
   %fail,fail,fail,fail,
   lf80(TypeS+TypeD+TypeI,ditrans_lex80(Verb,Prep,TypeS,S,TypeD,D,TypeI,I,Pred,Slots,SlotD,SlotI,_)).
*/
% slows the system way down like the danube
% slot_verb_kind(Type,Verb,TypeS,S,Pred,AllSlots):- fail,if_search_expanded(4),  lazy_pred_LF(Type,Verb,TypeS,S,AllSlots,Pred),!.

 % see no_repeats_dc(DC0,subj_obj_indirect_slots_LF(ditrans,verb_prep(Verb,Prep),TypeS,S,TypeD,D,TypeI,I,Pred,Slots,SlotI,SlotD,DC0)).

ditrans_lex80(Verb,Prep,TypeS,S,TypeD,D,TypeI,I,Pred,Slots,SlotD,SlotI,_):- 
  limit_slots(Slots,10),!,% fail,
  Pred = ditrans_call(Verb,prep(Prep),subjType(TypeS),subj(S),dirType(TypeD),dirO(D),indType(TypeI),
   indO(I),slots(Slots),slot_d(SlotD),slot_i(SlotI)).

limit_slots(Slots,L):- freeze(Slots,(proper_len(Slots,_,SL),SL<L)).

slot_suggester(dv(''),[slot(indO,_,_,_,free),slot(dirO,_,_,_,free)]).
slot_suggester(tv,[slot(dirO,_,_,_,free)]).
slot_suggester(iv,[]).
slot_suggester(dv(Prep),[slot(indO,_,Z,_,free),slot(dirO,_,_,_,free),slot(prep(Prep),_,Z,_,free)]):- dif(Prep,'').
%slot_suggester(dv(Prep),[slot(indO,_,_,_,free),slot(dirO,_,_,_,free),slot(prep(Prep),_,_,_,free)]):- dif(Prep,'').


deepen_case(prep(at),time).
deepen_case(subjP,dirO).
deepen_case(subjP,indO).
deepen_case(prep(by),subjA).
deepen_case(prep(to),indO).
deepen_case(prep(of),poSS).
deepen_case(X,X).

% ================================================================
% Determiner Indexing Table

index_slot(index,I,I).
index_slot(free,_,unit).
index_slot(apply,_,apply).
index_slot(comparator,_,comparator).

index_args(det(the(pl)),unit,I,set(I),index(I)) :- !.
index_args(wh_det(Kind,X),index(I),_,wh_det3(Kind,I,X),unit) :- !.
index_args(generic,apply,_,lambdaV,unit) :-!.
index_args(D,comparator,_,identityQ(_QModal),unit) :-
 ( indexable_arg(D); D=generic), !.
index_args(D,unit,_,D,unit) :- !.
index_args(det(D),I,_,I,I) :-
   indexable_arg(D),
   is_my_index(I), !.
index_args(D,I,_,D,I).

indexable_arg(the(pl)).
indexable_arg(all).
indexable_arg(de(pl)).
indexable_arg(alle).

is_my_index(index(_I)).

:- fixup_exports.
