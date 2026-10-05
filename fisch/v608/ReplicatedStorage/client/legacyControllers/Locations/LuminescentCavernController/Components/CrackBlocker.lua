local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("Players")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local modules = ReplicatedStorage.shared.modules
local LuminescentCavern = require(modules.LuminescentCavern)
local module = require("../LocalDataState")
local module2 = require("../Utility")
local v = Component.new({
	Tag = LuminescentCavern.Enums.CollectionService.CrackBlocker,
	Ancestors = { Workspace }
})

function v:Construct()
	if self.Instance and self.Instance:IsDescendantOf(Workspace) then
		self.DataObserver = module:observe(function(p)
			if self.Instance and self.Instance:IsDescendantOf(Workspace) then
				if not module2.IsPlacementsFinished(p) then
					return
				end

				local lastTime = tick()

				while module2.IsCrackVFXRunning() and not (tick() - lastTime > 5) do
					task.wait(0.05)
				end

				if self.Instance and self.Instance:IsDescendantOf(Workspace) then
					self.Instance:Destroy()
				else
					warn("CrackBlocker: Instance is nil or not in Workspace before destruction")
				end

				if self.DataObserver then
					self.DataObserver()
					self.DataObserver = nil
				end
			elseif self.DataObserver then
				self.DataObserver()
				self.DataObserver = nil
			end
		end, true)
	else
		warn("CrackBlocker: Instance is nil or not in Workspace during Construct")
	end
end

function v:Stop()
	if self.DataObserver then
		self.DataObserver()
		self.DataObserver = nil
	end

	if self.Instance and self.Instance:IsDescendantOf(Workspace) then
		self.Instance:Destroy()
	end
end

return v