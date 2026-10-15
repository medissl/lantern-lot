"""Lantern Lot original pixel drawings. Rebuild with Python + Pillow, no downloads.
All coordinates are authored at native resolution; no vector antialiasing.
"""
from pathlib import Path
from PIL import Image, ImageDraw
import json, math, wave, struct, random

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'assets' / 'pixel'
for folder in ['goods','furniture','decor','actors','environments','effects']:
    (OUT/folder).mkdir(parents=True,exist_ok=True)
P = dict(ink='#352c33', dark='#493538', wood='#73503e', grain='#906447', edge='#b88553', lightwood='#d4a06a', stone='#cdb394', stone2='#d5bd9d', grout='#ad947b', paper='#f2deb3', cream='#fff0ca', teal='#397f7d', teal2='#68aca0', teal3='#a9d7bf', red='#a85046', red2='#d77654', gold='#c69948', gold2='#f3cf73', blue='#486c88', blue2='#769faa', steel='#718b92', steel2='#bad0c7', skin='#d4a077', skin2='#f1c399', shadow='#7a675c', green='#56784d', green2='#8da460')
manifest=[]
def canvas(w,h):
    im=Image.new('RGBA',(w,h)); return im,ImageDraw.Draw(im)
def rect(d, box, c): d.rectangle(box,fill=P.get(c,c))
def poly(d, pts, c): d.polygon(pts,fill=P.get(c,c))
def line(d,pts,c,w=1): d.line(pts,fill=P.get(c,c),width=w)
def ellipse(d,box,c): d.ellipse(box,fill=P.get(c,c))
def save(im,folder,name,pivot,kind='sprite',animations=None):
    path=OUT/folder/(name+'.png');im.save(path)
    manifest.append(dict(asset_id=name,definition_id=name if kind=='good' and name!='covered' else None,actor_id=name.removesuffix('_directional') if kind in ['actor_sheet','directional_actor_atlas'] else None,path='res://'+path.relative_to(ROOT).as_posix(),output_atlas='res://'+path.relative_to(ROOT).as_posix(),region=[0,0,im.width,im.height],width=im.width,height=im.height,native_cel=[24,32] if 'actor' in kind else [im.width,im.height],pivot=list(pivot),footprint=[1,1] if kind=='good' else None,kind=kind,placeholder=False,creator='Lantern Lot implementation team (Codex-assisted original authored pixel clusters)',origin='original',source_url=None,license='CC0-1.0',commercial_use_basis='Original drawings dedicated under CC0-1.0; no reference pixels or downloaded components',modification_status='new original',editable_source='art/build_pixel_art.py',attribution_file='THIRD_PARTY_NOTICES.md',review_date='2026-10-14',review_scope='Contact-sheet native raster pixel inspection; runtime integration review tracked separately',animations=animations or {}))
def shadow(d,x1,y1,x2,y2): ellipse(d,(x1,y1,x2,y2),'shadow')

