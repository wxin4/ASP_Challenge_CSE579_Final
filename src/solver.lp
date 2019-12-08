%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sort And Object Declaration (Types/Fluents/Actions/Constants)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% node(X,Y)
% highway(X,Y)
% robot(Robot_ID)
% shelf(Shelf_ID)
% pickingstation(PickingStation_ID)
% product(Product_ID)
% curr_position(TYPE(ID),node(X,Y)) - current position of TYPE()
% carries(Robot_ID,Shelf_ID) - robot is carrying a shelf
% on(Product_ID,Shelf_ID,AMOUNT) - how many products on the shelf
% order(Request_ID,Product_ID,PickingStation_ID,Order_Amount) - request ID, product ID and picking station targeted
% complete(Request_ID,Product_ID,PickingStation_ID,Order_Amount) - order is completed
% move(DX,DY) - shelf pick up -> moving with robot
% pickup - robot is currently carrying a shelf
% putdown - robot is not carrying a shelf

% constants
#const inc = true.
% incremental is true (step++)
#const stop_at = "SATISFIABLE".
% stop at the state that is SATISFIABLE
#const min_step = 0.
#const max_step = 30.
% set the minimal step as 0 and maximum step is 30 so that when step exceedes 30 then we stop the implementaion


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% State Description
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#program base.

% initial state as False
has(False,0) :- init(False).

% turning project description's statement to what we implemented as above
node(X,Y) :- init(object(node, ID), value(at, (X, Y))).
highway(X,Y) :- init(object(highway, ID), value(at, (X, Y))).
init(curr_position(robot(ID), node(X, Y))) :- init(object(robot, ID), value(at, (X, Y))).
init(curr_position(shelf(ID), node(X, Y))) :- init(object(shelf, ID), value(at, (X, Y))).
init(curr_position(pickingstation(ID), node(X, Y))) :- init(object(pickingStation, ID), value(at, (X, Y))).
init(on(ID, ShelfID, Amount)) :- init(object(product, ID), value(on, (ShelfID, Amount))).
init(order(ID, Item, StationID, Amount)) :- init(object(order, ID), value(line, (Item, Amount))), init(object(order,ID),value(pickingStation, StationID)).
init(carries(Robot_ID,Shelf_ID)) :- init(object(robot, Robot_ID), value(carries, Shelf_ID)).
robot(Robot) :- init(curr_position(robot(Robot), node(_,_))).
shelf(Shelf) :- init(curr_position(shelf(Shelf), node(_,_))).

#program step(t).

% turning project description's statement to what we implemented as above
occurs(object(robot, Robot_ID), action(move, (DX,DY)), t) :- occurs(robot(Robot_ID),move(DX,DY),t).
occurs(object(robot, Robot_ID), action(pickup, ()), t) :- occurs(robot(Robot_ID),pickup,t).
occurs(object(robot, Robot_ID), action(putdown, ()), t) :- occurs(robot(Robot_ID),putdown,t).
occurs(object(robot, Robot_ID), action(deliver, (Request_ID, Product_ID, Order_Amount)), t) :- occurs(robot(Robot_ID),deliver(Request_ID, Product_ID, Order_Amount),t).

% next possible positions after time step t (can only move by 1 grid per time step)
next_position(-1,0,Robot_ID,t) :- has(curr_position(robot(Robot_ID),node(X,Y)),t), node(X-1,Y).
next_position(1,0,Robot_ID,t) :- has(curr_position(robot(Robot_ID),node(X,Y)),t), node(X+1,Y).
next_position(0,1,Robot_ID,t) :- has(curr_position(robot(Robot_ID),node(X,Y)),t), node(X,Y+1).
next_position(0,-1,Robot_ID,t) :- has(curr_position(robot(Robot_ID),node(X,Y)),t), node(X,Y-1).

% next possible cases
%% case 1: just move...
next_move_1(Robot_ID,move(X,Y),t) :- next_position(X,Y,Robot_ID,t-1).

