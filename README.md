# zoxide.vim

A small (Neo)Vim wrapper for [zoxide](https://github.com/ajeetdsouza/zoxide)

## Requirements

- A recent version of Vim or Neovim
- The [zoxide](https://github.com/ajeetdsouza/zoxide) utility
- (optional) The [fzf](https://github.com/junegunn/fzf) utility along with the [fzf.vim](https://github.com/junegunn/fzf/blob/master/plugin/fzf.vim) script

## Installation

Install using your favorite plugin manager:

- [vim-plug](https://github.com/junegunn/vim-plug)
    ```vim
    Plug 'nanotee/zoxide.vim'
    ```
- [packer.nvim](https://github.com/wbthomason/packer.nvim)
    ```lua
    use 'nanotee/zoxide.vim'
    ```
- [dein.vim](https://github.com/Shougo/dein.vim)
    ```vim
    call dein#add('nanotee/zoxide.vim')
    ```
- [vim-packager](https://github.com/kristijanhusak/vim-packager)
    ```vim
    call packager#add('nanotee/zoxide.vim')
    ```

## Usage

The plugin defines commands that wrap the functionality of zoxide:

- `:Z {query}`: cd to the highest ranked directory matching your query. If `{query}` is omitted, cd to the home directory
- `:Lz {query}`: same as `:Z`, but local to the current window
- `:Tz {query}`: same as `:Z`, but local to the current tab
- `:Zi {query}`: cd to one of your highest ranking directories using fzf
- `:Lzi {query}`: same as `:Zi`, but local to the current window
- `:Tzi {query}`: same as `:Zi`, but local to the current tab

## Configuration

See [zoxide-vim-configuration](doc/zoxide-vim.txt#L27)

## Events

See [zoxide-vim-events](doc/zoxide-vim.txt#L92)
