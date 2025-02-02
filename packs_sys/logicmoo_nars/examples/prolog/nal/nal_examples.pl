%
% NAL-Examples.txt
% Pei Wang
% September 2012
%
% Examples for NAL rules in the NAL Prolog program
%
% Each of the examples consists of a goal, followed by one or more expected results
% (among the possible multiple results) To run it, copy the first line, then paste
% it into a Prolog interpreter.
%

:- module(nal_examples,[nal_example_test/2]).

:- [library(nars/nars)].

% ----- NAL-1 ----- %

%= revision


nal_example_test(
  revision([inheritance(bird, swimmer), [1, 0.8]], [inheritance(bird, swimmer), [0, 0.5]], R) ,
 [ R = [inheritance(bird, swimmer), [0.8, 0.83]] ]). 


%= choice

nal_example_test(
  choice([inheritance(swan, bird), [1, 0.8]], [inheritance(swan, bird), [0, 0.5]], R) ,
 [ R = [inheritance(swan, bird), [1, 0.8]] ]). 


nal_example_test(
  choice([inheritance(swan, bird), [1, 0.5]], [inheritance(penguin, bird), [0.8, 0.9]], R) ,
 [ R = [inheritance(penguin, bird), [0.8, 0.9]] ]). 


%= deduction

nal_example_test(
  inference([inheritance(bird, animal), [1, 0.9]], [inheritance(robin, bird), [1, 0.9]], [inheritance(robin, animal), T]) ,
 [ T = [1, 0.81] ]). 


%= induction

nal_example_test(
  inference([inheritance(robin, animal), [1, 0.9]], [inheritance(robin, bird), [1, 0.9]], [inheritance(bird, animal), T]) ,
 [ T = [1, 0.45] ]). 


%= abduction

nal_example_test(
  inference([inheritance(bird, animal), [1, 0.9]], [inheritance(robin, animal), [1, 0.9]], [inheritance(robin, bird), T]) ,
 [ T = [1, 0.45] ]). 


%= examplification

nal_example_test(
  inference([inheritance(robin, bird), [1, 0.9]], [inheritance(bird, animal), [1, 0.9]], [inheritance(animal, robin), T]) ,
 [ T = [1, 0.45] ]). 


%= convension

nal_example_test(
  inference([inheritance(swan, bird), [0.9, 0.8]], [inheritance(bird, swan), T]) ,
 [ T = [1, 0.42] ]). 


% ----- NAL-2 ----- %

%= inheritance to similarity

nal_example_test(
  inference([inheritance(swan, robin), [0.9, 0.8]], 
            [inheritance(robin, swan), [0.9, 0.8]], 
            [similarity(swan, robin), T]) ,
 [ T = [0.81, 0.64] ]). 


%= comparison

nal_example_test(
  inference([inheritance(swan, swimmer), [1, 0.9]], [inheritance(swan, bird), [1, 0.9]], [similarity(bird, swimmer), T]) ,
 [ T = [1, 0.45] ]). 

nal_example_test(
  inference([inheritance(sport, competition), [1, 0.9]],  
            [inheritance(chess, competition), [1, 0.9]], 
            [similarity(chess, sport), T]) ,
 [ T = [1, 0.45] ]). 


%= analogy

nal_example_test(
  inference([inheritance(swan, swimmer), [1, 0.9]], [similarity(gull, swan), [0.9, 0.9]], [inheritance(gull, swimmer), T]) ,
 [ T = [0.9, 0.73] ]). 

nal_example_test(
  inference([inheritance(chess, competition), [1, 0.9]], [similarity(sport, competition), [0.9, 0.9]], [inheritance(chess, sport), T]) ,
 [ T = [0.9, 0.73] ]). 


%= resemblance

nal_example_test(
  inference([similarity(swan, robin), [0.8, 0.9]], [similarity(gull, swan), [0.9, 0.8]], [similarity(gull, robin), T]) ,
 [ T = [0.72, 0.71] ]). 


%= instance and property

nal_example_test(
  inference([instance(tweety, bird), [1, 0.9]], [inheritance(S, P), T]) ,
 [ S = ext_set([tweety]),
   P = bird,
   T = [1, 0.9] ]). 

nal_example_test(
  inference([property(raven, black), [1, 0.9]], [inheritance(S, P), T]) ,
 [ S = raven,
   P = int_set([black]),
   T = [1, 0.9] ]). 

nal_example_test(
  inference([inst_prop(tweety, yellow), [1, 0.9]], [inheritance(S, P), T]) ,
 [ S = ext_set([tweety]),
   P = int_set([yellow]),
   T = [1, 0.9] ]). 


%= set definition

nal_example_test(
  inference([inheritance(ext_set([tweety]), ext_set([birdie])), [1, 0.8]], [similarity(S, P), T]) ,
 [ S = ext_set([tweety]),
   P = ext_set([birdie]),
   T = [1, 0.8] ]). 

nal_example_test(
  inference([inheritance(int_set([smart]), int_set([bright])), [1, 0.8]], [similarity(S, P), T]) ,
 [ S = int_set([smart]),
   P = int_set([bright]),
   T = [1, 0.8] ]). 


%= structure transformation

nal_example_test(
  inference([similarity(ext_set([tweety]), ext_set([birdie])), [1, 0.9]], [similarity(tweety, birdie), T]) ,
 [ T = [1, 0.9] ]). 

nal_example_test(
  inference([similarity(int_set([smart]), int_set([bright])), [0.8, 0.9]], [similarity(smart, bright), T]) ,
 [ T = [0.8, 0.9] ]). 


% ----- NAL-3 ----- %

%= compound construction, two premises

nal_example_test(
  inference([inheritance(swan, swimmer), [0.9, 0.9]], [inheritance(swan, bird), [0.8, 0.9]], R) ,
 [ R = [inheritance(swan, ext_intersection([swimmer, bird])), [0.72, 0.81]] ;
   R = [inheritance(swan, int_intersection([swimmer, bird])), [0.98, 0.81]] ;
   R = [inheritance(swan, ext_difference(swimmer, bird)), [0.18, 0.81]] ]). 

