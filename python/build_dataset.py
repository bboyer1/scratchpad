### Bret Boyer
### Build images for all letters and fonts

from PIL import Image, ImageDraw, ImageFont

FONT_LIST = [
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
    "Impact",
    "Optima",
    "Palatino",
    "Papyrus",
    "Skia",
    "Tahoma",
    "Times",
    "Times New Roman",
    "Verdana",
]

LETTERS = "abcdefghijklmnopqrstuvwxyz"
fontsize = 28

def build_img(letter, fonttype="Arial", fontsize=28):
    font = ImageFont.truetype(fonttype, fontsize)
    img = Image.new('RGB', (32, 32), color='white') # 32x32 pixels
    ImageDraw.Draw(img).text((0, -4), letter, fill=(0, 0, 0), font=font) # letter starts at pixel (messing w this is required depending on font and pixels available)
    return img

for font in FONT_LIST:
    for letter in LETTERS:
        img = build_img(letter, font, fontsize)
        img.save(f'training_images/{letter}_{font}_{fontsize}.jpg')
