### Inference classifier that takes in an image
### Bret Boyer

from hv_training import encode, convert_img, threshold
import sys, re

DIM = 10000
dir_path = f"outputs/dim{DIM}"


def xor(bin_1, bin_2):
    return int(bin_1, 2) ^ int(bin_2, 2)


def just_the_1s(bin_str):
    return len(re.findall("1", bin_str))


def main():
    # Take in an image
    image = sys.argv[1]

    # Get assicative memory
    am = dict()
    with open(f"{dir_path}/Encoded_dim_{DIM}.data", "r") as ass_mem:
        for line in ass_mem:
            am[line[0]] = line[3:-1]

    # Get the feature set
    with open(f"{dir_path}/feature_set_{DIM}.txt", "r") as fs:
        file = fs.readline()[1:-1]

    feature_set = file.replace("'", "").split(", ")
    hv = convert_img(image)

    # get hv of image
    encode_list = encode(feature_set, hv)
    img_hv = threshold(encode_list, DIM, 513)

    # Inference
    dist = DIM
    for key in am:
        xor_val = xor(img_hv, am[key])
        ham_dist = just_the_1s(bin(xor_val)[2:])
        if ham_dist < dist:
            dist = ham_dist
            closest_dist = key
    print(closest_dist)


if __name__ == "__main__":
    main()