# GOODS: independent silhouettes, deliberate highlights and small material marks.
def goods(name):
    im,d=canvas(24,24)
    if name=='homewares.enamel_kettle':
        shadow(d,3,19,21,22); line(d,[(9,8),(9,4),(15,3),(18,6),(18,10)],'ink',2)
        line(d,[(11,5),(15,5),(16,7)],'steel2'); poly(d,[(7,10),(17,10),(19,14),(19,19),(16,21),(7,21),(5,18),(5,13)],'ink')
        poly(d,[(7,11),(16,11),(17,13),(18,18),(16,19),(7,19),(6,17)],'teal');rect(d,(7,12,9,17),'teal2');line(d,[(10,19),(15,19)],'teal3')
        poly(d,[(5,13),(2,10),(1,10),(2,16),(6,17)],'ink');poly(d,[(3,12),(5,14),(5,15),(3,14)],'teal2')
        rect(d,(8,9,16,10),'gold');rect(d,(9,9,14,9),'gold2');rect(d,(11,7,13,8),'ink');rect(d,(15,15,16,16),'cream')
    elif name=='homewares.folding_stool':
        shadow(d,2,20,22,22);poly(d,[(4,7),(18,7),(21,11),(17,14),(4,14),(2,11)],'ink');poly(d,[(5,8),(17,8),(19,10),(16,12),(4,12),(3,10)],'red');line(d,[(5,9),(16,9)],'red2')
        line(d,[(5,14),(17,21)],'wood',3);line(d,[(17,14),(5,21)],'wood',3);line(d,[(6,15),(15,20)],'edge');line(d,[(16,15),(7,20)],'lightwood');rect(d,(10,16,12,18),'steel2')
    elif name=='tools.desk_fan':
        shadow(d,3,20,21,23);poly(d,[(9,14),(15,14),(16,20),(20,21),(19,23),(4,23),(3,21),(8,20)],'ink');rect(d,(10,15,14,20),'teal');poly(d,[(6,21),(17,21),(18,22),(5,22)],'teal2')
        ellipse(d,(3,1,21,18),'ink');ellipse(d,(4,2,20,17),'steel');ellipse(d,(6,4,18,15),'dark');poly(d,[(12,9),(9,3),(6,7),(10,10)],'steel2');poly(d,[(12,9),(19,7),(17,13),(13,11)],'teal2');poly(d,[(12,10),(9,16),(6,12),(10,9)],'blue2')
        for x in [6,9,12,15,18]:line(d,[(x,4),(x,15)],'steel')
        line(d,[(5,7),(19,7)],'steel');line(d,[(5,12),(19,12)],'steel');ellipse(d,(10,8,14,12),'gold2');rect(d,(17,17,20,19),'paper')
    elif name=='tools.hand_drill':
        shadow(d,3,20,22,23);poly(d,[(5,3),(8,2),(10,6),(9,8),(7,8)],'ink');poly(d,[(6,3),(8,3),(9,6),(7,6)],'red2');rect(d,(7,8,9,18),'steel');rect(d,(8,9,12,11),'steel2')
        ellipse(d,(7,10,15,18),'ink');ellipse(d,(8,11,14,17),'gold');ellipse(d,(10,13,12,15),'dark');line(d,[(14,13),(18,13),(18,17)],'steel2',2);rect(d,(17,17,20,21),'wood');rect(d,(18,18,19,20),'edge');poly(d,[(8,18),(10,18),(9,23),(8,22)],'steel2')
    elif name=='homewares.serving_bowl':
        shadow(d,2,19,22,22);ellipse(d,(2,6,22,15),'ink');poly(d,[(3,10),(21,10),(19,18),(15,21),(8,21),(5,17)],'teal');poly(d,[(4,11),(7,12),(8,18),(10,20),(7,19),(5,16)],'teal2');ellipse(d,(3,7,21,14),'cream');ellipse(d,(5,8,19,12),'blue2');ellipse(d,(7,9,17,11),'paper');line(d,[(7,16),(17,16)],'gold2');rect(d,(10,20,15,21),'dark')
    elif name=='paper.tram_print':
        shadow(d,2,21,23,23);rect(d,(2,2,22,22),'ink');rect(d,(3,3,21,21),'wood');rect(d,(4,4,20,20),'gold');rect(d,(5,5,19,19),'paper');rect(d,(6,6,18,12),'blue2');rect(d,(6,13,18,18),'stone');line(d,[(6,18),(18,14)],'grout');rect(d,(8,9,16,16),'red');rect(d,(9,10,11,12),'cream');rect(d,(13,10,15,12),'cream');rect(d,(8,13,16,14),'gold2');rect(d,(9,16,10,17),'ink');rect(d,(14,16,15,17),'ink');line(d,[(12,9),(12,7),(16,6)],'ink');rect(d,(4,4,4,18),'lightwood')
    elif name=='practice.cup':
        shadow(d,3,20,22,23);poly(d,[(4,6),(16,6),(16,20),(13,22),(7,22),(4,19)],'ink');rect(d,(5,7,15,19),'steel');rect(d,(6,8,8,18),'steel2');poly(d,[(15,8),(21,8),(22,10),(22,16),(20,18),(16,18),(16,16),(19,16),(20,15),(20,11),(16,11)],'ink');line(d,[(17,9),(20,9),(21,11),(21,15)],'steel2');ellipse(d,(4,4,16,8),'steel2');ellipse(d,(6,5,14,7),'dark');line(d,[(11,11),(14,11)],'ink');line(d,[(12,14),(14,14)],'ink');line(d,[(11,17),(14,17)],'ink')
    elif name=='practice.square':
        shadow(d,2,20,22,23);poly(d,[(3,3),(8,3),(8,17),(21,17),(21,22),(3,22)],'ink');poly(d,[(4,4),(7,4),(7,18),(20,18),(20,21),(4,21)],'steel');line(d,[(4,4),(4,20),(19,20)],'steel2');
        for y in [6,9,12,15]:line(d,[(5,y),(6,y)],'ink')
        for x in [10,13,16,19]:line(d,[(x,18),(x,19)],'ink')
    elif name=='practice.folio':
        shadow(d,2,20,22,23);poly(d,[(3,4),(17,2),(21,6),(21,20),(6,22),(3,19)],'ink');poly(d,[(4,5),(17,3),(19,6),(19,19),(6,20),(4,18)],'red');poly(d,[(6,6),(18,4),(18,18),(6,20)],'paper');line(d,[(8,8),(16,7)],'grout');line(d,[(8,11),(15,10)],'grout');line(d,[(8,14),(16,13)],'grout');rect(d,(4,6,5,18),'red2');line(d,[(10,4),(10,20)],'wood');rect(d,(9,9,11,13),'gold2')
    elif name=='covered':
        shadow(d,2,19,22,23);poly(d,[(3,7),(17,5),(22,10),(21,20),(7,22),(2,18)],'ink');poly(d,[(4,8),(16,6),(21,11),(19,19),(7,20),(3,17)],'stone');poly(d,[(4,8),(16,6),(21,11),(8,13)],'paper');line(d,[(11,7),(10,12),(10,20)],'wood');line(d,[(4,13),(20,15)],'wood');rect(d,(12,13,16,15),'cream')
    return im
for name in ['homewares.enamel_kettle','homewares.folding_stool','tools.desk_fan','tools.hand_drill','homewares.serving_bowl','paper.tram_print','practice.cup','practice.square','practice.folio','covered']:
    save(goods(name),'goods',name,(12,22),'good')

def timber(d,x1,y1,x2,y2):
    rect(d,(x1,y1,x2,y2),'ink');rect(d,(x1+1,y1+1,x2-1,y2-1),'wood');line(d,[(x1+1,y1+1),(x2-1,y1+1)],'edge');line(d,[(x1+3,y1+3),(x2-4,y1+3)],'grain')
