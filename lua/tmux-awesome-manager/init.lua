local M = {}

local per_project = require('tmux-awesome-manager.src.per-project')
local term = require('tmux-awesome-manager.src.term')
local nav = require("tmux-awesome-manager.src.nav")

local function quit_neovim()
  term.refresh_really_opens()

  local keyset = {}
  local n = 0

  for k, v in pairs(vim.g.tmux_open_terms) do
    n = n + 1
    keyset[n] = k
  end

  if n > 0 then
    local response = vim.fn.input("There is some terminals open.  Close then before exit? y/n  ")

    if response == 'y' or response == 's' or response == 'Y' then
      M.kill_all_terms()
    end
  end
end

function M.setup(opts)
  local opts = opts or {}

  if opts.use_cwd == false then
    vim.g.tmux_use_cwd = false
  else
    vim.g.tmux_use_cwd = true
  end

  if opts.read_after_cmd == false or opts.read_after_cmd == nil then
    vim.g.tmux_read_after_cmd = false
  else
    vim.g.tmux_read_after_cmd = true
  end

  vim.g.tmux_close_on_timer = opts.close_on_timer or 0
  vim.g.tmux_per_project_commands = opts.per_project_commands or {}
  vim.g.tmux_default_orientation = opts.default_orientation or 'vertical'
  vim.g.tmux_open_new_as = opts.open_new_as or 'window'
  vim.g.tmux_open_terms = {}
  vim.g.tmux_project_open_as = opts.project_open_as
  vim.g.tmux_default_size = opts.default_size or '50%'
  vim.g.tmux_session_name = opts.session_name
  
  -- Set the picker preference (telescope or fzf-lua)
  vim.g.tmux_picker = opts.picker or 'telescope'

  vim.g.tmux_use_icon = opts.use_icon or false
  vim.g.tmux_icon = opts.icon or ' '

  local refresh = require('tmux-awesome-manager.src.term').refresh_really_opens

  local autocommands = { { {"VimLeavePre"}, {"*"}, quit_neovim },
                         { {"FocusGained"}, {"*"}, refresh } }

  local cmd = vim.api.nvim_create_autocmd

  for i = 1, #autocommands, 1 do
    cmd(autocommands[i][1], { pattern = autocommands[i][2], callback = autocommands[i][3] })
  end
end

M.run_project_terms = per_project.run_project_terms
M.run = term.run
M.run_wk = term.run_wk
M.visit_last = nav.visit_last
M.switch_open_as = term.switch_open_as
M.switch_orientation = term.switch_orientation
M.kill_all_terms = term.kill_all_terms
M.refresh_really_opens = term.refresh_really_opens
M.execute_command = term.execute_command
M.send_text_to = term.send_text_to

-- Direct picker functions (works with both telescope and fzf-lua)
M.list_terms = function(opts)
  local term = require('tmux-awesome-manager.src.term')
  local picker = require('tmux-awesome-manager.src.picker')
  
  term.refresh_really_opens()

  local opts = opts or {}

  picker.pick({
    prompt_title = 'Select a command to run on tmux:',
    results = vim.g.tmux_saved_commands,
    entry_maker = function(cmd)
      local prefix = ''
      
      -- Check if key exists in open terms
      local include = false
      for key, value in pairs(vim.g.tmux_open_terms) do
        if key == cmd.name then
          include = true
          break
        end
      end

      if include then
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

M.list_open_terms = function(opts)
  local term = require('tmux-awesome-manager.src.term')
  local picker = require('tmux-awesome-manager.src.picker')
  
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

return M

