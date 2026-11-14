from PIL import Image
import pathlib,shutil,hashlib,json
files=['94a14b13-ff9f-422f-ad93-21d174054ea7','7df16b9f-168e-45e5-b1a3-90935198db7f','ebe95ea8-1da1-4fc8-b355-a508f6cc2332','45d8cd10-4f37-4e7a-b479-30f725406a9e']
manifest=[]
for sheet,f in enumerate(files):
 src=pathlib.Path('/Users/ahmedmansour/.codex/generated_images/01a1d454-24c8-70e3-85d5-319c1b813e6e')/('exec-'+f+'.png');dest=pathlib.Path(f'assets/enemies/monster-migration/motifs/source-{sheet+1}.png');shutil.copyfile(src,dest)
 im=Image.open(src).convert('RGBA');w,h=im.size
 for j in range(25):
  x=j%5;y=j//5;crop=im.crop((round(x*w/5)+2,round(y*h/5)+2,round((x+1)*w/5)-2,round((y+1)*h/5)-2))
  # Remove barely visible generator haze; maintain crisp clusters with nearest sampling.
  alpha=crop.getchannel('A');alpha=alpha.point(lambda p:0 if p<28 else p);crop.putalpha(alpha)
  crop.thumbnail((120,120),Image.Resampling.NEAREST);out=Image.new('RGBA',(128,128));out.alpha_composite(crop,((128-crop.width)//2,(128-crop.height)//2));idx=sheet*25+j+1;path=pathlib.Path(f'game/art/monster-motifs/{idx:03}.png');out.save(path)
  manifest.append({'id':idx,'texture':str(path),'sha256':hashlib.sha256(path.read_bytes()).hexdigest()})
pathlib.Path('assets/enemies/monster-migration/motifs/manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
assert len({m['sha256'] for m in manifest})==100
print('100 distinct motif hashes')
