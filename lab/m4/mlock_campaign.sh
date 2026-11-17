#!/bin/bash
# mlock 대조군(이슈 #6)의 실제 종료 실험: runaway_growth, 데몬 켜짐(kill)에서 mlock=yes와 no를 번갈아 N쌍 실행한다.
# 계획은 docs/validation/mlock-control.md. 한 번에 VM 하나만 쓴다(포트 2222, 4444, 9999).
#
# 사용법: lab/m4/mlock_campaign.sh <쌍 수> <결과 디렉터리> [시작 번호]
#   예) lab/m4/mlock_campaign.sh 3 results/m4/mlock-20261117        (1~3번)
#       lab/m4/mlock_campaign.sh 5 results/m4/mlock-20261117 4      (4~8번을 이어서)
set -u
N="${1:?쌍 수}"
OUT="${2:?결과 디렉터리}"
START="${3:-1}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$OUT"
for n in $(seq "$START" $((START + N - 1))); do
    for arm in yes no; do
        id="mlock${arm}-$n"
        "$HERE/run.sh" --load runaway_growth --daemon kill --mlock "$arm" --id "$id" --out "$OUT/$id" \
            > "$OUT/$id.out" 2>&1 || echo "$id 실패(rc=$?)" | tee -a "$OUT/failures.txt"
    done
done
