#!/bin/bash

parallel -j $(nproc) sh -c 'cat input | ./q2 $0' -- $(
  mapfile -t input <input
  for y in "${!input[@]}"; do
    for x in $(seq 0 $((${#input[y]} - 1))); do
      [[ "${input[y]:x:1}" == "a" || "${input[y]:x:1}" == "S" ]] && echo $((y * ${#input[y]} + x))
    done
  done
)
