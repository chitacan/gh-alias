#!/bin/sh

# query current repos pull-requests
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

# query my starred repos
gh alias set --shell stars \
    'gh api graphql \
        --cache 5m \
        -f query="query {
          viewer {
            starredRepositories(after: \"$1\", orderBy: {field: STARRED_AT, direction: DESC}) {
              totalCount
              pageInfo {
                endCursor
              }
              nodes {
                nameWithOwner
                stargazerCount
                description
              }
            }
          }
        }" \
        --jq ".data.viewer.starredRepositories | .pageInfo.endCursor as \$cursor | (\"total: \" + (.totalCount | tostring)), (.nodes | .[] | [.nameWithOwner, .stargazerCount, \$cursor, .description] | @tsv)" \
    | column -t -s "$(printf "\t")" \
    | fzf --header "C-v: toggle preview, C-o: open vscode, C-y: copy endCursor to clipboard" \
        --bind "ctrl-v:toggle-preview" \
        --bind "ctrl-o:execute(open vscode://github.remotehub/open\?url=https://github.com/{1})" \
        --bind "ctrl-y:execute(echo {3} | pbcopy)+abort" \
        --preview "CLICOLOR_FORCE=1 gh repo view {1}" \
        --preview-window hidden \
        --header-lines=1 \
        --with-nth 1,2,4.. \
        --border none'

# query corp-momenti's members
gh alias set mem 'api orgs/corp-momenti/members --jq ".[].login"'
