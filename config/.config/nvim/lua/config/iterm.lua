-- =============================================================================
--  iTerm2 Status Bar Integration (High Performance)
--  Requires: nvim-web-devicons
-- =============================================================================

-- 1. Pure Lua Base64 Encoder (No system calls = No lag)
local b = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local function to_base64(data)
	return (
		(data:gsub(".", function(x)
			local r, b = "", x:byte()
			for i = 8, 1, -1 do
				r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and "1" or "0")
			end
			return r
		end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(x)
			if #x < 6 then
				return ""
			end
			local c = 0
			for i = 1, 6 do
				c = c + (x:sub(i, i) == "1" and 2 ^ (6 - i) or 0)
			end
			return b:sub(c + 1, c + 1)
		end) .. ({ "", "==", "=" })[#data % 3 + 1]
	)
end

local function update_iterm2_status()
	local has_devicons, devicons = pcall(require, "nvim-web-devicons")

	-- Optimized Helper: Uses Lua function instead of slow vim.fn.system
	local function set_iterm_var(name, value)
		local base64_val = to_base64(tostring(value))
		io.stdout:write(string.format("\27]1337;SetUserVar=%s=%s\7", name, base64_val))
	end

	-- 2. MODE LOGIC
	local current_mode = vim.api.nvim_get_mode().mode
	local mode_map = {
		["n"] = { name = "NORMAL", target = "n" },
		["i"] = { name = "INSERT", target = "i" },
		["v"] = { name = "VISUAL", target = "v" },
		["V"] = { name = "V-LINE", target = "v" },
		["\22"] = { name = "V-BLOCK", target = "v" },
		["c"] = { name = "COMMAND", target = "c" },
		["R"] = { name = "REPLACE", target = "r" },
		["t"] = { name = "TERM", target = "t" },
	}

	local active_data = mode_map[current_mode] or { name = current_mode:upper(), target = "n" }
	local all_targets = { "n", "i", "v", "c", "r", "t" }

	for _, target in ipairs(all_targets) do
		local var_name = "nv_mode_" .. target
		if target == active_data.target then
			set_iterm_var(var_name, active_data.name .. " ")
		else
			set_iterm_var(var_name, "")
		end
	end

	-- 3. GATHER INFO
	local branch = vim.b.gitsigns_head or ""
	local branch_icon = branch ~= "" and " " or ""

	local warn = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
	local err = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
	local diag_str = ""
	if err > 0 then
		diag_str = " " .. err .. " "
	end
	if warn > 0 then
		diag_str = diag_str .. " " .. warn
	end

	local filename = vim.fn.expand("%:t")
	local extension = vim.fn.expand("%:e")
	local modified = vim.bo.modified and " [+]" or ""
	local file_display = (filename == "" and "[No Name]" or filename) .. modified

	local lang_icon = ""
	if has_devicons then
		lang_icon, _ = devicons.get_icon(filename, extension, { default = true })
	end

	local ft = vim.bo.filetype
	local encoding = vim.opt.fileencoding:get()
	encoding = encoding ~= "" and encoding or "utf-8"

	local os_icon = ""
	local cursor = vim.api.nvim_win_get_cursor(0)
	local total_lines = vim.api.nvim_buf_line_count(0)
	-- Safe division for empty buffers
	local progress = "0%%"
	if total_lines > 0 then
		progress = math.floor(cursor[1] / total_lines * 100) .. "%"
	end
	local position = string.format("%d:%d", cursor[1], cursor[2])

	-- 4. SEND DATA
	set_iterm_var("nv_git", branch_icon .. branch)
	set_iterm_var("nv_diag", diag_str)
	set_iterm_var("nv_file", file_display)
	set_iterm_var("nv_misc", encoding)
	set_iterm_var("nv_os", os_icon)
	set_iterm_var("nv_ft", string.format("%s %s", lang_icon, ft))
	set_iterm_var("nv_prog", progress)
	set_iterm_var("nv_pos", position)
end

-- Create Autocommands
local group = vim.api.nvim_create_augroup("iTerm2Status", { clear = true })
vim.api.nvim_create_autocmd({
	"CursorMoved",
	"CursorMovedI",
	"BufEnter",
	"DiagnosticChanged",
	"ModeChanged",
	"TextChanged",
}, {
	group = group,
	callback = update_iterm2_status,
})
