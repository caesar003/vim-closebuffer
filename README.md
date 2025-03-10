# Vim CloseBuffer

```
 _    ___                 ________                ____        ________
| |  / (_)___ ___        / ____/ /___  ________  / __ )__  __/ __/ __/__  _____
| | / / / __ `__ \______/ /   / / __ \/ ___/ _ \/ __  / / / / /_/ /_/ _ \/ ___/
| |/ / / / / / / /_____/ /___/ / /_/ (__  )  __/ /_/ / /_/ / __/ __/  __/ /
|___/_/_/ /_/ /_/      \____/_/\____/____/\___/_____/\__,_/_/ /_/  \___/_/
```

## Overview

Have you ever been frustrated by Vim's behavior when closing buffers, where your carefully arranged split window layout gets ruined? You're not alone. **Vim CloseBuffer** is a plugin designed to help you close buffers without disrupting your window layout, making your Vim experience smoother and more efficient.

## Why Use Vim CloseBuffer?

When you close a buffer in Vim using the default commands, Vim can sometimes close the window as well, collapsing your split layout and leaving you with a disorganized workspace. This plugin prevents that by allowing you to close buffers without affecting the current window arrangement.

## Features

-   **Preserve Split Windows** - Close buffers without disrupting your window layout
-   **Handle Unsaved Changes** - Interactive prompts to save, discard, or cancel
-   **Multiple Buffer Operations** - Close specific buffers by number or close all except current
-   **Configurable Behavior** - Customize messages and confirmation behavior
-   **Comprehensive Documentation** - Full help system with `:help closeBuffer`

## Installation

To install the Vim CloseBuffer plugin, you can use any popular Vim plugin manager. For instance, if you're using [vim-plug](https://github.com/junegunn/vim-plug), add the following line to your .vimrc:

```vim
Plug 'caesar003/vim-closebuffer'
```

Then, install the plugin by running:

```vim
:PlugInstall
```

Alternatively, if you're using a different plugin manager like [lazy.nvim](https://github.com/folke/lazy.nvim), [Vundle](https://github.com/VundleVim/Vundle.vim), or [Packer](https://github.com/wbthomason/packer.nvim), refer to its specific documentation to install the plugin.

Here's how you might add it with lazy.nvim:

```lua
return {
  -- other plugins
  { 'caesar003/vim-closebuffer' },
}
```

## Usage

After installing the plugin, you can use the following commands:

```vim
" Close the current buffer
:CloseBuffer

" Close specific buffers by number
:CloseBuffer 3 5 7

" Close all buffers except the current one
:CloseBufferExceptCurrent
```

These commands provide interactive prompts if there are unsaved changes, allowing you to save, discard, or cancel the close operation. They ensure that your split layout remains intact, no matter how you choose to handle the buffer.

## Custom Mappings

You are free to define convenient mappings to make using the plugin even easier. For example:

```vim
" Close current buffer
nnoremap <leader>x :CloseBuffer<cr>

" Close all buffers except current
nnoremap <leader>X :CloseBufferExceptCurrent<cr>
```

Or with lazy.nvim

```lua
return {
  -- other plugins
  {
    "caesar003/vim-closebuffer",
    config = function()
      vim.api.nvim_set_keymap("n", "<leader>x", ":CloseBuffer<CR>", { noremap = true, silent = true, desc = "Delete Buffer" })
      vim.api.nvim_set_keymap("n", "<leader>X", ":CloseBufferExceptCurrent<CR>", { noremap = true, silent = true, desc = "Delete Other Buffers" })
    end,
  },
}
```

Feel free to customize the mappings to fit your preferred keybindings.

## Configuration

You can customize the plugin's behavior with these global variables:

```vim
" Disable status messages
let g:close_buffer_quiet = 1

" Disable confirmation for unmodified buffers
let g:close_buffer_no_confirm = 1
```

## Documentation

After installation, you can access the full documentation with:

```vim
:help closeBuffer
```

Make sure to run `:helptags ALL` or `:helptags ~/.vim/doc/` after installation to generate the help tags.

## Breaking Changes in v2.0

Version 2.0 includes the following breaking changes from v1.x:

-   Command syntax has changed to support multiple buffer operations
-   New configuration variables have been introduced
-   Internal function signatures have been modified
-   Buffer switching logic has been significantly improved

Please update any custom scripts that may interact with this plugin accordingly.

## Contributing

If you find any issues or have suggestions for improvements, feel free to open an issue or submit a pull request on GitHub. Contributions are always welcome!

## License

This plugin is open-source and licensed under the [MIT License](LICENSE).
