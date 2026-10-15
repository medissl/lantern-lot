# Lantern Lot: visual game overhaul implementation brief

## Paste this prompt into the Codex chat that implements the game

```text
Work in the EXISTING Lantern Lot Godot project at:
C:\Users\media\OneDrive\Documents\lantern-lot

Read this entire attached README before implementing. You are the implementation
agent. This document was prepared by a separate UI/UX and software-flow designer.
Implement a visual overhaul of the existing game, not a replacement game or a
new conceptual GDD. Preserve the economy, inventory identities, auction rules,
customer decision rules, transaction durability, and compatible existing saves.
Keep the name Lantern Lot. Retain Godot 4.7.2 and GL Compatibility unless a
demonstrated blocker requires a narrowly explained change.

First inspect the actual project, applicable AGENTS.md, settings, scenes,
scripts, content, tests, tools, and current rendered screens. Revalidate the
repository audit in this README because the project may have changed. Inspect
the attached art reference directly if available; its /mnt/data/images.jpg path
was not accessible to the designer on Windows. Never claim to have seen a file
that you cannot open. Treat the image as visual reference, not reusable assets.

Build persistent, interactive portrait pixel-art rooms: storage/auction yard,
won-storage reveal, appraisal bench, transport feedback, and customizable shop
with visible visitors. The room is the main screen. Bids, inspected objects,
owned stock, shelf changes, customer choices, and sales must visibly affect the
room. Use original recognizable sprites, purposeful pixel clusters, warm stone,
dark timber, bright goods, small people, clear paths, and a restrained bottom
HUD. Do not replace environments with text-heavy cards, emoji, generic icons,
flat rectangles, or another long scrolling page. UI panels may hold necessary
prices and explanations; they must not substitute for a playable room.

Use specialist subagents if available for Godot integration, pixel art and
animation, mobile UX, business-flow preservation, and QA/accessibility. Give
each bounded work with clear file ownership. Integrate their work yourself.

Start with one finished shop interaction and one finished auction inspection
as a runnable visual slice, then complete the full current loop and polish.
Follow the milestones and acceptance matrix below. Do not stop at plans,
scaffolding, disconnected mockups, an art generator script, or a successful
headless launch. Run the actual game with rendering, inspect screenshots and
animations, exercise interactions, and repair problems. Keep the existing
3,907-check baseline passing unless the baseline legitimately changed; report
actual counts and unexpected errors. Headless tests do not prove visual quality.

Economic commands execute only through GameSession.command(kind, args).
Success feedback follows durable commit. Animations, walking, carrying,
unpacking, and transport are presentation, never additional charges, ownership
transfers, RNG rolls, or replayed commands. All six won goods already enter
inventory atomically; appraise currently verifies all owned goods together;
customers remain six paused decisions. Never invent timed sales or hidden-value
clues. Keep the save-failure Retry save barrier.

Produce reusable scenes, original raster assets and editable sources, a visual
asset manifest, licenses, a persistent responsive HUD, complete command
bindings, decoration presentation persistence, useful test evidence, and a
brief handoff. Mark any rough art or device tests still outstanding. Do not
declare the overhaul finished while required art is placeholder or any core
screen still looks like the old text prototype. No publishing, paid purchases,
new monetization, analytics, or unrelated full-GDD expansion is authorized by
this prompt. Continue autonomously within this overhaul until its gates pass
or report the precise blocker and remaining work honestly.
```

## 1. Authority, scope, and evidence

This is an implementation-directed **visual and interaction design** for an existing game. It is not executable code and does not itself authorize the designer to change the game. Send the file to the implementing Codex chat with the reference image. Keep the project's existing operational README; save this brief there as `docs/VISUAL_OVERHAUL.md` rather than overwriting run/recovery instructions.

Within the implementing chat, this brief supersedes `DESIGN.md` only where its presentation would preserve the small postcard and text-heavy interface. Existing implemented business rules are authoritative for this overhaul. The much larger 40-item GDD, progression expansion, relationships, randomized board, and future restoration features are separate work. Resolve conflicts by preserving current functional rules and applying this brief's visual language. Record any necessary exception with its consequence.

### Real repository audit, 14 October 2026

The designer inspected these real files read-only. Proposed additions elsewhere in this document are explicitly new, not existing files.

| Existing file | Observed responsibility | Overhaul instruction |
|---|---|---|
| `project.godot` | Lantern Lot; main scene `res://scenes/main.tscn`; 360×640 design viewport; 450×800 desktop override; `canvas_items`, `expand`; GL Compatibility | Preserve renderer/version. Add explicit portrait orientation, world filtering, safe-area behavior and responsive composition. |
| `scenes/main.tscn` | Single full-window `Control`, script `scripts/ui/main.gd` | Keep as entry point; build a persistent visual hierarchy. |
| `scripts/ui/main.gd` | Runtime-created labels/buttons/cards; `render()` frees all children; `ScrollContainer` + `VBoxContainer`; `world()` makes a 180×108 diorama; customer screen has no room | Replace default long page with world + HUD + context sheets. Stop recreating the whole scene per command. Preserve every command and error path. |
| `scripts/ui/world.gd` | Original procedural `_draw()` rectangle/line/circle placeholders; no moving actors or real item-state binding | Replace with authored room scenes and raster sprites. Do not call the current art final pixel art. |
| `scripts/services/game_session.gd` | Owns `state`, `pending`, `error`; `boot()`, `command(kind,args)`, `retry()`; save before acknowledged success | Keep as business boundary. Add an adapter around it, not a parallel economy. |
| `scripts/domain/session.gd` | Command reducer, validation, ownership, screen state, customer wave, transfer and sale | Preserve; derive presentation from committed state. Its closed schema rejects arbitrary extra keys. |
| `scripts/domain/auction.gd` | Seeded public-information rivals; bounded logical rounds; NPC actions batch synchronously after player command | Animate committed log entries without introducing a bidding timer. |
| `scripts/domain/valuation.gd` | Integer reference/fee rounding and proportional winning-cost allocation | Preserve; UI reads these values instead of duplicating formulas. |
| `scripts/services/content_registry.gd` | JSON definitions, instance creation, public slots; asserts six goods/three starters | Keep IDs/counts. Map visuals separately by `definition_id`. |
| `scripts/services/save_service.gd` | Schema 1 / `prototype-1`; checksummed A/B snapshots + previous; incompatible-save protection | Keep save compatibility, failure barrier and retention. Do not embed `.tres` objects in economic JSON. |
| `content/prototype.json` | Six lot definitions, three starter definitions, three rivals, six customers and economy constants | Finish art for these actual records before expanding content. |
| `tests/run.gd` | Domain/service/auction/save checks | Retain and add meaningful presentation integration tests. |
| `docs/DEVELOPMENT.md`, `DESIGN.md` | Prototype status and earlier large GDD | Update implementation status accurately; avoid confusing future design with completed mechanics. |

No production sprite, font or audio library was found among the project content inspected; the default `icon.svg` is still present. The original project was not edited. Git status could not be obtained under this session's access restrictions, so no claim is made about its clean/dirty status.

### Executed baseline verification

To avoid changing the project, its configuration, scenes, scripts, content and tests were copied into this deliverable chat's `work/baseline-audit`. Godot reported `4.7.2.stable.official.ed1daf0bf`. The copied project passed `tests/run.gd`: **3,907 checks; PASS**. The deliberate invalid-directory save test emitted its expected error; this is not a blanket exemption for other errors.

The real renderer executed the existing `--ui-smoke` harness and produced all seven baseline captures: shop, stock, auction, reveal, customer, receipt and large text. The designer directly viewed shop, auction and customer captures. The shop/auction are dominated by labels and small static art; the customer view is entirely UI text/cards. This is a presentation failure, not evidence that the economy is broken. Device, performance and screen-reader acceptance have not been established.

An initial editor import attempt reported restricted editor-data writes. The later domain/render runs used a scratch `APPDATA` directory within the audit workspace. Do not describe the initial import as an error-free editor pass or disable safe-save protections to hide permission errors.

### Art reference availability and interpretation

The crucial image was referenced as `/mnt/data/images.jpg`, but that file was not accessible on this Windows host. The earlier conversation could not be retrieved through the connected reader, either. **The following reference interpretation is based on the user's supplied description, not a direct pixel-level inspection.** Exact palette samples, camera angle, sprite dimensions, outlines and font identity in the image are unverified. The implementing chat must open the actual attachment and refine these proposed specs where appropriate.

