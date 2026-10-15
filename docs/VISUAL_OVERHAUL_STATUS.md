# Lantern Lot visual overhaul status

Implementation and desktop verification: 15 October 2026. Godot reports `4.7.2.stable.official.ed1daf0bf`; GL Compatibility is retained.

## Scope and preservation

Work starts from the existing `f1de5cb` prototype in `medissl/lantern-lot`, on `codex/visual-overhaul`. The previous untracked art/scenes/presentation work was moved to ignored `build/rejected-previous-overhaul/`; it is not used by this implementation. The pasted brief is preserved as `docs/VISUAL_OVERHAUL.md`. No reference image was available in the attachment directory, so no direct inspection or reuse is claimed.

The original domain, auction, valuation, content registry, content JSON, economic save service, GameSession and 3,907-check suite are unchanged. Economic JSON keeps schema 1 / content `prototype-1` and the closed dictionaries. All UI financial actions go through `GameSession.command`; pending saves retain the acknowledged room and block further economic actions until Retry succeeds. No renderer/engine upgrade, transport fee, extra acquisition, timer, background sale, paid decoration, monetization or network dependency was introduced.

Normal economic saves remain at `user://lantern_lot_prototype`. Presentation layout, settings and UID-to-display assignments use separate checksummed files under `user://lantern_lot_presentation`. Visual format 2 migrates format 1 without touching business data. Corrupt visual data uses safe defaults and reports recovery; corrupt/incompatible economic data retains the existing fail-closed behavior. All test/capture/recording saves are isolated under `build/`.

## Implemented presentation

- Persistent portrait world, status HUD and bottom dock. The root retains room/actor/item nodes across commands; meaningful locations switch shop/yard/reveal scenes. Detail sheets scroll internally and restore focus.
- Original warm stone and timber art, six TileMapLayer floor variants with a shared TileSet, architecture overlays, an original application icon, nine recognizable goods and nine dedicated 64px inspections.
- Shopkeeper, Mei/Arif/Suri, auctioneer and six customer appearances. Directional idle/walk/interact/carry/bid/browse/handoff poses use stable foot pivots and original frame atlases. Goods reconcile by UID; art maps by definition ID.
- Six real display positions, three starter goods on the tray, an overflow stock drawer and committed stock-rack visuals. Stock changes move the correct good. Display assignments survive returning/relaunching and remove stale sold UIDs.
- Four truthful inspection targets, retained clue readings, exact bid totals/cash remaining/ceilings, public leader and ledger. Concealed packages retain neutral labels/art until legal appraisal.
- Won-storage view, free batch appraisal, short cosmetic carrying/cart/reveal/sale feedback. Presentation never dispatches an extra economic command and can settle immediately with reduced motion/Skip.
- Current customers browse real displayed goods. Only the current encounter can receive an offer. Confirmation displays gross, fee and net; committed acceptance clears the shelf and advances the visitor once.
- Separate discovered/owned notebook state. Price changes require Set price; dealer liquidation has explicit permanent-sale confirmation.
- Six free decorations plus relocation of all six existing display fixtures. The editor previews a native grid, hatches the protected aisle, marks rejected footprints with a cross/reason, offers row/column controls, 20-edit undo, Cancel and validated atomic Done/Retry. Counter, appraisal bench and entry remain fixed service fixtures.
- A bespoke Harbor ledger UI: paper, walnut, enamel teal and brass hardware; original nine-patch borders; dual-tone focus rings. Atkinson Hyperlegible Next Regular/Semibold and Silkscreen are bundled with exact OFL notices. Raster sources, manifests and provenance are included.
- 100/150/200% text, keyboard alternatives, transformed pointer input with pan/cancel suppression, local audio levels, motion reduction, and portrait safe-area handling. Desktop simulated insets are explicitly distinguished from real mobile verification.

## Review gates

