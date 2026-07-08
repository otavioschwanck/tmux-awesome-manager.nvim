local M = {}

local function parse_json(str)
	local ok, data = pcall(vim.fn.json_decode, str)
	if ok then return data end
	return nil
end

local function extract_pane_id(json_str)
	local data = parse_json(json_str)
	if not data or not data.result then return "" end
	if data.result.root_pane then return data.result.root_pane.pane_id or "" end
	if data.result.pane then return data.result.pane.pane_id or "" end
	return ""
end

local function run_in_pane(pane_id, cmd)
	local full_cmd = vim.g.tmux_keep_open and cmd or (cmd .. "; exit")
	vim.fn.system("herdr pane run " .. pane_id .. " " .. vim.fn.shellescape(full_cmd))
end

function M.open_window(name, cmd, cwd, focus)
	local args = " --label " .. vim.fn.shellescape(name)
	if cwd then args = args .. " --cwd " .. vim.fn.shellescape(cwd) end
	args = args .. (focus and " --focus" or " --no-focus")
	local result = vim.fn.system("herdr tab create" .. args)
	local pane_id = extract_pane_id(result)
	if pane_id ~= "" then run_in_pane(pane_id, cmd) end
	return pane_id
end

function M.open_pane(cmd, size, orientation, cwd, focus)
	local dir = orientation == "horizontal" and "right" or "down"
	local args = " --current --direction " .. dir
	if size then
		local ratio = tonumber(string.match(size, "(%d+)%%") or "50") / 100
		args = args .. " --ratio " .. ratio
	end
	if cwd then args = args .. " --cwd " .. vim.fn.shellescape(cwd) end
	args = args .. (focus and " --focus" or " --no-focus")
	local result = vim.fn.system("herdr pane split" .. args)
	local pane_id = extract_pane_id(result)
	if pane_id ~= "" then run_in_pane(pane_id, cmd) end
	return pane_id
end

-- herdr não tem sessions equivalentes a tmux; abre como aba nova
function M.open_session(session_name, name, cmd, cwd, focus)
	return M.open_window(name, cmd, cwd, focus)
end

function M.session_exists(session_name)
	return false
end

function M.focus(pane_id)
	local result = vim.fn.system("herdr pane get " .. pane_id .. " 2>/dev/null")
	local data = parse_json(result)
	if data and data.result and data.result.pane then
		vim.fn.system("herdr tab focus " .. data.result.pane.tab_id)
	end
end

function M.close(pane_id)
	vim.fn.system("herdr pane close " .. pane_id)
end

function M.pane_exists(pane_id)
	vim.fn.system("herdr pane get " .. pane_id .. " 2>/dev/null")
	return vim.v.shell_error == 0
end

function M.pane_alive(pane_id)
	vim.fn.system("herdr pane get " .. pane_id .. " 2>/dev/null")
	return vim.v.shell_error == 0
end

function M.kill_term(pane_id)
	vim.fn.system("herdr pane close " .. pane_id)
end

function M.send_text(pane_id, text)
	vim.fn.system("herdr pane send-text " .. pane_id .. " " .. vim.fn.shellescape(text))
end

return M
