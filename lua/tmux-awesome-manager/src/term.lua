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

  opts.close_on_timer = opts.close_on_timer or vim.g.tmux_close_on_timer or 0
  opts.read_after_cmd = M.ternary(opts.read_after_cmd == false, false, true)

  opts.orientation = opts.orientation or vim.g.tmux_default_orientation or 'vertical'

  if opts.open_id == "" then
    opts.is_open = false
  else
    opts.is_open = true
  end

  if not (opts.is_open) then
    opts = M.ask_questions(opts)

    if not(opts == false) then
      M.open(opts)
    end
  elseif opts.focus_when_call then
    M.focus(opts.open_id)
  else
    M.close_and_open(opts)
  end
end

function M.ask_questions(opts)
  if #(opts.questions or {}) > 0 then
    local index = 1

    for __, value in ipairs(opts.questions) do
      local user_input = vim.fn.input(value.question .. ' ')

      if (user_input == "" and not(value.optional)) then
        vim.notify("\nThe input is required.  Canceling terminal command.")

        return false
      end

      opts.cmd = string.gsub(opts.cmd, '%%' .. index, user_input)
    end

    return opts
  else
    return opts
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
    base_command = "tmux new-window -P -n '" .. opts.name .. "'"
  else
    local orientation = ' -v '

    if opts.orientation == 'horizontal' then
      orientation = ' -h '
    end

    base_command = "tmux split-window -P -I -l " .. (opts.size or '50%') .. orientation .. ' -F "#{pane_id}" '
  end

  base_command = base_command .. " " .. extra_args

  if opts.close_on_timer > 0 then
    opts.cmd = opts.cmd .. '; sleep ' .. opts.close_on_timer
  elseif opts.read_after_cmd then
    opts.cmd = opts.cmd .. '; read'
  end

  local open_terms = vim.g.tmux_open_terms

  open_terms[opts.name] = M.normalize_return(vim.fn.system(base_command .. ' "' .. opts.cmd .. '"'))

  if opts.open_as == 'window' then
    open_terms[opts.name] = M.normalize_return(vim.fn.system('tmux display -pt "' ..
      open_terms[opts.name] .. '" "#{pane_id}"'))
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
  return not (M.normalize_return(vim.fn.system("tmux display-message -t " .. id .. " -p '#{pane_id}'")) == "")
end

function M.refresh_really_opens()
  local new_open = {}

  for k, value in pairs(vim.g.tmux_open_terms or {}) do
    local really_open = M.normalize_return(vim.fn.system("tmux has-session -t " .. value .. " 2>/dev/null && echo 123"))

    if M.pane_exists(value) then
      new_open[k] = value
    end
  end

  vim.g.tmux_open_terms = new_open
end

-- Add function to open term to be used on a keybinding.
-- Also adds the command
--
-- Arguments:
--  opts.focus_when_call -- Focus terminal instead opening a enw one - default = true
--  opts.visit_first_call -- Focus the new opened window / pane. default = true
--  opts.size -- If open_as = pane, split with this size. default = 50%
--  opts.open_as -- Open as window or pane? Default: what is setted on setup (window)
--  opts.use_cwd -- Use current cwd on new window / pane? Default: what is setted on setup (true)
--  opts.close_on_timer -- When the command completed, sleep for some seconds - default = what is setted on setup: 0
--  opts.read_after_cmd -- When the command completed, wait for enter to close the window. default = true
function M.run(opts)
  local cur_saves = vim.g.tmux_saved_commands or {}
  table.insert(cur_saves, opts)
  vim.g.tmux_saved_commands = cur_saves

  return function()
    M.execute_command(opts)
  end
end

function M.switch_orientation()
  if vim.g.tmux_default_orientation == 'horizontal' then
    vim.notify("new panes will open VERTICALLY")

    vim.g.tmux_default_orientation = 'vertical'
  else
    vim.notify("new panes will open HORIZONTALLY")

    vim.g.tmux_default_orientation = 'horizontal'
  end
end

function M.switch_open_as()
  if vim.g.tmux_open_new_as == 'window' then
    vim.notify("new terms will open as panes.")

    vim.g.tmux_open_new_as = 'pane'
  else
    vim.notify("new terms will open as windows")

    vim.g.tmux_open_new_as = 'window'
  end
end


-- Add function to open term to be used on a keybinding.
-- Also adds the command
--
-- Arguments:
--  opts.focus_when_call -- Focus terminal instead opening a enw one - default = true
--  opts.visit_first_call -- Focus the new opened window / pane. default = true
--  opts.size -- If open_as = pane, split with this size. default = 50%
--  opts.open_as -- Open as window or pane? Default: what is setted on setup (window)
--  opts.use_cwd -- Use current cwd on new window / pane? Default: what is setted on setup (true)
--  opts.close_on_timer -- When the command completed, sleep for some seconds - default = what is setted on setup: 0
--  opts.read_after_cmd -- When the command completed, wait for enter to close the window. default = true
function M.run_wk(opts)
  local cur_saves = vim.g.tmux_saved_commands or {}
  table.insert(cur_saves, opts)
  vim.g.tmux_saved_commands = cur_saves

  return { function() M.execute_command(opts) end, opts.name }
end

return M
