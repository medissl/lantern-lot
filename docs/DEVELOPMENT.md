# Development status

14 October 2026 — Prototype 0.1, starting P1.

The attached finalized game design was copied unchanged to `DESIGN.md`. P0's twelve authored paper-economy lots are still outstanding. This implementation starts the requested concrete prototype using the exact six-item example, rather than claiming any production gate is complete.

## Implemented foundation

- Domain reducer validates commands, applies them to a copy, and records revision/idempotency history.
- Auction module receives only public categories, freezes independent seeded rival budgets and interpretation offsets, and resolves bounded logical turns. It cannot read concealed objects.
- Inventory, sales, customer queues, fee rounding, and cost allocation use integer coins. Winning debit and all six stock additions commit together.
- Save service writes/verifies an inactive temporary slot, retains a verified prior copy, replaces/verifies the final slot, and only then acknowledges state. Candidate writes fail closed.
- Responsive portrait UI provides explicit labeled choices, focus navigation, large-text toggle, pricing entry, and readable receipts over original placeholder art.

The prototype batches NPC turns after player commands. A player leadership interval is resolved synchronously, so no intermediate leader-withdraw action is exposed; the domain still rejects leader retraction. No turn runs on a timer. Suri uses a consistent +10 preference in this first fixture; occasional +40 behavior is deferred.

## Next development work

1. Author P0's twelve lot fixtures and test varied clue choices, cautious policies, and loss recovery.
2. Expand content to the forty catalog definitions; persist the three-listing board with independent generation streams and truthful layouts.
3. Add relationship/request events and progression counters, with unique committed event keys and save migration fixtures.
4. Add six P2 decorations, protected-lane placement, introductory quest, and production-ready layout geometry.
5. Run Android device/export and semantic accessibility spikes, then invite consented testers for the P2 criteria.

## Verification boundary

Godot 4.7.2 headless run: **3,907 checks passed**, including 100 seeded auction rule scenarios, 100 full domain loops, and a service-level loop with disk reloads during inspection and a customer offer. Tests include corruption fallback, checksum rejection, newer-schema blocking, and an intentional invalid-directory write failure; the latter emits an expected engine error while the test passes.

Desktop Compatibility renderer launch and seven screen captures passed: shop, shelf pricing, inspection, reveal, customer confirmation, receipt, and enlarged text. Visual review corrected the placeholder viewport scaling. The service-level regression catches JSON numeric-type conversion after loading, including repeat inspection and materialized customer budgets. `DESIGN.md` has the same SHA-256 as the attached file.

No Android, screen-reader, human pacing, balance, or performance pass is claimed. Desktop tests cannot establish mobile save durability. Current saves are schema 1/content `prototype-1`; keep the prototype separate from future production saves until an explicit migration exists.

## Asset provenance

`scripts/ui/world.gd` contains original geometric placeholder artwork authored for this prototype. No downloaded/AI-generated art or audio was added. The scaffold's `icon.svg` is Godot's default project icon and will be replaced before branding/release. No commercial rights, final name clearance, or release license is asserted by this commit.
