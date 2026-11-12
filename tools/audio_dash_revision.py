"""Original short, low-passed cloth transients; no borrowed game/library samples."""
from pathlib import Path
import math,random,struct,wave
rate=44100;rng=random.Random(313)
for name,duration,cutoff in [('dash_cloth',.095,1250),('katana_air',.11,1750)]:
 values=[];a=0.;b=0.;alpha=1-math.exp(-2*math.pi*cutoff/rate)
 for i in range(int(rate*duration)):
  t=i/rate;noise=rng.uniform(-1,1);a+=alpha*(noise-a);b+=alpha*(a-b)
  envelope=(min(1,t/.004)*math.exp(-t*45))
  # A brief low fabric fold under the air, with no sustained broadband hiss.
  body=math.sin(2*math.pi*180*t)*math.exp(-t*75)*.07
  values.append((b*.75+body)*envelope)
 peak=max(abs(v) for v in values);gain=.58/peak
 p=Path('game/audio')/(name+'.wav')
 with wave.open(str(p),'wb') as f:
  f.setnchannels(1);f.setsampwidth(2);f.setframerate(rate)
  f.writeframes(b''.join(struct.pack('<h',round(v*gain*32767)) for v in values))
 print(name,'duration',duration,'low-pass',cutoff,'Hz')
