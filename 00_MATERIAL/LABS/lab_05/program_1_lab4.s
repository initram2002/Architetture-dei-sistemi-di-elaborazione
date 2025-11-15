#******** RISCV NEURAL NETWORK PROGRAM ************
#-------------------------------------------
# program_1.s
# This program calculates the output of a neural
# network neuron: y = f(x) where x = sum(i_j * w_j) + b
# and f(x) checks for NaN values
#-------------------------------------------
    # Data section
    .section .data
# Input vector i: 16 single precision floating point values
i: .float 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0
   .float 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0

# Weight vector w: 16 single precision floating point values
w: .float 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5
   .float 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5

# Bias value b = 0xab (171 in decimal as float)
b: .float 171.0

# Output value y
y: .float 0.0

# Temporary storage
T0: .word 0x0BADC0DE

    # Code section
    .section .text
    .globl _start
_start:
# Load first elements of each data area into cache
    la x1, i
    flw fs1, 0(x1)
    la x1, w
    flw fs1, 0(x1)
    la x1, b
    flw fs1, 0(x1)
    la x1, y
    flw fs1, 0(x1)
    la x1, T0
    lw x2, 0(x1)

Main:
    # Initialize variables
    li x3, 16           # x3 = K = number of elements (16)
    li x4, 0            # x4 = j = loop counter

    # Load base addresses
    la x5, i            # x5 = address of input vector i
    la x6, w            # x6 = address of weight vector w

    # Initialize accumulator for sum
    fmv.w.x fs0, zero   # fs0 = 0.0 (accumulator for x)

sum_loop:
    # Load i[j] and w[j]
    flw fs1, 0(x5)      # fs1 = i[j]
    flw fs2, 0(x6)      # fs2 = w[j]

    # Multiply i[j] * w[j]
    fmul.s fs3, fs1, fs2    # fs3 = i[j] * w[j]

    # Add to accumulator
    fadd.s fs0, fs0, fs3    # fs0 = fs0 + (i[j] * w[j])

    # Move to next elements
    addi x5, x5, 4      # increment i pointer by 4 bytes
    addi x6, x6, 4      # increment w pointer by 4 bytes
    addi x4, x4, 1      # j++

    # Check if we need to continue loop (if j < K, continue)
    blt x4, x3, sum_loop    # if j < K, loop back

compute_activation:
    # Add bias b to the sum
    la x7, b            # x7 = address of bias
    flw fs4, 0(x7)      # fs4 = b
    fadd.s fs0, fs0, fs4    # fs0 = x = sum + b

    # Check for NaN: extract exponent and check if it equals 0xFF
    # Move float to integer register to check bit pattern
    fmv.x.w x8, fs0     # x8 = bit pattern of x

    # Extract exponent (bits 30-23 for single precision)
    srli x9, x8, 23     # shift right by 23 bits
    andi x9, x9, 0xFF   # mask to get 8-bit exponent

    # Check if exponent == 0xFF (all ones for single precision NaN/Inf)
    li x10, 0xFF        # x10 = 0xFF
    bne x9, x10, set_value   # if exponent != 0xFF, set y = x

set_zero:
    # Set y = 0.0
    fmv.w.x fs5, zero   # fs5 = 0.0
    j store_result      # unconditional branch to store

set_value:
    # y = x
    fmv.s fs5, fs0      # fs5 = x (output y)

store_result:
    # Store result y in memory
    la x11, y           # x11 = address of y
    fsw fs5, 0(x11)     # store fs5 (y) to memory

End:
    # exit() syscall
    li a0, 0
    li a7, 93
    ecall