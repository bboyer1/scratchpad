# Converting letters -> jpg

from PIL import Image, ImageDraw, ImageFont
from string import ascii_letters
from time import sleep

ALPHA = ascii_letters + " " # "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ "

# font_list = [
#     "Copperplate",
#     "Helvetica",
#     "Arial",
#     "Avenir",
#     "Chalkboard",
#     "Chalkduster",
#     "Charter",
#     "Courier",
#     "Didot",
#     "Futura",
#     "Geneva",
#     "Georgia",
#     "Luminari",
#     "Menlo",
#     "Monaco",
#     "Noteworthy",
#     "Impact",
#     "Optima",
#     "Palatino",
#     "Papyrus",
#     "Phosphate",
#     "Skia",
#     "Tahoma",
#     "Times",
#     "Times New Roman",
#     "Verdana",
#     "Zapfino"
# ]


def build_img(letter, counter, fonttype="Arial", fontsize=24):
    font = ImageFont.truetype(fonttype, fontsize)
    img = Image.new('RGB', (32, 32), color='white') # 30x30 pixels
    ImageDraw.Draw(img).text((8, 4), letter, fill=(0, 0, 0), font=font) # letter starts at pixel 10x10
    return img


#for font in font_list:
for counter, letter in enumerate(ALPHA):
    img = build_img(letter, counter) #, font)
    img.save(f'images/{letter}_{counter}_.jpg')


#print(f'Image creation complete for {len(font_list)} fonts')
