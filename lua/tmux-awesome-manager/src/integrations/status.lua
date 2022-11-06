local M = {}

function M.status_with_icons()
  if vim.g.tmux_open_new_as then
    return " TMUX: Window"
  elseif vim.g.tmux_default_orientation == 'horizontal' then
    return "ײַ TMUX: Horizontal"
  else
    return "ﬠ TMUX: Vertical"
  end
end

function M.status_no_icons()
  if vim.g.tmux_open_new_as then
    return "TMUX: Window"
  elseif vim.g.tmux_default_orientation == 'horizontal' then
    return "TMUX: Horizontal"
  else
    return "TMUX: Vertical"
  end
end

return M
