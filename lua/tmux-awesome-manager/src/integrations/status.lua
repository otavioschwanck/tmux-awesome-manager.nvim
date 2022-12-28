local M = {}

local term = require('tmux-awesome-manager.src.term')

function M.status_with_icons()
  if vim.g.tmux_open_new_as == 'window' then
    return " TMUX: Window"
  elseif vim.g.tmux_default_orientation == 'horizontal' then
    return "ײַ TMUX: Horizontal"
  else
    return "ﬠ TMUX: Vertical"
  end
end

function M.open_terms()
  local s = "["
  local qtd = 0
  local keyset={}

  for k, v in pairs(vim.g.tmux_open_terms) do
    qtd = qtd + 1
    keyset[qtd] = k
  end

  if qtd == 0 then
    return ""
  end

  for i = 1, #keyset, 1 do
    s = s .. keyset[i]

    if not(#keyset == i) then
      s = s .. ", "
    end
  end

  s = s .. "]"

  return s
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
