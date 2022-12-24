#!/bin/bash

# macros {{{
true <<'_END'
m4_divert(-1)

m4_changequote(`#{',`#}')
m4_changecom(/*,*/)

m4_define(_FORI, #{
for $1 in "${!$2[@]}"; do
  set -- ${$2[$1]}
#})
m4_define(_ENDFORI, #{
done
#})

/*m4_define(_WIDTH, 6)
m4_define(_HEIGHT, 5)
m4_define(_INIT_X, 0)
m4_define(_INIT_Y, 4) */

m4_define(_WIDTH, 281)
m4_define(_HEIGHT, 229)
m4_define(_INIT_X, 209)
m4_define(_INIT_Y, 15)

m4_define(_V, _v[_WIDTH*($2)+($1)])
m4_define(_FORV, #{
for y in {0..m4_eval(_HEIGHT-1)}; do
for x in {0..m4_eval(_WIDTH-1)}; do
#})
m4_define(_ENDFORV, #{
done
done
#})

m4_define(_V_SEEN, 1)
m4_define(_V_HEAD, 2)
m4_define(_V_TAIL, 4)
m4_define(_V_HEAD_VISITED, 8)
m4_define(_V_TAIL_VISITED, 16)

m4_define(_ABS, (($1)*(1-2*(($1)<0))))

m4_define(_STEP_HEAD, #{
      while ((head$1 != $1#{0#} $2 step)); do
        : $(( _V(headx,heady) &= ~_V_HEAD ))
        : $(( head$1$2$2 ))
        : $(( _V(headx,heady) |= _V_HEAD | _V_HEAD_VISITED ))
        movetail
      done
#})

m4_divert(0)
_END
# }}}

show() {
  typeset -i y x
  typeset -a s

  return 0
  echo $'\e['m4_eval(_HEIGHT+2)'A'
  for y in {0..m4_eval(_HEIGHT-1)}; do
    echo "$y  ${_v[@]:y*m4_eval(_WIDTH):_WIDTH}"
  done
}

movetail() {
  ((headx == tailx && heady == taily)) && return 0

  local -i dx=headx-tailx dy=heady-taily

  (( _ABS(dx) > 1 || _ABS(dy) > 1 )) || return 0

  : $(( _V(tailx, taily) &= ~_V_TAIL ))
  : $(( tailx += (1 - 2 * (dx < 0)) * (dx != 0) ))
  : $(( taily += (1 - 2 * (dy < 0)) * (dy != 0) ))
  : $(( _V(tailx, taily) |=  _V_TAIL | _V_TAIL_VISITED ))
}

declare -a v
## _FORV()
_V(x,y)=0
## _ENDFORV()

declare -i headx=_INIT_X heady=_INIT_Y
declare -i tailx=_INIT_X taily=_INIT_Y
: $((
_V(headx, heady) |= _V_HEAD | _V_HEAD_VISITED,
_V(tailx, taily) |= _V_TAIL | _V_TAIL_VISITED
))

set -eu
mapfile -t orders
## _FORI(lineno, orders)
{
  let '_V(headx, heady) |= _V_HEAD | _V_HEAD_VISITED'
  # NB. coercing non-int positional arguments into int will result in a lookup
  # e.g., R=111; $2=R; typeset -i foo=$2
  # foo is now 111 (via R)
  typeset -i x0=headx y0=heady step=$2
  typeset direction=$1

  #show
  case $direction in
    D)
      ## _STEP_HEAD(y, +)
      ;;
    U)
      ## _STEP_HEAD(y, -)
      ;;
    R)
      ## _STEP_HEAD(x, +)
      ;;
    L)
      ## _STEP_HEAD(x, -)
      ;;
    *)
      exit 1
      ;;
  esac

  let '_V(headx, heady) |= _V_HEAD'
  movetail
}
## _ENDFORI()

typeset -i total=0
## _FORV()
(( _V(x,y) & _V_TAIL_VISITED )) && total+=1
## _ENDFORV()
echo $total

# vim:set ft=sh:
