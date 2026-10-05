local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "PlaySoundWhileMoving"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self.sound = self.Instance
	self.soundVolume = self.sound.Volume
	self.deltaTime = 0.1
	self._Janitor:Add(RunService.Heartbeat:Connect(function(dt)
		if self.deltaTime < 0.1 then
			self.deltaTime += dt
		else
			self.deltaTime = 0
			local parent = self.Instance.Parent

			if not parent then
				return
			end

			if parent.AssemblyLinearVelocity.Magnitude > 1 then
				self.sound.Volume = self.soundVolume
			else
				self.sound.Volume = 0
			end
		end
	end))
	task.wait(0.2)
	self.sound.Volume = self.soundVolume
	self.sound:Play()
end

function v:Stop()
	self._Janitor:Destroy()
end

return v