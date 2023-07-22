/* 
ld_spider using the Linked Data artifact to crawl a KG 

@author Olivier Boissier (Mines Saint-Etienne), Victor Charpenay (Mines Saint-Etienne)
*/

/*
Initial belief giving an entry point for hypermedia navigation.
The given URI identifies the index page of the KG describing the IT'm Factory.
*/
entryPoint("https://ci.mines-stetienne.fr/kg/") .

+!start :
    true
    <-
    /*
    The first action in the program is to add !crawl to the list of goals of ld_spider.
    */
    !crawl ;
    /*
    Once the crawl ends, the next goal of the agent is to count the number of RDF statements added to its set of beliefs.
    */
    !countRDF ;
  .

+!crawl :
    /*
    Any hypermedia navigation must have an entry point. Here, it is given as an initial belief, as mentioned above. 
    */
    entryPoint(EntryPoint)
    <-
    .print("Crawling starting from ", EntryPoint) ;
    /*
    If the agent has goal !visitSync, it will dereference the given URI and wait for a response from the server owning the resource identified by that URI.
    */
    !visitSync(EntryPoint) ;
  .

+!visitSync(URI) :
    true
    <-
    /*
    get() is an operation specific to Hypermedea agents. Given a URI, it will send a GET request to the server managing the resource identified by that URI. get() is asynchronous by design: the agent will move on to the following action without waiting for a response from the server. The agent can thus deal with non-responding servers and visit multiple resources in parallel.
    */
    get(URI) ;
    /*
    .wait() is a Jason internal action, as you already saw in vl10_agent. It is used in a slightly different way, here: instead of waiting a certain period of time, the agent will wait for a particular event (that may never occur). Here, the event the agent waits for is triggered by Hypermedea's LD crawler after a GET request, to inform the agent that the server responded. This action therefore enforces synchronous interaction with the server.
    See the documentation of .wait() for more details on the syntax of its arguments:
    https://jason.sourceforge.net/api/jason/stdlib/wait.html
    */
    .wait({ +visited(URI) }) ;
  .

/*
In Jason, events are not only generated when the agent's goals change. If an agent starts/stops believing something, an event is also generated (syntactically represented as +p or -p, where p is a logical statement).
*/
+visited(URI) :
    true
    <-
    .print("Visited ", URI) ;
  .

+!countRDF :
    true
    <-
    /*
    .count() is an internal action to inspect the agent's beliefs. The action below looks specifically for RDF triples. These triples are added by Hypermedea's LD crawler after a GET request. If the server responds with an RDF representation of the requested resource, the triples it contains are turned into beliefs and made visible to the agent. The LD crawler generates event +visited(URI) only after all triples are visible by the agent.
    See the documentation of .count():
    https://jason.sourceforge.net/api/jason/stdlib/count.html
    */
    .count(rdf(_, _, _), Count) ;
    .print("found ", Count, " triples.");
  .

/*
Exercises:

1. Execute the agent program above. Then, while the program is still running, open the Jason server at http://127.0.1.1:3272/ and select ld_spider. What do you see? How are RDF triples represented in Jason?
Read the documentation of the LD crawler to fully understand the mapping between RDF triples and Jason logical formulas:
https://hypermedea.github.io/javadoc/latest/org/hypermedea/LinkedDataArtifact.html

2. Extend the program so that ld_spider explores all subsystems of the IT'm Factory.
2.1 To do that, after visiting the entry point, write a plan that looks for all triples of the form rdf(_, "http://www.w3.org/ns/ssn/hasSubSystem", Target) and calls get(Target). Use a for loop.
2.2 In your plan, print the target URI being dereferenced. Is it the URI of the resource being actually visited? On the Semantic Web, it is important to distinguish between information resources (an HTML page, a Turtle document, an image, etc.) and non-information or "semantic" resources (a person, an event, a factory workshop, etc.). It is common to identify semantic URIs with hash URIs, i.e. URIs with a fragment. In the resources your program has visited, you should find one identifying the VL10 workshop. What is the URI of this resource? What is the URI of the information resource describing VL10?

3. Synchronous browsing of LD resources is useful for educational purposes but, in practice, one would quickly run into scalability issues. That's why get() is designed to be asynchronous. In the following program, the agent browses another KG (describing Mines Saint-Étienne offices) asynchronously:
https://github.com/Hypermedea/hypermedea/blob/master/examples/fayol/src/agt/controller.asl
Adapt this program to the IT'm Factory KG. How many triples does this KG include?

4. In the KG, the VL10 workshop is declared to be of type td:Thing. It must therefore expose affordances to read/write its properties, invoke actions and/or subscribe to events. Instead of counting RDF triples at the end of the crawl, modify ld_spider's program to list all Things it found, along with the affordances they expose.
Once you've done that, look at the file inc/common.asl (in ai4industry_jacamo_template/src/agt/). You will find a goal called !getDescription at the end of the file. What does the associated plan do?
In this file, you will also see Prolog rules. Jason agents can indeed include rules as beliefs (resolved by the Jason interpreter at runtime). If your agent includes inc/common.asl (see statements e.g. at the bottom of this file), all rules defined in the file will be included as beliefs in the agent's state.

Now that your agent has dynamically discovered WoT affordances, it can select the ones relevant to reach its goals and act on the factory workshops in an adaptive fashion.
*/

{ include("inc/common.asl") }

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
