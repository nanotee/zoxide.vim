function! zoxide#exec(cmd) abort
    let full_cmd = map(extend([get(g:, 'zoxide_executable', 'zoxide')], a:cmd), {_, arg -> shellescape(arg)})
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
        call zoxide#exec(['add', '.'])
    endif
endfunction

function! zoxide#z(cd_command, ...) abort
    let query = empty(a:000) ? [$HOME] : a:000

    if len(query) == 1 && isdirectory(query[0])
        call s:change_directory(a:cd_command, query[0])
        return
    endif
    let result = zoxide#exec(['query'] + query)[0]
    if !v:shell_error | call s:change_directory(a:cd_command, result) | endif
endfunction

function! s:handle_fzf_result(cd_command, result) abort
    let directory = substitute(a:result, '^\s*\d*\s*', '', '')
    call s:change_directory(a:cd_command, directory)
endfunction

function! zoxide#zi(cd_command, bang, ...) abort
    if !exists('g:loaded_fzf') | echoerr 'The fzf.vim plugin must be installed' | return | endif

    call fzf#run(fzf#wrap('zoxide', {
                \ 'source': zoxide#exec(['query', '--list', '--score'] + a:000),
                \ 'sink': funcref('s:handle_fzf_result', [a:cd_command]),
                \ 'options': '--prompt="Zoxide> "',
                \ }, a:bang))
endfunction
