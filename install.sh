#!/bin/sh
gh alias set --shell prs \
    'gh pr list \
        --json title,state,headRefName,number,author,mergeCommit \
        --jq ".[] |= . + { state: .state[0:1], author: .author.login, ref: . | (if .mergeCommit == null then (\"origin/\" + .headRefName) else .mergeCommit.oid[0:6] end) } | .[] | [.number,.state,.headRefName,.ref,.author,.title] | @tsv" \
        --search="$1" \
        2>/dev/null \
    | column -t -s "$(printf "\t")" \
    | fzf --header "C-v: preview, C-t: tig, C-w: wttw, C-e: approve" \
        --bind "ctrl-t:execute(tig {4})" \
        --bind "ctrl-w:execute(wttw n {3} --base-ref {4})" \
        --bind "ctrl-e:execute-silent(gh pr review {1} --approve)" \
        --bind "ctrl-v:toggle-preview" \
        --bind "enter:execute(gh pr view -c {1})+abort" \
        --preview "CLICOLOR_FORCE=1 gh pr view {1}" \
        --preview-window hidden \
        --border none \
        --with-nth 1..3,5,6..'
