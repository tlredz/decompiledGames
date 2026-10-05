local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local PropertyPermissions = require(ReplicatedStorage.Modules.Client.Components.Housing.PropertyPermissions)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local v = Component.new({
	Tag = "HouseLamp"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local A = self.Instance:WaitForChild("A")
	local ONOFF = self.Instance:WaitForChild("ONOFF")
	local B = self.Instance:WaitForChild("B")
	self.dbOnOff = false
	self.propertyPermissions = ComponentUtil.FindAndWaitForAncestorComponent(
		self.Instance,
		"PropertyPermissions",
		PropertyPermissions
	)
	ONOFF.ClickDetector.MouseClick:connect(function(player)
		if self.dbOnOff == false and self.propertyPermissions:HasAnyRole(player, "Owner", "Roommate") then
			self.dbOnOff = true
			task.delay(0.2, function()
				self.dbOnOff = false
			end)

			if player ~= nil and player.Character ~= nil and player.Character:FindFirstChild("UpperTorso") ~= nil then
				local upperTorso = player.Character:FindFirstChild("UpperTorso")
				local magnitude = (upperTorso.Position - ONOFF.Position).magnitude

				if upperTorso ~= nil and magnitude ~= nil and magnitude < 37 then
					if A.A.Enabled == false then
						A.A.Enabled = true
						B.Transparency = 0
					else
						A.A.Enabled = false
						B.Transparency = 0.9
					end
				end
			end
		elseif not self.propertyPermissions:HasAnyRole(player, "Owner", "Roommate") then
			NotificationController.NotifyCenter("You don't have permission to do that")
		end
	end)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v