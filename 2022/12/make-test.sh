#!/bin/bash

mapfile -t l <test.out
typeset -i pos=0
while true; do
  echo $pos
  case ${l[pos / 8]:pos%8:1} in
  .)
    echo barf
    exit 1
    ;;
  v) let pos+=8 ;;
  ^) let pos-=8 ;;
  \>) let pos+=1 ;;
  \<) let pos-=1 ;;
  E) exit 0 ;;
  *)
    echo unk
    exit 1
    ;;
  esac
done
echo $pos
