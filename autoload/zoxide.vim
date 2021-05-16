if has('nvim')
    function! zoxide#exec(cmd, callback = v:null) abort
        let full_cmd = [get(g:, 'zoxide_executable', 'zoxide')] + a:cmd
        let stdout = []
        let stderr = []
        call jobstart(full_cmd, {
                    \ 'on_stdout': {_, data -> extend(stdout, data)},
                    \ 'on_stderr': {_, data -> extend(stderr, data)},
                    \ 'on_exit': {_ -> s:handle_job_result(stdout, stderr, a:callback)},
                    \ })
    endfunction
else
    function! zoxide#exec(cmd, callback = v:null) abort
        let full_cmd = [get(g:, 'zoxide_executable', 'zoxide')] + a:cmd
        let stdout = []
        let stderr = []
        call job_start(full_cmd, {
                    \ 'out_cb': {_, msg -> extend(stdout, [msg])},
                    \ 'err_cb': {_, msg -> extend(stderr, [msg])},
                    \ 'exit_cb': {_ -> s:handle_job_result(stdout, stderr, a:callback)},
                    \ })
    endfunction
endif

function! s:handle_job_result(stdout, stderr, callback) abort
    let stdout = filter(a:stdout, '!empty(v:val)')
    let stderr = filter(a:stderr, '!empty(v:val)')
    if !empty(stderr)
        echohl ErrorMsg | echo join(stderr, "\n") | echohl None
        return
    endif
    if !empty(a:callback)
        call call(a:callback, [stdout])
    endif
endfunction

function! s:change_directory(cd_command, directory) abort
    let directory = type(a:directory) == v:t_list ? a:directory[0] : a:directory

    exe a:cd_command directory
    pwd
    if get(g:, 'zoxide_update_score', 1) && get(g:, 'zoxide_hook', 'none') !=# 'pwd'
        call zoxide#exec(['add', getcwd()])
    endif
endfunction

function! zoxide#z(cd_command, ...) abort
    let query = empty(a:000) ? [$HOME] : a:000

    if len(query) == 1 && isdirectory(query[0])
        call s:change_directory(a:cd_command, query[0])
        return
    endif
    call zoxide#exec(['query', '--exclude', getcwd()] + query, funcref('s:change_directory', [a:cd_command]))
endfunction

function! zoxide#zi(cd_command, bang, ...) abort
    if !exists('g:loaded_fzf') | echoerr 'The fzf.vim plugin must be installed' | return | endif

    call zoxide#exec(['query', '--list', '--score'] + a:000,
                \ {exec_results -> fzf#run(fzf#wrap('zoxide', {
                    \ 'source': exec_results,
                    \ 'sink': {result -> s:change_directory(a:cd_command, substitute(result, '^\s*\d*\s*', '', ''))},
                    \ 'options': '--prompt="Zoxide> "',
                    \ }, a:bang))})
endfunction
