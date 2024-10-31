# Simple Dynamic Memory Allocator in C and Assembly

This project implements a simple dynamic memory allocator in C and Assembly. The allocator provides core functions for dynamic memory allocation, designed to manage memory within a fixed-size buffer and allocate additional memory as needed. When required, it reserves 4096-byte blocks, and otherwise uses a Best Fit policy to find and reuse already allocated but freed blocks, reducing memory fragmentation and optimizing reuse.

## Features
- Dynamic memory allocation and deallocation with a Best Fit strategy.
- Automatic 4096-byte block reservation when necessary.
- Core allocator routines in Assembly for performance and low-level control.
- Easy-to-use C interface for integration with C-based applications.

## Use Cases
- Educational tool for learning memory management and allocation strategies.
- Systems needing efficient, custom memory management without external dependencies.

## Build Instructions
Compile the project with `make` to build the allocator and link necessary dependencies.
