function! s:build_cmd(cmd, query) abort
    return join([get(g:, 'zoxide_executable', 'zoxide')] + map(a:cmd + a:query, 'shellescape(v:val)'), ' ')
endfunction

function! zoxide#exec(cmd, query) abort
    let result = systemlist(s:build_cmd(a:cmd, a:query))
    if v:shell_error
        echohl ErrorMsg | echo join(result, "\n") | echohl None
    endif
    return result
endfunction

function! s:change_directory(cd_command, directory) abort
    try
        exe a:cd_command fnameescape(fnamemodify(a:directory, ':p'))
    catch
        echohl ErrorMsg | echomsg v:exception | echohl None
        return
    endtry

    if exists('#User#ZoxideDirChanged')
        doautocmd User ZoxideDirChanged
    endif

    pwd

    if get(g:, 'zoxide_update_score', 1) && get(g:, 'zoxide_hook', 'none') !=# 'pwd'
        call zoxide#exec(['add'], [getcwd()])
    endif
endfunction

function! zoxide#z(cd_command, ...) abort
    let query = empty(a:000) ? [$HOME] : a:000

    if len(query) == 1 && (query[0] ==# '-' || isdirectory(query[0]))
        call s:change_directory(a:cd_command, query[0])
        return
    endif
    let result = zoxide#exec(['query', '--exclude', getcwd()], query)[0]
    if !v:shell_error | call s:change_directory(a:cd_command, result) | endif
endfunction

function! zoxide#handle_select_result(cd_command, result) abort
    if empty(a:result) | return | endif
    let directory = substitute(a:result, '^\s*[0-9.]*\s*', '', '')
    call s:change_directory(a:cd_command, directory)
endfunction

if has('nvim') && get(g:, 'zoxide_use_select', 0)
    function! zoxide#zi(cd_command, bang, ...) abort
        call luaeval('require("zoxide-vim").select(_A[1], _A[2])', [
                    \ zoxide#exec(['query', '--list', '--score'], a:000),
                    \ a:cd_command,
                    \ ])
    endfunction
else
    let s:default_fzf_options = [
                \ '--prompt=Zoxide> ',
                \ '--no-sort',
                \ '--keep-right',
                \ '--info=inline',
                \ '--layout=reverse',
                \ '--select-1',
                \ ]
    " Previews are only supported on UNIX.
    if has('unix')
        " Non-POSIX args are only available on certain operating systems.
        let s:default_fzf_options += [
                    \ has('linux') ?
                    \ '--preview=\command -p ls -Cp --color=always --group-directories-first {2..}' :
                    \ '--preview=\command -p ls -Cp {2..}',
                    \ ]

        " Rounded edges don't display correctly on some terminals.
        let s:default_fzf_options += ['--preview-window=down,30%,sharp']
        " `CLICOLOR=1` Enables colorized `ls` output on macOS / FreeBSD.
        " `FORCE_CLICOLOR=1` Forces colorized `ls` output when the output is
        " not a TTY (like in fzf's preview window) on macOS / FreeBSD.
        " `sh -c` Ensures that the preview command is run in a POSIX-compliant
        " shell, regardless of what shell the user has selected.
        let s:default_fzf_options += ['--with-shell=env CLICOLOR=1 CLICOLOR_FORCE=1 sh -c']
    endif

    function! zoxide#zi(cd_command, bang, ...) abort
        if !exists('g:loaded_fzf') | echoerr 'The fzf.vim plugin must be installed' | return | endif

        call fzf#run(fzf#wrap('zoxide', {
                    \ 'source': s:build_cmd(['query', '--list', '--score'], a:000),
                    \ 'sink': funcref('zoxide#handle_select_result', [a:cd_command]),
                    \ 'options': get(g:, 'zoxide_fzf_options', s:default_fzf_options),
                    \ }, a:bang))
    endfunction
endif
