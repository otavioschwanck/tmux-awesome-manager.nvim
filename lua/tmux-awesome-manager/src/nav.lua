local M = {}

local term = require('tmux-awesome-manager.src.term')

function M.get_entry_from_end(table, entry)
  local count = (table and #table or false)
  if (count) then
    return table[count - entry];
  end

  return false;
end

function M.visit_last()
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

  local id = vim.g.tmux_open_terms[keyset[#keyset]]

  vim.fn.system("tmux select-window -t \"" .. id .. "\"")
  vim.fn.system("tmux select-pane -t \"" .. id .. "\"")
end

return M