nal_example_test(
  inference([inheritance(sport, competition), [0.9, 0.9]], [inheritance(chess, competition), [0.8, 0.9]], R) ,
 [ R = [inheritance(int_intersection([sport, chess]), competition), [0.72, 0.81]] ;
   R = [inheritance(ext_intersection([sport, chess]), competition), [0.98, 0.81]] ;
   R = [inheritance(int_difference(sport, chess), competition), [0.18, 0.81]] ]). 


%= compound construction, single premise

nal_example_test(
  inference([inheritance(swan, swimmer), [0.9, 0.8]], [inheritance(swan, ext_intersection([swimmer, bird])), V]) ,
 [ V = [0.9, 0.44] ]). 

nal_example_test(
  inference([inheritance(swan, swimmer), [0.9, 0.8]], [inheritance(swan, int_intersection([swimmer, bird])), V]) ,
 [ V = [0.9, 0.72] ]). 

nal_example_test(
  inference([inheritance(swan, swimmer), [0.9, 0.8]], [inheritance(swan, ext_difference(swimmer, bird)), V]) ,
 [ V = [0.9, 0.44] ]). 

nal_example_test(
  inference([inheritance(swan, swimmer), [0.9, 0.8]], [negation(inheritance(swan, ext_difference(bird, swimmer))), V]) ,
 [ V = [0.9, 0.72] ]). 

nal_example_test(
  inference([inheritance(sport, competition), [0.9, 0.8]], [inheritance(int_intersection([sport, chess]), competition), V]) ,
 [ V = [0.9, 0.44] ]). 

nal_example_test(
  inference([inheritance(sport, competition), [0.9, 0.8]], [inheritance(ext_intersection([sport, chess]), competition), V]) ,
 [ V = [0.9, 0.72] ]). 

nal_example_test(
  inference([inheritance(sport, competition), [0.9, 0.8]], [inheritance(int_difference(sport, chess), competition), V]) ,
 [ V = [0.9, 0.44] ]). 

nal_example_test(
  inference([inheritance(sport, competition), [0.9, 0.8]], [negation(inheritance(int_difference(chess, sport), competition)), V]) ,
 [ V = [0.9, 0.72] ]). 


%= compound destruction, two premises

nal_example_test(
  inference([inheritance(swan, bird), [1, 0.8]], [inheritance(swan, ext_intersection([swimmer, bird])), [0, 0.8]], [inheritance(swan, swimmer), T]) ,
 [ T = [0, 0.64] ]). 

nal_example_test(
  inference([inheritance(swan, bird), [0, 0.8]], [inheritance(swan, int_intersection([swimmer, bird])), [1, 0.8]], [inheritance(swan, swimmer), T]) ,
 [ T = [1, 0.64] ]). 

nal_example_test(
  inference([inheritance(swan, swimmer), [1, 0.8]], [inheritance(swan, ext_difference(swimmer, bird)), [0, 0.8]], [inheritance(swan, bird), T]) ,
 [ T = [1, 0.64] ]). 

nal_example_test(
  inference([inheritance(swan, bird), [0, 0.8]], [inheritance(swan, ext_difference(swimmer, bird)), [0, 0.8]], [inheritance(swan, swimmer), T]) ,
 [ T = [0, 0.64] ]). 

nal_example_test(
  inference([inheritance(sport, competition), [1, 0.8]], [inheritance(int_intersection([sport, chess]), competition), [0, 0.8]], [inheritance(chess, competition), V]) ,
 [ V = [0, 0.64] ]). 

nal_example_test(
  inference([inheritance(sport, competition), [0, 0.8]], [inheritance(ext_intersection([sport, chess]), competition), [1, 0.8]], [inheritance(chess, competition), V]) ,
 [ V = [1, 0.64] ]). 

nal_example_test(
  inference([inheritance(sport, competition), [1, 0.8]], [inheritance(int_difference(sport, chess), competition), [0, 0.8]], [inheritance(chess, competition), V]) ,
 [ V = [1, 0.64] ]). 

nal_example_test(
  inference([inheritance(chess, competition), [0, 0.8]], [inheritance(int_difference(sport, chess), competition), [0, 0.8]], [inheritance(sport, competition), V]) ,
 [ V = [0, 0.64] ]). 


%= compound destruction, single premise

nal_example_test(
  inference([inheritance(swan, ext_intersection([swimmer, bird])), [0.9, 0.8]], [inheritance(swan, swimmer), V]) ,
 [ V = [0.9, 0.72] ]). 

nal_example_test(
  inference([inheritance(swan, int_intersection([swimmer, bird])), [0.9, 0.8]], [inheritance(swan, swimmer), V]) ,
 [ V = [0.9, 0.44] ]). 

nal_example_test(
  inference([inheritance(swan, ext_difference(swimmer, bird)), [0.9, 0.8]], [inheritance(swan, swimmer), V]) ,
 [ V = [0.9, 0.72] ]). 

nal_example_test(
  inference([inheritance(swan, ext_difference(swimmer, bird)), [0.9, 0.8]], [negation(inheritance(swan, bird)), V]) ,
 [ V = [0.9, 0.72] ]). 

nal_example_test(
  inference([inheritance(int_intersection([sport, chess]), competition), [0.9, 0.8]], [inheritance(sport, competition), V]) ,
 [ V = [0.9, 0.72] ]). 

nal_example_test(
  inference([inheritance(ext_intersection([sport, chess]), competition), [0.9, 0.8]], [inheritance(sport, competition), V]) ,
 [ V = [0.9, 0.44] ]). 

nal_example_test(
  inference([inheritance(int_difference(sport, chess), competition), [0.9, 0.8]], [inheritance(sport, competition), V]) ,
 [ V = [0.9, 0.72] ]). 

nal_example_test(
  inference([inheritance(int_difference(sport, chess), competition), [0.9, 0.8]], [negation(inheritance(chess, competition)), V]) ,
 [ V = [0.9, 0.72] ]). 


%= operation on both sides of a relation

nal_example_test(
  inference([inheritance(bird, animal), [0.9, 0.8]], [inheritance(ext_intersection([swimmer, bird]), ext_intersection([swimmer, animal])), V]) ,
 [ V = [0.9, 0.72] ]). 

nal_example_test(
  inference([inheritance(ext_intersection([swimmer, bird]), ext_intersection([swimmer, animal])), [0.9, 0.8]], [inheritance(bird, animal), V]) ,
 [ V = [0.9, 0.44] ]). 

