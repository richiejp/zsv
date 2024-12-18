#!/bin/sh -eu

script_dir=$(dirname "$0")

export TARGET="$1"
if [ -z "${2:-}" ]; then
  export STAGE=""
else
  export STAGE=-"$2"
fi
export CAPTURE="${TMP_DIR}/$TARGET$STAGE".out
EXPECTED="$EXPECTED_PATH/$TARGET$STAGE".out
export EXPECTED
matched=false

EXPECT_TIMEOUT=${EXPECT_TIMEOUT:-5}

cleanup() {
  if $matched; then
    if [ -z "$STAGE" ]; then
      tmux send-keys -t "$TARGET" "q"
    fi
    exit 0
  fi

  tmux send-keys -t "$TARGET" "q"
  echo 'Incorrect output:'
  cat "$CAPTURE"
  ${CMP} -s "$CAPTURE" "$EXPECTED"
  exit 1
}

trap cleanup INT TERM QUIT

printf "\n%s, %s" "$TARGET" "${2:-}" >> "${TIMINGS_CSV}"

now_seconds() {
  date +%s
}

start_time=$(now_seconds)

while true; do
  tmux capture-pane -t "$TARGET" -p > "$CAPTURE"
  t=$(now_seconds)

  if ${CMP} -s "$CAPTURE" "$EXPECTED"; then
    matched=true
    break
  fi

  if [ $(( t - start_time )) -gt "$EXPECT_TIMEOUT" ]; then
    break
  fi

  sleep 0.025
done

elapsed=$(( t - start_time ))

if [ "$matched" = "true" ]; then
  echo "$TARGET$STAGE took ${elapsed}s"
  printf ", %s" "$elapsed" >> "${TIMINGS_CSV}"
fi

cleanup
