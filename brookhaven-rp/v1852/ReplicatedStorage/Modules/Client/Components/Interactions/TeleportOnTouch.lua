local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
local v = Component.new({
	Tag = "TeleportOnTouch"
})
v.OnTeleported = Signal.new()

function v:Construct()
	self._Janitor = Janitor.new()
	self._debounce = false
end

function v:Start()
	local value = self.Instance.Target.Value
	self.action = self.Instance:GetAttribute("Action")
	self.location = self.Instance:GetAttribute("Location")

	if value then
		self._Janitor:Add(self.Instance.Touched:Connect(function(otherPart)
			local character = Players.LocalPlayer.Character

			if not character or not otherPart:IsDescendantOf(character) or self._debounce or character:WaitForChild("Humanoid").Sit then
				return
			end

			self._debounce = true
			task.delay(0.3, function()
				self._debounce = false
			end)
			local currentCamera = workspace.CurrentCamera
			local cframe = currentCamera.CFrame:ToObjectSpace(character:GetPivot())
			character:PivotTo(value.CFrame)
			currentCamera.CFrame = value.CFrame * cframe:Inverse()

			if self.action and self.location then
				TelemetryController.SendClientInteraction("worldInteraction", {
					action = self.action,
					location = self.location
				})
			end

			v.OnTeleported:Fire(value.CFrame)
		end))
	else
		warn("TeleportOnTouch:Start() - No teleport part found")
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v