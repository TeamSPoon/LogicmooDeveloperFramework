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

:- op(400,xfy,&).


spatial(Thing):- dif(Thing,value), Thing = thing.

feat(Feat):- dif(Feat,geo). % debug_var(feat,Feat),

thing_LF(person,_,X,ti(person,X),[],_).

trans_LF12(Verb,TypeS,S,TypeD,D,Pred,Slots,SlotD,R):- 
 trans_LF(Verb,TypeS,S,TypeD,D,Pred,Slots,SlotD,R)
 *->true
 ;trans_LF1(Verb,TypeS,S,TypeD,D,Pred,Slots,SlotD,R).

trans_LF(contain,Spatial&_,X,Spatial&_,Y, Out,[],_,_):- make_pred(trans_pred,Spatial,contain,X,Y,Out).
trans_LF(have,   Spatial&_,X,Spatial&_,Y, Out,[],_,_):- make_pred(trans_pred,Spatial,have,X,Y,Out).
trans_LF(aux(have,MODAL),Spatial&_,X,Spatial&_,Y, OUT, [],_,_):- 
  make_pred(trans_pred,Spatial,have,X,Y,P), maybe_modalize(scope,MODAL,P,OUT).


thing_LF(OceanOrSea,Path,X,ti(OceanOrSea,X),Nil,Any):-  ti_subclass(OceanOrSea,Seamass), 
   like_type(_Geo,seamass,Seamass), %Seamass=seamass,
   thing_LF(Seamass,Path,X,ti(Seamass,X),Nil,Any),
    concrete_type(Seamass).

thing_LF(City,Spatial& Feat& City,X,ti(City,X),[],_):- concrete_type(City), feat(Feat), spatial(Spatial),like_type(geo,city,City).
thing_LF(Seamass,Spatial&Geo&  Seamass,X,ti(Seamass,X),[],_):- concrete_type(Seamass), spatial(Spatial),like_type(Geo,seamass,Seamass).

thing_LF_access(Continent,_,X,ti(Continent,X),[],_):- var(Continent),!,fail.

thing_LF_access(Continent,Spatial&Geo&  Continent,X,ti(Continent,X),[],_):- concrete_type(Continent), like_type(Geo,continent,Continent), spatial(Spatial).

name_template_lf0(X,_) :- var(X),!,fail.
name_template_lf0(X,Spatial& Feat& City) :-like_type(geo,city,City), ti(City,X),feat(Feat), spatial(Spatial).
name_template_lf0(X,Spatial& Feat& Circle_of_latitude) :- like_type(geo,circle_of_latitude,Circle_of_latitude), feat(Feat), ti(Circle_of_latitude,X), spatial(Spatial).

name_template_lf0(X,Spatial&Geo&  Seamass) :- like_type(Geo,seamass,Seamass),spatial(Spatial), ti(Seamass,X).
name_template_lf0(X,Spatial&Geo&  Country) :- like_type(Geo,country,Country), spatial(Spatial), ti(Country,X).
name_template_lf0(X,Spatial&Geo&  Continent) :- like_type(Geo,continent,Continent), spatial(Spatial), ti(Continent,X).

%like_type(geo,River,River):- bind_pos('type',River).




thing_LF(River,_,X,ti(River,X),[],_):- var(River),!.
thing_LF(River,Spatial& Feat& River,X,ti(River,X),[],_):- feat(Feat),like_type(geo,river,River),spatial(Spatial).
thing_LF(Type,Spatial& Feat & Type,X,ti(Type,X),[],_):- feat(Feat),bind_pos('type',Type),spatial(Spatial).
thing_LF(Types,Spatial& Feat & Type,X,ti(Type,X),[],_):- feat(Feat),bind_pos('type',Type,'s',Types),spatial(Spatial).
name_template_lf0(X,Spatial& Feat& River) :- feat(Feat),like_type(_Geo,river,River), ti(River,X), spatial(Spatial).
name_template_lf0(X,Spatial&_) :- like_type(_Geo,region,Region),spatial(Spatial), ti(Region,X).




thing_LF(Place,  Spatial&_,          X,ti(Place,X),  [],_):- spatial(Spatial), place_lex(Place).
thing_LF(Region, Spatial&_,          X,ti(Region,X), [],_):- spatial(Spatial),like_type(_Geo,region,Region).
thing_LF(Country,Spatial&Geo&  Country,X,ti(Country,X),[],_):- spatial(Spatial),like_type(Geo,country,Country).


unique_of_obj(geo,thing,Country,Govern,Capital,City,Capital_city,Nation_Capital):-
   maplist(bind_pos, 
       ['type','action','subtype','type','property','property'],
       [Country,Govern,Capital,City,Capital_city,Nation_Capital]).


  
