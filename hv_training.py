# converts test images to vector
import cv2
import numpy as np
from os import listdir
from random import randint

DIM = 100 # Length of HV
THRESHOLD = 513 # 32x32 = 1024pixels, then 512+1 for floor division

# Pull images from directory
directory = "imagesof32s"
path = f"/Users/Bret/Desktop/text-to-image/src/test/{directory}"
list_of_images = listdir(path)

#print(list_of_images)
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
    #print(f"Accumulation of values = {threshold_elem}")
    
    threshold = ""
    for num in threshold_elem:
        binary = num//threshold_val
        threshold += str(binary)

    return threshold

def feature_set(num_of_pixels=1024, dim=DIM):
    pixel_set = list()
    for x in range(num_of_pixels):
        hv = [randint(0,1) for n in range(0, dim)]
        pixel_set.append(list2string(hv))

    with open(f"feature_set_{dim}.txt", "w") as ff:
        ff.write(str(pixel_set))
    return pixel_set

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

    pixel_hvs = feature_set()

   
    print("Feature_set = " + str(pixel_hvs))

    hvs = dict()
    ### Loops through all hvs to encode and threshold
    for key in hyper_vectors:
        _pixel_hv = pixel_hvs.copy()

        print(f"HV {key}\nInput: {hyper_vectors[key]}")
        encode_list = encode(_pixel_hv, hyper_vectors[key])
        print(f"Output: {threshold(encode_list)}\n")
        
        hv = threshold(encode_list)

        hvs[key] = hv

    #print(hvs)


    with open(f"hv_files_abc_{DIM}.txt", "w") as fn:
        #fn.write(str(pixel_hvs))
        fn.write(str(hvs))

if __name__ == '__main__':
    main()
