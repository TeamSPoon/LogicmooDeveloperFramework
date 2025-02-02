/*************************************************************************

         name: godis-AOD
      version: 
  description: GoDiS-AOD specification file
       author: Staffan Larsson
 
*************************************************************************/

:- ensure_loaded( search_paths ).

/*========================================================================
   Select datatypes

   Speficies a list of datatypes to be loaded. Each item DataType in the
   list corresponds to a file DataType.pl in the search path.
========================================================================*/

selected_datatypes([string, move, atom, integer, real, bool, record,
set, stack, stackset, queue, oqueue, pair, godis_datatypes]).


/*========================================================================
   Select modules

   Each module spec has the form Predicate:FileName, where Predicate is the
   unary predicate used to call the module, and FileName.pl is the a file
   in the search path containing the module specification
========================================================================*/

selected_modules([ input : input_simpletext,
		   %input : input_nuance_score,
		   interpret: interpret_simple,
		   update : update,
		   select : select,
		   generate : generate_simple,
		   %output : output_nuance_score
		   output : output_simpletext
		   ]).

% dme_module/1 - spefifies which modules have unlimited access to TIS

dme_modules([ update, select ]). 


/*========================================================================
   Select resources

   Speficies a list of resources to be loaded. Each item
   ResourceFile in the list corresponds to a  a file ResourceFile.pl
   in the search path. The file defines a resource object with the same
   name as the file.
========================================================================*/

selected_resources( [
%		     device_vcr,
%		     lexicon_vcr_english,
%		     lexicon_vcr_svenska,
%%		     domain_vcr,
%		     device_telephone,
%		     lexicon_telephone_english,
%		     domain_telephone
		     device_legoturtle,
		     domain_legoturtle,
		     lexicon_legoturtle_svenska
		    ] ).

selected_macro_file( godis_macros ).

batch_files(['~sl/GoDiS/Batch/testdialog1.txt','~sl/GoDiS/Batch/testdialog2.txt']).

/*========================================================================
   operations to execute on TIS reset
========================================================================*/

reset_operations( [ set( program_state, run),
		    set( language, Lang ),
		    set( lexicon, $$dash2underscore(lexicon-Domain-Lang) ),
		    set( devices,
			 record([ turtle = device_legoturtle]) ),
%		    set( devices, record([telephone=device_telephone]) ),
		    set( domain, $$dash2underscore(domain-Domain) ),
		    push(/private/agenda,greet),
		    score := 1.0,
%		    push(/private/agenda,do(vcr_top)),
%		    push( /shared/actions, vcr_top ) ]):-
		    push(/private/agenda,do(top)),
		    push( /shared/actions, top ) ]):-
	flag( language, Lang ),
	flag( domain, Domain ).
