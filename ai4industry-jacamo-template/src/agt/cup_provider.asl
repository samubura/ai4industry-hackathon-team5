/*
 Cup and Package Provider agent
 Able to provide cups or packages on request
 It acts on a thing that has:
 - the following action affordances:
 -- order
 -- orderPackages
 - has no property affordances
 - has the following event affordances:
 -- delivered
 -- deliveredPackages

@author Olivier Boissier (Mines Saint-Etienne)
*/

/* Initial beliefs and rules */

thing(cupProvider,Thing) :-
    thing(Thing)
    // TODO include signature from the Product Ontology
    & rdf(Thing,"http://purl.org/dc/terms/title","cup-provider")
    & order_action(Thing,_)
    & order_packages_action(Thing,_)
    & has_event_affordance(Thing,DeliveredPackages)
    & name(DeliveredPackages,"deliveredPackages")
    & has_event_affordance(Thing,Delivered)
    & name(Delivered,"delivered")
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
    .print("found suitable cup and package provider: ", Thing) ;
    // To initialize the ThingArtifact in a dryRun mode (requests are printed but not executed)
    // makeArtifact(Name, "org.hypermedea.ThingArtifact", [Thing, false], ArtId);
    // .println("PAY ATTENTION: I am in dryRun=True mode");
    // When no parameter, dryRun is false by default.
    makeArtifact(Name, "org.hypermedea.ThingArtifact", [Thing], ArtId);
    focus(ArtId);
     // set credentials to access the Thing
    ?credentials(SimuName,SimuPasswd);
    setAuthCredentials(SimuName, SimuPasswd)[artifact_id(ArtId)] ;
    !getDescription(Name);
.

+!run(Name) :
    true
    <-
    .wait(100);
    !!run(Name);
  .

+!order(Value)[source(Sender)] :
    true
    <-
    !order(cupProvider,Value);
    .println("processed order and sending message to ",Sender);
    .send(Sender,tell,done(order));
  .

+!order(Name,Value) :
    thing(Name,Thing)
    & order_action(Thing,ActionName)
    <-
    .println("acting on ",Name," to act on ",Thing," with parameter ",Value," on operation ", ActionName);
    invokeAction(ActionName,Value)[artifact_name(Name)];
    .println("acted on ",Name," to act on ",Thing," with parameter ",Value," on operation ", ActionName);
  .

+!orderPackages(Name) :
    thing(Name,Thing)
    & order_packages_action(Thing,ActionName)
    <-
    .println("acting on ",Name," to act on ",Thing," on operation ", ActionName);
    invokeAction(ActionName)[artifact_name(Name)];
    .println("acted on ",Name," to act on ",Thing," on operation ", ActionName);
  .

{ include("inc/common.asl") }

{ include("$jacamoJar/templates/common-cartago.asl") }
