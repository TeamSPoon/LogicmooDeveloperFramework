 
:- use_module('$REGULUS/Prolog/specialised_regulus2nuance_tagging').

go :- specialised_regulus2nuance_tagging('$REGULUS/Examples/Calendar/Generated/calendar_specialised_no_binarise_default.regulus',
					 '$REGULUS/Examples/Calendar/SLM/scripts/tagging_grammar_spec.pl',
					 '$REGULUS/Examples/Calendar/SLM/generated_tagging.grammar',
					 debug,
					 '.MAIN_tagging').

:- go.				      

:- halt.



	
