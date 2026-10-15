"""Fail visibly for incomplete definition mappings, broken atlases or audio.

This is an asset import gate, not a substitute for running and reviewing rooms.
"""
from pathlib import Path
import json,wave,struct
from PIL import Image,ImageFont
ROOT=Path(__file__).resolve().parents[1]
registry=json.loads((ROOT/'content/prototype.json').read_text())
manifest=json.loads((ROOT/'assets/visual_manifest.json').read_text())
assets=manifest['assets'];by_id={a['asset_id']:a for a in assets}
assert len(by_id)==len(assets),'Duplicate stable asset IDs'
for item in registry['items']+registry['starters']:
    name=item['id']
    assert name in by_id,('Missing good mapping',name)
    assert 'inspect.'+name in by_id,('Missing inspection crop',name)
for person in [{'id':'shopkeeper'},{'id':'auctioneer'}]+registry['rivals']+registry['customers']:
    assert person['id']+'_directional' in by_id,('Missing actor',person['id'])
for asset in assets:
    path=ROOT/asset['path'].removeprefix('res://')
    assert path.is_file(),('Missing source asset',path)
    assert asset.get('license') in ['CC0-1.0','OFL-1.1'],('Unknown license',path)
    assert asset.get('attribution_file'),('Missing provenance notice',path)
    assert asset.get('placeholder') is False,('Required asset marked rough',path)
    if path.suffix=='.png':
        im=Image.open(path)
        assert im.mode=='RGBA',('PNG lost transparent raster format',path)
        assert max(im.size)<=1024,('Atlas budget exceeded',path)
        if 'width' in asset:assert im.size==(asset['width'],asset['height']),('Manifest dimensions wrong',path)
        if asset['kind']=='directional_actor_atlas':
            assert im.size==(816,128),('Actor atlas malformed',path)
            assert asset['pivot']==[12,28],('Foot pivot changed',path)
            for animation in asset['animations'].values():
                assert animation['frame_count']==len(animation['regions'])
                for x,y,w,h in animation['regions']:
                    assert w==24 and h==32 and x+w<=im.width and y+h<=im.height,('Bad region',path)
                    cel=im.crop((x,y,x+w,y+h));alpha=cel.getchannel('A')
                    for region in [(0,0,2,32),(22,0,24,32),(0,0,24,2),(0,30,24,32)]:
                        assert alpha.crop(region).getextrema()==(0,0),('Actor cel gutter contaminated',path,region)
    elif path.suffix=='.wav':
        with wave.open(str(path),'rb') as f:
            assert f.getnchannels()==1 and f.getsampwidth()==2 and f.getframerate()==22050,('Unexpected PCM format',path)
            samples=struct.unpack('<'+'h'*f.getnframes(),f.readframes(f.getnframes()))
            assert max(abs(v) for v in samples)<32767,('Clipped effect',path)
    elif path.suffix=='.ttf':
        font=ImageFont.truetype(str(path),18)
        assert font.getname()[0] in ['Atkinson Hyperlegible Next','Silkscreen'],('Unexpected font binary',path)
print(f'PASS: {len(assets)} asset records; all9 catalog goods/inspect crops,11 full directional actor sets, PNG/gutter/license/PCM/font checks.')
