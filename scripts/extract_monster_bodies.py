"""Extract the 25 disconnected bodies, preserving full silhouettes across uneven sheet gutters."""
from PIL import Image
import numpy as np
from scipy.ndimage import label,binary_dilation,find_objects
from pathlib import Path
for n in range(1,5):
 im=Image.open(f'assets/enemies/monster-migration/source/{n}.png').convert('RGBA');a=np.array(im)
 lab,num=label(binary_dilation(a[:,:,3]>40,iterations=2));objs=find_objects(lab)
 ranked=sorted([(int((lab[s]==i+1).sum()),i+1,s) for i,s in enumerate(objs)],reverse=True)[:25]
 ranked.sort(key=lambda v:(v[2][0].start+v[2][0].stop)/2)
 ordered=[]
 for row in range(5): ordered.extend(sorted(ranked[row*5:row*5+5],key=lambda v:(v[2][1].start+v[2][1].stop)/2))
 for j,(_,ident,s) in enumerate(ordered):
  arr=a[s].copy();arr[:,:,3][lab[s]!=ident]=0
  crop=Image.fromarray(arr);ratio=min(120/crop.width,106/crop.height)
  crop=crop.resize((max(1,round(crop.width*ratio)),max(1,round(crop.height*ratio))),Image.Resampling.NEAREST)
  canvas=Image.new('RGBA',(128,128));canvas.alpha_composite(crop,((128-crop.width)//2,112-crop.height));canvas.save(f'game/art/monster-migration/{(n-1)*25+j+1:03}.png')
