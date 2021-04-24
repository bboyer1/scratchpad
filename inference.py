from hv_training import encode, convert_img, threshold

import sys

DIM = 100
dir_path = f"/Users/Bret/Desktop/text-to-image/src/outputs/dim{DIM}"


### XOR
# a = "11011111101100110110011001011101000"
# b = "11001011101100111000011100001100001"
# y = int(a,2) ^ int(b,2)
# print(y)

def xor(bin_1, bin_2):
    return int(bin_1, 2) ^ int(bin_2, 2)

def main():
    ### Take in an image
    image = sys.argv[1]


    ### Open assicative memory
    am = dict()
    with open(f"{dir_path}/Encoded_dim_{DIM}.data", "r") as ass_mem:
        for line in ass_mem:
            am[line[0]] = line[3:-1]

    ### Get the feature set
    with open(f"{dir_path}/feature_set_{DIM}.txt", "r") as fs:
        file = fs.readline()[1:-1]

    feature_set = file.replace("'", "").split(", ")

    hv = convert_img(image)
    print(hv)

    ## get hv of image
    img_hv = threshold(encode(feature_set, hv), DIM, 513)
    print(img_hv)


    dist = int(am['z'], 2)
    for key in am:
        xor_val = xor(img_hv, am[key])
        print(f"{key} {xor_val}")
        if xor_val < dist:
            dist = xor_val
            closest_dist = key
    print(closest_dist)




### xor calculation

if __name__ == '__main__':
    main()