The description contains two side-by-side portrait museum/interior scenes: one sparse, one packed with colorful exhibitions, large skeleton/creature displays, warm tan/brown stone floor, dark timber, small visitors and a bottom HUD. Translate that into these practical goals:

| Reference characteristic | Original Lantern Lot interpretation | Visible proof |
|---|---|---|
| Sparse room versus packed room | Same recognizable shop grows from three practice goods to six stocked display positions plus arranged decor | Paired sparse/furnished screenshots with consistent camera and actual state bindings |
| Large skeleton/creature centerpiece | Strong sculptural focal shape from an original shop fixture: timber feature cabinet and curated display table; optional decorative ship-model later | One clear anchor, smaller shelf goods remain readable; no copied skeleton model |
| Warm tan stone and dark timber | Low-noise stone floor, substantial timber shelving, warm lamps and clear darker contact shadows | Floor/wood occupy most room area; merchandise separates from them |
| Bright exhibit focal points | Enamel teal kettle, golden brass, red upholstery and colorful framed artwork; palette accents belong to objects | Distinct silhouettes/materials without a screen-wide rarity glow |
| Tiny visitors make scale/activity readable | Small animated bidders and customers stand, browse and carry bags at real room positions | Visitors visible in auction and sale screens, with depth and movement |
| Bottom HUD | Compact reachable command dock; no scrolling to reach a bid or sale | Bid/pass, shelf action and sale confirmation remain visible |

Study spatial hierarchy, occupancy, material treatment and scale relationships. Do not trace the reference, extract sprites, copy its layout/UI, identify its source from guesswork, or ship the screenshot. Its copyright and redistribution license are unknown.

## 2. Intended experience and non-negotiable visual gates

**The player should see a small secondhand business operating in a room before reading a paragraph.** On launch, a warm portrait shop, recognizable goods, a shopkeeper and a clear entrance must fill the main play area. A tap selects a real item; a visible action at the bottom changes that item or opens a short detail sheet. An auction is people bidding over a visible storage lot. A sale is a customer discussing a displayed object and leaving with it.

Normal screen: 65–75% of available portrait content is the world, roughly 10% top status, the remainder lower navigation/actions. Sheets temporarily use more space for detailed pricing, index, settings, errors or 200% text. Do not enforce a decorative world-size quota at the expense of readable confirmation controls.

Short-session target: resume the current saved decision immediately, then complete one yard visit, optional batch appraisal, shelf stocking and at least one customer sale in roughly 3–5 minutes without changing balance. A single micro-session may be just pricing/stocking a good or making one bid. Walking and reactions cannot add mandatory chores; normal sheets open within about 150 ms after assets are ready, and optional transport settles within 1–2 seconds or skips immediately. Record actual loop timing rather than promising this target has been achieved. Pausing is safe at every acknowledged transaction; resume the same encounter instead of sending the player through a title/tutorial sequence again.

Reject these outcomes even if code compiles:

- The current postcard remains with nicer cards underneath.
- A dungeon-like choice list with item names is called a storage room.
- A visitor is only a portrait badge or text name.
- A shelf is a generic colored rectangle unrelated to owned stock.
- A box opens but the actual item is never drawn.
- Every screen uses the same unlabeled room texture despite different states.
- The agent provides mockups/scaffolding but never runs the integrated game.
- Missing sprites silently become emoji, unrelated icons, or blank blocks.
- Purple-to-blue gradients, glass panels, low-contrast dark cards, generic icon grids, floating badges, continuous glow/noise and decorative website effects are used as polish.

Flat shapes are allowed for UI backgrounds, hitboxes in debug mode, and deliberate pixel clusters inside authored sprites. The prohibition concerns using crude primitives as substitutes for environmental graphics. Text remains essential for numbers, decisions and accessible alternatives; it simply stops being the entire game.

## 3. Preserve these business mechanics

| Rule observed in current code | Presentation requirement |
|---|---|
| Start: 360 coins, 18 stock slots, three verified practice goods | Starter objects sit on a stock tray, not sale shelves until stocked. HUD shows 3/18 stock and 0/6 displayed. |
| Six sale shelf slots; rack upgrades add stock capacity only | Render six functional display sockets. Decoration must not change income or shelf count. Rack visuals reflect committed `rack_count`. |
| Yard entry needs 80 coins and six free stock slots; there is no entry fee | Disabled yard action explains shortage. Never subtract 80 for walking into the yard. |
| One repeating authored six-item fixture; fixed opening 40; raises 10/20/40; reserve 40; cap 250 | No fake three-listing board, rarity jackpot, value-dependent opening or generated new catalog in this pass. Clearly label prototype fixture in help, not permanent full-screen copy. |
| Two of four close inspections; repeat reading costs no extra inspection | Four scene hotspots show quota/use state. Reopening known clue reuses text. |
| Ceiling only tightens; bid is binding if it wins; pass is permanent | Exact total and cash remaining on bid control. No undo-bid UI or misleading refundable confirmation. |
| Rivals use public observations, not concealed identities | Sprites, audio, glow, semantic labels and hints must not reveal secret values or rival private budgets. |
| On win, one debit and all six objects transfer atomically | Carry/open/load animations describe the completed transfer; they never collect objects again. |
| `appraise` verifies all owned objects at once, free | Button reads `Appraise all · free`; selected-item close-up is visual context, not per-item domain appraisal. |
| Six paused customers, one offered object and one counteroffer each | Several ambient bodies may be shown, but only current visitor is an actionable encounter. No autonomous sales/timer. |
| Sale confirmation exposes gross, rounded 8% fee and net | Bottom confirmation shows all three numbers. Shelf clears and register chimes only after durable `accept`. |
| Dealer pays rounded 50% reference, no handling fee | Dedicated explicit dealer action/confirmation, not a normal retail sale with hidden fees. |
| Sorting commission pays 40; discoveries exclude practice items | Preserve accessible recovery action. No compulsory drag mini-game or new collection reward. |
| Every acknowledged economic change is saved; errors leave pending state | Freeze economic actions on pending save; display `Retry save`; no false success animation. |
| No background income or network economy | Returning after suspension reconstructs state without accumulating sales. |

Do not add luck accessories, mutation value multipliers, net-worth gates, compulsory time pressure, energy systems, transport fees, restoration, purchase discard, or more expensive regions as part of a graphics task. Visual shop improvement supplies a satisfying sense of care without claiming new progression systems exist.

## 4. Art direction, scale and color tokens

### Projection and room geometry

Use 2D **orthogonal top-down movement with three-quarter furniture drawings**. Show tops and front faces, short back walls and shallow side walls. Do not introduce a true isometric diamond grid or rotate the camera. Pixel art is authored at its native resolution, with upper-left light, darker lower-right contact shadows and intentional material clusters.

| Element | Required native metric |
|---|---|
| Floor/navigation cell | 16×16 art pixels |
| Decoration placement cell | 32×32 art pixels = 2×2 floor cells; separate from navigation |
| Shop furnishing footprint | 6×8 placement cells, matching earlier GDD intent; floor 192×256 before walls |
| Shop room including walls | Initial 208×288 art pixels; slightly wider than default viewport and pannable |
| Nominal world view | 180×224 art pixels in a 360×448 UI-unit world region; dynamically adjusted for integer physical scaling |
| Character cel | 24×32; body about 12×22; foot pivot `(12,28)` |
| Small object | 16×16 cel with 10–14-pixel distinguishing silhouette |
| Taller object | 16×24 or 24×24; atlas cell includes transparent padding |
| Furniture | Typical 32×32 / 48×32 / 64×48; art overhang differs from collision footprint |
| VFX | 16×16 or 32×32; no smooth gradient halos |

A 180×320 portrait artboard is useful for compositional studies, but is **not** the actual runtime world viewport height under the HUD. Do not squeeze a 320-high scene into a 224-high rectangle. Camera framing/panning should show the room at the chosen art scale. Keep a two-floor-cell-wide central walk lane and 2×2 floor-cell arrival zone. Maintain reachable stand positions at bench, checkout and display sockets.

Floors use about six subtle variants plus joins/edges/corners, arranged into coherent slabs rather than a busy chessboard. Timber has consistent grain clusters, top/front/shadow planes and joinery. Sprites use limited, material-aware colors and selective outlines. No anti-aliased edges, pillow shading, blurred generated textures, random noise overlay or subpixel rotation.

