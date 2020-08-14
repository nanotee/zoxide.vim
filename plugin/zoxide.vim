if exists('g:loaded_zoxide')
    finish
endif
let g:loaded_zoxide = 1

let s:save_cpo = &cpo
set cpo&vim

let s:z_cmd = toupper(get(g:, 'zoxide_prefix', 'z'))

" Z
" LZ
execute 'command! -nargs=? -complete=dir '..s:z_cmd..' call zoxide#z(<q-args>, v:false)'
execute 'command! -nargs=? -complete=dir L'..s:z_cmd..' call zoxide#z(<q-args>, v:true)'

" Zi
" LZi
execute 'command! -nargs=? -bang '..s:z_cmd..'i call zoxide#zi(<q-args>, v:false, <bang>0)'
execute 'command! -nargs=? -bang L'..s:z_cmd..'i call zoxide#zi(<q-args>, v:true, <bang>0)'

" Za
" Zr
execute 'command! -nargs=? -complete=dir '..s:z_cmd..'a call zoxide#exec(["add", <q-args>])'
execute 'command! -nargs=? -complete=dir '..s:z_cmd..'r call zoxide#exec(["remove", <q-args>])'

let &cpo = s:save_cpo
unlet s:save_cpo
