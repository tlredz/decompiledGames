local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages:WaitForChild("Component"))
local Trove = require(packages:WaitForChild("Trove"))
local _ = Players.LocalPlayer
local v = Component.new({
	Tag = "BoatBooster",
	Ancestors = { workspace }
})
local BoatController = require(ReplicatedStorage.client.legacyControllers.BoatController)

function v:Construct()
	self.trove = Trove.new()
	self.Enabled = true
end

function v:Start()
	local primaryPart

	if self.Instance:IsA("Model") then
		primaryPart = self.Instance.PrimaryPart
	else
		primaryPart = self.Instance
	end

	if primaryPart then
		self.trove:Add(primaryPart.Touched:Connect(function(otherPart)
			if not self.Enabled then
				return
			end

			local componentFromChild = BoatController.Boat:GetComponentFromChild(otherPart)

			if componentFromChild and componentFromChild.IsOwn then
				self.Enabled = false
				BoatController.Physics:Boost(
					self.Instance:GetAttribute("BoostStrength"),
					self.Instance:GetAttribute("BoostTime")
				)
				task.wait(self.Instance:GetAttribute("BoostTime"))
				self.Enabled = true
			end
		end))
	else
		warn((`No hitbox part found for BoatBooster {self.Instance:GetFullName()}`))
	end
end

function v.Stop(p)
	p.trove:Clean()
end

return v