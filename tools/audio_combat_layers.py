"""Original, reproducible short combat Foley/synthesis; no external samples.

Separate air/body/contact layers are deliberately tied to different gameplay events.
Run from any cwd. Produces 44.1 kHz mono PCM16 for mobile playback.
"""
from pathlib import Path
import json
import math
import random
import struct
import wave

OUT = Path(__file__).resolve().parents[1] / "game/audio"
RATE = 44100
REPORT = []

def noise(duration, cutoff, seed):
    rng = random.Random(seed)
    alpha = 1 - math.exp(-2 * math.pi * cutoff / RATE)
    a = b = 0.0
    values = []
    for _ in range(round(duration * RATE)):
        a += alpha * (rng.uniform(-1, 1) - a)
        b += alpha * (a - b)
        values.append(b)
    return values

def tone(t, frequency, damping, level=1, sweep=0):
    return level * math.sin(2 * math.pi * (frequency*t + sweep*t*t/2)) * math.exp(-damping*t)

def render(name, duration, fn, peak=.62):
    values = []
    for i in range(round(duration * RATE)):
        t = i / RATE
        # Every one-shot has an actual attack and tail fade, rather than a hard cut.
        edge = min(1, t/.0035, (duration-t)/.025)
        values.append(fn(t, i) * max(0, edge))
    # Remove any DC left by very short low-frequency layers before normalization.
    mean = sum(values) / len(values)
    values = [(v-mean)*min(1, i/100, (len(values)-1-i)/180) for i,v in enumerate(values)]
    gain = peak / max(abs(v) for v in values)
    values = [v*gain for v in values]
    with wave.open(str(OUT / (name + ".wav")), "wb") as f:
        f.setparams((1, 2, RATE, 0, "NONE", "not compressed"))
        f.writeframes(b"".join(struct.pack("<h", round(v*32767)) for v in values))
    rms = math.sqrt(sum(v*v for v in values)/len(values))
    REPORT.append({"file":name+".wav", "seconds":duration,
                   "peak_dbfs":round(20*math.log10(peak),2),
                   "rms_dbfs":round(20*math.log10(rms),2)})

# Air on a miss stays soft and short; alternating layers avoid a repeated white hiss.
for variant in range(3):
    duration = .115 + .006*variant
    cloth = noise(duration, 1400+variant*170, 600+variant)
    air = noise(duration, 3100, 610+variant)
    def swing(t,i):
        envelope = (1-math.exp(-t*320))*math.exp(-t*42)
        return (cloth[i]*1.6 + air[i]*.11)*envelope + tone(t,150+variant*11,75,.035)
    render("katana_air" + ("" if variant==0 else "_%d" % (variant+1)),duration,swing,.58)

# Contact = compact low-mid body plus damped inharmonic steel, not a long bright scrape.
for variant in range(3):
    duration = .19
    grain = noise(duration, 1950, 630+variant)
    shift = 1 + (variant-1)*.025
    def contact(t,i):
        body = tone(t,125*shift,35,.52,-170)
        steel = sum(tone(t,f*shift,d,a) for f,d,a in [(1147,52,.12),(1733,61,.075),(2491,74,.035)])
        return body + steel + grain[i]*math.exp(-t*58)*.8
    render("katana_contact" + ("" if variant==0 else "_%d" % (variant+1)),duration,contact,.64)

# Kick motion: a small fabric fold, not a false target impact on a miss.
cloth = noise(.13, 820, 651)
render("kick_cloth",.13,lambda t,i: cloth[i]*(1-math.exp(-t*400))*math.exp(-t*41)*2 + tone(t,155,62,.05),.50)
body_grain = noise(.16, 1100, 654)
render("kick_contact",.16,lambda t,i: tone(t,118,40,.50,-95)
       + tone(t,204,55,.12) + body_grain[i]*math.exp(-t*65)*.7,.60)

# Charged release: wider air envelope and a low cloth snap; contact remains separate.
low = noise(.24, 1150, 661)
edge = noise(.24, 2400, 662)
render("charged_blade",.24,lambda t,i:
       (low[i]*1.6+edge[i]*.2)*(1-math.exp(-t*180))*math.exp(-t*25)
       + tone(t,138,52,.055),.63)

# Charging is a quiet, rising harmonic breath with a soft start, not a piercing beep.
charge_noise = noise(.52, 440, 670)
def charging(t,i):
    env = math.sin(math.pi*t/.52)**1.25
    phase = 2*math.pi*(108*t+70*t*t)
    return (math.sin(phase)*.16+math.sin(phase*2.01)*.045+charge_noise[i]*.22)*env
render("power_charge",.52,charging,.40)

# Supernatural release has low-mid weight and a short glass/steel halo, with a clean tail.
release_noise = noise(.34, 1450, 680)
def power(t,i):
    body = tone(t,103,22,.4,-90) + tone(t,206,30,.12)
    halo = sum(tone(t,f,d,a) for f,d,a in [(880,24,.09),(1327,30,.055),(1913,40,.035)])
    air = release_noise[i]*(1-math.exp(-t*250))*math.exp(-t*30)*1.2
    return body + halo + air
render("power_release",.34,power,.65)

# Aerial landing = stone/sole body, then brief debris; no metallic note.
grit = noise(.26, 1700, 690)
render("aerial_stone",.26,lambda t,i:
       tone(t,94,25,.5,-100)+tone(t,174,42,.16)
       +grit[i]*(math.exp(-t*60)+.25*math.exp(-abs(t-.045)*100))*.75,.62)

# Unavailable power is a quiet dry tick with no harsh warning or long note.
tick = noise(.052, 950, 701)
render("power_empty",.052,lambda t,i:tick[i]*math.exp(-t*125)+tone(t,240,140,.045),.28)

print(json.dumps(REPORT,indent=2))
