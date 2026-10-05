local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NewUserDataController = require(ReplicatedStorage.Modules.Client.Util.NewUserDataController)
local v = nil
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v2 = Component.new({
	Tag = "DirectiveMenu"
})

function v2:Construct()
	self._Janitor = Janitor.new()
	local GameSdkShared = require(ReplicatedStorage:WaitForChild("Packages").GameSdkShared)
	local ABTest = require(GameSdkShared.Modules.ABTest)
	v = ABTest
end

function v2:Start()
	if not self.Instance:IsA("GuiObject") then
		warn("DirectiveMenu is not a GuiObject")
		return
	end

	if not NewUserDataController.IsFirstSession() then
		return
	end

	local v3, v4 = v.GetExperimentVariables("directive-menu"):timeout(3):await()

	if not v3 or (v4.menu == nil or v4.menu == "" or v4.menu == "nil") then
		return
	end

	local maid = Janitor.new()
	self._Janitor:Add(maid, "Destroy")

	for _, guiObject in self.Instance:GetChildren() do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		guiObject.Activated:Connect(function()
			maid:Cleanup()
		end)

		if guiObject.Name ~= v4.menu then
			continue
		end

		guiObject:SetAttribute("UIPulsatingBackground_Color", v4.colour or "#99e354")
		guiObject:SetAttribute("UIPulsatingBackground_Time", v4.time or 2)
		guiObject:AddTag("UIPulsatingBackground")
		local v5 = guiObject
		maid:Add(function()
			v5:SetAttribute("UIPulsatingBackground_Color", nil)
			v5:SetAttribute("UIPulsatingBackground_Time", nil)
			v5:RemoveTag("UIPulsatingBackground")
		end, true)
	end
end

function v2:Stop()
	self._Janitor:Destroy()
end

return v2