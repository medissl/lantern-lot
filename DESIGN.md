# Lantern Lot

## Implementation-ready game design document

Version 1.0, 14 October 2026. Status: design specification only. No game has been implemented, playtested, trademark-cleared, or performance-certified. Numbers are starting balance hypotheses, not observed results. This file is the design authority for a later prototype; change it when evidence contradicts it.

**Pitch:** Open a small secondhand shop in a fictional harbor neighborhood. Read the clues in storage lots, bid against three recognizable rivals, discover objects with useful histories, and decide whether to sell, restore, collect, or display them. Build a shop that feels like yours, including a traditional Chinese shopfront theme. A good decision can be a modest purchase, a customer match, or walking away.

## Contents

- [Assumptions, pillars and comparative research](#assumptions-and-decisions)
- [Authoritative MVP integration contract](#authoritative-mvp-integration-contract)
- [Complete seed catalog](#complete-seed-catalog-for-authoring)
- [Gameplay, content and economy](#gameplay-content-and-economy-specification)
- [Technical architecture and schemas](#technical-architecture-and-implementation-contract)
- [Art direction, interface and accessibility](#art-direction-interface-and-accessibility)
- [Production, QA and release obligations](#production-plan-verification-and-release-obligations)

### Assumptions and decisions

| Topic | Default decision | Why / validation needed |
|---|---|---|
| Audience | Teens and adults who enjoy collecting, decorating, and light management | Audience hypothesis, not a market-size claim; age rating must be assessed separately |
| Platform | Android portrait first; Windows portrait window for development and accessible keyboard/controller testing; iOS later | Small mobile scope; iOS needs macOS/Xcode and export validation |
| Team | One programmer/designer with contracted pixel art/audio and paid review as needed | Estimates below assume focused work, not guaranteed calendar promises |
| Engine | Godot Standard with GDScript and Compatibility renderer | Exact pinned version and export gates in architecture chapter |
| Connectivity | Core game works offline; no account, ad SDK, analytics service, or backend | Removes waiting, tracking and service dependencies |
| Business model | Prototype free/private; candidate release paid once | No price, store submission, purchase system, or publication authorized by this document |
| Setting | Fictional contemporary harbor town; goods are lawfully consigned clearance lots | Avoid treating vulnerable former owners or real auctions as entertainment targets |
| Camera | Fixed three-quarter top-down shop diorama; front-facing lot cutaway | No first-person walking, driving, combat, or continuous open world |
| Scope | One complete small game loop before additional systems | Exact MVP content minimums appear in the integration contract |

### Working name selection

Selected **Lantern Lot**: short, suggests both the shop's warm light and auction lots, and does not use Roblox or Storage Hunter branding. Alternatives considered: **Secondhand Stories** communicates object histories but has existing bookshop, music and game-adjacent uses; **Shelf & Story** already identifies an App Store product. Limited exact-name web searches on 14 October 2026 did not surface a clearly matching Lantern Lot game, but surfaced ordinary auction descriptions. This is only a discoverability screen. It is not a registered-trademark search or a finding of availability. Existing examples: [Secondhand Stories bookshop](https://bookshop.org/shop/SecondhandStories), [Shelf & Story App Store listing](https://apps.apple.com/ca/app/shelf-story/id6774715926).

Before branding expenditure, search exact, similar, phonetic, translated and logo marks in planned territories and relevant goods/services, including Nice classes 9 and 41 as a starting point. Search [WIPO Global Brand Database](https://www.wipo.int/en/web/global-brand-database/index) and relevant national/regional registers, storefronts, company names, domains and common-law uses. WIPO itself advises national/regional searches because coverage is incomplete. Have a qualified trademark professional assess conflicts. Do not claim clearance or register a domain based on this document. A neutral internal project identifier is `lantern_lot` until cleared.

### Pillars and design rejection rules

1. **Find meaning in evidence.** Clues, condition and maker details inform decisions. No hidden player luck stat, paid luck, timing-bar bidding, or price-coded opening bids.
2. **Make a home for objects.** Price and customer match matter; decoration is a central reward with no mandatory income multiplier.
3. **Grow your options.** Progress unlocks new information, customers, display choices and workflows. New venues overlap in value, instead of forming a net-worth ladder.
4. **Risk without punishment spirals.** A loss has a readable cause and a guaranteed route back. No debt interest, unavoidable rent, stamina, daily streaks, offline spoilage or expiring calendar events.
5. **Respect short sessions.** Every decision pauses. Save after durable actions. Transport is a quick packing choice and transition, not repeated carrying trips.

Reject any feature whose only purpose is multiplying numbers or increasing chores. A new item must add a recognizable visual, clue, customer use or story; a new venue must add a decision rule. The feeling to test is “I recognized something and made it mine,” not “I finally crossed the next money threshold.”

### Five-minute target session

| Elapsed target | Action | Meaningful choice |
|---|---|---|
| 0:00-0:30 | Review shop ledger and choose one of three lots | Need stock, a collection object, or a customer-request category? |
| 0:30-1:30 | Read lot silhouette and use inspection actions | Which uncertainty is worth resolving? |
| 1:30-2:30 | Set a personal bid ceiling and bid or walk away | Evidence and rival intent versus price |
| 2:30-3:10 | Reveal, appraise and pack | Keep, restore, sell, display or recycle |
| 3:10-4:30 | Stock shelves and run a short customer wave | Faster turnover versus a higher ask |
| 4:30-5:00 | Review outcomes and place a decoration | Choose next goal, stop with saved progress |

These are pacing targets, never deadlines. Losing an auction leads directly to another lot or the shop. Returning players can complete a shop-only session. A suspended session resumes at its last committed decision without running customers or bids in the background.

### Research and comparative analysis

The structure follows the overview, gameplay, art, technical and production coverage in [Indie Game Academy's GDD and one-pager guide](https://indiegameacademy.com/free-game-design-document-template-how-to-guide/), published 29 April 2025 and reviewed for this document. We also use explicit tuning values, named deliverables and a change log as recommended by [Game Developer's Crafting a GDD](https://www.gamedeveloper.com/design/design-docs---crafting-a-gdd), published 16 July 2020 and still accessible. These are documentation guidance, not proof this design is fun. No template's text or artwork has been copied into the game.

Comparisons below use developer/publisher storefront descriptions accessed 14 October 2026, not inferred player counts, revenue, retention or review sentiment. The Roblox game's specific frustrations are the user's reported experience, not independently audited current mechanics. Storage Hunter Simulator is a separate PC title and must not be confused with the Roblox reference.

| Reference | Verified relevant features / evidence boundary | Design lesson and our difference |
|---|---|---|
| Roblox Storage Hunter Open World | User reports auctions, transport, shop building, value-revealing opening prices, net-worth area gates and large mutations | Preserve acquisition-to-shop satisfaction; replace reflex bidding, price peeking and exponential progression. Do not copy characters, maps, item artwork, interface or scripts |
| [Storage Hunter Simulator](https://store.steampowered.com/app/1442430/Storage_Hunter_Simulator/?lang=en) | Publisher describes warehouse auctions, spotting valuables, driving and resale | Use evidence-led buying; compress travel into a map transition and offer paused decisions |
| [Dealer's Life 2](https://store.steampowered.com/app/1343670/Dealers_Life_2/) | Developer describes negotiation, customer reading, auctions, counterfeit goods, employees and an item catalogue | Make customers understandable through requests; MVP avoids counterfeit punishment and employee complexity |
| [Moonlighter](https://store.steampowered.com/app/606150/Moonlighter/) | Developer describes loot acquisition, shop price setting, reserve management and shop upgrades alongside combat | Share the acquisition/resale rhythm; auction inspection replaces combat and no theft threatens relaxed shop sessions |
| [Barn Finders](https://store.steampowered.com/app/991170/Barn_Finders/?l=english) | Developer describes finding valuables in barns and storage auctions | Keep tangible household objects; small portrait dioramas replace first-person scavenging |

Originality comes from the combination of a fixed-price opening, clue notebook, bounded auction decisions, request-driven resale, objects with grounded histories and a buildable intimate shop. Auctions and shopkeeping alone are not unique. Before production, play or watch authorized gameplay from the references and record a feature-by-feature similarity review. No advertising claim such as “first,” “most relaxing,” or “better than” is justified by this research.

### How to use this README later

Read the integration contract, then gameplay, then architecture before writing code. Build the smallest vertical slice listed in milestones. Content samples are seeds for authoring, not a claim all content exists. Never silently replace uncertain design choices with defaults from a UI kit. Proposed changes must identify the player problem, affected formulas/data, tests and scope cost. Where a named contract conflicts with an illustrative example, correct the example before implementation.


## Authoritative MVP integration contract

This section fixes cross-system defaults. Examples in later chapters illustrate them; they do not authorize extra scope. All content here is a specification to create, not existing art or code.

| System | MVP contract |
|---|---|
| Core content | 40 item identities, four categories with ten identities each; four ten-item index sets; one auction yard, three thematic listing profiles; three rival bidders; three named regular customers |
| Art / audio | 40 thumbnails plus inspect/world variants as needed; six unique portraits (three bidders, three regulars); two decoration kits with 12 placeable definitions each; one neighborhood facade; one ambient loop and 12 functional sounds |
| Start | 360 coins, 18 stock slots, six sale shelf slots, one six-item batch van, counter and free neutral basic furniture; three tutorial sample objects occupy three stock slots |
| Auction | Six objects, three exposed silhouettes plus three covered containers; four inspectable targets, two close-inspection actions; fixed opening 40; raises 10/20/40; three NPCs |
| Safety ceiling | `min(250, wallet - 40)`; hard per-lot cap 250 and protected reserve 40 in MVP. Below wallet 80 offer recovery or shop sales. Player may lower ceiling; cannot lower it below an already binding bid |
| Commitment | Only a nonleader can permanently pass out. Leader may Hold my bid but cannot retract. No timed input or bidder reentry. Highest remaining leader wins; no accepted opening means unsold |
| Transport / capacity | Reserve six free stock slots before joining. Automatic free batch transfer of all six on win. No cargo discard, transport fee or carrying trip. All item definitions consume one stock slot; art footprint applies to furniture/display, not transport |
| Customers | Six paused encounters per shop session: three regulars, two category browsers, one general bargain buyer. New queue only after current queue reaches receipt. No sales without player confirmation or while absent |
| Economy | Coins are integers; condition factors 0.60/0.85/1.00 at 20/65/15%; rarity weights 65/25/8/2%. Provenance factor 1.00 in MVP; 1.15 cap reserved for future authored research. 8% rounded fee per ordinary sale; dealer pays rounded 50% of reference with no fee |
| Capacity purchases | First rack 120 adds six stock slots; second 180 adds six, maximum 30. Both maintain six sale shelf slots in MVP; stock capacity is not customer throughput. Furniture uses separate placement budget |
| Recovery | Free repeatable sorting commission pays 40, with equivalent labeled-choice/skip accessibility completion; no loot/milestone rewards. No refunds, loans, debt, rent, daily restrictions or secret post-loss luck in MVP |
| Decoration | 6 by 8 floor, protected entrance/counter and two-tile continuous customer lane; theme has no price, traffic, appraisal or luck bonus. 24 prop definitions, neutral and Chinese timber shop themes mix freely |
| Scope exclusions | Restoration bench, provenance research, specialization, new auction formats, multiple yards, employees, online/social features, payments, alternative landscape mobile layout and deep narrative are future scope |
| Closure | Optional Community Exhibition after eight completed auctions (including withdrawals/losses), six unique discoveries in any one set, and three fulfilled regular requests. Player chooses three discovered entries for a non-saleable replica display; exhibition consumes no owned rare item and awards a signboard, then endless play continues |

Tutorial samples are explicit practice objects, known from the start, saleable at small preset references of 15/25/35 and never counted as catalog discoveries or auction finds. They do count as ordinary sales for customer/pricing tutorial steps. Paid lots add discoveries when post-win full inspection verifies identity. Three ordinary shop sessions unlock listing-profile choice. Customers, discovery and auction participation supply the exhibition path; no signature item is mandatory.

**Auction edge rules:** Seating order is player, Mei, Arif, Suri. Opening opportunities proceed in that order until one actor accepts 40; later turns rotate through active nonleaders. A raise must be one listed step and stay inside the bidder's frozen limit. Passing is permanent and always free for a nonleader. Equal limits create no equal bid: first accepted legal raise is authoritative, then the next actor must raise or pass. Player ceiling edits may only tighten a not-yet-binding ceiling; ceiling increases require leaving and entering a different lot, so there is no changing risk cap mid-auction. Every completed result, including a player walking away, is a durable resolved listing that cannot be farmed for participation counters by reopening it. Completing all three listed lots refreshes the board with three newly persisted listings. There is no wall-clock refresh or paid reroll.

**MVP customer defaults:** Lina prefers homewares, Tomas tools, and Bea paper/hobbies. They are regulars, not additional auction rivals. Each encounter draws a budget independently from {60, 100, 160, 300}, equal weights; preference gives 1.15 willingness, neutral 1.00, dislike 0.85. Category browsers choose one announced category; bargain buyer uses 0.85 and can offer the dealer floor without the retail fee through an explicitly labeled dealer action. A customer considers one player-chosen safe listing at a time; one counteroffer maximum. After selling, declining or choosing Skip visitor, the next encounter starts. A skipped visitor is not a failure or relationship penalty. Optional request offers are rounded neutral reference values for a named known family/condition, with the 8% fee displayed. No request requires undiscovered signature objects; request targets are selected from already discovered categories. Requests persist until delivered or freely replaced. Preference-match counters and request-completion counters are separate.

**Request schema and generation:** `Request {request_id, regular_id, target_definition_id, minimum_condition_bp, displayed_gross_offer, status, completed_transaction_id?}`. After three confirmed preference-match sales to a regular, generate one request for that regular. Maximum one active request per regular. Choose a specific already discovered definition in a preferred category, preferably one currently owned; exclude signature objects for mandatory progression. Default minimum condition is good (8500); offer is `round_half_up(target_catalog_value * 8500 / 10000)`. An excellent copy qualifies but receives the same stated offer; the player may choose ordinary resale instead. Deliver consumes exactly one owned matching definition whose condition meets the minimum, charges the 8% fee, and increments request completion once. Replace awards nothing and generates a new persisted request from eligible discoveries; opening it repeatedly cannot reroll it. A completed request can be followed by another on the next regular encounter. The exhibition's three completions can involve one or several regulars, so there is no dependence on a rare category draw or three separate relationship tracks.

**Appraisal definition:** Family means the item's ten-item collection/category set in MVP. The taught guide is unlocked by three unique verified items in that set. Family priors are catalog means, independent of the concealed item's value; novice/practiced intervals reflect the prior and observed condition, while verified intervals use the actual known identity. Never center an unknown-identity estimate on secret truth. A full post-win inspection is free and optional in pacing but required to list as an identified object; batch Appraise all does it in one command. Prior estimates are descriptive uncertainty bands, not calibrated confidence intervals until validated.

**Concrete inspection layout:** Four targets are reachable in a text list as well as the scene: exposed object 1 maker mark, exposed object 2 condition, exposed object 3 material/construction, and one covered-container packing label (truthful category hint only, no identity/rarity guarantee). All four are available initially; select at most two distinct targets. Each costs one action, has no money cost, and persists its exact fact. Returning to a selected target costs nothing. A guide may replace target 3's broad material reading with its family/mark interpretation; it does not add a third action. A covered object's identity remains unknown until opening. In later production, vary which exposed object receives which technique using authored layouts with the same action budget.

**NPC estimate implementation:** NPCs use doorway observations only. The player's close-inspection notebook is private and never changes the frozen rival ceiling. For each of six slots, use a documented category prior `58.7 * 0.8225` when unidentified; a visibly identified item uses known catalog base value and visible condition or the mean condition if unknown. Mei interprets exposed tools' condition correctly; Arif uses the mean unless an explicit condition fact is visible; Suri applies at most 1.15 willingness to a visibly matching category only. Sum the estimates, apply a seeded -15%/0%/+15% interpretation offset from the NPC stream (one draw per bidder), convert to estimated net via 0.92, apply the stated desired margin, then floor and cap by independent budget. This is an authored prior, not a lookup of hidden values. Draw budgets/offsets at listing generation and freeze resulting ceilings before the player starts bidding. NPC signals reveal profession/preference and actual action, never the private ceiling or a jackpot signal.

**Meaning of recovery:** The protected reserve plus one sorting job always restores eligibility for an opening bid after the worst permitted cash depletion. This does not reimburse a loss. Replacing an entire 250-coin overpayment can require up to seven commissions if sale proceeds are ignored; the stated two-job playtest target refers to reentering useful trade after a typical loss, not a guarantee of full restitution. Knowledge, kits, guides and requests persist.

Eligibility alone does not guarantee a competitive ceiling: the 80-coin minimum NPC wallet can crowd out a player with only a 40-coin ceiling. From a 40-coin wallet, three commissions produce 160 coins and a 120-coin legal ceiling, enough to contest some but not all auctions. Recovery UI should show both the minimum to enter (80 wallet) and a suggested cautious working balance (160), with shop liquidation alongside commissions. Test the number of actions required to regain credible auction choices; if this feels like a chore, retune independent NPC budget weights or the commission payout before adding content. Never advertise a guaranteed winning lot or full reimbursement.

**Separate clocks and counters:** `auction_schedule_slot` advances only when a listing is resolved; `shop_session_index` advances after a customer-queue receipt; `milestone_counters` record unique committed events. Customer budgets and any future request variants are materialized before display, so revisiting a screen is not a reroll. A empty-stock shop session is allowed and advances Regular trade, but it awards no sales, discoveries or request credit. This permits a recovery path without rewarding a money exploit. Opening a receipt repeatedly cannot increment any counter.

Assign a unique monotonic `listing_sequence` when each of the three board listings is generated, before displaying it. The generation seed includes that sequence, listing ID and profile ID. Persist all three lots together before opening the board. Resolution counters are separate from generation identity, so concurrent board lots cannot share a seed or be regenerated by reordering their resolution.

**Cost basis and record limits:** Allocate a winning bid across its six items in proportion to fully revealed reference values. Compute `raw_i = bid * reference_i / sum(reference)`, floor each allocation, then distribute the remaining coins by largest fractional remainder, breaking ties by stable instance ID. Allocations must sum to the exact paid bid. This is bookkeeping only; it does not change resale value. Original items on display still occupy stock slots; replicas and decorative props do not. Keep the most recent 1,000 detailed receipts and aggregate older sales by item definition while retaining discoveries/counters. Keep 128 recent command results for convenient retries; older stale commands fail the expected-revision check. Persist resolved listing IDs and unique progression event keys until no active command can refer to them, then compact with a validated high-water schedule marker. Never prune a key needed by an unresolved transaction.

### Complete seed catalog for authoring

The table specifies all 40 initial identities. Column letters map to frequency, base value and category-specific values below. Every identity needs two truthful visible clues and a distinctive 24-pixel silhouette plus inspect art. Fictional maker marks must be authored consistently; real branding is prohibited. Conditions are the common shared draw. No object gets a price boost just for its tier label.

| Slot | Homewares / Everyday Table set | Tools / Useful Workshop set | Paper / Paper Trail set | Hobbies / Small Pastimes set |
|---|---|---|---|---|
| A | Tin measuring cup | Wooden sanding block | Pocket address notebook | Wooden spinning top |
| B | Stamped kitchen tray | Steel square | Framed tram print | Painted skipping rope |
| C | Folding stool | Hand clamp | Linen-bound sketchbook | Folding game board |
| D | Enamel kettle | Brass plumb bob | Pressed-flower folio | Cloth beanbag set |
| E | Weave basket | Tested-safe desk fan | Hand-printed calendar | Tin model boat |
| F | Glazed planter | Manual bench vise | Illustrated harbor atlas | Brass puzzle ring |
| G | Ceramic serving bowl | Wooden tool chest | Typesetter's sample booklet | Carved tile game set |
| H | Lattice tea cabinet | Repairer's hand drill | Small print portfolio | Mechanical music box |
| I | Studio stoneware pitcher | Precision drafting kit | Numbered local lino print | Handbuilt model tram |
| J | Harbor potter's lidded jar | Retired signmaker's tool case | Founding ferry route folio | Neighborhood festival puppet |

A-F are common with respective base values 15/25/30/35/50/55. G-H are uncommon: homewares 75/75, tools 70/80, paper 65/85, hobbies 70/80. I is rare at 150; J signature at 260 in each category. Within a category/tier draw uniformly among its definitions. Each category has the same conditional mean at each tier; the 58.7 model base mean therefore matches this seed catalog before composition restrictions and rounding. Values are game coins and do not represent antique valuations. Signature histories are fictional neighborhood craft stories, not promises of historical authenticity.

For every item author: a material clue, a maker/family clue, one condition clue and, where applicable, a matching-set cue. Common templates: stamped metal reveals folded seam and maker ring; paper reveals binding/printing technique and fictional imprint; wood reveals joinery and maker cartouche; ceramic reveals glaze and foot stamp; mechanical goods reveal casing mark and a tested-safe/parts state. Bind each clue to actual item facts. Do not infer a maker name from a random text fragment. A global text template can describe a material, but each signature object gets unique authored lore and a reliable distinguishing detail.

Three listing profiles share tier and condition weights: household clearance guarantees at least three homewares; workshop clearance at least three tools; hobby-room clearance at least three paper/hobby items. Construct three required category slots and three shared-pool slots instead of rerolling for high value. Categories have overlapping distributions, so these themes change clues and buyer match. They can still create composition-dependent variance; recalculate expectations and verify no theme becomes a universally superior cash choice. The broad distribution should remain comparable, not falsely claimed identical after constraints.

Neutral kit's 12 placeable definitions: open shelf, glass-front cabinet, low display table, workbench prop, checkout counter, stool, pegboard, signboard, planter, wall clock, floor mat, hanging lamp. Chinese timber kit's 12: timber shelf, lattice cabinet, tea display table, lacquer counter, bench, lattice window panel, hanging signboard, ceramic planter, lantern, folding screen, tiled awning segment and timber door frame. Cosmetic checkout variants replace the fixed functional counter; decorative doors/awnings attach to designated wall sockets and do not create new routes. Floor/wall finish choices are palette swaps, not extra definitions. Start with basic neutral shelf/counter; earn the other neutral definitions through three sessions, and the Chinese kit through six discoveries in one set. Earned kit definitions are permanently available; placing owned/unlocked props is free, while buying optional duplicate props uses the cosmetic price bands. Stock-rack upgrades are separate economic records so moving a decorative shelf cannot change capacity or duplicate an upgrade.

### Implementation order and deferred decisions

Implement one complete loop with the exact six-item example first, then load the seed catalog and randomized observations. Freeze the following before the vertical slice: four authored inspection-target definitions per lot layout; mapping of hidden containers to visible truthful hints; customer request generation rules; engine device support; semantic accessibility capabilities. These need prototype validation, not user approval to draft them. The schema, rules and targets here provide defaults; production art, translations, sound files, legal identity and title clearance remain production inputs. Do not invent them or claim they are already complete.


## Gameplay, content and economy specification

All numerical values in this chapter are initial design hypotheses, not measured player outcomes. Use integer coins and basis points for implementation. Balance changes must preserve the information rules, optional recovery, and absence of real-time pressure. This is a single-player economy, so understandable outcomes take priority over exploit-proof scarcity.

### Pillars and differentiating promise

1. **Read objects, not a price label.** Auctions begin at a venue-wide flat opening bid. Observation, condition assessment, and the player's judgment influence a bid ceiling; a high opening number cannot identify a jackpot.
2. **Build a shop with a point of view.** Arrange useful, expressive furniture; curate collections; learn regular customers' tastes. Specialization changes decisions and requests, not a universal profit multiplier.
3. **Progress through new ways to trade.** New auction formats, provenance research, careful restoration, and customer relationships unlock horizontally. Every district retains overlapping item values and remains useful.
4. **A short visit is complete play.** One lot, one shop return, and a satisfying set of sales fit approximately five minutes. No expiring stock, offline theft, energy refill, timing pin, streak punishment, or compulsory daily visit.

The game's pleasure comes from interpreting imperfect evidence, revealing a coherent collection, negotiating one good sale, and making the shop feel personal. Money supports those activities; it is not the sole completion meter. It deliberately avoids copying Storage Hunter's timing minigame, opening-price jackpot detector, mutations, wearable luck bonuses, net-worth area gates, assets, map layout, or branding.

### Five-minute visit

| Segment | Approximate active time | Player decision | Completion result |
|---|---:|---|---|
| Shop preparation | 30 seconds | Review six queued customers, stock capacity, cash, and chosen auction listing | A visible safe bid ceiling and free stock slots |
| Inspection | 50 seconds | Choose two close inspections from the revealed doorway scene; record a ceiling | Evidence notebook persists |
| Auction | 60 seconds | Raise, pass, or withdraw while reading three NPCs | Win a lot or leave without a charge |
| Reveal and transport | 40 seconds | Reveal six items; batch load them into the van | All owned items move together without carrying chores |
| Shop session | 100 seconds | Set prices, accept/counter offers, place one object, or choose dealer liquidation | Coins, collection records, and a shop improvement |
| Save and exit | 20 seconds | View receipt and choose stop or another visit | Safe save and explicit session end |

Times are usability targets. There are no timers; reading slowly never reduces rewards. The player may run a shop-only session, inspect without bidding, or stop at any screen. A customer queue is a set of simulated encounters, not a queue that drains while the player is away.

### First session and state flow

Start with 360 coins, a van holding one six-item lot, a shop with 18 sale-item slots, six shelf slots, a counter, and a free cosmetic furniture kit. Three clearly marked starter items teach pricing and do not count toward collection discovery. Tutorials are dismissible and replayable from Help.

```text
SHOP_READY -> SELECT_LISTING -> DOORWAY_INSPECTION -> BID_PREVIEW
           -> AUCTION_TURN -> [RAISE -> NPC_ROUND -> AUCTION_TURN]*
           -> WIN_REVEAL -> BATCH_LOAD -> SHOP_CUSTOMERS -> RECEIPT -> SHOP_READY
           -> WITHDRAW / LOSE -> NO_CHARGE_RECEIPT -> SHOP_READY

Any stable screen -> SAVE_AND_EXIT -> restore the same committed screen
Winning payment and transfer occur as one transaction before WIN_REVEAL.
```

If fewer than six stock slots are free, the listing screen offers shop sales, dealer liquidation, or a free storage-sort action first. It never sells the player's stock automatically. A collection record survives selling its physical object. Decorative furniture uses a separate placement budget so cosmetic building does not consume sale-stock capacity.

### Inspection and information contract

Each standard lot has exactly six items in the MVP. A generated doorway scene shows three exposed item shapes and three covered containers. The listing gives an owner's contextual description and broad categories, such as “a repair enthusiast's household tools,” with no stated estimated total value. The category description must be true for at least three items, and uses shared rarity and condition weights with comparable overlapping value distributions, as defined in the seed catalog.

Before bidding, the player gets two close inspections, chosen from four highlighted targets. There is no tap-speed requirement. Inspection targets can reveal a maker mark, material, condition cue, or matching-set clue. All four targets are available; two distinct inspections may be selected, and their facts remain readable afterward in the notebook. Hover is never required. A loupe is an accessible labeled action, not a precision drag.

Information has four explicit levels: silhouette; visible fact; catalog family; verified identity. Facts are not random dishonest text. A surface scratch means cosmetic wear; a frayed power cable means an electrical item needs repair; a maker stamp maps to a catalog family. Covered objects may have no useful clue. An inexpensive item may look ornate, and a valuable item may look plain, but the game must supply discoverable reasons instead of arbitrary reversals.

The notebook shows a value interval only when the player has learned the relevant catalog family. An unidentified ceramic might show “material: glazed ceramic; maker unknown” rather than a fabricated precise estimate. Verified identity plus condition assessment produces an interval centered on the item's reference value. Before purchase, the notebook cannot look up a concealed item's identity or total the lot's true value.

**Anti-telegraph invariant:** standard opening bid is always 40 coins. The listing's fee, NPC cash budgets, doorway animation, sound, auction length, camera framing, and selection-card decoration do not read concealed item values or rarity. Listing names and categories describe content without segregating expensive pools. Within each auction format, opening price is identical. Future bundled formats may use a different published flat fee because of quantity or rules, not hidden value.

A final bid may correlate with observable evidence. That is a result of the bidding game, not a hidden valuation service. NPCs must not access authoritative `reference_value` for unseen objects. Logs and debug overlays may expose it only in development builds.

### Auction mechanics

Standard auction rules: three NPCs, flat opening of 40, raise buttons of +10/+20/+40, no entry fee, payment only on winning, and no time limit. The opening screen asks “Bid 40” or “Leave.” If the player leaves, the simulation can resolve the NPC auction offscreen without altering cash. After a bid, each other active bidder gets one turn in a fixed rotating seat order. An NPC either raises one allowed step or drops out. The current leader does not bid against themselves. Dropping out is permanent for the current lot and is available only to a nonleader. While leading, the player cannot withdraw or retract an accepted binding bid.

While leading, the player can select “Hold my bid” and wait for the NPC round; they cannot secretly retract it. When every non-leading bidder has dropped out, the leader wins. A player who is out never buys the lot. The current bid, leader name, cash remaining on win, and exit status are always visible. NPC character animation never blocks the next interaction; a fast-play setting skips it.

The player sets an optional ceiling before bidding. Default maximum is `min(250, wallet - 40)` with a minimum reserve of 40 coins, explicitly displayed. If the wallet is below 80, standard auctions are unavailable and the free sorting job is offered. A player can lower the ceiling before bidding. The reserve and 250-coin hard cap cannot be disabled in MVP; ceiling increases during an auction are prohibited. Raise buttons above the chosen ceiling are disabled with a readable reason. Ceiling checks use the full committed bid, not only the increment.

NPC decisions use the same public observations as the player plus a declared taste bias. They may interpret facts with different accuracy; this creates personalities without providing hidden X-ray knowledge. For each lot, assign an independent wallet budget from the same distribution regardless of content: 80/120/160/200 coins with equal probability. Their ceiling is the lesser of their wallet and their estimate of recoverable proceeds after their desired margin. Estimate hidden objects using a documented prior derived from the lot pool, never their actual draw. At least one seeded interpretation offset prevents all three from sharing one ceiling. Their budgets and estimated ceilings are frozen at auction start; they do not rubber-band upward because the player is rich.

| NPC | Visible behavior | Estimate rule | Desired margin | Raise preference | Counterplay |
|---|---|---|---:|---|---|
| Mei, careful repairer | Examines wear cues and says which category she wants | Values repairable tools accurately; discounts unverified provenance | 35% | +10 | Good condition recognition beats her on decorative lots |
| Arif, shop supplier | Wants usable stock and drops out cleanly | Uses category-average values and condition cues | 30% | +20 | Sparse but distinctive collectibles are less attractive to him |
| Suri, set collector | Reacts to visible matching pieces | Adds up to 15% willingness for her announced set category | 25% | +10, occasionally +40 within ceiling | Compete when another category is exposed; do not assume a flourish proves rarity |

The identities are original and provisional. Do not assign dishonest or foolish behavior to an ethnicity. Named NPC traits are professions and preferences. Suri's extra willingness is her private demand, not a multiplier on the item's universal resale value.

```text
npc_ceiling = min(wallet_budget,
    floor(public_estimated_proceeds * (10000 - desired_margin_bp) / 10000))
on_turn(npc):
    valid_steps = steps where current_bid + step <= npc_ceiling
    if valid_steps empty: drop_out(npc)
    else: raise(chosen_step_from_personality(valid_steps))
after_round():
    if only leader remains: commit_winner_payment_and_lot_transfer()
```

The no-leader starting state resolves to the first NPC willing to bid 40 if the player does not open. A player who opens at 40 may win for 40. Maximum total rounds is naturally bounded by finite ceilings; implementation also rejects illegal increments, self-bids, negative wallets, and stale turn actions.

### Treasure generation, rarity and appraisal

Generation is deterministic from a lot seed and catalog version. Draw six items without requiring uniqueness, then reject a draw only for impossible scene composition or physical size. Do not reroll because the player previously lost, paid highly, has a luck accessory, or uses a premium purchase. Generation occurs when the listing is created, before inspection or bids. Reloading preserves the lot and auction RNG state.

| Content frequency | Weight per slot | Example base-value band | Meaning |
|---|---:|---:|---|
| Common | 65% | 15–55 | Everyday usable goods with many identities |
| Uncommon | 25% | 45–110 | Distinctive craft, specialist tools, or set pieces |
| Rare | 8% | 90–220 | Less frequently found catalog identities |
| Signature | 2% | 160–350 | A small set of named objects with researched fictional stories |

Bands overlap deliberately. Rarity is a discovery frequency, never a price multiplier. No onyx, rainbow, shiny, mutation chain, or 175x tier. A useful common object in excellent condition may sell better than a damaged rare one. Signature objects need distinct art, a description, a reliable identifying clue, and at least one meaningful buyer interest; recolors do not count as separate rare content.

Initial condition draw: worn 20%, good 65%, excellent 15%. These are discrete MVP factors of 6000, 8500, and 10000 basis points. “Worn” does not imply unsafe or functional electrical goods; unsafe examples are outside the MVP ordinary-goods pool. Future unsafe goods must be tagged and restored or sold as parts. Provenance defaults to 10000. A verified named fictional provenance can use 11500, with authored evidence and no random premium. There is no provenance bonus in the MVP generation pool.

```text
reference_value = max(1, round_half_up(catalog_value * condition_bp * provenance_bp / 100000000))
dealer_offer = round_half_up(reference_value * 5000 / 10000)
sale_net = asking_or_agreed_price - round_half_up(asking_or_agreed_price * 800 / 10000)
```

Round each final money result once, with a shared integer helper. Rarity does not appear in the equation. Reference value is an internal benchmark, not a guaranteed consumer offer. The displayed price recommendation is explicitly an estimate until identity and condition are verified.

Appraisal is a knowledge system. Discovering and verifying three objects in a catalog family unlocks a maker-mark guide for that family. Guides add inspection options or tighten intervals; they do not change spawned items. Novice intervals use ±35% of the family prior, practiced ±20%, and verified identity/condition ±10% of reference value. Where information remains insufficient, show an unknown, not misleading precision. Catalog-guide accuracy always represents correct knowledge; independent visible condition uncertainty may still remain.

After purchase, a free full inspection verifies ordinary identity and condition. Provenance research is optional future scope; it takes a player-chosen action, no real-world countdown. An item that lacks provenance never becomes worthless because research fails.

### Collection index and progression

The index records item identity, first discovery, verified facts, sale history, and collection set membership. Unknown entries show category and a readable outline. Color is supplemented by rarity text and symbols; item descriptions are available as plain text. Index completion counts unique identities, not every condition/price combination. Selling an item cannot erase discovery. Players may display a previously found replica decoration after completing its set, clearly marked as a replica and never saleable.

Progress unlocks by demonstrated actions. Counters include successful fair sales, unique verified finds, customer requests fulfilled, and completed restoration actions. They do not require a cumulative net worth. All unlocks are permanent and usable after a loss.

| Milestone | Initial criterion | New decision | Scope |
|---|---|---|---|
| Regular trade | Finish 3 shop sessions, including a shop-only session if desired | Choose among household, workshop, and hobby listings with equal value distributions | MVP |
| Catalog guides | Verify 3 unique objects in a family | Spend an inspection on a maker mark instead of visible condition | MVP |
| Customer relationships | Fulfil 3 preference matches for a regular | Reserve a shelf for that regular's next non-expiring request | MVP |
| Curator collection | Discover 6 identities in a 10-item set | Free themed decorative kit and display replica | MVP |
| Restoration bench | Sell 12 items and inspect 4 worn pieces | Keep, restore, or sell as parts | Future |
| Specialist license | Fulfil 5 requests across 2 categories | Choose a workshop/shop focus that changes requests and tool access | Future |
| Provenance desk | Verify 20 identities | Research an authored provenance trail before selecting a buyer | Future |
| Alternative auctions | Complete 8 standard auctions without needing to win them all | Sealed offers and split lots with explicit rules | Future |

Future district unlocks are story introductions or optional travel routes, never a ladder of rising minimum values. A neighborhood may change categories, clue types, and bidder mix while keeping economy distributions overlapping. There is no ending forced by maximum net worth; a short authored “community exhibition” goal provides closure alongside ongoing collection and building.

### Shop, customers and price negotiation

The MVP shop is a 6 by 8 tile interior. Keep a two-tile route from entrance to counter and mark invalid placements visually and in text. Furniture can be rotated in 90-degree steps, moved, undone, and restored from a layout preset. Item placement uses snap-to-slot controls; drag is optional. A decorate/sell toggle prevents accidental sales while arranging the store. New furniture has no secret luck bonus and no required comfort meter.

Start with two complete kits: a bright reclaimed-wood corner shop and a Chinese-traditional-inspired neighborhood shop. The latter includes warm timber shelving, cream plaster walls, red lacquer accents, lattice cabinet doors, a hanging lantern, and a courtyard-window backdrop. Offer object-level mixing, not a single locked skin. Research and name details accurately; avoid claiming a specific historical dynasty or combining unrelated Asian motifs without references. Decorative Chinese text needs a fluent review, or use no decorative text. Chinese-inspired furniture is not the expensive or mystical rarity class. No gameplay benefit is tied to cultural theme.

Each shop session generates six customer encounters. Three regulars use saved preferences, two are category browsers, and one is a general bargain buyer. A shop-only session generates a fresh six-encounter queue immediately after its prior receipt. Customers do not visit during wall-clock absence and never consume objects automatically. Unsold stock remains until the player sells it.

A customer has preferred categories and tags, a spend budget, and a taste factor of 8500/10000/11500 for dislike/neutral/like. A customer's reserve is `min(spend_budget, round(reference_value * taste_bp / 10000))`. Budgets are drawn once at encounter creation and are independent of the player's asking prices. The UI reveals preference and a broad budget band. The game checks affordability only after a player-selected offer, keeping uncertain negotiation meaningful.

Every visitor considers a player-chosen safe item if stock exists. The fixed six-encounter mix supplies varied preferences; it does not guarantee a sale, adequate budget or matching preference. Reservations are fixed independently of asking price. This is a usability rule, disclosed in development documentation, not a promise that all prices sell. A general buyer guarantees a dealer-floor offer for any safe tradable object, giving the player an accessible route out of unwanted inventory.

The price editor has explicit coin buttons and text-entry alternatives. Default asking price is the notebook midpoint rounded to five coins. The player can increase or decrease by five, accept the recommendation, or select a customer-specific match. If ask is at or below reserve, the customer accepts. Otherwise the customer makes one counteroffer equal to reserve, rounded down to five except values under five. The player accepts or shelves the item; no repeated grinding dialogue, random failure roll, or relationship penalty for declining. The counteroffer may reveal information about demand, but does not verify catalog identity.

All shop sales visibly deduct an 8% handling/packing fee in the receipt. This is a game economic sink, not a real transaction fee. There is no surprise rent, salary, stock spoilage, vehicle fuel bill, or repair charge merely for visiting a listing. Dealer liquidation is instant and pays 50% reference value with no additional handling fee; its panel shows the exact proceeds before confirmation. Players can use an item's verified value without memorizing arithmetic.

Regular relationships award dialogue, decorating choices, and non-expiring requests. They cannot increase an item's universal reference value. A request names a family, condition minimum, and an offered coin amount before acceptance. It does not consume an item until the player confirms delivery. Fulfillment coins use the same 8% fee rule; any authored bonus must be included in the displayed offer and balancing sheet.

### Sample economic calibration

The following table illustrates one exact six-item lot, not a promised average. There is no signature object or provenance bonus in this example.

| Object | Frequency class | Base coins | Condition bp | Reference coins | Dealer coins |
|---|---|---:|---:|---:|---:|
| Enamel kettle | Common | 35 | 8500 | 30 | 15 |
| Folding stool | Common | 30 | 6000 | 18 | 9 |
| Desk fan, tested safe | Common | 50 | 8500 | 43 | 22 |
| Repairer's hand drill | Uncommon | 80 | 8500 | 68 | 34 |
| Ceramic serving bowl | Uncommon | 75 | 10000 | 75 | 38 |
| Framed tram print | Common | 25 | 8500 | 21 | 11 |
| **Total** | | **295** | | **255** | **129** |

At a 100-coin winning bid, selling those objects for 255 gross yields 235 net if the fee is calculated on that aggregate; per-sale rounding yields 236 for this example. Actual profit is 136 before optional upgrades. Liquidating the entire lot yields a 29-coin gain. At a 170-coin bid, actual retail profit is 66, while liquidation loses 41. Retail sales are a player opportunity, not guaranteed immediately.

Initial pool design uses approximate class mean base values of 35/75/150/260. Weighted mean per slot is `0.65*35 + 0.25*75 + 0.08*150 + 0.02*260 = 58.7`. Six slots have expected base total 352.2. Mean condition factor is `0.20*0.60 + 0.65*0.85 + 0.15*1.00 = 0.8225`, giving approximate reference total 289.68 before rounding. These expectations assume independent class/condition draws and no provenance bonus; authored pool restrictions require recalculating them. Expected dealer recovery is approximately 145, not a minimum guarantee.

| Scenario, assumed retail gross | Winning bid | Net sales, aggregate illustration | Lot profit | Intended interpretation |
|---|---:|---:|---:|---|
| Modest lot, 160 | 80 | 147 | +67 | A careful ordinary win is useful |
| Typical model, 290 | 140 | 267 | +127 | Room to buy decor or save |
| Overbid, 160 | 200 | 147 | -53 | Visible, recoverable judgment loss |
| Exceptional find, 500 | 180 | 460 | +280 | Exciting discovery without a multiplier |

Use per-sale rounding in actual simulation. “Typical” in the table means the stated mathematical model, not tested median behavior. Bidder beliefs can drive unusually expensive auctions; the player must always be able to withdraw and shop instead. Tune NPC budgets and desired margins after simulation to avoid all lots clearing at 40 or all useful decisions being crowded out.

| Sink or capacity | MVP initial price/default | Reason |
|---|---:|---|
| First extra six-item stock rack | 120 coins | Stock-flow choice, not discovery gate |
| Second extra rack | 180 coins | Supports curation; max stock 30 |
| Small decorative object | 25–50 coins | Frequent expression purchase |
| Large decorative furniture | 80–140 coins | Optional medium goal |
| Auction payment | Actual bid | Primary sink into fresh content |
| Handling fee | 8% of accepted price | Makes negotiation and matching matter |
| Sorting job | +40 coins | Guaranteed recovery source, no loot or rare rolls |

The free sorting job is repeatable with no real-world cooldown. It is a brief four-object classification task that can be completed through large labeled choices or skipped for the same 40 coins in accessibility settings. It does not increment auction, catalog, or collection milestones. It gives a reliable path to trade after bad judgment without lending, bankruptcy resets, ad viewing, or premium currency. A receipt openly explains the recovery option. Making it optimal for collection play would indicate auction balance or enjoyment needs repair.

Coins cannot become negative. Auctions cannot consume money before winning. A loss does not remove earned knowledge, rooms, furniture, customer relationships, or unlocked formats. Dealer liquidation and sorting jobs remain available. Post-win refunds are outside MVP scope. Do not secretly improve subsequent rarity after a loss.

### Optional restoration and specialization

These systems are future scope because six-item reveal, appraisal, auction, and pricing must first be fun. Restoration is a choice with a visible cost and guaranteed condition change when the prerequisites are met. No touch precision or failure RNG. Example: a worn stool worth 18 may become good, worth 26, for 5 coins and one bench action. At neutral retail demand its incremental net is approximately 7, yielding approximately 2 extra coins; the player may instead sell it immediately. A rare item may have a larger useful improvement, but tool/material costs use authored repair classes and bounded margins.

```text
expected_restore_gain = estimated_net_after - estimated_net_before - material_cost
allow_restore when material_cost <= wallet and item.repair_class supported
commit material_payment + new_condition + restoration_record atomically
```

The UI shows interval-based gain until appraisal is sufficient; it never guarantees an unknowable sale price. Restoration cannot create items, provenance, or rarity. Each item has one restoration step in the initial expansion. Electrical repair requires a “tested safe” flag before ordinary resale; otherwise sell as parts with clear description.

Choose one of three freely changeable focuses at the specialist milestone: practical repair, homewares curation, or paper-and-story collecting. Focus unlocks relevant request types, a tool, and layout props. It never penalizes off-focus sales or alters hidden loot weights. Switching is free outside an active auction. Shared content means no irreversible class-selection regret.

### Content schemas and sample configuration

Keep stable IDs separate from localized display names. Item definitions belong in versioned data files; instances belong in save data. Authoring tools validate that every definition has a sellable/parts policy, identification clue, accessible description, image provenance, and category. Theme furniture is a separate definition type and is never treated as auction loot unless explicitly authored as a saleable antique.

```json
{
  "economy_version": 1,
  "currency": "coins",
  "starting_coins": 360,
  "standard_lot_size": 6,
  "standard_opening_bid": 40,
  "bid_steps": [10, 20, 40],
  "default_bid_ceiling": 250,
  "cash_reserve": 40,
  "handling_fee_bp": 800,
  "dealer_rate_bp": 5000,
  "sorting_job_reward": 40,
  "rarity_weights": {"common": 65, "uncommon": 25, "rare": 8, "signature": 2},
  "condition_weights": {"6000": 20, "8500": 65, "10000": 15},
  "item": {
    "id": "homewares.enamel_kettle_01",
    "name_key": "item.enamel_kettle.name",
    "description_key": "item.enamel_kettle.description",
    "category": "homewares",
    "tags": ["practical", "enamel", "tea"],
    "rarity": "common",
    "catalog_value": 35,
    "collection_family": "everyday_table",
    "repair_class": "none",
    "safety_class": "ordinary",
    "clue_ids": ["enamel_material", "maker_ring_01"],
    "sprite_id": "items/enamel_kettle_01",
    "asset_manifest_id": "original.kettle.001"
  },
  "instance": {
    "instance_id": "persistent-uuid",
    "definition_id": "homewares.enamel_kettle_01",
    "condition_bp": 8500,
    "provenance_bp": 10000,
    "provenance_status": "none",
    "inspection_flags": ["material_seen"],
    "known_fact_ids": ["enamel_material"],
    "location": "lot:lot_000001",
    "restoration_state": "untouched",
    "asking_price": null,
    "sold": false
  }
}
```

`null` asking price means not listed. Examples omit snapshot fields for readability; generated instances must also contain catalog_value_snapshot and allocated cost as required by the architecture contract. Instance location must be exactly one of lot, van, shop-stock, shelf-slot, display, or sold-ledger; no simultaneous duplication. Sold-ledger entries keep a transaction ID and receipt, with active inventory ownership removed. Keep condition and provenance separate from known facts so appraisal can never mutate economic reality.

```text
generate_lot(seed, catalog_version):
    stream = derive_rng(seed, "loot")
    six_defs = weighted_draw_from_shared_catalog(stream, no_value_zone_filter)
    six_instances = attach_condition_and_identity(six_defs, stream)
    public_scene = build_scene_from_authored_visibility(six_instances)
    npc_budgets = draw_from_independent_stream(seed, "npc_budget")
    persist_lot_before_listing(public_scene, instances, budgets)

complete_sale(item, encounter, agreed_price, transaction_id):
    reject if item not owned, already sold, or transaction_id already committed
    reject if agreed_price exceeds immutable encounter reservation_price
    fee = round_half_up(agreed_price * 800 / 10000)
    atomically remove_inventory, credit_wallet(agreed_price-fee), add_receipt,
        update_collection_and_customer_relationship, record_transaction_id
```

### Balance and system acceptance checks

Before locking content, simulate at least 100,000 lots for each economy version using random, conservative-clue, informed-clue, and reckless bidding policies. Record observed distributions, not only means: opening-win frequency, bid distribution, retail/dealer profits, 10th/50th/90th percentile wallet after 20 sessions, withdrawal frequency, unsold stock, and recovery-job use. Include tests where the player never wins an auction, always refuses a counteroffer, or only runs shop sessions. The simulation is a balancing instrument, not proof of fun.

Initial targets for playtest revision: conservative/informed policy should usually avoid sustained cash collapse; knowing clues should improve median realized profit compared with random bids; collection variety should appear without requiring signature loot; the median negative-profit lot under the conservative policy should lose at most 80 coins, recoverable in two sorting jobs; extreme overbids may take more and must never erase progression; every five-minute test should contain a meaningful inspect, auction, price, or placement decision. Actual numerical profit targets remain provisional until content and customer queues are simulated.

Invariant tests: opening bid is identical across all standard lots; rarity does not multiply value; NPC hidden-item estimates cannot access instance values; NPC budgets are independent of loot stream; relaunch cannot reroll content; winning transfers six items and charges exactly once; withdraw charges zero; sell removes exactly one item and credits once; zero wallet can recover; permanent unlocks survive a loss; theme props cannot affect luck; no customer is consumed by wall-clock absence; no ordinary sale can include an unsafe electrical item. A debug statistical test should compare opening prices across value deciles and fail any variation, while an architecture test verifies that public observation DTOs exclude authoritative concealed value.





## Technical architecture and implementation contract

### Engine decision

Use **Godot 4.7.2 Standard, typed GDScript, Compatibility renderer** as the initial reproducible baseline, with the matching export templates. The official archive lists that stable maintenance release; confirm its Android export and required accessibility behavior in a device spike before freezing dependencies. Do not silently upgrade the engine during production. An upgrade is a branch with migration, rendering, export, RNG and save regression checks. This is a design choice, not a performance result. [Godot release archive](https://godotengine.org/download/archive/).

| Candidate | Relevant documented capability | Project-specific assessment |
|---|---|---|
| Godot | Native 2D scenes/UI; Android export; MIT license | Selected for a self-contained 2D game with editable scenes, typed scripts, and no required account/backend. Team learning cost must be measured. |
| Defold | Lua-centered game logic; Android/iOS exports; free engine; custom license allows commercial games but restricts commercialization of its engine/editor | Credible alternative if the team already knows Lua or a measured Godot device spike fails. Do not describe its license as MIT or assume its bundle is smaller without a comparable build. |
| Unity | Mobile publishing and established 2D tooling; Personal eligibility subject to current revenue/funding terms | Appropriate for an existing Unity team. This small offline game does not need Unity-specific services; licensing/dependency administration is additional scope. No assertion that Unity is intrinsically slower. |

Facts above are from [Godot license](https://godotengine.org/license/), [Defold FAQ](https://defold.com/faq/faq/), [Defold license](https://defold.com/license/), and [Unity Personal](https://unity.com/products/unity-personal), checked 2026-10-14. Current Unity Personal eligibility shown by that page is below USD 200,000 revenue/funding in the preceding 12 months; recheck contract applicability before adopting it.

Android is the MVP device target; Windows desktop is a development and keyboard/controller test target. Baseline device acceptance target is Android 9+, 3 GB RAM, ARM64 and compatible OpenGL ES 3 hardware, to be validated before committing the public device list. Use only bundled content and local files. No server, login, online leaderboard, cloud economy, ads SDK, remote config, or internet requirement in MVP. iOS is later scope because export requires macOS and Xcode; this Windows workspace cannot establish iOS acceptance. Android production uses a signed AAB, matching engine templates and current platform SDK requirements. Store signing keys outside the repository. The current Godot instructions specify OpenJDK 17 and Android SDK setup; verify store target requirements at release rather than treating today's SDK number as permanent. [Android export](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html), [iOS export](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_ios.html).

### Modules, ownership, and input

Domain logic owns money, inventory, auctions, customers and progression. Scenes render snapshots and submit commands; they never calculate a second version of the economy. Use typed `RefCounted` domain classes and small scene scripts. Avoid a giant global script. Autoloads: `GameSession` (one current domain snapshot), `SaveService`, `ContentRegistry`, `SettingsService`, `AudioService`. A signal may request presentation updates, but must not award items or money.

All controls map through named actions: `ui_confirm`, `ui_cancel`, `inspect`, `bid_small`, `bid_medium`, `bid_large`, `withdraw`, `rotate_furniture`, `open_index`. Touch and keyboard/controller call the same commands. Disable key-repeat/double-tap while a command is being committed. Bindings are remappable on desktop. Device Back closes the top modal, then offers save-and-exit; it never withdraws or confirms a bid accidentally. Suspension stops simulation immediately; mobile resume opens a paused summary of the exact saved auction/customer state. NPC decisions use logical turns, not rendering delta time.

World art renders in a 180x320 `SubViewport` with nearest filtering and integer pixel scaling. Accessible text and controls render on a separate responsive UI canvas with nominal 360x640 layout units, not baked into the pixel world. The visual chapter specifies typography and layout. Safe areas inset the UI independently of art framing. Letterbox surplus art space with the palette background, not stretched pixels. Integer scaling is an explicit Godot option; test awkward aspect ratios and large text. Native TalkBack/VoiceOver support requires a semantic bridge/export spike and demonstrated device coverage; do not claim support merely because visible controls have descriptive labels. [Godot multiple resolutions](https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html).

```text
project.godot
scenes/       boot, title, shop, auction, reveal, index, workshop, settings
scripts/
  domain/     auction, valuation, customers, inventory, progression, restoration
  services/   save_service, content_registry, input_router, audio_service
  ui/         screen presenters, focus navigation, accessible labels
content/      items, lot_profiles, bidders, customers, recipes, milestones, furniture
schemas/      content and save JSON specifications, versioned
assets/
  sprites/    objects, shop tiles, characters, UI glyphs
  audio/      sfx, music
  fonts/      licensed originals plus license texts
localization/ translation keys, en source, locale files
tests/        domain, fixtures, migration, export smoke, simulation
tools/        validators, atlas export, deterministic balance runner
docs/         design decisions, release checklist, content provenance
licenses/     engine and third-party notices
build/        generated artifacts; excluded from source control
```

### Data schemas

Use immutable IDs and translation keys, not English display strings as keys. Currency uses nonnegative integer coins. Ratios use integer basis points where 10,000 means 1.0. Round positive rational amounts with `floor((numerator + denominator/2)/denominator)`; do not allow floating-point drift in wallets. Keep JSON integers below 2^53; encode 64-bit seeds, RNG states and monotonically increasing save sequences as decimal/hex strings when necessary. Runtime parsers must reject unexpected types, negative money, missing definitions and oversized collections. Unknown cosmetic fields may be ignored; unknown economic fields require migration or a compatibility error.

| Record | Required fields and validation |
|---|---|
| `ItemDefinition` | `id`, `name_key`, `description_key`, `category`, `tags[]`, `catalog_value >= 1`, `safety_class`, `repair_class`, `rarity`, `sprite_id`, `footprint_cells`, `clue_ids[]`, `restoration_recipe_id?`, `collection_family`, `provenance_rules[]`. Rarity controls generation weight, never a universal price multiplier. |
| `ItemInstance` | `instance_id`, `definition_id`, `condition_bp` in {6000,8500,10000}, `provenance_bp` in {10000,11500}, `provenance_status`, `known_fact_ids[]`, `inspection_flags[]`, `location`, `restoration_state`, `asking_price?`, `catalog_value_snapshot`, `cost_allocation`, `sold`. One owner/location at a time. |
| `LotProfile` | `id`, `theme_tags[]`, `item_count=6`, `rarity_weights={65,25,8,2}`, `condition_weights`, `guarantee_rules[]`, `layout_id`, `public_manifest_key`, `visible_slot_ids[]`, `inspection_rules`. Standard opening always 40; profile does not derive price from hidden contents. |
| `AuctionState` | `lot_id`, materialized item instances/clues, `opening_bid`, `current_bid`, `leader_id?`, `active_bidder_ids[]`, `next_actor_id`, `turn_index`, `player_limit`, `npc_estimates[]`, `npc_limits[]`, `command_history`, `status`, `generator_version`, `content_version`. |
| `Listing` | `listing_id`, `item_instance_id`, `asking_price`, `placed_cell`, `listed_session`, `markdown_history`, `status`. No duplicate listings. |
| `CustomerDefinition` | `id`, `taste_tags`, `taste_bp` by category/tag, `spending_budget_range`, `visit_weight`, `request_rules`. Customer spend and preferences are generated independently from asking price. |
| `CustomerVisit` | `visit_id`, `definition_id`, `spending_budget`, `reservation_by_item`, `selected_listing_id?`, `offer?`, `status`. Materialize reservations before any price edit to prevent re-roll exploits. |
| `Request` | `request_id`, `regular_id`, `target_definition_id`, `minimum_condition_bp`, `displayed_gross_offer`, `status`, `completed_transaction_id?`. Exact matching definition/condition required; one active per regular; offer frozen at generation. |
| `FurnitureDefinition` | `id`, `theme`, `sprite_id`, `footprint_cells`, `rotation_variants`, `placement_rules`, `cost`, `style_tags`. Cosmetic theme must not silently multiply item value. |
| `RecipeDefinition` | `id`, `allowed_categories`, `material_cost`, `target_condition_bp`, `active_steps`, `result_fact_ids`, `preview_delta_rules`. No real-time offline waiting. |
| `MilestoneDefinition` | `id`, `prerequisites[]`, `requirements[]` with counters, `unlocks[]`, `reward`. Counters increment through committed events only. |

Example content, with illustrative values rather than guaranteed tuned balance:

```json
{
  "id": "homewares.enamel_kettle_01",
  "name_key": "item.enamel_kettle.name",
  "description_key": "item.enamel_kettle.description",
  "category": "homewares",
  "tags": ["kitchen", "enamel", "vintage"],
  "catalog_value": 35,
  "safety_class": "ordinary",
  "repair_class": "none",
  "rarity": "common",
  "sprite_id": "items/enamel_kettle_01",
  "footprint_cells": [1, 1],
  "clue_ids": ["enamel_surface", "base_stamp", "lid_fit"],
  "restoration_recipe_id": null,
  "collection_family": "everyday_table",
  "provenance_rules": []
}
```

```json
{
  "config_version": 1,
  "generator_version": 1,
  "standard_opening_bid": 40,
  "bid_steps": [10, 20, 40],
  "initial_player_lot_limit": 250,
  "items_per_lot": 6,
  "rarity_weights": {"common": 65, "uncommon": 25, "rare": 8, "signature": 2},
  "condition_bp": {"worn": 6000, "good": 8500, "excellent": 10000},
  "max_provenance_bp": 11500,
  "handling_fee_bp": 800,
  "dealer_liquidation_bp": 5000,
  "offline_income_enabled": false
}
```

Item-instance example: the enamel kettle in good condition has `reference=round_half_up(35*8500/10000)=30`. Its common label has no numeric effect. A listed price of 30 yields `30-round_half_up(30*800/10000)=28` net proceeds if sold. Display the fee before confirmation.

### Auction and session states

```text
BOOT -> VALIDATE_CONTENT -> LOAD_VALID_SAVE -> TITLE/RESUME
SHOP_IDLE -> SELECT_LOT -> INSPECT -> AUCTION_READY -> AUCTION_TURN
AUCTION_TURN -> [player raises / NPC raises] -> AUCTION_TURN
AUCTION_TURN -> [actor withdraws permanently] -> AUCTION_TURN
AUCTION_TURN -> [one active leader remains] -> RESOLVE
RESOLVE -> [player wins + durable payment/inventory commit] -> REVEAL -> SORT -> SHOP_IDLE
RESOLVE -> [NPC wins or no opening accepted] -> RESULT -> SHOP_IDLE
SHOP_IDLE -> APPRAISE / PLACE / PRICE / RESTORE / DECORATE / SERVE -> SHOP_IDLE
Any interactive state -> PAUSED -> same interactive state
Any commit failure -> RECOVERY_SCREEN -> retry / last valid snapshot
```

At opening, the player may accept 40 or withdraw. NPCs receive their opening opportunities in persisted seating order if the player withdraws. Once there is a leader, only the next active nonleader gets a decision; an explicit raise changes the leader, and withdrawal removes that nonleading actor for this lot. A leader may hold but may not withdraw or retract. There is no countdown. If all other actors withdraw, the leader wins. No seller reserve derived from hidden value; no post-win extra purchase step. Skip/withdraw may advance the schedule as defined in the economy chapter, but reload does not regenerate the same lot.

```text
generate_lot(profile, listing_sequence, listing_id):
  root = SHA256(save_seed || content_version || listing_sequence || listing_id || profile.id)
  loot_rng = independent_rng(root, "loot")
  clue_rng = independent_rng(root, "clues")
  npc_rng = independent_rng(root, "npc")
  items = draw_six_items(profile, loot_rng)
  doorway_clues, private_inspection_facts = derive_separate_truthful_clues(items, profile, clue_rng)
  public_view = PublicAuctionView(doorway_clues) # no hidden IDs/values/private notebook
  npc_estimates = estimate_from_public_clues(public_view, npc_rng)
  npc_limits = personality_budgets(npc_estimates, npc_rng)
  persist_entire_lot(items, doorway_clues, private_inspection_facts, npc_estimates, npc_limits)
  return lot with opening_bid = 40

submit(command_id, expected_revision, action):
  if command_id already committed: return previous result
  reject if expected_revision != current_revision
  candidate = copy(current_state)
  validate action against actor, phase, wallet, limit and inventory
  reduce(candidate, action)                  # no renderer, wall clock or network
  validate candidate invariants
  durable_save(candidate with revision+1 and command_id)
  publish candidate to scenes only after persistence succeeds

resolve_player_win(lot):
  require lot.status == resolving and lot.leader == player
  require wallet >= lot.current_bid
  in ONE candidate snapshot:
    wallet -= lot.current_bid
    transfer every generated instance to staging_inventory
    mark lot resolved and append transaction "win:" + lot.id
    increment eligible milestone counters
  commit candidate once; retries find existing transaction

sell(listing, visit):
  require listing active and item unsold and item belongs to player
  require accepted_offer <= visit.reservation_by_item[listing.item_instance_id]
  require accepted_offer <= visit.spending_budget
  in ONE candidate snapshot:
    remove listing and move item to sold_archive
    wallet += accepted_offer - round(accepted_offer * 800 / 10000)
    mark visit completed; increment sales and collection counters
  commit transaction "sale:" + listing.listing_id + ":" + visit.visit_id
```

NPC code receives a restricted `PublicAuctionView` containing visible silhouette/category/condition clues, current bid, public player actions and known personality parameters. It must not receive hidden item IDs, hidden reference values or the player's future decisions. Inspection reads existing facts; it cannot change items, rarity or NPC ceilings. Root seed streams must be isolated so idle animation RNG cannot change treasure. Materialized generation results are authoritative across loads and engine upgrades: Godot documents that its RNG algorithm is an implementation detail, so a seed alone is insufficient for permanent cross-version compatibility. Pin generator/engine versions in fixtures, persist remaining decisions or state as necessary, and migrate open auctions without re-drawing contents. [Godot RNG API](https://docs.godotengine.org/en/stable/classes/class_randomnumbergenerator.html).

### Local saves, recovery and migration

Save local progression under `user://`, using primitive JSON data only. Never deserialize uploaded resources/scripts. The official IO API supplies file access, but the recovery protocol below is a project requirement, not an engine guarantee. [Godot runtime IO](https://docs.godotengine.org/en/stable/tutorials/io/runtime_file_loading_and_saving.html).

Envelope: `{schema_version, content_version, generator_version, engine_version, save_sequence, payload_bytes_length, payload_sha256, payload_json}`. Hash the exact stored UTF-8 payload bytes, not a reserialized dictionary. SHA-256 detects corruption; it is not anti-cheat, authentication or encryption. No secret stored in the app can make offline saves tamper-proof, and the game does not punish edited personal saves.

Maintain two complete snapshot slots A/B and a previous known-good copy. For each committed action: validate candidate; write the older/inactive slot to a temporary file; flush/close; reopen and validate size, hash and schema; replace only that inactive slot using same-directory rename; reopen final path; then switch the in-memory state and acknowledge the command. Do not rely exclusively on a pointer file. On startup scan both slots and backup and select the highest valid compatible sequence. Preserve the other valid slot until a later successful commit. Flush/rename behavior must pass interruption tests on actual devices; do not claim universal atomicity or fsync durability. A power loss may roll back the newest action to the last valid snapshot, but must never produce half a sale or half an auction debit. A failed save shows a clear retry message and stops economic actions without deleting valid saves.

Persist after lot generation, inspection reveal, bid/withdrawal, win resolution, price edit, sale, restoration, furniture purchase and milestone reward. Debounce cosmetic drag-preview only; confirmed placement commits. Suspension additionally attempts a snapshot, but correctness must not depend on receiving a quit/suspend signal. Settings save separately. No offline income or deadline expiry in MVP; wall-clock changes do not influence money, customers, treasure or progress.

Schema migrations are explicit pure transforms `v1 -> v2 -> ...`, run on a copy with original saved separately. Revalidate all invariants before commit. New content removes old definitions only through tombstones/mappings that preserve an owned item and its stored value basis. Save each item's acquisition content/version or catalog value snapshot, so a balance patch cannot silently devalue existing inventory. An unsupported future save displays a compatibility message and offers export; it must not reset progress. If all copies fail, preserve them for user export and offer an explicit new game after confirmation. Provide user-selected save export/import with hash/type/count validation and a preview of replacement progress. Import is a replacement, not a wallet merge. No broad storage permission merely to save locally.

### Content production and provenance

Author item definitions and balance tables in versioned CSV/JSON; validate and compile them into engine resources at build time. Runtime economy uses one frozen content manifest/hash. Every content record requires: stable ID, translation keys, art/audio reference, gameplay test notes, author/source, license and clearance status. Designer exports a small batch, art supplies approved sprites, review checks clues/value/tags and cultural details, validator checks references and budget ranges, simulation checks distributions, then human playtesting checks readability and usefulness. Do not add 100 items before six complete items feel distinct.

Asset manifest fields: `asset_id`, `relative_path`, `creator`, `source_url_or_contract`, `license_name`, `license_file`, `attribution`, `modifications`, `commercial_use_allowed`, `redistribution_allowed`, `AI_tool_and_terms_if_used`, `review_date`, `approved_by`. Fonts and sounds follow the same process. Never use Storage Hunter screenshots, ripped Roblox models, brand logos, copied item names/lore, or unexplained online images as shipped assets. MIT licensing of the engine does not clear third-party assets. Package engine notices and third-party library notices in an offline Credits/Licenses screen and release archive. Game source/art can remain proprietary; engine licensing does not dictate the game's content license. [Godot license guidance](https://godotengine.org/license/).

### Performance budgets and technical QA

These are acceptance targets requiring measurement, not measured claims: 60 fps on the agreed baseline handset during auction/shop; optional 30 fps battery mode; p95 frame time <= 20 ms and p99 <= 33 ms during a ten-minute representative script; no recurring >100 ms hitch; peak app memory <= 250 MB; cold boot <= 5 seconds; routine durable command <= 150 ms p95; downloaded Android build <= 100 MB. If durable IO fails the budget, preserve correctness and show immediate pending feedback; never acknowledge a purchase early. Measure release builds, multiple thermal states, low free storage, and a 30-minute play session. Select one low and one midrange physical handset before calling the vertical slice accepted.

Budget scenes to <= 12 simultaneously animated customers/characters, <= 200 visible item/furniture sprites, <= 4 sprite atlas pages at 2048x2048 RGBA, and <= 12 concurrent audio voices. Cull offscreen content; pool repeated customer/item presentation nodes only after profiling justifies it. Preload current screen assets and use short asynchronous transitions for large loads. Atlas size, memory and file size need actual measurement; compression and renderer choice must preserve pixel edges. Disable battery-costly ambient animation when paused/backgrounded.

Automated tests target the domain reducer and data validators: opening bid identical for every standard lot; valid public clues; NPC does not read hidden truth; no illegal raises; wallet never negative; duplicate commands award once; listing and sold item uniqueness; deterministic fixed-seed fixtures; fee/valuation rounding; migration preservation; every content reference resolves; probabilities sum correctly; inventory caps produce recovery rather than dropped items. Balance simulation reports distribution and tails across many seeds and several policies, rather than checking only one lucky playthrough.

Fault tests interrupt each save protocol step and each win/sale/restoration/upgrade transition, including process death after durable write but before UI acknowledgement. Reload must choose a valid snapshot and apply zero or one transaction. Test truncated JSON, mismatched hash, duplicate item IDs, unknown definition, future schema, full disk, denied IO, reinstall/restore behavior, rapid double taps, network absent, backward clock, suspend during a bid, and engine/content upgrades with a live auction. UI tests cover focus order, screen-reader exploration where supported, remapping, 200% text, notches/gesture insets, alternate handedness, no-audio completion and reduced motion. Export smoke includes install/launch/save/relaunch on actual Android hardware, not solely desktop success.


## Art direction, interface and accessibility

### Visual identity

The view is a compact, warmly lit secondhand shop and its neighborhood: visible joinery, mismatched useful furniture, worn object edges, receipt paper, carefully arranged shelves. Objects should invite inspection through silhouette and construction detail. Rarity never changes an object into a neon, metallic or oversized version of itself. One uncommon provenance mark is more meaningful than a colored glow.

Use a fixed oblique top-down view with vertical edges, no perspective camera rotation, and a readable front face on shelving. Characters have recognizable clothing silhouettes, expressive posture and ordinary human proportions stylized into 24 × 40 source pixels. No mandatory free movement: tapping a destination or choosing it from a list performs travel. The player can enjoy decorating without pathfinding becoming a chore.

**Prohibited throughout production:** purple-blue gradients, gradient text, emoji headings, ubiquitous Inter, colored-outline cards, glass panels, low-contrast dark interfaces, generic stock icon systems, default web component styling, scroll entrance fades, hover tricks, inconsistent spacing, corporate promotional copy, ornamental italic serif headings and grain layered over gradients. Use solid fills, restrained separators, purpose-made pixel silhouettes and actual gameplay language. The game interface is a working counter, inventory ledger and auction ticket, not a marketing dashboard.

### Palette and typography

| Token | Hex | Purpose |
|---|---|---|
| Ink | `#29251F` | Body text, silhouettes and primary outlines |
| Paper | `#F5EBDD` | Main interface surface |
| Cream | `#FFFCF6` | Light button text, detail panel |
| Vermilion | `#A63D32` | Primary bidding/action fill, restrained architectural detail |
| Jade | `#326A57` | Confirmed sale, restoration action, foliage |
| Brass | `#BF8A39` | Selection fill with Ink text, physical hardware |
| Muted | `#665C50` | Secondary text on Paper |
| Wood dark | `#644738` | Environment wood shadows, never small text background |
| Wood light | `#BE916A` | Environment wood midtone |
| Ceramic | `#ABC0BB` | Porcelain and painted metal midtone |
| Roof slate | `#626D70` | Tile and industrial shutter midtone |
| Warm shadow | `#D7C5AD` | Environment floor shading |

Calculated with sRGB linearization and the WCAG relative-luminance formula: Ink/Paper **12.92:1**, Muted/Paper **5.55:1**, Cream/Vermilion **6.15:1**, Cream/Jade **6.15:1**, Ink/Brass **5.01:1**. These are flat token-pair measurements, not a claim that every future scene passes. Use these five pairs for text; place opaque panels behind text over scenes. Disabled controls keep legible text and explicitly say why unavailable. Check focus, icons and slider thumbs against their actual adjacent fills. Adopt 4.5:1 for all normal interface text and 3:1 for essential component boundaries as project criteria, using [W3C contrast guidance](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html) and [non-text contrast guidance](https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast.html) as benchmarks rather than claiming native-game WCAG certification.

Use **Noto Sans Regular/Semibold** for instructions, prices, item names and long text. Use **Pixelify Sans Medium** only for the title mark and optional short shop signage; never force it on appraisals or economic numbers. Both current upstream font packages use SIL OFL 1.1: preserve the actual bundled copyright and license files, and obey reserved-name conditions if modifying fonts. Sources: [Noto Sans license](https://github.com/google/fonts/blob/main/ofl/notosans/OFL.txt), [Pixelify Sans license](https://github.com/google/fonts/blob/main/ofl/pixelifysans/OFL.txt). Localize with script-specific Noto families after auditing each actual file; do not assume Latin fonts contain CJK glyphs. Use native script text rather than invented Chinese characters. No network font loading.

Default UI type on the 360-wide logical canvas: body 18, secondary 16, buttons 18 semibold, screen title 24, current bid 30. Minimum essential text 16. Support 100%, 125%, 150% and 200% text size through reflow, with the same gameplay information in scrollable panels at 200%. Keep prices in a stable column and enable tabular figures where the selected font supports them. Format whole credit amounts consistently using the active locale.

### Render geometry and assets

Separate **art pixels** from **UI layout units**. Render environmental art to a 180 × 320 reference SubViewport with nearest filtering, camera and sprite origins snapped to source pixels, and no smoothing. Render UI text and controls at display resolution over that layer; small pixel font text is not a requirement for the art style. The nominal layout canvas is 360 × 640 units, with container reflow for phone aspect ratios rather than stretching sprites. A 720 × 1280 display, for example, uses 4× world pixels and 2× layout units. Use the largest integer world scale that fits, extend framing or use neutral margins for surplus space. Respect native safe-area insets; never position bidding controls under a home gesture indicator or display cutout.

Minimum design test width: 320 layout units. Maximum normal portrait width: 600; center the main column and use surplus width for scenery. A desktop landscape window keeps a centered portrait play column and optional ledger side panel, with no gameplay advantage. Full alternate landscape mobile layout is future scope. At large text sizes the scenery shrinks before actionable controls do. Prototype the selected engine's native scale mapping on real phones; logical units must produce at least 48 dp targets on Android and 44 pt on iOS, rather than assuming a source-art pixel equals a platform point. Platform references: [Android accessibility](https://developer.android.com/guide/topics/ui/accessibility/apps), [Apple buttons](https://developer.apple.com/design/human-interface-guidelines/buttons).

| Asset | Source size | Rules |
|---|---|---|
| Floor/wall tile | 16 × 16 | Modular repeat, clear wall/floor contrast |
| Small item thumbnail | 24 × 24 | Recognizable at 2×; separate semantic label |
| Item inspect art | 64 × 64, 96 × 96 for furniture | Author detail variants, do not upscale thumbnail and invent detail |
| Character | 24 × 40 | Shared foot origin; 4 directional poses, 4-frame walk optional |
| Furniture | Multiples of 16 | Footprint defined independently of decorative overhang |
| Interaction silhouette | 16 × 16 | One meaning each, always accompanied by a label |
| Storefront | Modular 16-pixel segments | Roof, frontage, door and sign separated |

Maximum 16 palette colors per ordinary prop, transparent background, one-pixel clustered outlines, upper-left consistent lighting, no pillow shading, no pseudo-3D smooth gradients. Accent color occupies a small portion of an ordinary screen. Pixel texture conveys material through intentional clusters; do not cover the whole screen with noise. Selection is a flat Ink corner-bracket plus label, focus is a thick rectangular Ink outline against Paper, and invalid placement adds crossed footprint marks plus explanation. Color never carries status alone.

### Screen inventory and portrait composition

All measurements below are reference layout units before safe-area insets. Common margins 16, spacing steps 4/8/16/24, minimum target 48 × 48, separation at least 8. Header normally 56 high; bottom action region 72 minimum. On short screens preserve header/action regions and scroll the middle. Primary actions live in the lower reachable third. Do not require long thumb travel during auctions.

| Screen | Top | Middle | Bottom and behavior |
|---|---|---|---|
| First launch | Title, language choice | Plain summary of local save; text-size and sound controls | Start button; settings reachable before tutorial sound |
| Continue/title | Title and save health | Shop thumbnail; Resume, New shop, Import backup | Settings and credits; replacing save requires confirmation and backup |
| Shop/home | Cash and free capacity with labels | Shop world, highlighted selected shelf; open/closed state | Shop, Auctions, Ledger, Collection buttons; collapse to two-row navigation at large text |
| Auction board | Cash and six reserved free stock slots | Vertical lot rows: site, container size, public clues, fixed opening amount | Select lot then Inspect; no estimated hidden value or jackpot badge |
| Inspection | Back and remaining inspection actions | Scene occupying up to 45%; numbered reachable hotspots; scrollable clue notebook below | Choose hotspot/technique, then Join auction; optional direct list of all inspectable hotspots |
| Auction | Current bid, high bidder, remaining player ceiling | Three named NPC portraits in vertical or compact stacked strips, explicit bid/pass log | Raise +10/+20/+40 with resulting amount and cash after payment; Pass only while nonleader, Hold my bid while leading; no retraction of binding bid |
| Reveal/haul | Paid price and six reserved stock slots | Six-item list with reveal toggle; each row name, condition and discovered detail | Reveal all, Load all six; automatic free batch transport to reserved stock slots |
| Cargo/inventory | Used/free shop stock slots | Filterable rows, condition labels, destination selector | Appraise, Shelve, Dealer sale; actions disabled with reasons; Restore appears only in future expansion |
| Appraisal | Item name, confirmed clues | Large inspect art, plain description, uncertainty range and cost ledger | Compare reference, Record clue, Set price; inspect art is supplementary to text |
| Pricing | Item and acquisition cost | Suggested range with reasoning; numeric price field; step buttons and optional slider | Confirm price; shows expected margin as estimate, never guaranteed sale |
| Shop sales/customer request | Shop state and session sales | Customers visualized in world; request queue as text list | Accept/reject request, sell at posted price; no time-critical popup |
| Decoration | Cash, footprint and mode | Editable shop with selected cell; item catalog in lower sheet | Place/rotate/move, Undo, Done; numeric row/column alternative and accessible list layout |
| Collection | Found count and filters | Rows for found objects, narrative entries, known sets; unknown entries use neutral silhouettes | View discovered entry, pin goal; no unknown-price reveal |
| Ledger/session close | Session cash change | Purchased cost, sales, unsold cost basis, fees, discoveries listed separately | Continue or Save and exit; loss explanation is factual, no shame copy |
| Milestones/specialization | Current project | Requirements expressed as decisions/tasks; previews of newly available tools | Choose project or review reward; no net-worth ladder map |
| Restoration, if enabled | Item and material cost | Before/after condition, expected value range, reversible preview | Restore or Cancel; no compulsory rubbing/swiping minigame |
| Settings | Back, settings title | Text size, contrast, reduced motion, sound, haptics, input, save/backup sections | Apply immediately; settings saved independent of world slot |
| Help/privacy/credits | Plain document title | Searchable/scrollable text, accessibility summary, licenses and support route | Back; external link opens only after explicit activation |

Wireframe for the key auction screen:

```text
+----------------------------------+
| Back    Auction 2     Cash 1,240  |
| Current bid 180     Leader: Mei  |
| Your ceiling 250   [Edit ceiling]|
|                                  |
| [Mei]   Collects ceramics         |
| [Arif]  Passed                   |
| [Suri]  Thinking                 |
|                                  |
| Recent: Mei bids 180              |
| Your turn. No time limit.         |
| After bid: 1,040 cash             |
| [Bid 200]          [Pass]         |
+----------------------------------+
```

Copy rules: use `Bid 200`, `Pass on this lot`, `Restore for 35`, `Save and exit`; avoid `Go`, `Okay` and ambiguous checkmarks. Each bid control displays its exact binding amount and cash remaining if won. Payment and transfer happen automatically when that accepted bid wins; there is no cancellable post-win purchase step. The normal bid action must remain quick: set a ceiling before joining, then confirm each bid with the exact amount. Passing and bidding cannot occupy the same target between states. Auction result buttons appear after a short input guard to prevent a held confirm key from accidentally advancing into another action.

### Controls and accessible feedback

Touch: tap selects, second explicit action confirms. Drag is an optional decoration shortcut, with tap-pick/tap-place and list-based placement alternatives. Pinch is optional inspection zoom; plus/minus buttons provide the same function. No motion controls, simultaneous fingers, repeated tapping, precision meter or required long press. All adjustable values have digital step controls in addition to sliders. Left/right hand preference swaps primary lower controls while preserving order within reading/navigation flows.

Keyboard: arrows navigate, Enter/Space activate, Escape backs out, Tab/Shift-Tab move focus, Page Up/Down scroll. Controller: D-pad/left stick focus, south button activate, east button back, shoulders cycle tabs. Show prompts for the last active device; remapping applies to every screen and reserves an always reachable recovery control. Do not put essential functions behind an undocumented shortcut. Focus order is header, current context, content rows, actions; closing a dialog restores the initiating control. Announce price changes only after adjustment stops, not on every animation frame.

MVP accessibility commitments: turn-based auctions; no penalties for pausing or app suspension; scalable text; separate music/effect volumes; optional haptics; reduced motion disables shake, bounce and camera motion; all speech in text; status communicated in words and shapes; all controls reachable using one input method. These are design decisions informed by [Game Accessibility Guidelines](https://gameaccessibilityguidelines.com/full-list/), not proof of complete accessibility. Invite players with different access needs to the first external prototype test.

Every interactive item has semantic name, role, state and description. Example: `Wooden sewing box, worn, one stock slot. Contains a maker's stamp clue. Inspect button.` Explain the **visible** evidence only during inspection; do not leak concealed loot through screen-reader labels, object names, scene hierarchy or debugging text. Decorative backgrounds are omitted from reading order. An accessible inspection list provides the same observations and action costs as tapping world hotspots. If engine/platform accessibility bridging is incomplete, an accessible desktop prototype is insufficient: native mobile VoiceOver/TalkBack testing is a release gate, and the team must either implement the bridge or narrow published accessibility claims. Do not promise full screen-reader playability before it is demonstrated.

Accessible store/catalog website images need useful alt text, such as `Portrait auction interface showing three bidders and explicit Bid 200 and Pass buttons`. In-game semantic descriptions serve the analogous purpose; decorative art has no redundant description. Captions identify sound-producing events where relevant. Cash-register chime pairs with `Sold: 85`, NPC bid sound pairs with the bid log, and restoration completion pairs with a persistent completed state. No flashing jackpot sequence. Vibration can be off without information loss.

### Shop customization and cultural reference

MVP includes a neutral repair-shop set and a **traditional Chinese-inspired timber shop set**, available through ordinary decoration play rather than being the exotic highest-value reward. The second set supports the user's desired expressive storefront: tiled roof edges, timber framing, red-painted doors, restrained lattice panels, hanging signboards, ceramic planters and warm interior cabinets. Specific regional/historical reference boards must be chosen before final production; a broad label is not a claim of architectural authenticity. Consult a paid Chinese cultural/art reviewer on the reference board, text and assembled set. Do not combine unrelated Asian motifs indiscriminately or use religious objects as disposable loot decoration. No unverified characters or costume caricatures. Offer all structural elements in multiple restrained material finishes; players can combine pieces with neutral shelving. NPC identity and economic behavior are unrelated to ethnicity.

Decoration uses a 6 × 8 shop footprint for MVP. Door, accessible customer lane and checkout cells are protected. Furniture has explicit walkable footprint and visual overhang; readable preview shows conflicts before placement. Decorations do not multiply sale prices or substitute for appraisal skill. Displays provide no presentation or price bonus in the MVP. Undo retains the last 20 edits; cancel restores the pre-edit layout; commit validates all placements and saves atomically.

### Art/audio production and acceptance

Author source layers, stable asset IDs, reference attribution and export settings together. Content artists submit thumbnail, inspect art, world sprite, collision/footprint, semantic description and provenance manifest entry. The importer checks dimensions, naming, palette budget, missing IDs and localization keys. A human checks silhouette readability at minimum phone width, correct observation clues, cultural context and consistent lighting. Use explicit commissions or licensed assets; reference photos are study material unless redistribution permission is documented. Original sprites are preferred for auction items, NPCs and signature shop sets. Do not lift Roblox art, names, UI, sounds or object descriptions.

Ambient audio: gentle shop room tone, distant street activity, short wood/ceramic/metal handling sounds, a nonintrusive sale sound. No essential stereo positioning. Mono mode is available; any future dialogue mixing lowers ambience beneath speech. Commission or use verified licenses, track attribution and music loop provenance, and avoid culturally reductive music stereotypes for the Chinese-inspired theme. MVP can ship with one original ambient loop and 12 distinct functional effects.

Acceptance checks: no clipped labels at 320-wide layout with 200% text; controls meet native target minima; all required information survives grayscale; every core action works with touch, keyboard and controller; reduced motion suppresses cosmetic movement; sound/haptics off loses no clue; prices remain readable over every scene; no concealed item details exposed by semantic labels; a full auction and shop sale survive interruption; unsafe furniture placement cannot commit; actual VoiceOver/TalkBack behavior tested before mobile accessibility claims. Validate screenshots and live interaction, not palette values alone.

MVP: portrait layouts above, two shop sets with 12 props each, 40 base item illustrations across four categories of ten each plus condition detail variants, six distinct portraits (three bidders and three regular customers), one neighborhood facade, inspection/reveal/list semantics, native accessibility investigation, text reflow and input alternatives. Future: regional architecture packs with reviewed sources, alternate landscape phone composition, richer NPC animation, fully narrated object entries, switch-access enhancements and additional scripts. New content must meet the same readability/provenance gates; a theme pack is not a reason to add a new statistical rarity tier.



## Production plan, verification and release obligations

### Workflow and readiness

Use a versioned repository with this README, source assets, export presets stripped of secrets, data schemas, tests and license notices. Track each feature with a player-facing acceptance condition, content dependencies and an owner. Maintain separate prototype and release milestones. Keep all balances in data, not scene scripts. Pin engine/export tools; document deliberate upgrades and run save migration and device regression checks after each upgrade.

Before implementation: confirm Android test devices and development machine; reserve art/audio budget; create the license register; confirm the selected engine export pipeline with a disposable blank build; choose launch territories and publisher identity; choose whether the commercial candidate is paid once. These are readiness tasks, not completed actions. iOS, full nonvisual screen-reader navigation, monetization plugins and legal publication require separate validation gates. No engine installation or game project is included in this deliverable.

Daily workflow once implementation is requested: take one small behavior from the backlog, implement its domain rule, verify a representative failure path, integrate the screen, run the relevant save/input checks, and update the document when decisions change. Review a recorded build each week. Do not grow the content count to hide a weak auction loop.

### Milestones and acceptance criteria

Estimates are provisional person-weeks for a small experienced team with art support, excluding platform-review delays. A person-week means about 30 focused production hours; actual calendar time depends on staffing, experience and available hardware. Sequence matters more than the estimate.

| Gate | Estimate | Deliverable | Acceptance / exit criterion |
|---|---:|---|---|
| P0: paper economy | 1 | 12 hand-authored lots, three bidder profiles, price/inspection worksheet | Can explain profit and loss without secret rules; opening price never varies with contents; two viable inspection choices per ordinary lot |
| P1: domain prototype | 2 | One auction, one lot reveal, six objects, one customer wave, local persistence | Exact replay from a saved seed; no duplicate purchase/sale on resumed commands; 100 seeded manual scenarios settle without a stall |
| P2: portrait vertical slice | 3-4 | One venue, six items, complete UI loop, six decorations, introductory quest | At least 8-12 consented target players try it; at least 80% can bid, walk away, stock and sell after the tutorial without intervention; median normal loop 4-7 minutes |
| P3: content-complete MVP | 4-6 | Authoritative MVP manifest, progression, index, theme kit, customers and loss recovery | Every authored item has art, clue, sale/collection use and provenance; every unlock adds a decision; complete starter-to-finale path works without rare drops |
| P4: reliability/accessibility | 2-3 | Device pass, save fault tests, input/accessibility pass, balance simulations | Zero known critical or major progression/save faults; meet performance budgets; can recover from worst allowed loss; large text and tap alternatives complete all required actions |
| P5: release candidate | 1-2 | Signed Android build, honest listing, actual credits/policies and support path | Install/update/offline pass; store declarations match packaged SDKs; publisher and rights verified; legal/distribution gates complete |

Estimated base 13-18 person-weeks plus about 25% contingency, roughly 16-23 person-weeks. This is planning, not a promise that one person can ship in that many calendar weeks. Cut optional restoration depth, dialogue length and extra themes before compromising saves, readability or auction fairness. If P2 players mainly skip lots or cannot explain a bid decision, revise inspection and clue structure before P3.

### Content backlog and authoring definition of done

Maintain `content_manifest.csv` with stable ID, category, tier, maker/period, base value, footprint, condition states, clue hooks, sprite paths, text keys, audio references, venue weights, request tags, license record and review status. The authoritative MVP totals in the integration contract define the release minimum, not each specialist's illustrative examples. Count distinct item definitions, not recolors or condition variants. Include a starter lot that teaches choosing an inspection, a normal profitable lot, a tempting overbid, a low-value but collection-relevant object, and an intentionally unprofitable restoration.

One asset is done only when its silhouette reads at actual phone scale, runtime import is correct, description and clues agree with its hidden data, translations fit, keyboard selection has a clear label, and provenance is recorded. Condition wear must correspond to actual condition. Art must not signal hidden rarity through a pre-auction glow. A production lot fixture must include its visible observation, hidden inventory, NPC observation views and expected auction outcome under named policies.

### QA matrix

| ID | Scenario | Required result |
|---|---|---|
| A01 | Two lots with identical venue/size rules but radically different contents | Same opening price and increment; no art/UI/sound/ID sorting leaks secret value |
| A02 | Player opens, leaves, reopens a lot; restarts app mid-inspection | Same contents, NPC ceilings, visible clues and remaining actions |
| A03 | Player has exactly next-bid cash; one less; zero | Legal bid only when both cash and reserve rules permit; disabled control explains amount required |
| A04 | All bidders pass, sole active bidder, ties at ceiling, maximum rounds | Deterministic valid winner or unsold result; no infinite loop; tie rule matches chapter |
| A05 | Tap twice rapidly on bid, purchase, sale or restore | One durable action and one debit/credit; second command rejected or recognized as duplicate |
| A06 | Pause during NPC response or suspend at purchase commit | Resume from last committed state; no extra charge, refund or inventory copy |
| E01 | Every condition and reference sample price | Formula agrees with table; integer rounding and salvage floor documented |
| E02 | Cash at zero, all shelves empty, full inventory, player loses repeatedly | Consignment/recovery route available; no debt, no forced reset, no negative currency |
| E03 | Donate/sell/recycle last copy, then inspect collection | Discovered index entry remains; owned state updates; no loss of knowledge |
| E04 | Hoard, underprice everything, refuse all sales, pass every lot | Player can resume productive play; no compulsory storage fee or progression softlock |
| E05 | Restoration repeated or interrupted | One-time valid improvement; no value farming from reversible condition cycling |
| E06 | Repeated safe-policy auctions versus guessing/always-bid | Measured outcomes meet target bands; no claim of balance before simulation and human playtest |
| S01 | Kill before write, during temporary write, during slot replacement, after replacement | At least one valid previous/new generation opens; action not applied twice |
| S02 | Truncated JSON, bad checksum, newer schema, missing asset ID | Recover previous save when valid; retain originals; unsupported save never silently erased |
| S03 | Disk full, denied write, storage unavailable | Show unsaved state, stop further irreversible economy commands, allow retry/export |
| S04 | Import crafted oversized, negative-cash or duplicate-ID file | Reject safely before mutation, no code execution or path traversal |
| U01 | Small phone, tall phone, cutout, system gesture bar, tablet | Controls remain inside safe area; art crops without hiding clues; UI reflows |
| U02 | Text at 100%, 125%, 150%, 200%; long localized strings | Required amount, action, price and consequence stay readable and reachable |
| U03 | One hand, left-handed controls, no drag, keyboard only, controller only | Entire MVP path completes; focus never trapped; cancel is consistent |
| U04 | Grayscale, simulated color deficiencies, muted audio, reduced motion | Bid states, condition, item tier and warnings understandable without color/sound/motion |
| U05 | VoiceOver/TalkBack if marketed as supported | Labels, focus order, values and live action feedback work on exported device; otherwise disclose limitation accurately |
| C01 | Theme kit mixed with standard furniture and narrow paths | Placement preview clear, customer path remains valid, decorations do not grant secret luck |
| P01 | Maximum legal items/customization/customer population for 30 minutes | Meets frame/memory budgets without runaway allocation, overheating spikes or crash |
| R01 | Fresh install, update with legacy save, reinstall and uninstall | Documented save behavior; no false cloud-backup promise; import/export succeeds where supported |

Critical means loss of save or money, crash on core path, privacy misrepresentation or inability to progress. Major means unusable required input, broken auction fairness, unreachable controls or a mandatory content defect. Fix both before release. Record build, device/OS, seed, steps, expected/actual outcome and a minimal fixture for each fault. Hardware tests are required; desktop success is not a mobile pass.

### Balance and user research plan

Use headless seeded simulations with always-pass, always-bid, ceiling-at-estimated-value, cautious ceiling, specialist and random policies. Compare mean and median cash flow, loss percentiles, win rates, overpayment, sessions to unlock, recovery length and sale delay by category. Use paired seeds when changing one variable. Include 100,000 lots per economy version, reports by listing profile, and long 1,000-session trajectories as future validation runs. These runs have not been performed. Test the conditional relationship between opening price and hidden value within venue/lot size; verify independence by construction and catch accidental implementation leakage through fixtures. NPC final prices may legitimately correlate with clues, so do not mistake market bidding for an opening-price leak.

Recruit 8-12 players per early iteration, including players with limited dexterity or vision. Ask permission to record; avoid collecting unnecessary real identities. Observe whether players can articulate a clue, set a ceiling and willingly walk away. Ask what they remember about their shop and one acquired object. Stop using “retention” as a substitute for enjoyment. Later sessions should test repeated play and whether discovery remains interesting after the initial novelty. Targets are hypotheses that can change, not fabricated results.

### Analytics and privacy by default

MVP sends no gameplay telemetry. Development builds may keep a local, rotating debug ledger of event type, fixture seed, in-game session counter and numeric outcome. No advertising identifier, location, email, contacts, camera, microphone or background collection. Provide an explicit user action to export a diagnostic file, preview its contents and omit save narrative/custom shop names. Delete local logs with the in-game reset option. A checksum is for corruption detection, not anonymity or encryption.

Only add remote analytics if a specific unresolved product question needs it and volunteers' local exports cannot answer it. Write a data map first: event fields, purpose, lawful basis where needed, retention, recipient/processors and deletion path. Separate optional telemetry consent from ability to play; withdrawal must stop collection. Choose an explicit short retention period, audit SDK behavior and update policies/store declarations before release. Do not assume an opt-in alone satisfies every law. [GDPR Article 5](https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX%3A32016R0679) includes data minimisation; applicability depends on distribution and processing.

### Monetization and distribution branches

| Distribution | Candidate approach | Required preparation |
|---|---|---|
| Private prototype / direct free build | No purchases or accounts | Credits/provenance, honest compatibility and save notices; consent for any tester recordings |
| Google Play paid once | Recommended commercial candidate, price TBD after testing | Actual publisher details, support contact, content rating, accurate Data safety form, public and in-app privacy policy, signed export and applicable billing/refund disclosures |
| App Store paid once, later | Same gameplay; no special luck or content penalty | Apple enrollment, macOS/Xcode export pass, privacy policy and App Privacy disclosures, ratings, purchase/restore behavior if IAP is later added |
| Optional demo plus permanent unlock | Separate future business choice | Validate platform billing and entitlement restoration, offline access after ownership, interrupted purchase/refund/revocation behavior and localized price text |
| Optional cosmetic expansion | Fixed disclosed theme pack, never randomized | Clear contents, localized platform price, license rights and persistent entitlement; default Chinese-inspired MVP kit stays earnable |
| Web build / promotional site, future | No web build promised | Keyboard access, text alternatives, actual business details, cookies/embeds/tracking audit, necessary consent and appropriate policies |

Do not sell currency, random boxes, bid retries, odds improvements, stamina or loss relief. Do not add ads to the MVP. No unsupported scarcity countdowns, fake testimonials, purchased reviews or fabricated ratings. A purchase confirmation must show the actual localized charge and contents; do not invent a price in UI before billing returns it.

Google's [Data safety guidance](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en-GB) requires a form and privacy-policy link even for apps without user-data collection, with exemptions for exclusively internal testing and certain other app types. Third-party SDK data practices must be reflected. Apple's [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/) cover privacy and digital purchases; review current rules for the chosen storefront/territory rather than treating payment rules as universally identical. Policies are living release requirements and must be checked again at submission.

### Rights and legal release checklist

This is a preparation checklist, not a legal opinion or finished set of policies. Launch jurisdictions and business entity are unresolved. The user timezone does not establish a legal jurisdiction. Before sale, record chosen countries, developer identity, support address and applicable store contracts; have appropriate counsel review consumer, privacy, child audience, accessibility and IP obligations. If Indonesia is selected, include a review of Indonesian privacy/consumer law and applicable electronic-system/game-rating obligations; do not assume they are satisfied by GDPR or a store rating.

Use fictional makers and original object art. Do not use real brand logos, franchise collectibles, song recordings, TV clips, copied Roblox models or screenshots as shipped content. Reference photos must be owned, licensed or public-domain with documented basis. Traditional motifs require respectful interpretation and review, not an assumption that every photo of old architecture is free to copy. Record engine/library notices, font OFL files, commissioned-asset agreements and audio rights. Commission contracts must address commercial use, editing, ports, credits and source delivery.

Publish a privacy policy describing the actual offline game, any platform processing, optional support submissions and contact/deletion procedure. Never promise “no data anywhere” if the store/payment provider or support form processes data. Add suitable EULA/terms, refund information tied to the actual store and local rights, and support details. Do not invent the developer's company, address or response-time promise. A direct-sale refund policy must be approved for chosen territories. No mandatory cookie banner for a native game with no cookies; a later site needs an actual cookie/third-party embed inventory and consent where required. No account-deletion page is needed for an accountless MVP, but local save reset must be clear and confirmed.

Targeting teens/adults does not itself decide whether child privacy law applies. Marketing, visual content and actual knowledge matter. The FTC's [current COPPA FAQ](https://www.ftc.gov/business-guidance/resources/complying-coppa-frequently-asked-questions) addresses covered child-directed services and known under-13 data collection. Review the applicable rules before adding accounts, ads, chat, analytics or targeting children. Avoid needless birthdate collection merely to claim an age gate.

### Risk register and change log

| Risk | Trigger | Mitigation / stop condition |
|---|---|---|
| Auction becomes solved by one clue | Players rank every lot instantly | Add ambiguity through grounded condition/variant clues, not arbitrary secret multipliers; test equivalent-looking fixtures |
| Small content pool feels repetitive | Players cannot recall new decisions after several sessions | Improve requests and clue combinations; defer volume expansion until systemic variety works |
| Decoration overwhelms mobile readability | Theme obscures labels, shelves or paths | UI stays separate; placement contrast/readability review; no decorative text as essential control |
| Solo scope expands into simulation chores | Driving, staff, free roaming or large town requested | Move to future backlog; keep complete 5-minute loop as acceptance gate |
| Loss relief becomes an exploit or stigma | Farmable recovery mint or forced shame dialogue | Use commission work with bounded payout and opportunity cost; no ads or humiliating labels |
| Font/engine accessibility gap | Exported screen reader lacks semantic focus | Test early, budget adapter work, disclose limits accurately; do not claim nonvisual accessibility before device verification |
| Save filesystem behavior differs by device | Kill tests lose both slots | Block release, revise persistence implementation and repeat fault tests |
| Title/asset rights conflict | Name search or license cannot support distribution | Rename/replace before branding and release; keep provenance gate blocking |

14 October 2026, v1.0: initial specialist-reviewed design assembled. No gameplay validation results yet. Later changes must record date, reason, changed contract/config values, affected saves and verification evidence.