| Gate | Desktop result | Remaining boundary |
|---|---|---|
|M0 re-audit|Existing project, renderer, baseline checks/captures and Git state inspected; rejected work archived|Original reference unavailable|
|M1 visual slice|Persistent shop/yard, player/starters/six displays, selection/stock/price and four inspection targets exercised with rendering|Physical touch-device review open|
|M2 current loop|Win, appraisal, return, stocked shop, six visitor decisions, sale and receipt exercised; exact accounting retained|OS-level interruption and human pacing need device testing|
|M3 customization/responsiveness|Decor/display relocation, separate persistence, corrupt fallback, failure/retry, focus and large-text desktop matrix verified|Actual notch/gesture bars and mobile semantic bridge open|
|M4 polish/regression|Original art/animation sources, 102-record asset gate, rendered checks/captures,20-second movie and desktop profile available|Android/iOS export/device/RSS/performance/accessibility/audio audition and human art/pacing sign-off remain unverified|

No required asset is intentionally left as a placeholder in the shipped manifest. This is a completed desktop implementation of the current prototype loop, not a claim of mobile/store readiness or name/trademark clearance.

## Verification and evidence

Reproduce with `tools/verify.ps1 -FullSizeMatrix -RecordMovie` (supply the Python executable with Pillow). Complete stage logs and exit statuses are in ignored `build/visual-overhaul-evidence/logs/` and `verification-summary.json`. The verifier rejects unexpected engine errors, parser/resource errors and warnings. It preserves specifically scoped negative save-test errors.

The original suite has 3,907 checks. Added presentation, rendered controller and responsive suites cover slot reconciliation/depth, layout/navigation/migration, real button bindings, keyboard/focus, price editing, inspection quota, duplicate sale suppression, failed save/retry and transformed pointer/pan/cancel behavior. Counts and timings are reported by the current logs rather than substituted for visual review. Synthetic button/pointer/key events verify the Godot path; they do not establish OS touch latency or mobile screen-reader behavior.

Full verifier exit status: 0. Final suites: domain 3,907 + presentation 127 + controller 96 + responsive 336 = **4,466 checks PASS**. Six package-opening/concealment regressions were added and the presentation suite rerun after the full capture pipeline; implementation did not change. The 102-record asset gate and strict source-pixel block check on 35 captured rooms also pass. All seven requested window sizes were captured at their actual dimensions; smoke explicitly requests the size after startup to avoid Windows work-area clamping. Logical GUI snapping is disabled because it would otherwise shift fractional UI coordinates after physical stretch; the world texture rectangle is snapped in physical pixels.

Final ordinary desktop sample: populated shop 60.04fps (p95 frame 17.04ms), auction 60.02fps (p95 16.99ms), approximately 71.1MB static allocations and 82.9MB peak. This is a short 120-frame per-room sample on the machine listed in the profile, not a prolonged benchmark or total process memory claim.

Captured window matrix: 320×568,360×640,393×852,412×915,720×1280,1080×1920, and short360×480. The responsive suite additionally exercises 100/150/200% at the first three sizes, including a six-digit 100000 price, scroll-to-action and exact sale totals.

Each size directory contains named PNGs/JSON sidecars for sparse/stocked shop, yard/clues, bidding, won storage, appraisal, transport, customers, confirmation/sold state, notebook, layout validation, save failure, large text, simulated safe area and front/behind depth poses. The responsive subfolder includes `16-short-phone`, `21-price-100000-200` and `22-sale-200` evidence. Depth stills use controlled actor poses; continuous movement is separately demonstrated in the recording.

`lantern-lot-demo.avi` is a 20-second, 30fps engine-rendered demonstration. MovieMaker's actual output dimensions are recorded in the movie log; fixed-fps capture is not a performance benchmark. `desktop-profile.json` samples 120 ordinary rendered frames in a populated shop and auction on the local Intel i5-1135G7/Iris Xe Windows machine. Its static allocation figures are not process RSS. No Android 60fps/200MB target is asserted from this short desktop sample.

The final AVI includes 604 frames (20.13s) with four shutdown frames; the compact `lantern-lot-demo.mp4` preview is trimmed to exactly 20s/600 frames at 450×800. It shows walking, stock movement, public bidding, neutral package opening, appraisal, visitor browsing, sale confirmation and committed removal. Selected actual 393×852 PNGs are also committed under `docs/screenshots/` for repository review.

