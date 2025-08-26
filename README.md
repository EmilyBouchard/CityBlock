# City Block - Tech Design Demo

A compact, living city block demo built with Unity 6 and DOTS to showcase systems-level craftsmanship: dense NPC crowds, procedural micro-events, responsive first/third-person controls, and seamless multiplayer with an optional dedicated server. Visuals are intentionally XBOX-era low-poly to spotlight scale and performance.

[![CI](https://github.com/EmilyBouchard/CityBlock/actions/workflows/ci.yml/badge.svg)](https://github.com/<owner>/<repo>/actions/workflows/ci.yml)
[![License: CBEEL v1.0](https://img.shields.io/badge/license-CBEEL-blue.svg)](./LICENSE)

---

## Table of Contents
- Features
- Requirements
- Quick Start
- Builds
- Run the Dedicated Server
- Debug HUD
- Project Layout
- Performance Budget
- Roadmap
- License

---

## Features
- DOTS-first architecture (Entities/Jobs/Burst, Entities Graphics, Unity Physics)
- Server-authoritative multiplayer with Netcode for Entities
- Crowd simulation (hundreds to thousands) with local avoidance and lane graph
- Procedural interactions and micro-events
- SubScenes streaming, GPU instancing, LODs
- In-game Debug HUD for timings, entity counts, bandwidth hints

---

## Requirements
- Unity: 6.0 (6000.x) with URP  
- OS: Windows x64 (primary dev target)  
- Builds: GitHub Actions + GameCI produce Windows client and Linux dedicated server artifacts  
- Git LFS: enabled for large binary assets (textures, meshes, audio)

Exact package versions are pinned in:
- Packages/manifest.json
- Packages/packages-lock.json

---

## Quick Start
```bash
    # clone
    git clone https://github.com/EmilyBouchard/CityBlock.git
    cd CityBlock

    # optional: enable LFS if not already
    git lfs install
    git lfs pull
```

1. Open the project in Unity 6.  
2. Open the scene: Assets/Scenes/CityBlock_Main.unity  
3. Press Play.

If packages reimport, first load may take a few minutes.

---

## Builds

### Editor menu (if BuildScripts.cs is present)
- Client (Windows x64): Build > City Block > Build Client  
- Dedicated Server (Linux x64): Build > City Block > Build Dedicated Server

### CI (GitHub Actions)
This repo includes .github/workflows/ci.yml:
- Runs editmode/playmode tests
- Publishes artifacts:
  - client-win64
  - server-linux64 (Dedicated Server subtarget)

---

## Run the Dedicated Server

Linux:
```bash
    ./CityBlockServer.x86_64 -batchmode -nographics -logfile -
```

Windows:
```bash
    .\CityBlockServer.exe -batchmode -nographics -logfile -
```

Common flags (if implemented):
- -port <number>
- -seed <number>

Clients connect via the in-menu join flow or a simple connect field (WIP).

---

## Debug HUD
Toggle the HUD in-game to view:
- FPS and frame time (ms)
- Entity counts (total and top N archetypes)
- GC allocs/frame (target 0)
- Build/version and package versions
- (Optional) Netcode stats: ghost counts, snapshot size, RTT

---

## Project Layout
```text
    Assets/
      ArtLowPoly/          # Low-poly meshes and low-res textures
      Authoring/           # MonoBehaviours, Bakers, ScriptableObjects
      Scenes/
        CityBlock_Main.unity
        SubScenes/         # Sidewalks, buildings, nav graph, spawners
      UI/

    DOTS/
      Components/          # IComponentData, IBufferElementData
      Systems/
        Simulation/        # Movement, physics, nav, avoidance, interactions
        Rendering/         # LOD, instancing, decals
        Netcode/           # Ghosts, RPCs, commands, prediction
        Streaming/         # SubScene streaming, relevance
      Authoring/
      Tools/

    Server/
      Bootstrap/           # Headless entrypoint, settings

    Tests/
      EditMode/
      PlayMode/
```

---

## Performance Budget
- Target 60 FPS @ 1080p on mid-range PC
- Main thread: <= 6 ms
- Render thread: 6–8 ms
- Jobs: 6–10 ms
- Netcode: <= 2 ms
- UI: <= 0.5 ms
- GC: 0 allocs/frame

---

## Roadmap
- Design doc: docs/Tech_Design_Roadmap.md  
- Milestone 0 breakdown: see project issues (label: M0) and epics

---

## License
This repository is licensed under City Block Evaluation & Educational License (CBEEL) v1.0.
- Free to view, run, and evaluate  
- Educational institutions may use it for classroom teaching and coursework  
- Commercial use and general redistribution are not permitted

See LICENSE for details.

Copyright (c) 2025 Emily Bouchard