nal_example_test(
  inference([inheritance(bird, animal), [0.9, 0.8]], [inheritance(int_intersection([swimmer, bird]), int_intersection([swimmer, animal])), V]) ,
 [ V = [0.9, 0.72] ]). 

nal_example_test(
  inference([inheritance(int_intersection([swimmer, bird]), int_intersection([swimmer, animal])), [0.9, 0.8]], [inheritance(bird, animal), V]) ,
 [ V = [0.9, 0.44] ]). 

nal_example_test(
  inference([similarity(bird, animal), [0.9, 0.8]], [similarity(ext_intersection([swimmer, bird]), ext_intersection([swimmer, animal])), V]) ,
 [ V = [0.9, 0.72] ]). 

nal_example_test(
  inference([similarity(ext_intersection([swimmer, bird]), ext_intersection([swimmer, animal])), [0.9, 0.8]], [similarity(bird, animal), V]) ,
 [ V = [0.9, 0.44] ]). 

nal_example_test(
  inference([similarity(bird, animal), [0.9, 0.8]], [similarity(int_intersection([swimmer, bird]), int_intersection([swimmer, animal])), V]) ,
 [ V = [0.9, 0.72] ]). 

nal_example_test(
  inference([similarity(int_intersection([swimmer, bird]), int_intersection([swimmer, animal])), [0.9, 0.8]], [similarity(bird, animal), V]) ,
 [ V = [0.9, 0.44] ]). 

nal_example_test(
  inference([inheritance(bird, animal), [0.9, 0.8]], [inheritance(ext_difference(bird, swimmer), ext_difference(animal, swimmer)), V]) ,
 [ V = [0.9, 0.72] ]). 

nal_example_test(
  inference([inheritance(ext_difference(bird, swimmer), ext_difference(animal, swimmer)), [0.9, 0.8]], [inheritance(bird, animal), V]) ,
 [ V = [0.9, 0.44] ]). 

nal_example_test(
  inference([inheritance(bird, animal), [0.9, 0.8]], [inheritance(int_difference(bird, swimmer), int_difference(animal, swimmer)), V]) ,
 [ V = [0.9, 0.72] ]). 

nal_example_test(
  inference([inheritance(int_difference(bird, swimmer), int_difference(animal, swimmer)), [0.9, 0.8]], [inheritance(bird, animal), V]) ,
 [ V = [0.9, 0.44] ]). 

nal_example_test(
  inference([similarity(bird, animal), [0.9, 0.8]], [similarity(ext_difference(bird, swimmer), ext_difference(animal, swimmer)), V]) ,
 [ V = [0.9, 0.72] ]). 

nal_example_test(
  inference([similarity(ext_difference(bird, swimmer), ext_difference(animal, swimmer)), [0.9, 0.8]], [similarity(bird, animal), V]) ,
 [ V = [0.9, 0.44] ]). 

nal_example_test(
  inference([similarity(bird, animal), [0.9, 0.8]], [similarity(int_difference(bird, swimmer), int_difference(animal, swimmer)), V]) ,
 [ V = [0.9, 0.72] ]). 

nal_example_test(
  inference([similarity(int_difference(bird, swimmer), int_difference(animal, swimmer)), [0.9, 0.8]], [similarity(bird, animal), V]) ,
 [ V = [0.9, 0.44] ]). 

nal_example_test(
  inference([inheritance(bird, animal), [0.9, 0.8]], [inheritance(ext_difference(swimmer, animal), ext_difference(swimmer, bird)), V]) ,
 [ V = [0.9, 0.72] ]). 

nal_example_test(
  inference([inheritance(ext_difference(swimmer, animal), ext_difference(swimmer, bird)), [0.9, 0.8]], [inheritance(bird, animal), V]) ,
 [ V = [0.9, 0.44] ]). 

nal_example_test(
  inference([inheritance(bird, animal), [0.9, 0.8]], [inheritance(int_difference(swimmer, animal), int_difference(swimmer, bird)), V]) ,
 [ V = [0.9, 0.72] ]). 

nal_example_test(
  inference([inheritance(int_difference(swimmer, animal), int_difference(swimmer, bird)), [0.9, 0.8]], [inheritance(bird, animal), V]) ,
 [ V = [0.9, 0.44] ]). 

nal_example_test(
  inference([similarity(bird, animal), [0.9, 0.8]], [similarity(ext_difference(swimmer, animal), ext_difference(swimmer, bird)), V]) ,
 [ V = [0.9, 0.72] ]). 

nal_example_test(
  inference([similarity(ext_difference(swimmer, animal), ext_difference(swimmer, bird)), [0.9, 0.8]], [similarity(bird, animal), V]) ,
 [ V = [0.9, 0.44] ]). 

nal_example_test(
  inference([similarity(bird, animal), [0.9, 0.8]], [similarity(int_difference(swimmer, animal), int_difference(swimmer, bird)), V]) ,
 [ V = [0.9, 0.72] ]). 

nal_example_test(
  inference([similarity(int_difference(swimmer, animal), int_difference(swimmer, bird)), [0.9, 0.8]], [similarity(bird, animal), V]) ,
 [ V = [0.9, 0.44] ]). 


%= set operations

nal_example_test(
  inference([inheritance(ext_set([earth]), ext_set([venus, mars, pluto])), [0.9, 0.8]], [inheritance(ext_set([earth]), ext_set([pluto, saturn])), [0.7, 0.8]], R) ,
 [ R = [inheritance(ext_set([earth]), ext_set([pluto])), [0.63, 0.64]] ;
   R = [inheritance(ext_set([earth]), ext_set([venus, mars, pluto, saturn])), [0.97, 0.64]] ;
   R = [inheritance(ext_set([earth]), ext_set([venus, mars])), [0.27, 0.64]] ]). 

nal_example_test(
  inference([inheritance(int_set([red, green, blue]), int_set([colorful])), [0.9, 0.8]], 
            [inheritance(int_set([purple, green]), int_set([colorful])), [0.7, 0.8]], R) ,
 [ R = [inheritance(int_set([green]), int_set([colorful])), [0.63, 0.64]] ;
   R = [inheritance(int_set([red, blue, purple, green]), int_set([colorful])), [0.97, 0.64]] ;
   R = [inheritance(int_set([red, blue]), int_set([colorful])), [0.271, 0.64]] ]). 


