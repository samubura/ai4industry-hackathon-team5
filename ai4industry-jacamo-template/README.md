# AI4Industry JaCaMo template

This project is a template to start your own multi-agent system for the ai4industry hackathon.

## Getting started

Clone the project and follow [the configuration steps](https://gitlab.emse.fr/ai4industry/hackathon/-/wikis/hackathon-configuration#user-content-autonomous-agents) given in the wiki page "Hackathon configuration". Configuration includes downloading [Hypermedea](https://github.com/Hypermedea/hypermedea).

## The Hypermedea Framework

Hypermedea is an extension of JaCaMo that includes several types of artifacts. The main artifacts used in the hackathon are:

1. A `LinkedDataArtifact`, offering agents the possibility to crawl the Knowledge Graph. Any agent focusing on this artifact will get the result of the crawl as beliefs.
In the template project, this artifact is only used by the `ld_spider` agent (`ld_spider.asl`) in `src/agt` and observed by all agents.

2. An `OntologyArtifact`, translating Knowledge Graph statements into predicates and performing reasoning, based on ontological knowledge.

3. `ThingArtifact`s, kind of Thing Description browser artifact offering agents the possibility to interact with a Thing using high-level operations (`readProperty`, `writeProperty`, `invokeAction`, `subscribeEvent` and the special operation `observeProperty`).

For more details, refer to the [Javadoc of Hypermedea's artifact classes](https://hypermedea.github.io/javadoc/latest/org/hypermedea/package-summary.html).

## Content and structure of the project folder

The project folder contains:

1. Several agents in `src/agt`, including The agent `ld_spider` that crawls the knowledge graph using an instance of `LinkedDataArtifact` and the agent `template_agent` as a starting point for writing your code.

3. A set of predefined Jason plans (in `src/agt/inc`) that can be included in the agents.

4. The `ai4industry_jacamo.jcm` project file, which configures the multi-agent system to launch. Each time you create a new agent, you need to add it this `.jcm` file.

5. The `reset-simu` script, to reset the different simulated workshops (the argument of this script is the number of your group)

## Using Thing Artifacts

You are provided with an implementation of a CArtAgO artifact that can retrieve, interpret, and use a W3C WoT TD to interact with the described Thing. A Jason agent can create a `ThingArtifact` as follows:

```
makeArtifact("forkliftRobot", "org.hypermedea.ThingArtifact", [URL, true], ArtId);
focus(ArtId);
```

The `ThingArtifact` takes two initialization parameters:
- a URL that dereferences to a W3C WoT TD
- an optional `dryRun` flag: when set to `true`, all HTTP requests composed by the artifact are printed to the JaCaMo console (default value is `false`).

The `ThingArtifact` can use an [APIKeySecurityScheme](https://www.w3.org/TR/wot-thing-description/#apikeysecurityscheme) for authenticating HTTP requests. The API token can be set via the `setAPIKey` operation:

```
setAPIKey(Token)[artifact_name("forkliftRobot")];
```

The `ThingArtifact` also provides agents with CArtAgO operations that correspond to operation types defined by the W3C WoT TD recommendation, such as `writeProperty`, `writeProperty` or `invokeAction`.

The general invocation style of `writeProperty` and `invokeAction` is as follows (see also the Javadoc comments):

```
<operation type>(
  <affordance name>,
  [ <list of Jason terms, can be arbitrarily nested> ]
)
```

Example for writing a TD property of a `BooleanSchema` type:

```
writeProperty("status", [true])[artifact_name("forkliftRobot")];
```

Example for invoking a TD action with an `ArraySchema` payload:

```
invokeAction("moveTo", [30, 60, 70])[artifact_name("forkliftRobot")];
```

Example for invoking a TD action with an `ObjectSchema` payload:

```
invokeAction(
  "carryFromTo",
  json([
    kv("from", [30, 50, 70]),
    kv("to", [30, 60, 70])
  ])
)[artifact_name("forkliftRobot")];
```

A TD property can be read in a similar manner, where `PositionValue` is a CArtAgO operation feedback parameter:

```
readProperty("position", PositionValue)[artifact_name("forkliftRobot")];
```

You can find more details about CArtAgO and the Jason to/from CArtAgO data binding [here](http://cartago.sourceforge.net/?page_id=47). You can find additional information about the `ThingArtifact` [in its Javadoc](https://hypermedea.github.io/javadoc/latest/org/hypermedea/ThingArtifact.html).