%% case 2: move and pickup
next_move_2(Robot_ID,move(X,Y),t) :- next_position(X,Y,Robot_ID,t-1).
next_move_2(Robot_ID,pickup,t) :- robot(Robot_ID).

%% case 3: move and putdown
next_move_3(Robot_ID,move(X,Y),t) :- next_position(X,Y,Robot_ID,t-1).
next_move_3(Robot_ID,putdown,t) :- robot(Robot_ID).

%% case 4: move and deliver
next_move_4(Robot_ID,move(X,Y),t) :- next_position(X,Y,Robot_ID,t-1).
next_move_4(Robot_ID,deliver(Request_ID, Product_ID, AMOUNT),t) :- robot(Robot_ID), init(order(Request_ID, Product_ID, StationID, Order_Amount)), AMOUNT = 1..Order_Amount.

% 4 different cases definitions

%% just move which there is no shelf on the robot
move_1(t,Robot_ID) :- has(curr_position(robot(Robot_ID),node(X,Y)),t), not has(curr_position(shelf(_),node(X,Y)),t).

%% move and pickup which there is a shelf but with no product on it
move_2(t,Robot_ID) :- has(curr_position(robot(Robot_ID),node(X,Y)),t), has(curr_position(shelf(Shelf_ID),node(X,Y)),t), not has(carries(Robot_ID,Shelf_ID),t).

%% move and putdown which there is a shelf and product(s) on it
move_3(t,Robot_ID) :- has(curr_position(robot(Robot_ID),node(X,Y)),t), has(curr_position(shelf(Shelf_ID),node(X,Y)),t), has(carries(Robot_ID,Shelf_ID),t), not init(curr_position(pickingstation(_), node(X,Y))).

%% move and deliver which there is a shelf and product(s) on it and robot is at the pickingstation with the currect order on it.
move_4(t,Robot_ID,Request_ID,Item,Amt) :- has(carries(Robot_ID,Shelf_ID),t), has(curr_position(robot(Robot_ID),node(X,Y)),t), has(curr_position(shelf(Shelf_ID),node(X,Y)),t), init(curr_position(pickingstation(ID),node(X, Y))), init(order(Request_ID, Item, ID, Amount)), init(on(Item, Shelf_ID, Amt)).

% robots have to make their own decisions on each of the 4 cases and there is at most 1 case occurs at the same time step
{occurs(robot(Robot_ID),A,t):next_move_1(Robot_ID,A,t)}1 :- move_1(t-1,Robot_ID).
{occurs(robot(Robot_ID),A,t):next_move_2(Robot_ID,A,t)}1 :- move_2(t-1,Robot_ID).
{occurs(robot(Robot_ID),A,t):next_move_3(Robot_ID,A,t)}1 :- move_3(t-1,Robot_ID).
{occurs(robot(Robot_ID),A,t):next_move_4(Robot_ID,A,t)}1 :- move_4(t-1,Robot_ID,_,_,_).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Effects And Preconditions Of Actions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% if robot moves by (X,Y), then we print out the current position with how it moved
has(curr_position(robot(Robot_ID),node(X+DX,Y+DY)),t) :- node(X+DX,Y+DY), has(curr_position(robot(Robot_ID),node(X,Y)),t-1), occurs(robot(Robot_ID),move(DX,DY),t).

% so does shelves.
has(curr_position(shelf(Shelf_ID),node(X+DX,Y+DY)),t) :- node(X+DX,Y+DY), has(curr_position(robot(Robot_ID),node(X,Y)),t-1), occurs(robot(Robot_ID),move(DX,DY),t), has(carries(Robot_ID,Shelf_ID),t-1).