attribute_LF(Var,_,_,_,_,_):- var(Var),!,fail.
attribute_LF(populous,Spatial&_,X,value&units&population/*citizens*/,Y,count_pred(Spatial,population/*citizens*/,Y,X)).

attribute_LF(large,Spatial&_,X,value&size&Area,Y,measure_pred(Spatial,Area,X,Y)):- spatial(Spatial), type_measure_pred(_,size,Area,_).
attribute_LF(small,Spatial&_,X,value&size&Area,Y,measure_pred(Spatial,Area,X,Y)):- spatial(Spatial), type_measure_pred(_,size,Area,_).
attribute_LF(great,value&Measure&Type,X,value&Measure&Type,Y,exceeds(X,Y)).


/* Measure */

:- op(200,xfx,--).

unit_format(Population,X--million):- unit_format(Population,X--thousand).
unit_format(Population,_X--thousand):- type_measure_pred(_City,units,Population,countV).
unit_format(Latitude,_X--Degrees):- type_measure_pred(_Region, position(_),Latitude,Degrees).
%unit_format(Longitude,_X--Degrees):- measure_pred(_Region,position(x),Longitude,Degrees).
unit_format(Area,_X--Ksqmiles):- type_measure_pred(_Region,size,Area,Ksqmiles).

measure_LF(Unit,value&_&Size,[],Units):- type_measure_pred(_City,_,Size,Units), atom_concat(Unit,'s',Units).
measure_LF(sqmile,Path,[],sqmiles):- measure_LF(ksqmile,Path,[],ksqmiles).
measure_LF(sqmile,value&size&area,[],sqmiles).
measure_LF(Degree,value&position&Axis,[],Degrees):- type_measure_pred(_Region, position(Axis),_Latitude,Degrees), atom_concat(Degree,'s',Degrees).
measure_LF(thousand,value&units&Population/*citizens*/,[],thousand):-  type_measure_pred(_City,units,Population,countV).
measure_LF(million, value&units&Population/*citizens*/,[], million):-  type_measure_pred(_City,units,Population,countV).


verb_type_db(chat80,adj_prep(A,P),main+tv):- nonvar(A),nonvar(P),!.
verb_type_db(chat80,border,main+tv).
symmetric_verb(Spatial,border):- spatial(Spatial).

prep_order(move,by,dirO,dir).
prep_order(paint,by,dirO,color).
prep_order(give,by,to,dirO).

concrete_type(Type):- var(Type),dmsg(var_concrete_type(Type)),!,fail.
concrete_type(Type):- free_ti(Type).
concrete_type(dog).
concrete_type(toy).
concrete_type(person).
concrete_type(man).
concrete_type(island).
concrete_type(TI):- clause(ti(TI2,_),_),TI==TI2.
concrete_type(Type):- is_toplevel_class(Type).
concrete_type(Type):- nonvar(Type), loop_check(is_prop_type80(Type)),!,fail.

is_toplevel_class(C):- is_toplevel_enum(C).
is_toplevel_class(C):- ti_subclass(C,S), is_toplevel_class(S).

is_toplevel_enum(city).
is_toplevel_enum(river).
is_toplevel_enum(place).
is_toplevel_enum(circle_of_latitude).


is_prop_type80(Million):- ratio(Million1,Thousand,_,_),(Million1=Million;(Million1\=Thousand,Million=Thousand)).
is_prop_type80(Percentage):- comparator_LF(Percentage,_,_,_,_).
is_prop_type80(Total):- aggr_adj_LF(Total1,_,_,Total2),(Total1=Total;(Total1\=Total2,Total2=Total)).
is_prop_type80(Type):- nonvar(Type), loop_check(concrete_type(Type)),!,fail.


%prep_order(get,by,to,from).
/* Nouns *//*
property_LF(River,Spatial& Feat& River,X,Spatial&Geo&  _Country,Y,
 (GP,ti(River,X)),[],_,_):-  fail,
   if_search_expanded(7),
   make_gp(Spatial,any,Y,X,GP),
   feat(Feat),spatial(Spatial),Geo=geo,
   %concrete_type(Country),
   concrete_type(River).*/
%property_LF(Area,     _,    _X, _,_Y, _P,[],_,_):- var(Area),!,fail.

property_LF(Area,     value&size&Area,    X,Spatial&_,Y,  measure_pred(Spatial,Area,Y,X),[],_,_):- 
   spatial(Spatial), type_measure_pred(_,size,Area,_).
property_LF(Latitude, value&position&XY,X,Spatial&_,Y, position_pred(Spatial,Latitude,Y,X),[],_,_):- 
                     type_measure_pred(_Region,position(XY),Latitude,_).
