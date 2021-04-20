# converts test images to vector
import cv2
import numpy as np
from os import listdir
from random import randint


# Fixture for dimension size of 10
feature_set = [
    '1111110101', '1100100100', '1111000110', '1001111001', '0111000010',
    '1111001101', '1100011100', '0001111010', '0110110101', '0101011010',
    '1111110101', '0010111100', '1011110101', '1001111000', '0011111100', 
    '0001000010', '0101001000', '0001001101', '1111001001', '0111111011',
    '1111110010', '1001100011', '0101100111', '1011110010', '1000010111',
    '1110111110', '1001011100', '0100011000', '0111111111', '0111011001',
    '0001111010', '0001101001', '0001011010', '1011010001', '1010010110'
]


DIM = 10 # Length of HV
THRESHOLD = 18 # 5x7 = 35pixels, then 35+1/2

# Pull images from directory
directory = "test"
path = f"/Users/Bret/Desktop/text-to-image/src/{directory}"
list_of_images = listdir(path)
#print(f"{len(list_of_images)} files will be converted to binary")

def list2string(list_obj):
    """
    Convert list to a string.
    """
    return ''.join([str(elem) for elem in list_obj])

def shift_one(hv_to_shift):
    """
    Used to shift hypervector to the right once.
    Only called for white pixel(0 value).
    """
    return hv_to_shift[-1] + hv_to_shift[:-1]

def encode(pixel_feature, hypervector):
    """
    Encodes a single hv passed in using the pixel feature set
    """
    hv_str = list()
    for pixel_num, bit in enumerate(hypervector):
        if bit == "0":
            # Shifts feature set hv for pixel_num
            pixel_feature[pixel_num] = shift_one(pixel_feature[pixel_num])

        hv_str.append(pixel_feature[pixel_num])

    return hv_str

def threshold(pixel_list, dim=DIM, threshold_val=THRESHOLD):
    """
    Takes in a pixel_list to iterate through the pixel values

    """
    threshold_elem = list()
    for elem in range(dim):
        sum = 0
        for pixel in pixel_list:
            sum = sum + int(pixel[elem])
        
        threshold_elem.append(sum)
    print(f"Accumulation of values = {threshold_elem}")
    
    threshold = ""
    for num in threshold_elem:
        binary = num//threshold_val
        threshold += str(binary)

    return threshold

# def feature_set(num_of_pixels=35, dim=DIM):
#     pixel_set = list()
#     for x in range(num_of_pixels):
#         hv = [randint(0,1) for n in range(0, dim)]
#         pixel_set.append(list2string(hv))
#     return pixel_set

def main():
    ### Convert all images to binary form
    hyper_vectors = dict()
    for file in list_of_images:
        img = cv2.imread(path+"/"+file, 0)

        # converting to its binary form
        _, binary = cv2.threshold(img, 127, 1, cv2.THRESH_BINARY_INV)

        # builds the hypervector
        hyper_vector = list(np.concatenate(binary).flat) 
        hyper_vector = list2string(hyper_vector)
        hyper_vectors[file] = hyper_vector

    #pixel_hvs = feature_set()

    print("Feature_set = " + str(feature_set))

    ### Loops through all hvs to encode and threshold
    for key in hyper_vectors:
        _pixel_hv = feature_set.copy()

        print(f"HV {key}\nInput: {hyper_vectors[key]}")
        mylist = encode(_pixel_hv, hyper_vectors[key])
        print(f"After Thresholding: {threshold(mylist)}\n")

        

if __name__ == '__main__':
    main()


