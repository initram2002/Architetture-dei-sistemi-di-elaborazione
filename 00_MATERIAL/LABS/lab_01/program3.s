#******** RISCV INITIAL PROGRAM ************
#-------------------------------------------
# program3.s
# This program finds common elements between
# two byte arrays and checks ordering properties
# of the resulting array
#-------------------------------------------
    # Data section
    .section .data
# Input arrays of 10 bytes each
v1:     .byte 2, 6, -3, 11, 9, 18, -13, 16, 5, 1
v2:     .byte 4, 2, -13, 3, 9, 9, 7, 16, 4, 7
# Output array for common elements (max 10 bytes)
v3:     .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
# Flags
flag1:  .byte 0     # 1 if v3 is empty, 0 otherwise
flag2:  .byte 0     # 1 if v3 is strictly increasing, 0 otherwise
# Constants
size:   .word 10    # Size of input arrays

    # Code section
    .section .text
# The _start label signals the entry point of the program
    .globl _start
_start:
# Load first byte/word of each data area for cache optimization
    la x1, v1
    lb x2, 0(x1)
    la x1, v2
    lb x2, 0(x1)
    la x1, v3
    lb x2, 0(x1)
    la x1, flag1
    lb x2, 0(x1)
    la x1, flag2
    lb x2, 0(x1)
    la x1, size
    lw x2, 0(x1)

Main:
    # Initialize variables
    la x10, v1          # x10 = address of v1
    la x11, v2          # x11 = address of v2
    la x12, v3          # x12 = address of v3
    li x13, 10          # x13 = size of arrays
    li x14, 0           # x14 = index i for v1 (outer loop)
    li x15, 0           # x15 = index k for v3 (output counter)

outer_loop:
    beq x14, x13, check_flags   # if i == 10, go to flag checking

    # Load v1[i]
    add x16, x10, x14   # x16 = address of v1[i]
    lb x17, 0(x16)      # x17 = v1[i]

    # Inner loop: search v1[i] in v2
    li x18, 0           # x18 = index j for v2 (inner loop)

inner_loop:
    beq x18, x13, next_outer    # if j == 10, element not found

    # Load v2[j]
    add x19, x11, x18   # x19 = address of v2[j]
    lb x20, 0(x19)      # x20 = v2[j]

    # Compare v1[i] with v2[j]
    beq x17, x20, found_match   # if v1[i] == v2[j], found match

    # Increment inner loop counter
    addi x18, x18, 1    # j++
    j inner_loop

found_match:
    # Store v1[i] in v3[k]
    add x21, x12, x15   # x21 = address of v3[k]
    sb x17, 0(x21)      # v3[k] = v1[i]
    addi x15, x15, 1    # k++ (increment output counter)

next_outer:
    # Increment outer loop counter
    addi x14, x14, 1    # i++
    j outer_loop

check_flags:
    # Check flag1: is v3 empty?
    la x22, flag1       # x22 = address of flag1
    beqz x15, set_flag1 # if k == 0, v3 is empty
    sb  x0, 0(x22)      # flag1 = 0 (v3 not empty)
    j check_flag2

set_flag1:
    li x23, 1           # x23 = 1
    sb x23, 0(x22)      # flag1 = 1 (v3 is empty)
    j check_flag2

check_flag2:
    # Check flag2: is v3 strictly increasing?
    la x24, flag2       # x24 = address of flag2

    # If v3 is empty or has only 1 element, set flag2 = 0
    li x25, 2           # x25 = 2
    blt x15, x25, clear_flag2   # if k < 2, cannot be strictly increasing

    # Check if each element is greater than the previous
    li x26, 1           # x26 = index for checking (start from 1)
    li x27, 1           # x27 = assume strictly increasing (1)

check_increasing_loop:
    beq x26, x15, set_flag2 # if checked all elements, set flag2

    # Load v3[i - 1] and v3[i]
    addi x28, x26, -1   # x28 = i - 1
    add x29, x12, x28   # x29 address of v3[i - 1]
    lb x30, 0(x29)      # x30 = v3[i - 1]

    add x31, x12, x26   # x31 = address of v3[i]
    lb x5, 0(x31)       # x5 = v3[i]

    # Check if v3[i] > v3[i - 1]
    bge x30, x5, clear_flag2    # if v3[i - 1] >= v3[i], not strictly increasing

    # Continue checking
    addi x26, x26, 1    # i++
    j check_increasing_loop

set_flag2:
    sb x27, 0(x24)      # flag2 = 1 (strictly increasing)
    j End

clear_flag2:
    sb x0, 0(x24)       # flag2 = 0 (not strictly increasing)

End:
    # exit() syscall. This is needed to end the simulation gracefully
    li a0, 0
    li a7, 93
    ecall
