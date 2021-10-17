if exists('g:loaded_zoxide')
    finish
endif
let g:loaded_zoxide = 1

let s:save_cpo = &cpo
set cpo&vim

let s:z_cmd = substitute(get(g:, 'zoxide_prefix', 'z'), '\A', '', 'g')
let s:z_cmd_cap = toupper(s:z_cmd[0]) .. strcharpart(s:z_cmd, 1)

" Z
" Lz
" Tz
execute 'command! -nargs=* -complete=dir ' .. s:z_cmd_cap .. ' call zoxide#z("cd", <f-args>)'
execute 'command! -nargs=* -complete=dir L' .. s:z_cmd .. ' call zoxide#z("lcd", <f-args>)'
execute 'command! -nargs=* -complete=dir T' .. s:z_cmd .. ' call zoxide#z("tcd", <f-args>)'

" Zi
" Lzi
" Tzi
execute 'command! -nargs=* -bang ' .. s:z_cmd_cap .. 'i call zoxide#zi("cd", <bang>0, <f-args>)'
execute 'command! -nargs=* -bang L' .. s:z_cmd .. 'i call zoxide#zi("lcd", <bang>0, <f-args>)'
execute 'command! -nargs=* -bang T' .. s:z_cmd .. 'i call zoxide#zi("tcd", <bang>0, <f-args>)'

if get(g:, 'zoxide_legacy_aliases', 0)
    " Za
    " Zr
    execute 'command! -nargs=? -complete=dir ' .. s:z_cmd_cap .. 'a call zoxide#exec(["add"], [<q-args>])'
    execute 'command! -nargs=? -complete=dir ' .. s:z_cmd_cap .. 'r call zoxide#exec(["remove"], [<q-args>])'
endif

if get(g:, 'zoxide_hook', 'none') ==# 'pwd'
    if has('nvim')
        augroup zoxide_cd
            autocmd!
            autocmd DirChanged window,tabpage,global if !v:event['changed_window'] | call zoxide#exec(['add'], [v:event['cwd']]) | endif
        augroup END
    else
        augroup zoxide_cd
            autocmd!
            autocmd DirChanged window,tabpage,global call zoxide#exec(['add'], [expand('<afile>')])
        augroup END
    endif
endif

let &cpo = s:save_cpo
unlet s:save_cpo
