# zoxide.vim

A small (Neo)Vim wrapper for [zoxide](https://github.com/ajeetdsouza/zoxide)

## Requirements

- A recent version of Vim or Neovim
- The [zoxide](https://github.com/ajeetdsouza/zoxide) utility
- (optional) The [fzf](https://github.com/junegunn/fzf) utility along with the [fzf.vim](https://github.com/junegunn/fzf/blob/master/plugin/fzf.vim) script

## Installation

Install using your favorite plugin manager:

- [Native vim.pack in Neovim](https://neovim.io/doc/user/pack/#vim.pack)
    ```lua
    vim.pack.add({'https://github.com/nanotee/zoxide.vim'})
    ```
- [vim-plug](https://github.com/junegunn/vim-plug)
    ```vim
    Plug 'nanotee/zoxide.vim'
    ```

## Usage

The plugin defines commands that wrap the functionality of zoxide:

- `:Z {query}`: cd to the highest ranked directory matching your query. If `{query}` is omitted, cd to the home directory
- `:Lz {query}`: same as `:Z`, but local to the current window
- `:Tz {query}`: same as `:Z`, but local to the current tab
- `:Bz {query}`: same as `:Z`, but local to the current buffer (Neovim 0.13+ only)
- `:Zi {query}`: cd to one of your highest ranking directories using fzf
- `:Lzi {query}`: same as `:Zi`, but local to the current window
- `:Tzi {query}`: same as `:Zi`, but local to the current tab
- `:Bzi {query}`: same as `:Zi`, but local to the current buffer (Neovim 0.13+ only)

## Configuration

See [zoxide-vim-configuration](doc/zoxide-vim.txt#L35)

## Events

See [zoxide-vim-events](doc/zoxide-vim.txt#L100)
