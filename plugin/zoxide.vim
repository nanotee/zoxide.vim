if exists('g:loaded_zoxide')
    finish
endif
let g:loaded_zoxide = 1

let s:save_cpo = &cpo
set cpo&vim

let s:z_cmd = substitute(get(g:, 'zoxide_prefix', 'z'), '\A', '', 'g')
let s:z_cmd_cap = toupper(s:z_cmd[0])..strcharpart(s:z_cmd, 1)

" Z
" Lz
execute 'command! -nargs=? -complete=dir '..s:z_cmd_cap..' call zoxide#z(<q-args>, v:false)'
execute 'command! -nargs=? -complete=dir L'..s:z_cmd..' call zoxide#z(<q-args>, v:true)'

" Zi
" Lzi
execute 'command! -nargs=? -bang '..s:z_cmd_cap..'i call zoxide#zi(<q-args>, v:false, <bang>0)'
execute 'command! -nargs=? -bang L'..s:z_cmd..'i call zoxide#zi(<q-args>, v:true, <bang>0)'

" Za
" Zr
execute 'command! -nargs=? -complete=dir '..s:z_cmd_cap..'a call zoxide#exec(["add", <q-args>])'
execute 'command! -nargs=? -complete=dir '..s:z_cmd_cap..'r call zoxide#exec(["remove", <q-args>])'

let &cpo = s:save_cpo
unlet s:save_cpo
