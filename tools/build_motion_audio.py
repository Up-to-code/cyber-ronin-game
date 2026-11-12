"""Finalize recorded transients and measure movement leads. Run after existing audio builders."""
from pathlib import Path
import wave, struct, json, subprocess, shutil
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'game/audio/foley/designed'
QA=ROOT/'docs/qa/motion-audio'; QA.mkdir(parents=True,exist_ok=True)
def peak(path):
 with wave.open(str(path)) as w:
  rate=w.getframerate(); samples=struct.unpack('<'+'h'*w.getnframes(), w.readframes(w.getnframes()))
 hop=rate//200
 bins=[sum(x*x for x in samples[i:i+hop]) for i in range(0,len(samples),hop)]
 return bins.index(max(bins))*hop/rate
# Keep the existing palette. Remove the delayed build-up from contact/takeoff cues,
# never move collision or damage to compensate for a slow recording.
for name in ['land_light','air_jump','impact','kick_hit','kick_hit_alt','enemy_fire']:
 path=OUT/f'{name}.wav'; before=QA/f'{name}-before.wav'
 if not before.exists(): shutil.copyfile(path,before)
 # Always rebuild from the archived input, so repeated runs are deterministic.
 start=max(0,peak(before)-.005)
 subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-y','-i',str(before),'-af',f'atrim=start={start},asetpts=PTS-STARTPTS,afade=t=in:d=0.002','-ar','24000','-ac','1',str(path)],check=True)
leads={p.name:round(peak(p),4) for p in OUT.glob('*.wav')}
(ROOT/'game/data/audio_timing.json').write_text(json.dumps(leads,indent=2)+'\n')
# A/B contact transients at the actual game gains, 1-second slots.
segments=[]
for name,gain in [('land_light',-21),('air_jump',-20),('kick_hit',-10),('impact',-10)]:
 for version,source in [('before',QA/f'{name}-before.wav'),('after',OUT/f'{name}.wav')]:
  dest=QA/f'{name}-{version}-slot.wav'
  subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-y','-i',str(source),'-af',f'volume={gain}dB,apad=whole_dur=1,atrim=duration=1','-ar','24000','-ac','1',str(dest)],check=True); segments.append(dest)
manifest=QA/'concat.txt';manifest.write_text('\n'.join("file '"+str(p)+"'" for p in segments))
subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-y','-f','concat','-safe','0','-i',str(manifest),str(QA/'contact-before-after.wav')],check=True)
print(json.dumps(leads))
