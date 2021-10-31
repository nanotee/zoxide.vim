local M = {}

function M.select(items, cd_command)
    vim.ui.select(items, {prompt = 'Zoxide> '}, function(item)
        vim.fn["zoxide#handle_select_result"](cd_command, item)
    end)
end

return M
