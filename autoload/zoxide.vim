function! zoxide#exec(cmd) abort
    let full_cmd = extend([get(g:, 'zoxide_executable', 'zoxide')], a:cmd)
    let result = systemlist(join(full_cmd))
    if v:shell_error
        echohl ErrorMsg | echo join(result, "\n") | echohl None
    endif
    return result
endfunction

function! s:change_directory(directory, cmd) abort
    if !isdirectory(a:directory) | echoerr 'Not a directory' | return | endif

    exe a:cmd a:directory
    pwd
    if get(g:, 'zoxide_update_score', 1)
        call zoxide#exec(['add'])
    endif
endfunction

function! zoxide#z(query, local) abort
    let directory = a:query ==# '' ? $HOME : a:query
    let cmd = a:local ? 'lcd' : 'cd'

    if isdirectory(directory)
        call s:change_directory(directory, cmd)
        return
    endif
    let result = zoxide#exec(['query', directory])[0]
    if !v:shell_error | call s:change_directory(result, cmd) | endif
endfunction

function! s:handle_fzf_result(local, result) abort
    let cmd = a:local ? 'lcd' : 'cd'
    let directory = substitute(a:result, '^\s*\d*\s*', '', '')
    call s:change_directory(directory, cmd)
endfunction

function! zoxide#zi(query, local, bang) abort
    if !exists('g:loaded_fzf') | echoerr 'The fzf.vim plugin must be installed' | return | endif

    call fzf#run(fzf#wrap('zoxide', {
                \ 'source': zoxide#exec(['query', '--list', '--score', a:query]),
                \ 'sink': funcref('s:handle_fzf_result', [a:local]),
                \ 'options': '--prompt="Zoxide> "',
                \ }, a:bang))
endfunction
