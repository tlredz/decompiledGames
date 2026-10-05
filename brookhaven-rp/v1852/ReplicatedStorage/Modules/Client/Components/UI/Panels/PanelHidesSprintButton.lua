local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = nil
local localPlayer = Players.LocalPlayer
local v2 = Component.new({
	Tag = "PanelHidesSprintButton"
})

function v2:Construct()
	self._Janitor = Janitor.new()
	local Panel = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.Panel)
	v = Panel
end

function v2:Start()
	local expect = v:WaitForInstance(self.Instance):expect()

	if expect == nil then
		warn("PanelHidesSprintButton not on Panel!")
		return
	end

	local noResetGUIHandler = localPlayer:WaitForChild("PlayerGui"):WaitForChild("NoResetGUIHandler")
	expect:RegisterListener(self, expect.Events.Opening, function(_)
		local speed = noResetGUIHandler:WaitForChild("MobileSprint"):WaitForChild("Nothing"):WaitForChild("Speed")
		speed.Visible = false
	end)
	self._Janitor:Add(function()
		expect:UnregisterListener(self, expect.Events.Opening)
	end, true)
	expect:RegisterListener(self, expect.Events.Closing, function(_)
		if noResetGUIHandler:WaitForChild("Sprint").Value == true then
			local speed = noResetGUIHandler:WaitForChild("MobileSprint"):WaitForChild("Nothing"):WaitForChild("Speed")
			speed.Visible = true
		end
	end)
	self._Janitor:Add(function()
		expect:UnregisterListener(self, expect.Events.Closing)
	end, true)
end

function v2:Stop()
	self._Janitor:Destroy()
end

return v2