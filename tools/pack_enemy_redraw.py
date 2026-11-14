"""Alpha clean, uniformly scale and register model-drawn enemy poses; no pose synthesis."""
from PIL import Image, ImageOps
from pathlib import Path
import statistics
ROOT = Path(__file__).resolve().parents[1]
source = Image.open(ROOT / 'assets/art/pixel/enemies-redraw/raw.png').convert('RGBA')
source.putalpha(source.getchannel('A').point(lambda a: 255 if a >= 210 else 0))
atlas = Image.new('RGBA', (1024,384))
# Original art faces left. Registration is a per-character support/mask anchor,
# held fixed across drawings instead of fitting each drawing to a different box.
anchor_x = [145,140,100]
for row in range(3):
    cells = [source.crop((col*256,row*256,(col+1)*256,(row+1)*256)) for col in range(8)]
    heights = [cell.getbbox()[3]-cell.getbbox()[1] for cell in cells[:4]]
    scale = 58 / statistics.median(heights)
    for col, cell in enumerate(cells):
        bottom = cell.getbbox()[3]
        cell = ImageOps.mirror(cell)
        size = (round(256*scale),round(256*scale))
        cell = cell.resize(size,Image.Resampling.NEAREST)
        canvas = Image.new('RGBA',(128,128))
        at = (round(64-(256-anchor_x[row])*scale),round(112-bottom*scale))
        canvas.alpha_composite(cell,at)
        atlas.alpha_composite(canvas,(col*128,row*128))
# Wraith cloth changes length across poses. Pin the ivory mask rather than
# each pose's lowest cloth pixel, which previously moved the face by28worldpx.
for col in range(7):
    cell=atlas.crop((col*128,256,(col+1)*128,384))
    points=[(x,y) for y in range(128) for x in range(128) if (lambda p:p[3]>0 and p[0]>165 and p[1]>135 and p[2]>105)(cell.getpixel((x,y)))]
    cx=statistics.mean(x for x,y in points);cy=statistics.mean(y for x,y in points)
    registered=Image.new('RGBA',(128,128))
    registered.alpha_composite(cell,(round(64-cx),round(68-cy)))
    atlas.paste(registered,(col*128,256))
alpha = atlas.getchannel('A')
atlas = atlas.convert('RGB').quantize(colors=48,dither=Image.Dither.NONE).convert('RGBA')
atlas.putalpha(alpha)
# Recheck the mask anchor after palette quantization, whose color thresholds
# can otherwise move the measured ivory center by a pixel.
for col in range(7):
    cell=atlas.crop((col*128,256,(col+1)*128,384))
    pts=[(x,y) for y in range(128) for x in range(128) if (lambda p:p[3]>0 and p[0]>165 and p[1]>135 and p[2]>105)(cell.getpixel((x,y)))]
    registered=Image.new('RGBA',(128,128))
    registered.alpha_composite(cell,(round(64-statistics.mean(x for x,y in pts)),round(68-statistics.mean(y for x,y in pts))))
    atlas.paste(registered,(col*128,256))
atlas.save(ROOT / 'game/art/pixel/enemies-redraw.png')
# Native-size board for checking identity and pose registration, not a motion claim.
atlas.resize((2048,768),Image.Resampling.NEAREST).save(ROOT/'assets/art/pixel/enemies-redraw/contact-sheet.png')
