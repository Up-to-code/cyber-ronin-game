"""Ground-only multi-source mix. Does not touch walking, jump or attack cues."""
from pathlib import Path
import subprocess,json,shutil
R=Path(__file__).resolve().parents[1];S=R/'assets/audio/ground-candidates';O=R/'game/audio/ground-v3';O.mkdir(exist_ok=True)
Q=R/'docs/qa/ground-v3';Q.mkdir(exist_ok=True)
def run(args):subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-y',*map(str,args)],check=True)
run(['-i',S/'jumpland.wav','-af','silenceremove=start_periods=1:start_threshold=-45dB,highpass=f=65,lowpass=f=6000,atrim=duration=0.30,afade=t=in:d=0.002,afade=t=out:st=0.24:d=0.06','-ar','24000','-ac','1',O/'landing.wav'])
run(['-i',S/'extracted/qubodupImpact/qubodupImpactStone.flac','-af','silenceremove=start_periods=1:start_threshold=-45dB,highpass=f=140,lowpass=f=6500,atrim=duration=0.26,afade=t=in:d=0.002,afade=t=out:st=0.19:d=0.07','-ar','24000','-ac','1',O/'stone.wav'])
# Heavy ground contact combines a boot/body landing with a quieter stone texture.
run(['-i',O/'landing.wav','-i',O/'stone.wav','-filter_complex','[1:a]volume=0.3[s];[0:a][s]amix=inputs=2:normalize=0,alimiter=limit=0.8:level=false','-ar','24000','-ac','1',O/'landing_heavy.wav'])
run(['-i',O/'landing.wav','-i',O/'stone.wav','-filter_complex','[0:a]volume=0.6[b];[b][1:a]amix=inputs=2:normalize=0,alimiter=limit=0.8:level=false','-ar','24000','-ac','1',O/'slam.wav'])
# Four pairs at playback gains; a candidate comparison, not a quality verdict.
items=[('light',R/'game/audio/foley/designed/land_light.wav',O/'landing.wav',-21),('heavy',R/'game/audio/foley/designed/land_heavy.wav',O/'landing_heavy.wav',-14),('slam',R/'game/audio/foley/impactSoft_heavy_000.ogg',O/'slam.wav',-12)]
slots=[];timeline=[]
for name,before,after,gain in items:
 for tag,path in [('before',before),('new',after)]:
  output=Q/f'{name}-{tag}.wav';run(['-i',path,'-af',f'volume={gain}dB,apad=whole_dur=1.2,atrim=duration=1.2','-ar','24000','-ac','1',output]);slots.append(output);timeline.append({'at':round((len(slots)-1)*1.2,1),'cue':name,'version':tag})
manifest=Q/'concat.txt';manifest.write_text('\n'.join("file '"+str(p)+"'" for p in slots));run(['-f','concat','-safe','0','-i',manifest,Q/'ground-comparison.wav']);(Q/'timeline.json').write_text(json.dumps(timeline,indent=2)+'\n')
print('Built landing from MentalSanityOff and stone contact from qubodup; preserved source tails')
