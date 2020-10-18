function! zoxide#exec(cmd) abort
    let full_cmd = extend([get(g:, 'zoxide_executable', 'zoxide')], a:cmd)
    let result = systemlist(join(full_cmd))
    if v:shell_error
        echohl ErrorMsg | echo join(result, "\n") | echohl None
    endif
    return result
endfunction

function! s:change_directory(cd_command, directory) abort
    if !isdirectory(a:directory) | echoerr 'Not a directory' | return | endif

    exe a:cd_command a:directory
    pwd
    if get(g:, 'zoxide_update_score', 1)
        call zoxide#exec(['add'])
    endif
endfunction

function! zoxide#z(cd_command, query) abort
    let directory = a:query ==# '' ? $HOME : a:query

    if isdirectory(directory)
        call s:change_directory(a:cd_command, directory)
        return
    endif
    let result = zoxide#exec(['query', directory])[0]
    if !v:shell_error | call s:change_directory(a:cd_command, result) | endif
endfunction

function! s:handle_fzf_result(cd_command, result) abort
    let directory = substitute(a:result, '^\s*\d*\s*', '', '')
    call s:change_directory(a:cd_command, directory)
endfunction

function! zoxide#zi(cd_command, query, bang) abort
    if !exists('g:loaded_fzf') | echoerr 'The fzf.vim plugin must be installed' | return | endif

    call fzf#run(fzf#wrap('zoxide', {
                \ 'source': zoxide#exec(['query', '--list', '--score', a:query]),
                \ 'sink': funcref('s:handle_fzf_result', [a:cd_command]),
                \ 'options': '--prompt="Zoxide> "',
                \ }, a:bang))
endfunction
