local M = {}

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

  vim.g.tmux_close_on_timer = opts.close_on_timer or 2
  vim.g.tmux_per_project_commands = opts.per_project_commands or {}
  vim.g.tmux_saved_commands = {}
  vim.g.tmux_default_orientation = opts.orientation or 'horizontal'
  vim.g.tmux_open_new_as = opts.open_new_as or 'window'
  vim.g.tmux_open_terms = {}
  vim.g.tmux_default_size = opts.default_size or '50%'
end

return M

