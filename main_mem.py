"""f = open("main_mem.mem", "w")
for i in range (2*1024*1024):
    f.write(hex(i*5) + "\n")
    
f.close()"""

f = open("main_mem.mem", "w")
for i in range (1024*512):
    for j in range (0, 5):
        f.write(hex(j*5) + "\n")
    
f.close()
