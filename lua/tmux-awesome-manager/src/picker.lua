local M = {}

-- Helper function to check if a package is available
local function has_package(name)
  local ok, _ = pcall(require, name)
  return ok
end

-- Get the configured picker or fallback to available ones
local function get_picker_type()
  local picker = vim.g.tmux_picker or "telescope"
  
  if picker == "fzf-lua" then
    if has_package("fzf-lua") then
      return "fzf-lua"
    else
      vim.notify("fzf-lua not available, falling back to telescope", "warn", { title = "Tmux Awesome Manager" })
      return "telescope"
    end
  elseif picker == "telescope" then
    if has_package("telescope") then
      return "telescope"
    else
      vim.notify("telescope not available, falling back to fzf-lua", "warn", { title = "Tmux Awesome Manager" })
      return "fzf-lua"
    end
  else
    -- Auto-detect available picker
    if has_package("telescope") then
      return "telescope"
    elseif has_package("fzf-lua") then
      return "fzf-lua"
    else
      vim.notify("Neither telescope nor fzf-lua available", "error", { title = "Tmux Awesome Manager" })
      return nil
    end
  end
end

-- Telescope picker implementation
local function telescope_picker(opts)
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  
  opts.telescope_opts = require("telescope.themes").get_dropdown(opts.telescope_opts or {})
  
  pickers.new(opts.telescope_opts, {
    prompt_title = opts.prompt_title,
    finder = finders.new_table({
      results = opts.results,
      entry_maker = opts.entry_maker
    }),
    sorter = conf.generic_sorter(opts.telescope_opts),
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        opts.on_select(selection)
      end)
      return true
    end,
  }):find()
end

-- FZF-lua picker implementation
local function fzf_picker(opts)
  local fzf_lua = require("fzf-lua")
  
  local entries = {}
  for i, result in ipairs(opts.results) do
    local entry = opts.entry_maker and opts.entry_maker(result) or { value = result, display = result, ordinal = result }
    table.insert(entries, entry.display)
  end
  
  fzf_lua.fzf_exec(entries, {
    prompt = (opts.prompt_title or "Select") .. "> ",
    actions = {
      ["default"] = function(selected)
        if selected and #selected > 0 then
          -- Find the original result that matches the selected display
          local selected_display = selected[1]
          for i, result in ipairs(opts.results) do
            local entry = opts.entry_maker and opts.entry_maker(result) or { value = result, display = result, ordinal = result }
            if entry.display == selected_display then
              opts.on_select(entry)
              break
            end
          end
        end
      end
    }
  })
end

-- Generic picker function
function M.pick(opts)
  local picker_type = get_picker_type()
  
  if not picker_type then
    return
  end
  
  if picker_type == "telescope" then
    telescope_picker(opts)
  elseif picker_type == "fzf-lua" then
    fzf_picker(opts)
  end
end

return M