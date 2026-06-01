---
title: "Inside the Military AI Complex: How Palantir, Starshield, and Autonomous Targeting Became the Operating System of Modern Warfare"
tags:
  - military-AI
  - palantir
  - autonomous-weapons
  - surveillance
  - defense-technology
  - starshield
  - AI-ethics
  - government-software
---

**Challenge to the reader:** Before reading, list every US government agency you think uses Palantir software. For each one, write down what you think they use it for. After finishing this post, compare your list to the reality. How many were you right about — and what did you miss entirely?

---

The modern military doesn't just buy weapons anymore. It buys software platforms that fuse intelligence, automate targeting, and deploy AI into the kill chain. Three technologies sit at the center of this transformation: Palantir's Gotham, Foundry, and AIP — an ecosystem so deeply embedded in Western defense infrastructure that it now spans from Pentagon targeting rooms to Ukrainian battlefields to the UK Ministry of Defence. Alongside it, SpaceX's Starshield has militarized satellite internet, and Israel's Lavender/WhereDaddy system has pushed AI-driven human targeting into operational reality.

This post maps the products, contracts, agencies, and ethical fault lines of the military AI complex as it exists today.

---

## 1. The Core Platforms

Palantir's government and military work centers on a small set of core software platforms deployed across defense, intelligence, law enforcement, immigration, health, and other civil agencies[^1][^2].

**Gotham** — An operating system for intelligence, defense, and law-enforcement data, used by militaries and counter-terrorism analysts in the U.S. Intelligence Community and Department of Defense. It fuses data from many sources (sensors, databases, reports) and supports targeting, investigations, and battlefield intelligence[^2][^1].

**Foundry** — A data integration and analytics platform used more broadly in civilian government, including health and administrative agencies, to organize large datasets and support AI/ML analytics. It is used, for example, in U.S. health data initiatives and cross-agency data-sharing efforts[^3][^4][^1].

**Apollo** — A deployment and operations layer that runs underneath Gotham and Foundry, allowing them to be deployed, updated, and managed across highly restricted and disconnected military and government environments such as classified clouds, submarines, and forward bases[^5][^3].

---

## 2. Defense and Intelligence Uses

### U.S. Army

The Army is Palantir's single largest customer. Key programs include:

- **Distributed Common Ground System–Army (DCGS-A)** — battlefield intelligence using Gotham and related stacks[^4].
- **Tactical Intelligence Targeting Access Node (TITAN)** — a next-generation ground station for fusing data from space and airborne sensors to provide targeting information. Palantir holds a contract worth approximately $178 million to deliver TITAN prototypes[^6][^7][^8].
- **Maven Smart System (Project Maven)** — an AI system that aggregates multi-source data for target identification. Palantir has a contract worth approximately $480 million running into 2029[^9][^6]. The contract ceiling was later increased by approximately $795 million to meet growing demand from multiple military users. Users include at least five U.S. combatant commands: Central Command, European Command, Indo-Pacific Command, Northern Command/NORAD, and Transportation Command[^10].
- **Enterprise Service Agreement** — a long-term agreement with the Army valued at up to approximately $10 billion to provide software services across the service[^11].

### U.S. Intelligence Community

The Defense Intelligence Agency and CIA use Gotham for large-scale intelligence analysis, counter-IED work, and other analytic workflows. Gotham is explicitly described as an intelligence tool whose customers include the United States Intelligence Community, supporting large-scale intelligence fusion including terrorism networks, financial flows, and security threats[^2][^4].

### Other U.S. Services

U.S. Special Operations Command, Navy, Air Force, Space Force, and Marine Corps use Palantir platforms for mission command, AI/ML analytics, and command-and-control modernization[^4].

**Challenge:** The Maven Smart System contract grew from $480M to over $1.2B. What operational demand do you think drove that expansion — and which five combatant commands now use it?

---

## 3. Law Enforcement, Immigration, and Border Control