% ----- NAL-4 ----- %

%= extensional image

nal_example_test(
  inference([inheritance(product([acid, base]), reaction), [1, 0.9]], C) ,
 [ C = [inheritance(acid, ext_image(reaction, [nil, base])), [1, 0.9]] ;
   C = [inheritance(base, ext_image(reaction, [acid, nil])), [1, 0.9]] ]). 

nal_example_test(
  inference([inheritance(acid, ext_image(reaction, [nil, base])), [1, 0.9]], C) ,
 [ C = [inheritance(product([acid, base]), reaction), [1, 0.9]] ]). 

nal_example_test(
  inference([inheritance(acid, ext_image(reaction, [acid, nil])), [1, 0.9]], C) ,
 [ C = [inheritance(product([acid, acid]), reaction), [1, 0.9]] ]). 


%= intensional image

nal_example_test(
  inference([inheritance(neutralization, product([acid, base])), [1, 0.9]], C) ,
 [ C = [inheritance(int_image(neutralization, [nil, base]), acid), [1, 0.9]] ;
   C = [inheritance(int_image(neutralization, [acid, nil]), base), [1, 0.9]] ]). 

nal_example_test(
  inference([inheritance(int_image(neutralization, [nil, base]), acid), [1, 0.9]], C) ,
 [ C = [inheritance(neutralization, product([acid, base])), [1, 0.9]] ]). 

nal_example_test(
  inference([inheritance(int_image(neutralization, [acid, nil]), base), [1, 0.9]], C) ,
 [ C = [inheritance(neutralization, product([acid, base])), [1, 0.9]] ]). 


%= operation on both sides of a relation

nal_example_test(
  inference([inheritance(bird, animal), [0.9, 0.8]], [inheritance(product([bird, plant]), product([animal, plant])), V]) ,
 [ V = [0.9, 0.8] ]). 

nal_example_test(
  inference([inheritance(product([plant, bird]), product([plant, animal])), [0.9, 0.8]], [inheritance(bird, animal), V]) ,
 [ V = [0.9, 0.8] ]). 

nal_example_test(
  inference([inheritance(neutralization, reaction), [0.9, 0.8]], [inheritance(ext_image(neutralization, [acid, nil]), ext_image(reaction, [acid, nil])), V]) ,
 [ V = [0.9, 0.72] ]). 

nal_example_test(
  inference([inheritance(ext_image(neutralization, [acid, nil]), ext_image(reaction, [acid, nil])), [0.9, 0.8]], [inheritance(neutralization, reaction), V]) ,
 [ V = [0.9, 0.44] ]). 

nal_example_test(
  inference([inheritance(neutralization, reaction), [0.9, 0.8]], [inheritance(int_image(neutralization, [acid, nil]), int_image(reaction, [acid, nil])), V]) ,
 [ V = [0.9, 0.72] ]). 

nal_example_test(
  inference([inheritance(int_image(neutralization, [acid, nil]), int_image(reaction, [acid, nil])), [0.9, 0.8]], [inheritance(neutralization, reaction), V]) ,
 [ V = [0.9, 0.44] ]). 

nal_example_test(
  inference([inheritance(soda, base), [0.9, 0.8]], [inheritance(ext_image(reaction, [nil, base]), ext_image(reaction, [nil, soda])), V]) ,
 [ V = [0.9, 0.72] ]). 

nal_example_test(
  inference([inheritance(ext_image(reaction, [nil, base]), ext_image(reaction, [nil, soda])), [0.9, 0.8]], [inheritance(soda, base), V]) ,
 [ V = [0.9, 0.44] ]). 

nal_example_test(
  inference([inheritance(soda, base), [0.9, 0.8]], [inheritance(int_image(neutralization, [nil, base]), int_image(neutralization, [nil, soda])), V]) ,
 [ V = [0.9, 0.72] ]). 

nal_example_test(
  inference([inheritance(int_image(neutralization, [nil, base]), int_image(neutralization, [nil, soda])), [0.9, 0.8]], [inheritance(soda, base), V]) ,
 [ V = [0.9, 0.44] ]). 


% ----- NAL-5 ----- %

%= revision

nal_example_test(
  revision([implication(inheritance(robin, flyer), inheritance(robin, bird)), [1, 0.8]], [implication(inheritance(robin, flyer), inheritance(robin, bird)), [0, 0.5]], R) ,
 [ R = [implication(inheritance(robin, flyer), inheritance(robin, bird)), [0.8, 0.83]] ]). 

nal_example_test(
  revision([equivalence(inheritance(robin, flyer), inheritance(robin, bird)), [1, 0.8]], [equivalence(inheritance(robin, flyer), inheritance(robin, bird)), [0, 0.5]], R) ,
 [ R = [equivalence(inheritance(robin, flyer), inheritance(robin, bird)), [0.8, 0.83]] ]). 


%= choice

nal_example_test(
  choice([implication(inheritance(robin, flyer), inheritance(robin, bird)), [1, 0.8]], [implication(inheritance(robin, flyer), inheritance(robin, bird)), [0, 0.5]], R) ,
 [ R = [implication(inheritance(robin, flyer), inheritance(robin, bird)), [1, 0.8]] ]). 

nal_example_test(
  choice([implication(inheritance(robin, flyer), inheritance(robin, bird)), [0.8, 0.9]], [implication(inheritance(robin, swimmer), inheritance(robin, bird)), [1, 0.5]], R) ,
 [ R = [implication(inheritance(robin, flyer), inheritance(robin, bird)), [0.8, 0.9]] ]). 


%= deduction

nal_example_test(
  inference([implication(inheritance(robin, bird), inheritance(robin, animal)), [0.9, 0.8]], [implication(inheritance(robin, flyer), inheritance(robin, bird)), [1, 0.5]], R) ,
 [ R = [implication(inheritance(robin, flyer), inheritance(robin, animal)), [0.9, 0.36]] ]). 

nal_example_test(
  inference([equivalence(inheritance(robin, bird), inheritance(robin, animal)), [0.9, 0.8]], [equivalence(inheritance(robin, flyer), inheritance(robin, bird)), [1, 0.5]], R) ,
 [ R = [equivalence(inheritance(robin, flyer), inheritance(robin, animal)), [0.9, 0.4]] ]). 


%= induction

