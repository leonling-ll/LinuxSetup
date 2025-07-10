# NeoVim config

This config is a folk of [leslie255/nvim-config](https://github.com/leslie255/nvim-config) with some customized configuration.

## Setup
0. Use the latest version of NVIM(0.10.0+)
Since ubuntu package management tool does not install the lastet neovim, we should download it from [github nvim v0.10.4 release](https://github.com/neovim/neovim/releases/tag/v0.10.4).
```shell
wget https://github.com/neovim/neovim/releases/download/v0.10.4/nvim-linux-x86_64.tar.gz
tar xzvf nvim-linux-x86_64.tar.gz
./nvim-linux64/bin/nvim
```

1. Clone or link this folder to `~/.config/nvim`:
```shell
$ ln -s /path/to/LinuxSetup/nvim ~/.config/nvim
```

2. When you first enter `nvim`, you will see a bunch of mess because the plugins aren't installed yet, so run `:PackerInstall` to install the plugins<br>
> Note that there is a chance that the download would timeout and `packer.nvim` would report install failed, in this case run `:PackerInstall` again

4. This setup uses the modern LSP system for langauge support, things like auto-complete, symbols tree, etc..., **which requires a LSP server outside the editor**. Fortunately [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) manages to configure most of the LSP server options for us, all we need to do is to install the LSP servers themselves:<br>
In `lua/configs/autocomplete.lua`, line `51`, edit the list of LSP servers, a complete list of supported LSP servers is listed [here](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md). After that install the corresponding servers on your OS, auto-complete should pop up for supported languages now :)
  * Install [clangd](https://clangd.llvm.org/installation.html)
    ```shell
    # Try to install a packaged release (12.0):
    sudo apt-get install clangd-12
    # This will install clangd as /usr/bin/clangd-12. Make it the default clangd:
    sudo update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-12 100
    ```
  * Install [py-lsp-server](https://github.com/python-lsp/python-lsp-server)
    ```shell
    pip install python-lsp-server
    pip install autopep8
    ```

4. Final step, smart highlighting using treesitter!<br>
The default vim regex-based highlighting is pretty lame, for NVIM, [treesitter](https://github.com/nvim-treesitter/nvim-treesitter) offered an advanced code highlighting that can make your code much cleaner<br>
You can use the `:TSInstall <lang>` command to install a parser for a language<br>
Alternatively, in `lua/configs/treesitter.lua`, line `6`, you can have a list of parsers that will be updated everytime you use the `:TSUpdate` or `:TSUpdateSync` command (the latter is for synchronized updating), or you can just install all maintained parsers by uncommenting line `5` and commenting line `6`

6. To make `Telescope` can be fully worked.
`conda install -c conda-forge ripgrep` to install `ripgrep` and which `live_grep` depends on.

## Plugins

There are a bunch of plugins included in `nvim/lua/core/plugins.lua` and their usage can be refered in `nvim/lua/core/keymaps.lua`. 
Exclusions are listed here.

* [nvim-tree](https://github.com/kyazdani42/nvim-tree.lua) 
  * `shift + i`: toggle show hidden git ignored files
  * `shift + h`: toggle show hidden dot files (ie. .vim)
  * `BackSpace`: fold directory

* [Comment](https://github.com/numToStr/Comment.nvim)

  All you need to remember is 
  * `gcc` for Line style comment 
  * `gbc` for Block style comment if applicable


