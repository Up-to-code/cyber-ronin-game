"""Role-specific edits of existing CC0 recordings; no new downloaded material."""
from pathlib import Path
import subprocess
root=Path(__file__).resolve().parents[1]; src=root/'game/audio/foley'; out=src/'designed'
specs={
'land_light':('footstep02.ogg',.15,'highpass=f=95,lowpass=f=3200'),
'land_heavy':('impactSoft_heavy_000.ogg',.28,'highpass=f=60,lowpass=f=2100'),
'swing_reverse':('cloth2.ogg',.21,'highpass=f=320,lowpass=f=6500'),
'swing_finisher':('cloth3.ogg',.27,'highpass=f=150,lowpass=f=5000'),
'enemy_blade':('cloth3.ogg',.22,'highpass=f=650,lowpass=f=7000'),
'enemy_fire':('cloth2.ogg',.34,'asetrate=22050,aresample=24000,highpass=f=100,lowpass=f=2100'),
'defeat':('impactSoft_heavy_000.ogg',1.05,'asetrate=16000,aresample=24000,lowpass=f=1000,aecho=0.8:0.5:130|290:0.22|0.12,apad'),
}
for name,(file,duration,filters) in specs.items():
 subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-y','-i',str(src/file),'-af',f'silenceremove=start_periods=1:start_threshold=-48dB,{filters},atrim=duration={duration},afade=t=in:d=0.003,afade=t=out:st={max(.03,duration-.08)}:d=0.08','-ar','24000','-ac','1',str(out/f'{name}.wav')],check=True)
