
% Compile the main Regulus code
:- compile('$REGULUS/Prolog/load').

% Compile generator
:- regulus_batch('$REGULUS/Examples/Toy1/scripts/swedish.cfg', ["LOAD_GENERATION"]).

:- halt.