### Cohesive palette

These are proposed tokens, not colors sampled from the inaccessible image. About 70–80% of the room uses stone, timber and paper neutrals; accent color occupies recognizable goods, visitors and selected controls. Ordinary props typically use 4–8 colors, no more than 16 without a specific need.

| Token | Hex | Use |
|---|---|---|
| Ink | `#282522` | Outlines and primary text on paper |
| Timber shadow | `#3F3029` | Beam underside, shelving recess |
| Timber | `#6C4938` | Doors, counter front, cabinets |
| Timber light | `#9B7050` | Top planes, edge wear |
| Stone shadow | `#A47E59` | Floor joins, corner wear |
| Stone | `#C7A779` | Main warm floor |
| Stone light | `#E1C79C` | Lit floor planes |
| Paper | `#F7E9CC` | Opaque HUD and detail sheets |
| Deep teal | `#245B59` | Primary action background, enamel shadow |
| Teal light | `#63A9A0` | Kettle/enamel accents |
| Brick | `#B94F3B` | Upholstery, small warning accents |
| Brass | `#E6AD42` | Lamp/brass, selected detail |
| Leaf | `#597452` | Plants, fabric accent |
| Ivory | `#FFF1D6` | Ceramic/light text on deep teal |
| Steel | `#7C8B90` | Metal appliances |
| Violet | `#866E95` | Optional textile accent only, no rarity interface |

Approved starting text pairs: Ink on Paper; Ivory on Deep teal. Warning copy uses Ink on Paper plus a Brick symbol and explicit wording rather than assuming Brick body text passes contrast. Brass/Stone/Teal light are art colors, not default body-text colors. Measure the actual final pairs, disabled states and focus indicators; alpha overlays change results. Record computed contrast in QA. Target at least 4.5:1 normal text, 3:1 large text and essential non-text boundaries. This is a WCAG-inspired target, not a claim that a Godot app automatically conforms to web WCAG.

Calculated from these opaque sRGB tokens using relative luminance: Ink/Paper **12.69:1**, Ivory/Deep teal **6.92:1**. Brick/Paper is **4.12:1**, below the normal-text target, so do not use it for small warning text. These calculations verify token pairs, not final text size, overlay composition, focus contrast or device rendering.

### Typography

Use **Atkinson Hyperlegible Next Regular/Semibold** for amounts, names, buttons and explanatory UI. Use **Silkscreen Regular** sparingly for the shop sign or short headings at tested sizes. Render interface text at UI resolution, not inside the low-resolution world texture. Do not use tiny pixel fonts for financial decisions or bake text into item sprites.

At the 360-wide UI design size: body/buttons 16–18, amounts 20–24, screen heading 22, secondary copy minimum 14. Use sentence case, line spacing around 1.25–1.4 where applicable, and no all-caps paragraphs. Text options 100%, 150%, 200%; containers reflow and confirmation sheets scroll internally. Don't shrink essential labels to preserve a pretty layout. Test `1/I/l`, `0/O`, integer amounts through 100000, punctuation and localizations. Bind a verified fallback for unsupported scripts.

The two fonts' repositories contain OFL files: [Atkinson Hyperlegible Next license](https://github.com/googlefonts/atkinson-hyperlegible-next/blob/main/OFL.txt), [Silkscreen license](https://github.com/googlefonts/silkscreen/blob/main/OFL.txt). Inspect the exact downloaded release, bundle its license/copyright notices, and respect reserved font-name terms if modifying. A citation is not a bundled license. Font choice does not guarantee complete glyph coverage or accessibility.

## 5. Mobile composition and interaction grammar

### Layout units and safe areas

Retain root design size 360×640, `canvas_items` stretch and `expand`. At default size outside safe-area insets: top HUD 56, world 448, bottom dock 136 UI units. Use 4/8/12/16/24 spacing steps, 12–16 edge margins. Design for portrait; set mobile orientation explicitly. Keep Compatibility rendering.

Test 320×568, 360×640, 393×852, 412×915, 720×1280 and 1080×1920 output sizes, plus an unusual short portrait window. Taller phones gain world visibility instead of enlarged blank cards. At short heights/large text, fold secondary navigation and allow sheets to scroll while the active confirmation remains reachable. Screen rotation, if disallowed, must remain portrait without losing state.

Query the installed Godot version's `DisplayServer.get_display_safe_area()` and transform the physical/window rectangle into local UI coordinates using the actual viewport transforms. Apply insets to HUD, bottom dock and sheets; do not simply paste physical pixel values into logical margins. Recompute on resize/orientation/resume. Test actual notches and gesture bars; a desktop zero-inset result proves little. Background art may extend behind safe areas, essential targets may not.

World scaling: nearest sampling, no mipmaps, integer **physical** magnification. A logical 2× image under fractional root stretching is not pixel-perfect at 393 pixels wide. Calculate the largest supported integer scale for the actual world output rectangle, derive a suitable viewport extent and center/reframe. Prefer a small neutral margin or a changed field of view over uneven source pixels. Keep art pixels square. Record how camera clipping and touch mapping behave at each size. Do not scale high-resolution fonts with this world calculation.

### Input rules

1. Tap an object to select it. Show corner brackets/footprint and its short name. A tap alone does not spend coins, sell, bid or consume an inspection.
2. A labeled action in the bottom dock performs the decision: `Inspect kettle`, `Stock shelf`, `Bid 60`, `Confirm sale · receive 14`.
3. Empty-floor tap can move the shopkeeper to a reachable position. Walking is optional presentation; offer a direct-action alternative so routefinding never blocks economy or accessibility.
4. Drag empty world space to pan. Begin drag after about 10 UI units; release after a pan does not also select or activate an object. Use one captured pointer, handle cancellation and app suspension.
5. In decoration mode only, drag furniture as a shortcut. Tap-pick/tap-place, row/column fields and directional controls perform the same placement. No precision dragging requirement.
6. Start with fixed world magnification. If close-up zoom is added, use discrete integer zoom levels and `+`/`−` controls as alternatives to pinch. No continuous blurry zoom.
7. GUI controls consume their events before the world. Opening/closing a sheet must not click through. Bid/pass targets must not become unrelated result actions under a held finger/key; require release before accepting the new action.
8. Keyboard: Tab/Shift-Tab focus, arrows/D-pad spatial/list navigation, Enter/Space activate, Escape back/cancel. Touch has an equivalent to each action. Preserve a visible focus ring and restore focus to the initiating object/control after closing a sheet.

Minimum target: **48×48 UI units**, with 8 units separation where feasible. A 12-pixel kettle has an enlarged screen-space hit region, not an enlarged/blurred sprite. Overlapping hit regions must select through a short object chooser or prioritize the nearest visible item. Drawer rows and numeric-entry controls meet the same target minimum. Mouse hover supplements touch; it must never be required.

Use one explicit screen-to-world mapping pipeline. A `TextureRect` displaying a `SubViewport` does not forward input automatically. Map pointer from window to the displayed texture rectangle, to viewport pixels, then through camera canvas transform to world coordinates, excluding margins. Alternatively use `SubViewportContainer` and test its forwarding/stretch carefully. Do not mix forwarding strategies and deliver duplicate taps.

## 6. Screen wireframes and precise flows

Wireframes indicate hierarchy, not permission to ship ASCII/text boxes as the game art. `[world]` means actual authored tiles, sprites, actors and depth. Default navigation contains short text labels; original small icons are optional supplements.

### A. Shop home and shelf interaction

```text
┌──────────────────────────────────┐
│ 360 coins       Stock 3/18   Menu │ 56
├──────────────────────────────────┤
│ short timber back wall / window │
│ cabinets     appraisal bench    │
│     REAL shelf goods            │
│        clear stone aisle        │
│ player              stock tray  │ world
│ checkout      entry / street    │
│ [selected item brackets]        │
├──────────────────────────────────┤
│ Measuring cup • identified      │
│ [Stock shelf]    [Inspect / price]│
│ [Shop] [Yard] [Notebook] [Layout] │ 136
└──────────────────────────────────┘
```

First launch shows the practice cup, steel square and folio on a stock tray; empty display furniture is intentional. Map six `shelf=true` objects to six named physical sockets. Deterministically assign by stable `uid`/saved presentation mapping so refresh/restart does not shuffle everything. Stocking puts the selected item's real sprite on a socket; unstock returns it to the stock tray. More stock than visible tray positions uses a labeled stock drawer with true thumbnails, not disappearing inventory.

