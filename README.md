# Vim CloseBuffer

## Overview

Have you ever been frustrated by Vim's behavior when closing buffers, where your carefully arranged split window layout gets ruined? You’re not alone. **Vim CloseBuffer** is a plugin designed to help you close buffers without disrupting your window layout, making your Vim experience smoother and more efficient.

## Why Use Vim CloseBuffer?

When you close a buffer in Vim using the default commands, Vim can sometimes close the window as well, collapsing your split layout and leaving you with a disorganized workspace. This plugin prevents that by allowing you to close buffers without affecting the current window arrangement.

## Installation

To install the Vim CloseBuffer plugin, you can use any popular Vim plugin manager. For instance, if you're using [vim-plug](https://github.com/junegunn/vim-plug), add the following line to your .vimrc:

```vim
Plug 'caesar003/vim-closebuffer'
```

Then, install the plugin by running:

```vim
:PlugInstall
```

Alternatively, if you’re using a different plugin manager like [lazy.nvim](https://github.com/folke/lazy.nvim), [Vundle](https://github.com/wbthomason/packer.nvim), or [packer.nvim](https://github.com/VundleVim/Vundle.vim), refer to its specific documentation to install the plugin.

Here’s how you might add it with lazy.nvim:

```lua
 {
  -- other plugins
  { 'caesar003/vim-closebuffer' },
}
```

## Usage

After installing the plugin, you can use the following command to safely close your buffers:

```vim
:HandleCloseBuffer
```

This command provides an interactive prompt if there are unsaved changes, allowing you to save, discard, or cancel the close operation. It ensures that your split layout remains intact, no matter how you choose to handle the buffer.

## Custom Mappings

You are free to define convenient mappings to make using the plugin even easier. For example:

```vim
nnoremap <leader>c :HandleCloseBuffer<cr>
```

Feel free to customize the mapping to fit your preferred keybindings.

## Contributing

If you find any issues or have suggestions for improvements, feel free to open an issue or submit a pull request on GitHub. Contributions are always welcome!

## License

This plugin is open-source and licensed under the [MIT License](LICENSE).
