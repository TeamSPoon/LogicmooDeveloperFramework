:- module(test_tornado,
  [test_tornado/0]).
:- use_module(library(plunit)).

test_tornado:-
    trill:set_algorithm(tornado),
    run_tests([tornado_biopax,
    %tornado_biopax_rdf,
    tornado_dbpedia,
    tornado_brca,
    tornado_commander,
    tornado_johnEmployee,
    tornado_peoplePets,
    tornado_vicodi]).

:- use_module(library(trill_test/trill_test)).

:- begin_tests(tornado_brca, []).

:- ensure_loaded(library('examples/BRCA.pl')).

test(p_wlbrcr_h):-
  run((prob_instanceOf('WomanUnderLifetimeBRCRisk','Helen',Prob),close_to(Prob,0.123))).
test(p_wa_wulbrcr):-
  run((prob_sub_class('WomanAged3040','WomanUnderLifetimeBRCRisk',Prob),close_to(Prob,0.123))).

:- end_tests(tornado_brca).


:- begin_tests(tornado_vicodi, []).

:-ensure_loaded(library(examples/vicodi)).

test(p_r_avdpf):-
  run((prob_instanceOf('vicodi:Role','vicodi:Anthony-van-Dyck-is-Painter-in-Flanders',Prob),close_to(Prob,0.27540000000000003))).
test(p_p_r):-
  run((prob_sub_class('vicodi:Painter','vicodi:Role',Prob),close_to(Prob,0.30600000000000005))).

:- end_tests(tornado_vicodi).


:- begin_tests(tornado_commander, []).

:-ensure_loaded(library(examples/commander)).

test(e_c_j):-
  run((prob_instanceOf(commander,john,Prob),close_to(Prob,1))).

:- end_tests(tornado_commander).


:- begin_tests(tornado_peoplePets, []).

:-ensure_loaded(library(examples/peoplePets)).

test(p_nl_k):-
  run((prob_instanceOf('natureLover','Kevin',Prob),close_to(Prob,0.348))).

:- end_tests(tornado_peoplePets).


:- begin_tests(tornado_biopax, []).

:-ensure_loaded(library(examples/biopaxLevel3)).

test(p_twbr_e):-
  run((prob_sub_class('biopax:TransportWithBiochemicalReaction','biopax:Entity',Prob),close_to(Prob,0.98))).

:- end_tests(tornado_biopax).

:- begin_tests(tornado_biopax_rdf, []).

:-ensure_loaded(library(trill)).

test(p_twbr_e):-
  run((init_trill(tornado),load_owl_kb('../examples/biopaxLevel3_rdf.owl'),prob_sub_class('biopax:TransportWithBiochemicalReaction','biopax:Entity',Prob),close_to(Prob,0.98))).

:- end_tests(tornado_biopax_rdf).


:- begin_tests(tornado_dbpedia, []).

:-ensure_loaded(library('examples/DBPedia.pl')).

test(p_p_pp):-
  run((prob_sub_class('dbpedia:Place','dbpedia:PopulatedPlace',Prob),close_to(Prob,0.8273765902816))).

:- end_tests(tornado_dbpedia).


:- begin_tests(tornado_johnEmployee, []).

:-ensure_loaded(library(examples/johnEmployee)).

test(e_p_j):-
  run((prob_instanceOf('johnEmployee:person','johnEmployee:john',Prob),close_to(Prob,1))).
  
:- end_tests(tornado_johnEmployee).