nal_example_test(
  inference([implication(inheritance(robin, bird), inheritance(robin, animal)), [0.9, 0.8]], [implication(inheritance(robin, bird), inheritance(robin, flyer)), [1, 0.5]], R) ,
 [ R = [implication(inheritance(robin, flyer), inheritance(robin, animal)), [0.9, 0.29]] ]). 


%= abduction

nal_example_test(
  inference([implication(inheritance(robin, bird), inheritance(robin, animal)), [0.9, 0.8]], [implication(inheritance(robin, flyer), inheritance(robin, animal)), [1, 0.5]], R) ,
 [ R = [implication(inheritance(robin, flyer), inheritance(robin, bird)), [1, 0.26]] ]). 


%= examplification

nal_example_test(
  inference([implication(inheritance(robin, flyer), inheritance(robin, bird)), [0.9, 0.8]], [implication(inheritance(robin, bird), inheritance(robin, animal)), [1, 0.5]], R) ,
 [ R = [implication(inheritance(robin, animal), inheritance(robin, flyer)), [1, 0.26]] ]). 


%= convension

nal_example_test(
  inference([implication(inheritance(robin, flyer), inheritance(robin, animal)), [0.9, 0.8]], R) ,
 [ R = [implication(inheritance(robin, animal), inheritance(robin, flyer)), [1, 0.42]] ]). 

nal_example_test(
  inference([equivalence(inheritance(robin, flyer), inheritance(robin, bird)), [0.9, 0.8]], [implication(inheritance(robin, flyer), inheritance(robin, bird)), V]) ,
 [ V = [0.9, 0.72] ]). 

nal_example_test(
  inference([implication(inheritance(robin, flyer), inheritance(robin, bird)), [0.9, 0.8]], [implication(inheritance(robin, bird), inheritance(robin, flyer)), [0.9, 0.8]], R) ,
 [ R = [equivalence(inheritance(robin, flyer), inheritance(robin, bird)), [0.81, 0.64]] ]). 

nal_example_test(
  inference([similarity(swan, bird), [0.9, 0.8]], [inheritance(swan, bird), V]) ,
 [ V = [0.9, 0.72] ]). 

nal_example_test(
  inference([inheritance(swan, bird), [0.9, 0.8]], [similarity(swan, bird), V]) ,
 [ V = [0.9, 0.44] ]). 

nal_example_test(
  inference([inheritance(swan, bird), [1, 0.8]], [inheritance(bird, swan), [0.1, 0.8]], R) ,
 [ R = [similarity(swan, bird), [0.1, 0.64]] ]). 


%= comparison

nal_example_test(
  inference([implication(inheritance(robin, bird), inheritance(robin, animal)), [0.9, 0.8]], [implication(inheritance(robin, bird), inheritance(robin, flyer)), [0.9, 0.8]], [equivalence(A, B), V]) ,
 [ A = inheritance(robin, flyer),
   B = inheritance(robin, animal),
   V = [0.82, 0.39] ]). 

nal_example_test(
  inference([implication(inheritance(robin, bird), inheritance(robin, animal)), [0.9, 0.8]], [implication(inheritance(robin, flyer), inheritance(robin, animal)), [0.9, 0.8]], [equivalence(A, B), V]) ,
 [ % R = [equivalence(inheritance(robin, flyer), inheritance(robin, bird)), [0.818182, 0.387855]] ;
   A = inheritance(robin, flyer),
   B = inheritance(robin, bird),
   V = [0.82, 0.39] ]). 


%= analogy

nal_example_test(
  inference([implication(inheritance(robin, bird), inheritance(robin, animal)), [0.9, 0.8]], [equivalence(inheritance(robin, flyer), inheritance(robin, animal)), [0.9, 0.8]], R) ,
 [ R = [implication(inheritance(robin, bird), inheritance(robin, flyer)), [0.81, 0.58]] ]). 

nal_example_test(
  inference([implication(inheritance(robin, bird), inheritance(robin, animal)), [0.9, 0.8]], [equivalence(inheritance(robin, flyer), inheritance(robin, bird)), [0.9, 0.8]], R) ,
 [ R = [implication(inheritance(robin, flyer), inheritance(robin, animal)), [0.81, 0.58]] ]). 


%= compound construction, two premises

nal_example_test(
  inference([implication(inheritance(robin, bird), inheritance(robin, animal)), [0.9, 0.8]], [implication(inheritance(robin, bird), inheritance(robin, flyer)), [0.9, 0.8]], R) ,
 [ R = [implication(inheritance(robin, bird), conjunction([inheritance(robin, animal), inheritance(robin, flyer)])), [0.81, 0.64]] ;
   R = [implication(inheritance(robin, bird), disjunction([inheritance(robin, animal), inheritance(robin, flyer)])), [0.99, 0.64]] ]). 

nal_example_test(
  inference([implication(inheritance(robin, bird), inheritance(robin, animal)), [0.9, 0.8]], [implication(inheritance(robin, flyer), inheritance(robin, animal)), [0.9, 0.8]], R) ,
 [ R = [implication(disjunction([inheritance(robin, bird), inheritance(robin, flyer)]), inheritance(robin, animal)), [0.81, 0.64]] ;
   R = [implication(conjunction([inheritance(robin, bird), inheritance(robin, flyer)]), inheritance(robin, animal)), [0.99, 0.64]] ]). 

nal_example_test(
  inference([inheritance(robin, animal), [0.9, 0.9]], [inheritance(robin, flyer), [0.9, 0.9]], [conjunction([inheritance(robin, animal), inheritance(robin, flyer)]), V]) ,
 [ V = [0.81, 0.81] ]). 

nal_example_test(
  inference([inheritance(robin, animal), [0.9, 0.8]], [inheritance(robin, flyer), [0.9, 0.8]], [disjunction([inheritance(robin, animal), inheritance(robin, flyer)]), V]) ,
 [ V = [0.99, 0.64] ]). 


%= compound construction, single premise

nal_example_test(
  inference([implication(inheritance(robin, bird), inheritance(robin, animal)), [0.9, 0.8]], [implication(inheritance(robin, bird), conjunction([inheritance(robin, animal), inheritance(robin, flyer)])), V]) ,
 [ V = [0.9, 0.44] ]). 

