local M = {}

local function normalize(str)
	return string.gsub(tostring(str), "\n", "")
end

local function b()
	return vim.g.tmux_binary or "tmux"
end

function M.open_window(name, cmd, cwd, focus)
	local extra = focus and "" or " -d "
	if cwd then extra = extra .. " -c " .. cwd .. " " end
	local result = vim.fn.system(b() .. " new-window -P -n '" .. name .. "' " .. extra .. ' "' .. cmd .. '"')
	local target = normalize(result)
	return normalize(vim.fn.system(b() .. ' display -pt "' .. target .. '" "#{pane_id}"'))
end

function M.open_pane(cmd, size, orientation, cwd, focus)
	local dir = orientation == "horizontal" and " -h " or " -v "
	local extra = focus and "" or " -d "
	if cwd then extra = extra .. " -c " .. cwd .. " " end
	local result = vim.fn.system(b() .. " split-window -P -l " .. (size or "50%") .. dir .. extra .. ' -F "#{pane_id}" "' .. cmd .. '"')
	return normalize(result)
end

function M.open_session(session_name, name, cmd, cwd, focus)
	local extra = " -d "
	if cwd then extra = extra .. " -c " .. cwd .. " " end
	if M.session_exists(session_name) then
		local result = vim.fn.system(b() .. " new-window -P -F '#{pane_id}' -n '" .. name .. "' -t '" .. session_name .. "': " .. extra .. ' "' .. cmd .. '"')
		return normalize(result)
	else
		local result = vim.fn.system(b() .. " new-session -P -d -F '#{pane_id}' -s '" .. session_name .. "' -n '" .. name .. "' " .. extra .. ' "' .. cmd .. '"')
		return normalize(result)
	end
end

function M.session_exists(session_name)
	local result = vim.fn.system(b() .. " ls | grep '" .. session_name .. "'")
	return result ~= ""
end

function M.focus(pane_id)
	vim.fn.system(b() .. ' switch-client -t "' .. pane_id .. '"')
	vim.fn.system(b() .. ' select-window -t "' .. pane_id .. '"')
	vim.fn.system(b() .. ' select-pane -t "' .. pane_id .. '"')
end

function M.close(pane_id)
	vim.fn.system(b() .. " kill-pane -t " .. pane_id)
end

function M.pane_exists(pane_id)
	return normalize(vim.fn.system(b() .. " display-message -t " .. pane_id .. " -p '#{pane_id}'")) ~= ""
end

function M.pane_alive(pane_id)
	return normalize(vim.fn.system(b() .. " has-session -t " .. pane_id .. " 2>/dev/null && echo 123")) == "123"
end

function M.kill_term(pane_id)
	vim.fn.system(b() .. " run-shell -t " .. pane_id .. ' \'kill -s USR1 -- "-$(ps -o tpgid= -p #{pane_pid} | sed "s/^[[:blank:]]*//")"\' ')
end

function M.send_text(pane_id, text)
	vim.fn.system(b() .. " send-keys -t " .. pane_id .. " '" .. text .. "'")
end

return M
