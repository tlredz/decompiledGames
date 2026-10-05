local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = {}
local v2 = Component.new({
	Tag = "TopbarLeftAnchored"
})

local function updateLayout()
	local topbarInset = GuiService.TopbarInset
	local v3 = topbarInset.Min.X + 14
	local v4 = topbarInset.Min.Y + topbarInset.Height / 2
	local v5 = {}

	for k in v do
		table.insert(v5, k)
	end

	table.sort(v5)

	for _, v6 in v5 do
		local v7 = v[v6]
		local screenGui = v7:FindFirstAncestorOfClass("ScreenGui")
		local v8 = v4 - ((screenGui and screenGui.IgnoreGuiInset or false) and 0 or GuiService:GetGuiInset().Y) + 6
		local v9 = v3 + v7.AbsoluteSize.X * v7.AnchorPoint.X
		local v10 = v8 + v7.AbsoluteSize.Y * (v7.AnchorPoint.Y - 0.5)
		v7.Position = UDim2.fromOffset(v9, v10)
		v3 += v7.AbsoluteSize.X + 14
	end
end

function v2:Construct()
	self._Janitor = Janitor.new()
end

function v2:Start()
	local topbarOrder = self.Instance:GetAttribute("TopbarOrder")
	assert(
		typeof(topbarOrder) == "number",
		(`TopbarLeftAnchored: TopbarOrder attribute on {self.Instance:GetFullName()} must be a number`)
	)

	if v[topbarOrder] then
		error((`TopbarLeftAnchored: TopbarOrder {topbarOrder} is already taken by {v[topbarOrder]:GetFullName()} and it is colliding with {self.Instance:GetFullName()}`))
	end

	self._order = topbarOrder
	v[topbarOrder] = self.Instance
	self._Janitor:Add(self.Instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateLayout))
	updateLayout()
end

function v2:Stop()
	if self._order and v[self._order] == self.Instance then
		v[self._order] = nil
		updateLayout()
	end

	self._Janitor:Destroy()
end

GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(updateLayout)
return v2