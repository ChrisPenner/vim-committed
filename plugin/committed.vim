" committed.vim - Remember to commit
" Author:       Chris Penner
" Version:      0.1
" License:      MIT

if exists("g:loaded_committed") || v:version < 700
  finish
endif
let g:loaded_committed = 1

" Bail if we don't have the required executables
if !executable("git") || !executable("date") || !executable("head") || !executable("tr") || !executable("cut")
    finish
endif

let s:has_reattach = executable("reattach-to-user-namespace")

" Set up defaults
if !exists("g:committed_time_threshold")
  let g:committed_time_threshold = 5
endif

if !exists("g:committed_lines_threshold")
  let g:committed_lines_threshold = 15
endif

if !exists("g:committed_enable_at_startup")
  let g:committed_enable_at_startup = 1
endif

let s:enabled = g:committed_enable_at_startup
let s:thresholds = {}

" Send notification via applescript
function! s:Notify(message)
    " Fix for display notifications not working in tmux
    if s:has_reattach
        let command='! reattach-to-user-namespace osascript -e ''display notification "' . a:message . '" with title "Commit\!"'''
    else
        let command='! osascript -e ''display notification "' . a:message . '" with title "Commit\!"'''
    endif
    silent execute command
endfunction

function! s:GetLinesChanged()
    return system("git diff --stat | tail -n1 | cut -f2 -d, | tr -dC '[:digit:]'")
endfunction

" Determine whether to send a notification for the current repo
function! s:CheckIfNotify()
    if !s:enabled
        return
    endif

    " Bail if not enough lines have been changed
    let lines_changed = s:GetLinesChanged()
    if lines_changed < g:committed_lines_threshold
        return
    endif

    " Use a different threshold for each repo
    let repo_path = system("git rev-parse --show-toplevel")
    if !has_key(s:thresholds, repo_path)
        let s:thresholds[repo_path] = g:committed_time_threshold
    endif

    " Collect info about the current repo
    let now = system("date +%s")
    let last_commit = system("git log --pretty=format:%at -1 2> /dev/null")
    " Bail if not a git repo
    if empty(last_commit)
        return
    endif
    let seconds_since_last_commit = now - last_commit
    let minutes_since_last_commit = seconds_since_last_commit / 60
    let hours_since_last_commit = minutes_since_last_commit / 60

    echom "thresh: " . s:thresholds[repo_path]
    echom "minutes since: " . minutes_since_last_commit

    " If this matches, there must be a new commit.
    if minutes_since_last_commit < (s:thresholds[repo_path] / 2)
        let s:thresholds[repo_path] = g:committed_time_threshold
        if minutes_since_last_commit < threshold
            return
        else
            while minutes_since_last_commit >= s:thresholds[repo_path]
                let  s:thresholds[repo_path] = 2 * s:thresholds[repo_path]
            endwhile
        endif
    " If we're still within the threshold don't send another notification
    elseif minutes_since_last_commit < s:thresholds[repo_path]
        return
    else
        " If we reach here, we're past the threshold, bump it up
        while minutes_since_last_commit >= s:thresholds[repo_path]
            let s:thresholds[repo_path] = 2 * s:thresholds[repo_path]
        endwhile
    endif

    if hours_since_last_commit > 0
        let message = "Its been over " . hours_since_last_commit . " hour(s) since your last commit."
    else
        let message = "Its been " . minutes_since_last_commit . " minutes since your last commit."
    endif
    call s:Notify(message)
endfunction

augroup CommittedCheck
  autocmd!
  autocmd BufWritePost * silent call s:CheckIfNotify()
augroup END

function! s:SetCommitted(value)
    let s:enabled = a:value
endfunction

function! s:ToggleCommitted()
    let s:enabled = !s:enabled
endfunction

command CommittedDisable call <SID>SetCommitted(0)
command CommittedEnable call <SID>SetCommitted(1)
command CommittedToggle call <SID>ToggleCommitted()
