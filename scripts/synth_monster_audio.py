import wave,math,random,struct,pathlib
rng=random.Random(814)
for element,base in [('blood',150),('fire',85),('frost',760),('thunder',62),('void',210),('water',390)]:
 for cue in ['cast','contact']:
  rate=22050;duration=.24 if cue=='cast' else .17;n=int(rate*duration);values=[];phase=0
  for i in range(n):
   t=i/rate;p=i/n;env=min(1,p*30)*(1-p)**(1.5 if cue=='cast' else 3)
   f=base*((.65+p*.85) if cue=='cast' else (1.8-p*1.3));phase+=math.tau*f/rate
   noise=rng.uniform(-1,1)
   if element=='fire':v=noise*.7+math.sin(phase)*.3
   elif element=='frost':v=math.sin(phase)+.35*math.sin(phase*2.73)
   elif element=='thunder':v=noise*.5+(.5 if math.sin(phase)>0 else -.5)
   elif element=='void':v=math.sin(phase)*math.sin(math.tau*t*17)+.3*math.sin(phase*.51)
   elif element=='water':v=math.sin(phase+math.sin(t*80)*3)*.7+noise*.1
   else:v=math.sin(phase)*.55+noise*.45
   values.append(int(max(-1,min(1,v*env*.42))*32767))
  with wave.open(f'game/audio/monster-elements/{element}_{cue}.wav','wb') as w:w.setnchannels(1);w.setsampwidth(2);w.setframerate(rate);w.writeframes(struct.pack('<'+'h'*len(values),*values))
pathlib.Path('game/audio/monster-elements/LICENSE.txt').write_text('Original synthesized waveforms authored for Ashen Veil. No sampled third-party audio. Deterministic oscillator/noise synthesis, 22050 Hz mono.\n')
