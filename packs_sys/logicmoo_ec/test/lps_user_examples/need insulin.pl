:- expects_dialect(lps).

/* This is based on the example in Bench-Capon, 
Persuasion in practical argument using value-based argumentation
frameworks. Journal of Logic and Computation, 13(3):429–448, 2003.
https://academic.oup.com/logcom/article-pdf/13/3/429/4241286/130429.pdf

In this representation, different values are represented 
by different goals and constraints.
*/

fluents has/2, need/2, diabetic/1, paid/3.
events highBloodSugar/1, obtain/2.
actions takeFrom/3, use/2, pay/3.

initially  has(dave, insulin), has(carla, insulin), diabetic(dave).

% Here 1 and 2 are "cycle times" during which "time stands still". 
%
observe highBloodSugar(bob) from 1 to 2.

% Causal laws, similar to the event caclulus, 
% but with destructive updates:
%
takeFrom(Person1, Person2, Object) 
updates Person2 to Person1 in has(Person2, Object)
if has(Person2, Object).

pay(Person1, Person2, Object) 
initiates paid(Person1, Person2, Object).

% This rule is a goal, which generates actions to make itself true:
if 		highBloodSugar(Person)
then 	obtain(Person, insulin), use(Person, insulin).

% obtain/2 is a macroaction/plan:
obtain(Person, Object) from T to T if has(Person, Object) at T.
obtain(Person1, Object) from T1 to T2 if has(Person2, Object) at T1, 
			takeFrom(Person1, Person2, Object) from T1 to T2.

/* Optional additional goal:
if takeFrom(Person1, Person2, Object), not paid(Person1, Person2, Object)
then pay(Person1, Person2, Object).

Optional additional goal/constraint:
false takeFrom(Person1, Person2, Object), need(Person2, Object).

need(Person, insulin) if diabetic(Person). 
*/ 

% These two constraints are necessary because the interpreter tries all alternatives in parallel.
% 
false takeFrom(Person1, Person2, Object), 
	has(Person1, Object).

false takeFrom(Person1, Person2, Object), 
	takeFrom(Person1, Person3, Object), 
	Person2 \= Person3.





