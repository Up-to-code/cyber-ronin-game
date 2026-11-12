"""Deterministic export of image-generated jungle art. Does not draw raw artwork."""
from pathlib import Path
from PIL import Image

SOURCE = Path('assets/pixel/jungle')
OUTPUT = Path('game/art/pixel')

def clean(im: Image.Image, colors: int = 12) -> Image.Image:
    im = im.convert('RGBA')
    alpha = im.getchannel('A').point(lambda value: 255 if value >= 128 else 0)
    im = im.convert('RGB').quantize(colors=colors, dither=Image.Dither.NONE).convert('RGBA')
    im.putalpha(alpha)
    return im

def process() -> None:
    cap = clean(Image.open(SOURCE / 'surface.raw.png'))
    cap = cap.crop(cap.getbbox())
    cap = cap.resize((256, 16), Image.Resampling.NEAREST).crop((0, 0, 256, 12))
    cap.save(OUTPUT / 'jungle_surface.png')
    roots = Image.open(SOURCE / 'roots.raw.png').convert('RGBA')
    atlas = Image.new('RGBA', (128, 128))
    for index in range(4):
        col, row = index % 2, index // 2
        cell = roots.crop((col * roots.width // 2, row * roots.height // 2,
                           (col + 1) * roots.width // 2, (row + 1) * roots.height // 2))
        cell = clean(cell)
        cell = cell.crop(cell.getbbox())
        scale = min(58 / cell.width, 60 / cell.height)
        cell = cell.resize((round(cell.width * scale), round(cell.height * scale)), Image.Resampling.NEAREST)
        atlas.paste(cell, (col * 64 + (64 - cell.width) // 2, row * 64 + 2))
    atlas.save(OUTPUT / 'jungle_roots.png')
    for path in (OUTPUT / 'jungle_surface.png', OUTPUT / 'jungle_roots.png'):
        im = Image.open(path)
        assert im.mode == 'RGBA' and im.getchannel('A').getextrema() == (0, 255), path
        print(path, im.size)

if __name__ == '__main__':
    process()