%property_LF(Longitude,value&position&x,X,Spatial&_,Y, position_pred(Spatial,Longitude,Y,X),[],_,_):- type_measure_pred(_Region,position(x),Longitude,_).
property_LF(Population, value&Units&Population/*citizens*/, X,Spatial&_,Y,    
  count_pred(Spatial,Population/*citizens*/,Y,X),[],_,_):-
  type_measure_pred(_City,Units,Population,countV).

property_LF(Area,     value&size&Area,    X,Spatial&_,Y, measure_pred(Spatial,Area,Y,X),[],_,_):- assertion(nonvar(Area)),spatial(Spatial), clex_attribute(Area).

type_measure_pred(_AnyObjectType,MeasureType,Area,countV):- MeasureType\==size, MeasureType=Area, clex_attribute(Area).

property_LF(Capital,_,X,_,Y,Out,[],_,_):- 
   nonvar(Capital),
   \+ is_prop_type80(Capital),!,
   (( \+ \+ ti(Capital,_) ; concrete_type(Capital)) -> PT = type ; (fail, PT = prop)),
   make_gp(_Spatial,has_prop(PT,Capital),Y,X,Out).

property_LF_1(Area,     _,    _X, _,_Y, _P,[],_,_):- var(Area),!,fail.


trans_LF(    Govern,Spatial& Feat& City,X,Spatial&Geo&  Country,Y,specific_pred(Spatial,Nation_capital,Y,X),[],_,_):-
  feat(Feat), assertion(nonvar(Govern)),
  unique_of_obj(Geo,Spatial,Country,Govern,_Capital,City,_Capital_city,Nation_capital).
   

thing_LF(Capital,Spatial& Feat& City,X,ti(Capital_city,X),[],_):- 
  feat(Feat), assertion(nonvar(Capital)),
   unique_of_obj(_Geo,Spatial,_Country,_Govern,Capital,City,Capital_city,_Nation_capital),
   spatial(Spatial).

thing_LF_access_1(Capital,Spatial& Feat& _City,X,ti(Capital,X),[],_):- 
  feat(Feat), assertion(nonvar(Capital)),
   concrete_type(Capital),
   spatial(Spatial).

/*
thing_LF(River,Spatial& Feat& River,X,ti(River,X),[],_):- 
  feat(Feat), concrete_type(River), spatial(Spatial).
*/
  

clex_attribute(Area):-  bind_pos('attrib',Area).
%clex_attribute(Area):-  bind_pos('type',Area).

synonymous_spatial(nation,country).

thing_LF_access(Area,value&size&Area,X,unit_format(Area,X),[],_):- assertion(nonvar(Area)), 
  type_measure_pred(_,size,Area,_).

thing_LF_access(Latitude,value&position,X,unit_format(Latitude,X),[],_):- assertion(nonvar(Latitude)), type_measure_pred(_Region,position(_Y),Latitude,_).

%thing_LF_access(Longitude,value&position,X,unit_format(Longitude,X),[],_):- type_measure_pred(_Region,position(x),Longitude,_).
thing_LF_access(Population,value&units&Population/*citizens*/,X,unit_format(Population,X),[],_):- assertion(nonvar(Population)), type_measure_pred(_,units,Population,_).


/* Prepositions */

adjunction_LF(in, Spatial&_-X,Spatial&_-Y,GP):- make_pred(trans_pred,Spatial,contain,Y,X,GP).
adjunction_LF(Any,Spatial&_-X,Spatial&_-Y,GP):- if_search_expanded(2), make_pred(trans_pred,Spatial,prop(adjunct,Any),X,Y,GP).
adjunction_LF(cp(East,Of),Spatial&_-X,Spatial&_-Y,ordering_pred(Spatial,cp(East,Of),X,Y)).


/* Proper nouns */

name_template_LF(X,_):- var(X),!.
name_template_LF(X,Type2):- bind_pos('object',X), type_conversion(typeOfFn(X),Type2).
name_template_LF(X,Type2):- bind_pos('type',X), type_conversion(X,Type2).
name_template_LF(X,Type2):- name_template_lf0(X,Type1), type_conversion(Type1,Type2).


aggr_noun_LF(average,_,_,average).
aggr_noun_LF(sum,_,_,total).
aggr_noun_LF(total,_,_,total).

meta_noun_LF(number,of,_,V,Spatial&_,X,P,numberof(X,P,V)):- spatial(Spatial).


% thing_LF(geo,Spatial&_,X,ti(geo,X),[],_):- spatial(Spatial).

thing_LF(Nation,Path,X,LF,Slots,Other):- synonymous_spatial(Nation,Country), thing_LF(Country,Path,X,LF,Slots,Other).


thing_LF_access(Noun,Type2,X,P,Slots,_):-
  thing_LF(Noun,Type1,X,P,Slots,_),
  btype_conversion(Type1,Type2).
