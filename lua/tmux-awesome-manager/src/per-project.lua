local M = {}

local term = require('tmux-awesome-manager.src.term')

function M.run_project_terms()
  local commands = vim.g.tmux_per_project_commands
  local p_name = M.project_name()

  if vim.fn.len(p_name) > 0 then
    p_name = p_name[vim.fn.len(p_name)]
  end

  local commands_for_project = commands[p_name]

  if not commands_for_project then
    vim.notify("this project doesn't have any commands configured.")

    return
  end

  for __, value in ipairs(commands_for_project) do
    value.focus_when_call = false
    value.visit_first_call = false

    term.execute_command(value)
  end
end

function M.project_name()
  return vim.fn.split(vim.fn.getcwd(), "/")
end

return M
