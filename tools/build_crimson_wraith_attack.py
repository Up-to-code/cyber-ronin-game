"""Extract generated casting cels and register to the hover mask; no authored pixels."""
from PIL import Image
from pathlib import Path
import json,sys,shutil,statistics
raw=Path('assets/enemies/crimson-wraith');out=Path('game/art/crimson-wraith');shutil.copy2(sys.argv[1],raw/'attack-source.png')
im=Image.open(sys.argv[1]).convert('RGBA');frames=[]
def mask_points(im):
 return [(x,y) for y in range(im.height) for x in range(im.width) if im.getpixel((x,y))[3]>128 and min(im.getpixel((x,y))[:3])>125 and im.getpixel((x,y))[0]>im.getpixel((x,y))[2]]
for row in range(3):
 for col in range(2):
  f=im.crop((round(col*im.width/2),round(row*im.height/3),round((col+1)*im.width/2),round((row+1)*im.height/3)))
  px=f.load()
  for y in range(f.height):
   for x in range(f.width):
    r,g,b,a=px[x,y]
    if r>130 and b>100 and g<130 and min(r,b)>g*1.6:px[x,y]=(0,0,0,0)
  frames.append(f)
heights=[]
for f in frames:
 pts=mask_points(f);heights.append(max(y for x,y in pts)-min(y for x,y in pts)+1)
scale=32/statistics.median(heights);processed=[]
for f in frames:
 f=f.resize((round(f.width*scale),round(f.height*scale)),Image.Resampling.NEAREST)
 pts=mask_points(f);mx=sum(x for x,y in pts)/len(pts);my=sum(y for x,y in pts)/len(pts)
 canvas=Image.new('RGBA',(192,128));canvas.paste(f,(round(96-mx),round(68-my)));box=canvas.getbbox();assert box[0]>0 and box[1]>0 and box[2]<192 and box[3]<128
 processed.append(canvas)
atlas=Image.new('RGBA',(1152,128))
for i,f in enumerate(processed):atlas.paste(f,(192*i,0))
atlas.save(out/'attack.png');processed[0].save(out/'attack.webp',save_all=True,append_images=processed[1:],duration=[160,160,50,45,45,80],loop=0,lossless=True)
p=Path('game/animation/profiles/wraith_pixel.json');profile=json.loads(p.read_text());path='res://art/crimson-wraith/attack.png'
profile['clips']['windup']={'atlas':path,'loop':True,'frames':[{'rect':[i*192,0,192,128],'duration_ms':160} for i in [0,1]]}
profile['clips']['attack']={'atlas':path,'frames':[{'rect':[i*192,0,192,128],'duration_ms':ms} for i,ms in [(1,100),(2,50),(3,45),(4,45),(5,80)]]}
for name in ['windup','attack']:
 profile['clips'][name]['feet_origin']=[96,112]
 profile['clips'][name]['sockets']={key:[value[0]+32,value[1]] for key,value in profile['sockets'].items()}
profile['status']='Nine generated hover cels and six generated casting cels; original hurt/death poses retained.'
p.write_text(json.dumps(profile,indent=2)+'\n')