thing_LF_access(Person,_,X,ti(Person,X),[],_):-  if_search_expanded(4), concrete_type(Person).

btype_conversion(_,_).
type_conversion(Type1,Type2):- !, Type1=Type2.

check_slots(Slots):- ignore((var(Slots),trace,break)).

/* Verbs */

/*
%verb_root_db(chat80,border).
trans_LF(border,Spatial&Geo&  _,X,Spatial&Geo&  _,Y,symmetric_pred(Spatial,borders,X,Y),[],_,_).
%regular_past_db(chat80,bordered,border).
%% superceeded regular_pres_db(chat80,border).
verb_form_db(chat80,bordering,border,pres+part,_):- .
verb_form_db(chat80,borders,border,pres+fin,3+sg).
verb_form_db(chat80,border,border,pres+fin,_+pl). %:- verb_root_db(chat80,border)
% ... because [which,countries,border,france,?] was not properly parsed (the singular form was)
verb_form_db(chat80,border,border,inf,_). %:- verb_root_db(chat80,border)
% ... because [does,france,border,belgium,?] was not properly parsed
verb_form_db(chat80,bordered,border,past+part,_). % :- regular_past_db(chat80,bordered,border).
*/

:- style_check(+singleton).

trans_LF(Border,Spatial&Super&_,X,Spatial&Super&_,Y,GP,[],_,_):-  
  nonvar(Border),
  make_gp(Spatial,has_prop(pred,Border),X,Y,GP),
   verb_type_lex(Border,main+tv),
   symmetric_verb(Spatial, Border).

trans_LF(Border,Spatial&Super&_,X,Spatial&Super&_,Y,GP,[],_,_):-  
   (bind_pos('action',Border);bind_pos('attrib',Border)),nop(spatial(Spatial)),
   nonvar(Border),
   make_gp(Spatial,has_prop(pred,Border),X,Y,GP).

bind_pos(_,_,_,_):- !,fail.
bind_pos(Type,Var,Lex,Var2):- nonvar(Var),!,clex:learned_as_type(Type,Var,Lex,Var2).
bind_pos(Type,Var,Lex,Var2):- freeze80(Var2,clex:learned_as_type(Type,Var,Lex,Var2)).
bind_pos(_,_):- !,fail.
bind_pos(Type,Var):- freeze80(Var,clex:learned_as_type(Type,Var)).


verb_form_db(clex,Borders,Border,A,B):- verb_form_db_clex(Borders,Border,A,B).

verb_form_db_clex(Bordering,Border,pres+part,_):- (bind_pos('action',Border,'ing',Bordering)).
verb_form_db_clex(Bordered,Border,past+part,_):- (bind_pos('action',Border,'ed',Bordered)).
verb_form_db_clex(Borders,Border,pres+fin,_):- (bind_pos('action',Border,'s',Borders)).
verb_form_db_clex(Border,Border,inf,_):- (bind_pos('action',Border,'',Border)).

talkdb_talk_db(transitive,   Border,  Borders,  Bordered,  Bordering,  Bordered):-
  (bind_pos('action',Border,'ing',Bordering), bind_pos('action',Border,'ed',Bordered), bind_pos('action',Border,'s',Borders)).
 
%use_lexicon_80(_):- !, true.
%us e_lexicon_80(cha t80).
%use _lexicon_80(chat 80_extra).
%use_lexicon_80(talkd b_verb(X)):- verb _type_db(chat80,X,_).
% use_lexicon_80(_):- fail.

:- import(talkdb:talk_db/6).
%                         nonfinite,  pres+fin, past+fin,  pres+part    past+part,
talkdb_talk_db(transitive,   border,  borders,  bordered,  bordering,  bordered).
talkdb_talk_db(  Transitive, Write,   Writes,   Wrote,     Writing,    Written):- 
  talkdb:talk_db(Transitive, Write,   Writes,   Wrote,     Writing,    Written).

%verb_root_lex(Write):-            talkdb_talk_db(_Transitive,Write,_Writes,_Wrote,_Writing,_Written).
verb_type_db(talkdb,Write,main+tv):-   talkdb_talk_db( transitive,Write,_Writes,_Wrote,_Writing,_Written), \+ avoided_verb(Write).
verb_type_db(talkdb,Write,main+iv):-    
   talkdb_talk_db( intransitive,Write,_Writes,_Wrote,_Writing,_Written), 
 % \+ talkdb_talk_db( transitive,Write,_Writes2,_Wrote2,_Writing2,_Written2),
  \+ avoided_verb(Write).
%regular_past_lex(Wrote,Write):-   talkdb_talk_db(_Transitive,Write,_Writes, Wrote,_Writing,_Written).
% superceeded regular_pres_lex(Write):-         talkdb_talk_db(_Transitive,Write,_Writes,_Wrote,_Writing,_Written).

