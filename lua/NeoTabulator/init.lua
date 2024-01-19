-- Author: Shane
-- Date: 2024-01-19 16:49
local options = {}

-- All optional alignment modes
local mode_options = {
    center = "c",
    left = "l",
    right = "r"
}

local error_message = "Usage: CreateTable [ALIGNMENT] <height>x<width>"

-- Generate table content and pass to create_table()
local function generate_table_content(mode, rows, cols)
    local header = "| " .. string.rep("head | ", cols)
    -- separator default to be center alignment
    local separator = "|" .. string.rep(":----:|", cols)
    -- reassign separator according to the mode
    if mode == mode_options.left then
        separator = "|" .. string.rep(":-----|", cols)
    elseif mode == mode_options.right then
        separator = "|" .. string.rep("-----:|", cols)
    end

    local table_content = { header, separator }

    -- Generate table
    for _ = 1, rows-1 do
        table.insert(table_content, "| " .. string.rep("item | ", cols))
    end

    return table_content
end

-- Write table to buffer
local function create_table(mode, rows, cols)
    local buffer = vim.api.nvim_get_current_buf()
    local line = vim.api.nvim_win_get_cursor(0)[1]
    local table_content = generate_table_content(mode, rows, cols)
    vim.api.nvim_buf_set_lines(buffer, line, line, false, table_content)
end

-- A common function used to find the longest string
-- and format the whole string
local function format(line)
    -- Remove spaces form both sides of line string
    line = line:gsub("^%s*(.-)%s*$", "%1")
    -- Check if "|" in line
    local check = string.find(line, "|")
    local result = {}
    if check then
        local length = 0
        for match in string.gmatch(line, "|([^|]+)") do
            -- Remove spaces from both sides of string
            match = match:gsub("^%s*(.-)%s*$", "%1")
            -- Find the longest string
            if string.len(match) > length then
                length = string.len(match)
            end
            table.insert(result, match)
        end
        -- rewrite the text
        for i, word in ipairs(result) do
            local current_len = string.len(word)
            -- Check if it is the line of alignment syntax
            local find_pattern = string.find(word, ":%-")
            -- Add 2 spaces at both sides of the word
            local diff = length - current_len + 2
            local left = math.floor(diff / 2)
            local right = diff - left
            if find_pattern then
                if vim.api.nvim_get_mode().mode == "n" then
                    diff = length - current_len
                end
                -- find the half length of the word
                local middle = math.floor(current_len / 2)
                local first_part = string.sub(word, 1, middle)
                local last_part = string.sub(word, middle + 1, current_len)
                result[i] = first_part .. string.rep("-", diff) .. last_part
            else
                result[i] = string.rep(" ", left) .. result[i] .. string.rep(" ", right)
            end
        end
        return result
    else
        return
    end
end

-- auto format in normal mode
local function autoformat_normal()
    -- Get the content of current line
    local line = vim.api.nvim_get_current_line()
    -- Format begin
    local result = format(line)
    if result then
        local buf = vim.api.nvim_get_current_buf()
        local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
        local new_line = "|" .. table.concat(result, "|") .. "|"
        vim.api.nvim_buf_set_lines(buf, row-1, row, false, {new_line})
    else
        return
    end
end

-- Get selected text on visual mode
-- See https://github.com/neovim/neovim/pull/13896#issuecomment-774680224
local function get_visual_selection()
    local M = {}
    local vstart = vim.fn.getpos('v')
    local vend = vim.fn.getcurpos()
    M.region_start = vstart[2]
    M.region_end = vend[2]
    M.rows = vend[2] - vstart[2] + 1
    local lines = {}
    -- Remove spaces from both sides of line
    for i = vstart[2], vend[2] do
        local line = vim.api.nvim_buf_get_lines(0, i-1, i, false)
        line[1] = line[1]:gsub("^%s*(.-)%s*$", "%1")
        table.insert(lines, line[1])
    end
    M.text = table.concat(lines)
    return M
end

-- auto format under visual mode
local function autoformat_visual()
    local info = get_visual_selection()
    local text = info.text
    -- Replace "||" to be "|"
    -- and then format it
    local content = format(string.gsub(text, "%|%|", "%|"))
    -- Reinsert "||" to the recorded positions
    if content then
        -- find the cols of table
        local _, count = string.gsub(table.concat(content, "|"), "%|", "")
        local cols = (count + info.rows + 1) / info.rows - 1
        -- Create a new table store the rearrange data
        local new_table = {}
        local total_str = #content
        for i = 1, total_str, cols do
            local temp = {}
            for j = 0, cols-1 do
                table.insert(temp, content[i + j])
            end
            local single_str = "|" .. table.concat(temp, "|") .. "|"
            table.insert(new_table, single_str)
        end
        vim.api.nvim_buf_set_lines(0, info.region_start-1, info.region_end, false, new_table)
    else
        return
    end
end

-- Default setup
local function setup(opts)
    options = vim.tbl_extend("force", {
        -- Alignment
        -- Default value: center
        -- Options: center, left, right
        mode = mode_options.center,
        -- Keymaps
        create_table = "<leader>ta",
        format_normal = "<leader>fn",
        format_visual = "<leader>fv"
    }, opts or {})
    vim.keymap.set("n", options.create_table, ":CreateTable ", {})
    vim.keymap.set("n", options.format_normal, autoformat_normal, {})
    vim.keymap.set("v", options.format_visual, autoformat_visual, {})
end

-- Register command
vim.api.nvim_create_user_command('CreateTable', function(params)
    -- Get the number of params
    -- Mode: Alignment
    local parameter = vim.split(params.args, ' ')
    local length = #parameter
    local args = {}
    -- Check the number of params and reassign values to mode and args
    -- If 1 => mode: default to be center alignment
    -- else => mode: first params
    if length == 1 then
        args = vim.split(params.args, "x")
    elseif length == 2 then
        options.mode = parameter[1]
        -- Check if mode is valid
        local contain = false
        for _, value in pairs(mode_options) do
            if options.mode == value then
                contain = true
                break
            end
        end
        -- Check if it is the correct format
        if contain and string.match(parameter[2], "^[%d+x%d+]$") then
            args = vim.split(parameter[2], "x")
        else
            print(error_message)
            return
        end
    else
        print(error_message)
        return
    end

    -- Call create_table function
    local rows = tonumber(args[1])
    local cols = tonumber(args[2])
    create_table(options.mode, rows, cols)

end, { nargs = 1 })

return {
    setup = setup
}
