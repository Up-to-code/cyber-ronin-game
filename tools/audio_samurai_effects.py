"""Original short contact/cloth/steel effects for Crimson Monastery; no external samples."""
from pathlib import Path
import math,random,struct,wave
OUT=Path(__file__).resolve().parents[1]/'game/audio'
RATE=44100
rng=random.Random(411)
def render(name,duration,fn):
    values=[]
    for i in range(int(RATE*duration)):
        t=i/RATE
        value=fn(t,i)
        # Tiny fade at both ends prevents transport clicks, no leading silence.
        edge=min(1,t/.0015,(duration-t)/.008)
        values.append(max(-.95,min(.95,value*max(0,edge))))
    peak=max(abs(v) for v in values) or 1
    gain=.74/peak
    with wave.open(str(OUT/(name+'.wav')),'wb') as f:
        f.setnchannels(1);f.setsampwidth(2);f.setframerate(RATE)
        f.writeframes(b''.join(struct.pack('<h',round(v*gain*32767)) for v in values))
def noise():return rng.uniform(-1,1)
# Filtered, accelerating blade air; no tonal beep or metallic rattle for a miss.
low=[0.]
def swish(t,i):
    low[0]=.78*low[0]+.22*noise()
    sweep=math.sin(math.pi*min(1,t/.15))**1.4 if t<.15 else math.exp(-(t-.15)*65)*.03
    return (noise()*.30+low[0]*1.5)*sweep
render('katana_air',.19,swish)
# A short weighty contact with brief inharmonic steel overtones, not long knife scraping.
low=[0.]
def impact(t,i):
    low[0]=.62*low[0]+.38*noise()
    thud=math.sin(2*math.pi*(92*t-42*t*t))*math.exp(-t*38)*.60
    steel=sum(math.sin(2*math.pi*f*t)*a for f,a in [(1960,.12),(2723,.07),(3650,.035)])*math.exp(-t*48)
    return thud+steel+low[0]*math.exp(-t*65)*.9
render('katana_contact',.16,impact)
# Light cloth lift with a low sole push; takeoff should not whistle.
low=[0.]
def takeoff(t,i):
    low[0]=.88*low[0]+.12*noise()
    return (low[0]*1.4+math.sin(2*math.pi*135*t)*.08)*math.exp(-t*38)
render('takeoff_cloth',.13,takeoff)
# Two stone grit ticks over a low heel contact. Same material for steps and landing.
def step(t,i):
    grit=noise()*(math.exp(-t*90)+.4*math.exp(-abs(t-.025)*180))*.25
    sole=math.sin(2*math.pi*115*t)*math.exp(-t*48)*.30
    return grit+sole
render('step_stone',.10,step)
def landing(t,i):
    return step(t,i)*.65+math.sin(2*math.pi*(68*t-15*t*t))*math.exp(-t*24)*.4+noise()*math.exp(-t*55)*.12
render('landing_stone',.18,landing)
low=[0.]
def dodge(t,i):
    low[0]=.92*low[0]+.08*noise()
    return low[0]*math.sin(math.pi*t/.16)**1.1
render('dash_cloth',.16,dodge)
def hurt(t,i):
    return (math.sin(2*math.pi*84*t)*.32+noise()*.13)*math.exp(-t*30)
render('body_hurt',.17,hurt)
def shrine(t,i):
    return sum(math.sin(2*math.pi*f*t)*a for f,a in [(659.25,.34),(1318.5,.12),(1840,.035)])*math.exp(-t*4.5)
render('shrine_bell',1.2,shrine)
def select(t,i):
    return (math.sin(2*math.pi*440*t)+math.sin(2*math.pi*660*t)*.25)*math.exp(-t*100)
render('menu_wood',.055,select)
print('Generated 9 original samurai contact/cloth/stone effects; peaks normalized to -2.6 dBFS')
