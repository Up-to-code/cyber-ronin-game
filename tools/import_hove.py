from pathlib import Path
import subprocess,json,wave,struct
R=Path(__file__).resolve().parents[1];S=R/'assets/audio/hove/Sword Combat Sound Effects Pack FREE VERSION';O=R/'game/audio/hove';O.mkdir(exist_ok=True)
t=json.loads((R/'game/data/audio_timing.json').read_text());files=[]
for p in sorted(S.rglob('*.wav')):
 out=O/p.name
 subprocess.run(['ffmpeg','-v','error','-y','-i',str(p),'-af','silenceremove=start_periods=1:start_threshold=-48dB,afade=t=in:d=0.002,alimiter=limit=0.8:level=false','-ar','24000','-ac','1',str(out)],check=True)
 with wave.open(str(out)) as w:
  rate=w.getframerate();d=struct.unpack('<'+'h'*w.getnframes(),w.readframes(w.getnframes()));n=rate//200;e=[sum(v*v for v in d[i:i+n]) for i in range(0,len(d),n)]
 t['res://audio/hove/'+p.name]=round(e.index(max(e))*n/rate,4)
 files.append(p.name)
(R/'game/data/audio_timing.json').write_text(json.dumps(t,indent=2)+'\n')
p=R/'game/systems/audio.gd';s=p.read_text();start=s.index('\tfor i in range(12):')
def group(fragment):return [f for f in files if fragment in f]
mapping={'swing':group('WHSH_'),'swing_reverse':group('WHSH_')[::-1],'swing_finisher':group('WHSH_')[::-1],'charged_swing':group('WHSH_')[::-1],'kick':group('WHSH_'),'enemy_swing':group('WHSH_'),'enemy_thrust':group('WHSH_'),'enemy_heavy':group('WHSH_')[::-1],'ranged_swing':group('WHSH_'),'impact':group('WEAPSwrd_SwordStab_Hove'),'impact_armor':group('BaseMetal'),'hurt':group('DamageGrunt'),'power':group('MAGShim'),'energy_swing':group('MAGShim'),'impact_spirit':group('MAGShim')}
block='\t# Hove Audio: clean movement and contact layers remain separate.\n'
for cue,arr in mapping.items():
 if not arr:raise Exception(cue)
 block+='\tstreams["'+cue+'"] = preload("res://audio/hove/'+arr[0]+'")\n'
 block+='\tstream_variants["'+cue+'"] = ['+', '.join('preload("res://audio/hove/'+f+'")' for f in arr)+']\n'
s=s[:start]+block+s[start:];p.write_text(s)
(R/'game/audio/hove/manifest.json').write_text(json.dumps({'source':'https://hoveaudio.itch.io/sword-combat-sound-effects-pack-free-version','imported':files,'roles':mapping},indent=2))
print('Imported',len(files),'sounds')
