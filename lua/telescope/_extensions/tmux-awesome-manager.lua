local M = {}

local term = require('tmux-awesome-manager.src.term')
local picker = require('tmux-awesome-manager.src.picker')

function M.include_key(name)
  local include = false

  for key, value in pairs(vim.g.tmux_open_terms) do
    if key == name then
      include = true
    end
  end

  return include
end

function M.list_terms(opts)
  term.refresh_really_opens()

  local opts = opts or {}

  picker.pick({
    prompt_title = 'Select a command to run on tmux:',
    results = vim.g.tmux_saved_commands,
    entry_maker = function(cmd)
      local prefix = ''

      if M.include_key(cmd.name) then
        prefix = '[open] '
      end

      return { value = cmd.name, display = prefix .. cmd.name, ordinal = cmd.name, cmd = cmd }
    end,
    on_select = function(selection)
      term.execute_command(selection.cmd)
    end,
    telescope_opts = opts
  })
end

function M.list_open_terms(opts)
  term.refresh_really_opens()

  local keyset = {}
  local n = 0

  for k, v in pairs(vim.g.tmux_open_terms) do
    n = n + 1
    keyset[n] = k
  end

  if #keyset == 0 then
    vim.notify("No tmux consoles open.")

    return
  end

  local opts = opts or {}

  picker.pick({
    prompt_title = 'Select a tmux window to go:',
    results = keyset,
    on_select = function(selection)
      term.focus(vim.g.tmux_open_terms[selection.value])
    end,
    telescope_opts = opts
  })
end

return require("telescope").register_extension {
  exports = {
    list_terms = M.list_terms,
    list_open_terms = M.list_open_terms
  }
}
