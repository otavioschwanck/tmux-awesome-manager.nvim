local M = {}

function M.get()
	if vim.g.tmux_binary == "herdr" then
		return require('tmux-awesome-manager.src.adapters.herdr')
	end
	return require('tmux-awesome-manager.src.adapters.tmux')
end

return M
