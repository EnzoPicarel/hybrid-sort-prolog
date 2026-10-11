# Machine and Benchmark Setup

Information collected on October 11, 2026.

## Machine

- Processor: Intel Core i5-1135G7, 4 cores / 8 threads, 2.40 GHz
- Memory: 7.5 GiB total
- Operating system: Ubuntu 24.04.5 LTS, Linux 7.0.0-38-generic, x86_64
- Prolog system: SWI-Prolog 9.0.4

## Benchmark Parameters

- Hybrid sort threshold: 24 elements
- Timing method: SWI-Prolog CPU time measured with `statistics(cputime, ...)`. Very short runs were repeated, and the average CPU time per sort was recorded.
- Algorithms measured: bubble sort, insertion sort, accumulator-based insertion sort (bonus), merge sort, quick sort, and all four hybrid configurations.
