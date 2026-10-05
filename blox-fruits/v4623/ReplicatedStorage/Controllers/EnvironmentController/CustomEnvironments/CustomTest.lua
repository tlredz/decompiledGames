local CustomTest = {}
CustomTest.__index = CustomTest

function CustomTest.new(environment)
	local object = setmetatable({
		fogEnabled = false,
		fogTween = nil,
		destroyed = false,
		environment = environment
	}, CustomTest)
	print("init", script.Name, environment.name)
	return object
end

function CustomTest:LocalPlayerEnteredEnvironment()
	print("localPlayerEntered")
	local TweenService = game:GetService("TweenService")
	self:UpdateFog(true, (TweenService:Create(game.Lighting.LightingLayers.KitsuneFog.Intensity, TweenInfo.new(1), {
		Value = 1
	})))
end

function CustomTest:LocalPlayerExitedEnvironment()
	print("localPlayerExited", self.destroyed)

	if self.destroyed then
		return
	end

	local TweenService = game:GetService("TweenService")
	self:UpdateFog(false, (TweenService:Create(game.Lighting.LightingLayers.KitsuneFog.Intensity, TweenInfo.new(1), {
		Value = 0
	})))
end

function CustomTest.Update(_) end

function CustomTest:UpdateFog(flag: boolean, fogTween)
	if self.fogTween then
		self.fogTween:Destroy()
		self.fogTween = nil
	end

	if flag and not self.fogEnabled then
		print("on")
		self.fogEnabled = true
		self.fogTween = fogTween
		self.fogTween:Play()
	elseif not flag and self.fogEnabled then
		print("off")
		self.fogEnabled = false
		self.fogTween = fogTween
		self.fogTween:Play()
	end

	if self.maid and self.fogTween then
		self.maid:Add(self.fogTween)
	end
end

function CustomTest:Start()
	if self.destroyedThread then
		task.cancel(self.destroyedThread)
		self.destroyedThread = nil
	end

	local Trove = require(game.ReplicatedStorage.Modules.Util.Trove)
	self.maid = Trove.new()
	self.maid:Add(function()
		self.destroyed = true
		self.maid = nil
		self.destroyedThread = task.delay(3, function()
			self.destroyedThread = nil
			local v = self
			local TweenService = game:GetService("TweenService")
			v.fogTween = TweenService:Create(game.Lighting.LightingLayers.KitsuneFog.Intensity, TweenInfo.new(1), {
				Value = 0
			})
			self:UpdateFog(false, self.fogTween)
		end)
		print("streamed out", script.Name, self.environment.name)
	end)
	print("streamed in", script.Name, self.environment.name)
end

function CustomTest.Stop(p)
	if p.maid then
		p.maid:Destroy()
	end
end

return CustomTest