- **U.S. Immigration and Customs Enforcement (ICE)** uses Palantir software for Investigative Case Management (ICM), a system built under a ~$41 million contract that links personal and criminal records of immigrants across multiple federal and private databases. Additional contracts worth around $30 million support real-time migrant tracking and deportation-related analytics, sometimes described as providing the engine for large-scale deportation operations[^11][^12].
- **U.S. Customs and Border Protection (CBP)** uses Gotham to track immigrants and travelers at borders, integrating multiple data sources for risk assessment and targeting[^12][^4].

---

## 4. International Deployments

### United Kingdom Ministry of Defence

The UK MoD has a three-year, approximately £240.6 million contract (started April 2026) with Palantir for continued licensing and support of data-analytics capabilities used for critical strategic, tactical, and live operational decision-making across classifications. The contract emphasizes interoperability with NATO and allied nations' Palantir systems, implying deployment across multiple commands and operational domains[^13][^14][^15].

### NATO and Allied Nations

Public contract language from the UK MoD and other reporting explicitly notes interoperability with NATO and allied nations' Palantir systems. Palantir itself markets its Intelligence and Defense offerings as supporting allied and coalition partners with secure data-sharing, cross-domain fusion, and joint targeting workflows[^16][^17].

### Other International Users

- **Norwegian Customs** — screening passengers and vehicles based on integrated customs and financial data[^4].
- **Danish, German, and other European police forces** — POL-INTEL in Denmark, Hesse state police, and Europol use Palantir for predictive policing and intelligence analysis[^4].
- **International Atomic Energy Agency (IAEA)** — used Palantir to help verify Iran's compliance with the 2015 nuclear agreement by analyzing nuclear-related data[^2][^4].

---

## 5. Palantir AIP: The AI Control Plane

Palantir's Artificial Intelligence Platform (AIP) is an AI control plane that sits on top of Foundry and Apollo to connect LLMs and other AI models directly to operational data and workflows, with heavy emphasis on security, governance, and human-in-the-loop control[^18][^19][^20][^21].

### How It Fits In

AIP is a platform for deploying and governing large language models and other AI inside an organization's own networks, including classified and highly sensitive environments[^20][^22][^23][^18]. Together with Foundry (data/ontology layer) and Apollo (software deployment and updates), AIP forms an operating system that can deliver LLM-powered web apps, mobile apps, and edge apps that embed localized AI[^19][^21][^18].

### Core Capabilities

- **Model and tool access** — Governed access to a catalog of LLMs and multimodal models (first-party and external) with routing and abstraction so apps aren't hard-wired to one model. Tools to deploy models into private networks, including air-gapped and classified environments and tactical edge devices[^22][^23][^18][^24].
- **Agents and workflows** — Building blocks to define LLM-driven functions and multi-step agents that can read from ontologies, call tools/APIs, and take actions in operational systems. Automation primitives to orchestrate these agents across business or mission processes, with scheduling, triggers, and guardrails[^20][^18][^25].
- **Evaluation and observability** — Suites to define evaluation metrics and tests (quality, safety, bias, hallucinations) and to monitor agent/app performance over time. Observability tooling to inspect prompts, completions, tool calls, and outcomes[^20][^18].

### Security and Governance

AIP is designed for regulated and classified contexts. Its controls include:

- **Data protection** — Access controls, encryption, and detailed auditing are inherited from Palantir's stack and applied to prompts, completions, and actions taken by agents. When using third-party-hosted models, Palantir states that no customer data in prompts or completions is retained by those third parties; calls are mediated with strict contracts and technical safeguards[^26][^21][^27].
- **Fine-grained policy control** — Mechanisms like markings, cipher, checkpoints, and granular access controls constrain what data an agent can see and what operations it can perform. Tool scopes restrict which tools/APIs an agent may invoke[^27][^26].
- **Governance and lineage** — Built-in governance tools track historical lineage of AI operations and give transparency into why an agent did something, who approved it, and what data it used, supporting compliance, audit, and accountability requirements in defense, government, and regulated industries[^25][^19][^26][^28].

### Military Usage Patterns

Palantir's defense demos and write-ups show AIP being used as the AI layer on top of defense ontologies and operational systems[^23][^29][^22][^28]:

- **Threat monitoring and ISR fusion** — Operators query LLM-backed agents for real-time situational awareness about enemy units in a region. Agents pull from integrated intel data (sensors, reports) to construct likely unit formations and identify vulnerabilities. Agents can task drones or other ISR assets, analyze imagery or video, and confirm presence of specific threats[^22].
- **Course of action (COA) generation** — AIP agents generate multiple COAs to neutralize detected threats and automatically package them for review up the chain of command. The system validates logistics (e.g., whether units have required munitions) and proposes routes or plans that respect constraints and rules of engagement[^28][^22].
- **EW, comms, and targeting support** — AIP identifies and pairs validated enemy communication nodes and suggests how to assign jammers, helping planners disrupt adversary comms while protecting friendly forces[^22][^28].

---

## 6. Starshield: SpaceX's Military Satellite Network

Starshield is SpaceX's dedicated, government-only variant of Starlink, focused on secure communications, Earth observation, and hosting classified payloads for national security customers[^30][^31].

### What Starshield Is

Starshield is a secured satellite network designed for government use, distinct from the consumer/commercial Starlink service but built on the same LEO constellation and tech stack[^31][^32]. It adds mission-specific satellites and payloads plus higher-assurance encryption so that government users can run classified missions and process sensitive data end-to-end[^33][^34][^31].

### Core Capabilities

SpaceX and defense sources describe three primary Starshield capability areas[^35][^31][^33]:

- **Earth observation** — Satellites can carry sensing payloads (imaging, other ISR sensors) for tasks like monitoring military movements, natural disasters, or environmental conditions. Data is processed and delivered securely to customers[^30][^35][^33].
- **Secure communications** — Provides assured global communications for government users, using Starshield user equipment and leveraging the broader Starlink constellation for coverage. Uses laser inter-satellite links to route traffic without relying on ground stations, increasing resiliency and global reach[^34][^36][^31][^35][^33].
- **Hosted payloads / custom missions** — SpaceX builds satellite buses that can host the most demanding customer payload missions, meaning government agencies can fly their own instruments or mission packages on Starshield platforms. The architecture is proliferated LEO (many small satellites) for resilience and rapid reconstitution[^34][^37][^31].

### Government Customers and Contracts

SpaceX identifies Starshield's primary customers as the U.S. Space Development Agency (SDA), National Reconnaissance Office (NRO), and U.S. Space Force[^30][^35]. The U.S. Space Force awarded SpaceX a Starshield contract worth up to approximately $70 million for one year, providing Starshield end-to-end service via the Starlink constellation, user terminals, ancillary equipment, network management, and other related services[^36][^33][^34]. The Starshield contract framework is also being leveraged for a larger MILNET-type constellation program (approximately 480 satellites) funded by Space Force and managed by the NRO to meet DoD connectivity requirements[^38][^39].

Ukraine's armed forces have been granted access to Starshield as a secure, militarized version of Starlink through U.S. Department of Defense contracts. An earlier agreement connected 500 terminals to Starshield for about $40 million; a later contract expanded access so roughly 3,000 terminals in Ukraine could use the encrypted Starshield network, with service extended through 2025[^40][^41][^42].

---

## 7. WhereDaddy and Lavender: AI-Driven Human Targeting

"Where's Daddy?" (often written "WhereDaddy") is the reported nickname of an Israeli military AI targeting support system used in the Gaza war, designed to track people already placed on a kill list and alert operators when they return home to their families[^43][^44].

### How It Links to Lavender

