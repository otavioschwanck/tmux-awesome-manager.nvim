# 🚀 Tmux Awesome Manager

This plugin provides a pack of functionalities to work with TMUX on Neovim. Manage your commands and run inside neovim! 🎯 This plugin is perfect for common commands of your workflow like yarn install, rails console, yarn add, bundle install, etc.

## ✨ Features:

- 🔗 Bind commands to shortcuts with a lot of options (open as tab / window, orientation, name, pass user input, etc).
- 🔍 Search for the commands that you binded with **Telescope** or **fzf-lua**.
- 👀 Verify open terminals and visit them.
- 📤 Send text to the tmux panes / windows managed by Tmux Awesome Manager.
- 🏗️ Create startup commands per project.

## 🎬 Demonstration

![demo](https://i.imgur.com/WnIEglJ.gif)

## 📋 Requirements:

- 🖥️ Tmux >= 3.3 (Ubuntu 22.04 has an older version, install from another source)
- 🔭 Telescope (Optional)
- 🔍 fzf-lua (Optional)
- 🗝️ Which-key (Optional)

## ⚙️ Setup

### 📦 Installation

#### 🌙 Lazy.nvim

```lua
{
  "otavioschwanck/tmux-awesome-manager.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim", -- Optional: for telescope picker
    -- OR
    -- "ibhagwan/fzf-lua", -- Optional: for fzf-lua picker
  },
  config = function()
    require('tmux-awesome-manager').setup({
      per_project_commands = { -- Configure your per project servers with
      -- project name = { { cmd, name } }
        api = { { cmd = 'rails server', name = 'Rails Server' } },
        front = { { cmd = 'yarn dev', name = 'react server' } },
      },
      session_name = 'Neovim Terminals',
      use_icon = false, -- use prefix icon
      picker = 'telescope', -- 🔍 Choose picker: 'telescope' or 'fzf-lua' (default: 'telescope')
      icon = ' ', -- Prefix icon to use
      -- project_open_as = 'window', -- Open per_project_commands as.  Default: separated_session
      -- default_size = '30%', -- on panes, the default size
      -- open_new_as = 'window', -- open new command as.  options: pane, window, separated_session.
      -- default_orientation = 'vertical' -- Can also be horizontal
    })
  end
}
```

#### 📦 Packer.nvim

```lua
use {
  'otavioschwanck/tmux-awesome-manager.nvim',
  requires = {
    'nvim-telescope/telescope.nvim', -- Optional: for telescope picker
    -- OR
    -- 'ibhagwan/fzf-lua', -- Optional: for fzf-lua picker
  },
  config = function()
    require('tmux-awesome-manager').setup({
      per_project_commands = { -- Configure your per project servers with
      -- project name = { { cmd, name } }
        api = { { cmd = 'rails server', name = 'Rails Server' } },
        front = { { cmd = 'yarn dev', name = 'react server' } },
      },
      session_name = 'Neovim Terminals',
      use_icon = false, -- use prefix icon
      picker = 'telescope', -- 🔍 Choose picker: 'telescope' or 'fzf-lua' (default: 'telescope')
      icon = ' ', -- Prefix icon to use
      -- project_open_as = 'window', -- Open per_project_commands as.  Default: separated_session
      -- default_size = '30%', -- on panes, the default size
      -- open_new_as = 'window', -- open new command as.  options: pane, window, separated_session.
      -- default_orientation = 'vertical' -- Can also be horizontal
    })
  end
}
```

#### 🔌 vim-plug

```lua
Plug 'otavioschwanck/tmux-awesome-manager.nvim'
Plug 'nvim-telescope/telescope.nvim' " Optional: for telescope picker
" OR
" Plug 'ibhagwan/fzf-lua' " Optional: for fzf-lua picker

" Add to your init.lua or in a lua heredoc:
lua << EOF
require('tmux-awesome-manager').setup({
  picker = 'telescope', -- or 'fzf-lua'
  -- ... other options
})
EOF
```

#### 💎 rocks.nvim

```lua
:Rocks install tmux-awesome-manager.nvim
```

Then add to your configuration:

```lua
require('tmux-awesome-manager').setup({
  picker = 'telescope', -- or 'fzf-lua'
  -- ... other options
})
```

### ⚡ Quick Start (Minimal Setup)

For a quick start with default settings:

```lua
-- Lazy.nvim
{
  "otavioschwanck/tmux-awesome-manager.nvim",
  config = true -- Uses default configuration
}

-- Or manual setup with defaults
require('tmux-awesome-manager').setup({})
```

### 🔧 Manual Setup

If you prefer to call setup manually:

## ⚙️ Full Configuration Example

```lua
require('tmux-awesome-manager').setup({
  per_project_commands = { -- Configure your per project servers with
  -- project name = { { cmd, name } }
    api = { { cmd = 'rails server', name = 'Rails Server' } },
    front = { { cmd = 'yarn dev', name = 'react server' } },
  },
  session_name = 'Neovim Terminals',
  use_icon = false, -- use prefix icon
  picker = 'telescope', -- 🔍 Choose picker: 'telescope' or 'fzf-lua' (default: 'telescope')
  icon = ' ', -- Prefix icon to use
  -- project_open_as = 'window', -- Open per_project_commands as.  Default: separated_session
  -- default_size = '30%', -- on panes, the default size
  -- open_new_as = 'window', -- open new command as.  options: pane, window, separated_session.
  -- default_orientation = 'vertical' -- Can also be horizontal
})
```

### 🎯 Picker Options

The plugin supports two picker backends for selecting terminals and commands:

- **🔭 Telescope** (default): Uses telescope.nvim for fuzzy finding
- **🔍 fzf-lua**: Uses fzf-lua for lightning-fast fuzzy finding

Simply set the `picker` option in your setup to choose your preferred picker:

```lua
-- Use telescope (default)
require('tmux-awesome-manager').setup({
  picker = 'telescope'
})

-- Use fzf-lua for faster performance
require('tmux-awesome-manager').setup({
  picker = 'fzf-lua'
})
```

The plugin automatically detects which picker is available and falls back gracefully if your preferred picker isn't installed.

### 🔧 Different Ways to Call Picker Functions

The plugin provides multiple ways to call the picker functions:

#### 🎯 Direct Function Calls (Recommended)
Works with both telescope and fzf-lua automatically:

```lua
local tmux = require("tmux-awesome-manager")

-- List all saved commands
tmux.list_terms()

-- List currently open terminals
tmux.list_open_terms()
```

#### 🔭 Telescope Extension (Traditional)
If you prefer using telescope commands directly:

```lua
-- List all saved commands
vim.cmd(":Telescope tmux-awesome-manager list_terms")

-- List currently open terminals
vim.cmd(":Telescope tmux-awesome-manager list_open_terms")
```

#### 🚀 Lua Function Calls
For more control or custom mappings:

```lua
-- With options
require("tmux-awesome-manager").list_terms({ layout_config = { width = 0.9 } })

-- Simple call
require("tmux-awesome-manager").list_open_terms()
```

## 🗝️ Keybindings

### 🌍 Global Keybindings

Example mappings:

```lua
local tmux = require("tmux-awesome-manager")

vim.keymap.set('v', 'l', tmux.send_text_to, {}) -- Send text to a open terminal?
vim.keymap.set('n', 'lo', tmux.switch_orientation, {}) -- Open new panes as vertical / horizontal?
vim.keymap.set('n', 'lp', tmux.switch_open_as, {}) -- Open new terminals as panes or windows?
vim.keymap.set('n', 'lk', tmux.kill_all_terms, {}) -- Kill all open terms.
vim.keymap.set('n', 'l!', tmux.run_project_terms, {}) -- Run the per project commands

-- 🔍 List terminals - works with both telescope and fzf-lua
vim.keymap.set('n', 'lf', tmux.list_terms, {}) -- List all terminals
vim.keymap.set('n', 'll', tmux.list_open_terms, {}) -- List open terminals
```

### 🔧 Commands Mappings

I recommend using **which-key**, but it's also possible to map with `vim.keymap`. 

#### 📋 Parameters for `tmux_term.run()` and `tmux_term.run_wk()`:

| param            | description                                                                                                                   |
|------------------|-------------------------------------------------------------------------------------------------------------------------------|
| cmd              | Command to be runned on terminal                                                                                              |
| name             | Humanized name of command (to search and window name)                                                                         |
| focus_when_call  | Focus terminal instead opening a enw one - default = true                                                                     |
| visit_first_call | Focus the new opened window / pane. default = true                                                                            |
| size             | If open_as = pane, split with this size. default = 50%                                                                        |
| open_as          | Open as window, pane or separated_session? Default: what is setted on setup (window)                                          |
| session_name     | When open_as is separated_session, the session name to open.  Set this if you want to all neovim instances have same session. |
| use_cwd          | Use current cwd on new window / pane? Default: what is setted on setup (true)                                                 |
| close_on_timer   | When the command completed, sleep for some seconds - default = what is setted on setup: 0                                     |
| read_after_cmd   | When the command completed, wait for enter to close the window. default = true                                                |
| questions        | Array of user inputs to be asked for the command.  On `cmd`, the result of inputs will be added on %1 %2.                     |
| open_id          | You can use various commands using same pane / window.  Just set same id for all and add focus_when_call = false and do the magic |

#### 💡 Example of question mapping:

```lua
tmux.run_wk({ cmd = 'yarn add %1', name = 'Yarn Add', questions = { { question = 'package name: ', required = true } } })
```

### 📝 vim.keymap

```lua
local tmux_term = require('tmux-awesome-manager.src.term')

vim.keymap.set('n', 'rr', tmux_term.run({ name = 'Rails Console', name = 'console', open_as = 'pane' }), {}) -- Send text to a open terminal?
```

### 🗝️ Which-key
```lua
local tmux_term = require('tmux-awesome-manager.src.term')
local wk = require("which-key")

wk.register({
  r = {
    name = "+rails",
    R = tmux_term.run_wk({ cmd = 'rails s', name = 'Rails Server', visit_first_call = false, open_as = 'separated_session', session_name = 'My Terms' }),
    r = tmux_term.run_wk({ cmd = 'rails s', name = 'Rails Console', open_as = 'window' }),
    b = tmux_term.run_wk({ cmd = 'bundle install', name = 'Bundle Install', open_as = 'pane', close_on_timer = 2, visit_first_call = false, focus_when_call = false }),
    g = tmux_term.run_wk({ cmd = 'rails generate %1', name = 'Rails Generate',
      questions = { { question = "Rails generate: ", required = true, open_as = 'pane', close_on_timer = 4,
        visit_first_call = false, focus_when_call = false } } }),
    d = tmux_term.run_wk({ cmd = 'rails destroy %1', name = 'Rails Destroy',
      questions = { { question = "Rails destroy: ", required = true, open_as = 'pane', close_on_timer = 4,
        visit_first_call = false, focus_when_call = false } } }),
  },
}, { prefix = "<leader>", silent = true })
```

## 🚀 Add command without a mapping

Just run without assigning to a key map:

```lua
local tmux_term = require('tmux-awesome-manager.src.term')

tmux_term.run({ cmd = 'yarn add %1', name = 'Yarn Add', questions = { { question = 'package name: ', required = true } } })
```

## 📊 Statusline

```lua
-- Status with icons:
require('tmux-awesome-manager.src.integrations.status').status_with_icons()

-- Status without icons:
require('tmux-awesome-manager.src.integrations.status').status_no_icons()

-- List of open terms
require('tmux-awesome-manager.src.integrations.status').open_terms()

-- Example for lualine:
ins_right {
  function()
    return require('tmux-awesome-manager.src.integrations.status').open_terms()
  end,
  color = { fg = colors.green },
}
```

## 💡 Tmux Pro tips to improve this plugin workflow

- 🔧 Create a shortcut for break pane / join pane:

```tmux
bind-key m choose-tree -Zw "join-pane -t '%%'"
bind-key b break-pane
```

- ⚡ Create a shortcut to switch between two windows (last window and current):
```tmux
bind-key = last-window
```

- 🚀 Use alacritty terminal to bypass tmux prefix.

In my case, my prefix is C-x:

```
set-option -g prefix C-x
unbind-key C-x
bind-key C-x send-prefix
```

So, in alacritty config, when i need to call something, i just put \u0018 + the key i want.  Example:

```yaml
# This will call C-x j using Alt + j
[[keyboard.bindings]]
chars = "\u0018m"
key = "J"
mods = "Alt"
```

📁 To copy my tmux and alacritty config, visit my config at:

- 🔗 https://github.com/otavioschwanck/mood-nvim (config)
- 🔗 https://github.com/otavioschwanck/mood-nvim/blob/main/extra/alacritty.yml (alacritty)
- 🔗 https://github.com/otavioschwanck/mood-nvim/blob/main/extra/.tmux.conf (tmux)

## 📝 Changelog

- **1.3** - 🔍 Added fzf-lua picker support as alternative to telescope
- **1.2** - 📊 Text for statusline
- **1.1** - 🖥️ Open terms in another session
- **1.0** - 🎉 Release
