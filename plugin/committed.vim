" committed.vim - Remember to commit
" Author:       Chris Penner
" Version:      0.1
" License:      MIT

" Bail if we don't have git.
if !executable("git") || !executable("date")
    finish
endif

let s:has_reattach = executable("reattach-to-user-namespace")

" Set up defaults
if !exists("g:committed_min_time_threshold")
  let g:committed_min_time_threshold = 5
endif

if !exists("g:current_time_threshold")
    let g:current_time_threshold = g:committed_min_time_threshold
endif

" Send notification via applescript
function! s:Notify(message)
    " Fix for display notifications not working in tmux
    if s:has_reattach
        let command='! reattach-to-user-namespace osascript -e ''display notification "' . a:message . '" with title "Commit\!"'''
    else
        let command='! osascript -e ''display notification "' . a:message . '" with title "Commit\!"'''
    endif
    exe command
endfunction

" Determine whether to send a notification for the current repo
function! s:CheckIfNotify()
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

    " echom "thresh: " . g:current_time_threshold
    " echom "minutes since: " . minutes_since_last_commit

    " If this matches, there must be a new commit.
    if minutes_since_last_commit < (g:current_time_threshold / 2)
        let g:current_time_threshold = g:committed_min_time_threshold
        if minutes_since_last_commit < g:current_time_threshold
            return
        else
            while minutes_since_last_commit > g:current_time_threshold
                let g:current_time_threshold = 2 * g:current_time_threshold
            endwhile
        endif
    " If we're still within the threshold don't send another notification
    elseif minutes_since_last_commit < g:current_time_threshold
        return
    else
        " If we reach here, we're past the threshold, bump it up
        while minutes_since_last_commit > g:current_time_threshold
            let g:current_time_threshold = 2 * g:current_time_threshold
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
  autocmd BufWritePost * call s:CheckIfNotify()
augroup END

call s:CheckIfNotify()
