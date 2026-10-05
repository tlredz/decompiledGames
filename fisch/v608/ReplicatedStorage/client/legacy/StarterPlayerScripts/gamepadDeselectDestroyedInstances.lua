local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local packages = ReplicatedStorage.packages
local Trove = require(packages.Trove)
local v = nil
local v2 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function createObserverTrove(selectedObject)
	if v then
		v:Destroy()
	end

	if not selectedObject then
		return
	end

	v = Trove.new()
	v:Connect(selectedObject.AncestryChanged, function(_, p)
		if p ~= nil then
			return
		end

		GuiService.SelectedObject = nil
	end)
end

UserInputService.InputBegan:Connect(function(input, _)
	if input.KeyCode == Enum.KeyCode.BackSlash then
		v2 = not v2
		Players.LocalPlayer:SetAttribute("BackslashToggled", v2)
	end
end)
GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(function()
	createObserverTrove(GuiService.SelectedObject) -- equivalent call inferred; original call site unknown
end)