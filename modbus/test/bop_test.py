import random

with open('bop_test.lua', 'w') as f:
    f.write('package.path = "../?.lua;"..package.path..";"\n\n')
    f.write('bop = require("bop")\n\n')

    for i in range(0, 1000):
        a = random.randint(0,0xFFFFFFFF)
        b = random.randint(0,0xFFFFFFFF)
        f.write("assert(bop.band(0x%X, 0x%X) == 0x%X)\n" % (a, b, a & b))

    for i in range(0, 1000):
        a = random.randint(0,0xFFFFFFFF)
        b = random.randint(0,0xFFFFFFFF)
        f.write("assert(bop.bor(0x%X, 0x%X) == 0x%X)\n" % (a, b, a | b))

    for i in range(0, 1000):
        a = random.randint(0,0xFFFFFFFF)
        b = random.randint(0,0xFFFFFFFF)
        f.write("assert(bop.bxor(0x%X, 0x%X) == 0x%X)\n" % (a, b, a ^ b))

    a = 0xF50A
    b = 0
    f.write("assert(bop.bxor(0x%X, 0x%X) == 0x%X)\n" % (a, b, a ^ b))

    for i in range(0, 1000):
        a = random.randint(0,0xFFFFFFFF)
        b = random.randint(0,32)
        f.write("assert(bop.rshift(0x%X, 0x%X) == 0x%X)\n" % (a, b, a >> b))

    for i in range(0, 1000):
        a = random.randint(0,0xFFFFFFFF)
        b = random.randint(0,32)
        f.write("assert(bop.lshift(0x%X, 0x%X) == 0x%X)\n" % (a, b, a << b))        

