
% Load the config file to define library directories etc
:- ['$REGULUS/doc/ACL2003/Experiments/Prolog/config'].

% Compile the main Regulus code
:- compile('$REGULUS/Prolog/load').

:- format('~N~n~n**************************~nGRAMMAR VERSION: PSA + HOUSE + TRAVEL_DEALS~n~n', []).

:- regulus_batch('$REGULUS/doc/ACL2003/Experiments/GrammarScaleScripts/psa_travel_deals.cfg', 
		 ["LOAD", "EBL_TREEBANK", "EBL_TRAIN", "EBL_POSTPROCESS", "EBL_NUANCE"]).

:- halt.


