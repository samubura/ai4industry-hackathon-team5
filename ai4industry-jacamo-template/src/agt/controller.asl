/* 
controller_agent used to test actions affordances, property affordances 
It acts on many things of the IT'M Factory.
This agent can be used with a REPL agent to execute some the agent's goals
by sending of messages (e.g. . send(controller,achieve,invokeAction(....)))

@author Olivier Boissier (Mines Saint-Etienne), Victor Charpenay (Mines Saint-Etienne)
*/


+?workshopRunning :
    true
    <-
    !readProperty("conveyorSpeed", "test_vl10") ;
    .

+!start :
    true
    <-
    // set credentials to access the Thing of the IT'm factory
    ?credentials(SimuName,SimuPasswd);
    setAuthCredentials(SimuName, SimuPasswd)[artifact_name("test_vl10")] ;
    setAuthCredentials(SimuName, SimuPasswd)[artifact_name("test_dx10")] ;
    setAuthCredentials(SimuName, SimuPasswd)[artifact_name("test_xy10")] ;
    setAuthCredentials(SimuName, SimuPasswd)[artifact_name("test_boschApas")] ;
    setAuthCredentials(SimuName, SimuPasswd)[artifact_name("test_cupProvider")] ;
    setAuthCredentials(SimuName, SimuPasswd)[artifact_name("test_dairyProductProvider")] ;
    // check the status of the conveyor and starts it if it is idling
    !run;
    .

+!run :
    true
    <-
    ?workshopRunning ;
    !writeProperty("conveyorSpeed", test_vl10, 1);
    .print("conveyor speed set to 1") ;
    !invokeAction("pressEmergencyStop",test_vl10);
    .print("emergency stop pressed");
    .

+!readProperty(Name,ArtName) : 
    true
    <-
    readProperty(Name,Value)[artifact_name(ArtName)];
    .print("read property ",Name,": ",Value);
    .

+!writeProperty(Name,ArtName,Value) : 
    true
    <-
    writeProperty(Name,Value)[artifact_name(ArtName)];
    .print("updated property ",Name," with value ", Value," on ",ArtName);
    .

+!invokeAction(Name,ArtName,Value) :
    true
    <-
    .print("executing ",Name," with ",Value," on ",ArtName);
    invokeAction(Name,Value)[artifact_name(ArtName)];
    .print("executed ",Name," with ",Value," on ",ArtName);
    .

+!invokeAction(Name,ArtName) :
    true
    <-
    .print("executing ",Name," on ",ArtName);
    invokeAction(Name)[artifact_name(ArtName)];
    .print("executed ",Name," on ",ArtName);
    .

+conveyorSpeed(V) : 
    true 
    <- 
    .print("conveyorSpeed has changed to: ",V); 
    .

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