Tap the counter for `Open shop`; tap the bench for `Appraise all · free`; tap the yard door or Yard dock control for `visit_lot`. Shop closed/open is a clear sign. Menu holds Help, Settings, Receipts and save health; remove the permanent marketing title/tagline and huge Help/Text+ row from play screens.

Price sheet: item sprite/close-up, condition, reference, allocated cost, current ask, numeric field and step controls; `Set price` sends the existing `price` command. Confirm field commits only on explicit action. Show `Stock shelf`/`Unstock` and `Sell to dealer · N net` where legal. Dealer sale has a confirmation because it permanently removes stock; preserve fee-free rule. The inventory drawer is a supporting tool, not home screen.

### B. Storage inspection and auction

```text
┌──────────────────────────────────┐
│ Cash 360      Clues 0/2      Menu │
├──────────────────────────────────┤
│   corrugated shutter / bay      │
│ kettle   stool   fan            │
│ crate    wrapped box flat parcel│
│      threshold / yard           │
│ Mei       Arif       Suri       │
│       auctioneer   player       │
├──────────────────────────────────┤
│ Selected: covered tool crate    │
│ [Inspect packing label] [Clues] │
│ Opening 40  [Ceiling 250]       │
│ [Bid 40]      [Leave freely]    │
└──────────────────────────────────┘
```

Three exposed goods show truthful silhouette/category cues; three covered packages stay concealed. Four inspection targets correspond exactly to indices 0–3: kettle maker mark, stool condition, fan material, covered crate packing label. Hotspot numbering is available in an optional overlay and equivalent list. Opening a clue sheet costs nothing; pressing `Inspect` sends the command. Used targets gain a small check and `Read clue`; quota remains 2/2 after rereading.

After bidding changes the domain screen to `auction`, `Read clue` reads the already-recorded notebook locally; it must not send `inspect`, which the reducer allows only during `inspect`. Do not offer any new close inspection once bidding starts.

Ceiling sheet shows current limit, reserve, numeric adjustment and `Tighten ceiling`. Explain it cannot increase for this lot. No hidden value estimate centered on secret truth. Inspection text remains readable in a short notebook sheet, not several paragraphs occupying the room.

Auction mode uses the same lot/people/camera. Show current bid and leader in a compact strip, last one or two log entries with expandable history, and the actual player's remaining ceiling. Bottom dock offers `Bid TOTAL (+10)`, `Bid TOTAL (+20)`, `Bid TOTAL (+40)` in 48-high rows or a two-step amount selector if width/large text demands it. Each indicates coins remaining if won. Do not squeeze three long labels into unreadable tiny columns. Pass is distinct and fixed-position. Above-ceiling options are disabled with a readable reason.

Animate new public log entries: bidder paddle raises, named amount appears, another bidder lowers paddle on permanent pass. Because domain NPC rounds resolve synchronously, queue an ordered **presentation replay** of log differences, not timer-driven domain commands. Provide `Skip reactions` or reduced-motion immediate final state. A queue lock ends even if an actor disappears. A result sheet shows winner/amount without changing the economy again.

### C. Won storage, unpacking and transport

```text
┌──────────────────────────────────┐
│ Won for N     All 6 in stock     │
├──────────────────────────────────┤
│ same bay, shutter visibly raised│
│ exposed/covered goods in place  │
│ player beside selected package │
│ open lids / wrapping on ground │
│ cart parked outside threshold  │
├──────────────────────────────────┤
│ [View package] [Appraise all free]│
│ [Return to shop]   [Skip motion]│
└──────────────────────────────────┘
```

Winning has **already** charged and transferred six objects. Reveal/open/carry are local presentation states; don't create `collect`, `load` or `transport` economic commands. Unknown covered goods remain wrapped until appraisal exposes identity. An open package can show a neutral covered interior before verification. Exposed goods retain truthful known silhouettes. `Appraise all · free` commits verification for all owned inventory, then reveals true goods and updates discoveries.

Optional tapping through each revealed item gives scale/material/condition appreciation. It cannot be required to receive items or proceed. `Return to shop` dispatches exactly once; a brief cart-loading/carrying sequence may follow or be skipped. Label `All 6 already transferred · no transport fee`, not `Load to collect`. Returning/reloading before that animation finishes lands in a valid state with the same items. No driving mini-game, travel timer, cargo fee, repeated acquisition, discarded goods or new capacity rules.

### D. Appraisal and collection notebook

```text
┌──────────────────────────────────┐
│ Appraisal / Notebook       Close │
├──────────────────────────────────┤
│ room bench and lamp visible     │
│ selected recognizable item      │
├──────────────────────────────────┤
│ [large pixel close-up] Name      │
│ Good • reference 30 • cost N     │
│ maker clue / known material     │
│ [Appraise all free] or [Set price]│
└──────────────────────────────────┘
```

Item inspection is a view over real inventory. Unverified goods do not show secret name/reference in UI, tooltips, accessibility strings or thumbnails. Verified identity supplies consistent world sprite, carried sprite, thumbnail and close-up. Use fictional maker marks matching authored clue text. Condition is visually indicated by purposeful scuffs plus a label; visual wear never secretly changes condition.

Notebook has all six prototype collectible slots; discovered entries show art/name and remembered clue; unknown entries use a neutral covered-outline treatment. Practice objects appear in inventory but don't increment six-object collection progress. Selling keeps discovery knowledge; show `Owned` only for present copies, independently from `Discovered`. Filters and scroll are permitted inside the notebook. Do not add luck, color rarity tiers, exclusive multipliers or invented percentage completion across a nonexistent catalog.

### E. Customers and sale confirmation

```text
┌──────────────────────────────────┐
│ Cash 190       Visitor 1/6       │
├──────────────────────────────────┤
│ shop stays visible              │
│ customer browsing real shelf    │
│ ambient people wait near entry  │
│ selected object / shopkeeper    │
│ checkout counter                │
├──────────────────────────────────┤
│ Lina • homewares • modest budget│
│ [Offer selected cup · ask 15]    │
│ [Skip visitor]                  │
└──────────────────────────────────┘
```

`customers` creates the existing six-visitor wave. The current visitor enters and pauses near a matching stocked display or neutral browsing position. A short preference/budget-band line is allowed. Select a stocked item and use `Offer ITEM · ask N`; a small chooser handles six displayed items at large text sizes. A pending offer sheet shows `Gross 15 − fee 1 = net 14` and `Confirm sale · receive 14`. Keep the room/visitor visible behind or above it.

Only successful `accept` clears shelf, animates bag handoff/register, updates cash, and moves to next committed visitor. `skip` moves the wave without fee/shame text. One offer/counteroffer per encounter is enforced; don't offer a second object after considered state. Waiting does not change budgets or outcomes. Ambient customers never buy on their own or imply passive income. At visitor 6 completion, show a short session receipt above the quiet shop with `Return to shop`, not another empty text-only screen.

### F. Layout mode and visible customization

```text
┌──────────────────────────────────┐
│ Layout       [Cancel]     [Done] │
├──────────────────────────────────┤
│ actual shop + optional cell grid│
│ selected furniture ghost        │
│ clear protected entry/lane      │
│ valid tick OR crossed footprint │
├──────────────────────────────────┤
│ [Shelf] [Low table] [Rug] [Plant]│
│ Row 3 / Col 2  [Place]  [Undo]  │
└──────────────────────────────────┘
```

Customization is new **presentation behavior**, not new economy/progression. Start with free relocation of existing fixtures plus six original free cosmetic options: rug, planter, wall clock, framed harbor illustration, stool and lamp. All available without claiming future GDD unlocks are implemented. Do not introduce decorative purchases or money rewards. Functional counter/bench/entrance are fixed or only moved to validated service sockets; six shelf positions remain six regardless of appearance.

Validate bounds, overlapping solid footprints, protected arrival/lane/checkout access, and reachable stand cells using the same navigation occupancy grid. Furnishing cell 32×32, navigation cell 16×16. Reject invalid placement before Done with crossed footprint + reason; green/red alone is insufficient. Furniture overhang is not its collision footprint. Rotate only props with authored alternate orientations; no blurry arbitrary rotation. Wall items use wall sockets.

