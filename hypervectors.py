from random import randint


def list2string(list_obj):
    return ''.join([str(elem) for elem in list_obj])

with open("hv_1k.txt", "w") as fn:
    for x in range(0,35):
        hv = [randint(0,1) for n in range(0,10000)]
        fn.write(list2string(hv))
        fn.write("\n\n\n")