Investigations by Israeli outlet +972 Magazine and Local Call describe two linked AI systems: **Lavender**, which generates a kill list of suspected Hamas or Islamic Jihad members, and **Where's Daddy?**, which tracks those flagged individuals to time strikes. Lavender reportedly identifies tens of thousands of suspected militants and their home addresses; WhereDaddy then monitors movements and signals when the person goes back to their residence, especially at night[^44][^43].

### Reported Function and Targeting Logic

WhereDaddy is described as a monitoring and alert system that uses surveillance data to tell intelligence officers "the target is now at home," so airstrikes can be launched against family houses rather than military facilities. Several anonymous Israeli intelligence officers told reporters the system was explicitly built to prefer hitting targets at home, because it is easier to bomb a family's house than to strike them during military activity[^43][^44].

This approach, combined with a permissive bombing policy, allegedly contributed to entire families being killed inside their homes, with civilians treated as collateral damage[^44][^43].

### Human Oversight and Error Concerns

Sources quoted in the +972/Local Call investigation say human oversight over Lavender and WhereDaddy was extremely thin, with operators sometimes rubber-stamping machine selections after only seconds of review, mainly checking the target's gender. Lavender itself reportedly had around a 10% error rate in labeling people as militants; combined with timing strikes on homes, this magnified the risk of killing people with weak or no real links to armed groups, plus their families[^43][^44].

AI and safety experts interviewed by media outlets argued that such use of AI is dangerously close to indiscriminate targeting and raises serious questions under international humanitarian law[^45][^44][^43].

### IDF's Official Position

The Israel Defense Forces (IDF) publicly dispute key claims about these systems. They say reports about automated kill lists and deliberate targeting of family homes are misleading and contain numerous inaccuracies. The IDF insists it does not use an AI system to automatically identify terrorists or to decide if someone is a terrorist; it says human analysts must independently verify that targets comply with international law and IDF directives. At the same time, the IDF acknowledges using AI-based tools to assist in target generation and says it takes measures to minimize civilian harm[^45][^44][^43].

**Challenge:** WhereDaddy and Lavender raise a specific question under international humanitarian law: if an AI system recommends striking a target at home with a known 10% error rate, does approving that strike after a few seconds of human review satisfy the legal requirement for distinction and proportionality? Write down your reasoning before reading the next section.

---

## 8. WhereDaddy: Technical Pipeline Reconstruction

The exact implementation is not public, but a reasonable reconstruction of WhereDaddy's architecture — consistent with the behaviors and data sources described by open reporting — reveals an end-to-end pipeline that ingests bulk surveillance data, maintains a dynamic person-to-home and person-to-device graph, and drives an alerting system[^43][^44][^46].

### Data Ingestion and Person Graph

**Upstream inputs:**
- Telecom and SIGINT feeds: call detail records, device IDs (IMEI/IMSI), approximate cell-tower or RF-based location, possibly Wi-Fi/Bluetooth or other RF sensors[^46][^43].
- ISR and geospatial data: drone and aircraft video, satellite imagery, map data, building outlines, address databases[^44][^46].
- Intelligence databases: Lavender's outputs (suspected militants and family ties), prior HUMINT reports, social/organizational network data[^43][^44].

**Entity resolution:** Each person in the Lavender kill list is linked to devices, phone numbers, and other identifiers, maintaining many-to-many edges (person ↔ phone ↔ SIM). For each person, one or more home locations are inferred using nighttime location clustering of phones, registry or address data, and kinship/household graphs derived from intel databases[^46][^44].

### Location and Presence Estimation

As telecom/SIGINT events arrive, the system updates the estimated location of each device and, by association, each person. For each home, a spatial footprint (polygon or radius) is defined, and for each target, a time-varying probability $$P(\text{target at home} \mid \text{device signals, ISR cues})$$ is computed using device location within the home polygon, dwell time, time of day, and prior patterns such as usual sleep hours. When the presence probability crosses a threshold, the system may automatically propose or schedule ISR collection such as a drone camera on that building for visual confirmation[^46][^44][^43].