Keep 20-edit local undo history, Cancel restores pre-edit layout, Done validates and atomically saves a separate versioned presentation file. Bad/missing visual-save data falls back to safe layout **without resetting economic stock** and explains layout recovery. Layout save failure keeps the player in edit mode with the draft retained and Retry/Cancel available. Lost/unknown `uid` mappings are reconciled safely when an item is sold; don't resurrect stock. Persist settings separately from both economy and decoration where appropriate.

### G. Errors, empty states and help

Empty shelves, no coins, full stock, passed/lost auction, no offered shelf object and completed waves must be visually intentional rooms with a short contextual next action. `Sort · earn 40`, dealer sale and stock drawer supply recovery within existing rules. A save failure puts an opaque readable message and Retry save above the retained room and disables all economic controls. Do not show red error text over a busy floor or clear the scene to a blank screen.

Help is optional and available from Menu, with concise first-use hints anchored to real controls: select a practice good → stock it → open shop → offer → confirm. No modal tutorial wall on every launch. Settings include text size, reduced motion, independent audio levels and haptics off. Receipts remain available for exact accounting. Preserve warnings for incompatible/corrupt saves and manual recovery; no automatic reset shortcut.

## 7. Godot implementation map for the other chat

The following tree/file names are a **proposed addition plan**. Reuse equivalent existing abstractions discovered on reinspection; don't create duplicate managers to follow names mechanically.

```text
scenes/main.tscn                         EXISTING entry scene
  LanternLot (Control)
  ├─ WorldPresentation (Control)
  │  ├─ WorldTexture (TextureRect; nearest)
  │  └─ WorldViewport (SubViewport; disable_3d)
  │     └─ ActiveRoom (Node2D)
  │        ├─ Ground (TileMapLayer; z=-20)
  │        ├─ FloorDetails (TileMapLayer; z=-10)
  │        ├─ DepthSorted (Node2D; y_sort_enabled)
  │        │  ├─ furniture / goods (floor-contact pivots; z=0)
  │        │  └─ player / visitors / bidders (feet pivots; z=0)
  │        ├─ ForegroundCutaway (z=20)
  │        ├─ Effects
  │        └─ Camera2D
  ├─ SafeArea (MarginContainer with layout child)
  │  ├─ StatusHUD
  │  └─ ContextDock
  ├─ ModalOverlay
  └─ PresentationController

NEW reusable scenes:
scenes/world/shop_room.tscn
scenes/world/auction_yard.tscn
scenes/world/loot_room.tscn               shares authored lot arrangement
scenes/actors/shopkeeper.tscn
scenes/actors/visitor.tscn
scenes/actors/rival.tscn
scenes/props/item_view.tscn
scenes/props/furniture_view.tscn
scenes/ui/status_hud.tscn
scenes/ui/context_dock.tscn
scenes/ui/item_inspector.tscn
scenes/ui/bid_controls.tscn
scenes/ui/notebook.tscn
scenes/ui/layout_editor.tscn

NEW scripts/resources:
scripts/presentation/presentation_controller.gd
scripts/presentation/world_input_router.gd
scripts/presentation/item_view.gd
scripts/presentation/actor_view.gd
scripts/presentation/layout_controller.gd
scripts/services/presentation_save.gd
resources/visuals/item_visual.gd          custom Resource definition
resources/visuals/items/*.tres           keyed by existing definition_id
resources/visuals/room_tileset.tres
resources/visuals/furniture/*.tres
assets/art/{tiles,props,goods,actors,vfx,ui}/
assets/fonts/                            fonts + exact licenses
assets/audio/                           original/licensed local audio
art/source/                             editable layered sources
art/art_manifest.json
THIRD_PARTY_NOTICES.md
docs/VISUAL_OVERHAUL_STATUS.md
```

### State binding and resource contracts

Keep one `Game.new()`/`boot()` owner. Child views emit intents; only the controller calls `game.command(kind,args)`. A successful command publishes a read-only snapshot/view model and diff; a failure shows `game.error` without optimism. On save pending, views remain consistent with acknowledged state and economic controls freeze. `Retry save` calls `game.retry()`, then updates views on success. Never let a view edit `game.state` directly.

Authoritative domain screens remain exactly `shop`, `inspect`, `auction`, `reveal`, `result`, `customers`, `receipt`. Appraisal close-up, notebook, transport and layout are presentation modes, not new strings in the validated economic `screen` field. Guard each intent with an in-flight latch and pointer/key release policy: rapid stock/commission taps can otherwise create distinct valid command IDs, which domain duplicate-ID protection cannot deduplicate. Locking must clear on failure or cancellation, while pending-save blocking remains until retry succeeds.

Suggested visual Resource fields: `definition_id`, world `AtlasTexture`, inspect texture, thumbnail region, carry offsets by direction, SpriteFrames if animated, native dimensions, floor contact pivot, visual footprint, truthful clue variant IDs, semantic description key and provenance ID. These fields are **not added to item dictionaries**. The current item dictionary has exactly eight fields and `valid()` checks that size. Root state, lots, receipts and visitors also have closed schemas. Avoid breaking compatible saves to add cosmetics.

View instance identity is owned-item `uid`; sprite selection is definition `definition_id`. Public lot view models must intentionally redact hidden identities/values until legal revelation. Bind the lot's public shape and packing slots before purchase, not full secret resources with hidden labels. Definition IDs visible in development data are not a license to put concealed information into user-facing names/debug overlays.

Keep persistent HUD/world nodes. Switch room scenes for meaningful location changes; reconcile item/visitor nodes by stable IDs on commands. Update labels, sprites, selection and sockets in place. The current `render()` all-child deletion loses animation/focus state; replacing it with another destructive rebuild misses the task.

Economy changes first, presentation second. Compare before/after committed snapshots to derive shelf movement, reveal, customer exit, cash change, discovery and auction reactions. Animations have cancellation/settling behavior; finishing an animation never invokes a financial command. Reconstruct current views directly from a loaded snapshot. Cosmetic viewing/open-box history may be ephemeral and never changes ownership. Walking/action animations may run concurrently with UI provided they cannot issue duplicate intent.

### Exact current command bindings

| Control/intent | `kind` | `args` | Where legal / effect |
|---|---|---|---|
| Enter yard | `visit_lot` | `{}` | shop; validates money/free slots; creates current fixture |
| Confirm hotspot inspection | `inspect` | `{target: 0..3}` | inspect; quota/max two; read same target allowed |
| Tighten ceiling | `ceiling` | `{amount: integer}` | inspect/auction; only lower permitted |
| Bid exact amount | `bid` | `{amount: integer}` | inspect/auction; opening 40 or legal increment |
| Leave/pass | `pass` | `{}` | inspect/auction; permanent withdrawal under domain rules |
| Batch verification | `appraise` | `{}` | shop/reveal; verifies all owned and discoveries |
| Return | `return_shop` | `{}` | reveal/result/receipt; clears lot, goes shop |
| Stock/unstock chosen item | `stock` | `{uid: string}` | shop; verified object; toggles shelf |
| Commit asking price | `price` | `{uid: string, amount: integer}` | shop; integer 1..100000 |
| Dealer liquidation | `dealer` | `{uid: string}` | shop; verify actual guards on reinspection |
| Recovery sorting | `commission` | `{}` | shop; +40 under current rule |
| Buy stock-rack capacity | `rack` | `{}` | shop; existing 120/180 costs and max two |
| Start customer wave | `customers` | `{}` | shop; six paused visitors |
| Offer selected shelf object | `offer` | `{uid: string}` | customers; one considered offer per visitor |
| Confirm current sale | `accept` | `{}` | customers; existing offer; saves net proceeds/removal |
| Decline/skip current visitor | `skip` | `{}` | customers; advances wave |
| Recover pending save | service `retry()` | no command | preserves existing commit candidate |

Inspection, movement, notebook browsing, box-view toggles, transport motion, camera pan and decoration editing have no invented economic command. Recheck the reducer's exact guards before binding. Keep useful original tests, don't rewrite tests simply to approve a changed rule.

### Tiles, depth, collision and movement

Use shared external `TileSet` resources and several `TileMapLayer` nodes for floor, details and appropriate walls. Installed 4.7.2 supports these; don't use deprecated `TileMap` APIs from old tutorials. Tall movable props are independent reusable scenes so they can share actor Y-sorting. [Godot TileMap documentation](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilemaps.html) describes layer organization and reusable TileSets.