def furniture(name):
    sizes={'shelf':(64,48),'table':(48,32),'bench':(48,32),'counter':(64,40),'tray':(64,24),'cart':(40,40),'shutter':(96,64),'crate':(32,32),'parcel':(32,24),'stock_rack':(24,32),'stock_bundle':(16,16)}
    w,h=sizes[name];im,d=canvas(w,h)
    if name=='shelf':
        shadow(d,1,42,63,47);timber(d,2,1,61,43);rect(d,(6,5,57,37),'dark')
        for y in [12,26,39]:
            rect(d,(5,y-3,58,y),'grain');line(d,[(6,y-3),(57,y-3)],'lightwood');rect(d,(4,y+1,59,y+3),'ink');line(d,[(6,y+1),(56,y+1)],'wood')
        timber(d,2,2,5,43);timber(d,58,2,61,43);rect(d,(8,44,13,46),'ink');rect(d,(50,44,55,46),'ink');line(d,[(8,4),(55,4)],'edge')
    elif name in ['table','bench']:
        shadow(d,1,26,47,31);timber(d,5,17,9,29);timber(d,39,17,43,29);timber(d,4,3,43,19);poly(d,[(5,4),(40,4),(46,11),(2,11)],'lightwood');poly(d,[(3,12),(45,12),(45,16),(3,16)],'grain');line(d,[(7,7),(41,7)],'edge');line(d,[(5,10),(43,10)],'edge');rect(d,(7,21,41,23),'wood')
        if name=='bench':
            rect(d,(25,2,36,8),'ink');rect(d,(26,3,35,7),'steel');rect(d,(28,1,32,2),'steel2');rect(d,(37,11,40,13),'gold2');line(d,[(10,5),(16,7)],'dark');rect(d,(13,5,15,9),'steel2')
    elif name=='counter':
        shadow(d,1,32,63,39);timber(d,3,8,60,35);poly(d,[(3,4),(55,4),(63,12),(1,12)],'lightwood');rect(d,(2,13,62,17),'grain');line(d,[(4,5),(55,5)],'paper');rect(d,(8,20,54,29),'dark');rect(d,(10,21,52,28),'wood');line(d,[(11,21),(51,21)],'edge');rect(d,(28,22,31,24),'gold2');rect(d,(8,35,12,38),'ink');rect(d,(52,35,56,38),'ink');rect(d,(39,3,53,11),'ink');rect(d,(40,4,52,8),'teal');rect(d,(42,2,49,4),'steel2');rect(d,(43,5,47,6),'cream');rect(d,(40,9,52,10),'gold')
    elif name=='tray':
        shadow(d,0,18,63,23);poly(d,[(3,5),(57,5),(63,12),(61,20),(2,20),(0,12)],'ink');poly(d,[(4,6),(56,6),(61,12),(3,12)],'grain');rect(d,(3,13,60,18),'wood');line(d,[(3,12),(60,12)],'lightwood');line(d,[(6,8),(55,8)],'edge');rect(d,(29,15,34,16),'ink')
    elif name=='cart':
        shadow(d,1,33,38,39);ellipse(d,(4,28,13,37),'ink');ellipse(d,(27,28,36,37),'ink');ellipse(d,(6,30,11,35),'steel');ellipse(d,(29,30,34,35),'steel');line(d,[(6,8),(3,3),(2,3)],'steel2',2);line(d,[(32,8),(35,3),(37,3)],'steel2',2);poly(d,[(6,9),(31,9),(36,19),(33,30),(7,30),(3,19)],'ink');poly(d,[(7,10),(30,10),(34,18),(5,18)],'edge');rect(d,(6,19,33,28),'wood');line(d,[(7,20),(32,20)],'lightwood');line(d,[(8,25),(31,25)],'grain');rect(d,(10,17,12,29),'dark');rect(d,(27,17,29,29),'dark')
    elif name=='shutter':
        rect(d,(0,0,95,63),'ink');rect(d,(4,3,91,62),'dark');rect(d,(6,4,89,57),'steel')
        for y in range(5,58,5):line(d,[(7,y),(88,y)],'steel2');line(d,[(7,y+3),(88,y+3)],'blue')
        rect(d,(1,2,4,61),'wood');rect(d,(91,2,94,61),'wood');rect(d,(43,52,52,55),'ink');rect(d,(44,53,51,54),'steel2');rect(d,(6,58,89,62),'dark')
    elif name=='crate':
        shadow(d,0,25,31,31);poly(d,[(2,7),(23,3),(30,9),(29,26),(8,30),(1,24)],'ink');poly(d,[(3,8),(22,4),(28,9),(9,13)],'lightwood');poly(d,[(2,10),(8,14),(8,28),(2,23)],'wood');poly(d,[(10,14),(28,10),(28,25),(10,28)],'grain');line(d,[(11,18),(27,15)],'wood');line(d,[(11,23),(27,20)],'wood');line(d,[(12,15),(25,24)],'edge',2);line(d,[(25,11),(13,27)],'edge',2);rect(d,(16,17,22,21),'paper');rect(d,(18,19,20,19),'dark')
    elif name=='stock_rack':
        shadow(d,0,26,23,31);timber(d,1,1,22,29);rect(d,(4,4,19,25),'dark')
        for y in [13,25]:
            rect(d,(3,y,20,y+2),'grain');line(d,[(3,y),(20,y)],'lightwood');rect(d,(5,y-7,12,y-1),'stone');rect(d,(6,y-7,12,y-5),'paper');line(d,[(9,y-7),(9,y-1)],'wood');rect(d,(14,y-9,18,y-1),'red');line(d,[(15,y-8),(15,y-2)],'red2')
        rect(d,(2,29,5,30),'ink');rect(d,(18,29,21,30),'ink')
    elif name=='stock_bundle':
        shadow(d,0,12,15,15);poly(d,[(1,5),(11,3),(15,7),(14,13),(4,15),(0,11)],'ink');poly(d,[(2,6),(10,4),(13,7),(4,9)],'paper');poly(d,[(4,10),(14,8),(13,12),(4,13)],'stone');poly(d,[(1,7),(3,10),(3,13),(1,11)],'grout');line(d,[(7,5),(8,8),(8,13)],'wood');rect(d,(3,1,10,5),'wood');line(d,[(4,2),(9,2)],'edge');rect(d,(4,4,9,4),'dark')
    else:
        shadow(d,1,18,31,23);poly(d,[(2,7),(24,3),(30,9),(28,20),(7,23),(1,17)],'ink');poly(d,[(3,8),(24,4),(28,9),(8,13)],'paper');poly(d,[(8,14),(28,10),(27,19),(8,21)],'stone');poly(d,[(2,10),(7,14),(7,21),(2,16)],'grout');line(d,[(13,6),(18,12),(17,20)],'wood');line(d,[(3,13),(27,15)],'wood');rect(d,(20,13,25,15),'cream')
    return im
