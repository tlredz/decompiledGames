local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RaceTrackConfettiMachine = require(ReplicatedStorage.Modules.Client.Components.LiveOps.SummerCarnival2026.GoKarts.RaceTrackConfettiMachine)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "GoKartTrack"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._confettiMachines = {}

	for _, child in self.Instance:GetChildren() do
		if child:HasTag("RaceTrackConfettiMachine") then
			table.insert(
				self._confettiMachines,
				ComponentUtil.GetComponentFromInstance(child, RaceTrackConfettiMachine)
			)
		end
	end
end

function v:Start()
	Remotes.connectComponentRemote(self.Instance, "LapCompleted", function()
		for _, _confettiMachine in self._confettiMachines do
			_confettiMachine:EnableForSeconds(2.4)
		end
	end)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v