Ground/details sit below actors. Actors and tall props share `z_index=0` and a Y-sorted parent, origins at floor contact. Godot compares Y-order within compatible z bands; setting every shelf to a permanently high z breaks behind/in-front overlap. Split overhanging upper shelves/signs from bases where needed; foreground cutaways never hide active objects. Use a clipped/faded obstructing upper part with a readable base, not broad transparency across all furniture. [CanvasItem reference](https://docs.godotengine.org/en/stable/classes/class_canvasitem.html).

Collision covers occupied floor cells, not entire tall artwork. Use a simple `AStarGrid2D` occupancy grid for this small editable orthogonal room or a verified equivalent; no need for stacked navigation meshes. Recompute connectivity on committed layout edits, not per frame. Shopkeeper/visitors can be CharacterBody2D with conservative foot colliders and discrete path waypoints. Avoid crowd physics that traps the player; brief waiting/reservations and direct-action alternative suffice. Assign explicit world-blocker/actor/interactable layers and masks, documented in status notes.

Camera keeps continuous logical targets if useful but snaps the **rendered** transform to whole art pixels. Disable smoothing until panning/walking is demonstrated without shimmer. Clamp to room bounds, keep the selected object outside HUD occlusion, and don't shake the camera to communicate bids.

### Import/export and technical checks

PNG RGBA sprites exported at native size, transparent backgrounds, lossless import, mipmaps disabled for pixel sprites enlarged at integer scale. In Godot 4 filtering/repeat belong to CanvasItem/project settings, not old import-panel Filter instructions. Set nearest on the world texture and sprite hierarchy; verify actual default 2D filter in installed Project Settings. Text uses its appropriate font rendering separately. [Image import documentation](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_images.html).

Atlas maximum initial 1024×1024; split environment, goods, furniture, actor variants and VFX. Keep two transparent gutter pixels around each cel with explicit region rectangles/padding so animation doesn't sample neighbors. Consistent pivot is mandatory. Export integer region coordinates and no JPEG compression. Preserve editable sources and stable imported paths/UIDs; don't regenerate resources into new IDs every run. Import/export presets and font/license assets must be included in actual builds, not just the editor project.

The hybrid low-resolution world/high-resolution UI is this brief's design choice, using Godot's supported viewport and UI facilities. It is not a claim that the documentation mandates this architecture. Use [multiple-resolution guidance](https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html), [SubViewportContainer reference](https://docs.godotengine.org/en/stable/classes/class_subviewportcontainer.html), [InputEvent routing](https://docs.godotengine.org/en/stable/tutorials/inputs/inputevent.html) and [DisplayServer reference](https://docs.godotengine.org/en/stable/classes/class_displayserver.html), verifying API signatures against the installed engine.

## 8. Asset production brief and animation contracts

### Complete the actual catalog

All nine current identities require an original distinctive world sprite, truthful inspect crop, notebook/inventory thumbnail and carried attachment derived from a consistent source. Don't expand the catalog to avoid finishing existing goods.

| Existing ID | Native art starting point | Required recognizable detail |
|---|---|---|
| `homewares.enamel_kettle` | 16×16 | Teal enamel body, distinct spout/handle, brass lid; subtle maker ring in inspect crop |
| `homewares.folding_stool` | 16×24 | Crossed legs, seat top/front, purposeful worn joints |
| `tools.desk_fan` | 16×24 | Round metal grille, pedestal and foot; fictional tested-safe tag close-up |
| `tools.hand_drill` | 16×16 | Crank, grip and bit; not a generic tool icon |
| `homewares.serving_bowl` | 16×16 | Elliptical rim, cream ceramic interior, decorated outside |
| `paper.tram_print` | 24×24 | Timber frame and original tiny tram illustration; larger crop readable as artwork |
| `practice.cup` | 16×16 | Measuring cup handle, lip and marks |
| `practice.square` | 16×16 | Steel L-shaped square, material edge, not a solid rectangle |
| `practice.folio` | 16×16 | Folded paper case, overlapping corners and closure |

Use fictional maker marks, no real brand logos. Accurate exposed clues and concealed packages matter more than glamorous item rarity. Do not import museum dinosaur assets just because the reference has them. The large anchor is shop furniture/display composition; new decorative collectibles require explicit scope approval.

### Required environment/actor batch

- One original shop room set: warm stone pieces, timber wall/door/window, six display sockets, stock tray/rack, counter, appraisal bench, hanging lamp and street threshold.
- One auction yard/storage bay set: shutter pieces, timber/concrete frame, pavement/stone floor, exposed item stands, crate, wrapped carton, flat package, auctioneer position and cart.
- Six cosmetic pieces described in Layout mode; final placement footprints and authored orientation variants where supported.
- One shopkeeper, three visibly distinct named bidders Mei/Arif/Suri, one auctioneer, six customer appearances mapped to existing customer IDs. A coherent modular body/clothing/hair kit is acceptable; don't make six unrelated generated art styles.
- Box/shutter/sale/reveal/sparkle/selection effects; actual UI theme and focus/pressed/disabled states; original Lantern Lot application icon.

Sparse and stocked versions of the same shop must both look composed. Don't fill every empty floor cell with clutter. Closed shop has a person checking stock/bench; an active wave has the current visitor browsing; quiet result has a finished transaction and visible goods. More people are presentation, not extra sales.

### Atlas manifest

For each sprite/frame sequence, record stable asset ID, related definition/actor, source path, output atlas, region `(x,y,w,h)`, gutter, native size, pivot, footprint, animation name, frame IDs/count, FPS, looping, terminal pose, directional carry anchor, license/provenance and `placeholder` flag. Validate required mappings at import/test time. Missing final mapping is a failing build gate, not a reason to silently draw a block. Keep rough sprites separately identified.

Four directions: down/left/right/up. Character cels 24×32, pivot `(12,28)`. Avoid runtime scaling/bounce/rotation of pixel sprites. Use integer pose changes or sprite frames. Customer outfits retain palette/lighting and enough value contrast with the floor.

| Motion | Frames / rate / cel | Required visual/event behavior |
|---|---|---|
| Idle | 4 at 3 fps, 24×32 | Subtle 1-pixel breathing; no distracting rhythmic bouncing |
| Walk, each direction | 6 at 8 fps, 24×32 | Alternating contact feet, no foot sliding; stable pivot |
| Interact | 4 at 6 fps, 24×32 | Reach/tool motion; short final pose; no transaction callback |
| Carry idle | 2 at 2 fps, 24×32 | Goods on directional hand anchor |
| Carry walk | 6 at 8 fps, 24×32 | Same gait/pivot; item behind body when facing up |
| Bidder paddle | 4 at 8 fps, 24×32 | Raise, 0.25-second hold, lower; accepted public log reaction only |
| Browse | 4 at 4 fps, 24×32 | Head/hand toward actual displayed object, 1–2-second still pauses |
| Checkout handoff | 4 at 8 fps, 24×32 | Customer receives bag; after committed sale |
| Crate open | 5 at 10 fps, 32×32 | Lid separates by frame 3; show legally revealed content only |
| Shutter open | 6 at 8 fps, modular or 64×64 | Stop at open state; expose room, not a new transaction |
| Reveal accent | 6 at 12 fps, 32×32 | 0.5-second clustered glints around real sprite; no rarity slot machine |
| Sold accent | 4 at 10 fps, 16×16 | Brief receipt/register glint; item removal mirrors committed state |
| Sparkle | 6 at 12 fps, 16×16 | One diamond star + two tiny glints; event-driven, never all items continuously |
| Selection | static brackets, optional 2 at 2 fps | Stable object/foot marker; contrast against varied backgrounds |
| Lamp/radio ambient | 2–3 at 2 fps, 16×16 | Decorative only, cap simultaneous animation |

Non-looping motions settle in a known terminal pose. Cancel/reload/skip settles from acknowledged state without replay. Limit a batch of auction reactions to roughly 1.5 seconds or offer immediate skip; no forced long cinematic. Reduced motion removes breath cycles, sparkle, camera motion and carrying sequences while retaining static status/functional poses. Each action remains usable without animation or sound.

### Rough versus final art

Milestone rough art: original silhouette-complete raster sprites at final cel sizes, recognizable object/material planes and coherent palette. They must already allow visual gameplay. Tag them `placeholder=true`, show an explicit backlog, and don't declare final polish.

Final art: deliberate cleaned pixel clusters, consistent lighting/perspective/outlines, no interpolated fringe or image-generation artifacts, completed poses, stable atlas/pivots and unique phone-scale silhouettes. Procedural floor tiling is fine; an unreviewed matrix of rectangles masquerading as furniture is not. If an image tool is used, generate original art, inspect and clean it, reconcile exact frames and prove license/provenance; a generated sheet is not automatically a valid atlas. Never generate each animation frame independently and accept drifting characters.

If no final-art capability is available, the implementing chat can deliver a runnable rough visual slice and exact asset commission brief, but must report final graphics as incomplete. Do not fabricate production-quality claims or art-source permission.

## 9. Audio, accessibility and offline performance

### Feedback

Use restrained locally stored original/licensed sounds: wood drawer, paper, crate lid, ceramic handling, metal handling, bid paddle, bid accepted, auction closure, appraisal note, shelf placement, register and invalid action. One quiet room/street ambience loop is enough. Budget 12 short effects; no copied game audio, voices or commercial songs. Separate music/ambience/SFX buses; default gentle levels, no clipping, no essential stereo clue. Optional haptics default off until supported; sound/haptics off must lose no information.

Every sound has visible equivalent: new bid number/log, clear selected item, verified notebook entry, shelf change or receipt/net amount. Do not play success chimes on a failed command. Focus/press feedback uses a defined outline and immediate pressed state; no fade-only buttons, cursor beams or screen flash. Keep technical save diagnostics in development logs/help, not constant prose across the play area.

### Accessibility

Use WCAG as a design reference for contrast and readable interaction, not as an untested certification. [WCAG 2.2 quick reference](https://www.w3.org/WAI/WCAG22/quickref/) covers text/non-text contrast, focus and target considerations. This brief's 48-unit targets are a larger product target, not a claim WCAG prescribes that exact native size.

All important information survives grayscale: label current leader, check inspected hotspot, crossed invalid footprint, text budget/condition, named discovery. All financial values are text, not coin icons alone. Focus indication must be visible against both paper and room. Large-text sheets wrap/reflow, input fields remain operable, keyboard isn't trapped and closing sheets restores focus.

Expose interactive semantic name/role/state with truthful public descriptions where supported. Decorative art is excluded from reading order. An equivalent inspection/object list provides access when small world targets are difficult. Semantic names of covered goods must remain neutral. Verify actual mobile TalkBack/VoiceOver behavior and bridge support before claiming nonvisual playability; desktop focus tests alone do not establish it. Provide captions for any essential spoken audio if later added. No rapid flashes, precision swipes, required long presses or multi-finger gestures.

### Offline/performance design targets

No network requests, accounts, ads, tracking or external embeds. All art/fonts/audio load locally. Do not request permissions unrelated to the game. Store policies/legal pages are not invented for this prototype; public distribution, monetization and territory review are separate gates.

Initial budgets are proposed targets, **not measured baseline results**: stable 60 fps on an agreed mid-range Android device, 30 fps low-power fallback without changed rules; normal update budget 16.7 ms or 33.3 ms in fallback; about 12 active actors maximum, 20 brief effects maximum, atlas pages up to 1024², no idle decoration per-frame script, and no frame-by-frame rebuild of UI/room. Start with a measured memory target around 200 MB on the chosen device and adjust transparently for engine/platform overhead, never assert compliance without profiling.

Profile the populated shop and auction, not only empty-room screenshots. Disable updates for invisible viewports/rooms; pause/cancel presentation on app suspension; avoid continuous particles, expensive lights/postprocessing, idle allocations, synchronous asset loading during bids and large hidden scene collections. Sharing atlases/resources and capped actor path checks usually suffice; optimize the measured bottleneck. [Godot optimization guidance](https://docs.godotengine.org/en/stable/tutorials/performance/general_optimization.html) emphasizes profiling.

Economic saves remain on meaningful commands, never every rendered frame. Resume does not regenerate budgets, replay purchases or alter current encounter. Preserve engine safe-save protections. Logs/assets/diagnostics must not silently be uploaded anywhere.

## 10. Milestones and acceptance evidence

Implement in reviewable slices. A milestone fails when its screenshots look wrong even if automated checks pass. Keep changed-file ownership separate among agents; integration agent owns main controller/scene and final verification. Don't have several agents edit `main.gd` simultaneously.

| Gate | Concrete deliverables | Acceptance proof |
|---|---|---|
| M0: re-audit | Current scene/settings/command map; baseline tests; baseline captures; reference opened or availability flagged; save backup strategy | Real engine version, commands/results and screenshot review; no invented paths/features |
| M1: visual slice | Persistent world/HUD; authored shop floor/walls; shopkeeper; three starter sprites; six sockets; selection/stock/price; one auction bay with four hotspots | Default view dominated by room; stocking visibly moves correct good; inspect sends correct target; 360×640 plus 393×852; no scroll to core controls |
| M2: full current loop | All nine item sprites; three bidder motions; win/loss; crate/reveal/appraisal; free transport feedback; six visible customers; sale/receipt | Full rendered interaction recording/screenshots; exact coin/stock/discovery consistency; save-before-success; same hidden-information policy |
| M3: customization/responsiveness | Six decor assets; validated layout mode; separate visual persistence; safe-area transform; large text; focus; reduced motion/audio off | Valid/invalid layout captures, relaunch preservation, corrupt visual-file fallback without economy loss, size matrix and 200% text |
| M4: final polish and regression | Final reviewed raster art/source; atlases/manifests/licenses; icon/audio; no missing IDs; adapted smoke harness; performance/device evidence | No placeholder flags on required assets; clean runtime except specifically expected test error; complete evidence table and measured profile |

Missing Android hardware/export setup does not excuse skipping desktop rendered verification. Report mobile acceptance as untested if unavailable and do not call the entire mobile-ready overhaul complete. Do not silently add the future full catalog/monetization while these gates are unfinished.

### Required screenshot and recording set

Use `build/visual-overhaul-evidence/` or another ignored development folder in the implementation repository. Name captures deterministically and provide actual file links in the handoff. Use fixture/scratch saves, never overwrite normal saves to manufacture a screenshot.

1. `01-shop-sparse`: three identifiable practice goods, player, clear aisle, full default HUD.
2. `02-shop-stocked`: six true shelf items plus decor, same camera as sparse.
3. `03-yard-inspect`: four reachable hotspots, two consumed clues, concealed goods still concealed.
4. `04-auction-bid`: visible bidders/current leader; legal exact bid totals and disabled-above-ceiling state.
5. `05-won-storage`: open shutter/crates, same six-item layout, correct won amount.
6. `06-appraisal`: real item close-up, name/condition/reference after legal verification.
7. `07-transport`: cart/carrying feedback with no added economic action.
8. `08-customer-browse` and `09-sale-confirm`: named current visitor and actual displayed item, exact gross/fee/net.
9. `10-sold`: good removed, customer bag/exit, updated cash.
10. `11-notebook`: discovered/owned separated; sold discovery retained; unknown entry neutral.
11. `12-layout-valid`, `13-layout-invalid`: footprints, preserved lane and explicit rejection.
12. `14-save-failure`: retained world, paused actions and Retry save.
13. `15-large-text-200`, `16-short-phone`, `17-notch-safe-area`: readable controls at edge cases.
14. `18-depth-front` and `19-depth-behind`: same actor around tall shelf, correct sorting.

Also capture 10–20 seconds of walk/interact/box/bidder/customer/sold animation at real runtime speed. Static images cannot prove pivot stability, input responsiveness or no shimmer. View at native world pixels and actual phone presentation, not only a high-resolution zoom that conceals unreadability.

### Executable verification for the implementing chat

Use its real Godot integration for version/project info/editor/run/debug output. Current connected tooling supports those operations and scene/sprite operations, but screenshot capture and touch playback capabilities must be checked rather than assumed. The existing `--ui-smoke` harness already writes rendered screenshots with scratch saves; adapt it to the new persistent UI. Inspect produced captures, don't just count PNGs.

PowerShell examples for the current machine, run only in the implementing chat's authorized checkout or disposable audit copy:

```powershell
$godotExecutable = 'D:\Godot\Godot_v4.7.2-stable_win64_console.exe'
$projectDirectory = 'C:\Users\media\OneDrive\Documents\lantern-lot'
& $godotExecutable --version
& $godotExecutable --headless --path $projectDirectory --editor --import --quit
& $godotExecutable --headless --path $projectDirectory --script tests/run.gd
& $godotExecutable --path $projectDirectory --resolution 360x640 -- --ui-smoke
& $godotExecutable --path $projectDirectory --resolution 393x852 -- --ui-smoke
```

Create evidence/log directories first. Save full stdout/stderr and exit status for each stage in the actual workflow. Headless startup of the main game should use an explicitly isolated scratch save mode; the current `--ui-smoke` waits for rendering and is not a headless screenshot tool. Add a proper non-rendering smoke fixture if needed, then use `--quit-after 120` only as a bounded startup check. That value counts process iterations, not seconds. `--check-only` applies with `--script`; it is not a substitute for project import/startup/tests. See the [official command-line tutorial](https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html).

Run the editor/game with the actual renderer, inspect debug output and close only runs you started. A zero exit status with ERROR lines is not an error-free pass. Identify the expected negative-save test by test context; fail on new parser/import/resource/null/animation errors, missing assets and unhandled warnings with practical consequences. Never mute errors or remove the bad-directory test to produce a green log.

### Acceptance matrix

| ID | Action/test | Pass criterion |
|---|---|---|
| V01 | Launch shop without help | Room, player, three recognizable stock goods visible immediately; no default full-page scroll |
| V02 | Stock/unstock starter; edit price | Correct `uid` sprite/socket moves; stock/unstock commits once; coins unchanged; asking price changes only on explicit Set price |
| V03 | Inspect targets 0 and 3; repeat; try third | Accurate clues/quota; third denied; no concealed identity/value leakage |
| V04 | Bid/open/raise/pass at ceiling edges | Domain exact legal rules; paddle/log reflects committed rounds; no timer/retraction |
| V05 | Win and interrupt open/carry sequence | Debit once, six objects once; resume same inventory and safe scene |
| V06 | Appraise from selected item | All owned verify together; free; discoveries only nonpractice; visuals update coherently |
| V07 | Return during/skip transport | Same ownership/coins with or without animation; no load transaction |
| V08 | Offer/accept and rapidly double tap | One sale/net increase/removal; no accidental offer to next visitor; failed/stale command no success feedback |
| V09 | Skip visitors or wait indefinitely | Existing queue rules preserved; no spontaneous sale, budget reroll or fee |
| V10 | Full wave and receipt reopen | Session increments once; return valid; receipt accurate and readable |
| V11 | Sell last copy; view notebook | Discovery persists, Owned clears; no phantom shelf item |
| V12 | Fail economic save then retry | Economic actions blocked; room not falsely advanced; one commit and one acknowledged outcome |
| V13 | Corrupt/incompatible economic save | Originals retained; no automatic reset or silent layout-based inventory repair |
| V14 | Edit layout into aisle/outside | Placement denied with explanation; Cancel/Undo works; route remains reachable |
| V15 | Save valid layout/relaunch/corrupt visual file | Valid layout restored; bad visual data safe fallback; coins/inventory/saves untouched |
| V16 | Touch pan → release over object/button | No unintended inspection/bid/sale; correct transformed hit target at all sizes |
| V17 | Keyboard-only complete current loop | Visible focus, no trap, modal focus return; all world intents have accessible equivalents |
| V18 | 200% text and shortest portrait | Amounts/buttons fit or sheet scrolls; controls remain reachable; no clipping/ellipsis of binding total |
| V19 | Actual notch/gesture-area/mobile suspension | Safe essential controls; state restored; no background income or duplicated effects |
| V20 | Walk around tall furniture/pan camera | Correct front/back depth; no shimmer, blurred pixels, pivot drift or blocked route |
| V21 | Grayscale/audio off/reduced motion | All decisions/info retained; instant settling available; no mandatory gesture/animation |
| V22 | Inspect populated shop profile offline | Report actual device/resolution/FPS/frame-time/memory; no network dependency or runaway actor/effect count |
| V23 | Verify full asset manifest/licenses | All nine IDs mapped, no required placeholders, exact source/author/license or original provenance; no reference art shipped |

Preserve the 3,907 current checks and meaningful failure coverage. New tests should target real risks: view-to-command mapping, commit/failure feedback, cancellation/resume, hidden-data redaction, pointer transform, slot reconciliation and layout validation. Do not test superficial constants merely to inflate a count. Domain pass alone cannot satisfy V01/V20/art quality.

## 11. Deliverables, handoff and honest completion

The implementing Codex chat must deliver:

- The working existing project with persistent visible rooms, all current command bindings and preserved saves/mechanics.
- Finished required art/animations and editable sources, all nine goods, actor/environment/decor sets, atlas/visual manifests and licenses.
- Responsive HUD/sheets, safe-area handling, input alternatives, focus/text/audio/motion options and validated customization.
- A runnable baseline-compatible full loop, adapted isolated smoke fixtures and relevant integration checks.
- Captures/recording, full check summaries/error review, actual device/profile results or explicit untested device gates.
- `docs/VISUAL_OVERHAUL_STATUS.md` listing completed gates, changed scenes/settings, rules intentionally preserved, rough assets remaining, source uncertainties and precise remaining blockers.
- A short final message: how to launch; what visibly changed; which checks passed; actual evidence links; what remains incomplete. No “done” claim based only on scaffolding or headless success.

Art/audio register fields: asset ID, origin/source URL if applicable, creator, exact license/version, commercial-use basis, modification status, attribution file, editable-source location and review date. Original commissioned assets need ownership/use terms; unknown license assets stay out of builds. Never assume “found online,” “AI generated,” or “open source” proves every use is permitted. Name/trademark clearance and public release are not certified by this brief.

## 12. Research and limitations

Primary sources were retrieved for this brief on 14 October 2026. Links under `stable` can move as Godot evolves; verify installed 4.7.2 signatures before coding. Art metrics, palette, composition, UI sizes, scene plan and performance budgets are this designer's decisions, not borrowed mandates or measurements from the reference.

| Source | Specific application |
|---|---|
| [OpenAI Codex Prompting Guide](https://developers.openai.com/cookbook/examples/gpt-5/codex_prompting_guide) | Give implementation agents relevant repository context, clear outcomes and a completion/verification contract. This brief is a task artifact, not a replacement system prompt or a guarantee of model performance. |
| [OpenAI: Rethinking skills and prompts](https://developers.openai.com/blog/rethinking-skills-and-prompts-for-gpt-6-astra) | Keep instructions relevant and grounded; separate this detailed design reference from the concise entry prompt. No particular model change is requested here. |
| [Godot multiple resolutions](https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html) | Anchors/stretch/portrait and scale decisions; verify physical integer pixels in the hybrid architecture. |
| [Godot image import](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_images.html) | Lossless pixel assets and Godot 4 filter location. |
| [TileMapLayer reference](https://docs.godotengine.org/en/stable/classes/class_tilemaplayer.html) and [TileMap workflow](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilemaps.html) | Shared TileSets, separate floor/detail layers, version-correct APIs. |
| [CanvasItem](https://docs.godotengine.org/en/stable/classes/class_canvasitem.html) | Y-sort/z-index and texture filtering behavior. |
| [SubViewportContainer](https://docs.godotengine.org/en/stable/classes/class_subviewportcontainer.html) and [InputEvent](https://docs.godotengine.org/en/stable/tutorials/inputs/inputevent.html) | Choose and verify one input-forwarding system; consume GUI events. |
| [DisplayServer](https://docs.godotengine.org/en/stable/classes/class_displayserver.html) | Safe-area query/support limitations. |
| [Godot optimization](https://docs.godotengine.org/en/stable/tutorials/performance/general_optimization.html) | Profile actual populated scenes instead of assuming budgets passed. |
| [Godot command line](https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html) | Import/run/check tooling and CLI argument semantics. |
| [W3C WCAG 2.2 quick reference](https://www.w3.org/WAI/WCAG22/quickref/) | Contrast/focus/readability inspiration, not a native-game certification. |
| [Atkinson font OFL](https://github.com/googlefonts/atkinson-hyperlegible-next/blob/main/OFL.txt), [Silkscreen OFL](https://github.com/googlefonts/silkscreen/blob/main/OFL.txt) | Verify/download/bundle exact font notices and license terms. |

Unresolved source limitations: the original art reference could not be viewed here and its origin/license are unknown; the linked historical conversation was unavailable; actual Android/iOS safe areas, performance and semantic accessibility remain untested; Git worktree state was not inspectable. The real project code and copied desktop baseline were inspected/run as described. The implementing chat must not turn these limitations into fabricated observations or shipped-rights claims.