verb_form_db(chat80,A,B,C,D):- verb_form_db(talkdb,A,B,C,D).
% verb_form_db(chat80,A,B,C,D):- verb_form_db(talkdb,A,B,C,D).

verb_form_db(talkdb,Written,Write,past+part,_):-   talkdb_talk_db(_Transitive,Write,_Writes,_Wrote,_Writing, Written).
verb_form_db(talkdb,Writing,Write,pres+part,_):-   talkdb_talk_db(_Transitive,Write,_Writes,_Wrote, Writing,_Written).
verb_form_db(talkdb, Writes,Write,pres+fin,3+sg):- talkdb_talk_db(_Transitive,Write, Writes,_Wrote,_Writing,_Written).
verb_form_db(talkdb, Writes,Write,pres+fin,_):-    talkdb_talk_db(_Transitive,Write, Writes,_Wrote,_Writing,_Written).
verb_form_db(talkdb,  Write,Write,      inf,_):-   talkdb_talk_db(_Transitive,Write,_Writes,_Wrote,_Writing,_Written).
verb_form_db(talkdb,  Wrote,Write,past+fin,_):-    talkdb_talk_db(_Transitive,Write,_Writes, Wrote,_Writing,_Written).

verb_form_db(talkdb,A,B,C,D):- verb_form_db(clex,A,B,C,D).

:- clex_iface:export(clex_iface:clex_verb/4).
:- import(clex_iface:clex_verb/4).
clex_verb80(Looked,Look,VerbType,Form):- \+ compound(Looked),\+ compound(Look), 
  clex_iface:clex_verb(Looked,Look,VerbType,Form).
%% superceeded regular_pres_lex(Look):- no_loop_check(verb_root_lex(Look)).
%verb_form_lex(Looking,Look,pres+part,_):- (atom(Looking)->atom_concat(Look,'ing',Looking);var(Looking)),
%  no_loop_check(verb_root_lex(Look)),atom(Look),atom_concat(Look,'ing',Looking).
% NEW TRY verb_root_lex(Look):- clex_verb80(_Formed,Look,_Iv,_Finsg).
% regular_past_lex(Looked,Look):- clex_verb80(Looked,Look,_Iv,pp).
verb_form_db(clex,Looks,Look,pres+fin,3+sg):- clex_verb80(Looks,Look,_,finsg).
verb_form_db(clex,LookPL,Look,pres+fin,3+pl):-  clex_verb80(LookPL,Look,_,infpl).
verb_type_db(clex,Look,main+ITDV):- clex_verb80(_Formed,Look,ITDV,_Finsg).

intrans_LF(Assign,feature&_,X,dbase_t(Assign,X,Y), [slot(prep(To),feature&_,Y,_,free)],_):-
  clex_verb80(_Assigned, Assign, dv(To),_).

trans_LF(Look,feature&_,X,dbase_t(Look,X,Y), [slot(prep(At),feature&_,Y,_,free)],_):- 
  (tv_infpl(S,_);tv_finsg(S,_)), atomic_list_concat([Look,At],'-',S).

trans_LF(exceed,value&Measure&Type,X,value&Measure&Type,Y,exceeds(X,Y),[],_,_).

trans_LF1(Trans,_,X,_,Y, P,[],_,_):- if_search_expanded(4), Trans\=aux(_,_),
  make_gp(Spatial,prop(pred,Trans),X,Y,P),spatial(Spatial).

make_pred(Trans_pred,S,P,X,Y,OUT):- OUT=..[Trans_pred,S,P,X,Y].
%make_gp(Spatial,prop(adjunct,AT),X,Y,generic_pred(VV,Spatial,prop(adjunct,AT),X,Y)):- t_l:current_vv(VV),!.
make_gp(_Spatial,(AT),X,Y,OUT):-  \+ compound(AT), OUT = trans_pred(_,AT,X,Y).
make_gp(_Spatial,(AT),X,Y,OUT):-  ignore(t_l:current_vv(VV)),!, OUT = generic_pred(x,VV,AT,X,Y).
make_gp(_Spatial,(AT),X,Y,OUT):- OUT = generic_pred(x,y,AT,X,Y).
%make_gp(Spatial,(AT),X,Y,OUT):- ignore(t_l:current_vv(VV)),!, OUT = generic_pred(VV,Spatial,AT,X,Y).

% qualifiedBy
qualifiedBy_LF2(Var,FType,Name,Type,Else,P):-
  qf(Var,true,qualifiedBy(Var,FType,Name,Type,Else),_,P).
qualifiedBy_LF(_Var,_FType,_Name,_Type,_Else,_P):-  \+ if_search_expanded(2),!, fail.
qualifiedBy_LF(Var,FType,Name,Type,Else,PO):-  qualifiedBy_LF0(Var,FType,Name,Type,Else,P),
   (var(Name)->(Var=Name,P=PO) ; conjoin(P,var_name(Var,Name),PO)).

