# Original raster art source

Run `art/build_pixel_art.py` with Python 3 and Pillow to regenerate the new
overhaul art, actor SpriteFrames and original synthesized WAV effects. All
drawings use integer coordinates at native resolution. There is no raster
reference tracing, downloaded sprite, vector antialiasing, or procedural
runtime substitute for these raster assets.

The script is the editable source. Palette names, object silhouettes, material
clusters, actor clothes, animations and floor details are separate sections.
Every good has an independent authored silhouette; the covered object deliberately
has no identity marks. Actor sheets contain 12 horizontal 24×32 cels, with foot
pivot (12,28): idle 0–1, walk 2–5, interact 6–7, carry 8–9, bid 10–11. Carry and
bid have distinct pose frames. TRES resources have matching named animations.

The full runtime directional set is `{actor_id}_directional.png`, 816×128:
34 cels per row, down/left/right/up rows, with a two-pixel transparent gutter
inside each cel. Matching external SpriteFrames resources provide `idle_DIR`
(4 frames at3fps), `walk_DIR` (6at8), `interact_DIR` (4at6), `carry_idle_DIR`
(2at2), `carry_walk_DIR` (6at8), `bid_DIR` (4at8 with a quarter-second hold),
`browse_DIR` (4at4), `handoff_DIR` (4at8). Foot pivot stays (12,28). Carry
anchors are recorded by direction; up-facing goods go behind the body. The
compact original12-cel atlas remains as an integration-compatible alternative.

Run `art/build_inspect_ui.py` after the base generator to rebuild dedicated
64×64 inspection drawings and the 32×32 ninepatch ledger UI skin. This source
also registers the three downloaded font binaries without modifying them.
The inspect art is newly drawn in the same palette, with fictional maker
details, measured-cup marks, a local tram illustration and material wear.
Covered goods keep a neutral parcel silhouette until legally revealed.

UI patch margins are8pixels on all sides. Suggested content margins are
12horizontal/8vertical. Teal buttons have normal/hover/pressed/disabled skins;
timber tabs have normal/pressed skins. `focus_ring.png` has a transparent
center and dual ink/ivory outline for both dark and paper surfaces. Use nearest
sampling for the skin; interface text remains high resolution and independent.

All four contact sheets in `art/review/` were directly opened and visually
inspected on 14 October 2026. The nine goods were reviewed at 3× integer scale;
actors at 2× and 3×; fixtures/architecture at integer scales. The room integration
must additionally verify depth, real phone-size readability, and animation in
the running engine. Raster quality and runtime composition are separate gates.
On15October2026, dedicated inspect, ledger UI and font specimen sheets were
also opened and directly inspected. Full directional pose sheets, all11 actor
appearances in four directions, stock-capacity props, and all seven effect
strips were viewed. Runtime composition/animation remains a separate gate.

Warm floor tiles0–5 are also available through the shared
`resources/visuals/room_tileset.tres` (source IDs0–5, atlas coord0,0; no
collision). Architecture overlays retain walls/bay/threshold while leaving
the stone floor transparent for the runtime TileMapLayer. Full-room PNGs
remain available as source composition references.

`assets/visual_manifest.json` contains provenance and registration for every
required asset. Original audio waveforms are generated at mono 22,050 Hz with
quiet exponential envelopes; runtime playback and device audition remain QA.
See `THIRD_PARTY_NOTICES.md` for CC0-1.0 terms.
