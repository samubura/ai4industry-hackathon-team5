/* 
Agent controlling the storage rack.

It acts on a Thing described by:
https://ci.mines-stetienne.fr/kg/itmfactory/vl10
It has:
- the following action affordances:
-- pressEmergencyStop
-- pickItem
- the following property affordances:
-- positionX
-- capacity
-- positionZ
-- conveyorSpeed
-- clampStatus
-- stackLightStatus

@author Olivier Boissier (Mines Saint-Etienne), Victor Charpenay (Mines Saint-Etienne)
*/

/*
An agent's state is roughly composed of beliefs (logical statements, as in Prolog) and goals (syntactically represented as atomic statements prefixed with '!'). The following line initializes the agent's state with a belief that gives what credentials it should use to interact with the VL10 workshop.

TODO: replace N with your group number (to obtain e.g. "simu1", "simu2", etc).
*/

thing(storageRack,Thing) :-
    thing(Thing)
    // TODO include signature from the Product Ontology
    & rdf(Thing,"http://www.w3.org/1999/02/22-rdf-syntax-ns#type","http://www.productontology.org/id/Automated_storage_and_retrieval_system")
    & rdf(Thing, "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", "http://www.w3.org/ns/sosa/Platform" )
    & has_action_affordance(Thing, PressEmergencyStop)
    & stop_in_emergency_action(PressEmergencyStop)
    & has_action_affordance(Thing, MoveFromTo)
    & move_from_to_action(MoveFromTo)
    & has_property_affordance(Thing, StackLightStatus)
    & stack_light_status(StackLightStatus)
    // & has_property_affordance(Thing, Capacity)
    // & maximum_count(Thing, Capacity)
    & has_property_affordance(Thing, ConveyorSpeed)
    & conveyor_speed(ConveyorSpeed)
  .

/*
Entry point of vl10_agent's program.

An agent program (in the Jason/AgentSpeak language) is roughly a set of plans. A plan has the following structure:

triggering_event : guard_condition <- action ; action ; ... action .

The following plan has the guard condition credentials(Username, Passward), which will be matched against the agent's beliefs. Its triggering event is the addition of !start to the agent's list of goals (remember that goals start with '!'). The plan states that the agent will achieve goal !start if it executes two actions in sequence: setAuthCredentials() and !readConveyorSpeed.
Once the event occurs, the agent will therefore execute the two actions and remove !start from its list of goals.
*/

+!start :
    name(Name)
    <-
    .println("Belief base is under initialization");
    !!run(Name);
  .

+!run(Name) :
    thing(Name,Thing)
    <-
    .print("Found suitable storage rack: ", Thing) ;
    // To initialize the ThingArtifact in a dryRun mode (requests are printed but not executed)
    // makeArtifact(Name, "org.hypermedea.ThingArtifact", [Thing, false], ArtId);
    // .println("PAY ATTENTION: I am in dryRun=True mode");
    // When no parameter, dryRun is false by default.
    makeArtifact(Name, "org.hypermedea.ThingArtifact", [Thing], ArtId);
    focus(ArtId);
    // set credentials to access the Thing 
    ?credentials(SimuName,SimuPasswd);
    setAuthCredentials(SimuName, SimuPasswd)[artifact_id(ArtId)] ;
    .println("ThingArtifact created");

    +initializing;
    ?capacity(X,Y);
    +nextItem(0,0);
    !observeClampStatus(Name);

    ?conveyorSpeed(Name,IS);
    ?initialSpeed(S)
    if (IS == 0) {
      !changeConveyorSpeed(Name,1);
    }

    //!getDescription(Thing);
    //!testStatus(Name);

  .

+!run(Name) :
    true
    <-
    .wait(100);
    !!run(Name)
.

+propertyValue("capacity", _) : initializing
<- -initializing.

+!pickNextItem : initializing | propertyValue("clampStatus", true)
<- 
  .wait(100);
  !pickNextItem;
.

+!pickNextItem : 
thing(N, T) 
& nextItem(X, Y) 
& propertyValue("capacity", [MAX_X, MAX_Y])
& X < MAX_X
<- 
  .print("Picking Item at ",[X,Y]);
  -+nextItem(X+1, Y);
  !pickItem(N, [X, Y]);
.

+!pickNextItem : 
thing(N, T) 
& nextItem(X, Y) 
& propertyValue("capacity", [MAX_X, MAX_Y])
& Y < MAX_Y - 1
<- 
  -+nextItem(0, Y+1);
  !pickNextItem
.

+!pickNextItem : 
thing(N, T) 
& nextItem(X, Y) 
& propertyValue("capacity", [MAX_X, MAX_Y])
<- 
  -+nextItem(0, 0);
  .print("Done! rack is empty")
  .print("Ordering cups....")
  //TODO ORDER
.



{ include("inc/vl10_skills.asl") }
{ include("inc/common.asl") }
{ include("inc/owl-signature.asl") }

{ include("$jacamoJar/templates/common-cartago.asl") }
