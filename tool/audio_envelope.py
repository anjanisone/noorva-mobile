"""Compute a loudness envelope (one value per window) from an MP3.

Usage: python envelope.py <input.mp3> <output.json>
Output: {"stepMs": 50, "levels": [0..100 ints]}
"""
import array
import json
import math
import sys

import miniaudio

STEP_MS = 50

src, dst = sys.argv[1], sys.argv[2]
decoded = miniaudio.decode_file(
    src, output_format=miniaudio.SampleFormat.SIGNED16, nchannels=1, sample_rate=16000
)
samples = array.array("h", decoded.samples)
window = decoded.sample_rate * STEP_MS // 1000

rms = []
for i in range(0, len(samples), window):
    chunk = samples[i : i + window]
    if not chunk:
        break
    rms.append(math.sqrt(sum(s * s for s in chunk) / len(chunk)))

# Normalise against a high percentile so a few peaks don't flatten everything,
# then apply a gentle curve so quiet syllables still move the bars.
peak = sorted(rms)[int(len(rms) * 0.98)] or 1.0
levels = [min(100, round(100 * (min(r / peak, 1.0) ** 0.6))) for r in rms]

with open(dst, "w") as f:
    json.dump({"stepMs": STEP_MS, "levels": levels}, f, separators=(",", ":"))

print(f"duration={len(samples) / decoded.sample_rate:.1f}s windows={len(levels)} "
      f"silent={sum(1 for v in levels if v < 8)}")
