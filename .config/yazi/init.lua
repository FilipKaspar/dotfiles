require("recycle-bin"):setup()
require("full-border"):setup {
	-- Available values: ui.Border.PLAIN, ui.Border.ROUNDED
	type = ui.Border.ROUNDED,
}

-- Hide tab bar
function Tabs.height()
    return 0
end

-- Put tabs in top line bar
Header:children_add(function()
    if #cx.tabs <= 1 then
        return ""
    end
    local spans = {}
    for i = 1, #cx.tabs do
        local name = ya.truncate(string.format(" %d %s ", i, cx.tabs[i].name), { max = 20 })
        if i == cx.tabs.idx then
            spans[#spans + 1] = ui.Span(" " .. name .. " "):style(th.tabs.active)
        else
            spans[#spans + 1] = ui.Span(" " .. name .. " "):style(th.tabs.inactive)
        end
    end
    return ui.Line(spans)
end, 9000, Header.RIGHT)
