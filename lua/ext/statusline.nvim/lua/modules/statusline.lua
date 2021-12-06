local api = vim.api
local cmd = api.nvim_command
local call = vim.call
local modes = require('tables._modes')
local git_branch = require('sections._git_branch')
local lsp = require('sections._lsp')
local signify = require('sections._signify')
local bufmod = require('sections._bufmodified')
local bufname = require('sections._bufname')
local buficon = require('sections._buficon')
local editable = require('sections._bufeditable')
local filesize = require('sections._filesize')
local M = {}

-- Separators
local left_separator = ''
local right_separator = ''

-- Blank Between Components
local space = ' '

-- Different colors for mode
local purple = '#C57BDB' 
local blue = '#51afef' 
local yellow = '#FCCE7B'
local green = '#7bc275' 
local red = '#ff665c' 

-- fg and bg
local white_fg = '#bbc2cf'
local black_fg = '#242730'
local mybg = '#242730'

--Statusline colour
local statusline_bg = 'None' --> Set to none, use native bg
local statusline_fg = white_fg
-- local statusline_font = 'regular'
cmd('hi Status_Line guibg=' .. statusline_bg .. ' guifg=' .. statusline_fg)

--LSP Function Highlight Color
cmd('hi Statusline_LSP_Func guibg=' .. statusline_bg .. ' guifg=' .. green)

-- INACTIVE BUFFER Colours
local InactiveLine_bg = '#1c1c1c'
local InactiveLine_fg = white_fg
cmd('hi InActive guibg=' .. InactiveLine_bg .. ' guifg=' .. InactiveLine_fg)

-- Redraw different colors for different mode
local set_mode_colours = function(mode)
	if mode == 'n' then
		cmd('hi Mode guibg=' .. green .. ' guifg=' .. black_fg .. ' gui=bold')
		cmd('hi ModeSeparator guifg=' .. green)
	end
	if mode == 'i' then
		cmd('hi Mode guibg=' .. blue .. ' guifg=' .. black_fg .. ' gui=bold')
		cmd('hi ModeSeparator guifg=' .. blue)
	end
	if mode == 'v' or mode == 'V' or mode == '^V' then
		cmd('hi Mode guibg=' .. purple .. ' guifg=' .. black_fg .. ' gui=bold')
		cmd('hi ModeSeparator guifg=' .. purple)
	end
	if mode == 'c' then
		cmd('hi Mode guibg=' .. yellow .. ' guifg=' .. black_fg .. ' gui=bold')
		cmd('hi ModeSeparator guifg=' .. yellow)
	end
	if mode == 't' then
		cmd('hi Mode guibg=' .. red .. ' guifg=' .. black_fg .. ' gui=bold')
		cmd('hi ModeSeparator guifg=' .. red)
	end
end

function M.activeLine()
	local statusline = ''
	-- Component: Mode
	local mode = api.nvim_get_mode()['mode']
	set_mode_colours(mode)
	statusline = statusline .. '%#ModeSeparator#' .. space
	statusline = statusline
		.. '%#ModeSeparator#'
		.. left_separator
		.. '%#Mode# '
		.. modes.current_mode[mode]
		.. ' %#ModeSeparator#'
		.. right_separator
		.. space
	-- Component: Filetype and icons
	statusline = statusline .. '%#Status_Line#' .. bufname.get_buffer_name()
	statusline = statusline .. buficon.get_file_icon()

	if diag_lsp then
		statusline = statusline .. lsp.diagnostics()
	end

	statusline = statusline .. signify.signify()
	statusline = statusline .. git_branch.branch()
	statusline = statusline .. lsp.lsp_progress()
	statusline = statusline .. '%='

	-- Component: LSP CURRENT FUCTION --> Requires LSP
	statusline = statusline .. '%#Statusline_LSP_Func# ' .. lsp.current_function()
	statusline = statusline .. '%#Statusline_LSP_Func# ' .. lsp.lightbulb()

    -- Component: Modified, Read-Only, Filesize, Row/Col
	statusline = statusline .. '%#Status_Line#' .. bufmod.is_buffer_modified()
	statusline = statusline .. editable.editable() .. filesize.get_file_size() .. [[ʟ %l/%L c %c]] .. space
	cmd('set noruler') --disable line numbers in bottom right for our custom indicator as above
	return statusline
end

function M.wants_lsp()
	diag_lsp = true
	return M.activeLine(diag_lsp)
end

-- statusline for simple buffers such as NvimTree where you don't need mode indicators etc
function M.simpleLine()
	local statusline = ''
	return statusline .. '%#Status_Line#' .. bufname.get_buffer_name() .. ''
end

-- INACTIVE FUNCTION DISPLAY
function M.inActiveLine()
	local statusline = ''
	return statusline .. bufname.get_buffer_name() .. buficon.get_file_icon()
end

return M