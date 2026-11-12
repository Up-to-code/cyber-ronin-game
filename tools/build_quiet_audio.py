"""Pack existing licensed composer takes as tail/head-crossfaded loops. No new composition."""
import array, math, subprocess, wave
from pathlib import Path
root=Path(__file__).resolve().parents[1]
for source,name in [('Moonlight Japanese Harp.mp3','moonlight_loop'),('Mysterious Kyoto.mp3','kyoto_tension_loop')]:
    raw=subprocess.check_output(['ffmpeg','-v','error','-i',str(root/'game/audio/music_source'/source),'-f','f32le','-ac','2','-ar','24000','-'])
    samples=array.array('f');samples.frombytes(raw)
    overlap=48000*2
    end=len(samples)-overlap
    for i in range(overlap):
        t=i/(overlap-1)
        samples[i]=samples[end+i]*(1-t)+samples[i]*t
    packed=array.array('h',(int(max(-1,min(1,v))*32767) for v in samples[:end]))
    temp=Path('/tmp')/(name+'.wav')
    with wave.open(str(temp),'wb') as f:
        f.setparams((2,2,24000,0,'NONE','not compressed'));f.writeframes(packed.tobytes())
    subprocess.run(['ffmpeg','-y','-v','error','-i',str(temp),'-c:a','vorbis','-strict','-2','-q:a','4',str(root/'game/audio'/(name+'.ogg'))],check=True)
    temp.unlink()
    print(name,len(packed)/48000,'seconds')
