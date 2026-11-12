"""Generate original placeholder game audio with deterministic synthesis; no samples."""
import math, random, wave, struct
from pathlib import Path
RATE=22050
OUT=Path(__file__).resolve().parents[1]/'game/audio'
OUT.mkdir(parents=True,exist_ok=True)
rng=random.Random(21)
def save(name,duration,synth):
    samples=[]
    for i in range(int(RATE*duration)):
        t=i/RATE
        v=synth(t,i)
        samples.append(struct.pack('<h',int(max(-1,min(1,v))*26000)))
    with wave.open(str(OUT/(name+'.wav')),'wb') as w:
        w.setnchannels(1);w.setsampwidth(2);w.setframerate(RATE);w.writeframes(b''.join(samples))
def noise():return rng.uniform(-1,1)
save('swing',.26,lambda t,i: noise()*.38*math.sin(math.pi*t/.26)**2+math.sin(2*math.pi*(900*t-1100*t*t))*.08*math.sin(math.pi*t/.26))
save('impact',.22,lambda t,i:(noise()*.34+math.sin(2*math.pi*110*t)*.5)*math.exp(-t*30)*min(1,t*1000))
save('jump',.18,lambda t,i:math.sin(2*math.pi*(190*t+500*t*t))*.2*math.sin(math.pi*t/.18))
save('dodge',.2,lambda t,i:noise()*.2*math.sin(math.pi*t/.2)**2)
save('hurt',.3,lambda t,i:(math.sin(2*math.pi*(130*t-90*t*t))*.35+noise()*.1)*math.exp(-t*16)*min(1,t*700))
save('bell',1.7,lambda t,i:sum(math.sin(2*math.pi*f*t)*a for f,a in [(587,.35),(1178,.15),(1710,.06)])*math.exp(-t*3.5)*min(1,t*180))
save('ui',.09,lambda t,i:math.sin(2*math.pi*680*t)*.16*math.sin(math.pi*t/.09))
# Eight-second seamless, restrained atmospheric drum/drone sketch. Smooth periodic envelope.
def score(t,i):
    drone=(math.sin(2*math.pi*73.5*t)+.4*math.sin(2*math.pi*110*t))*.055
    beat=t%2
    drum=math.sin(2*math.pi*(60*beat-8*(1-math.exp(-beat*15))))*math.exp(-beat*8)*min(1,beat*300)*.16
    return (drone+drum)*math.sin(math.pi*t/8)**2
save('atmosphere',8,score)
print('Generated eight original WAV assets')

# Revision: textured cloth takeoff and gravel landing instead of a rising tone.
for cue,duration,weight in [("jump",.15,.27),("land",.18,.46)]:
    filtered=[0.0]
    def contact(t,i):
        filtered[0]=.62*filtered[0]+.38*noise()
        envelope=min(1,t*500)*math.exp(-t*(28 if cue=="jump" else 22))
        return (filtered[0]*.8+math.sin(2*math.pi*95*t)*weight)*envelope
    save(cue,duration,contact)
