"""Reproducible recorded-material edits plus before/after audition. No synthesis."""
from pathlib import Path
import subprocess, json
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'game/audio/foley/designed';QA=ROOT/'docs/qa/audio-audition'
OUT.mkdir(exist_ok=True);QA.mkdir(exist_ok=True)
def run(args):subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-y',*map(str,args)],check=True)
specs={
 'jump':('footstep02.ogg',.11,'highpass=f=90,lowpass=f=2600'),
 'air_jump':('cloth1.ogg',.13,'highpass=f=250,lowpass=f=4200'),
 'kick_alt':('cloth2.ogg',.14,'highpass=f=180,lowpass=f=4500'),
 'kick_hit_alt':('impactPunch_medium_000.ogg',.19,'highpass=f=65,lowpass=f=2400'),
 'kick':('cloth3.ogg',.14,'highpass=f=180,lowpass=f=4500'),
 'kick_hit':('impactPunch_heavy_000.ogg',.19,'highpass=f=65,lowpass=f=2400'),
 'swing_alt':('cloth2.ogg',.16,'highpass=f=400,lowpass=f=7000'),
 'swing':('cloth1.ogg',.16,'highpass=f=400,lowpass=f=7000'),
 'impact':('impactPunch_medium_000.ogg',.14,'highpass=f=180,lowpass=f=5200'),
 'land':('impactSoft_heavy_000.ogg',.16,'highpass=f=75,lowpass=f=2800'),
}
for cue,(source,duration,eq) in specs.items():
 run(['-i',ROOT/'game/audio/foley'/source,'-af',f'silenceremove=start_periods=1:start_threshold=-48dB,{eq},atrim=duration={duration},afade=t=in:d=0.003,afade=t=out:st={duration-.035}:d=0.035','-ar','24000','-ac','1',OUT/f'{cue}.wav'])
# Audition reproduces cue gain; music excerpts are six seconds, with no source export.
old={'jump':'cloth2.ogg','kick':'cloth2.ogg','swing':'cloth1.ogg','kick_hit':'impactPunch_heavy_000.ogg','impact':'impactPunch_medium_000.ogg'}
gains={'jump':(-21,-18),'kick':(-15,-14),'swing':(-13,-12),'kick_hit':(-10,-10),'impact':(-10,-10)}
segments=[];timeline=[];cursor=0
for cue,src in old.items():
 for kind in ['before','after']:
  path=ROOT/'game/audio/foley'/src if kind=='before' else OUT/f'{cue}.wav'
  gain=gains[cue][kind=='after'];dest=QA/f'{cue}-{kind}.wav'
  run(['-i',path,'-af',f'volume={gain}dB,apad=whole_dur=1.2,atrim=duration=1.2','-ar','24000','-ac','1',dest])
  timeline.append({'start':round(cursor,1),'end':round(cursor+1.2,1),'cue':cue,'version':kind});cursor+=1.2;segments.append(dest)
for title,source in [('earlier_music','exploration_music.ogg'),('current_music','moonlight_loop.ogg')]:
 dest=QA/f'{title}.wav'
 run(['-ss','8','-i',ROOT/'game/audio'/source,'-t','6','-af','volume=-21dB,afade=t=in:d=0.3,afade=t=out:st=5.5:d=0.5','-ar','24000','-ac','1',dest]);segments.append(dest)
 timeline.append({'start':round(cursor,1),'end':round(cursor+6,1),'cue':title,'version':'music comparison'});cursor+=6
manifest=QA/'concat.txt';manifest.write_text('\n'.join("file '"+str(p)+"'" for p in segments))
run(['-f','concat','-safe','0','-i',manifest,'-c:a','pcm_s16le',QA/'comparison.wav'])
(QA/'timeline.json').write_text(json.dumps(timeline,indent=2))
print('Audition seconds:',cursor)
