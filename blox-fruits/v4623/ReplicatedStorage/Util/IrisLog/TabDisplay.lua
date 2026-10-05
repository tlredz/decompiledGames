local TabDisplay = {}

local function tabLineCount(p)
	if typeof(p) == "table" and typeof(p.Lines) == "table" then
		return #p.Lines
	end

	return 0
end

local function hiddenDefaultLogTabIndex(list)
	if #list <= 1 then
		return nil
	end

	for k, v in list do
		if typeof(v) == "table" and v.Name == "Log" and (typeof(v) == "table" and typeof(v.Lines) == "table" and #v.Lines or 0) == 0 then
			return k
		end
	end

	return nil
end

function TabDisplay.shouldHideDefaultLogTab(p)
	return hiddenDefaultLogTabIndex(p) ~= nil
end

function TabDisplay.resolveSelectedTabIndex(list, value: number?)
	local count = #list

	if count <= 0 then
		return 1
	end

	local v = math.clamp(value or 1, 1, count)
	local v2 = hiddenDefaultLogTabIndex(list)

	if v ~= v2 then
		return v
	end

	if v2 == 1 then
		return 2
	end

	return 1
end

function TabDisplay.visibleTabIndexForSourceIndex(list, p: number?)
	local count = #list

	if count <= 0 then
		return 1
	end

	local selectedTabIndex = TabDisplay.resolveSelectedTabIndex(list, p)
	local v = hiddenDefaultLogTabIndex(list)

	if v and v < selectedTabIndex then
		return (math.clamp(selectedTabIndex - 1, 1, (math.max(1, count - 1))))
	end

	return selectedTabIndex
end

function TabDisplay.visibleTabs(list)
	local v = hiddenDefaultLogTabIndex(list)
	local result = {}
	local result2 = {}

	for i = 1, #list do
		if i == v then
			continue
		end

		table.insert(result, list[i])
		table.insert(result2, i)
	end

	return result, result2
end

return TabDisplay