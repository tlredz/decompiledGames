local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UI = require(ReplicatedStorage.Modules.UI)
local parent = script.Parent.Parent
local pages = parent.Parent.Pages
local shop = script:FindFirstAncestor("Shop")

local function ResetInspectToDefault()
	for _, button in script.Parent.Buttons:GetChildren() do
		if button:IsA("ImageButton") and button.Name ~= "Cancel" then
			button.Visible = false
		end
	end

	script.Parent.Price.Visible = true
	script.Parent.ViewContent.Visible = false
	script.Parent.ViewDesigns.Visible = false
	pages.Visible = true
	script.Parent.Item.Visible = true
	script.Parent.Profile.Visible = false
	script.Parent.Description.Visible = true

	if script.Parent.Item:FindFirstChild("EmoteDisplay") then
		script.Parent.Item.EmoteDisplay.Visible = false
	end

	if script.Parent.Item:FindFirstChild("Title") then
		script.Parent.Item.Title.Visible = false
	end
end

parent:GetPropertyChangedSignal("Visible"):Connect(function()
	for _, v in shop:QueryDescendants("GuiButton") do
		if not (v.Name ~= "Close" and (v:FindFirstAncestor("Tabs") or v:FindFirstAncestor("Hotbar") or v.Parent.Name == "Header")) then
			continue
		end

		v.Active = not parent.Visible
	end

	if not parent.Visible then
		return ResetInspectToDefault()
	end

	pages.Visible = false
end)
local v = {
	script.Parent.Buttons.Purchase,
	script.Parent.Buttons.Owned,
	script.Parent.Buttons.Unequip,
	script.Parent.Buttons.Equip,
	script.Parent.Buttons.Rebind,
	script.Parent.Buttons.Bind
}

for _, v2 in v do
	local v3 = v2
	v2:GetPropertyChangedSignal("Visible"):Connect(function()
		if v3.Visible then
			for k, v4 in v do
				if v4 ~= v3 then
					v4.Visible = false
				end
			end
		end
	end)
end

UI:Bind(script.Parent.ViewDesigns)
local v2 = { script.Parent.Robux, script.Parent.Price }

for _, v3 in v2 do
	local v4 = v3
	v3:GetPropertyChangedSignal("Visible"):Connect(function()
		if v4.Visible then
			for k, v5 in v2 do
				if v5 ~= v4 then
					v5.Visible = false
				end
			end
		end
	end)
end

ResetInspectToDefault()