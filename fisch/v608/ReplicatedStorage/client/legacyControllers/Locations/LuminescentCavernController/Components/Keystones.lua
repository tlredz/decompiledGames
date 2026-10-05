local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local modules = ReplicatedStorage.shared.modules
local LuminescentCavern = require(modules.LuminescentCavern)
local module = require("../LocalDataState")
local module2 = require("../Utility")
local v = Component.new({
	Tag = LuminescentCavern.Enums.CollectionService.KeystoneSpawn,
	Ancestors = { Workspace }
})

function v:Construct()
	local UID = self.Instance:GetAttribute("UID")

	if UID then
		self.DataObserver = module:observe(function(p)
			if p and p.KeystoneData and p.KeystoneData.CollectedKeystones and self.Instance:IsDescendantOf(Workspace) and module2.IsKeystoneCollected(
				p,
				UID
			) then
				self.Instance:Destroy()

				if self.DataObserver then
					self.DataObserver()
					self.DataObserver = nil
				end
			end
		end, true)
	else
		warn("Keystone missing UID: ", self.Instance:GetFullName())
	end
end

function v:Stop()
	if self.DataObserver then
		self.DataObserver()
		self.DataObserver = nil
	end
end

return v