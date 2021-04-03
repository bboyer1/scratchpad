# Converting letters -> jpg

from PIL import Image, ImageDraw, ImageFont
from string import ascii_letters
from time import sleep

ALPHA = ascii_letters + " " # "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ "



font_list = [
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
    "Zapfino"
]


def build_img(letter, counter, fonttype, fontsize=12):
    font = ImageFont.truetype(fonttype, fontsize)
    img = Image.new('RGB', (100, 100), color='white')
    ImageDraw.Draw(img).text((50, 50), letter, fill=(0, 0, 0), font=font)
    img.save(f'images/{letter}_{counter}_{fonttype}.jpg')

for font in font_list:
    sleep(0.5)
    for counter, letter in enumerate(ALPHA):
        build_img(letter, counter, font)


print(f'Image creation complete for {len(font_list)} fonts')