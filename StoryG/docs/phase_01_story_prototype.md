# 1. Architecture Summary

This prototype now runs as a 2D Godot 4.6 story project inside `StoryG`. The shared runtime is still designed for one Godot project with separate Android and Web exports, but the gameplay path has been corrected to a handheld-style 2D presentation.

Current playable flow:

- `Title Screen`
- `Intro Screen` with professor dialogue
- `Character Select`
- `Bedroom Waking Up`
- `2D controllable player in the room`

Imported source assets now in use from `Pokemon sprites`:

- trainer select portraits
- overworld walking sprite sheets
- professor Rowan sprite
- intro and professor music
- interior tileset imported for room art reference and decor

# 2. Folder Structure

```text
StoryG/
  assets/
    imported/
      audio/
      characters/
      tilesets/
      ui/
  docs/
    phase_01_story_prototype.md
  scenes/
    common/
    menus/
    player/
    ui/
    world/
  scripts/
    autoload/
    core/
    menus/
    player/
    ui/
    world/
```

# 3. Scene Tree Structure

Boot:

- `scenes/common/app_boot.tscn`

Menu flow:

- `scenes/menus/title_screen.tscn`
- `scenes/menus/intro_screen.tscn`
- `scenes/menus/character_select_screen.tscn`

Gameplay:

- `scenes/world/bedroom_scene.tscn`
  - `RoomRoot`
  - `PlayerCharacter`
  - HUD overlay for wake-up text and controls

# 4. Autoloads And Managers

- `InputActions`
  - registers keyboard and gamepad actions
- `GameSession`
  - selected character
  - intro seen flag
  - current scene
  - placeholder save slot
  - launch params for Flutter handoff
- `LaunchBridge`
  - reads command-line args and web query params
- `TransitionLayer`
  - shared fade transitions
- `SceneRouter`
  - entry routing and scene changes

# 5. InputMap Plan

Registered actions:

- `ui_accept`
- `ui_cancel`
- `ui_left`
- `ui_right`
- `ui_up`
- `ui_down`
- `move_left`
- `move_right`
- `move_forward`
- `move_back`
- `interact`
- `pause`
- `advance_dialogue`
- `skip_intro`

Defaults:

- keyboard: `WASD`, arrows, `Enter`, `Space`, `Esc`, `E`, `P`, `X`
- gamepad: D-pad, left stick, south/east/north/start buttons
- touch and click: buttons, dialogue tap advance

Controller support notes:

- Razer Kishi: expected to map through Godot as a standard Android-compatible gamepad, using left stick or D-pad plus south/east/start buttons
- Xbox controllers: south=`A`, east=`B`, north=`Y`, start=`Menu`
- PS5 DualSense: south=`Cross`, east=`Circle`, north=`Triangle`, start=`Options`
- Switch-style controllers: Godot uses logical south/east/north mapping even though the printed face labels differ physically

Current logical action layer:

- accept: south button
- cancel/back: east button and back button fallback
- skip intro: north button and right shoulder fallback
- pause: start and back fallback
- movement/navigation: left stick and D-pad

# 6. GDScript Scripts

Key scripts:

- `scripts/autoload/game_session.gd`
- `scripts/autoload/scene_router.gd`
- `scripts/ui/dialogue_sequence_player.gd`
- `scripts/player/player_controller.gd`
- `scripts/world/bedroom_controller.gd`

The player now uses `CharacterBody2D` and sprite-sheet driven facing / walking instead of the previous 3D controller.

# 7. Bedroom Environment Setup

The opening room is now a 2D top-down bedroom prototype. For this phase it combines:

- `TileMapLayer`-based room layout for floor, walls, and furniture
- collision bodies for traversal boundaries
- imported interior tileset as an art source / decor hook
- trainer overworld sprite for the player

Current tile-mapping setup:

- atlas texture: `assets/imported/tilesets/4g tileset_interieur.png`
- source tile size: `16x16`
- world display scale: `2x`, producing a `32x32` gameplay grid
- dedicated layers: `FloorLayer`, `WallLayer`, `FurnitureLayer`
- temporary grid overlay enabled for visual tile-placement accuracy while authoring

Recommended modern Godot 4.6 2D workflow going forward:

- use `TileMapLayer` for finalized interior maps
- create one reusable bedroom / house tileset resource from imported sheets
- keep collision on dedicated layers
- keep decor and interactables on separate tile or object layers
- use scene-based interactables for special props like bed, desk, TV, door

For this prototype I did not force the old external map format directly into runtime yet; instead I imported the assets into `StoryG` and used them to establish the 2D pipeline cleanly.

# 8. Player Controller Setup

Player setup:

- `CharacterBody2D`
- top-down movement
- sprite-sheet facing by direction
- walk / idle animation hook
- room collision
- `Camera2D` follow camera

Expansion hooks:

- sprint toggle
- interaction prompts
- cutscene movement lock
- animation state machine
- map transitions

# 9. Menu / Controller Navigation Setup

Current menu behavior:

- title starts focused on `Story`
- intro advances with `Enter`, `Space`, south button, or tap
- intro skips with `Esc`, cancel, or north button
- character select supports focus navigation and direct tap/click
- selected trainer is stored in `GameSession`

Imported art usage:

- `welcome-bg.png` supports title / intro presentation
- `welcome-boy.png` and `welcome-girl.png` support selection cards
- `npc_prof-rowan.png` supports professor dialogue framing

# 10. Scene Transition Setup

All flow still goes through:

- `SceneRouter`
- `TransitionLayer`

Transition style:

- fade out
- scene change
- fade in

# 11. Flutter Integration Notes

Android flow:

1. Flutter Home screen Story button is tapped.
2. Native handoff opens the Godot Android export.
3. Launch data is passed through intent extras or bridge glue.
4. Godot reads those values into `LaunchBridge` and starts at the desired story scene.

Web flow:

1. Flutter web Story button navigates to a Story page.
2. That page embeds the Godot Web export.
3. Query params or a JS bridge pass session data into Godot.

Launch payloads already planned for:

- `user_id`
- `save_slot`
- `language`
- `session_token`
- `chapter_start`

# 12. Testing Checklist

- Project boots to title
- Title music plays
- Story starts intro flow
- Professor scene shows dialogue and advances correctly
- Character select stores `player_m` or `player_f`
- Bedroom scene loads after confirmation
- Player sprite changes based on selected trainer
- Player can move and collide with room obstacles
- Keyboard, controller, and click/tap interactions work through the full flow

# 13. Future Expansion Notes

Placeholder art plan:

- keep imported trainer portraits for selection until custom UI art exists
- keep overworld trainer sheets for movement until character-specific sheets are authored
- convert the interior tileset into a proper Godot `TileSet` / `TileMapLayer` workflow next

How to swap prototype room assets later:

- replace block-color room pieces with proper atlas-based tiles
- move furniture from code-built shapes to reusable 2D prop scenes
- keep collision and interaction data stable while swapping visuals

How to expand into full save-select:

1. Add `SaveSelectScreen` after title.
2. Promote `placeholder_save_slot` into a real save-slot data model.
3. Route new saves into character select.
4. Route existing saves directly into the current map / chapter.

How to turn the bedroom into the true Chapter 1 opening:

1. Add a bed interaction and wake animation.
2. Add desk, window, and door prompts.
3. Gate the exit until the first story beat completes.
4. Transition from bedroom to the first town or lab map.
