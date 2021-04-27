### File used to run the inference and return output
### Bret Boyer

import os
import subprocess


directory = "training_images" # test_images
path = f"/Users/Bret/Desktop/text-to-image/src/{directory}"
list_of_images = os.listdir(path)

num_of_images = len(list_of_images)

correct = 0
for i in list_of_images:
    value = i[0]
    test = subprocess.run(["python3", "inference.py", f"training_images/{i}"], capture_output=True, text=True)
    if value == test.stdout[0]:
        correct += 1
print(f"Sum: {correct}\nPercentage: {(correct/num_of_images)* 100}")