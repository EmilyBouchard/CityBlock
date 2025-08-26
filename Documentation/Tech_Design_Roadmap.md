# City Block — Tech Design & Roadmap

**Author:** Emily Bouchard (Senior Game Programmer)  
**Engine:** Unity 6 (URP)  
**Tech Pillars:** DOTS-first (Entities/Jobs/Burst), server-authoritative multiplayer, predictable performance, low-poly aesthetic  
**Last Updated:** 2025-08-26

---

## 1) Elevator Pitch
A compact, living city block built from the ground up with Unity DOTS to showcase systems-level craftsmanship: dense NPC crowds, procedural micro-events, responsive first/third-person controls, and seamless multiplayer with an optional dedicated server. The visual style is deliberately minimal (low poly / low-res XBOX-era) to spotlight systems, scale, and performance.

---

## 2) Goals & Success Criteria
- **Demonstrate DOTS mastery:** entity archetype design, baking, custom systems/jobs, Burst optimization, Entities Graphics, Unity Physics.  
- **Server-authoritative multiplayer** with client prediction/interpolation, ghosting, and relevancy culling.  
- **Crowd simulation:** hundreds to thousands of lightweight ECS agents with local avoidance and lane/flow-field navigation.  
- **Procedural interactions & events:** ambient activities and bite-size objectives driven by data.  
- **Stable frame-time:** 60 FPS at 1080p on a mid-range PC GPU (target <= 16.6 ms frame; <= 6 ms main-thread; <= 10 ms jobs).  
- **Clean deliverables:** source repo, profiling captures, in-game debug HUD, short showcase video.

---

## 3) Target Platforms & Dependencies
- **Platform:** Windows PC (x64). Headless dedicated server build supported.  
- **Render pipeline:** URP (Forward+ if available).  
- **Core packages:**
  - Entities (1.3+), Entities Graphics (1.4+), Collections, Burst, Jobs  
  - Unity Physics (DOTS) with optional Havok Physics for heavier scenes  
  - Netcode for Entities (server-authoritative ghosts, prediction)  
  - Input System, UI Toolkit, Cinemachine (camera rigs)
- **Authoring:** SubScenes + Bakers; BlobAssets for static/data; Addressables for optional content.

> Exact package minor versions are pinned in `/Packages/manifest.json` and verified in CI.

---

## 4) Repository Layout
```text
CityBlock/
  Assets/
    ArtLowPoly/          # FBX/GLB meshes, low-res textures, palettes
    Authoring/           # MonoBehaviours, Bakers, ScriptableObjects
    Scenes/
      CityBlock_Main.unity
      SubScenes/         # Sidewalks, buildings, nav graph, spawn points
    UI/
  Packages/
  ProjectSettings/
  DOTS/
    Components/          # IComponentData, IBufferElementData
    Systems/
      Simulation/        # Movement, physics, nav, avoidance, interactions
      Rendering/         # LOD, impostors, light probes, decals
      Netcode/           # Ghosts, RPCs, commands, prediction
      Streaming/         # SubScene streaming, relevance
    Authoring/
    Tools/
  Server/
    Bootstrap/           # Headless entrypoint, settings
  Tests/
    PlayMode/
    EditMode/
```

---

## 5) Rendering & Aesthetic
- **Style:** XBOX-era low-poly; fixed palette; chunky silhouettes; sharp edge highlights; simple decals.  
- **Entities Graphics:** GPU instancing for buildings, props, crowd agents; LODs authored in DCC and baked as LODGroup -> ECS LODs.  
- **Lighting:** Baked GI for statics; few dynamic lights (caps/area) with light cookies.  
- **Effects:** Simple particle impostors (entities) for smoke/steam; planar reflections avoided; SSR disabled; fog for depth cueing.  
- **Performance:** Shared materials; texture atlases; 64-128 px/m target texel density; minimal post-processing.

---

## 6) World Building & Streaming
- **SubScenes:** sidewalk segments, street modules, building facades, interior stubs.  
- **Spatial indexing:** grid cells (e.g., 10x10 m) as entities with an Occupancy counter.  
- **Streaming policy:** load neighbor SubScenes around the player; unload far tiles; move-only data via BlobAssets; keep physics broadphase stable.  
- **Relevancy:** server only replicates ghosts in a radius (with hysteresis); clients smoothly fade entering actors.

---

## 7) Player Controller (First/Third Person)
- **Kinematic capsule** with shapecast step offset and slope handling (Unity Physics).  
- **Client prediction** for move/jump/sprint; reconciliation on snapshot ack.  
- **Third-person camera** via Cinemachine; shoulder swap; collision linecast.  
- **Input** via Input System actions; rebind UI.  
- **ECS layout** (example):
  - PlayerTag, MoveInput, DesiredVelocity, GroundingInfo, KinematicState, CameraRigRef

---

## 8) Crowd & Traffic (Scalable)
- **Navigation graph:** author sidewalk lanes as a spline/waypoint graph; precompute BlobAsset routes between POIs.  
- **Local avoidance:** lightweight ORCA-like step (no global solve), radial sampling with Burst jobs.  
- **State model:** Utility-AI scores on Desire (commute, loiter, buy, chat, watch).  
- **Spawners & pooling:** time-of-day density curves; outfit decorators; simple emotion flags.  
- **Budget:** start with 500-1,500 agents @ 60 FPS on mid-tier desktop; scale with LOD (full anim -> impostor card).  
- **Extension:** optional single-lane vehicle loops for ambience (authoring only).

---

