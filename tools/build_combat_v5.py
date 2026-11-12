"""Short action-specific cues: VD Sounds + artisticdude + SpritePilot; no locomotion edits."""
from pathlib import Path
import subprocess,json,wave,struct,shutil
R=Path(__file__).resolve().parents[1]; V=R/'assets/audio/vd-swords/medieval-combat-swords-sfx-lite'; A=R/'assets/audio/attack-candidates'; O=R/'game/audio/combat-v5';O.mkdir(exist_ok=True)
def cue(name,src,duration,filters):
 subprocess.run(['ffmpeg','-v','error','-y','-i',str(src),'-af',f'silenceremove=start_periods=1:start_threshold=-48dB,{filters},atrim=duration={duration},afade=t=in:d=0.002,afade=t=out:st={duration-.035}:d=0.035,alimiter=limit=0.8:level=false','-ar','24000','-ac','1',str(O/(name+'.wav'))],check=True)
for name,source,duration,filters in [
 ('cut','swing_light_01.wav',.17,'highpass=f=300,lowpass=f=8500'),
 ('cut_alt','swing_light_01.wav',.16,'asetrate=48000,aresample=24000,highpass=f=450'),
 ('reverse','swing_medium_01.wav',.21,'highpass=f=220,lowpass=f=7000'),
 ('heavy','swing_medium_01.wav',.27,'asetrate=38000,aresample=24000,highpass=f=160'),
 ('contact','slash_hit_01.wav',.15,'highpass=f=120,lowpass=f=6500'),
 ('contact_alt','slash_hit_02.wav',.16,'highpass=f=120,lowpass=f=6500'),
 ('armor','shield_block_iron_01.wav',.19,'highpass=f=300,lowpass=f=7000'),
 ('enemy','swing_medium_01.wav',.24,'highpass=f=500,lowpass=f=5000')]:cue(name,V/source,duration,filters)
for name,source,duration,filters in [
 ('kick','swish-12.wav',.10,'highpass=f=180,lowpass=f=2600'),
 ('kick_alt','swish-13.wav',.11,'highpass=f=180,lowpass=f=2600'),
 ('kick_hit','kick.wav',.13,'highpass=f=85,lowpass=f=3000'),
 ('kick_hit_alt','punch.wav',.14,'highpass=f=85,lowpass=f=3000'),
 ('energy','laser-shot.wav',.20,'highpass=f=400,lowpass=f=4200'),
 ('power','fireball.wav',.26,'highpass=f=120,lowpass=f=3200')]:cue(name,A/source,duration,filters)
timing=json.loads((R/'game/data/audio_timing.json').read_text())
for p in O.glob('*.wav'):
 with wave.open(str(p)) as w:
  rate=w.getframerate();d=struct.unpack('<'+'h'*w.getnframes(),w.readframes(w.getnframes()));n=rate//200;energy=[sum(v*v for v in d[i:i+n]) for i in range(0,len(d),n)]
 timing['res://audio/combat-v5/'+p.name]=round(energy.index(max(energy))*n/rate,4)
(R/'game/data/audio_timing.json').write_text(json.dumps(timing,indent=2)+'\n')
shutil.copyfile(V/'LICENSE.txt',R/'game/licenses/vd-swords-license.txt')
