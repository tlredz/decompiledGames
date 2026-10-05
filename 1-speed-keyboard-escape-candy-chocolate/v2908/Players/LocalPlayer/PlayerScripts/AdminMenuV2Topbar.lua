local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local Icon = require(ReplicatedStorage:WaitForChild("TopbarPlus"):WaitForChild("Icon"))
local v = nil
local v2 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function openAdminMenuV2()
	if not v2 then
		local AdminMenu = require(ReplicatedStorage:WaitForChild("Cmdr"):WaitForChild("Menus"):WaitForChild("AdminMenu"))
		v2 = AdminMenu
	end

	v2.Open()
end

local function updateButton()
	local hasCmdr = localPlayer:GetAttribute("HasCmdr") == true

	if hasCmdr and not v then
		v = Icon.new():setName("AdminMenuV2"):setImage(""):setLabel("AdminV2")
		v.selected:Connect(function()
			openAdminMenuV2() -- equivalent call inferred; original call site unknown
			v:deselect()
		end)
	elseif not hasCmdr and v then
		v:destroy()
		v = nil
	end
end

localPlayer:GetAttributeChangedSignal("HasCmdr"):Connect(updateButton)
updateButton()