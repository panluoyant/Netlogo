## WHAT IS IT?

This is a simple model of a heat network for demonstration purposes.
The aim of this network is to investigate and illustrate the potential of the Agent-Based Modeling (ABM) approach for studying heat networks. ABM are already used in the energy sector, especially in the electricity sector for smart grid studies or in holistic approaches. Modeling complex systems with the use of ABM seems to gain interest in the last years and would gain to be better known. A couple of references at the end of this documentation provide a short insight to this subject.
This present demo model enables to simulate the dynamics of the heat supply and heat consumption in the network: how do the PRODUCERS (e.g. boilers...) react to match the demand of the CONSUMERS (e.g. households).
The demand is variable. It consists of space heating and/or domestic hot water.

## HOW IT WORKS

### Environment
The environment defines the climate through:

* the outside ambient temperature: each day, the temperature is fixed to a random value between -20 °C and +20 °C, varying from the previous day by +/-5 °C.

The "environment" also takes care of the balance in the hydraulic network and imposes a mass flow in the different branches of the network. The FLOW list is a global variable.

### Types of Agents
At this stage, the hydraulic network could be seen as a meta-agent. It is composed of:

* PIPES as links, with a certain length (defining the size of the temperature list along the pipe): 1 link to or 1 link from
* SPLITTERS as agents with:
* 2 links to
* 1 link from
* MERGERS as agents with:
* 1 link to
* 2 links from
* TURNS, defined for a better graphical representation, as agents with:
* 1 link to
* 1 link from

For the moment, pumps are integrated in the consumers/producers. Valves are not modelled. The FLOW is fixed...
In a later stage, the mass flow could be computed by an external tool (or imported module?) based on pressure losses in the hydraulic circuit and pressure heads of the pumps.

The network data could be later imported from GIS data. There are 5 types of agents (breeds): PRODUCERS, CONSUMERS, SPLITTERS, MERGERS, TURNS. The hydraulic network is defined by lists defining for each agent breed:

* its spatial position (x, y coordinates)
* its connection to the network:
* the mass flow in the line (network branches are numbered)
* the temperature it sees at inlet, given by the incoming pipe.

The agents are numbered according to the network definition. In the example network, several CONSUMERS are connected in series on a branch of the hydraulic circuit.

