"""Adapt CC0 attack resources into role-specific layered cues and a shared palette."""
from pathlib import Path
import subprocess,json,wave,struct,shutil
from PIL import Image
R=Path(__file__).resolve().parents[1];S=R/'assets/audio/attack-candidates';O=R/'game/audio/combat-v2';O.mkdir(exist_ok=True)
def edit(name,source,duration,filters=''):
 subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-y','-i',str(S/source),'-af',f'silenceremove=start_periods=1:start_threshold=-45dB,{filters+"," if filters else ""}atrim=duration={duration},afade=t=in:d=0.002,afade=t=out:st={duration-.035}:d=0.035,alimiter=limit=0.8:level=false','-ar','24000','-ac','1',str(O/f'{name}.wav')],check=True)
for name,source,duration,filters in [
 ('charged','swish-8.wav',.23,'highpass=f=200'),
 ('swing','swish-1.wav',.19,'highpass=f=280'),('swing_alt','swish-3.wav',.21,'highpass=f=400'),
 ('swing_reverse','swish-5.wav',.19,'highpass=f=350'),('swing_finisher','swish-9.wav',.29,'highpass=f=140'),
 ('kick','swish-12.wav',.115,'lowpass=f=5000'),('kick_alt','swish-13.wav',.11,'lowpass=f=5000'),
 ('enemy_blade','swish-7.wav',.27,'highpass=f=500'),('enemy_thrust','swish-11.wav',.16,'highpass=f=600'),
 ('kick_hit','kick.wav',.20,'highpass=f=65,lowpass=f=4500'),('kick_hit_alt','punch.wav',.20,'highpass=f=65,lowpass=f=4000'),
 ('enemy_fire','fireball.wav',.30,'highpass=f=100,lowpass=f=5000'),
 ('body','punch.wav',.18,'highpass=f=100'),('steel','sword-clash.wav',.25,'highpass=f=1300,volume=-12dB'),
 ('energy','laser-shot.wav',.32,'highpass=f=180,lowpass=f=7500')]: edit(name,source,duration,filters)
# Layer an armor contact from a short body transient and a quieter steel edge.
subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-y','-i',str(O/'body.wav'),'-i',str(O/'steel.wav'),'-filter_complex','[0:a][1:a]amix=inputs=2:normalize=0,alimiter=limit=0.8:level=false','-ar','24000','-ac','1',str(O/'armor.wav')],check=True)
subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-y','-i',str(O/'swing_finisher.wav'),'-i',str(O/'energy.wav'),'-filter_complex','[1:a]volume=0.35[e];[0:a][e]amix=inputs=2:normalize=0,alimiter=limit=0.8:level=false','-ar','24000','-ac','1',str(O/'power.wav')],check=True)
# Preserve originals; deterministic hue remapping only, no new drawing.
A=R/'game/art/pixel/combat-v2';raw=R/'assets/art/pixel/combat-v2';raw.mkdir(exist_ok=True)
for p in A.glob('*.png'):
 original=raw/p.name
 if not original.exists():shutil.copyfile(p,original)
 im=Image.open(original).convert('RGBA');pix=im.load()
 for y in range(im.height):
  for x in range(im.width):
   r,g,b,a=pix[x,y]
   if not a:continue
   v=max(r,g,b)
   if p.stem=='bolt': c=(245,235,208) if min(r,g,b)>180 else ((95,230,214) if v>150 else (30,123,135))
   else:c=(250,236,205) if min(r,g,b)>180 else ((244,116,89) if v>200 else ((190,44,62) if v>130 else (104,25,48)))
   pix[x,y]=(*c,255 if a>=128 else 0)
 im.save(p)
# Store path-keyed timing so unrelated clips with equal basenames never collide.
timing=json.loads((R/'game/data/audio_timing.json').read_text())
for p in O.glob('*.wav'):
 with wave.open(str(p)) as w:
  rate=w.getframerate();a=struct.unpack('<'+'h'*w.getnframes(),w.readframes(w.getnframes()));n=rate//200;b=[sum(v*v for v in a[i:i+n]) for i in range(0,len(a),n)]
 timing['res://audio/combat-v2/'+p.name]=round(b.index(max(b))*n/rate,4)
(R/'game/data/audio_timing.json').write_text(json.dumps(timing,indent=2)+'\n')
print('Built',len(list(O.glob('*.wav'))),'attack cues and five remapped pixel sheets')
