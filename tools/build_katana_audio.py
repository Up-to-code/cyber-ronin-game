"""TK samurai recordings edited for gameplay; never export a standalone source library."""
from pathlib import Path
import subprocess,json,wave,struct
R=Path(__file__).resolve().parents[1];S=R/'assets/audio/tk-samurai';O=R/'game/audio/katana-v4';O.mkdir(exist_ok=True)
def edit(name,source,start,duration,filters=''):
 subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-y','-ss',str(start),'-i',str(S/(source+'.mp3')),'-af',f'{filters+"," if filters else ""}atrim=duration={duration},afade=t=in:d=0.002,afade=t=out:st={duration-.04}:d=0.04,alimiter=limit=0.8:level=false','-ar','24000','-ac','1',str(O/(name+'.wav'))],check=True)
for args in [('cut','sword_attack1',.125,.24,'highpass=f=250'),('cut_alt','sword_attack2',.035,.23,'highpass=f=250'),('reverse','sword_attack2',.035,.23,'asetrate=52800,aresample=24000'),('heavy','sword_attack1',.125,.28,'asetrate=38000,aresample=24000,highpass=f=150'),('contact','cutting_with_a_katana1',.205,.22,'highpass=f=120'),('contact_alt','cutting_with_a_katana2',.175,.25,'highpass=f=120')]:edit(*args)
subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-y','-i',str(O/'contact.wav'),'-i',str(R/'game/audio/combat-v2/steel.wav'),'-filter_complex','[1:a]volume=0.45[s];[0:a][s]amix=inputs=2:normalize=0,alimiter=limit=0.8:level=false','-ar','24000','-ac','1',str(O/'armor.wav')],check=True)
timing=json.loads((R/'game/data/audio_timing.json').read_text())
for p in O.glob('*.wav'):
 with wave.open(str(p)) as w:
  rate=w.getframerate();data=struct.unpack('<'+'h'*w.getnframes(),w.readframes(w.getnframes()));n=rate//200;energy=[sum(x*x for x in data[i:i+n]) for i in range(0,len(data),n)]
 timing['res://audio/katana-v4/'+p.name]=round(energy.index(max(energy))*n/rate,4)
(R/'game/data/audio_timing.json').write_text(json.dumps(timing,indent=2)+'\n')
print('Prepared seven katana-specific gameplay cues; draw sound remains an unused reference')
