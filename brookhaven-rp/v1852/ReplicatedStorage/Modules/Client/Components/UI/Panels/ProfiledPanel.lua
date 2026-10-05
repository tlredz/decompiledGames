game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Panel = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.Panel)
local ClientProfilingController = require(ReplicatedStorage.Modules.Client.Telemetry.ClientProfilingController)
local v = Component.new({
	Tag = "ProfiledPanel"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._wasStarted = false
end

function v:Start()
	local expect = Panel:WaitForInstance(self.Instance):expect()

	if expect == nil then
		warn("ProfiledPanel not on valid panel")
		return
	end

	expect:RegisterListener(self, expect.Events.Opening, function()
		ClientProfilingController.Start(self.Instance.Name)
		self._wasStarted = true
	end)
	expect:RegisterListener(self, expect.Events.Closing, function()
		if self._wasStarted then
			ClientProfilingController.Stop(self.Instance.Name)
			self._wasStarted = false
		end
	end)
	self._Janitor:Add(function()
		expect:UnregisterListener(self, expect.Events.Opening)
		expect:UnregisterListener(self, expect.Events.Closing)
	end, true)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v