local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local OnlyRunOnPlayerHotbar = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.OnlyRunOnPlayerHotbar)
local v = Component.new({
	Tag = "WhackABunnyMalletTool",
	Extensions = { OnlyRunOnPlayerHotbar }
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._equipJanitor = Janitor.new()
	self.mouse = Players.LocalPlayer:GetMouse()
end

function v:StartListeningToUsage()
	self._equipJanitor:Cleanup()
end

function v:WHAM()
	if self.whamDebounce then
		return
	end

	self.whamDebounce = true
	local v2 = math.random(90, 110) / 100
	local v3 = 0.33 / v2
	self.whamAnim:Play(0.05, 1, v2)
	task.delay(self.whamAnim.Length, function()
		self.whamDebounce = false
	end)
	task.delay(v3, function()
		if not self.whamAnim.IsPlaying then
			return
		end

		for _, emitter in self.normalWhamVFX:GetDescendants() do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		local bopGroundSFX = self.handle:FindFirstChild("BopGroundSFX")

		if bopGroundSFX then
			bopGroundSFX.PlaybackSpeed = math.random(90, 110) / 100
			bopGroundSFX:Play()
		end
	end)
end

function v:Equipped()
	self.idleAnim:Play()
	self._equipJanitor:Add(self.mouse.Button1Down:Connect(function()
		self:WHAM()
	end))
end

function v:Unequipped()
	self.idleAnim:Stop()
	self._equipJanitor:Cleanup()
end

function v:Start()
	if self.Instance.Parent ~= Players.LocalPlayer.Character and self.Instance.Parent ~= Players.LocalPlayer.Backpack then
		return
	end

	local humanoid = Players.LocalPlayer.Character:FindFirstChild("Humanoid")
	local animator = humanoid and humanoid:FindFirstChild("Animator")

	if not animator then
		return
	end

	self.handle = self.Instance:WaitForChild("Handle")
	self.head = self.Instance:WaitForChild("Head")
	self.normalWhamVFX = self.head:WaitForChild("NormalWhamVFX")
	self.whamAnim = animator:LoadAnimation(self.Instance:WaitForChild("WHAM"))
	self.idleAnim = animator:LoadAnimation(self.Instance:WaitForChild("Idle"))
	ContentProvider:PreloadAsync({ self.Instance:WaitForChild("WHAM").AnimationId })
	self._Janitor:Add(self.Instance.Equipped:Connect(function()
		self:Equipped()
	end))
	self._Janitor:Add(self.Instance.Unequipped:Connect(function()
		self:Unequipped()
	end))

	if self.Instance.Parent == Players.LocalPlayer.Character then
		self:Equipped()
	end
end

function v:Stop()
	if self.idleAnim then
		self.idleAnim:Stop()
	end

	self._Janitor:Destroy()
	self._equipJanitor:Destroy()
end

return v