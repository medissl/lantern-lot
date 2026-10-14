# Lantern Lot

An offline secondhand-shop game built in **Godot 4.7.2 Standard**, typed GDScript, and the Compatibility renderer. The finalized [design document](DESIGN.md) is the design authority; this repository starts the first playable domain prototype.

## Run

Import `project.godot` in Godot 4.7.2 and press **F6** on `scenes/main.tscn` or **F5** for the project. The development window is portrait, 450 × 800. Use touch/mouse or keyboard focus (Tab/arrows, Enter/Space). Help explains the loop, and Text + enlarges the interface.

Start with 360 coins and three practice objects. Stock shelves, set asking prices, and open a six-visitor customer wave. Or visit the yard, inspect two of four targets, tighten your ceiling, and bid or leave. Winning deducts the bid and transfers all six objects in one transaction. Appraise all before listing. Sales show the 8% fee before confirmation. Dealer liquidation pays 50% reference with no fee. Sorting's accessible skip pays 40 without collection rewards.

Every acknowledged economic action saves locally under `user://lantern_lot_prototype`. Two checksummed snapshots and a previous snapshot permit fallback after corruption. No accounts, background income, network gameplay, or analytics. If writing fails, gameplay pauses with **Retry save**. If all snapshots are incompatible or corrupt, originals are retained and the app blocks automatic reset. For manual recovery, close the app and back up the entire save folder before replacing a snapshot; removing the folder starts fresh. User-facing export/import and reset confirmation are later work.

## Verify

```powershell
& 'D:\Godot\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script tests/run.gd
```

The tests cover integer valuation and cost allocation; legal turns and permanent withdrawal; 100 deterministic auction scenarios; resumed full shop loops; duplicate/stale commands; inventory reserve; fee/counteroffer rules; disk replay, corruption fallback, and denied saves. These are automated development checks, not the design's required human playtests or physical Android acceptance.

For a UI capture, create `build/` and run the game with `-- --ui-smoke`; this runs an isolated full loop, writes seven previews including `build/shop-preview.png`, and exits. Smoke saves are isolated in `build/`; your normal save is untouched. `build/` is excluded from Git.

## Prototype scope

Implemented: the exact six-item economic example, four truthful inspection targets, three seeded public-information rivals, protected ceilings, win/loss receipts, appraisal, six shelves, pricing, one counteroffer, six paused customer encounters, collection notebook, dealer sales, stock racks, recovery, and transactional local saves. Scenes present snapshots and submit commands; domain modules own the economy.

This prototype deliberately repeats **one authored household-clearance fixture**, giving each visit a fresh listing ID. It does not claim to implement the randomized three-listing board or the 40-item MVP. Rivals currently use category priors because this fixture's doorway reveals categories without verified identities. UI text/content identifiers are provisional; production translation keys and full schema manifests remain to be authored.

Still planned: the randomized catalog and board, regular relationships and requests, exhibition progression, six decorations and placement, production sprites/audio, remapping/controller polish, full safe-area and 200% text tests, Android export, device save interruption tests, performance measurement, accessibility semantic bridge, and human playtests. The small diorama is original procedural placeholder art. It is not finished production art.

See [development status](docs/DEVELOPMENT.md) for milestones and verification notes. Engine/export upgrades require a deliberate migration. No store release is implied.
