local v = 20
local parent = script.Parent.Parent

local function TableToNumberSequence(list)
	table.sort(list, function(a, b)
		return a[1] < b[1]
	end)

	local function getValueAt(p)
		for k, v2 in pairs(list) do
			if not (v2[1] ~= p and list[k + 1]) then
				return v2[2]
			end

			if not (v2[1] < p and p < list[k + 1][1]) then
				continue
			end

			local v3 = list[k][1]
			local v4 = list[k][2]
			local v5 = list[k + 1][1]
			local v6 = list[k + 1][2]
			local v7 = (p - v3) / (v5 - v3)
			return v4 + (v6 - v4) * v7
		end
	end

	local v2 = {}

	for _, v3 in ipairs(list) do
		table.insert(v2, NumberSequenceKeypoint.new((v3[1] - 0) / 1, v3[2]))
	end

	local v3 = false

	for _, v5 in pairs(v2) do
		if v5.Time ~= 0 then
			continue
		end

		v3 = true
		break
	end

	if not v3 then
		table.insert(v2, 1, NumberSequenceKeypoint.new(0, getValueAt(0)))
	end

	local v5 = false

	for _, v7 in pairs(v2) do
		if v7.Time ~= 1 then
			continue
		end

		v5 = true
		break
	end

	if not v5 then
		table.insert(v2, NumberSequenceKeypoint.new(1, getValueAt(1)))
	end

	table.sort(v2, function(a, b)
		return a.Time < b.Time
	end)
	local v7 = {}

	for _, v8 in pairs(v2) do
		if v8.Time >= 0 and v8.Time <= 1 then
			table.insert(v7, v8)
		end
	end

	return NumberSequence.new(v7)
end

local thread = nil

local function Refresh()
	if thread then
		return
	end

	thread = task.defer(function()
		v = math.min(script.Parent.Parent.AbsoluteSize.Y / 3.2, 20)
		local v2 = {
			parent.CanvasPosition.Y + math.min(parent.CanvasPosition.Y, v) - v,
			parent.CanvasPosition.Y + math.min(parent.CanvasPosition.Y, v),
			parent.CanvasPosition.Y + parent.AbsoluteSize.Y - v + v - math.min(
				parent.AbsoluteCanvasSize.Y - parent.CanvasPosition.Y - parent.AbsoluteSize.Y,
				v
			),
			parent.CanvasPosition.Y + parent.AbsoluteSize.Y + v - math.min(
				parent.AbsoluteCanvasSize.Y - parent.CanvasPosition.Y - parent.AbsoluteSize.Y,
				v
			)
		}
		local v3 = {}

		for k, v4 in pairs(v2) do
			local v5 = v4 / parent.AbsoluteCanvasSize.Y
			v3[k] = { math.abs(v5 - 1) < 0.01 and 1 or math.abs(v5) < 0.01 and 0 or v5, (k == 1 or k == 4) and 1 or 0 }
		end

		script.Parent.UIGradient.Transparency = TableToNumberSequence(v3)
		thread = nil
	end)
end

script.Parent.Parent:GetPropertyChangedSignal("CanvasPosition"):Connect(Refresh)
script.Parent.Parent:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(Refresh)