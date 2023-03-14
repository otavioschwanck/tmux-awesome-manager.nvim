local M = {}

local notify_ok, notify = pcall(require, 'notify')

local project_name = function()
  return vim.fn.split(vim.fn.getcwd(), "/")
end

if not(notify_ok) then
  notify = vim.notify
end

function M.execute_command(opts)
  if not opts.name then
    notify('You need to pass command_name to run the tmux command', "error", { title = "Tmux Awesome Manager" })

    return
  end

  if not opts.cmd then
    notify('You need to pass command to run the tmux command', "error", { title = "Tmux Awesome Manager" })

    return
  end

  M.refresh_really_opens()

  local name

  if vim.g.tmux_use_icon then
    name = vim.g.tmux_icon .. opts.name
  else
    name = opts.name
  end

  opts.focus_when_call = M.ternary(opts.focus_when_call == false, false, true)
  opts.visit_first_call = M.ternary(opts.visit_first_call == false, false, true)

  opts.size = opts.size or vim.g.tmux_default_size
  opts.open_as = opts.open_as or vim.g.tmux_open_new_as

  opts.open_id = M.get_open_id(name)
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
    local new_opts = M.ask_questions(M.deepcopy(opts))

    if not(new_opts == false) then
      M.open(new_opts)
    end
  elseif opts.focus_when_call then
    M.focus(opts.open_id)
  else
    M.close_and_open(opts)
  end
end

function M.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[M.deepcopy(orig_key)] = M.deepcopy(orig_value)
        end
        setmetatable(copy, M.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function M.kill_all_terms()
  for __, value in pairs(vim.g.tmux_open_terms or {}) do
    vim.fn.system('tmux run-shell -t ' .. value .. ' \'kill -s USR1 -- "-$(ps -o tpgid= -p #{pane_pid} | sed "s/^[[:blank:]]*//")"\'')
  end

  M.refresh_really_opens()

  notify("Safely killing terminals...", "info", { title = "Tmux Awesome Manager" })
end

function M.ask_questions(opts)
  local new_opts = opts

  if #(new_opts.questions or {}) > 0 then
    local index = 1

    for __, value in ipairs(new_opts.questions) do
      local user_input = vim.fn.input(value.question .. ' ')

      if (user_input == "" and not(value.optional)) then
        notify("\nThe input is required.  Canceling terminal command.", "warn", { title = "Tmux Awesome Manager" })

        return false
      end

      new_opts.cmd = string.gsub(new_opts.cmd, '%%' .. index, user_input)
    end

    return new_opts
  else
    return new_opts
  end
end

function M.ternary(cond, T, F)
  if cond then return T else return F end
end

function M.close_and_open(opts)
  vim.fn.system("tmux kill-pane -t " .. opts.open_id)

  M.open(opts)
end

function M.session_exists(session_name)
  local result = vim.fn.system("tmux ls | grep '" .. session_name .. "'")

  return result ~= ""
end

function M.session_name()
  if vim.g.tmux_session_name then
    return vim.g.tmux_session_name
  end

  local p_name = project_name()

  if vim.fn.len(p_name) > 0 then
    p_name = p_name[vim.fn.len(p_name)]
  else
    return "Neovim Terminals"
  end

  return p_name .. " Terminals"
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

  local session_name = opts.session_name or M.session_name()

  if opts.open_as == 'window' then
    base_command = "tmux new-window -P -n '" .. opts.name .. "'"
  elseif opts.open_as == 'separated_session' and M.session_exists(session_name) then
    base_command = "tmux new-window -P -F '#{pane_id}' -n " .. "'" .. opts.name .. "' -t '" .. session_name .. "': "

    notify("Opening " .. opts.name .. " in session: " .. session_name, " info", { title = "Tmux Awesome Manager" })
  elseif opts.open_as == 'separated_session' then
    base_command = "tmux new-session -P -d -F '#{pane_id}' -s '" .. session_name .. "' -n " .. "'" .. opts.name .. "' "
    notify("Opening " .. opts.name .. ".  Creating session: " .. session_name, " info", { title = "Tmux Awesome Manager" })
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

  local result = vim.fn.system(base_command .. ' "' .. opts.cmd .. '"')

  open_terms[opts.name] = M.normalize_return(result)

  if opts.open_as == 'window' then
    open_terms[opts.name] = M.normalize_return(vim.fn.system('tmux display -pt "' ..
      open_terms[opts.name] .. '" "#{pane_id}"'))
  end

  if opts.visit_first_call then
    M.focus(open_terms[opts.name])
  end

  vim.g.tmux_open_terms = open_terms
end

function M.focus(id)
  vim.fn.system("tmux switch-client -t \"" .. id .. "\"")
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
    notify("new panes will open VERTICALLY", "info", { title = "Tmux Awesome Manager" })

    vim.g.tmux_default_orientation = 'vertical'
  else
    notify("new panes will open HORIZONTALLY", "info", { title = "Tmux Awesome Manager" })

    vim.g.tmux_default_orientation = 'horizontal'
  end
end

function M.switch_open_as()
  if vim.g.tmux_open_new_as == 'window' then
    notify("new terms will open as panes.", "info", { title = "Tmux Awesome Manager" })

    vim.g.tmux_open_new_as = 'pane'
  else
    notify("new terms will open as windows", "info", { title = "Tmux Awesome Manager" })

    vim.g.tmux_open_new_as = 'window'
  end
end


function M.send_text_to(opts)
  if not(vim.fn.mode() == "v" or vim.fn.mode() == "V") then
    notify("Use this on visual mode", "warn", { title = "Tmux Awesome Manager" })

    return
  end

  M.refresh_really_opens()

  local keyset = {}
  local n = 0

  for k, v in pairs(vim.g.tmux_open_terms) do
    n = n + 1
    keyset[n] = k
  end

  if #keyset == 0 then
    notify("No tmux consoles open.", "warn", { title = "Tmux Awesome Manager" })

    return
  end

  local opts = opts or {}

  opts.prompt_title = 'Send selected text to:'

  opts = require("telescope.themes").get_dropdown(opts)

  vim.cmd('normal! "ty')

  local pickers = require "telescope.pickers"
  local finders = require "telescope.finders"
  local conf = require("telescope.config").values
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"

  pickers.new(opts, {
    finder = finders.new_table {
      results = keyset
    },
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()

        vim.fn.system("tmux send-keys -t " .. vim.g.tmux_open_terms[selection[1]] .. " '" .. vim.fn.getreg("t") .. "'")
      end)
      return true
    end,
  }):find()
end

-- Add function to open term to be used on a keybinding.
-- Also adds the command
--
-- Arguments:
--  opts.focus_when_call -- Focus terminal instead opening a enw one - default = true
--  opts.visit_first_call -- Focus the new opened window / pane. default = true
--  opts.size -- If open_as = pane, split with this size. default = 50%
--  opts.open_as -- Open as window or pane separated_session? Default: what is setted on setup (window)
--  opts.use_cwd -- Use current cwd on new window / pane? Default: what is setted on setup (true)
--  opts.close_on_timer -- When the command completed, sleep for some seconds - default = what is setted on setup: 0
--  opts.read_after_cmd -- When the command completed, wait for enter to close the window. default = true
function M.run_wk(opts)
  return { M.run(opts), opts.name }
end

return M
