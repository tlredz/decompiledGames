local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local snowballParticles = Players.LocalPlayer.PlayerScripts.Assets.Misc.SnowballParticles
local snowballs = Players.LocalPlayer.PlayerScripts.Assets.Misc.Snowballs
local Snowball = {}
Snowball.__index = Snowball

function Snowball.new(clientFighterCharacter)
	local self = setmetatable({}, Snowball)
	self.ClientFighterCharacter = clientFighterCharacter
	self._grab_snowball_hash = 0
	self._grab_snowball_visual = nil
	self._grab_snowball_animation_start = Instance.new("Animation")
	self._grab_snowball_animation_idle = Instance.new("Animation")
	self._grab_snowball_animation_throw = Instance.new("Animation")
	self._grab_snowball_animation_track_start = nil
	self._grab_snowball_animation_track_idle = nil
	self:_Init()
	return self
end

function Snowball:ThrowSnowball(p)
	local isGrabbingSnowball = self.ClientFighterCharacter:Get("IsGrabbingSnowball")
	self.ClientFighterCharacter:SetReplicate("IsGrabbingSnowball", nil)
	self:_ThrowSnowball(p, isGrabbingSnowball)
end

function Snowball.Update(_, _, _) end

function Snowball:Destroy()
	self._grab_snowball_animation_start:Destroy()
	self._grab_snowball_animation_idle:Destroy()
	self._grab_snowball_animation_throw:Destroy()
	self:_ThrowSnowball(nil)
end

function Snowball:_GrabSnowball(p)
	self:_ThrowSnowball(nil)
	local rightHand = self.ClientFighterCharacter.Model:FindFirstChild("RightHand")

	if not rightHand then
		return
	end

	self._grab_snowball_hash += 1
	local _grab_snowball_hash = self._grab_snowball_hash
	local success, result = pcall(
		self.ClientFighterCharacter.Humanoid.LoadAnimation,
		self.ClientFighterCharacter.Humanoid,
		self._grab_snowball_animation_start
	)

	if success then
		self._grab_snowball_animation_track_start = result
		self._grab_snowball_animation_track_start:Play(0)
		self._grab_snowball_animation_track_start:AdjustSpeed(3)
		task.delay(0.5, function()
			if _grab_snowball_hash ~= self._grab_snowball_hash then
				return
			end

			local success2, result2 = pcall(
				self.ClientFighterCharacter.Humanoid.LoadAnimation,
				self.ClientFighterCharacter.Humanoid,
				self._grab_snowball_animation_idle
			)

			if success2 then
				self._grab_snowball_animation_track_idle = result2
				self._grab_snowball_animation_track_idle:Play()
			end
		end)
	end

	if not p then
		return
	end

	self._grab_snowball_visual = snowballs[p]:Clone()
	self._grab_snowball_visual.PrimaryPart = self._grab_snowball_visual.Primary
	self._grab_snowball_visual:PivotTo(rightHand.CFrame)
	self._grab_snowball_visual.Parent = rightHand
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = rightHand
	weldConstraint.Part1 = self._grab_snowball_visual.PrimaryPart
	weldConstraint.Parent = self._grab_snowball_visual
end

function Snowball:_ThrowSnowball(p, p2)
	self._grab_snowball_hash += 1

	if self._grab_snowball_visual then
		self._grab_snowball_visual:Destroy()
		self._grab_snowball_visual = nil
	end

	if self._grab_snowball_animation_track_start then
		self._grab_snowball_animation_track_start:Stop(0)
		self._grab_snowball_animation_track_start:Destroy()
		self._grab_snowball_animation_track_start = nil
	end

	if self._grab_snowball_animation_track_idle then
		self._grab_snowball_animation_track_idle:Stop(0)
		self._grab_snowball_animation_track_idle:Destroy()
		self._grab_snowball_animation_track_idle = nil
	end

	if not (p and p2) then
		return
	end

	local rightHand = self.ClientFighterCharacter.Model:FindFirstChild("RightHand")

	if not rightHand then
		return
	end

	task.spawn(function()
		local position = rightHand.Position
		local magnitude = (position - p).Magnitude
		local clone = snowballs[p2]:Clone()
		clone.PrimaryPart = clone.Primary
		clone:PivotTo(rightHand.CFrame)
		clone.Parent = workspace
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = rightHand
		weldConstraint.Part1 = clone.PrimaryPart
		weldConstraint.Parent = clone
		local success, result = pcall(
			self.ClientFighterCharacter.Humanoid.LoadAnimation,
			self.ClientFighterCharacter.Humanoid,
			self._grab_snowball_animation_throw
		)

		if success then
			result:Play()
			result:AdjustSpeed(1.25)
			BetterDebris:AddItem(result, 2)
			wait(0.32)
		end

		clone.PrimaryPart.Anchored = true
		weldConstraint.Part0 = nil
		local cframe = CFrame.Angles(
			math.random() * 3.141592653589793 * 2,
			math.random() * 3.141592653589793 * 2,
			math.random() * 3.141592653589793 * 2
		)
		Utility:RenderstepForLoop(0, 100, 225 / magnitude, function(p3)
			local v = p3 / 100
			local cframe2 = CFrame.new(position:Lerp(p, v))
			local v2 = position.Y + (p.Y - position.Y) * (math.sin(1.8849555921538759 * v) / 0.9510565162951536)
			local v3 = math.sin(3.141592653589793 * v) * 3
			clone:PivotTo(CFrame.new(cframe2.X, cframe2.Y + math.max(v3, (math.abs(cframe2.Y - v2))), cframe2.Z) * cframe)
		end)

		for _, part in pairs(clone:GetDescendants()) do
			if part:IsA("BasePart") then
				part.LocalTransparencyModifier = 1
			end
		end

		BetterDebris:AddItem(clone, 4)
		local clone2 = snowballParticles[p2].Attachment:Clone()
		clone2.Parent = clone.PrimaryPart
		Utility:PlayParticles(clone2)

		if p2 == "WaterBalloon" then
			Utility:CreateSound(
				"rbxassetid://122599219317279",
				0.4,
				0.9 + 0.2 * math.random(),
				clone.PrimaryPart,
				true,
				5
			)
		else
			Utility:CreateSound("rbxassetid://11800684590", 0.4, 0.9 + 0.2 * math.random(), clone.PrimaryPart, true, 5)
		end
	end)
end

function Snowball:_Setup()
	self._grab_snowball_animation_start.AnimationId = "rbxassetid://127148856297189"
	self._grab_snowball_animation_idle.AnimationId = "rbxassetid://120318438418071"
	self._grab_snowball_animation_throw.AnimationId = "rbxassetid://107298949913168"
end

function Snowball:_Init()
	self.ClientFighterCharacter:GetDataChangedSignal("IsGrabbingSnowball"):Connect(function()
		local isGrabbingSnowball = self.ClientFighterCharacter:Get("IsGrabbingSnowball")

		if not isGrabbingSnowball then
			return
		end

		self:_GrabSnowball(isGrabbingSnowball)
	end)
	self:_Setup()
end

return Snowball