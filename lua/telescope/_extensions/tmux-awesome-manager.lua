local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local M = {}

local term = require('tmux-awesome-manager.src.term')

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

  opts.prompt_title = 'Select a command to run on tmux:'

  opts = require("telescope.themes").get_dropdown(opts)

  pickers.new(opts, {
    finder = finders.new_table {
      results = vim.g.tmux_saved_commands,
      entry_maker = function(cmd)
        local prefix = ''

        if M.include_key(cmd.name) then
          prefix = '[open] '
        end

        return { value = cmd.name, display = prefix .. cmd.name, ordinal = cmd.name, cmd = cmd }
      end
    },
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry().cmd

        term.execute_command(selection)
      end)
      return true
    end,
  }):find()
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

  opts.prompt_title = 'Select a tmux window to go:'

  opts = require("telescope.themes").get_dropdown(opts)

  pickers.new(opts, {
    finder = finders.new_table {
      results = keyset
    },
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()

        term.focus(vim.g.tmux_open_terms[selection[1]])
      end)
      return true
    end,
  }):find()
end

return require("telescope").register_extension {
  exports = {
    list_terms = M.list_terms,
    list_open_terms = M.list_open_terms
  }
}