% if the order contains less than the actual product storage, we will decrease the number of the product storage by the order amount
has(on(Product_ID,Shelf_ID,AMOUNT-Order_Amount),t) :- AMOUNT>Order_Amount, has(on(Product_ID,Shelf_ID,AMOUNT),t-1), has(carries(Robot_ID,Shelf_ID),t-1), occurs(object(robot, Robot_ID), action(deliver, (Request_ID, Product_ID, Order_Amount)), t).

% if the order contains more than the actual product storage, we will not do the delivery
has(order(Request_ID,Product_ID,PSID,Order_Amount-AMOUNT),t) :-	AMOUNT < Order_Amount, has(order(Request_ID,Product_ID,PSID,Order_Amount),t-1), occurs(object(robot, Robot_ID), action(deliver, (Request_ID, Product_ID, AMOUNT)), t).

% if the order is delivered and the request ID is over, we say the order is completed.
has(complete(Request_ID,Product_ID,PSID,Order_Amount),t) :- has(order(Request_ID,Product_ID,PSID,Order_Amount),t-1), occurs(object(robot, Robot_ID), action(deliver, (Request_ID, Product_ID, Order_Amount)), t).

% if a robot picks up products based on the order, we say the robot is carrying the shelf as well. Very important constraint
has(carries(Robot_ID,Shelf_ID),t) :- has(curr_position(robot(Robot_ID),node(X,Y)),t), has(curr_position(shelf(Shelf_ID),node(X,Y)),t), occurs(robot(Robot_ID),pickup,t).

% if the robot moves by(_,_), we say robot moved no matter how
moved(robot(Robot_ID),t) :- occurs(robot(Robot_ID),move(_,_),t), robot(Robot_ID).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Domain Independent Axioms
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Commonsense law of inertia
has(False,t) :- has(False,t-1), not impossible(False,t).

% it is impossible that the robot is moved but still stays at the same spot
impossible(curr_position(robot(Robot_ID),node(X,Y)),t) :- has(curr_position(robot(Robot_ID),node(X,Y)),t-1), moved(robot(Robot_ID),t).			

% same as the shelf position
impossible(curr_position(shelf(Shelf_ID),node(X,Y)),t) :- has(curr_position(shelf(Shelf_ID),node(X,Y)),t-1), has(carries(Robot_ID,Shelf_ID),t-1), moved(robot(Robot_ID),t).

% also same as the robot carries shelves
impossible(carries(Robot_ID,Shelf_ID),t) :- has(carries(Robot_ID,Shelf_ID),t-1), occurs(robot(Robot_ID),putdown,t).

% it is impossible that robot successfully delivered a product but the shelf still has the previous amount of products
impossible(on(Product_ID,Shelf_ID,AMOUNT),t) :- has(on(Product_ID,Shelf_ID,AMOUNT),t-1), has(carries(Robot_ID,Shelf_ID),t-1), occurs(object(robot, Robot_ID), action(deliver, (Request_ID, Product_ID, Order_Amount)), t).

% not-quite understand this constraint!
impossible(order(Request_ID,Product_ID,PickingStation_ID,Order_Amount),t) :- has(order(Request_ID,Product_ID,PickingStation_ID,Order_Amount),t-1), occurs(object(robot, Robot_ID), action(deliver, (Request_ID, Product_ID, AMOUNT)), t).

% it is impossible that after a successful delivery and the previous order still exists
impossible(order(Request_ID,Product_ID,PickingStation_ID,Order_Amount),t) :- has(complete(Request_ID,Product_ID,PickingStation_ID,Order_Amount),t).

% it is impossible that after a successful delivery and the completion holds again
impossible(complete(Request_ID,Product_ID,PickingStation_ID,Order_Amount),t) :- has(complete(Request_ID,Product_ID,PickingStation_ID,Order_Amount),t-1).


% robots should never collide (swapping positions)
:- has(curr_position(robot(RID1),node(X1,Y1)),t), has(curr_position(robot(RID2),node(X2,Y2)),t), has(curr_position(robot(RID1),node(X2,Y2)),t-1), has(curr_position(robot(RID2),node(X1,Y1)),t-1), RID1<RID2, |X2-X1|+|Y2-Y1|==1.

