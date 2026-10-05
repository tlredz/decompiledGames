local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local PreloadController = require(Players.LocalPlayer.PlayerScripts.Controllers.PreloadController)
local v = {
	idle = "rbxassetid://17702749856",
	run = "rbxassetid://17702824140",
	walk = "rbxassetid://17702824140",
	runBack = "rbxassetid://17703291282",
	walkBack = "rbxassetid://17703291282",
	runForwardLeft = "rbxassetid://17703649282",
	walkForwardLeft = "rbxassetid://17703649282",
	runBackwardLeft = "rbxassetid://17703612699",
	walkBackwardLeft = "rbxassetid://17703612699",
	runLeft = "rbxassetid://17703296049",
	runLeft2 = "rbxassetid://17703296049",
	walkLeft = "rbxassetid://17703296049",
	walkLeft2 = "rbxassetid://17703296049",
	runForwardRight = "rbxassetid://17703652486",
	walkForwardRight = "rbxassetid://17703652486",
	runBackwardRight = "rbxassetid://17703646109",
	walkBackwardRight = "rbxassetid://17703646109",
	runRight = "rbxassetid://17703299653",
	runRight2 = "rbxassetid://17703299653",
	walkRight = "rbxassetid://17703299653",
	walkRight2 = "rbxassetid://17703299653"
}
local v2 = {
	Start = {
		{ "SlidingStartForward", "LookVector", 1 },
		{ "SlidingStartRightward", "RightVector", 1 },
		{ "SlidingStartBackward", "LookVector", -1 },
		{ "SlidingStartLeftward", "RightVector", -1 }
	},
	Loop = {
		{ "SlidingLoopForward", "LookVector", 1 },
		{ "SlidingLoopRightward", "RightVector", 1 },
		{ "SlidingLoopBackward", "LookVector", -1 },
		{ "SlidingLoopLeftward", "RightVector", -1 }
	}
}
local Animations = {}
Animations.__index = Animations

function Animations.new(clientFighterCharacter)
	local self = setmetatable({}, Animations)
	self.ClientFighterCharacter = clientFighterCharacter
	self._original_humanoid_animations = {}
	self._sliding_animation_hash = 0
	self._sliding_animation_track = nil
	self:_Init()
	return self
end

function Animations:PlaySlidingAnimationAsync(p)
	self:StopSlidingAnimation()

	if not self.ClientFighterCharacter.ClientFighter.IsLocalPlayer then
		return
	end

	self._sliding_animation_hash += 1
	local _sliding_animation_hash = self._sliding_animation_hash
	local _GetSlidingAnimation = self:_GetSlidingAnimation("Start", p)
	local success, result = pcall(
		self.ClientFighterCharacter.Humanoid.LoadAnimation,
		self.ClientFighterCharacter.Humanoid,
		PreloadController:GetPreloadedAnimation(_GetSlidingAnimation and _GetSlidingAnimation[1])
	)

	if success then
		self._sliding_animation_track = result
		self._sliding_animation_track:Play()
		wait(0.4)
	end

	if _sliding_animation_hash ~= self._sliding_animation_hash then
		return
	end

	local v3 = nil

	while _sliding_animation_hash == self._sliding_animation_hash do
		local _GetSlidingAnimation2 = self:_GetSlidingAnimation("Loop", p)

		if _GetSlidingAnimation2 and _GetSlidingAnimation2[1] ~= v3 then
			v3 = _GetSlidingAnimation2[1]

			if self._sliding_animation_track then
				self._sliding_animation_track:Stop(0)
				self._sliding_animation_track:Destroy()
				self._sliding_animation_track = nil
			end

			local success2, result2 = pcall(
				self.ClientFighterCharacter.Humanoid.LoadAnimation,
				self.ClientFighterCharacter.Humanoid,
				PreloadController:GetPreloadedAnimation(v3)
			)

			if success2 then
				self._sliding_animation_track = result2
				self._sliding_animation_track:Play(0)
			end
		end

		RunService.RenderStepped:Wait()
	end
end

function Animations:StopSlidingAnimation()
	self._sliding_animation_hash += 1

	if self._sliding_animation_track then
		self._sliding_animation_track:Stop(0)
		self._sliding_animation_track = nil
	end
end

function Animations.Update(_, _, _) end

function Animations:Destroy()
	self:StopSlidingAnimation()
end

function Animations:_GetSlidingAnimation(p2, p3)
	local v3 = p3 * createVector(1, 0, 1)
	self.ClientFighterCharacter.ClientFighter:GetRotationCFrame()
	local v4 = 1e999
	local v5 = nil

	for _, v6 in pairs(v2[p2]) do
		local angleBetweenVectors = Utility:AngleBetweenVectors(
			v3,
			self.ClientFighterCharacter.ClientFighter:GetRotationCFrame()[v6[2]] * v6[3] * createVector(1, 0, 1)
		)

		if not (angleBetweenVectors < v4) then
			continue
		end

		v5 = v6
		v4 = angleBetweenVectors
	end

	return v5
end

function Animations:_UpdateHumanoidAnimations()
	if not (self.ClientFighterCharacter.ClientFighter.IsLocalPlayer and self.ClientFighterCharacter:IsInWorld()) then
		return
	end

	local animate = self.ClientFighterCharacter.Model:FindFirstChild("Animate")

	if not animate then
		return
	end

	local isCrouching = self.ClientFighterCharacter.ClientFighter:Get("IsCrouching")

	for childName, v3 in pairs(v) do
		local child = animate:FindFirstChild(childName)

		if not child then
			continue
		end

		local v4 = isCrouching and v3 or nil

		for _, child2 in pairs(child:GetChildren()) do
			self._original_humanoid_animations[child2] = self._original_humanoid_animations[child2] or child2.AnimationId
			child2.AnimationId = v4 or self._original_humanoid_animations[child2]
		end
	end

	if animate:FindFirstChild("Refresh") then
		animate.Refresh:Fire()
	end
end

function Animations:_Init()
	self.ClientFighterCharacter.EnteredWorld:Connect(function()
		self:_UpdateHumanoidAnimations()
	end)
	self.ClientFighterCharacter.Died:Connect(function()
		self:StopSlidingAnimation()
	end)
	self.ClientFighterCharacter:AddConnection(self.ClientFighterCharacter.ClientFighter:GetDataChangedSignal("IsCrouching"):Connect(function()
		self:_UpdateHumanoidAnimations()
	end))
	self:_UpdateHumanoidAnimations()
end

return Animations