for name in ['shelf','table','bench','counter','tray','cart','shutter','crate','parcel','stock_rack','stock_bundle']:
    im=furniture(name);save(im,'furniture',name,(im.width//2,im.height-2),'furniture')

def decor(name):
    sizes={'rug':(48,32),'planter':(24,32),'wall_clock':(24,24),'harbor_print':(32,24),'stool':(24,24),'lamp':(24,40)}
    im,d=canvas(*sizes[name])
    if name=='rug':
        rect(d,(2,3,45,28),'dark');rect(d,(3,4,44,27),'red');rect(d,(5,6,42,25),'gold');rect(d,(7,8,40,23),'teal');
        for x in range(8,41,8):poly(d,[(x,15),(x+3,11),(x+6,15),(x+3,20)],'paper')
        for x in range(4,46,3):line(d,[(x,1),(x,3)],'paper');line(d,[(x,28),(x,30)],'paper')
        line(d,[(8,9),(39,9)],'teal2');line(d,[(8,22),(39,22)],'teal2')
    elif name=='planter':
        shadow(d,3,27,22,31);line(d,[(12,24),(12,7)],'wood',2)
        for pts in [[(11,18),(3,14),(2,8),(8,10)],[(13,17),(21,12),(22,7),(16,9)],[(11,11),(7,6),(9,1),(13,6)],[(14,12),(17,4),(20,3),(19,9)]]:poly(d,pts,'green');line(d,[pts[0],pts[2]],'green2')
        poly(d,[(5,22),(20,22),(18,30),(8,30)],'red');rect(d,(4,20,21,23),'red2');line(d,[(8,24),(9,28)],'gold2')
    elif name=='wall_clock':
        ellipse(d,(2,1,22,22),'ink');ellipse(d,(3,2,21,21),'wood');ellipse(d,(5,4,19,18),'gold');ellipse(d,(6,5,18,17),'cream');line(d,[(12,7),(12,11),(16,13)],'ink');rect(d,(11,6,12,7),'grain');rect(d,(7,10,8,11),'grain');rect(d,(16,10,17,11),'grain');rect(d,(11,15,12,16),'grain');ellipse(d,(10,10,13,13),'red')
    elif name=='harbor_print':
        rect(d,(1,1,30,22),'ink');rect(d,(2,2,29,21),'edge');rect(d,(4,4,27,19),'paper');rect(d,(5,5,26,12),'blue2');rect(d,(5,13,26,18),'teal');poly(d,[(9,14),(22,14),(19,17),(12,17)],'wood');line(d,[(16,7),(16,15)],'ink');poly(d,[(15,7),(10,13),(15,13)],'cream');poly(d,[(17,8),(17,13),(22,13)],'gold2');line(d,[(6,16),(9,16)],'teal3');line(d,[(21,17),(25,17)],'teal3')
    elif name=='stool':
        shadow(d,2,19,22,23);timber(d,5,10,8,21);timber(d,16,10,19,21);ellipse(d,(2,3,22,12),'ink');ellipse(d,(3,4,21,10),'edge');line(d,[(5,6),(18,6)],'lightwood');line(d,[(7,15),(17,15)],'wood',2)
    elif name=='lamp':
        shadow(d,3,34,22,39);ellipse(d,(5,34,21,38),'ink');ellipse(d,(6,34,20,36),'gold');rect(d,(12,13,14,34),'wood');rect(d,(12,13,12,33),'gold2');poly(d,[(7,2),(18,2),(23,14),(2,14)],'ink');poly(d,[(8,3),(17,3),(21,12),(4,12)],'paper');poly(d,[(8,3),(10,3),(8,12),(5,12)],'cream');rect(d,(4,13,21,14),'gold');rect(d,(10,15,16,17),'gold2')
    return im
for name in ['rug','planter','wall_clock','harbor_print','stool','lamp']:
    im=decor(name);save(im,'decor',name,(im.width//2,im.height-2),'decor')

# Architecture: stones are intentionally clustered, stable and low contrast.
def floor_tile(variant):
    im,d=canvas(16,16);rect(d,(0,0,15,15),'stone2' if variant%3==0 else 'stone');line(d,[(0,0),(15,0)],'grout');line(d,[(0,0),(0,15)],'grout');line(d,[(1,1),(14,1)],'paper');line(d,[(15,1),(15,15)],'grout')
    if variant==1:line(d,[(10,7),(13,7),(14,8)],'#c3a98b')
    if variant==2:line(d,[(4,12),(6,11)],'#b99d81')
    if variant==3:rect(d,(7,5,9,5),'stone2')
    if variant==4:line(d,[(9,10),(11,10),(12,11)],'#bea285');rect(d,(3,6,5,6),'stone2')
    if variant==5:line(d,[(5,12),(6,12),(7,13)],'#bfa689');line(d,[(10,3),(13,3)],'stone2')
    return im
for v in range(6):save(floor_tile(v),'environments','floor_'+str(v),(0,0),'floor_tile')
def environment(yard=False):
    im,d=canvas(208,288);rect(d,(0,0,207,287),'ink')
    for row,y in enumerate(range(32,280,16)):
        for col,x in enumerate(range(8,200,16)):
            im.alpha_composite(floor_tile((row*3+col*7)%4),(x,y))
    d=ImageDraw.Draw(im)
    rect(d,(0,0,207,31),'wood' if not yard else 'grout')
    for y in [2,12,22]:
        for x in range(-10 if y==12 else 0,208,32):
            rect(d,(x,y,x+30,y+8),'grain' if not yard else 'stone');line(d,[(x+1,y),(x+28,y)],'edge' if not yard else 'stone2')
    rect(d,(0,31,207,34),'dark');line(d,[(8,32),(199,32)],'edge');rect(d,(0,32,7,287),'dark');rect(d,(200,32,207,287),'dark');rect(d,(2,34,5,276),'wood');rect(d,(202,34,205,276),'wood');line(d,[(7,34),(7,278)],'edge');line(d,[(199,34),(199,278)],'grain')
    if not yard:
        # Cool daylight crosses warm wood; window is independent of goods state.
        for x in [15,150]:
            timber(d,x,3,x+40,27);rect(d,(x+3,6,x+37,22),'blue');rect(d,(x+4,6,x+16,13),'blue2');rect(d,(x+22,7,x+35,17),'teal2');line(d,[(x+20,5),(x+20,23)],'wood',2);line(d,[(x+3,15),(x+37,15)],'wood',2);rect(d,(x-1,25,x+41,28),'lightwood')
        timber(d,79,5,129,25);rect(d,(82,8,126,21),'teal');line(d,[(88,12),(120,12)],'gold2');line(d,[(94,16),(114,16)],'paper')
        # threshold and recessed entrance, where path remains clear
        rect(d,(79,270,132,287),'dark');rect(d,(83,272,128,284),'wood');line(d,[(84,273),(127,273)],'lightwood');rect(d,(91,277,120,283),'grout');line(d,[(94,278),(117,278)],'stone2')
    else:
        rect(d,(39,33,170,124),'dark');rect(d,(42,36,167,121),'wood');rect(d,(47,41,162,118),'ink');rect(d,(47,111,162,120),'grout');line(d,[(48,112),(161,112)],'stone2');rect(d,(41,123,168,127),'shadow')
        # Cobble threshold and yard edge; bay interior unlit behind shutter.
        for y in range(136,273,16):
            for x in range(12,196,16):
                if (x//16+y//16)%6==0:line(d,[(x+4,y+7),(x+8,y+7)],'#baa080')
        timber(d,74,7,135,25);rect(d,(77,10,132,22),'paper');line(d,[(84,14),(126,14)],'wood');line(d,[(94,18),(116,18)],'red')
        # Fine wheel ruts keep yard distinct without crowding actors.
        line(d,[(70,185),(69,245)],'grout');line(d,[(76,186),(75,244)],'stone2');line(d,[(145,183),(145,238)],'grout');rect(d,(8,275,199,282),'grout');line(d,[(9,277),(198,277)],'stone2')
    return im
save(environment(),'environments','shop',(0,0),'environment')
save(environment(True),'environments','yard',(0,0),'environment')
for name,yard in [('shop',False),('yard',True)]:
    im=environment(yard);original=im.copy();d=ImageDraw.Draw(im)
    rect(d,(8,35,199,279),'#00000000')
    if yard:
        # Bay flooring/wall is structural. The actual yard stone is a tile layer.
        im.alpha_composite(original.crop((39,33,171,128)),(39,33))
        im.alpha_composite(original.crop((8,275,200,283)),(8,275))
    else:im.alpha_composite(original.crop((79,270,133,288)),(79,270))
    save(im,'environments',name+'_architecture',(0,0),'architecture_overlay')

# Twelve frames: 2 idle, 4 walk, 2 interact, 2 carry, 2 bid. Identical pivots.
ACTORS={
 'shopkeeper':('teal','teal2','dark','skin2','apron'),
 'mei':('blue','blue2','ink','skin2','bun'),
 'arif':('gold','gold2','wood','skin','cap'),
 'suri':('red','red2','dark','skin2','long'),
 'auctioneer':('dark','grain','wood','skin','vest'),
 'lina':('green','green2','dark','skin2','long'),
 'tomas':('blue','blue2','wood','skin','cap'),
 'bea':('red','red2','ink','skin2','bob'),
 'browser_home':('gold','gold2','dark','skin','bun'),
 'browser_tools':('teal','teal2','wood','skin2','vest'),
 'bargain':('wood','edge','ink','skin','cap')}
def actor(info,frame):
    shirt,hi,hair,skin,style=info;im,d=canvas(24,32)
    walk=2<=frame<=5 or frame in [8,9];bob=1 if walk and frame%2==1 else 0
    oy=-bob;footL=1 if frame in [2,8] else -1 if frame in [4,9] else 0;footR=-footL
    ellipse(d,(5,26,19,29),'#00000036')
    # feet stay on the baseline while alternating strides, torso rises one pixel
    rect(d,(8,23+oy,10,27+footL),'dark');rect(d,(14,23+oy,16,27+footR),'dark');rect(d,(7,27+footL,11,28+footL),'ink');rect(d,(14,27+footR,18,28+footR),'ink')
    poly(d,[(8,12+oy),(16,12+oy),(18,16+oy),(17,23+oy),(7,23+oy),(6,16+oy)],shirt);rect(d,(8,14+oy,10,21+oy),hi);line(d,[(11,22+oy),(16,22+oy)],'dark')
    rect(d,(9,10+oy,14,13+oy),skin);poly(d,[(8,4+oy),(15,4+oy),(17,7+oy),(16,11+oy),(13,13+oy),(9,11+oy),(7,8+oy)],skin);rect(d,(8,6+oy,9,9+oy),'skin2');rect(d,(9,8+oy,9,8+oy),'ink');rect(d,(14,8+oy,14,8+oy),'ink');rect(d,(11,11+oy,13,11+oy),'red')
    poly(d,[(7,4+oy),(10,2+oy),(15,3+oy),(17,5+oy),(17,7+oy),(14,6+oy),(13,4+oy),(8,6+oy),(7,9+oy)],hair);line(d,[(9,3+oy),(13,3+oy)],'grain')
    if style=='bun':ellipse(d,(15,2+oy,19,6+oy),hair)
    if style=='long':rect(d,(6,6+oy,7,13+oy),hair);rect(d,(16,6+oy,18,14+oy),hair)
    if style=='bob':rect(d,(6,5+oy,7,10+oy),hair);rect(d,(16,5+oy,18,11+oy),hair)
    if style=='cap':poly(d,[(7,3+oy),(14,2+oy),(17,5+oy),(7,5+oy)],'green');rect(d,(6,5+oy,18,6+oy),'green2')
    if style in ['vest','apron']:rect(d,(10,14+oy,15,22+oy),'paper');line(d,[(11,14+oy),(14,14+oy)],'edge');rect(d,(11,18+oy,14,20+oy),'grain')
    if frame>=10:
        raise_y=4 if frame==10 else 0
        poly(d,[(17,14+oy),(19,13+oy),(19,8+oy+raise_y),(21,8+oy+raise_y),(20,16+oy),(18,18+oy)],shirt);rect(d,(19,6+oy+raise_y,21,9+oy+raise_y),skin);line(d,[(20,8+oy+raise_y),(20,2+oy+raise_y)],'wood');ellipse(d,(16,2+raise_y,21,6+raise_y),'paper');rect(d,(18,3+raise_y,20,4+raise_y),'red')
        rect(d,(5,16+oy,7,20+oy),skin)
    elif frame in [6,7]:
        poly(d,[(17,14+oy),(19,16+oy),(21,15+oy),(21,17+oy),(18,19+oy),(16,17+oy)],shirt);rect(d,(20,14+oy,21,17+oy),skin);rect(d,(5,16+oy,7,20+oy),skin)
    elif frame in [8,9]:
        poly(d,[(5,15+oy),(7,15+oy),(9,18+oy),(16,18+oy),(18,15+oy),(20,16+oy),(18,22+oy),(8,22+oy)],shirt);rect(d,(8,18+oy,18,25+oy),'wood');rect(d,(9,19+oy,17,24+oy),'paper');line(d,[(13,19+oy),(13,24+oy)],'grain');rect(d,(7,19+oy,9,21+oy),skin);rect(d,(17,19+oy,19,21+oy),skin)
    else:
        rect(d,(5,15+oy,7,19+oy),shirt);rect(d,(5,19+oy,7,21+oy),skin);rect(d,(18,15+oy,19,19+oy),shirt);rect(d,(18,19+oy,19,21+oy),skin)
        if frame==1:rect(d,(9,8+oy,9,8+oy),skin);rect(d,(14,8+oy,14,8+oy),skin)
    return im
animations={'idle':[0,1],'walk':[2,3,4,5],'interact':[6,7],'carry':[8,9],'bid':[10,11]}
for name,info in ACTORS.items():
    sheet=Image.new('RGBA',(288,32))
    for frame in range(12):sheet.alpha_composite(actor(info,frame),(frame*24,0))
    save(sheet,'actors',name,(12,28),'actor_sheet',animations)
    resources=['[gd_resource type="SpriteFrames" load_steps=14 format=3]','',f'[ext_resource type="Texture2D" path="res://assets/pixel/actors/{name}.png" id="1"]','']
    for frame in range(12):resources.extend([f'[sub_resource type="AtlasTexture" id="F{frame}"]','atlas = ExtResource("1")',f'region = Rect2({frame*24}, 0, 24, 32)',''])
    resources.extend(['[resource]','animations = ['])
    for idx,(anim,frames) in enumerate(animations.items()):
        items=', '.join('{"duration": 1.0, "texture": SubResource("F'+str(f)+'")}' for f in frames)
        resources.append('{"frames": ['+items+'], "loop": '+('true' if anim in ['idle','walk','carry'] else 'false')+', "name": &"'+anim+'", "speed": '+('2.0' if anim=='idle' else '7.0')+'}'+(',' if idx<4 else ''))
    resources.append(']');(OUT/'actors'/(name+'.tres')).write_text('\n'.join(resources)+'\n')

# Full directional motion set. The compact 12-cel integration sheet stays stable.
MOTIONS={
 'idle':([0,0,1,0],3,True),
 'walk':([2,3,0,4,5,0],8,True),
 'interact':([0,6,7,0],6,False),
 'carry_idle':([8,8],2,True),
 'carry_walk':([8,9,8,9,8,9],8,True),
 'bid':([0,10,11,0],8,False),
 'browse':([0,6,6,0],4,True),
 'handoff':([0,6,8,8],8,False)}
DIRECTIONS=['down','left','right','up']
def directional(info,frame,direction,motion,phase):
    if direction=='down':return actor(info,frame)
    shirt,hi,hair,skin,style=info
    if direction=='up':
        # Back-facing people have hair/back panels, never a front-facing eye pair.
        im=actor(info,frame);d=ImageDraw.Draw(im);bob=1 if frame in [3,5,9] else 0;oy=-bob
        rect(d,(6,1+oy,18,13+oy),'#00000000');poly(d,[(8,4+oy),(10,2+oy),(15,3+oy),(17,6+oy),(16,11+oy),(13,13+oy),(9,11+oy),(7,8+oy)],hair);line(d,[(9,4+oy),(14,4+oy)],'grain');rect(d,(10,12+oy,14,13+oy),skin)
        if style=='cap':poly(d,[(7,3+oy),(14,2+oy),(17,5+oy),(7,5+oy)],'green');rect(d,(7,5+oy,17,6+oy),'green2')
        if style=='bun':ellipse(d,(14,5+oy,18,9+oy),hair)
        if style in ['long','bob']:rect(d,(7,7+oy,17,14+oy),hair)
        rect(d,(8,14+oy,16,22+oy),shirt);line(d,[(9,15+oy),(9,20+oy)],hi);line(d,[(10,22+oy),(16,22+oy)],'dark')
        if frame in [8,9]:
            # Carried parcel is behind torso with its upper edge seen over arms.
            rect(d,(8,17+oy,18,25+oy),'#00000000');rect(d,(8,17+oy,17,22+oy),shirt);rect(d,(8,23+oy,10,27),'dark');rect(d,(14,23+oy,16,27),'dark');rect(d,(7,27,11,28),'ink');rect(d,(14,27,18,28),'ink');rect(d,(7,16+oy,18,18+oy),'paper');rect(d,(11,16+oy,12,18+oy),'grain')
        return im
    im,d=canvas(24,32);ellipse(d,(5,26,19,29),'#00000036');oy=-1 if frame in [3,5,9] else 0
    step=2 if frame in [2,8] else -2 if frame in [4,9] else 0
    rect(d,(9+step,23+oy,11+step,27),'dark');rect(d,(13-step,23+oy,15-step,27),'dark');rect(d,(9+step,27,13+step,28),'ink');rect(d,(13-step,27,17-step,28),'ink')
    poly(d,[(9,13+oy),(14,12+oy),(16,16+oy),(15,23+oy),(8,23+oy),(8,17+oy)],shirt);rect(d,(9,15+oy,10,21+oy),hi);line(d,[(9,22+oy),(14,22+oy)],'dark')
    rect(d,(11,10+oy,14,13+oy),skin);poly(d,[(9,4+oy),(14,4+oy),(16,6+oy),(16,8+oy),(18,9+oy),(16,10+oy),(15,12+oy),(11,11+oy),(8,8+oy)],skin)
    poly(d,[(8,4+oy),(10,2+oy),(15,3+oy),(16,5+oy),(13,5+oy),(12,7+oy),(9,9+oy),(8,8+oy)],hair);line(d,[(10,3+oy),(14,3+oy)],'grain');rect(d,(15,7+oy,15,8+oy),'ink');rect(d,(15,10+oy,16,10+oy),'red')
    if style=='cap':poly(d,[(8,3+oy),(14,2+oy),(16,5+oy),(8,5+oy)],'green');rect(d,(8,5+oy,18,6+oy),'green2')
    if style=='bun':ellipse(d,(6,3+oy,10,7+oy),hair)
    if style in ['bob','long']:rect(d,(7,6+oy,9,12+oy),hair)
    if style=='long':rect(d,(7,11+oy,10,15+oy),hair)
    if frame in [6,7]:line(d,[(13,15+oy),(17,18+oy),(20,17+oy)],shirt,3);rect(d,(19,16+oy,21,18+oy),skin)
    elif frame in [8,9]:rect(d,(15,17+oy,21,24+oy),'paper');rect(d,(17,17+oy,18,24+oy),'grain');line(d,[(13,15+oy),(15,20+oy)],shirt,3);rect(d,(14,20+oy,16,21+oy),skin)
    elif frame in [10,11]:
        ry=4 if frame==10 else 0;line(d,[(13,15+oy),(17,12+oy),(19,7+ry)],shirt,3);rect(d,(18,6+ry,20,8+ry),skin);line(d,[(19,7+ry),(19,3+ry)],'wood');ellipse(d,(16,2+ry,21,6+ry),'paper');rect(d,(18,3+ry,19,4+ry),'red')
    else:rect(d,(12,15+oy,14,20+oy),shirt);rect(d,(12,20+oy,14,22+oy),skin)
    if direction=='left':return im.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
    return im
for name,info in ACTORS.items():
    full=Image.new('RGBA',(816,128));resources=['[gd_resource type="SpriteFrames" load_steps=138 format=3]','',f'[ext_resource type="Texture2D" path="res://assets/pixel/actors/{name}_directional.png" id="1"]',''];animation_records={};animlines=[]
    for row,direction in enumerate(DIRECTIONS):
        col=0
        for motion,(frames,fps,loop) in MOTIONS.items():
            ids=[]
            for phase,baseframe in enumerate(frames):
                cel=directional(info,baseframe,direction,motion,phase);cd=ImageDraw.Draw(cel)
                if motion=='idle' and phase==2:
                    # Shoulder-only breathing preserves the head and foot pivot.
                    rect(cd,(8,14,9,14),info[1]);rect(cd,(15,14,16,14),info[0])
                for gutter in [(0,0,1,31),(22,0,23,31),(0,0,23,1),(0,30,23,31)]:rect(cd,gutter,'#00000000')
                full.alpha_composite(cel,(col*24,row*32));rid=row*34+col;ids.append(rid)
                resources.extend([f'[sub_resource type="AtlasTexture" id="F{rid}"]','atlas = ExtResource("1")',f'region = Rect2({col*24}, {row*32}, 24, 32)','']);col+=1
            key=motion+'_'+direction;animation_records[key]={'frame_ids':ids,'frame_count':len(ids),'fps':fps,'loop':loop,'terminal_frame':ids[-1],'regions':[[i%34*24,i//34*32,24,32] for i in ids],'gutter':2,'carry_anchor':{'down':[12,20],'left':[4,20],'right':[20,20],'up':[12,17]}[direction]}
            items=', '.join('{"duration": '+('2.0' if motion=='bid' and i==2 else '1.0')+', "texture": SubResource("F'+str(f)+'")}' for i,f in enumerate(ids))
            animlines.append('{"frames": ['+items+'], "loop": '+str(loop).lower()+', "name": &"'+key+'", "speed": '+str(float(fps))+'}')
    save(full,'actors',name+'_directional',(12,28),'directional_actor_atlas',animation_records)
    resources.extend(['[resource]','animations = [',',\n'.join(animlines),']']);(OUT/'actors'/(name+'_directional.tres')).write_text('\n'.join(resources)+'\n')

def effect_sheet(name,count,w,h,fps):
    sheet=Image.new('RGBA',(w*count,h))
    for frame in range(count):
        im,d=canvas(w,h)
        if name=='crate_open':
            im=furniture('crate');d=ImageDraw.Draw(im)
            if frame>=2:
                poly(d,[(3,8),(22,4),(28,9),(9,13)],'dark');lid_y=max(1,7-frame*2);poly(d,[(4,lid_y+4),(21,lid_y),(27,lid_y+3),(10,lid_y+7)],'wood');line(d,[(5,lid_y+4),(21,lid_y+1)],'lightwood');rect(d,(14,13,21,17),'stone')
        elif name=='shutter_open':
            im=furniture('shutter');d=ImageDraw.Draw(im);open_y=57-frame*9
            rect(d,(6,max(5,open_y),89,62),'#00000000');rect(d,(6,max(5,open_y)-3,89,max(5,open_y)),'steel2');line(d,[(7,max(5,open_y)-2),(88,max(5,open_y)-2)],'blue')
        elif name in ['sparkle','reveal_accent','sold_accent']:
            x=w//2;y=h//2;r=[1,2,3,4,2,1][frame%6]
            poly(d,[(x,y-r),(x+1,y-1),(x+r,y),(x+1,y+1),(x,y+r),(x-1,y+1),(x-r,y),(x-1,y-1)],'cream');rect(d,(x,y,x,y),'gold2')
            if frame in [1,2,3,4]:rect(d,(x-6,y+3,x-5,y+3),'paper');rect(d,(x+5,y-5,x+5,y-4),'gold2')
        elif name=='selection':
            c='cream' if frame==0 else 'gold2'
            for x,y,sx,sy in [(2,2,1,1),(w-3,2,-1,1),(2,h-3,1,-1),(w-3,h-3,-1,-1)]:line(d,[(x+sx*4,y),(x,y),(x,y+sy*4)],'ink',3);line(d,[(x+sx*4,y),(x,y),(x,y+sy*4)],c)
        elif name=='lamp_ambient':
            ellipse(d,(5,4,11,10),'gold2' if frame%2 else 'paper');rect(d,(7,2,9,3),'wood');rect(d,(7,11,9,12),'wood');line(d,[(6,5),(6,8)],'cream')
        sheet.alpha_composite(im,(frame*w,0))
    records={'default':{'frame_ids':list(range(count)),'frame_count':count,'fps':fps,'loop':name in ['selection','lamp_ambient'],'terminal_frame':count-1,'regions':[[f*w,0,w,h] for f in range(count)],'gutter':0}}
    save(sheet,'effects',name,(w//2,h-2),'effect_atlas',records)
    resources=[f'[gd_resource type="SpriteFrames" load_steps={count+2} format=3]','',f'[ext_resource type="Texture2D" path="res://assets/pixel/effects/{name}.png" id="1"]','']
    for frame in range(count):resources.extend([f'[sub_resource type="AtlasTexture" id="F{frame}"]','atlas = ExtResource("1")',f'region = Rect2({frame*w}, 0, {w}, {h})',''])
    items=', '.join('{"duration": 1.0, "texture": SubResource("F'+str(f)+'")}' for f in range(count))
    resources.extend(['[resource]','animations = [{"frames": ['+items+'], "loop": '+str(name in ['selection','lamp_ambient']).lower()+', "name": &"default", "speed": '+str(float(fps))+'}]']);(OUT/'effects'/(name+'.tres')).write_text('\n'.join(resources)+'\n')
for args in [('crate_open',5,32,32,10),('shutter_open',6,96,64,8),('reveal_accent',6,32,32,12),('sold_accent',4,16,16,10),('sparkle',6,16,16,12),('selection',2,32,32,2),('lamp_ambient',3,16,16,2)]:effect_sheet(*args)

# App icon is original and uses the same material language.
im,d=canvas(64,64);rect(d,(0,0,63,63),'dark');rect(d,(3,3,60,60),'wood');rect(d,(6,6,57,57),'teal');line(d,[(31,10),(31,14)],'gold2',3);poly(d,[(22,16),(40,16),(44,40),(19,40)],'ink');rect(d,(24,18,38,37),'gold2');rect(d,(26,21,36,34),'paper');rect(d,(30,18,32,38),'wood');rect(d,(22,40,41,43),'edge');line(d,[(12,51),(52,51)],'gold');save(im,'effects','lantern_icon',(32,32),'icon')

# Gentle original synthesised effects, no downloaded recordings.
AUD=ROOT/'assets'/'audio';AUD.mkdir(parents=True,exist_ok=True)
def sound(name,notes,duration=.25,kind='tone'):
    rate=22050;buf=[];rng=random.Random(20261014)
    for i in range(int(duration*rate)):
        t=i/rate;env=min(1,t/.006)*max(0,1-t/duration)**2
        if kind=='noise':v=(rng.random()*2-1)*.16*env
        else:
            v=sum(math.sin(2*math.pi*f*t)*math.exp(-t*(8+j*3)) for j,f in enumerate(notes))*.16*env/max(1,len(notes))
        buf.append(struct.pack('<h',int(max(-1,min(1,v))*32767)))
    with wave.open(str(AUD/(name+'.wav')),'wb') as f:f.setnchannels(1);f.setsampwidth(2);f.setframerate(rate);f.writeframes(b''.join(buf))
    manifest.append(dict(asset_id='audio.'+name,path='res://assets/audio/'+name+'.wav',kind='audio',placeholder=False,creator='Lantern Lot implementation team',origin='original mathematical synthesis',license='CC0-1.0',source_url=None,commercial_use_basis='Original waveform synthesis dedicated under CC0-1.0',modification_status='new original',editable_source='art/build_pixel_art.py',attribution_file='THIRD_PARTY_NOTICES.md',review_date=None,review_scope='Waveform format validated; playback audition not yet established',duration_seconds=duration))
sound('select',[580],.08);sound('stock',[320,640],.16);sound('inspect',[480,720],.22);sound('bid',[240,480],.19);sound('register',[880,1320,1760],.38);sound('unpack',[],.24,'noise');sound('step',[],.07,'noise')
sound('wood_drawer',[],.18,'noise');sound('paper',[],.14,'noise');sound('ceramic',[760,1140],.18);sound('metal',[1260,2050],.19);sound('auction_close',[370,555,740],.35);sound('invalid',[190,220],.16)
# Quiet, seamlessly periodic ambience has no speech or meaningful stereo clues.
rate=22050;duration=2.0
with wave.open(str(AUD/'room_ambience.wav'),'wb') as f:
    f.setnchannels(1);f.setsampwidth(2);f.setframerate(rate)
    f.writeframes(b''.join(struct.pack('<h',int(32767*.018*(math.sin(2*math.pi*55*i/rate)+.35*math.sin(2*math.pi*110*i/rate)))) for i in range(int(rate*duration))))
manifest.append(dict(asset_id='audio.room_ambience',path='res://assets/audio/room_ambience.wav',kind='audio',placeholder=False,creator='Lantern Lot implementation team',origin='original mathematical synthesis',license='CC0-1.0',source_url=None,commercial_use_basis='Original waveform synthesis dedicated under CC0-1.0',modification_status='new original',editable_source='art/build_pixel_art.py',attribution_file='THIRD_PARTY_NOTICES.md',review_date=None,review_scope='Waveform format validated; playback audition not yet established',duration_seconds=duration,loop=True))

manifest_path=ROOT/'assets'/'visual_manifest.json'
if manifest_path.exists():
    extras=json.loads(manifest_path.read_text()).get('assets',[])
    known={a['asset_id'] for a in manifest}
    manifest.extend(a for a in extras if a['asset_id'] not in known)
manifest_path.write_text(json.dumps({'version':1,'native_floor_cell':[16,16],'actor_cel':[24,32],'art_reference':'Not available; independently authored original material language','assets':manifest},indent=2)+'\n')

# Contact sheets are QA evidence, not shipped game textures.
preview=ROOT/'art'/'review';preview.mkdir(parents=True,exist_ok=True)
sheet=Image.new('RGBA',(480,330),P['paper']);d=ImageDraw.Draw(sheet)
for i,name in enumerate(['homewares.enamel_kettle','homewares.folding_stool','tools.desk_fan','tools.hand_drill','homewares.serving_bowl','paper.tram_print','practice.cup','practice.square','practice.folio','covered']):
    x=(i%5)*96;y=(i//5)*150;sheet.alpha_composite(goods(name).resize((72,72),Image.Resampling.NEAREST),(x+12,y+10));d.text((x+3,y+89),name.split('.')[-1][:15],fill=P['ink'])
sheet.convert('RGB').save(preview/'goods.png')
sheet=Image.new('RGBA',(640,440),P['paper']);d=ImageDraw.Draw(sheet)
for i,(name,info) in enumerate(ACTORS.items()):
    x=(i%6)*104;y=(i//6)*200;sheet.alpha_composite(actor(info,0).resize((72,96),Image.Resampling.NEAREST),(x+12,y+8));sheet.alpha_composite(actor(info,10).resize((48,64),Image.Resampling.NEAREST),(x+28,y+113));d.text((x+3,y+182),name[:14],fill=P['ink'])
sheet.convert('RGB').save(preview/'actors.png')
sheet=Image.new('RGBA',(832,576),P['paper']);sheet.alpha_composite(environment().resize((416,576),Image.Resampling.NEAREST),(0,0));sheet.alpha_composite(environment(True).resize((416,576),Image.Resampling.NEAREST),(416,0));sheet.convert('RGB').save(preview/'architecture.png')
sheet=Image.new('RGBA',(640,420),P['paper']);d=ImageDraw.Draw(sheet)
for i,name in enumerate(['shelf','table','bench','counter','tray','cart','shutter','crate','parcel','rug','planter','wall_clock','harbor_print','stool','lamp']):
    x=(i%5)*128;y=(i//5)*136;im=furniture(name) if i<9 else decor(name);scale=min(2,120//im.width,104//im.height);sheet.alpha_composite(im.resize((im.width*scale,im.height*scale),Image.Resampling.NEAREST),(x+4,y+4));d.text((x+4,y+112),name,fill=P['ink'])
sheet.convert('RGB').save(preview/'fixtures.png')
sheet=Image.new('RGBA',(216,144),P['paper']);sheet.alpha_composite(furniture('stock_rack').resize((72,96),Image.Resampling.NEAREST),(18,10));sheet.alpha_composite(furniture('stock_bundle').resize((48,48),Image.Resampling.NEAREST),(132,52));sheet.convert('RGB').save(preview/'stock-capacity.png')
sheet=Image.new('RGBA',(816,384),P['paper'])
for row,direction in enumerate(DIRECTIONS):
    for i,frame in enumerate([0,1,2,3,4,5,6,7,8,9,10,11]):sheet.alpha_composite(directional(ACTORS['shopkeeper'],frame,direction,'walk',i).resize((48,64),Image.Resampling.NEAREST),(i*66,row*90+10))
sheet.convert('RGB').save(preview/'directional-poses.png')
print('Original asset set built:',len(manifest),'registered assets.')
