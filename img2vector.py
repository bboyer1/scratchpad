# converts images to vector
import cv2
from numpy import concatenate
from os import listdir
import csv


list_of_images = listdir("/Users/Bret/Desktop/text-to-image/src/images")
list_of_images.remove(".DS_Store")
print(f"{len(list_of_images)} files will be converted to binary")

hyper_vectors = dict()
for counter, file in enumerate(list_of_images):
    print(file)
    img = cv2.imread(f'images/{file}', 2)

    # converting to its binary form
    _, binary = cv2.threshold(img, 0, 1, cv2.THRESH_BINARY)
    hyper_vector = list(concatenate(binary).flat) # builds the hypervector
    print(f'File count: {counter}')
    hyper_vectors[file] = hyper_vector

w = csv.writer(open("hypervectors.csv", "w"))
for key, val in hyper_vectors.items():
    w.writerow([key, val])