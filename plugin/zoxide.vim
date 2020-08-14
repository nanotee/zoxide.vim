if exists('g:loaded_zoxide')
    finish
endif
let g:loaded_zoxide = 1

let s:save_cpo = &cpo
set cpo&vim

command! -nargs=? -complete=dir Z call zoxide#z(<q-args>, v:false)
command! -nargs=? -complete=dir Lz call zoxide#z(<q-args>, v:true)

command! -nargs=? -bang Zi call zoxide#zi(<q-args>, v:false, <bang>0)
command! -nargs=? -bang Lzi call zoxide#zi(<q-args>, v:true, <bang>0)

command! -nargs=? -complete=dir Za call zoxide#exec(['add', <q-args>])
command! -nargs=? -complete=dir Zr call zoxide#exec(['remove', <q-args>])

let &cpo = s:save_cpo
unlet s:save_cpo