nal_example_test(
  inference([implication(inheritance(robin, bird), inheritance(robin, animal)), [0.9, 0.8]], [implication(inheritance(robin, bird), disjunction([inheritance(robin, animal), inheritance(robin, flyer)])), V]) ,
 [ V = [0.9, 0.72] ]). 

nal_example_test(
  inference([implication(inheritance(robin, bird), inheritance(robin, animal)), [0.9, 0.8]], [implication(disjunction([inheritance(robin, bird), inheritance(robin, flyer)]), inheritance(robin, animal)), V]) ,
 [ V = [0.9, 0.44] ]). 

nal_example_test(
  inference([implication(inheritance(robin, bird), inheritance(robin, animal)), [0.9, 0.8]], [implication(conjunction([inheritance(robin, bird), inheritance(robin, flyer)]), inheritance(robin, animal)), V]) ,
 [ V = [0.9, 0.72] ]). 

nal_example_test(
  inference([inheritance(robin, animal), [0.9, 0.8]], [conjunction([inheritance(robin, animal), inheritance(robin, flyer)]), V]) ,
 [ V = [0.9, 0.44] ]). 

nal_example_test(
  inference([inheritance(robin, animal), [0.9, 0.8]], [disjunction([inheritance(robin, animal), inheritance(robin, flyer)]), V]) ,
 [ V = [0.9, 0.72] ]). 


%= compound destruction, two premises

nal_example_test(
  inference([implication(inheritance(robin, bird), inheritance(robin, flyer)), [1, 0.8]], [implication(inheritance(robin, bird), conjunction([inheritance(robin, animal), inheritance(robin, flyer)])), [0, 0.8]], [implication(inheritance(robin, bird), inheritance(robin, animal)), T]) ,
 [ T = [0, 0.64] ]). 

nal_example_test(
  inference([implication(inheritance(robin, bird), inheritance(robin, flyer)), [0, 0.8]], [implication(inheritance(robin, bird), disjunction([inheritance(robin, animal), inheritance(robin, flyer)])), [1, 0.8]], [implication(inheritance(robin, bird), inheritance(robin, animal)), T]) ,
 [ T = [1, 0.64] ]). 

nal_example_test(
  inference([implication(inheritance(robin, bird), inheritance(robin, animal)), [1, 0.8]], [implication(disjunction([inheritance(robin, bird), inheritance(robin, flyer)]), inheritance(robin, animal)), [0, 0.8]], [implication(inheritance(robin, flyer), inheritance(robin, animal)), T]) ,
 [ T = [0, 0.64] ]). 

nal_example_test(
  inference([implication(inheritance(robin, bird), inheritance(robin, animal)), [0, 0.8]], [implication(conjunction([inheritance(robin, bird), inheritance(robin, flyer)]), inheritance(robin, animal)), [1, 0.8]], [implication(inheritance(robin, flyer), inheritance(robin, animal)), T]) ,
 [ T = [1, 0.64] ]). 

nal_example_test(
  inference([inheritance(robin, bird), [1, 0.8]], [conjunction([inheritance(robin, bird), inheritance(robin, flyer)]), [0, 0.8]], R) ,
 [ R = [inheritance(robin, flyer), [0, 0.64]] ]). 

nal_example_test(
  inference([inheritance(robin, bird), [0, 0.8]], [disjunction([inheritance(robin, bird), inheritance(robin, flyer)]), [1, 0.8]], R) ,
 [ R = [inheritance(robin, flyer), [1, 0.64]] ]). 


%= compound destruction, single premise

nal_example_test(
  inference([implication(inheritance(robin, bird), conjunction([inheritance(robin, animal), inheritance(robin, flyer)])), [0.9, 0.8]], [implication(inheritance(robin, bird), inheritance(robin, animal)), V]) ,
 [ V = [0.9, 0.72] ]). 

nal_example_test(
  inference([implication(inheritance(robin, bird), disjunction([inheritance(robin, animal), inheritance(robin, flyer)])), [0.9, 0.8]], [implication(inheritance(robin, bird), inheritance(robin, animal)), V]) ,
 [ V = [0.9, 0.44] ]). 

nal_example_test(
  inference([implication(disjunction([inheritance(robin, bird), inheritance(robin, flyer)]), inheritance(robin, animal)), [0.9, 0.8]], [implication(inheritance(robin, bird), inheritance(robin, animal)), V]) ,
 [ V = [0.9, 0.72] ]). 

nal_example_test(
  inference([implication(conjunction([inheritance(robin, bird), inheritance(robin, flyer)]), inheritance(robin, animal)), [0.9, 0.8]], [implication(inheritance(robin, bird), inheritance(robin, animal)), V]) ,
 [ V = [0.9, 0.44] ]). 

nal_example_test(
  inference([conjunction([inheritance(robin, bird), inheritance(robin, flyer)]), [0.9, 0.8]], [inheritance(robin, bird),V]) ,
 [ V = [0.9, 0.72] ]). 

nal_example_test(
  inference([disjunction([inheritance(robin, bird), inheritance(robin, flyer)]), [0.9, 0.8]], [inheritance(robin, bird),V]) ,
 [ V = [0.9, 0.44] ]). 


%= operation on both sides of a relation

nal_example_test(
  inference([implication(p, q), [0.9, 0.8]], [implication(conjunction([p, r]), conjunction([q, r])), V]) ,
 [ V = [0.9, 0.72] ]). 

nal_example_test(
  inference([implication(conjunction([p, r]), conjunction([q, r])), [0.9, 0.8]], [implication(p, q), V]) ,
 [ V = [0.9, 0.44] ]). 

nal_example_test(
  inference([implication(p, q), [0.9, 0.8]], [implication(disjunction([p, r]), disjunction([q, r])), V]) ,
 [ V = [0.9, 0.72] ]). 

nal_example_test(
  inference([implication(disjunction([p, r]), disjunction([q, r])), [0.9, 0.8]], [implication(p, q), V]) ,
 [ V = [0.9, 0.44] ]). 

nal_example_test(
  inference([equivalence(p, q), [0.9, 0.8]], [equivalence(conjunction([p, r]), conjunction([q, r])), V]) ,
 [ V = [0.9, 0.72] ]). 

nal_example_test(
  inference([equivalence(conjunction([p, r]), conjunction([q, r])), [0.9, 0.8]], [equivalence(p, q), V]) ,
 [ V = [0.9, 0.44] ]). 

