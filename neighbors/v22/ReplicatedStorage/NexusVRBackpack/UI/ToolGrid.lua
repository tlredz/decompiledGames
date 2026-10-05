local ToolIcon = require(script.Parent:WaitForChild("ToolIcon"))
local ToolGrid = {}
ToolGrid.__index = ToolGrid

function ToolGrid.new()
	local self = setmetatable({
		IconGroups = {}
	}, ToolGrid)
	local frame = Instance.new("Frame")
	frame.BackgroundTransparency = 1
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	self.AdornFrame = frame
	return self
end

function ToolGrid:CreateToolIcon(p2: number, p3: number)
	return ToolIcon.new(self.AdornFrame, p2, p3)
end

function ToolGrid:SetRadius(p: number)
	local v = math.max(1, p)

	if v == #self.IconGroups then
		return
	end

	for i = #self.IconGroups + 1, v do
		local v2 = {}

		for i2 = 1, i + 1 do
			table.insert(v2, self:CreateToolIcon(-(i + 1) / 2 + i2 - 0.5, -i))
		end

		local v3 = i + 1
		local v4 = {}

		for i2 = 2, i * 2 do
			if i2 <= i + 1 then
				v3 += 1
			else
				v3 += -1
			end

			table.insert(v4, self:CreateToolIcon(-v3 / 2 + 1 - 0.5, -i + i2 - 1))
			table.insert(v2, self:CreateToolIcon(-v3 / 2 + v3 - 0.5, -i + i2 - 1))
		end

		for i2 = i + 1, 1, -1 do
			table.insert(v2, self:CreateToolIcon(-(i + 1) / 2 + i2 - 0.5, i))
		end

		for i2 = #v4, 1, -1 do
			table.insert(v2, v4[i2])
		end

		table.insert(self.IconGroups, v2)
	end

	for i = #self.IconGroups, v + 1, -1 do
		local iconGroup = self.IconGroups[i]
		table.remove(self.IconGroups, i)

		for _, v2 in iconGroup do
			v2:Destroy()
		end
	end
end

function ToolGrid:SetTools(list)
	local total = 6
	local v = 1

	while total < #list do
		v += 1
		total += v * 6
	end

	self:SetRadius(v)
	local v2 = 1

	for _, iconGroup in self.IconGroups do
		for _, v3 in iconGroup do
			v3:SetTool(list[v2])
			v2 += 1
		end
	end
end

function ToolGrid:UpdateFocusedIcon(p: number, p2: number)
	local v = 0.5
	local focusedIcon = nil

	for _, iconGroup in self.IconGroups do
		for _, v3 in iconGroup do
			local v4 = ((p - v3.RelativePositionX) ^ 2 + (p2 - v3.RelativePositionY) ^ 2) ^ 0.5

			if not (v4 < v) then
				continue
			end

			focusedIcon = v3
			v = v4
		end
	end

	if focusedIcon ~= self.FocusedIcon then
		if self.FocusedIcon then
			self.FocusedIcon:SetFocused(false)
		end

		if focusedIcon then
			focusedIcon:SetFocused(true)
		end

		self.FocusedIcon = focusedIcon
	end
end

function ToolGrid:Destroy()
	self.AdornFrame:Destroy()

	for _, iconGroup in self.IconGroups do
		for _, v in iconGroup do
			v:Destroy()
		end
	end

	self.IconGroups = {}
end

return ToolGrid