qf(Var,PIn,I,Out,POut):- sub_term(E,I),nonvar(E),pl_qualified(E,R),subst(R,self,Var,RP),subst(I,E,xxx,MM),!,
  conjoin(PIn,RP,PMid),qf(Var,PMid,MM,Out,POut).
qf(_Var,POut,_,_,POut).

pl_qualified(Atom,ti(Atom,self)):- atom(Atom), Atom\==xxx.
pl_qualified(det(the(sg)),count(self,eq,1)).
pl_qualified(det(the(pl)),count(self,gt,1)).
pl_qualified(det(some),exists(self)).

%qualifiedBy_LF(Var, FType,X,Type,Else,P):- nop(qualifiedBy_LF(Var,FType,X,Type,Else,P)),fail.
qualifiedBy_LF0(Var,_FType, X,Base&Thing,np_head(Var,wh_det(Kind,Kind-_23246),[],Type),(ti(Thing,X),ti(Base,X),ti(Type,X))).
qualifiedBy_LF0(Var,FType, X, BaseAndThing,np_head(Var,det(the(sg)),Adjs,Table),Head):- qualifiedBy_LF(Var,FType, X, BaseAndThing,np_head(Var,det(a),Adjs,Table),Head),!.
qualifiedBy_LF0(Var,_FType, X,_,np_head(Var,det(a),[],Table),ti(Table,X)).
qualifiedBy_LF0(Var,_FType,X,_Type,pronoun(Var,_,1+sg),isa(X,vTheVarFn("I"))).
qualifiedBy_LF0(Var,_FType,X,_Type,pronoun(Var,_,1+pl),isa(X,vTheVarFn("US"))).
qualifiedBy_LF0(Var,_FType,X,Type,np_head(Var,generic,Adjs,Table),Pred):-
  must80(i_adjs(Adjs,Type-X,Type-X,_,Head,Head,Pred,ti(Table,X))).
qualifiedBy_LF0(Var,_FType,X,Type,np_head(Var,det(a),Adjs,Table),Pred):- 
  must80(i_adjs(Adjs,Type-X,Type-X,_,Head,Head,Pred,ti(Table,X))).
qualifiedBy_LF0(Var,_FType,Name,Type,Else,P):- P = qualifiedBy(Var,Name,Type,Else),!.
qualifiedBy_LF0(Var,FType,Name,Type,Else,P):- wdmsg(missed(qualifiedBy_LF(Var,FType,Name,Type,Else,P))),fail.


adv_template_LF(RefVar,Adv,Case,X,pred_adv(RefVar,Adv,Case,X)).

/* Adjectives */

restriction_LF(Word,_Type,_X,_P):- aggr_adj_LF(Word,_TypeV,_TypeX,_F),!,fail.
restriction_LF(Word,_Type,_X,_P):- adj_sign_LF(Word,_),!,fail.
restriction_LF(African,Spatial&_,X,ti(African,X)):- adj_lex(African,restr), spatial(Spatial).
restriction_LF(Word,_,X,Out):- compound(Word),subst(Word,self,X,Out), Word\==Out.
restriction_LF(_,_,_,_):- \+ if_search_expanded(2), !, fail.
restriction_LF(Word,Spatial&_,X, property(X,Type,pos)):- adj_db_clex(Type,Word,restr), spatial(Spatial).
restriction_LF(Type,_Spatial&_,X, object(X,Type,countable, na, eq, 1)).

%restriction_LF(american,Spatial&_,X,ti(american,X)).
%restriction_LF(asian,Spatial&_,X,ti(asian,X)).
%restriction_LF(european,Spatial&_,X,ti(european,X)).

aggr_adj_LF(average,_,_,average).
aggr_adj_LF(total,_,_,total).
aggr_adj_LF(minimum,_,_,minimum).
aggr_adj_LF(maximum,_,_,maximum).

/* Measure */

units_db(large,_Measure&_).
units_db(small,value&_&_).

adj_sign_LF(large,+).
adj_sign_LF(small,-).
adj_sign_LF(great,+).

/* Proportions and the like */

comparator_LF(proportion,_,V,[],proportion(V)).
comparator_LF(percentage,_,V,[],proportion(V)).



ratio(thousand,million,1,1000).
ratio(million,thousand,1000,1).

ratio(ksqmiles,sqmiles,1000,1).
ratio(sqmiles,ksqmiles,1,1000).




% NLU Logical Forms
% ------------------

