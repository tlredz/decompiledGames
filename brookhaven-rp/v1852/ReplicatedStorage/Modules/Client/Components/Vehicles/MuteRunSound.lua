local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "MuteRunSound"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local parent = self.Instance.Parent
	local running = nil

	if parent then
		if parent.Name == "Workspace" then
			local playerObject = self.Instance:WaitForChild("PlayerObject", 10)

			if playerObject then
				local value = playerObject.Value

				if not value then
					return
				end

				local character = value.Character

				if not character then
					return
				end

				running = character.PrimaryPart:FindFirstChild("Running")
			end
		else
			running = parent.PrimaryPart:FindFirstChild("Running")
		end

		if running then
			running.Volume = 0
			self._Janitor:Add(function()
				running.Volume = 0.65
			end)
		end
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v