### Targeting Logic and Alert Generation

The system references the Lavender kill list entries and rules of engagement (ROE) to determine whether a person is currently authorized as a valid target. Conditions typically include: target is on the Lavender list, probability of being at home is above threshold, timing window is open (often night), and target has not been recently struck. When conditions are satisfied, a WhereDaddy event is generated with fields like target ID, home location, confidence scores, suggested strike window, ISR evidence references, and collateral estimates[^44][^43].

Operators see a list or map of ready targets. According to whistleblower accounts, review time was often minimal (seconds), with humans mostly checking coarse attributes such as gender rather than re-verifying ground truth or civilian risk. On approval, the event is promoted to a fire mission request, which triggers standard fire-control and weaponeering processes[^44][^43].

### System Components (Abstracted)

An engineer's block diagram for a WhereDaddy-like system would likely include:

- Data ingestion bus: message queues / streams for telecom, SIGINT, ISR, intel DB updates.
- Entity and graph store: person–device–location–family graph, backed by a graph DB or ontology service.
- Presence and behavior models: ML models and rule engines for "who is where when."
- Policy/ROE engine: encodes targetability rules, time windows, and any collateral constraints.
- Target-state service: maintains current state of each target (at home, abroad, in vehicle, unknown).
- Alerting and UI: dashboards and APIs that surface "target at home" events to intel officers and feed C2.
- Audit/logging: logs all inferences, decisions, overrides, and strike outcomes (at least internally), though whistleblowers suggest the human review layer was shallow[^44][^43].

---

## 9. Broader Implications

WhereDaddy is widely cited in academic and policy discussions as an example of AI-mediated human targeting, where algorithms track individuals and optimize when to kill them rather than just where to strike infrastructure[^47][^45].

Commentators argue it illustrates how AI can collapse the line between surveillance and execution, making intimate life patterns — like visiting one's children — into triggers for lethal force. Human-rights lawyers warn that designing systems to hit people in their homes, where large numbers of civilians are predictably present, may violate proportionality and distinction requirements in the laws of war[^45][^47][^44].

These systems — Palantir's AIP, SpaceX's Starshield, Israel's WhereDaddy — don't exist in isolation. They represent a convergence: AI-driven intelligence fusion feeding autonomous targeting recommendations, delivered over militarized satellite networks, with human oversight that can be measured in seconds. Understanding their architecture, contracts, and ethical implications isn't just important for defense analysts. It's essential for anyone trying to understand what modern warfare has become.

**Final challenge:** You are asked to design the rules of engagement for an AI-assisted targeting system. Write three rules that would satisfy international humanitarian law while still allowing the system to be operationally useful. For each rule, explain how you would technically enforce it in software — and what would happen if someone disabled that enforcement.

---

