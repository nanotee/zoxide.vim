if exists('g:loaded_zoxide')
    finish
endif
let g:loaded_zoxide = 1

let s:save_cpo = &cpo
set cpo&vim

command! -nargs=? -complete=file Z call zoxide#z(<q-args>, v:false)
command! -nargs=? -complete=file Lz call zoxide#z(<q-args>, v:true)

command! -nargs=? -bang Zi call zoxide#zi(<q-args>, v:false, <bang>0)
command! -nargs=? -bang Lzi call zoxide#zi(<q-args>, v:true, <bang>0)

command! -nargs=? -complete=file Za call zoxide#exec(['zoxide', 'add', <q-args>])
command! -nargs=? -complete=file Zr call zoxide#exec(['zoxide', 'remove', <q-args>])

let &cpo = s:save_cpo
unlet s:save_cpo
