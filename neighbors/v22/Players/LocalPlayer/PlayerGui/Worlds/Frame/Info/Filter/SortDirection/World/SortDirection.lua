local parent = script.Parent.Parent.Parent
local button = script.Parent.Button
local icon = script.Parent.Icon
local v = {
	Descending = "rbxassetid://13327605103",
	Ascending = "rbxassetid://13327604062"
}

local function update()
	icon.Image = v[parent:GetAttribute("SortDirection")] or "rbxassetid://13327605103"
end

button.MouseButton1Click:connect(function()
	parent:SetAttribute(
		"SortDirection",
		parent:GetAttribute("SortDirection") == "Descending" and "Ascending" or "Descending"
	)
end)
parent:GetAttributeChangedSignal("SortDirection"):connect(update)
icon.Image = v[parent:GetAttribute("SortDirection")] or v.Descending