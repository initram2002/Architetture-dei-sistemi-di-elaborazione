#******** RISCV INITIAL PROGRAM ************
#-------------------------------------------
# program_1.s
# This program implements a loop that processes
# three input vectors (v1, v2, v3) and generates
# three output vectors (v4, v5, v6) with floating
# point operations and conditional logic
# ------------------------------------------
    # Data section
    .section .data
# Input vectors - 32 single precision floating point values each
v1: .float 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 17.0, 18.0, 19.0, 20.0, 21.0, 22.0, 23.0, 24.0, 25.0, 26.0, 27.0, 28.0, 29.0, 30.0, 31.0, 32.0
v2: .float 0.5, 1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5, 8.5, 9.5, 10.5, 11.5, 12.5, 13.5, 14.5, 15.5, 16.5, 17.5, 18.5, 19.5, 20.5, 21.5, 22.5, 23.5, 24.5, 25.5, 26.5, 27.5, 28.5, 29.5, 30.5, 31.5
v3: .float 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0

# Output vectors - 32 empty slots for results
v4: .float 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
v5: .float 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
v6: .float 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0

T0: .word 0x0BADC0DE

    # Code section
    .section .text
# The _start label signals the entry point of the program
# DO NOT CHANGE ITS NAME. It must be "_start", not "start",
# not "main", not "start_".
# It's "_start" with a leading underscore and all lowercase letters
    .globl _start
_start:
# Load the first element of each vector into cache
# to avoid pipeline stalls during computation
    la x1, v1
    flw fs0, 0(x1)
    la x1, v2
    flw fs0, 0(x1)
    la x1, v3
    flw fs0, 0(x1)
    la x1, v4
    flw fs0, 0(x1)
    la x1, v5
    flw fs0, 0(x1)
    la x1, v6
    flw fs0, 0(x1)
    la x1, T0
    lw x2, 0(x1)

Main:
    # Initialize loop counter and base addresses
    li x10, 31              # x10 = i = 31 (loop counter, starts from 31)
    li x25, 1               # x25 = m = 1 (integer variable m)

    # Load base addresses of all vectors
    la x12, v1              # x12 = base address of v1
    la x13, v2              # x13 = base address of v2
    la x14, v3              # x14 = base address of v3
    la x15, v4              # x15 = base address of v4
    la x16, v5              # x16 = base address of v5
    la x17, v6              # x17 = base address of v6

loop:
    blt x10, x0, End        # if i < 0, exit loop

    # Calculate offset: offset = i * 4 (each float is 4 bytes)
    slli x18, x10, 2        # x18 = i * 4 (shift left by 2 = multiply by 4)

    # Calculate addresses for current iteration
    add x19, x12, x18       # x19 = address of v1[i]
    add x20, x13, x18       # x20 = address of v2[i]
    add x21, x14, x18       # x21 = address of v3[i]
    add x22, x15, x18       # x22 = address of v4[i]
    add x23, x16, x18       # x23 = address of v5[i]
    add x24, x17, x18       # x24 = address of v6[i]

    # Load values from memory
    flw fs1, 0(x19)         # fs1 = v1[i]
    flw fs2, 0(x20)         # fs2 = v2[i]
    flw fs3, 0(x21)         # fs3 = v3[i]

    # Check if i is a multiple of 3
    # Using: i % 3 == 0 can be checked by dividing and comparing
    li x26, 3               # x26 = 3 (divisor)
    rem x27, x10, x26       # x27 = i % 3 (remainder)

    bnez x27, else_branch   # if i % 3 != 0, go to else_branch

    # if branch: i is a multiple of 3
    # a = v1[i] / ((float) m << 1)
    slli x28, x25, 1        # x28 = m << 1 (logical shift left)
    fcvt.s.w fs7, x28       # fs7 = (float) (m << 1)
    fdiv.s fs8, fs1, fs7    # fs8 = a = v1[i] / ((float) m << 1) [LATENCY: 12 cycles]

    # Pipeline optimization: start loading next iteration data during division
    addi x29, x10, -1       # x29 = i - 1 (next iteration index)
    blt x29, x0, skip_prefetch1 # if next i < 0, skip prefetch
    slli x30, x29, 2        # x30 = (i - 1) * 4
    add x31, x12, x30       # x31 = address of v1[i - 1]
    flw fs0, 0(x31)         # Prefetch v1[i - 1] into cache
skip_prefetch1:

    fcvt.w.s x25, fs8, rtz  # m = (int) a (round toward zero)
    j after_if

else_branch:
    # else branch: i is not a multiple of 3
    # a = v1[i] * ((float) m * i)
    fcvt.s.w fs7, x25       # fs7 = (float) m
    fcvt.s.w fs9, x10       # fs9 = (float) i
    fmul.s fs10, fs7, fs9   # fs10 = (float) m * i [LATENCY: 6 cycles]
    fmul.s fs8, fs1, fs10   # fs8 = a = v1[i] * ((float) m * i) [LATENCY: 6 cycles]

    # Pipeline optimization: perform integer operations during multiplication
    addi x29, x10, -1       # x29 = i - 1 (prepare next iteration)

    fcvt.w.s x25, fs8, rtz  # m = (int) a (round toward zero)

after_if:                   # Jump to common code
    # Common calculations for both branches
    # v4[i] = a * v1[i] - v2[i]
    fmul.s fs4, fs8, fs1    # fs4 = a * v1[i] [LATENCY: 6 cycles]

    # Pipeline optimization: prepare addresses while waiting for multiplication
    slli x18, x10, 2        # Recalculate offset (may have been modified)

    fsub.s fs4, fs4, fs2    # fs4 = a * v1[i] - v2[i] [LATENCY: 4 cycles]
    fsw fs4, 0(x22)         # Store result in v4[i]

    # v5[i] = v4[i]/v3[i] - b
    # Note: b is not initialized in the original code, using fs2 (v2[i]) as b
    fdiv.s fs5, fs4, fs3    # fs5 = v4[i]/v3[i] [LATENCY: 12 cycles]

    # Pipeline optimization: start next calculation during division
    fsub.s fs11, fs4, fs1   # fs11 = v4[i] - v1[i] (prepare for v6 calculation) [LATENCY: 4 cycles]

    fsub.s fs5, fs5, fs2    # fs5 = v4[i]/v3[i] - b [LATENCY: 4 cycles]
    fsw fs5, 0(x23)         # Store result in v5[i]

    # v6[i] = (v4[i] - v1[i]) * v5[i]
    # fs11 already contains (v4[i] - v1[i])
    fmul.s fs6, fs11, fs5   # fs6 = (v4[i] - v1[i]) * v5[i] [LATENCY: 6 cycles]
    fsw fs6, 0(x24)         # Store result in v6[i]

    # Decrement counter and continue loop
    addi x10, x10, -1       # i--
    j loop                  # Jump back to loop start

End:
    # exit() syscall. This is needed to end the simulation
    # gracefully
    li a0, 0
    li a7, 93
    ecall