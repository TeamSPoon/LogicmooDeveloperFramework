% MAZE

% 0123456
% wwwwwww 0
% w++++gw 1
% w+wwwww 2
% w+w+w+w 3
% wA++++w 4
% wwwwwww 5

cell((0..6, 0..5)).

% (X+1,Y) is right next to (X,Y)
adjacent(right, (X+1,Y),(X,Y))   :- cell((X,Y)), cell((X+1,Y)).

adjacent(left,(X,Y),  (X+1,Y)) :- cell((X,Y)), cell((X+1,Y)).

% (X,Y+1) is above next to (X,Y)
adjacent(up, (X,Y+1),(X,Y))   :- cell((X,Y)), cell((X,Y+1)).

adjacent(down,   (X,Y),  (X,Y+1)) :- cell((X,Y)), cell((X,Y+1)).

#modeh(state_after(var(cell))).

#modeb(1, adjacent(const(action), var(cell), var(cell))).
#modeb(1, state_before(var(cell)), (positive)).
#modeb(1, action(const(action)),(positive)).
#modeb(1, wall(var(cell))).

#max_penalty(100).

#constant(action, right).
#constant(action, left).
#constant(action, down).
#constant(action, up).
#constant(action, non).

#pos({state_after((1,3))}, {state_after((2,4)),state_after((1,5)),state_after((0,4)),state_after((1,4))}, {state_before((1,4)). action(down). wall((1, 5)). wall((0, 4)). }).
#pos({state_after((1,2))}, {state_after((2,3)),state_after((1,4)),state_after((0,3)),state_after((1,3))}, {state_before((1,3)). action(down). wall((2, 3)). wall((0, 3)). }).
#pos({state_after((1,1))}, {state_after((2,2)),state_after((1,3)),state_after((0,2)),state_after((1,2))}, {state_before((1,2)). action(down). wall((2, 2)). wall((0, 2)). }).
#pos({state_after((1,1))}, {state_after((2,1)),state_after((1,2)),state_after((0,1)),state_after((1,0))}, {state_before((1,1)). action(down). wall((0, 1)). wall((1, 0)). }).
#pos({state_after((1,1))}, {state_after((2,1)),state_after((1,2)),state_after((0,1)),state_after((1,0))}, {state_before((1,1)). action(left). wall((0, 1)). wall((1, 0)). }).
#pos({state_after((1,2))}, {state_after((2,1)),state_after((0,1)),state_after((1,0)),state_after((1,1))}, {state_before((1,1)). action(up). wall((0, 1)). wall((1, 0)). }).
#pos({state_after((1,3))}, {state_after((2,2)),state_after((0,2)),state_after((1,1)),state_after((1,2))}, {state_before((1,2)). action(up). wall((2, 2)). wall((0, 2)). }).
#pos({state_after((1,4))}, {state_after((2,3)),state_after((0,3)),state_after((1,2)),state_after((1,3))}, {state_before((1,3)). action(up). wall((2, 3)). wall((0, 3)). }).
#pos({state_after((1,4))}, {state_after((2,4)),state_after((1,5)),state_after((0,4)),state_after((1,3))}, {state_before((1,4)). action(up). wall((1, 5)). wall((0, 4)). }).
#pos({state_after((1,4))}, {state_after((2,4)),state_after((1,5)),state_after((0,4)),state_after((1,3))}, {state_before((1,4)). action(left). wall((1, 5)). wall((0, 4)). }).
#pos({state_after((2,4))}, {state_after((1,5)),state_after((0,4)),state_after((1,3)),state_after((1,4))}, {state_before((1,4)). action(right). wall((1, 5)). wall((0, 4)). }).
#pos({state_after((2,4))}, {state_after((3,4)),state_after((2,5)),state_after((1,4)),state_after((2,3))}, {state_before((2,4)). action(non). wall((2, 5)). wall((2, 3)). }).
#pos({state_after((2,4))}, {state_after((3,4)),state_after((2,5)),state_after((1,4)),state_after((2,3))}, {state_before((2,4)). action(down). wall((2, 5)). wall((2, 3)). }).
#pos({state_after((2,4))}, {state_after((3,4)),state_after((2,5)),state_after((1,4)),state_after((2,3))}, {state_before((2,4)). action(up). wall((2, 5)). wall((2, 3)). }).
#pos({state_after((1,4))}, {state_after((3,4)),state_after((2,5)),state_after((2,3)),state_after((2,4))}, {state_before((2,4)). action(left). wall((2, 5)). wall((2, 3)). }).
#pos({state_after((1,4))}, {state_after((2,4)),state_after((1,5)),state_after((0,4)),state_after((1,3))}, {state_before((1,4)). action(non). wall((1, 5)). wall((0, 4)). }).
#pos({state_after((1,3))}, {state_after((2,4)),state_after((1,5)),state_after((0,4)),state_after((1,4))}, {state_before((1,4)). action(down). wall((1, 5)). wall((0, 4)). }).
#pos({state_after((1,3))}, {state_after((2,3)),state_after((1,4)),state_after((0,3)),state_after((1,2))}, {state_before((1,3)). action(left). wall((2, 3)). wall((0, 3)). }).
#pos({state_after((1,2))}, {state_after((2,3)),state_after((1,4)),state_after((0,3)),state_after((1,3))}, {state_before((1,3)). action(down). wall((2, 3)). wall((0, 3)). }).
#pos({state_after((1,2))}, {state_after((2,2)),state_after((1,3)),state_after((0,2)),state_after((1,1))}, {state_before((1,2)). action(left). wall((2, 2)). wall((0, 2)). }).
#pos({state_after((1,4))}, {state_after((2,4)),state_after((1,5)),state_after((0,4)),state_after((1,3))}, {state_before((1,4)). action(up). wall((1, 5)). wall((0, 4)). }).
#pos({state_after((1,4))}, {state_after((2,4)),state_after((1,5)),state_after((0,4)),state_after((1,3))}, {state_before((1,4)). action(left). wall((1, 5)). wall((0, 4)). }).
#pos({state_after((2,4))}, {state_after((1,5)),state_after((0,4)),state_after((1,3)),state_after((1,4))}, {state_before((1,4)). action(right). wall((1, 5)). wall((0, 4)). }).
#pos({state_after((3,4))}, {state_after((2,5)),state_after((1,4)),state_after((2,3)),state_after((2,4))}, {state_before((2,4)). action(right). wall((2, 5)). wall((2, 3)). }).
#pos({state_after((3,3))}, {state_after((4,4)),state_after((3,5)),state_after((2,4)),state_after((3,4))}, {state_before((3,4)). action(down). wall((3, 5)). }).
