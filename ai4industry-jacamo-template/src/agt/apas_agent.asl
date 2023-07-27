/* 
apas_agent controlling the Robot Arm. 
It acts on a thing described by: https://ci.mines-stetienne.fr/kg/itmfactory/bosch-apas#this
It has:
- the following action affordances:
-- grasp
-- moveTo
-- release
- the following property affordances:
-- inMovement
-- grasping

@author Olivier Boissier (Mines Saint-Etienne)
*/


/* Initial beliefs and rules */

td_name(boschApas). // boch-apas

thing(boschApas,Thing) :-
      thing(Thing)
      & bosch_apas(Thing)
      & has_action_affordance(Thing, MoveAction)
      & move_from_to_action(MoveAction)
      & has_action_affordance(Thing, GraspAction)
      & grasp_action(GraspAction)
      & has_action_affordance(Thing, ReleaseAction)
      & release_action(ReleaseAction)
      & has_property_affordance(Thing, InMovement)
      & activity_status(InMovement)
      & name(InMovement,"inMovement")
      & has_property_affordance(Thing, Grasping)
      & activity_status(Grasping)
      & name(Grasping,"grasping")
  .

+!start :
    name(Name)
    <-
    .print("Belief base is under initialization");
    !!run(Name);
  .

+!run(Name) : 
    thing(Name,Thing) 
    <-
    .print("Found suitable RobotArm : ", Thing) ;
    // To also execute the requests, remove the second init parameter (dryRun flag).
    // When dryRun is set to true, the requests are printed (but not executed).
    makeArtifact(Name, "org.hypermedea.ThingArtifact", [Thing], ArtId);
    focus(ArtId);
    // set credentials to access the Thing (DX10 workshop of the IT'm factory)
    ?credentials(SimuName,SimuPasswd);
    setAuthCredentials(SimuName, SimuPasswd)[artifact_id(ArtId)] ;

    ?has_origin_coordinates(Name,CX,CY,CZ);
    .println(Thing, " has origin coordinates ",CX," ",CY," ",CZ);

    !getDescription(Thing);

    !testStatus(Name);

    // Not necessary to get all of them regularly. 
    // Choose and comment, otherwise there is a risk of
    // consuming all the computing resources
    !observeInMovement(Name);
    !observeGrasping(Name);

    !potItems(Name);

    !testStatus(Name);
  .

+!run(Name) :
    true
    <-
    .wait(100);
    !!run(Name);
  .

+!testStatus(Name) :
    true
    <-
    ?inMovement(Name,ValueI);
    .println("TEST In Movement ",ValueI);
    ?grasping(Name,ValueG);
    .println("TEST Grasping ",ValueG);
  .

+!potItems(Name) :
    location_conveyor(Lc)
    & location_packaging(Lp)
    <-
    !carry(Name,Lc,Lp);
    .wait(1000);
    !!potItems(Name);
  .

// Fake plan. Adapt.
+!carry(Name,From,To) :
    true
    <-
    .println("carrying a pot from ",From," to ",To);
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

+propertyValue("inMovement", X) :
    true
    <-
    .println("inMovement is now ", X);
  .

+propertyValue("grasping", X) :
    true
    <-
    .println("grasping is now ", X);
  .

{ include("inc/robot_arm_skills.asl") }
{ include("inc/common.asl") }
{ include("inc/owl-signature.asl") }

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
