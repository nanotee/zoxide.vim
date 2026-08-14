if exists('g:loaded_zoxide')
    finish
endif
let g:loaded_zoxide = 1

let s:save_cpo = &cpo
set cpo&vim

let s:z_cmd = g:->get('zoxide_prefix', 'z')->substitute('\A', '', 'g')
let s:z_cmd_upper = s:z_cmd[0]->toupper() .. s:z_cmd->strcharpart(1)

" Z
" Lz
" Tz
" Bz
execute 'command! -nargs=* -complete=dir ' .. s:z_cmd_upper .. ' call zoxide#z("cd", <f-args>)'
execute 'command! -nargs=* -complete=dir L' .. s:z_cmd .. ' call zoxide#z("lcd", <f-args>)'
execute 'command! -nargs=* -complete=dir T' .. s:z_cmd .. ' call zoxide#z("tcd", <f-args>)'
if exists(':bcd')
    execute 'command! -nargs=* -complete=dir B' .. s:z_cmd .. ' call zoxide#z("bcd", <f-args>)'
endif

" Zi
" Lzi
" Tzi
" Bzi
execute 'command! -nargs=* -bang ' .. s:z_cmd_upper .. 'i call zoxide#zi("cd", <bang>0, <f-args>)'
execute 'command! -nargs=* -bang L' .. s:z_cmd .. 'i call zoxide#zi("lcd", <bang>0, <f-args>)'
execute 'command! -nargs=* -bang T' .. s:z_cmd .. 'i call zoxide#zi("tcd", <bang>0, <f-args>)'
if exists(':bcd')
    execute 'command! -nargs=* -bang B' .. s:z_cmd .. 'i call zoxide#zi("bcd", <bang>0, <f-args>)'
endif

if g:->get('zoxide_hook', 'none') ==# 'pwd'
    if has('nvim')
        augroup zoxide_cd
            autocmd!
            autocmd DirChanged buffer,window,tabpage,global if !v:event['changed_window'] | call zoxide#exec(['add'], [v:event['cwd']]) | endif
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