nal_example_test(
  inference([equivalence(p, q), [0.9, 0.8]], [equivalence(disjunction([p, r]), disjunction([q, r])), V]) ,
 [ V = [0.9, 0.72] ]). 

nal_example_test(
  inference([equivalence(disjunction([p, r]), disjunction([q, r])), [0.9, 0.8]], [equivalence(p, q), V]) ,
 [ V = [0.9, 0.44] ]). 


%= negation

nal_example_test(
  inference([negation(inheritance(robin, bird)), [0.9, 0.8]], R) ,
 [ R = [inheritance(robin, bird), [0.1, 0.8]] ]). 

nal_example_test(
  inference([inheritance(robin, bird), [0.2, 0.8]], [negation(inheritance(robin, bird)), T]) ,
 [ T = [0.8, 0.8] ]). 

nal_example_test(
  inference([implication(negation(inheritance(penguin, flyer)), inheritance(penguin, swimmer)), [0.1, 0.8]], [implication(negation(inheritance(penguin, swimmer)), inheritance(penguin, flyer)), T]) ,
 [ T = [0, 0.42] ]). 


%= conditional inference

nal_example_test(
  inference([implication(inheritance(robin, bird), inheritance(robin, animal)), [0.9, 0.8]], [inheritance(robin, bird), [1, 0.5]], R) ,
 [ R = [inheritance(robin, animal), [0.9, 0.36]] ]). 

nal_example_test(
  inference([implication(inheritance(robin, bird), inheritance(robin, animal)), [0.9, 0.8]], [inheritance(robin, animal), [1, 0.5]], R) ,
 [ R = [inheritance(robin, bird), [1, 0.26]] ]). 

nal_example_test(
  inference([inheritance(robin, animal), [0.9, 0.8]], [inheritance(robin, flyer), [1, 0.5]], [implication(inheritance(robin, flyer), inheritance(robin, animal)), V]) ,
 [ V = [0.9, 0.29] ]). 

nal_example_test(
  inference([inheritance(robin, animal), [1, 0.5]], [equivalence(inheritance(robin, flyer), inheritance(robin, animal)), [0.9, 0.8]], R) ,
 [ R = [inheritance(robin, flyer), [0.9, 0.36]] ]). 

nal_example_test(
  inference([inheritance(robin, animal), [0.9, 0.8]], [inheritance(robin, flyer), [1, 0.5]], [equivalence(inheritance(robin, flyer), inheritance(robin, animal)), V]) ,
 [ V = [0.9, 0.29] ]). 

nal_example_test(
  inference([implication(conjunction([a1, a2, a3]), c), [0.9, 0.9]], [a2, [0.9, 0.9]], R) ,
 [ R = [implication(conjunction([a1, a3]), c), [0.81, 0.66]] ]). 

nal_example_test(
  inference([implication(conjunction([a1, a2, a3]), c), [0.9, 0.9]], [implication(conjunction([a1, a3]), c), [0.9, 0.9]], [a2, V]) ,
 [ V = [0.9, 0.42] ]). 

nal_example_test(
  inference([implication(conjunction([a1, a3]), c), [0.9, 0.9]], [a2, [0.9, 0.9]], [implication(conjunction([a2, a1, a3]), c), V]) ,
 [ V = [0.9, 0.42] ]). 

nal_example_test(
  inference([implication(conjunction([a1, a2, a3]), c), [0.9, 0.9]], [implication(b2, a2), [0.9, 0.9]], R) ,
 [ R = [implication(conjunction([a1, b2, a3]), c), [0.81, 0.66]] ]). 

nal_example_test(
  inference([implication(conjunction([a1, a2, a3]), c), [0.9, 0.9]], [implication(conjunction([a1, b2, a3]), c), [0.9, 0.9]], [implication(b2, a2), V]) ,
 [ V = [0.9, 0.42] ]). 

nal_example_test(
  inference([implication(conjunction([a1, b2, a3]), c), [0.9, 0.9]], [implication(b2, a2), [0.9, 0.9]], R) ,
 [ R = [implication(conjunction([a1, a2, a3]), c), [0.9, 0.42]] ]). 


% ----- NAL-6 ----- %

%= variable unification

nal_example_test(
  revision([implication(inheritance(X, bird), inheritance(X, flyer)), [0.9, 0.8]], [implication(inheritance(Y, bird), inheritance(Y, flyer)), [1, 0.5]], R) ,
 [ R = [implication(inheritance(Y, bird), inheritance(Y, flyer)), [0.92, 0.83]] ]). 

nal_example_test(
  inference([implication(inheritance(X, bird), inheritance(X, animal)), [1, 0.9]], [implication(inheritance(Y, robin), inheritance(Y, bird)), [1, 0.9]], R) ,
 [ R = [implication(inheritance(Y, robin), inheritance(Y, animal)), [1, 0.81]] ]). 
  
nal_example_test(
  inference([implication(inheritance(X, bird), inheritance(X, animal)), [1, 0.9]], [implication(inheritance(Y, robin), inheritance(Y, animal)), [1, 0.9]], R) ,
 [ R = [implication(inheritance(Y, robin), inheritance(Y, bird)), [1, 0.45]] ]). 

nal_example_test(
  inference([implication(inheritance(X, robin), inheritance(X, animal)), [1, 0.9]], [implication(inheritance(Y, robin), inheritance(Y, bird)), [1, 0.9]], R) ,
 [ R = [implication(inheritance(Y, bird), inheritance(Y, animal)), [1, 0.45]] ]). 

nal_example_test(
  inference([implication(inheritance(X, feathered), inheritance(X, bird)), [1, 0.9]], [equivalence(inheritance(Y, flyer), inheritance(Y, bird)), [1, 0.9]], R) ,
 [ R = [implication(inheritance(Y, feathered), inheritance(Y, flyer)), [1, 0.81]] ]). 

nal_example_test(
  inference([implication(inheritance(X, feathered), inheritance(X, flyer)), [1, 0.9]], [implication(inheritance(Y, feathered), inheritance(Y, bird)), [1, 0.9]], R) ,
 [ R = [implication(inheritance(Y, bird), inheritance(Y, flyer)), [1, 0.45]] ]). 

