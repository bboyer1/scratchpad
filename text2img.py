# Converting letters -> jpg

from PIL import Image, ImageDraw, ImageFont
from string import ascii_letters


def build_img(letter, counter):
    img = Image.new('RGB', (100, 100), color='white')
    ImageDraw.Draw(img).text((50, 50), letter, fill=(0, 0, 0))
    img.save(f'images/{letter}_{counter}.jpg')

ALPHA = ascii_letters + " " # "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ "

for counter, letter in enumerate(ALPHA):
    build_img(letter, counter)

print(f'Image creation complete check the images folder')