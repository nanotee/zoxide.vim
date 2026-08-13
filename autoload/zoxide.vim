function! s:build_cmd(cmd, query) abort
    return ([g:->get('zoxide_executable', 'zoxide')] + (a:cmd + a:query)->mapnew('shellescape(v:val)'))->join(' ')
endfunction

function! zoxide#exec(cmd, query) abort
    let result = systemlist(s:build_cmd(a:cmd, a:query))
    if v:shell_error
        echohl ErrorMsg | echo result->join("\n") | echohl None
    endif
    return result
endfunction

function! s:chdir_legacy(cd_command, directory) abort
    try
        exe a:cd_command a:directory->fnamemodify(':p')->fnameescape()
    catch
        echohl ErrorMsg | echomsg v:exception | echohl None
        return
    endtry
endfunction

function! s:chdir_new(cd_command, directory) abort
    let scope = a:cd_command is# 'tcd' ? 'tabpage' : a:cd_command is# 'lcd' ? 'window' : a:cd_command is# 'bcd' ? 'buffer' : 'global'
    call chdir(a:directory, scope)
endfunction

" Replace with raw chdir call eventually
let s:chdir = funcref(has('patch-9.1.1605') ? 's:chdir_new' : 's:chdir_legacy')

function! s:change_directory(cd_command, directory) abort
    if empty(a:directory)
        return
    endif

    call s:chdir(a:cd_command, a:directory)

    if exists('#User#ZoxideDirChanged')
        doautocmd User ZoxideDirChanged
    endif

    pwd

    if g:->get('zoxide_update_score', 1) && g:->get('zoxide_hook', 'none') !=# 'pwd'
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
    let directory = a:result->substitute('^\s*[0-9.]*\s*', '', '')
    call s:change_directory(a:cd_command, directory)
endfunction

let s:default_fzf_options = [
            \ '--prompt=Zoxide> ',
            \ '--exact',
            \ '--no-sort',
            \ '--bind=btab:up,tab:down',
            \ '--cycle',
            \ '--keep-right',
            \ '--info=inline',
            \ '--layout=reverse',
            \ '--tabstop=1',
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

function! s:zoxide_zi_fzf(cd_command, bang, query) abort
    call fzf#run(fzf#wrap('zoxide', {
                \ 'source': s:build_cmd(['query', '--list', '--score'], a:query),
                \ 'sink': funcref('zoxide#handle_select_result', [a:cd_command]),
                \ 'options': g:->get('zoxide_fzf_options', s:default_fzf_options),
                \ }, a:bang))
endfunction

function! s:zoxide_zi_nvim_ui_select(cd_command, bang, query) abort
    call luaeval('require("zoxide-vim").select(_A[1], _A[2])', [
                \ zoxide#exec(['query', '--list', '--score'], a:query),
                \ a:cd_command,
                \ ])
endfunction

function! s:zoxide_zi_inputlist(cd_command, bang, query) abort
    let items = zoxide#exec(
                \ ['query', '--list', '--score'],
                \ a:query
                \ )
    let numbered_items = items->mapnew({key, val -> key + 1 .. '. ' .. val})
    let choice_index = inputlist(['Zoxide> '] + numbered_items)

    if !empty(choice_index)
        call zoxide#handle_select_result(a:cd_command, items[choice_index - 1])
    endif
endfunction

if g:->get('zoxide_use_select', 0) || !g:->get('loaded_fzf', 0)
    let s:zoxide_zi = funcref(has('nvim') ? 's:zoxide_zi_nvim_ui_select' : 's:zoxide_zi_inputlist')
else
    let s:zoxide_zi = funcref('s:zoxide_zi_fzf')
endif

function! zoxide#zi(cd_command, bang, ...) abort
    call s:zoxide_zi(a:cd_command, a:bang, a:000)
endfunction