nal_example_test(
  inference([implication(conjunction([inheritance(X, feathered), inheritance(X, flyer)]), inheritance(X, bird)), [1, 0.9]], [implication(inheritance(Y, swimmer), inheritance(Y, feathered)), [1, 0.9]], R) ,
 [ R = [implication(conjunction([inheritance(Y, swimmer), inheritance(Y, flyer)]), inheritance(Y, bird)), [1, 0.81]] ]). 

nal_example_test(
  inference([implication(conjunction([inheritance(X, feathered), inheritance(X, flyer)]), inheritance(X, bird)), [1, 0.9]], [implication(conjunction([inheritance(X, swimmer), inheritance(X, flyer)]), inheritance(X, bird)), [1, 0.9]], R) ,
 [ R = [implication(inheritance(X, swimmer), inheritance(X, feathered)), [1, 0.45]] ]). 

nal_example_test(
  inference([implication(conjunction([inheritance(X, swimmer), inheritance(X, flyer)]), inheritance(X, bird)), [1, 0.9]], [implication(inheritance(Y, swimmer), inheritance(Y, feathered)), [1, 0.9]], R) ,
 [ R = [implication(conjunction([inheritance(Y, feathered), inheritance(Y, flyer)]), inheritance(Y, bird)), [1, 0.45]] ]). 

nal_example_test(
  inference([implication(conjunction([inheritance(X, feathered), inheritance(X, flyer)]), inheritance(X, bird)), [1, 0.9]], [implication(inheritance(Y, swimmer), inheritance(Y, feathered)), [1, 0.9]], R) ,
 [ R = [implication(conjunction([inheritance(Y, swimmer), inheritance(Y, flyer)]), inheritance(Y, bird)), [1, 0.81]] ]). 


%= variable elimination

nal_example_test(
  inference([implication(inheritance(X, bird), inheritance(X, animal)), [1, 0.9]], [inheritance(robin, bird), [1, 0.9]], R) ,
 [ R = [inheritance(robin, animal), [1, 0.81]] ]). 

nal_example_test(
  inference([implication(inheritance(X, bird), inheritance(X, animal)), [1, 0.9]], [inheritance(robin, animal), [1, 0.9]], R) ,
 [ R = [inheritance(robin, bird), [1, 0.45]] ]). 

nal_example_test(
  inference([inheritance(robin, animal), [1, 0.9]], [equivalence(inheritance(X, bird), inheritance(X, animal)), [1, 0.9]], R) ,
 [ R = [inheritance(robin, bird), [1, 0.81]] ]). 

nal_example_test(
  inference([implication(conjunction([inheritance(X, feathered), inheritance(X, flyer)]), inheritance(X, bird)), [1, 0.9]], [inheritance(swan, feathered), [1, 0.9]], R) ,
 [ R = [implication(inheritance(swan, flyer), inheritance(swan, bird)), [1, 0.81]] ]). 

nal_example_test(
  inference([conjunction([inheritance(var(X, []), bird), inheritance(var(X, []), swimmer)]), [1, 0.9]], [inheritance(swan, bird), [1, 0.9]], [inheritance(swan, swimmer), V]) ,
 [ V = [1, 0.42] ]). 

nal_example_test(
  inference([conjunction([inheritance(var(X, []), flyer), inheritance(var(X, []), bird), inheritance(var(X, []), swimmer)]), [1, 0.9]], [inheritance(swan, bird), [1, 0.9]], R) ,
 [ R = [conjunction([inheritance(swan, flyer), inheritance(swan, swimmer)]), [1, 0.42]] ]). 


%= variable introduction

nal_example_test(
  inference([inheritance(robin, animal), [1, 0.9]], [inheritance(robin, bird), [1, 0.9]], R) ,
 [ R = [implication(inheritance(G650, bird), inheritance(G650, animal)), [1, 0.45]] ;
   R = [equivalence(inheritance(G650, bird), inheritance(G650, animal)), [1, 0.45]] ;
   R = [conjunction([inheritance(var(G655, []), bird), inheritance(var(G655, []), animal)]), [1, 0.81]] ]). 

nal_example_test(
  inference([inheritance(sport, competition), [1, 0.9]], [inheritance(chess, competition), [1, 0.9]], R) ,
 [ R = [implication(inheritance(sport, G738), inheritance(chess, G738)), [1, 0.45]] ;
   R = [equivalence(inheritance(sport, G738), inheritance(chess, G738)), [1, 0.45]] ;
   R = [conjunction([inheritance(chess, var(G742, [])), inheritance(sport, var(G742, []))]), [1, 0.81]] ]). 


%= multiple variables

nal_example_test(
  inference([inheritance(key1, ext_image(open, [nil, lock1])), [1, 0.9]], [inheritance(key1, key), [1, 0.9]], R) ,
 [ R = [implication(inheritance(G836, key), inheritance(G836, ext_image(open, [nil, lock1]))), [1, 0.45]] ;
   R = [conjunction([inheritance(var(G841, []), key), inheritance(var(G841, []), ext_image(open, [nil, lock1]))]), [1, 0.81]] ]). 

nal_example_test(
  inference([implication(inheritance(X, key), inheritance(lock1, ext_image(open, [X, nil]))), [1, 0.9]], [inheritance(lock1, lock), [1, 0.9]], R) ,
 [ R = [implication(conjunction([inheritance(X, key), inheritance(G1233, lock)]), inheritance(G1233, ext_image(open, [X, nil]))), [1, 0.45]] ;
   R = [conjunction([implication(inheritance(X, key), inheritance(var(G1233, []), ext_image(open, [X, nil]))), inheritance(var(G1233, []), lock)]), [1, 0.81]] ]). 

nal_example_test(
  inference([conjunction([inheritance(var(X, []), key), inheritance(lock1, ext_image(open, [var(X, []), nil]))]), [1, 0.9]],[inheritance(lock1, lock), [1, 0.9]], R) ,
 [ R = [implication(inheritance(G1367, lock), conjunction([inheritance(G1367, ext_image(open, [var(X, [G1367]), nil])), inheritance(var(X, [G1367]), key)])), [1, 0.45]] ;
   R = [conjunction([inheritance(var(G1372, []), lock), inheritance(var(G1372, []), ext_image(open, [var(X, []), nil])), inheritance(var(X, []), key)]), [1, 0.81]] ]). 