### Simulation time step
The simulation TIME-STEP (tick duration) can be adjusted. 
By default, the agents take action with a time step of 6 min. One hour is 10 steps. One day has then 240 steps.
The flow is fixed to the design value (to enable the supply of the maximum heat load). Therefore we can assume that the network has been designed to obtain a fixed flow speed in the network. The flow speed in the network is then by default 6 min per unit length (let's say 1 patch = 50 m).
For the temperature propagation in the network, the hydraulic network has a "memory" of its temperature: it is stored in a list PIPE-TEMPERATURE for each pipe. Note that the temperature propagation in the network goes by 1 unit length (1 patch) per time step. The list stores as many temperatures as the pipe's length (number of patches separating the agents). This supposes the pipe diameters are exactly adjusted, according to the design mass flow, to maintain the same speed in the entire network.
Attention: to enable variable flows, there is a need for improvement. For example to take into account actions of valves, modifying the relative mass flow in network branches. But for demonstration purposes with fixed mass flows, this current model is enough.

### Consumer behavior
Each CONSUMER has a user profile with heat needs for:

* space heating, caracterised by:
* the desired set temperature: randomly chosen between T_SET-MIN and T_SET-MAX (for example 15 and 25 °C)
* the heat loss coefficient of the house in W/K, calculated for a 100 m² house. 3 types are proposed to start with:
* (passive: 10 W/K) ignored so far
* efficient: 100 W/K
* inefficient: 1000 W/K
* domestic hot water (showers):
* consumption of 10 to 100 L per shower(s), randomly
* consumption happens with a mass flow of 10 L/min.
* it can happen several times a day:
* with a probability of 0.01 at each time step (happening statistically 2,9 times a day with a 6 min time step...) and
* with a probability of 0.2 between 18:00 and 19:00 to try to generate peak demand. This could be refined with more realistic profiles and some more diversity in the agents...

From the heat load in a time step, the temperature of the FLOW available to the agent is decreased accordingly:
T_OUT = T_IN - ( HEAT-LOAD * (T_AIM - T_EXT) ) / ( FLOW * CP )

### Producer behavior
Each PRODUCER tries to maintain its outlet temperature T_OUT to the setup temperature T_SET by adjusting its thermal power according to the variation of the return temperature T_IN. It has a maximal power Q_MAX (kW) and a maximal variation Q_STEP (kW).
HEAT-LOAD_NEW = min( Q_MAX, max( 0, FLOW * CP * ( T_OUT - T_IN ) ) )

* if HEAT-LOAD_NEW > HEAT-LOAD + Q_STEP
then limit power: HEAT-LOAD = HEAT-LOAD + Q_STEP
* if HEAT-LOAD_NEW < HEAT-LOAD - Q_STEP
then limit power: HEAT-LOAD = HEAT-LOAD - Q_STEP
* otherwise
set power to calculated value: HEAT-LOAD = HEAT-LOAD_NEW

Then the new outlet temperature should be as close as possible to the set temperature:
T_OUT = T_IN - HEAT-LOAD / ( FLOW * CP )

## HOW TO USE IT

Click SETUP to build the network.
Click GO 1 to run 1 time step
Click GO to run the model

You can choose the mode: activate only "space heating load" or "space heating + domestic hot water" (default).

The maximum power Q_MAX of the producers can be adjusted, as well as its inertia: how fast can the power output be adjusted, or what is the maximum variation Q_STEP of the power per time step.

Further parameters can be modified directly in the code tab.

Attention:
When you create the network using the SETUP button, the consumers are given a somewhat random behavior: the house energy efficiency and the set temperature for space heating vary from one setup to the other. The consumption of each shower is chosen randomly at the beginning of each shower. Additionally, the climate is randomly determined.
As a consequence, 2 single runs with different SETUPs and parameters can not be directly compared. The use of BEHAVIOR SPACE tool is recommended to explore the band width of what can possibly happen in this network, considering the variability of load profiles and heat producers.

## THINGS TO NOTICE

You can visualize the power output of the producers (blue lines) and the power consumption of the consumers (orange lines) during the two last days simulated in the bottom left diagram. In this diagram, each line represent the power of a producer or consumer, in a cumulated way (the first line from the bottom line accounts for the power of the first producer, the difference between the first and second line on top of it shows the power of the second producer; same for consumers)
The rose line shows the current balance of thermal power in the network: if it is negative, the network is losing energy at the moment, while a positive value indicates more energy is produced than consumed at this moment.

In the bottom right diagram, the total powers of producers and consumers are plotted from the beginning of the simulation.

The "cumulated time (min) with unmatched needs" accounts for the time (TICKS * TIME-STEP) when a consumer is not able to cover its needs. This happens when the temperature in the network is too low: the required temperature can not be reached. The time is cumulated between consumers: if N consumers do not match their needs during the same time step, the time is counted N times!

The "Average percentage of time with uncovered needs" shows the percentage of time steps when needs are not covered in average over all consumers.

The current outside temperature is also indicated on the network diagram (top right).
On the network graphical representation, some information can be red:

* the thickness of the pipes is proportional to the mass flow, 
* the color of the pipes is varying with the temperature (from white at 0 °C, gradually darker until black at 100 °C)
* the color of the consumers and producers is varying with their current thermal power consumption and production respectively (the darker, the higher) 
* the value on each consumer and producer indicates the current temperature outlet (at the beginning of each time step) 
* when a consumer is taking a shower, the label is switched to "shower"

## THINGS TO TRY

You can run the model with default values (Q_MAX = 50 kW as maximum power for producers). Is the load covering the network needs?
You can increase the maximum power to 100 kW. How does this affects the "Average percentage of time with uncovered needs"?
Does increasing the reactivity of the producer (Q_STEP = 5 or 10 kW) affects the results?

Try to switch from "Space heating + Hot water" mode to "Space heating" mode. Observe the behavior with space heating load only. How does this affect the "Average percentage of time with uncovered needs"?

Using BehaviorSpace (in the tools menu) can be interesting to run several times the model and draw statistical conclusions on the bandwidth of "behavior" the network can have.

## EXTENDING THE MODEL

There are many ways one could improve the model.

### on the structure of the network:

The configuration of the network is very simple, with only two branches on which few CONSUMERS are connected in series. In most networks, consumers are connected in parallel, so that they are all supplied with the same temperature (except from inline thermal losses). Another network structure could be implemented.

### on the inputs:

The weather data could be generated based on a climate/weather model (or using standard data base).

Develop an interface to import easily network data.

The load profiles of consumers could be adjusted to more realistic user profiles, depending on the use case.

### on the physical model of phenomena:

The model could be more robust on the modelling of the hydraulic network. This would be especially interesting to implement the possibility of variable flows (effect of pumps or valves).

The control strategy could be improved. The model could actually be used to investigate and optimize control strategies. The model could help test the robustness of the control strategies in all situations the network can meet.

### on the outputs:

The variables and diagrams for the analysis could be further developed to investigate some aspects in more details.

## NETLOGO FEATURES

FOREACH is used to generate the network.

In the diagram, to plot the cumulated values of producer/consumer thermal powers, we use a FOREACH structure, calling CREATE-TEMPORARY-PLOT-PEN for each producer and consumer. This enables to generate the diagram automatically, whatever the number of producers and consumers.

A parallel simulation of all agents could be interesting. But the current feature with "parallel-like" simulation --like it is used in the termites model-- is not suitable. Indeed it does not keep track of time in a strict manner...

## RELATED MODELS

No similar model could be identified in the library.
The "diffusion in a directed network" could be the nearest model to which the present one can be related to.
Some work has already been done in the energy sector using Agent Based Modeling, especially concerning smart electricity grid. Some references are given in the following section.
