"""Authored close inspection drawings and the Lantern Lot ledger UI skin.

These are separate native 64px drawings, not enlarged world goods. Only the
palette/material vocabulary is shared with build_pixel_art.py.
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json,hashlib

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'assets'/'pixel'
for folder in ['inspect','ui']:(OUT/folder).mkdir(parents=True,exist_ok=True)
P=dict(ink='#352c33',dark='#493538',wood='#73503e',grain='#906447',edge='#b88553',lightwood='#d4a06a',stone='#cdb394',stone2='#d5bd9d',grout='#ad947b',paper='#f2deb3',cream='#fff0ca',teal='#397f7d',teal2='#68aca0',teal3='#a9d7bf',red='#a85046',red2='#d77654',gold='#c69948',gold2='#f3cf73',blue='#486c88',blue2='#769faa',steel='#718b92',steel2='#bad0c7',skin='#d4a077',skin2='#f1c399',shadow='#7a675c',green='#56784d',green2='#8da460')
records=[]
def rect(d,b,c):d.rectangle((min(b[0],b[2]),min(b[1],b[3]),max(b[0],b[2]),max(b[1],b[3])),fill=P.get(c,c))
def poly(d,b,c):d.polygon(b,fill=P.get(c,c))
def line(d,b,c,w=1):d.line(b,fill=P.get(c,c),width=w)
def ellipse(d,b,c):d.ellipse(b,fill=P.get(c,c))
def canvas(w=64,h=64):
    im=Image.new('RGBA',(w,h));return im,ImageDraw.Draw(im)
def save(im,folder,name,kind):
    path=OUT/folder/(name+'.png');im.save(path)
    records.append(dict(asset_id=folder+'.'+name,definition_id=name if kind=='inspect' else None,path='res://'+path.relative_to(ROOT).as_posix(),output_atlas='res://'+path.relative_to(ROOT).as_posix(),region=[0,0,im.width,im.height],native_cel=list(im.size),pivot=[im.width//2,im.height-4],footprint=None,animations={},kind=kind,placeholder=False,origin='Original authored integer-coordinate pixel drawing',source_url=None,creator='Lantern Lot implementation team (Codex-assisted pixel cluster drawing)',license='CC0-1.0',commercial_use_basis='Original drawing; CC0-1.0 dedication to the extent copyright applies. No reference pixels copied.',modification_status='New original',editable_source='art/build_inspect_ui.py',attribution_file='THIRD_PARTY_NOTICES.md',review_date='2026-10-15',review_scope='Dedicated inspection and UI skin contact sheet opened and inspected separately from runtime layout'))
def contact_shadow(d):ellipse(d,(8,54,57,60),'#49353842')
def inspect(name):
    im,d=canvas();contact_shadow(d)
    if name=='homewares.enamel_kettle':
        # Folded steel handle, enamel body, separate brass lid and maker ring.
        line(d,[(23,24),(22,12),(27,7),(40,7),(47,12),(47,24)],'ink',5);line(d,[(24,22),(24,12),(28,9),(39,9),(44,13),(44,22)],'steel',2);line(d,[(27,10),(39,10)],'steel2')
        poly(d,[(16,26),(43,26),(49,33),(51,48),(47,55),(22,57),(14,52),(12,38)],'ink');poly(d,[(17,28),(42,28),(47,34),(49,47),(45,52),(23,54),(16,50),(14,39)],'teal');poly(d,[(18,31),(22,30),(20,43),(22,51),(18,49),(16,40)],'teal2');poly(d,[(24,51),(44,50),(47,47),(44,52),(24,54)],'#29605f')
        poly(d,[(14,34),(7,23),(4,22),(3,25),(7,40),(14,43)],'ink');poly(d,[(12,35),(7,27),(6,27),(9,37),(13,39)],'teal2');line(d,[(6,23),(8,23)],'steel2')
        ellipse(d,(16,22,45,31),'ink');ellipse(d,(18,23,43,29),'gold');line(d,[(22,24),(37,24)],'gold2');ellipse(d,(28,19,35,24),'ink');rect(d,(30,18,33,20),'wood');line(d,[(31,18),(33,18)],'edge')
        ellipse(d,(34,40,41,47),'teal2');ellipse(d,(35,41,40,46),'teal');rect(d,(37,42,38,44),'teal3');line(d,[(24,46),(26,46)],'stone2');rect(d,(45,34,46,37),'cream')
    elif name=='homewares.folding_stool':
        # Upper-left light reveals the worn red canvas seat and crossed braces.
        poly(d,[(10,16),(45,13),(56,24),(48,34),(14,37),(6,26)],'ink');poly(d,[(12,17),(44,15),(53,24),(47,29),(14,32),(8,25)],'red');poly(d,[(12,18),(42,16),(47,20),(16,23)],'red2');poly(d,[(10,28),(15,32),(47,29),(49,32),(15,35)],'#843d3c');line(d,[(16,20),(42,18)],'#e18b64');line(d,[(13,30),(16,31)],'paper');rect(d,(44,28,47,29),'stone2')
        line(d,[(15,35),(46,57)],'ink',7);line(d,[(46,34),(16,58)],'ink',7);line(d,[(15,35),(46,56)],'wood',5);line(d,[(46,34),(16,57)],'wood',5);line(d,[(17,36),(43,54)],'edge',2);line(d,[(43,37),(18,56)],'lightwood');ellipse(d,(28,43,34,49),'ink');ellipse(d,(29,44,33,48),'steel');rect(d,(30,45,31,46),'steel2');rect(d,(43,53,46,54),'grout');line(d,[(14,57),(19,57)],'edge')
    elif name=='tools.desk_fan':
        poly(d,[(25,39),(37,39),(39,52),(48,55),(47,59),(16,59),(14,56),(24,52)],'ink');poly(d,[(27,40),(35,40),(37,53),(26,53)],'teal');line(d,[(28,42),(28,51)],'teal2');ellipse(d,(17,53,46,58),'teal');line(d,[(22,54),(39,54)],'teal2');rect(d,(37,55,39,56),'gold2')
        ellipse(d,(9,2,55,45),'ink');ellipse(d,(11,4,53,43),'steel');ellipse(d,(14,7,50,40),'dark');poly(d,[(31,21),(22,7),(17,13),(18,22),(27,25)],'steel2');poly(d,[(33,23),(49,14),(50,24),(45,32),(35,29)],'teal2');poly(d,[(31,26),(31,40),(21,37),(18,30),(27,25)],'blue2')
        for x in range(16,51,5):line(d,[(x,11),(x,36)],'steel')
        for y in range(12,40,6):line(d,[(15,y),(49,y)],'steel')
        ellipse(d,(14,7,50,40),'#00000000') if False else None
        # An outer grille ring and fastener hubs establish metal construction.
        d.ellipse((14,7,50,40),outline=P['steel2'],width=1);ellipse(d,(27,20,37,30),'ink');ellipse(d,(28,21,36,29),'gold');ellipse(d,(30,22,34,26),'gold2');rect(d,(42,43,53,51),'ink');rect(d,(43,44,52,50),'paper');line(d,[(45,47),(47,49),(50,45)],'teal',1);line(d,[(46,41),(46,44)],'wood')
    elif name=='tools.hand_drill':
        # Breast handle, toothed gear, off-axis crank and twisted steel bit.
        poly(d,[(17,3),(22,2),(26,6),(25,14),(22,17),(17,14),(14,7)],'ink');poly(d,[(18,4),(22,4),(24,7),(23,13),(20,14),(17,12),(16,7)],'red');line(d,[(18,5),(18,10)],'red2');rect(d,(19,16,23,45),'ink');rect(d,(20,16,22,44),'steel');line(d,[(20,17),(20,40)],'steel2')
        for a in range(0,360,45):
            import math
            x=30+int(11*math.cos(a*math.pi/180));y=31+int(11*math.sin(a*math.pi/180));rect(d,(x-1,y-1,x+1,y+1),'ink')
        ellipse(d,(19,20,41,42),'ink');ellipse(d,(21,22,39,40),'gold');ellipse(d,(25,26,35,36),'dark');ellipse(d,(27,28,33,34),'steel');rect(d,(29,30,31,32),'steel2');line(d,[(40,29),(49,29),(49,41)],'ink',5);line(d,[(40,28),(49,28),(49,40)],'steel2',2)
        poly(d,[(45,41),(51,39),(55,43),(55,51),(51,55),(46,53)],'ink');poly(d,[(47,43),(51,42),(53,44),(53,50),(50,52),(48,51)],'wood');line(d,[(49,43),(49,49)],'edge');poly(d,[(19,44),(24,44),(23,51),(21,54),(19,51)],'ink');rect(d,(20,45,23,49),'steel');line(d,[(21,50),(21,60)],'steel2',2);line(d,[(20,53),(22,55),(20,57),(21,59)],'steel')
    elif name=='homewares.serving_bowl':
        poly(d,[(7,27),(56,27),(52,44),(45,52),(24,54),(14,48),(9,37)],'ink');poly(d,[(9,28),(54,28),(50,43),(43,49),(25,52),(16,46),(11,37)],'teal');poly(d,[(11,31),(17,33),(18,43),(25,49),(22,49),(15,44)],'teal2');line(d,[(21,45),(47,43)],'gold2',2);ellipse(d,(5,13,58,35),'ink');ellipse(d,(7,15,56,33),'cream');ellipse(d,(10,17,53,30),'steel');ellipse(d,(12,18,51,28),'paper');ellipse(d,(16,20,46,26),'cream');line(d,[(13,19),(26,17),(43,19)],'#ffffff')
        # Fictional workshop stamp: harbor anchor, no real-world maker logo.
        line(d,[(33,34),(33,41),(29,39)],'teal3');line(d,[(33,41),(37,38)],'teal3');ellipse(d,(32,32,34,34),'teal3');line(d,[(28,42),(31,43),(35,42),(38,42)],'teal2');rect(d,(25,52,44,54),'ink');line(d,[(27,52),(42,52)],'steel')
    elif name=='paper.tram_print':
        poly(d,[(7,4),(55,4),(58,7),(58,59),(8,59),(5,56),(5,7)],'ink');rect(d,(7,6,56,57),'wood');rect(d,(9,8,54,55),'gold');rect(d,(11,10,52,53),'paper');rect(d,(14,13,49,48),'blue2');rect(d,(14,31,49,48),'stone');line(d,[(15,46),(48,38)],'grout');line(d,[(15,48),(48,40)],'paper');rect(d,(17,28,19,35),'green');poly(d,[(16,29),(19,20),(23,29)],'green2');line(d,[(38,14),(38,22)],'dark');line(d,[(14,17),(49,15)],'dark');line(d,[(34,23),(37,17),(38,17)],'ink')
        poly(d,[(25,23),(40,21),(45,26),(45,39),(26,41),(23,37),(23,27)],'ink');poly(d,[(26,24),(39,23),(43,27),(43,37),(27,39),(25,36),(25,28)],'red');rect(d,(27,26,32,31),'cream');rect(d,(35,25,40,30),'cream');rect(d,(28,27,31,29),'blue2');rect(d,(36,26,39,28),'blue2');line(d,[(26,34),(42,32)],'gold2',2);ellipse(d,(27,38,31,42),'ink');ellipse(d,(38,37,42,41),'ink');rect(d,(29,35,31,36),'paper');rect(d,(38,34,40,35),'paper');line(d,[(8,7),(8,54)],'lightwood');line(d,[(10,8),(52,8)],'edge')
    elif name=='practice.cup':
        poly(d,[(11,16),(40,16),(40,50),(36,56),(20,58),(12,54),(9,23)],'ink');poly(d,[(12,19),(38,19),(38,49),(34,53),(20,55),(14,51),(11,25)],'steel');poly(d,[(14,23),(18,23),(17,46),(20,52),(16,50)],'steel2');poly(d,[(39,20),(52,20),(57,25),(57,43),(52,48),(40,48),(40,43),(50,43),(52,40),(52,27),(49,25),(40,25)],'ink');line(d,[(41,22),(51,22),(55,26),(55,41),(51,45),(42,45)],'steel2',2);ellipse(d,(9,11,41,23),'ink');ellipse(d,(11,13,39,21),'steel2');ellipse(d,(14,15,36,20),'dark');line(d,[(15,14),(32,13)],'cream')
        for y in range(28,49,5):line(d,[(28 if y%2 else 31,y),(36,y)],'ink')
        rect(d,(20,53,29,54),'steel2');line(d,[(38,25),(38,35)],'paper')
    elif name=='practice.square':
        poly(d,[(9,4),(21,4),(21,43),(56,43),(56,56),(9,56)],'ink');poly(d,[(11,6),(19,6),(19,45),(54,45),(54,54),(11,54)],'steel');line(d,[(12,7),(12,52),(52,52)],'steel2',2);rect(d,(13,8,18,10),'steel2');ellipse(d,(13,12,17,16),'ink');ellipse(d,(14,13,16,15),'paper')
        for y in range(20,43,3):line(d,[(16 if y%2 else 14,y),(18,y)],'dark')
        for x in range(23,54,3):line(d,[(x,46),(x,48 if x%2 else 50)],'dark')
        line(d,[(21,48),(23,48)],'steel2');rect(d,(14,50,16,51),'paper')
    elif name=='practice.folio':
        poly(d,[(10,11),(44,5),(54,14),(54,52),(18,59),(9,52),(8,16)],'ink');poly(d,[(12,13),(44,7),(51,14),(51,50),(19,56),(12,50),(10,16)],'red');poly(d,[(18,15),(45,10),(48,13),(48,49),(18,54)],'paper');poly(d,[(44,10),(44,16),(49,15)],'cream');line(d,[(19,52),(46,47)],'grout');line(d,[(20,50),(46,45)],'cream');line(d,[(14,15),(14,48),(18,52)],'red2',2)
        for y in [21,27,33,39]:line(d,[(23,y),(29,y-1),(31,y),(39,y-2),(43,y-2)],'grout')
        line(d,[(31,9),(31,54)],'wood',3);rect(d,(28,28,35,38),'ink');rect(d,(29,29,34,37),'gold');rect(d,(30,30,33,35),'gold2');rect(d,(31,31,32,34),'wood');line(d,[(46,19),(46,38)],'cream')
    elif name=='covered':
        poly(d,[(10,18),(45,12),(57,26),(54,51),(22,58),(8,44)],'ink');poly(d,[(12,19),(44,14),(54,27),(23,34)],'paper');poly(d,[(24,35),(54,28),(52,49),(24,55)],'stone');poly(d,[(10,22),(22,35),(22,54),(10,43)],'grout');line(d,[(29,17),(36,31),(35,53)],'wood',2);line(d,[(11,33),(53,40)],'wood',2);rect(d,(39,34,48,38),'cream')
    return im
IDS=['homewares.enamel_kettle','homewares.folding_stool','tools.desk_fan','tools.hand_drill','homewares.serving_bowl','paper.tram_print','practice.cup','practice.square','practice.folio','covered']
for name in IDS:save(inspect(name),'inspect',name,'inspect')

# Ledger/enamel/timber style: intentional corner construction and flat centers
# keep stretching crisp. Insets are fixed, no smooth shadows or giant pills.
UI_COLORS={'paper':'#f7e9cc','ink':'#282522','teal':'#245b59','ivory':'#fff1d6','walnut':'#573d31','brass':'#c59950','brass_hi':'#f4d688'}
def ui_skin(name):
    im,d=canvas(32,32)
    if name=='paper_panel':
        rect(d,(1,1,30,30),'#282522');rect(d,(2,2,29,29),'#a57c50');rect(d,(3,3,28,28),'#f7e9cc');line(d,[(4,3),(27,3)],'#fff7e1');line(d,[(3,4),(3,27)],'#fff7e1');line(d,[(4,28),(28,28)],'#d5bd92')
        # Brass corner book protectors, with cream rivet reflecting upper left.
        for x,y,sx,sy in [(2,2,1,1),(29,2,-1,1),(2,29,1,-1),(29,29,-1,-1)]:
            line(d,[(x+sx*5,y),(x,y),(x,y+sy*5)],'#73503e',2);rect(d,(x+sx,y+sy,x+sx*2,y+sy*2),'#c59950');rect(d,(x+sx,y+sy,x+sx,y+sy),'#f4d688')
    elif name in ['teal_button','teal_button_hover','teal_button_pressed','teal_button_disabled']:
        center={'teal_button':'#245b59','teal_button_hover':'#2d6b65','teal_button_pressed':'#1b4847','teal_button_disabled':'#6d695e'}[name]
        rect(d,(1,1,30,30),'#282522');rect(d,(2,2,29,29),'#9a7647');rect(d,(3,3,28,28),center);line(d,[(4,3),(27,3)],'#5c9483' if 'pressed' not in name else '#163c3b');line(d,[(3,4),(3,27)],'#4a8074');line(d,[(4,28),(28,28)],'#173e3e')
        for x,y in [(5,5),(26,5),(5,26),(26,26)]:rect(d,(x-1,y-1,x+1,y+1),'#163c3b');rect(d,(x,y,x,y),'#d8b775')
    elif name in ['timber_tab','timber_tab_pressed']:
        rect(d,(1,1,30,30),'#282522');rect(d,(2,2,29,29),'#8b6547');rect(d,(3,3,28,28),'#573d31' if name=='timber_tab' else '#3c302a');line(d,[(4,3),(27,3)],'#ae8257');line(d,[(3,4),(3,26)],'#8b6547');line(d,[(4,28),(28,28)],'#382c27');line(d,[(8,5),(24,5)],'#73503e');line(d,[(10,27),(24,27)],'#73503e')
        for x,y in [(5,5),(26,5),(5,26),(26,26)]:rect(d,(x,y,x,y),'#ba935b')
    elif name=='focus_ring':
        # Transparent interior overlays the normal button without losing color.
        d.rectangle((0,0,31,31),outline='#282522',width=1);d.rectangle((1,1,30,30),outline='#fff1d6',width=2);d.rectangle((3,3,28,28),outline='#c59950',width=1)
    return im
SKINS=['paper_panel','teal_button','teal_button_hover','teal_button_pressed','teal_button_disabled','timber_tab','timber_tab_pressed','focus_ring']
for name in SKINS:
    save(ui_skin(name),'ui',name,'ui_ninepatch');records[-1]['patch_margins']=[8,8,8,8];records[-1]['content_margins']=[12,8,12,8]

# Complete license and source register for unmodified upstream font binaries.
FONT_SOURCES={
 'AtkinsonHyperlegibleNext-Regular.ttf':('https://raw.githubusercontent.com/googlefonts/atkinson-hyperlegible-next/main/fonts/ttf/AtkinsonHyperlegibleNext-Regular.ttf','Atkinson-OFL.txt','Copyright 2020-2024 The Atkinson Hyperlegible Next Project Authors (https://github.com/googlefonts/atkinson-hyperlegible-next)'),
 'AtkinsonHyperlegibleNext-Semibold.ttf':('https://raw.githubusercontent.com/googlefonts/atkinson-hyperlegible-next/main/fonts/ttf/AtkinsonHyperlegibleNext-SemiBold.ttf','Atkinson-OFL.txt','Copyright 2020-2024 The Atkinson Hyperlegible Next Project Authors (https://github.com/googlefonts/atkinson-hyperlegible-next)'),
 'Silkscreen-Regular.ttf':('https://raw.githubusercontent.com/google/fonts/main/ofl/silkscreen/Silkscreen-Regular.ttf','Silkscreen-OFL.txt','Copyright 2001 The Silkscreen Project Authors (https://github.com/googlefonts/silkscreen)')}
for name,(source,license_file,copyright) in FONT_SOURCES.items():
    path=ROOT/'assets'/'fonts'/name
    if not path.exists():continue
    records.append(dict(asset_id='font.'+name,path='res://assets/fonts/'+name,kind='font',placeholder=False,origin='Official upstream Google Fonts repository download',source_url=source,creator=copyright,license='OFL-1.1',commercial_use_basis='SIL Open Font License1.1 permits bundling with software; complete copyright/license notices included',modification_status='Unmodified upstream binary; local semibold filename normalizes capital B only',attribution_file='assets/fonts/'+license_file,editable_source=source,review_date='2026-10-15',review_scope='Exact bundled OFL notices read; Pillow FreeType font family and style opened successfully',sha256=hashlib.sha256(path.read_bytes()).hexdigest()))

manifest_path=ROOT/'assets'/'visual_manifest.json';data=json.loads(manifest_path.read_text());owned={r['asset_id'] for r in records};data['assets']=[r for r in data['assets'] if r['asset_id'] not in owned]+records;manifest_path.write_text(json.dumps(data,indent=2)+'\n')
review=ROOT/'art'/'review';review.mkdir(exist_ok=True)
sheet=Image.new('RGBA',(750,420),'#f7e9cc');d=ImageDraw.Draw(sheet);font=ImageFont.truetype(str(ROOT/'assets/fonts/AtkinsonHyperlegibleNext-Regular.ttf'),14)
for i,name in enumerate(IDS):
    x=i%5*150;y=i//5*205;sheet.alpha_composite(inspect(name).resize((128,128),Image.Resampling.NEAREST),(x+10,y+10));d.text((x+8,y+146),name.split('.')[-1],font=font,fill='#282522')
sheet.convert('RGB').save(review/'inspect-closeups.png')
sheet=Image.new('RGBA',(704,368),'#d5bd9d');d=ImageDraw.Draw(sheet)
for i,name in enumerate(SKINS):
    x=i%4*176;y=i//4*184;sheet.alpha_composite(ui_skin(name).resize((128,128),Image.Resampling.NEAREST),(x+24,y+12));d.text((x+4,y+148),name,font=font,fill='#282522')
sheet.convert('RGB').save(review/'ledger-ui.png')
sheet=Image.new('RGB',(720,240),'#f7e9cc');d=ImageDraw.Draw(sheet)
for y,(name,source) in enumerate(FONT_SOURCES.items()):
    font=ImageFont.truetype(str(ROOT/'assets/fonts'/name),22);d.text((15,y*75+7),name,font=ImageFont.truetype(str(ROOT/'assets/fonts/AtkinsonHyperlegibleNext-Regular.ttf'),14),fill='#573d31');d.text((15,y*75+30),'Lantern Lot   1/I/l   0/O   100000   8%   − 15 = 14',font=font,fill='#282522')
sheet.save(review/'font-specimen.png')
print('Inspect/UI/fonts registered:',len(records))
