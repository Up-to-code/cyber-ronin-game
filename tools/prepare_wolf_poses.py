from PIL import Image
from pathlib import Path
source=Image.open('assets/monster-motion/source/ash-wolf-poses.png').convert('RGBA')
for index,(left,right) in enumerate([(0,640),(640,1510),(1510,source.width)]):
    crop=source.crop((left,0,right,source.height))
    crop=crop.crop(crop.getbbox())
    crop=crop.resize((round(crop.width*.15),round(crop.height*.15)),Image.Resampling.NEAREST)
    frame=Image.new('RGBA',(128,128))
    frame.alpha_composite(crop,((128-crop.width)//2,112-crop.height-(16 if index==1 else 0)))
    frame.save(f'game/art/monster-motion/wolf{index}.png')
