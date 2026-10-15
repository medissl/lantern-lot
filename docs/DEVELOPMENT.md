# Development

The existing Lantern Lot economic prototype is now presented through persistent pixel-art rooms. The detailed current implementation, acceptance matrix boundaries, asset provenance and evidence paths are in [visual overhaul status](VISUAL_OVERHAUL_STATUS.md).

## Architecture

- `scripts/domain/` and `content/prototype.json`: unchanged current rules/content.
- `scripts/services/game_session.gd`: unchanged durable command/Retry boundary; `save_service.gd` retains compatible A/B economic saves.
- `scripts/ui/main.gd`: one session owner, persistent HUD/world, context sheets, intent latch, safe-area/physical-pixel transform, settings and isolated evidence harness.
- `scripts/presentation/room_view.gd`: UID reconciliation, six display sockets, public lot presentation, Y-sorted fixtures/actors/goods, navigation and committed cosmetic reactions.
- `actor_view.gd`, `item_view.gd`, `world_input_router.gd`: stable raster pivots, bounded motion and explicit pointer mapping.
- `layout_controller.gd`: free decor/display placement, protected aisle/service reachability, undo/cancel.
- `presentation_save.gd`: independent versioned checksummed visual files; never repairs economic state.
- `scenes/ui/`, `scenes/world/`, `scenes/actors/`, `scenes/props/` and `resources/visuals/`: reusable scenes and shared tile resources.
- `art/`: editable original raster/sound source, review sheets and asset validation. Runtime assets/fonts/notices are local.

## Verification

Run `tools/verify.ps1 -FullSizeMatrix -RecordMovie`; supply `-PythonExecutable` for a Python with Pillow. It records full logs, expected negative-save failures and exit status. Inspect the PNGs and movie directly. `tests/preview.tscn` starts a playable scratch-save session. Never use normal saves to manufacture screenshots.

Domain checks remain 3,907; presentation, rendered controller and responsive suites add risk-focused integration coverage. A passing domain suite cannot establish pixel quality, mobile accessibility or physical-device behavior.

## Future work

Physical Android/iOS exports, actual safe areas/suspension, mobile screen readers, longer device profiles, audio audition and human pacing/art feedback remain open. The larger randomized board/catalog, relationships and progression in `DESIGN.md` are separate work. Do not expand or migrate economic schemas to store cosmetics.
