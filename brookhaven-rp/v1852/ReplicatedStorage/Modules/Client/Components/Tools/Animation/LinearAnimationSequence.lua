local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local Signal = require(ReplicatedStorage.Packages.Signal)
local OnlyRunOnPlayerHotbar = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.OnlyRunOnPlayerHotbar)
local v = Component.new({
	Tag = "LinearAnimationSequence",
	Extensions = { OnlyRunOnPlayerHotbar }
})

function v:Construct()
	self._Janitor = Janitor.new()
	self.OnAnimationNumberUpdated = Signal.new()
	local animations = self.Instance:WaitForChild("Animations")

	if not animations then
		warn("LinearAnimationSequence:Construct() - Animations folder not found")
	end

	self.animations = {}
	self.count = 0

	local function loadAnimation(animation)
		if ContentProvider:GetAssetFetchStatus(animation.AnimationId) == Enum.AssetFetchStatus.None then
			task.spawn(ContentProvider.PreloadAsync, ContentProvider, { animation })
		end
	end

	for _, animation in animations:GetChildren() do
		if not animation:IsA("Animation") then
			continue
		end

		self.animations[animation.Name] = animation
		self.count += 1
		loadAnimation(animation)
		local animation2 = animation:FindFirstChildOfClass("Animation")

		if animation2 then
			loadAnimation(animation2)
		end
	end
end

function v.GetCurrentAnimation(p)
	return p.Instance:GetAttribute("CurrentAnimation")
end

function v.GetAllAnimations(p)
	return p.animations
end

function v.GetAnimationCount(p)
	return p.count
end

function v.CycleNextAnimation(p)
	Remotes.fireServerComponent(p.Instance, "CycleNextAnimation")
end

function v:_stopDefaultToolTrack()
	local localPlayer = Players.LocalPlayer

	if localPlayer == nil then
		return
	end

	local character = localPlayer.Character

	if not (character ~= nil and character:FindFirstChildOfClass("Tool") == nil) then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if humanoid == nil then
		return
	end

	local animator = humanoid:FindFirstChildOfClass("Animator")

	if animator == nil then
		return
	end

	for _, v2 in animator:GetPlayingAnimationTracks() do
		if v2.Name == "ToolNoneAnim" then
			v2:Stop(0.1)
		end
	end
end

function v:Start()
	self._Janitor:Add(self.Instance:GetAttributeChangedSignal("CurrentAnimation"):Connect(function()
		self.OnAnimationNumberUpdated:Fire(self.Instance:GetAttribute("CurrentAnimation"))
	end))
	self._Janitor:Add(self.Instance.Unequipped:Connect(function()
		task.defer(function()
			self:_stopDefaultToolTrack()
		end)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v