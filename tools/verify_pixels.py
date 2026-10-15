"""Check actual raster world magnification from captured PNG/geometry pairs.

Only unobstructed room captures are inspected. High-resolution GUI text/sheets
intentionally use a separate rendering scale and are excluded.
"""
from pathlib import Path
from PIL import Image
import json

ROOT = Path(__file__).resolve().parents[1]
EVIDENCE = ROOT / "build" / "visual-overhaul-evidence"
NAMES = ["01-shop-sparse", "02-shop-stocked", "03-yard-inspect", "04-auction-bid", "08-customer-browse"]
results = []
summary = json.loads((EVIDENCE / "verification-summary.json").read_text(encoding="utf-8-sig"))
sizes = [stage["stage"].removeprefix("render-") for stage in summary if stage["stage"].startswith("render-") and stage["passed"]]
for size in sizes:
    directory = EVIDENCE / size
    assert directory.is_dir(), f"Requested capture size {size} missing; do not substitute a clamped window."
    for name in NAMES:
        metadata = directory / f"{name}.json"
        assert metadata.exists(), (size, name, "Missing geometry sidecar")
        info = json.loads(metadata.read_text())
        image = Image.open(directory / f"{name}.png").convert("RGB")
        x, y, width, height = info["world_rect_physical"]
        scale = info["integer_world_scale"]
        assert image.size == tuple(info["window"]), (directory, "Window/capture size differs")
        assert scale >= 1 and width == info["world_viewport"][0] * scale
        assert height == info["world_viewport"][1] * scale
        pixel = image.load()
        unequal, blocks = 0, 0
        for top in range(y, min(y + height, image.height) - scale + 1, scale):
            for left in range(x, min(x + width, image.width) - scale + 1, scale):
                color = pixel[left, top]
                blocks += 1
                if any(pixel[left + col, top + row] != color for row in range(scale) for col in range(scale)):
                    unequal += 1
        results.append({"capture": str(directory.relative_to(ROOT) / f"{name}.png"), "scale": scale, "blocks": blocks, "unequal_blocks": unequal})
report = {"captures": len(results), "results": results, "scope": "Nearest-neighbor physical world pixels only; excludes UI, motion timing and mobile displays."}
(EVIDENCE / "pixel-scale-report.json").write_text(json.dumps(report, indent=2))
assert results, "No current PNG/JSON evidence pairs; run --ui-smoke first."
failures = [result for result in results if result["unequal_blocks"]]
for failure in failures:
    print("PIXEL_SCALE_MISMATCH:", failure)
assert not failures, f"{len(failures)} captures have nonuniform source-pixel blocks; review pixel-scale-report.json"
print(f"PIXEL_SCALE_PASS: {len(results)} captured rooms at integer physical magnification.")
