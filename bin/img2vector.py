# converts images to vector
import cv2
from numpy import concatenate
from os import listdir
import csv

directory = "images" #"32x32"# 
path = f"/Users/Bret/Desktop/text-to-image/src/{directory}"

list_of_images = listdir(path)
list_of_images.remove(".DS_Store")
print(f"{len(list_of_images)} files will be converted to binary")

def list2string(list_obj):
    return ''.join([str(elem) for elem in list_obj])

hyper_vectors = dict()
for counter, file in enumerate(list_of_images):
    #print(path+"/"+file)
    img = cv2.imread(path+"/"+file, 0)

    # converting to its binary form
    _, binary = cv2.threshold(img, 127, 1, cv2.THRESH_BINARY_INV)
    hyper_vector = list(concatenate(binary).flat) # builds the hypervector
    hyper_vector = list2string(hyper_vector)
    print(f'File number: {counter+1}')
    hyper_vectors[file] = hyper_vector
    #print(list2string(hyper_vector))

# # # w = csv.writer(open("hypervectors.csv", "w"))
# # # for key, val in hyper_vectors.items():
# # #     w.writerow([key, val])

with open("hypervectors.data", "w") as hv_file:
    for key, val in hyper_vectors.items():
        hv_file.write(key)
        hv_file.write("\n")
        hv_file.write(val)
        hv_file.write("\n\n\n")

# with open("full_data_set.data", "w") as hv_file:
#     for key, val in hyper_vectors.items():
#         hv_file.write(key)
#         hv_file.write("\n")
#         hv_file.write(val)
#         hv_file.write("\n\n\n")

