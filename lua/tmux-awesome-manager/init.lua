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
  vim.g.tmux_saved_commands = {}
  vim.g.tmux_default_orientation = opts.default_orientation or 'vertical'
  vim.g.tmux_open_new_as = opts.open_new_as or 'window'
  vim.g.tmux_open_terms = {}
  vim.g.tmux_project_open_as = opts.project_open_as
  vim.g.tmux_default_size = opts.default_size or '50%'
  vim.g.tmux_session_name = opts.session_name

  local autocommands = { { {"VimLeavePre"}, {"*"}, quit_neovim } }
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

return M