% X rises in Begin
% % chat80("where does the rhine rise?") -> [switzerland]
% chat80("the rhine rises in switzerland ?      ").
% @TODO: X begins from Begin
intrans_LF(Start,Spatial & Feat& Type,X, LF,
   [slot(prep(From),Spatial&_,Begin,_,free)],_):- 
 feat(Feat),
 type_begins_thru_ends(Type, PathSystem, Start, _Continue, _Stop),
 spatial(Spatial),member(From,[in,from,at]),debug_var(From,Begin),
 LF = path_pred(begins(PathSystem),Type,X,Begin).

% X drains into End
intrans_LF(Stop,Spatial & Feat& Type,X, LF, 
   [slot(prep(Into),Spatial&_,End,_,free)],_):- 
 feat(Feat),
 type_begins_thru_ends(Type, PathSystem, _Start, _Continue, Stop),
 spatial(Spatial),member(Into,[into,in,to,at]),debug_var(Into,End),
 LF = path_pred(ends(PathSystem),Type,X,End).


intrans_LF(Continue,Spatial & Feat& Type,X,LF,
   [slot(prep(Into),Spatial&_,Dest,_,free),
    slot(prep(From),Spatial&_,Origin,_,free)],_):- 
 feat(Feat),
 type_begins_thru_ends(Type, PathSystem, _Start, Continue, _Stop),
 spatial(Spatial),
 member(Into,[into,to,through,in,at]),
 member(From,[from,through,in,at]), 
 dif(From,Into),
 debug_var(Into,Dest),
 debug_var(From,Origin),
 LF = path_pred_linkage(direct(PathSystem),Type,X,Origin,Dest).

%intrans_LF(Verb,TypeS,S,Pred,Slots,W):- if_search_expanded(2),
%  intrans_LF_1(Verb,TypeS,S,Pred,Slots,W).

intrans_LF_1(_,Run,Spatial & Feat& Type,X,LF, [],_):- 
 feat(Feat),
 intrans_verb(Run),
 spatial(Spatial),
 LF = intrans_pred(Spatial,Type,Run,X).

intrans_LF_1(_,Run,Spatial & Feat& Type,X,LF,
 [slot(prep(Into),Spatial&_,Dest,_,free)],_):- 
 feat(Feat),
 %\+ concrete_type(Run),
 intrans_verb(Run),
 spatial(Spatial),
 LF = intrans_pred_prep(Spatial,Type,Run,X,Into,Dest).

intrans_LF_1(_,Continue,Spatial& _Feat& Type,X,LF,
  [slot(dirO,Spatial&_,Y,_,free)],_):-   
  intrans_verb(Continue),
  LF = intrans_pred_direct(_Spatial,Continue,Type,X,Y).


intrans_LF_1(Type,Run,Spatial & _Feat& _TypeX,X,LF, Slots,_):- 
 clex_iface:clex_verb(_Sent,Run,RType,_Form),
 LF = intrans_pred_slots(Spatial,Type=RType,Run,X,Slots).

intrans_LF_1(Type,Run,Spatial & Feat& _TypeX,X,LF, Slots,_):- 
 %slot_suggester(Type,Slots),
 feat(Feat), 
 %\+ concrete_type(Run),
 intrans_verb(Run),
 ignore(clex_iface:clex_verb(_Sent,Run,RType,_Form)),
 spatial(Spatial),
 LF = intrans_pred_slots(Spatial,Type=RType,Run,X,Slots).


intrans_verb(Y):- once(intrans_verb0(Y)).
intrans_verb(verb_fn(_)).
%intrans_verb0(Run):- clex:iv_infpl(Run,_).
intrans_verb0(run).
intrans_verb0(Send):- clex_iface:clex_verb(_Sent,Send,_VerbType,_Form).
intrans_verb0(wait).
%intrans_verb0(Y):- clex:iv_finsg(_,Y).


% X flows through Begin
/*
intrans_LF(Continue,Spatial & Feat& Type,X,LF,
   [slot(prep(Through),Spatial&_,Link,_,free)],_):- 
 feat(Feat),
 type_begins_thru_ends(Type, PathSystem, _Start, Continue, _Stop),
 spatial(Spatial),member(Through,[through,in]),
 LF = path_pred(thru_from(PathSystem),Type,X,Link).
*/



less_specific(Rise,  begin):-    type_specific_bte(_Type, _PathSystem,Rise,_,_).
less_specific(begin, start).
less_specific(Flow,  link):-     type_specific_bte(_Type, _PathSystem,_,Flow,_).
less_specific(link,  continue).
less_specific(Drain, end):-      type_specific_bte(_Type, _PathSystem,_,_,Drain).
less_specific(end,   stop).