% robots cannot do nothing but moving on the highway
:- highway(X,Y), has(curr_position(robot(Robot_ID),node(X,Y)),t), occurs(robot(Robot_ID),putdown,t).

% don't let the robot do looping (squaring) in clock-wise or counter clock-wise
:- occurs(robot(Robot_ID),move(A,B),t), occurs(robot(Robot_ID),move(X,Y),t+1), occurs(robot(Robot_ID),move(-A,-B),t+2), occurs(robot(Robot_ID),move(-X,-Y),t+3).
:- occurs(robot(Robot_ID),move(A,B),t), occurs(robot(Robot_ID),move(X,Y),t+1), occurs(robot(Robot_ID),move(-X,-Y),t+2), occurs(robot(Robot_ID),move(-A,-B),t+3).

% same as above, do not do circulation movement
:- occurs(robot(Robot_ID),move(A,B),t),occurs(robot(Robot_ID),move(C,D),t+1),occurs(robot(Robot_ID),move(E,F),t+2),occurs(robot(Robot_ID),move(G,H),t+3),has(curr_position(robot(Robot_ID),node(X,Y)),t-1),has(curr_position(robot(Robot_ID),node(X,Y)),t+3).

% if there is not enough product or there is indeed no product on the specific shelf, then we do not deliver
:- occurs(robot(Robot_ID),deliver(O,I,U),t), has(carries(Robot_ID,Shelf_ID),t-1), has(on(I,Shelf_ID,AMOUNT),t-1), U > AMOUNT.
:- occurs(robot(Robot_ID),deliver(O,I,U),t), has(carries(Robot_ID,Shelf_ID),t-1), not has(on(I,Shelf_ID,_),t-1).

% only one robot can be at a node at the same time step
:- node(X,Y), 2{has(curr_position(robot(Robot_ID),node(X,Y)),t): robot(Robot_ID)}.
:- robot(Robot_ID), 2{has(curr_position(robot(Robot_ID),node(X,Y)),t) : node(X,Y)}.

% same as shelf
:- node(X,Y), 2{has(curr_position(shelf(Shelf_ID),node(X,Y)),t): shelf(Shelf_ID)}.
:- shelf(Shelf_ID), 2{has(curr_position(shelf(Shelf_ID),node(X,Y)),t) : node(X,Y)}.

% robots should not do anything more than one steps
:- highway(X,Y), has(curr_position(robot(Robot_ID),node(X,Y)),t), not moved(robot(Robot_ID),t-1), not moved(robot(Robot_ID),t), not init(curr_position(robot(Robot_ID),node(X,Y))).

% robots must be at a node
:- highway(X,Y), not node(X,Y).

% robot cannot make more than one actions per time step
:- occurs(robot(Robot_ID), MOVEMENT_1,t), occurs(robot(Robot_ID), MOVEMENT_2,t), MOVEMENT_1 != MOVEMENT_2.

% robots should not do opposite movements at the previous time step, e.g. move left -> move right -> move left -> move right ......
% or pickup -> putdown -> pickup -> putdown
:- occurs(robot(Robot_ID),move(DX,DY),t), occurs(robot(Robot_ID),move(-DX,-DY),t-1).
:- occurs(robot(Robot_ID),pickup,t), occurs(robot(Robot_ID),putdown,t-1).
:- occurs(robot(Robot_ID),putdown,t), occurs(robot(Robot_ID),pickup,t-1).

% clingo check and query
#program check(t).
#external query(t).

% final goal constraint
goal(t) :- not has(order(_,_,_,_),t).
:- not goal(t), query(t).

% #minimize{Robot_ID,T : occurs(robot(Robot_ID),_,T)}.
% output
#program base.
#show occurs/3.

