### Bret Boyer
### Build images for a, b, c with 3 fonts

from PIL import Image, ImageDraw, ImageFont

FONT_LIST = [
    "Copperplate",
    "Helvetica",
    "Arial",
    "Avenir",
    "Chalkboard",
    "Chalkduster",
    "Charter",
    "Courier",
    "Didot",
    "Futura",
    "Geneva",
    "Georgia",
    "Luminari",
    "Menlo",
    "Monaco",
    "Noteworthy",
    "Impact",
    "Optima",
    "Palatino",
    "Papyrus",
    "Phosphate",
    "Skia",
    "Tahoma",
    "Times",
    "Times New Roman",
    "Verdana",
]

LETTERS = "abcdefghijklmnopqurstuvwxyz"


def build_img(letter, fonttype="Arial", fontsize=32):
    font = ImageFont.truetype(fonttype, fontsize)
    img = Image.new('RGB', (32, 32), color='white') # 5x7 pixels
    ImageDraw.Draw(img).text((8, -4), letter, fill=(0, 0, 0), font=font) # letter starts at pixel (messing w this is required depending on font and pixels available)
    return img

for font in FONT_LIST:
    for letter in LETTERS:
        img = build_img(letter, font)
        img.save(f'test/imagesof32s/{letter}_{font}.jpg')
