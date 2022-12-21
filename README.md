# Tmux Awesome Manager

This plugin provides a pack of functionalities to work with TMUX on Neovim. Manage your commands and run inside neovim!  This plugin is perfect
for common commands of your workflow like yarn install, rails console, yarn add, bundle install, etc.

# Features:

- Bind commands to shortcuts with a lot of options (open as tab / window, orientation, name, pass user input, etc).
- Search for the commands that you binded with Telescope.
- Verify open terminals and visit then.
- Send text to the tmux panes / windows managed by Tmux Awesome Manager.
- Create startup commands per project.

# Demonstration

![demo](https://i.imgur.com/WnIEglJ.gif)

# Requirements:

- Tmux >= 3.3 (Ubuntu 22.04 has an older version, install for another font)
- Telescope (Optional)
- Which-key (Optional)

# Setup

```lua
require('tmux-awesome-manager').setup({
  per_project_commands = { -- Configure your per project servers with
  -- project name = { { cmd, name } }
    api = { { cmd = 'rails server', name = 'Rails Server' } },
    front = { { cmd = 'yarn dev', name = 'react server' } },
  },
  session_name = 'Neovim Terminals',
  -- default_size = '30%', -- on panes, the default size
  -- open_new_as = 'window' -- open new command as.  options: pane, window.
})
```

# Keybindings

## Global Keybindings

Example mappings

```lua
local tmux = require("tmux-awesome-manager")

vim.keymap.set('v', 'l', tmux.send_text_to, {}) -- Send text to a open terminal?
vim.keymap.set('n', 'lo', tmux.switch_orientation, {}) -- Open new panes as vertical / horizontal?
vim.keymap.set('n', 'lp', tmux.switch_open_as, {}) -- Open new terminals as panes or windows?
vim.keymap.set('n', 'lk', tmux.kill_all_terms, {}) -- Kill all open terms.
vim.keymap.set('n', 'l!', tmux.run_project_terms, {}) -- Run the per project commands
vim.keymap.set('n', 'lf', function() vim.cmd(":Telescope tmux-awesome-manager list_terms") end, {}) -- List all terminals
vim.keymap.set('n', 'll', function() vim.cmd(":Telescope tmux-awesome-manager list_open_terms") end, {}) -- List open terminals
```

## Commands Mappings

I recommend the which-key, but is possible to map with vim.keymap too

tmux_term.run() and tmux_term.run_wk() parameters:

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
| project_open_as  | Open as for project commands                                                                                                  |

Example of question mapping:

```lua
tmux.run_wk({ cmd = 'yarn add %1', name = 'Yarn Add', questions = { { question = 'package name: ', required = true } } })
```

### vim.keymap

```lua
local tmux_term = require('tmux-awesome-manager.src.term')

vim.keymap.set('n', 'rr', tmux_term.run({ name = 'Rails Console', name = 'console', open_as = 'pane' }), {}) -- Send text to a open terminal?
```

### Which-key
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

# Statusline

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

# Tmux Pro tips to improve this plugin workflow

- Create a shortcut for break pane / join pane:

```tmux
bind-key m choose-tree -Zw "join-pane -t '%%'"
bind-key b break-pane
```

- Create a shortcut to switch between two windows (last window and current):
```tmux
bind-key = last-window
```

- Use alacritty terminal to bypass tmux prefix.

In my case, my prefix is C-x:

```
set-option -g prefix C-x
unbind-key C-x
bind-key C-x send-prefix
```

So, in alacritty config, when i need to call something, i just put \x18 + the code of the key i want.  Example:

```yaml
# This will call C-x j using Alt + j
- { key: J, mods: Alt, chars: "\x18\x6d" }
```

To see what is the code of a key, just run:
`xxd -psd`.

To copy my tmux and alacritty config, visit my config at:

- https://github.com/otavioschwanck/mood-nvim (config)
- https://github.com/otavioschwanck/mood-nvim/blob/main/extra/.tmux.conf (tmux)
- https://github.com/otavioschwanck/mood-nvim/blob/main/extra/alacritty.yml (alacritty)

# Changelog

1.2 - Text for statusline
1.1 - Open terms in another session
1.0 - Release
