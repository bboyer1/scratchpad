import ast
from hv_training import threshold

LETTERS = {
    "a": [], "b": [], "c": [], "d": [], "e": [],
    "f": [], "g": [], "h": [], "i": [], "j": [],
    "k": [], "l": [], "m": [], "n": [], "o": [],
    "p": [], "q": [], "r": [], "s": [], "t": [],
    "u": [], "v": [], "w": [], "x": [], "y": [],
    "z": []
    }

DIM = 100

with open(f"/Users/Bret/Desktop/text-to-image/src/hv_files_abc_{DIM}.txt", "r") as fn:
    hv_dict = fn.readline()
    hv_dict = ast.literal_eval(hv_dict)

for letter in LETTERS:
    for key in hv_dict:
        if key[0] == letter:
            _file = LETTERS[letter]
            _file.append(hv_dict[key])
            LETTERS[letter] = _file

#print(LETTERS)

with open(f"Encoded_dim_{DIM}.data", "w") as fe:
    for key in LETTERS:
        print(f"{key}: {threshold(LETTERS[key], dim=DIM, threshold_val=14)}")
        fe.write(f"{key}: {threshold(LETTERS[key])}")
