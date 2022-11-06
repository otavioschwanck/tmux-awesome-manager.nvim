local M = {}

function M.execute_command(opts)
  if not opts.name then
    vim.notify('You need to pass command_name to run the tmux command')

    return
  end

  if not opts.cmd then
    vim.notify('You need to pass command to run the tmux command')

    return
  end

  M.refresh_really_opens()

  opts.focus_when_call = M.ternary(opts.focus_when_call == false, false, true)
  opts.visit_first_call = M.ternary(opts.visit_first_call == false, false, true)

  opts.size = opts.size or vim.g.tmux_default_size
  opts.open_as = opts.open_as or vim.g.tmux_open_new_as

  opts.open_id = M.get_open_id(opts.name)
  opts.use_cwd = M.ternary(opts.tmux_use_cwd == false, false, true)

  if opts.open_id == "" then
    opts.is_open = false
  else
    opts.is_open = true
  end

  if not(opts.is_open) then
    M.open(opts)
  elseif opts.focus_when_call then
    M.focus(opts.open_id)
  else
    M.close_and_open(opts)
  end
end

function M.ternary(cond, T, F)
    if cond then return T else return F end
end

function M.close_and_open(opts)
  vim.fn.system("tmux kill-pane -t " .. opts.open_id)

  M.open(opts)
end

function M.open(opts)
  local base_command

  local extra_args = ''

  if not opts.visit_first_call then
    extra_args = ' -d '
  end

  if opts.use_cwd == true then
    extra_args = extra_args .. ' -c ' .. vim.fn.getcwd() .. ' '
  end

  if opts.open_as == 'window' then
    base_command = "tmux new-window -P "
  else
    base_command = "tmux split-window -P -I -l " .. opts.size .. ' -F "#{pane_id}" '
  end

  base_command = base_command .. " " .. extra_args

  local open_terms = vim.g.tmux_open_terms

  open_terms[opts.name] = M.normalize_return(vim.fn.system(base_command .. ' "' .. opts.cmd .. '"'))

  if opts.open_as == 'window' then
    open_terms[opts.name] = M.normalize_return(vim.fn.system('tmux display -pt "' .. open_terms[opts.name] .. '" "#{pane_id}"'))
  end

  vim.g.tmux_open_terms = open_terms
end

function M.focus(id)
  vim.fn.system("tmux select-window -t \"" .. id .. "\"")
  vim.fn.system("tmux select-pane -t \"" .. id .. "\"")
end

function M.get_open_id(name)
  local id = vim.g.tmux_open_terms[name]

  if id then
    return id
  else
    return ""
  end
end

function M.normalize_return(str)
  local str = string.gsub(str, "\n", "")

  return str
end

function M.pane_exists(id)
  return not(M.normalize_return(vim.fn.system("tmux display-message -t " .. id .. " -p '#{pane_id}'")) == "")
end

function M.refresh_really_opens()
  local new_open = {}

  for k, value in pairs(vim.g.tmux_open_terms) do
    local really_open = M.normalize_return(vim.fn.system("tmux has-session -t " .. value .. " 2>/dev/null && echo 123"))

    if M.pane_exists(value) then
      new_open[k] = value
    end
  end

  vim.g.tmux_open_terms = new_open
end

function M.run(opts)
  local cur_saves = vim.g.tmux_saved_commands
  table.insert(cur_saves, opts)
  vim.g.tmux_saved_commands = cur_saves

  return function()
    M.execute_command(opts)
  end
end

return M
