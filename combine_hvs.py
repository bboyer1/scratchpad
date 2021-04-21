import ast


LETTERS = {
    "a": [], "b": [], "c": [], "d": [], "e": [],
    "f": [], "g": [], "h": [], "i": [], "j": [],
    "k": [], "l": [], "m": [], "n": [], "o": [],
    "p": [], "q": [], "r": [], "s": [], "t": [],
    "u": [], "v": [], "w": [], "x": [], "y": [],
    "z": []
    }


def threshold(pixel_list, dim=100, threshold_val=14):
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

with open("/Users/Bret/Desktop/text-to-image/src/hv_files_abc.txt", "r") as fn:
    hv_dict = fn.readline()
    hv_dict = ast.literal_eval(hv_dict)

for letter in LETTERS:
    for key in hv_dict:
        if key[0] == letter:
            _file = LETTERS[letter]
            _file.append(hv_dict[key])
            LETTERS[letter] = _file

#print(LETTERS)

for key in LETTERS:
    print(f"{key}: {threshold(LETTERS[key])}")

