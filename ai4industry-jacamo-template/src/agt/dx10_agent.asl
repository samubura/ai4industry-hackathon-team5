/* 
dx10_agent controlling the Filling Workshop. 
It acts on a thing described by: https://ci.mines-stetienne.fr/kg/itmfactory/dx10
It has:
- the following action affordances:
-- pressEmergencyStop
- the following property affordances:
-- stackLightStatus
-- conveyorSpeed
-- positionX
-- tankLevel
-- magneticValveStatus
-- opticalSensorStatus
-- conveyorHeadStatus

@author Olivier Boissier (Mines Saint-Etienne)
*/

/* Initial beliefs and rules */

thing(fillingWorkshop,Thing) :-
    thing(Thing)
    // TODO include signature from the Product Ontology
    & rdf(Thing, "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", "http://www.productontology.org/id/Filler_(packaging)")
    & has_action_affordance(Thing, PressEmergencyStop)
    & stop_in_emergency_action(PressEmergencyStop)
    & has_property_affordance(Thing,StackLightStatus)
    & stack_light_status(StackLightStatus)
    & has_property_affordance(Thing, PositionX)
    & x_coordinate(PositionX)
    & has_property_affordance(Thing,TankLevel)
    & liquid_volume(TankLevel)
    & has_property_affordance(Thing, ConveyorSpeed)
    & conveyor_speed(ConveyorSpeed)
    & has_property_affordance(Thing,OpticalSensorStatus)
    & optical_sensor_status(OpticalSensorStatus)
    & name(OpticalSensorStatus, "opticalSensorStatus")
    & has_property_affordance(Thing,ConveyorHeadStatus)
    & optical_sensor_status(ConveyorHeadStatus)
    & name(ConveyorHeadStatus,"conveyorHeadStatus")
    & has_property_affordance(Thing, MagneticValveStatus)
    & valve_status(MagneticValveStatus)
  .

/* Initial goals */

/* Plans */

+!start :
    name(Name)
    <-
    .println("Belief base is under initialization");
    !!run(Name);
  .

+!run(Name) :
    thing(Name,Thing)
    <-
    .print("Found suitable filling workshop: ", Thing) ;
    // To initialize the ThingArtifact in a dryRun mode (requests are printed but not executed)
    // makeArtifact(Name, "org.hypermedea.ThingArtifact", [Thing, false], ArtId);
    // .println("PAY ATTENTION: I am in dryRun=True mode");
    // When no parameter, dryRun is false by default.
    makeArtifact(Name, "org.hypermedea.ThingArtifact", [Thing], ArtId);
    focus(ArtId);
    // set credentials to access the Thing (DX10 workshop of the IT'm factory)
    ?credentials(SimuName,SimuPasswd);
    setAuthCredentials(SimuName, SimuPasswd)[artifact_id(ArtId)] ;
    .println("ThingArtifact created");
    //  ?locationOfInputMaterial(Name,CIX,CIY,CIZ);
    //  ?locationOfOutputProduct(Name,COX,COY,COZ);
    !getDescription(Name);
    !testStatus(Name);
    
    // Not necessary to get all of them regularly. 
    // Choose and comment, otherwise there is a risk of
    // consuming all the computing resources
    !observeTankLevel(Name);
    !observeConveyorSpeed(Name);
    !observeConveyorHeadStatus(Name);
    !observeOpticalSensorStatus(Name);
    !observeMagneticValveStatus(Name);
    !observePositionX(Name);
    !observeStackLightStatus(Name);
    
    ?conveyorSpeed(Name,IS);
    if (IS == 0) {
      !changeConveyorSpeed(Name,0.5);
    }
    
    !fillItems(Name);

    !testStatus(Name);
  .

+!run(Name) :
    true
    <-
    .wait(100);
    !!run(Name).

// Fake plan. Adapt.
+!fillItems(Name) :
    thing(Name,Thing)
    <-
    .println("is filling Item.");
    .wait(1000);
  .

// TO BE COMPLETED ....

{ include("inc/dx10_skills.asl") }
{ include("inc/common.asl") }

{ include("$jacamoJar/templates/common-cartago.asl") }
