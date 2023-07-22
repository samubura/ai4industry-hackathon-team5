// Agent sample_agent in project ai4industry_jacamo

/* Initial beliefs and rules */

/* Initial goals */

!start.

/* Plans */

+!start : true <- .print("Waiting for command of isPresent, update ").

+!isPresent(St1, St2, St3) : true <-
            isPresent(St1,St2,St3, Value);
            .println("Result is ",Value);
      .

+!update(St1, St2, St3, Index, St4) : true <-
            update(St1,St2,St3, Index, St4);
      .

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }

// uncomment the include below to have an agent compliant with its organisation
//{ include("$moiseJar/asl/org-obedient.asl") }