## 9) Procedural Interactions & Events
- **Affordances:** ECS tags on props (e.g., VendingMachine, Bench, NewsStand, Door).  
- **Event templates** (SO -> Blob): trigger rules, participants, steps, rewards, cooldowns.  
- **Event runner:** job-driven scheduler picks candidates by proximity/availability; assigns roles; writes Activity buffers to agents.  
- **Examples:**
  - Street artist spawns; crowd gathers; tip jar increments  
  - Power outage micro-event: streetlights flicker -> player can fix fuse box  
  - Coffee coupon pop-up: visit kiosk for a small sprint boost
- **Player integration:** small prompts (UI Toolkit); XP or small perks for completing micro-goals.

---

## 10) Networking Architecture
- **Model:** server-authoritative dedicated server (headless) or listen server.  
- **Transport:** Netcode for Entities (ghost snapshots, RPCs, commands).  
- **Prediction/Interpolation:** player motion predicted; NPCs interpolated; high-priority ghosts for neighbors; snapshot delta + tick-based rollback.  
- **Ghost archetypes:** Player, Agent (LOD-switched ghosts), Door/Prop, EventController.  
- **Relevancy:** per-client interest management by grid cell + FOV cone for crowd.  
- **Session flow:** bootstrap -> map seed -> spawn points -> late-join resync -> seamless handoff to gameplay.  
- **Anti-cheat basics:** input command rate limits; sanity checks; server-side nav validation.

---

## 11) UI/UX
- **UI Toolkit** for HUD and menus; data-driven panels bound to ECS via thin presenters.  
- **Debug HUD:** frame time, job timings, entity counts per archetype, ghost bandwidth, GC allocs.  
- **Diegetic prompts:** small radial prompt near focus; minimalist quest log; map inset.

---

## 12) Tools & Workflows
- **Bakers** for nav graph, POIs, lane splines, LOD data, spawn tables.  
- **Scenario sandbox:** in-editor window to spawn micro-events and visualize desirability heatmaps.  
- **Replay recorder:** store input and major events; deterministic replays for perf regressions.  
- **CI:** per-commit Windows build (client and headless), unit + playmode tests, code style.

---

## 13) Performance Plan
- **Budgets (ms @ 60 FPS):** Main 6, Render 6-8, Jobs 6-10, Netcode <= 2, UI <= 0.5, GC 0.  
- **Archetype hygiene:** keep hot components tight (SoA via IComponentData); avoid structural changes by using enableable components/buffers.  
- **Burst everywhere;** prefer IJobEntity/IAspect for tight inner loops; use Unity.Mathematics.  
- **Physics:** simple colliders; continuous only where required; broadphase stable across frames.  
- **Entities Graphics:** cross-fade off for LOD; batch thresholds tuned; static batching for non-entity renderers.

---

## 14) Risks & Mitigations
- **Nav with DOTS:** use author-time lane graph + simple local avoidance rather than heavy runtime navmesh agents; bridge only where needed.  
- **Netcode complexity:** limit write-frequency; ghost LOD; authoritative triggers only.  
- **Content sprawl:** lock art style; keep prop sets tiny; lean on decorators (hats, colors).  
- **Streaming hiccups:** warm pools, incremental blob loads; avoid large archetype churn.

---

## 15) Milestones (6 Sprints, Multiplayer Early)
**M0 - Bootstrap (1-2 wks)**  
Project setup, URP, SubScenes, Bakers, starter low-poly set, Entities Graphics, input, debug HUD. Headless server target added to CI.

**M1 - Movement & World (2 wks)**  
Kinematic controller (1P/3P), camera rigs, collisions, grid cells, streaming shell, interact raycasts. Capture first performance baselines.

**M2 - Multiplayer Core (2-3 wks) - moved earlier**  
Netcode for Entities bootstrap (ghosts, RPCs, commands), client prediction and reconciliation for player motion, snapshot interpolation, relevancy by grid cell, listen and dedicated server flows, basic lobby. Add network soak tests in CI.

**M3 - Crowd MVP (2 wks) - network-aware**  
Lane graph, spawners, local avoidance, simple idles/decorators as server-authored ghosts with LOD-based replication; client-side impostor pathing for far LOD if needed. First bandwidth and relevancy tuning passes.

**M4 - Events & Mini-Objectives (2 wks) - replicated**  
Event templates (SO -> Blob), scheduler on server, replicated triggers/state, affordance tags, player rewards. Validate determinism/prediction safety. Record replay for regression.

**M5 - Polish & Showcase (1-2 wks)**  
Telemetry, frame-time polish, QA checklist, capture multiplayer demo reel, README/site. Perf targets: 60 FPS solo; >= 50 FPS with 8 players + 800-1500 agents on mid PC.

**Cross-cutting validation each sprint**  
- Multiplayer playtest at end of every sprint (listen + dedicated)  
- Packet/BW budgets tracked in Debug HUD; ghost counts per archetype; GC allocs = 0  
- Replays captured for perf and correctness regression

---

## 16) MVP Backlog (Concrete)
- SubScene: 3x street modules, 2x alley pieces, 6x facade prefabs  
- Player: walk/sprint/jump, interact, camera swap  
- Crowd: 200 walkers, 4 lane loops, bench/vending affordances  
- Events: busker, kiosk coupon, light-fuse fix  
- Netcode: 8 players, spawn/respawn, chat ping, prop doors replicated  
- UI: HUD, settings, mini-map inset, debug HUD  
- Perf gates: 60 FPS solo; >= 50 FPS with 8 players and 800-1500 agents on mid PC

---

## 17) Showcase Plan
- 2-3 minute reel: walking tour, crowd density, event triggers, multiplayer sync shots, profiler overlay  
- README highlights: package versions, perf numbers, profiler captures, design rationale

---

## 18) Stretch Ideas (time permitting)
- Simple weather and day/night; dynamic density curve  
- Ambient vehicle loop with stoplights (scripted)  
- Photo mode; replay scrubbing; Steam demo packaging