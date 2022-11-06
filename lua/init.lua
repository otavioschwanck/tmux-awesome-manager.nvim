local M = {}

function M.setup(opts)
  local opts = opts or {}

  if opts.use_cwd == false then
    vim.g.tmux_use_cwd = false
  else
    vim.g.tmux_use_cwd = true
  end

  vim.g.tmux_per_project_commands = opts.per_project_commands or {}
  vim.g.tmux_saved_commands = {}
  vim.g.tmux_default_orientation = opts.orientation or 'horizontal'
  vim.g.tmux_open_new_as = opts.open_new_as or 'window'
  vim.g.tmux_open_terms = {}
  vim.g.tmux_default_size = opts.default_size or '50%'
end

return M

