%ILASP

%state_after(V0) :- adjacent(right, V0, V1), state_before(V1), action(right).
%state_after(V1) :- adjacent(down, V0, V1), state_before(V0), action(up).
%state_after(V0) :- adjacent(down, V0, V1), state_before(V1), action(down).
%state_after(V0) :- adjacent(right, V0, V1), action(left), wall(V1).
%state_after(V0) :- adjacent(left, V0, V1), state_before(V1), action(left), not wall(V0).
cell((0..19, 0..8)).
#modeb(1, link_start(var(cell)), (positive)).
#modeb(1, link_dest(var(cell)), (positive)).
% (X+1,Y) is right next to (X,Y)
adjacent(right, (X+1,Y),(X,Y))   :- cell((X,Y)), cell((X+1,Y)).

adjacent(left,(X,Y),  (X+1,Y)) :- cell((X,Y)), cell((X+1,Y)).

% (X,Y+1) is above next to (X,Y)
adjacent(down, (X,Y+1),(X,Y))   :- cell((X,Y)), cell((X,Y+1)).

adjacent(up,   (X,Y),  (X,Y+1)) :- cell((X,Y)), cell((X,Y+1)).

#modeh(state_after(var(cell))).

#modeb(1, adjacent(const(action), var(cell), var(cell)), (positive)).
#modeb(1, state_before(var(cell)), (positive)).
#modeb(1, action(const(action)), (positive)).
#modeb(1, wall(var(cell))).

#max_penalty(50).

#constant(action, right).
#constant(action, left).
#constant(action, down).
#constant(action, up).
#pos({state_after((2,5))}, {state_after((4,5)),state_after((3,6)),state_after((3,4)),state_after((3,5))}, {state_before((3,5)).action(left).}).
#pos({state_after((3,5))}, {state_after((2,6)),state_after((1,5)),state_after((2,4)),state_after((2,5)),state_after((1,5))}, {state_before((2,5)).action(right).}).
#pos({}, {state_after((4,5)),state_after((3,6)),state_after((3,4)),state_after((3,5))}, {state_before((3,5)).action(left).}).
#pos({}, {state_after((3,5)),state_after((2,6)),state_after((2,4)),state_after((2,5))}, {state_before((2,5)).action(left).}).
#pos({state_after((1,4))}, {state_after((2,5)),state_after((1,6)),state_after((0,5)),state_after((1,5))}, {state_before((1,5)).action(up).wall((0, 5)). }).
#pos({}, {state_after((2,4)),state_after((1,5)),state_after((0,4)),state_after((1,4))}, {state_before((1,4)).action(up).wall((0, 4)). }).
#pos({}, {state_after((1,4)),state_after((0,3)),state_after((1,2)),state_after((1,3))}, {state_before((1,3)).action(right).wall((0, 3)). }).
#pos({state_after((2,4))}, {state_after((3,3)),state_after((1,3)),state_after((2,2)),state_after((2,3))}, {state_before((2,3)).action(down).}).
#pos({}, {state_after((3,4)),state_after((1,4)),state_after((2,3)),state_after((2,4))}, {state_before((2,4)).action(down).}).
#pos({}, {state_after((3,5)),state_after((2,6)),state_after((2,4)),state_after((2,5))}, {state_before((2,5)).action(left).}).
#pos({}, {state_after((1,6)),state_after((0,5)),state_after((1,4)),state_after((1,5))}, {state_before((1,5)).action(right).wall((0, 5)). }).
#pos({}, {state_after((3,5)),state_after((2,6)),state_after((2,4)),state_after((2,5))}, {state_before((2,5)).action(left).}).
#pos({state_after((1,5))}, {state_after((2,5)),state_after((1,6)),state_after((0,5)),state_after((1,4)),state_after((0,5))}, {state_before((1,5)).action(left).wall((0, 5)). }).
