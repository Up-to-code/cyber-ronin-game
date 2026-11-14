"""Register authored whole-character movement drawings; no pose synthesis."""
from pathlib import Path
from PIL import Image, ImageOps
import statistics, json
ROOT=Path(__file__).resolve().parents[1]
source=Image.open(ROOT/'assets/art/pixel/enemy-movement/raw.png').convert('RGBA')
source.putalpha(source.getchannel('A').point(lambda a:255 if a>=210 else 0))
assert source.size==(2048,768),source.size
atlas=Image.new('RGBA',(1024,384)); records=[]
def anchor(cell,row):
    box=cell.getbbox(); cutoff=box[1]+(box[3]-box[1])*.43
    pts=[(x,y) for y in range(box[1],box[3]) for x in range(box[0],box[2]) if (row==2 or y<cutoff) and (lambda c:c[3]>0 and c[0]>165 and c[1]>135 and c[2]>105)(cell.getpixel((x,y)))]
    assert pts
    return (statistics.mean(x for x,y in pts),statistics.mean(y for x,y in pts))
for row in range(3):
    cells=[source.crop((i*256,row*256,(i+1)*256,(row+1)*256)) for i in range(8)]
    factor=58/statistics.median(c.getbbox()[3]-c.getbbox()[1] for c in cells)
    for i,c in enumerate(cells):
        head=anchor(c,row); bottom=c.getbbox()[3]
        c=ImageOps.mirror(c).resize((round(256*factor),round(256*factor)),Image.Resampling.NEAREST)
        dx=round([70,68,64][row]-(256-head[0])*factor)
        dy=round(68-head[1]*factor) if row==2 else round(112-bottom*factor)
        out=Image.new('RGBA',(128,128));out.alpha_composite(c,(dx,dy))
        atlas.alpha_composite(out,(i*128,row*128))
        packed=anchor(out,row)
        records.append({'row':row,'column':i,'head':packed,'bottom':out.getbbox()[3],'scale':factor})
alpha=atlas.getchannel('A')
palette=Image.open(ROOT/'game/art/pixel/enemies-redraw.png').convert('RGB').quantize(colors=48,dither=Image.Dither.NONE)
atlas=atlas.convert('RGB').quantize(palette=palette,dither=Image.Dither.NONE).convert('RGBA');atlas.putalpha(alpha)
# Recheck the mask anchor after palette quantization, whose color thresholds
# can otherwise move the measured ivory center by a pixel.
for col in range(8):
    cell=atlas.crop((col*128,256,(col+1)*128,384))
    pts=[(x,y) for y in range(128) for x in range(128) if (lambda p:p[3]>0 and p[0]>165 and p[1]>135 and p[2]>105)(cell.getpixel((x,y)))]
    registered=Image.new('RGBA',(128,128))
    registered.alpha_composite(cell,(round(64-statistics.mean(x for x,y in pts)),round(68-statistics.mean(y for x,y in pts))))
    atlas.paste(registered,(col*128,256))
atlas.save(ROOT/'game/art/pixel/enemy-movement.png')
atlas.resize((2048,768),Image.Resampling.NEAREST).save(ROOT/'assets/art/pixel/enemy-movement/contact-sheet.png')
for record in records:
    cell=atlas.crop((record['column']*128,record['row']*128,(record['column']+1)*128,(record['row']+1)*128))
    record['head']=anchor(cell,record['row'])
    record['bottom']=cell.getbbox()[3]
(ROOT/'assets/art/pixel/enemy-movement/registration.json').write_text(json.dumps(records,indent=2)+'\n')
for row,kind in enumerate(('guard','fire','wraith')):
    path=ROOT/'game/animation/profiles'/f'{kind}_pixel.json';profile=json.loads(path.read_text())
    def frame(i,contact=False):
        f={'rect':[i*128,row*128,128,128],'duration_ms':100}
        if contact:f['events']=['foot_contact']
        return f
    profile['clips']['walk']={'atlas':'res://art/pixel/enemy-movement.png','frames':[frame(i,i in (0,4)) for i in range(8)],'loop':True,'stride_world':96}
    profile['clips']['float']={'atlas':'res://art/pixel/enemy-movement.png','frames':[frame(i) for i in (0,1,2,3,4,6,7)],'loop':True}
    profile['status']='Whole-character pixel enemy with separate movement atlas and action key poses; several generated movement drawings are near repeats, not a complete high-frame animation.'
    profile['movement_status']='Eight source movement drawings, several near repeats; uniform per-character scale, registered head/mask and ground baseline; distance cadence96worldpx.'
    path.write_text(json.dumps(profile,indent=2)+'\n')
