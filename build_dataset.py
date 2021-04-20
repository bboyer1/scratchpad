### Bret Boyer
### Build images for a, b, c with 3 fonts

from PIL import Image, ImageDraw, ImageFont

FONT_LIST = [
    "Copperplate",
    "Helvetica",
    "Arial",
]

LETTERS = "abc"


def build_img(letter, fonttype="Arial", fontsize=10):
    font = ImageFont.truetype(fonttype, fontsize)
    img = Image.new('RGB', (5, 7), color='white') # 5x7 pixels
    ImageDraw.Draw(img).text((0, -3), letter, fill=(0, 0, 0), font=font) # letter starts at pixel (messing w this is required depending on font and pixels available)
    return img

for font in FONT_LIST:
    for letter in LETTERS:
        img = build_img(letter, font)
        img.save(f'test/{letter}_{font}.jpg')
