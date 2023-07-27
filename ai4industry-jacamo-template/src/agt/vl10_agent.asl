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
credentials("simuN", "simuN") .

/*
Entry point of vl10_agent's program.

An agent program (in the Jason/AgentSpeak language) is roughly a set of plans. A plan has the following structure:

triggering_event : guard_condition <- action ; action ; ... action .

The following plan has the guard condition credentials(Username, Passward), which will be matched against the agent's beliefs. Its triggering event is the addition of !start to the agent's list of goals (remember that goals start with '!'). The plan states that the agent will achieve goal !start if it executes two actions in sequence: setAuthCredentials() and !readConveyorSpeed.
Once the event occurs, the agent will therefore execute the two actions and remove !start from its list of goals.
*/
+!start :
    credentials(Username, Password)
    <-
    /*
    setAuthCredentials() is boilerplate code so that Hypermedea inject the given credentials in subsequent operations. 
    */
    setAuthCredentials(Username, Password);
    /*
    This pseudo-action generates an event of the form +!readConveyorSpeed, triggering the plan defined below.
    */
    !readConveyorSpeed;
  .

+!readConveyorSpeed :
    /*
    This plan has no guard condition. Side note: when a plan has no guard condition, it can also be written as:

    triggering_event <- action ; action ; ... action .
    */
    true
    <-
    /*
    readProperty() is one of the WoT operations. For the VL10 workshop, this operation sends a GET request to the simulation server for the "conveyorSpeed" property and maps Val to the server's response payload (a real number). As in Prolog, Val is a variable because it starts with a capital letter.
    */
    readProperty("conveyorSpeed", Val);
    /*
    .print() is an "internal" action. All agents have some internal actions built in, as opposed to external actions that depend on the environment in which an agent is situated. See the Jason stdlib for a list of internal actions:
    https://jason.sourceforge.net/api/jason/stdlib/package-summary.html
    */
    .print("Conveyor speed: ", Val);
    /*
    The agent should print "Conveyor speed: 0".
    If you have an authentication error, see line 26.
    */
  .

/*
Exercises:

1. Read all properties of the VL10 workshop and print them to the console.

2. A Jason plan can include control statements (if/while/for). Add an infinite loop to constantly monitor the workshop's properties. Add a pause between each iteration with the .wait() internal action. See the Jason stdlib for documentation on while and .wait():
https://jason.sourceforge.net/api/jason/stdlib/package-summary.html

3. Use writeProperty() to set conveyor speed to some value >0 and invokeAction() to pick items on the storage rack, repeatedly (at location [0, 0], [0, 1], ... [1, 0], [1, 1], ...). Once no item is in storage, the agent should wait until it is refilled. Examples of how to use WoT operations are provided in the template's README and in Hypermedea's Javadoc:
https://hypermedea.github.io/javadoc/latest/org/hypermedea/ThingArtifact.html

Now you've got a first controller agent for the VL10 workshop!
*/

{ include("inc/vl10_skills.asl") }
{ include("inc/common.asl") }
{ include("inc/owl-signature.asl") }

{ include("$jacamoJar/templates/common-cartago.asl") }
