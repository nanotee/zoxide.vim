# zoxide.vim

A small (Neo)Vim wrapper for [zoxide](https://github.com/ajeetdsouza/zoxide)

## Requirements

- A recent version of Vim or Neovim
- The [zoxide](https://github.com/ajeetdsouza/zoxide) utility
- (optional) The [fzf](https://github.com/junegunn/fzf) utility along with the [fzf.vim](https://github.com/junegunn/fzf/blob/master/plugin/fzf.vim) script

## Installation

Install using your favorite plugin manager:

```vim
" vim-plug
Plug 'nanotee/zoxide.vim'

" dein.vim
call dein#add('nanotee/zoxide.vim')

" vim-packager
call packager#add('nanotee/zoxide.vim')
```

## Usage

The plugin defines several commands that wrap the functionality of zoxide:

- `:Z {query}`: cd to the highest ranked directory matching your query. If `{query}` is omitted, cd to the home directory
- `:Lz {query}`: same as `:Z`, but local to the current window
- `:Tz {query}`: same as `:Z`, but local to the current tab
- `:Zi {query}`: cd to one of your highest ranking directories using fzf
- `:Lzi {query}`: same as `:Zi`, but local to the current window
- `:Tzi {query}`: same as `:Zi`, but local to the current tab

## Configuration

- `g:zoxide_executable` (default value: `'zoxide'`):

    The name or path of the zoxide executable

- `g:zoxide_prefix` (default value: `'z'`)

    The prefix to use for commands. Example:
    ```vim
    let g:zoxide_prefix = 'jump'
    ```

    Generates the following commands:
    ```
    :Jump
    :Ljump
    :Tjump
    :Jumpi
    :Ljumpi
    :Tjumpi
    ```

- `g:zoxide_update_score` (default value: `1`)

    Decides whether the zoxide database should be updated when you execute a :Z-style command

- `g:zoxide_hook` (default value: `'none'`)

    Automatically increment a directory's score on certain events. Available hooks:
    - `'none'`: never automatically add directories to zoxide.
    - `'pwd'`: sets up an autocommand that listens to the `DirChanged` event. **Note**: on Neovim < `0.6.0`, `'autochdir'` can cause the event to be triggered very often.

- `g:zoxide_legacy_aliases` (default value: `0`)

    Defines aliases `:Za` and `:Zr`.
    These were removed from the main zoxide package because they were used too infrequently: [ajeetdsouza/zoxide#158](https://github.com/ajeetdsouza/zoxide/pull/158)
    (They probably don't warrant adding any kind of alias in Vim either because it's really easy to use `:!zoxide add {query}`)

    I'm going to remove them in the future.
