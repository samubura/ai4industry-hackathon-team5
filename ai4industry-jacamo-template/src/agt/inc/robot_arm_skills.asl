/* 

@author Olivier Boissier (Mines Saint-Etienne)
*/

// location_conveyor([-0.5,0.5,0.2]). // relative position of conveyor
 location_conveyor([2.2,0,1]). // absolute position of conveyor
// location_packaging([0.5,0.5,0.2]). // relative position of packaging workshop
 location_packaging([3.2,0,1]). // absolute position of packaging workshop

/*
location_conveyor("dx10",ValueX, ValueY, ValueZ) :-
      thing(Name,Thing)
      & entryPoint(Base)
      & builder(Thing, Base, "ontology#hasOriginCoordinates", Temp)
      & builder(Temp, Base, "ontology#coordX",ValueX)
      & builder(Temp, Base, "ontology#coordY",ValueY)
      & builder(Temp, Base, "ontology#coordZ",ValueZ)
  .

location_packaging("xy10",ValueX, ValueY, ValueZ) :-
      thing(Name,Thing)
      & entryPoint(Base)
      & builder(Thing, Base, "ontology#hasOriginCoordinates", Temp)
      & builder(Temp, Base, "ontology#coordX",ValueX)
      & builder(Temp, Base, "ontology#coordY",ValueY)
      & builder(Temp, Base, "ontology#coordZ",ValueZ)
  .
*/
has_origin_coordinates(Name,ValueX, ValueY, ValueZ) :-
      thing(Name,Thing)
      & entryPoint(Base)
      & builder(Thing, Base, "ontology#hasOriginCoordinates", Temp)
      & builder(Temp, Base, "ontology#coordX",ValueX)
      & builder(Temp, Base, "ontology#coordY",ValueY)
      & builder(Temp, Base, "ontology#coordZ",ValueZ)
  .

+!testStatus(Name) :
    true
    <-
    ?inMovement(Name,ValueI);
    .println("TEST In Movement ",ValueI);
    ?grasping(Name,ValueG);
    .println("TEST Grasping ",ValueG);
  .

// Plan for invoking the action affordance reset
+!reset(Name) :
    thing(Name,Thing)
    <-
    ?reset_action(Thing,ActionName);
    invokeAction(ActionName)[artifact_name(Name)];
    .println("invoked operation ",ActionName," on ",Thing);
  .

// contingency plan in case the achievement of goal !reset fails
-!reset(Name) :
    thing(Name,Thing)
    <-
    .println("---> ",Thing," has no reset operation");
  .

// Plan for invoking the action affordance release
+!release(Name,At) :
    thing(Name,Thing)
    & release_action(Thing,ActionName)
    <-
    invokeAction(ActionName)[artifact_name(Name)];
    .println("invoked operation ",ActionName," with parameter ",At," on ",Thing);
  .

// Plan for invoking the action affordance grasp
+!grasp(Name,At) :
    thing(Name,Thing)
    & grasp_action(Thing,ActionName)
    <-
    .println("invoking operation ",ActionName," with parameter ",At," on ",Thing);
    invokeAction(ActionName)[artifact_name(Name)];
    .println("invoked operation ",ActionName," with parameter ",At," on ",Thing);
  .

// contingency plan in case the achievement of goal !grasp fails
-!grasp(Name,At) :
    thing(Name,Thing)
    & grasp_action(Thing,ActionName)
    <-
    .println("---> Grasp operation failed ");
    .wait(3000);
    !grasp(Name,At);
  .

// Plan for invoking the move affordance grasp
+!move(Name,[X,Y,Z]) :
    thing(Name,Thing)
    & move_action(Thing,ActionName)
    <-
    invokeAction(ActionName,json([kv(x,X),kv(y,Y),kv(z,Z)]))[artifact_name(Name)];
    .println("invoked operation ",ActionName," with parameter X ",X," Y ",Y," Z ",Z," on ",Thing);
  .

+!observeInMovement(Name) :
    timer(Timer)
    & thing(Name,Thing)
    & in_movement_property(Thing,PName)
    <-
    !observeProperty(Name,PName,Timer);
    .println("observing ",PName," on ",Thing);
  .

+!observeGrasping(Name) :
    timer(Timer)
    & thing(Name,Thing)
    & grasping_property(Thing,PName)
    <-
    !observeProperty(Name,PName,Timer);
    .println("observing ",PName," on ",Thing);
  .



// HORS HACKATHON
+?inMovement(Name,Value) :
    thing(Name,Thing)
    & in_movement_property(Thing,PName)
    <-
    readProperty(PName,Value)[artifact_name(Name)];
    .println(Name,"---> ",Thing," current in Movement ",Value," for ",PName);
  .


+?grasping(Name,Value) :
    thing(Name,Thing)
    & grasping_property(Thing,PName)
    <-
    readProperty(PName,Value)[artifact_name(Name)];
    .println(Name,"---> ",Thing," current grasping ",Value," for ",FullName," ",PName);
  .