% Lexical Data
% ------------------
%verb_type_db(chat80,Rise,main+iv):-  less_specific(Rise,  begin).
%verb_type_db(chat80,Flow,main+iv):-  less_specific(Flow,  link).
%verb_type_db(chat80,Drain,main+iv):- less_specific(Drain, end).
verb_type_db(chat80,LessSpecific,main+_):-  (bind_pos('action',LessSpecific)).
verb_type_db(chat80,LessSpecific,main+iv):- less_specific(_, LessSpecific).
verb_type_db(chat80,MoreSpecific,main+iv):- less_specific(MoreSpecific, _).

type_begins_thru_ends(Type, PathSystem, Begin, Continue, Stop):- 
  type_specific_bte(Type, PathSystem, Rise, Flow, Drain),
  maybe_less_specific(Rise,  Begin),
  maybe_less_specific(Flow,  Continue),
  maybe_less_specific(Drain, Stop).

maybe_less_specific(Drain, Drain).
maybe_less_specific(Drain, Stop):-
 less_specific(Drain, End),
 maybe_less_specific(End, Stop).



add_ss(Spatial,B,X,C):- X @> C, !, add_ss(Spatial,B,C,X).
add_ss(Spatial,B,X,C):- direct_ss(Spatial,B, X,C), !.
add_ss(Spatial,B,X,C):- assertz(direct_ss(Spatial,B, X,C)), !.
%:- add_ss(thing,border,Albania,Greece).

:- abolish(tmp80:trans_rel_cache_creating,2).
:- abolish(tmp80:trans_rel_cache_created,2).
:- abolish(tmp80:trans_rel_cache_insts,3).
:- abolish(tmp80:trans_rel_cache,4).

:- dynamic(tmp80:trans_rel_cache_creating/2).
:- dynamic(tmp80:trans_rel_cache_created/2).
:- dynamic(tmp80:trans_rel_cache_insts/3).
:- dynamic(tmp80:trans_rel_cache/4).

trans_rel(Spatial,Contain,X,Y):- \+ compound(Contain),!,
  trace_or_throw(wrong(trans_rel(Spatial,Contain,X,Y))),
  trans_rel(=,trans_direct(Spatial,Contain),X,Y).

trans_rel(P1,P2,X,Y) :- trans_rel_cache_create(P1,P2),!, tmp80:trans_rel_cache(P1,P2,X,Y).
trans_rel(P1,P2,X,Y):- trans_rel_nc(P1,P2,X,Y).

trans_rel_nc(P1,P2,X,Y) :- var(X),!, no_repeats(X, trans_rel_rl(P1,P2,X,Y)).
trans_rel_nc(P1,P2,X,Y) :- nonvar(Y), !, trans_rel_lr(P1,P2,X,Y), !.
trans_rel_nc(P1,P2,X,Y) :- no_repeats(Y, trans_rel_lr(P1,P2,X,Y)).

trans_rel_lr(P1,P2,X,Y) :- call(P2,X,W), ( call(P1,W,Y) ; trans_rel_lr(P1,P2,W,Y) ).
trans_rel_rl(P1,P2,X,Y) :- call(P2,W,Y), ( call(P1,W,X) ; trans_rel_rl(P1,P2,X,W) ).


% @TODO Dmiles maybe not cache these?
trans_rel_cache_create(P1,P2):- Both = (P1,P2), \+ ground(Both),numbervars(Both),!,trans_rel_cache_create0(P1,P2).
trans_rel_cache_create(P1,P2):- trans_rel_cache_create0(P1,P2).

trans_rel_cache_create0(P1,P2):- must_be(ground,(P1,P2)),
                                tmp80:trans_rel_cache_created(P1,P2),!.
trans_rel_cache_create0(P1,P2):- tmp80:trans_rel_cache_creating(P1,P2),dmsg(looped(trans_rel_cache_create(P1,P2))),fail.
trans_rel_cache_create0(P1,P2):-
  asserta((tmp80:trans_rel_cache_creating(P1,P2)),Ref),
  dmsg(trans_rel_cache_creating(P1,P2)),
  forall(call(P2,XX,YY),
     (assert_if_new(tmp80:trans_rel_cache_insts(P1,P2,XX)),
      assert_if_new(tmp80:trans_rel_cache_insts(P1,P2,YY)))),
  forall(tmp80:trans_rel_cache_insts(P1,P2,E),
        (forall(trans_rel_nc(P1,P2,E,Y),assert_if_new(tmp80:trans_rel_cache(P1,P2,E,Y))),
         forall(trans_rel_nc(P1,P2,Y,E),assert_if_new(tmp80:trans_rel_cache(P1,P2,Y,E))))),
  dmsg(trans_rel_cache_created(P1,P2)),
  asserta((tmp80:trans_rel_cache_created(P1,P2))),!,
  erase(Ref),
  %listing(tmp80:trans_rel_cache_insts(P1,P2,_Instances)),
  %listing(tmp80:trans_rel_cache(P1,P2,_,_)),
  !.


:- fixup_exports.
