Param(
  [string]$Repo  # optional; e.g. "yourname/CityBlock"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Detect repo if not provided
if (-not $Repo -or $Repo.Trim() -eq "") {
  $repoJson = gh repo view --json nameWithOwner | ConvertFrom-Json
  $Repo = $repoJson.nameWithOwner
}
$Milestone = "M0 - Bootstrap"   # ASCII title

Write-Host "Using repository: $Repo"
Write-Host "Milestone: $Milestone"

function Ensure-Label {
  param([string]$Name, [string]$Color, [string]$Desc)
  try { gh label create $Name --color $Color --description $Desc --repo $Repo *> $null } catch {}
}

function Append-ToBody {
  param([string]$IssueNumber, [string]$Line)

  # Get current body via REST (JSON is reliable on Windows)
  $issueJson = gh api "repos/$Repo/issues/$IssueNumber"
  $issue     = $null
  if ($issueJson) { $issue = $issueJson | ConvertFrom-Json }

  $current = ""
  if ($issue -and $issue.body) { $current = [string]$issue.body }

  # Append with a newline (handle empty body)
  $newBody = if ($current.Length -gt 0) { "$current`n$Line" } else { $Line }

  # Update body (no jq; let gh do the quoting)
  gh issue edit $IssueNumber --repo $Repo --body $newBody *> $null
}

function Get-MilestoneNumber {
  param([string]$Repo, [string]$Title)
  # Find existing milestone by title; create if missing
  $msListJson = gh api "repos/$Repo/milestones?state=all"
  $msList = @()
  if ($msListJson) { $msList = $msListJson | ConvertFrom-Json }
  $match = $msList | Where-Object { $_.title -eq $Title } | Select-Object -First 1
  if (-not $match) {
    $created = gh api -X POST "repos/$Repo/milestones" -f "title=$Title" | ConvertFrom-Json
    return $created.number
  }
  return $match.number
}

function New-Issue {
  param([string]$Title, [string]$Body, [string[]]$Labels, [string]$MilestoneName)
  $msNumber = Get-MilestoneNumber -Repo $Repo -Title $MilestoneName

  # Build -f form args (labels[] repeated)
  $form = @("-f", "title=$Title", "-f", "body=$Body", "-f", "milestone=$msNumber")
  foreach ($l in $Labels) { $form += @("-f", "labels[]=$l") }

  # Create via REST; reliable JSON output
  $json = gh api -X POST "repos/$Repo/issues" @form
  if (-not $json) { throw "gh api returned no output creating issue: $Title" }
  return (ConvertFrom-Json $json).number
}


# Ensure labels
Ensure-Label "M0"                "5319e7" "Milestone 0"
Ensure-Label "type/task"         "ededed" "Task"
Ensure-Label "type/epic"         "b60205" "Epic"
Ensure-Label "area/ci"           "1d76db" "CI & automation"
Ensure-Label "area/project-settings" "1d76db" "Project settings"
Ensure-Label "area/rendering"    "0e8a16" "Rendering & URP"
Ensure-Label "area/authoring"    "0e8a16" "Authoring & SubScenes/Bakers"
Ensure-Label "area/dots"         "fbca04" "DOTS core"
Ensure-Label "area/physics"      "c2e0c6" "Physics"
Ensure-Label "area/input"        "c5def5" "Input & Cameras"
Ensure-Label "area/ui"           "bfdadc" "UI & Debug HUD"
Ensure-Label "area/build"        "5319e7" "Build & scripts"
Ensure-Label "area/content"      "fef2c0" "Sample content"
Ensure-Label "area/docs"         "d4c5f9" "Documentation"
Ensure-Label "area/verification" "d93f0b" "Verification"
Ensure-Label "area/release"      "d93f0b" "Deliverables/Release"

# Ensure milestone
try { gh milestone create $Milestone --repo $Repo *> $null } catch {}

# Workstreams & tasks (ASCII only)
$workstreams = @(
  @{ Code="A"; Title="Repo & CI Hygiene"; Area="area/ci"; Tasks=@(
    "Add .gitignore (Unity + Rider/VS) and .gitattributes enabling Git LFS for asset types (*.psd, *.png, *.fbx, *.glb, *.wav, *.mp4, *.asset, *.unity).",
    "Commit LICENSE (CBEEL v1.0) and a short source header snippet.",
    "Add .editorconfig and enable Roslyn analyzers (EnableNETAnalyzers + AnalysisMode=AllEnabledByDefault).",
    "Ensure Packages/manifest.json and packages-lock.json are pinned; document exact versions in README.",
    "CI: verify ci.yml runs on PRs; produce artifacts client-win64 and server-linux64 with build metadata.",
    "Add README CI badge and a minimal CONTRIBUTING.md."
  )},
  @{ Code="B"; Title="Project Settings"; Area="area/project-settings"; Tasks=@(
    "Player settings: set Company/Product names; choose scripting backend (IL2CPP or Mono) and document the choice.",
    "Active Input Handling: switch to Input System Only; remove legacy input if unused.",
    "Time: set Fixed Timestep (e.g., 0.02) and document in README.",
    "Quality: create a CityBlock profile tuned for low-poly (shadow caps, minimal post).",
    "Rendering: set Linear color space; choose MSAA (2x/4x); turn VSync off in dev builds.",
    "Layers/Tags: reserve layers (Agents, Props, Triggers) and tags (Player, SpawnPoint)."
  )},
  @{ Code="C"; Title="URP & Rendering Baseline"; Area="area/rendering"; Tasks=@(
    "Create URP Pipeline Asset + Renderer Data; assign in Graphics settings.",
    "Establish minimalist Lit material palette and a trim sheet.",
    "Enable SRP Batcher; confirm batching in Frame Debugger.",
    "Create an LOD template prefab (LOD0/1/2) for props/buildings."
  )},
  @{ Code="D"; Title="Scenes, SubScenes & Authoring Structure"; Area="area/authoring"; Tasks=@(
    "Create entry scene Scenes/CityBlock_Main.unity (Bootstrap).",
    "Create Scenes/SubScenes/ for Street_Segments, Sidewalks, Buildings_Facades, POIs, Spawners.",
    "Add SubScene GameObjects with proper conversion modes; ensure conversion logs are clean.",
    "Author a 10x10 m grid as Authoring components and bake to ECS grid entities."
  )},
  @{ Code="E"; Title="DOTS Foundations"; Area="area/dots"; Tasks=@(
    "Create assemblies: DOTS.Components, DOTS.Systems, DOTS.Authoring, DOTS.Tools (Editor-only).",
    "Add sample components: GridCell, SpawnPoint, BuildInfo, FrameStats.",
    "Create a trivial IJobEntity system that increments a counter; verify Burst is enabled.",
    "Add Entities Graphics instancing test: spawn ~1000 entity cubes with LOD."
  )},
  @{ Code="F"; Title="Bakers & BlobAssets"; Area="area/authoring"; Tasks=@(
    "Implement LaneSplineAuthoring + Baker that emits a spline BlobAsset and an entity buffer of waypoints.",
    "Implement SpawnPointAuthoring + Baker (position/rotation, type).",
    "Add NavGraphAuthoring that collects lane endpoints into a small routing Blob graph.",
    "Add Editor gizmos to visualize lanes and spawn points."
  )},
  @{ Code="G"; Title="Physics Baseline (Unity Physics)"; Area="area/physics"; Tasks=@(
    "Install Unity Physics; add a PhysicsStep singleton with default gravity.",
    "Add ground plane collider and a dynamic box entity; validate collisions in Play Mode.",
    "Define collision filters for Agents/Props/World and document category IDs."
  )},
  @{ Code="H"; Title="Input & Camera Shell"; Area="area/input"; Tasks=@(
    "Create an InputActions asset with Move, Look, Jump, Sprint, Interact.",
    "Set up Cinemachine rigs: First-Person (rotation-only) and Third-Person (follow + shoulder swap); add camera collision linecast.",
    "Bind input to camera look on mouse/gamepad to validate Input System wiring."
  )},
  @{ Code="I"; Title="Debug HUD (UI Toolkit)"; Area="area/ui"; Tasks=@(
    "Create UI/DebugHUD (UIDocument + USS); bind to a toggle key.",
    "Display HUD data: FPS, frame time (ms), total entity count, top-N per archetype, GC alloc/frame, build/version, Unity/Entities versions.",
    "Optional: add a small System Profiler table using ProfilerRecorder."
  )},
  @{ Code="J"; Title="Build Targets & Scripts"; Area="area/build"; Tasks=@(
    "Configure Scenes in Build for the desktop client.",
    "Create Assets/Editor/BuildScripts.cs with PerformClientBuild() and PerformDedicatedServerBuild() (sets StandaloneBuildSubtarget.Server).",
    "Verify local builds succeed (Windows client and Linux server) and match CI outputs."
  )},
  @{ Code="K"; Title="Sample Content (Low-Poly Starter)"; Area="area/content"; Tasks=@(
    "Create 6-8 primitive props (bench, trash can, kiosk, light pole) with LODs and colliders.",
    "Create 2-3 facade prefabs using the trim sheet; verify draw call counts via instancing.",
    "Assemble a tiny block (two streets + one alley); ensure sensible SubScene boundaries."
  )},
  @{ Code="L"; Title="Documentation"; Area="area/docs"; Tasks=@(
    "Update README: quick start, Unity and package versions, input map, running client/server, opening SubScenes.",
    "Add Docs/Perf.md (budgets, profiling tips, disabling vsync, useful editor prefs).",
    "Add Docs/Art.md (palette, texel density 64-128 px/m, LOD conventions, naming)."
  )},
  @{ Code="V"; Title="Verification Checklist"; Area="area/verification"; Tasks=@(
    "Press Play: scene loads; SubScenes convert/stream; Debug HUD visible; FPS > 60; no GC spikes.",
    "CI on a PR: tests pass (even if empty suite); client/server artifacts are produced and downloadable.",
    "Dedicated server binary runs headless (-batchmode -nographics) and prints build/version header."
  )},
  @{ Code="R"; Title="Deliverables"; Area="area/release"; Tasks=@(
    "Commit(s) implementing all workstreams.",
    "CI run with artifacts attached.",
    "Short screen capture (10-20 s) showing the minimal block and Debug HUD."
  )}
)

# Create epics and tasks
$epicNums = @{}

foreach ($ws in $workstreams) {
  $epicTitle = "M0/$($ws.Code): $($ws.Title) (Epic)"
  $epicBody  = "**Workstream:** $($ws.Title)`n**Milestone:** $Milestone`n`nThis epic tracks all tasks for the workstream. Child issues are appended as they are created."
  $epicNum   = New-Issue -Title $epicTitle -Body $epicBody -Labels @("type/epic","M0",$ws.Area) -MilestoneName $Milestone
  $epicNums[$ws.Code] = $epicNum
  Write-Host "Created epic $($ws.Code): #$epicNum"

  $i = 0
  foreach ($task in $ws.Tasks) {
    $i++
	$taskTitle = "M0/$($ws.Code).$($i): $task"	
    $taskBody  = "**Context**`nWorkstream: $($ws.Title) (M0)`n`n**Task**`n$task`n`n**Acceptance Criteria**`n- Implemented and committed.`n- Verified locally (Play/Editor where applicable).`n- Referenced in README/docs if configuration changes.`n- Linked back to this epic."
    $taskNum   = New-Issue -Title $taskTitle -Body $taskBody -Labels @("type/task","M0",$ws.Area) -MilestoneName $Milestone
    Append-ToBody -IssueNumber $epicNum -Line "- [ ] #$taskNum $task"
    Write-Host "  - Created task #$taskNum"
  }
}

Write-Host "Done. Epics and tasks created and linked."