Initial unapproved editor import attempts reported a safe-save permission error; later approved imports completed with safe-save retained. Integration testing also caught and repaired an interim room static-call parser error, covered-goods depth occlusion, stale item tween restarts, first-frame HUD sizing, modal reflow overflow, large-text close controls and canceled-touch selection. Historical attempt logs are not treated as passing acceptance. Final stage logs are authoritative.

The Godot integration's debug run retains baseline integer-division warnings in valuation/session where deliberate integer arithmetic implements existing rounding. Those source files were not changed or globally silenced. New presentation warnings were corrected.

## Assets and licenses

`assets/visual_manifest.json` registers identity, atlas regions/gutters, dimensions/pivots, animation frames/rates, editable source, creator/origin, license, attribution and review scope. `art/build_pixel_art.py` and `art/build_inspect_ui.py` reproduce original rasters; `art/validate_assets.py` gates catalog coverage and resource integrity. Review sheets are in `art/review/`. `THIRD_PARTY_NOTICES.md` and exact font OFL files distinguish original CC0-dedicated work from unmodified upstream fonts. No reference-image pixels, commercial game audio, real brands, remote embeds or analytics are shipped.

PCM/clipping and original synthesis checks pass. Actual speaker/headphone audition and mobile audio behavior remain unverified. No nonvisual-playability or WCAG certification is claimed; token contrast checks and desktop focus tests are narrower evidence.

## Acceptance matrix boundary

|ID|Evidence and result|
|---|---|
|V01|Sparse rendered shop: player, three starter goods, persistent HUD; no page scroll.|
|V02|Controller bindings stock/unstock the exact UID without coins changing; Set price alone commits the edited amount.|
|V03|Targets0/3, repeat reading and disabled third inspection tested; covered identities remain neutral.|
|V04|Existing auction edge suite plus exact bid/ceiling controls and public leader/log captures.|
|V05|Original durable transfer/resume tests retained; win debits/transfers once. Cosmetic motion can settle; real mobile interruption open.|
|V06|Batch free appraisal identifies owned goods and nonpractice discoveries; real inspection crop captured.|
|V07|Cart/carry/open are view functions without domain commands; return uses the original single command.|
|V08|Rapid duplicate sale activation commits once and does not offer to the next visitor; receipt/stock/cash checked.|
|V09|Original paused visitor decisions retained; no timer or budget regeneration added.|
|V10|Complete six-visitor queue and receipt/return bindings exercised.|
|V11|Notebook reads persistent discoveries separately from current owned copies; original discovery retention rules unchanged.|
|V12|Economic save failure retains world/state, disables actions, and Retry commits the one candidate; negative engine error remains visible.|
|V13|Original corrupt/newer/incompatible economic-save tests unchanged and passing; no automatic reset introduced.|
|V14|Decor and all six display fixtures validate bounds/overlap/aisle/reachable stands; invalid cross/reason captured.|
|V15|Visual persistence, legacy migration, corrupt fallback, undo/cancel and failed-save draft/retry tested independently of economy.|
|V16|Transformed synthetic taps, pan-release over goods, and canceled touch tested at three sizes; physical OS touch latency open.|
|V17|Actual keyboard activation, Escape/focus restoration and labeled equivalents tested. Complete end-to-end OS keyboard/controller and mobile assistive-technology playtests remain open.|
|V18|Three sizes × three text scales: fields/buttons/scroll bounds,100000 digits and exact sale totals checked. Short-window captures add visual evidence.|
|V19|Inset simulation and suspend/resume code exist; actual notch, gesture bars and mobile suspension remain untested.|
|V20|Shared foot sorting, clipped shelf cutaway, moving raster pivots and controlled depth stills reviewed; physical pixel block gate checks captured world magnification.|
|V21|Reduced motion settles/stops poses/effects; audio off loses no decision text. Token contrast and dual-outline focus checked; full grayscale/device accessibility review open.|
|V22|Populated desktop shop/auction profile available; Android battery/RSS/frame pacing and prolonged device/offline flight-mode run remain untested.|
|V23|102-record manifest gate: all nine goods/inspect crops,11 directional actors, frame/gutter dimensions, local fonts/notices and unclipped PCM. No unavailable reference art included.|
