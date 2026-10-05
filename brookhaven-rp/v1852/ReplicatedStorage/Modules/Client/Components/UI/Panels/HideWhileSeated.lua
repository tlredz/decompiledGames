local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "HideWhileSeated"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._seatJanitor = Janitor.new()
end

function v:Start()
	local localPlayer = Players.LocalPlayer
	localPlayer.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")
		self._seatJanitor:Cleanup()
		self._seatJanitor:Add(humanoid.Seated:Connect(function(p2)
			if p2 then
				self.Instance.Visible = false
			else
				self.Instance.Visible = true
			end
		end))
	end)

	if localPlayer.Character then
		local humanoid = localPlayer.Character:WaitForChild("Humanoid")
		self._seatJanitor:Add(humanoid.Seated:Connect(function(p2)
			if p2 then
				self.Instance.Visible = false
			else
				self.Instance.Visible = true
			end
		end))
	end
end

function v:Stop()
	self._Janitor:Destroy()
	self._seatJanitor:Destroy()
end

return v