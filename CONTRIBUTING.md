# Contributing to City Block

Thanks for your interest in contributing! This document explains how to propose changes, the coding standards used, and the workflow for pull requests.

---

## Ground Rules
- Be respectful and professional.
- Keep the scope small and focused. One PR per change set.
- Avoid adding external dependencies unless they clearly improve performance or developer ergonomics.

---

## How to Propose a Change
1. Search issues to avoid duplicates.  
2. Open an issue describing the problem or proposal. Use labels if applicable (see Labels).  
3. For significant changes, discuss in the issue first.  
4. When ready, open a PR referencing the issue.

---

## Development Environment
- Unity: 6.0 (6000.x) with URP  
- DOTS: Entities, Entities Graphics, Collections, Jobs, Burst, Unity Physics  
- Git LFS: installed for large assets (git lfs install)

Recommended editor: Rider or VS Code with C# Dev Kit.

---

## Repository Hygiene
- Do not commit Library/ or other build artifacts.  
- Use Git LFS for large binaries (textures, meshes, audio, video).  
- Prefer text-based assets where possible.

---

## Branching & Commit Style
- Branch from main:
  - feat/<short-name> for features
  - fix/<short-name> for fixes
  - chore/<short-name> for misc tasks
- Commit messages (Conventional Commits preferred):
  - feat(crowd): add lane-follow sampling step
  - fix(netcode): reconcile input jitter under packet loss
  - chore(ci): cache Library across jobs

---

## Code Style (C# / DOTS)
- C# 9+ style with analyzers enabled (.editorconfig).  
- Nullable reference types: enabled where practical.  
- Use Unity.Mathematics types (float3, quaternion) in DOTS code.  
- Components are data-only (IComponentData, IBufferElementData). Avoid managed refs in ECS components.  
- Prefer enableable components or buffers to avoid structural changes per frame.  
- Burst-compile hot paths; avoid allocations in tight loops.  
- Keep systems focused; group by domain (Simulation/Rendering/Netcode/Streaming).  
- Add unit or playmode tests where meaningful (bakers, utilities).

---

## Scenes, Prefabs, Assets
- Small, composable prefabs. Keep colliders and LODs consistent.  
- SubScenes should be cohesive and streamable. Avoid per-frame conversions.  
- Use shared materials and atlases. Keep texel density roughly 64–128 px/m.

---

## Netcode Guidelines
- Server is authoritative. Clients predict local player motion and interpolate others.  
- Do not write server-owned state from the client.  
- Keep ghost components lean; use LOD/relevancy to reduce bandwidth.  
- Use thin clients for load testing where possible.

---

## Testing
- EditMode tests: C# unit tests for utilities and bakers.  
- PlayMode tests: minimal runtime checks (e.g., systems wiring).  
- Run tests locally via Unity Test Runner.  
- CI runs tests automatically on PRs.

---

## Debugging & Profiling
- Use the in-game Debug HUD for quick metrics.  
- Unity Profiler: capture main thread, jobs, and GC.  
- For DOTS: enable Burst; turn off Jobs Leak Detection for perf runs.

---

## Labels
This repo uses a simple label scheme:
- type/epic, type/task  
- area/ci, area/project-settings, area/rendering, area/authoring, area/dots, area/physics, area/input, area/ui, area/build, area/content, area/docs, area/verification, area/release  
- Milestones use M0, M1, etc.

---

## Pull Request Checklist
- [ ] Branch up to date with main  
- [ ] Build succeeds locally  
- [ ] Tests pass locally (if applicable)  
- [ ] No GC allocations in hot paths  
- [ ] Scenes/Prefabs updated intentionally and minimal diffs  
- [ ] Docs/README updated if user-facing changes  
- [ ] Linked to an issue and labeled appropriately

---

## Security / Abuse
Open an issue for non-sensitive reports. For sensitive disclosures, contact the maintainer directly.

---

## License for Contributions
By submitting a contribution, you agree it may be incorporated into the project and distributed under the repository’s CBEEL v1.0 license, as described in LICENSE.
