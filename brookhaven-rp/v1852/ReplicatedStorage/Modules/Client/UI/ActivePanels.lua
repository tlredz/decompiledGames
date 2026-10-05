local v = {}
local ActivePanels = {}

function ActivePanels.Push(p)
	if not table.find(v, p) then
		table.insert(v, p)
	end
end

function ActivePanels.Pop()
	return table.remove(v)
end

function ActivePanels.Peek()
	return v[#v]
end

function ActivePanels.Clear()
	table.clear(v)
end

function ActivePanels.IsEmpty()
	return #v == 0
end

function ActivePanels.Remove(p)
	for i = #v, 1, -1 do
		if v[i] ~= p then
			continue
		end

		table.remove(v, i)
		break
	end
end

return ActivePanels