[^1]: <https://www.palantir.com/platforms/>
[^2]: <https://en.wikipedia.org/wiki/Palantir>
[^3]: <https://d3.harvard.edu/platform-digit/submission/palantir-a-software-that-safes-and-takes-lives/>
[^4]: <https://x.com/i/grok/share/Z6ITPk8UBunEHVtb5LRn1r2El>
[^5]: <https://www.palantir.com/platforms/apollo/product/>
[^6]: <https://defensescoop.com/2024/05/29/palantir-480-million-army-contract-maven-smart-system-artificial-intelligence/>
[^7]: <https://breakingdefense.com/2024/03/palantir-wins-contract-for-army-titan-next-gen-targeting-system/>
[^8]: <https://www.defensenews.com/land/2025/03/07/palantir-delivers-first-2-next-gen-targeting-systems-to-army/>
[^9]: <https://www.reuters.com/technology/palantir-wins-480-million-us-army-deal-maven-prototype-2024-05-29/>
[^10]: <https://defensescoop.com/2025/05/23/dod-palantir-maven-smart-system-contract-increase/>
[^11]: <https://en.wikipedia.org/wiki/Palantir_Technologies>
[^12]: <https://caat.org.uk/data/companies/palantir/>
[^13]: <https://www.theregister.com/2026/01/28/mod_palantir_deal/>
[^14]: <https://www.publictechnology.net/2026/01/29/defence-and-security/mod-signs-240m-palantir-deal-as-ministers-insist-uk-defence-data-remains-sovereign/>
[^15]: <https://finance.yahoo.com/news/uk-mod-just-signed-240-145101136.html>
[^16]: <https://www.palantir.com/offerings/intelligence/>
[^17]: <https://www.palantir.com/offerings/defense/community/>
[^18]: <https://palantir.com/docs/foundry/aip/overview/>
[^19]: <https://palantir.com/docs/foundry/platform-overview/overview/>
[^20]: <https://www.palantir.com/docs/foundry/platform-overview/aip-capabilities>
[^21]: <https://www.palantir.com/docs/foundry/aip/overview>
[^22]: <https://www.toolify.ai/ai-news/unleashing-the-power-of-ai-in-military-operations-palantirs-aip-revealed-1410062>
[^23]: <https://www.youtube.com/watch?v=XEM5qz__HOU>
[^24]: <https://unit8.com/resources/palantir-foundry-aip/>
[^25]: <https://www.amcham.it/upload/documenti/1/10/102/1029/10293.pdf>
[^26]: <https://www.palantir.com/docs/foundry/aip/aip-security>
[^27]: <https://www.youtube.com/watch?v=pGBkkZFqLn4>
[^28]: <https://www.toolify.ai/ai-news/revolutionizing-defense-and-military-with-palantir-aip-19357>
[^29]: <https://www.cnbc.com/2025/08/01/palantir-lands-10-billion-army-software-and-data-contract.html>
[^30]: <https://en.wikipedia.org/wiki/SpaceX_Starshield>
[^31]: <https://www.spacex.com/starshield/>
[^32]: <https://www.cnbc.com/2022/12/05/spacex-unveils-starshield-a-military-variation-of-starlink-satellites.html>
[^33]: <https://www.space.com/spacex-starshield-space-force-contract>
[^34]: <https://news.satnews.com/2022/12/05/spacex-introduces-the-starshield-secured-satellite-network-for-government-entities/>
[^35]: <https://newspaceeconomy.ca/2025/03/01/spacex-starshield-a-new-frontier-in-government-satellite-services/>
[^36]: <https://www.pcmag.com/news/spacex-wins-pentagon-contract-to-supply-military-communications>
[^37]: <https://www.airandspaceforces.com/space-force-contract-spacex-starshield/>
[^38]: <https://breakingdefense.com/2025/06/space-force-is-contracting-with-spacex-for-new-secretive-milnet-satcom-network/>
[^39]: <https://news.satnews.com/2025/12/29/u-s-space-force-and-spacex-partner-to-develop-480-satellite-milnet-constellation/>
[^40]: <https://www.defensemirror.com/news/38339>
[^41]: <https://www.defensemirror.com/news/38339/Ukraine_Allowed_Access_to_Military_Satellite_Internet__Starshield>
[^42]: <https://www.bloomberg.com/news/articles/2024-12-06/spacex-gets-us-contract-to-expand-ukraine-s-access-to-starshield>
[^43]: <https://www.yahoo.com/news/israels-wheres-daddy-ai-system-093311866.html>
[^44]: <https://www.democracynow.org/2024/4/5/israel_ai>
[^45]: <https://theconversation.com/gaza-war-israel-using-ai-to-identify-human-targets-raising-fears-that-innocents-are-being-caught-in-the-net-227422>
[^46]: <https://substack.com/home/post/p-164261706>
[^47]: <https://www.linkedin.com/pulse/israels-wheres-daddy-system-hidden-risks-ai-combat-controism-gfr5e>
