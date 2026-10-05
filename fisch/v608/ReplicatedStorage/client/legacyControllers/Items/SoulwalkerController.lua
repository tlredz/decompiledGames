local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Trove = require(ReplicatedStorage.packages.Trove)
local module = require("./GliderController")
local module2 = require("../DataController")
local playerDataReplicator = module2.PlayerDataReplicator
local trove = Trove.new()
local v2 = {
	[Enum.HumanoidStateType.Landed] = true,
	[Enum.HumanoidStateType.Running] = true,
	[Enum.HumanoidStateType.RunningNoPhysics] = true,
	[Enum.HumanoidStateType.StrafingNoPhysics] = true
}
local v3 = {
	[Enum.HumanoidStateType.Jumping] = true,
	[Enum.HumanoidStateType.Landed] = true,
	[Enum.HumanoidStateType.Running] = true,
	[Enum.HumanoidStateType.GettingUp] = true,
	[Enum.HumanoidStateType.RunningNoPhysics] = true,
	[Enum.HumanoidStateType.Freefall] = true,
	[Enum.HumanoidStateType.FallingDown] = true,
	[Enum.HumanoidStateType.StrafingNoPhysics] = true
}
local SoulwalkerController = {
	Trove = trove,
	CurrentSpeed = 0,
	Active = false,
	CurrentCharacter = nil,
	CurrentHumanoid = nil,
	CurrentRoot = nil,
	RunAnim = nil,
	IsVisible = true,
	Reset = function(self)
		self.CurrentSpeed = 0

		if self.CurrentCharacter then
			self.CurrentCharacter:SetAttribute("SoulwalkerSpeed", self.CurrentSpeed)
		end

		if self.RunAnim and self.RunAnim.IsPlaying then
			self.RunAnim:Stop()
		end
	end,
	Tick = function(self, p: number)
		if not (self.Active and self.CurrentCharacter and self.CurrentHumanoid and self.CurrentRoot and self.RunAnim) then
			self:Reset()
			return
		end

		if module.GlidingSince then
			self:Reset()
			return
		end

		if (self.CurrentRoot.AssemblyLinearVelocity * createVector(1, 0, 1)).Magnitude < 0.1 then
			self:Reset()
			return
		end

		local state = self.CurrentHumanoid:GetState()

		if not v3[state] then
			self:Reset()
		elseif v2[state] then
			if (self.CurrentHumanoid.MoveDirection * createVector(1, 0, 1)).Magnitude < 0.1 then
				self:Reset()
				return
			end

			if self.RunAnim.IsPlaying or not self.IsVisible then
				if self.RunAnim.IsPlaying and not self.IsVisible then
					self.RunAnim:Stop()
				end
			else
				self.RunAnim:Play()
			end

			self.CurrentSpeed = math.clamp(self.CurrentSpeed + p * 12.444444444444445, 0, 28)
			self.CurrentCharacter:SetAttribute("SoulwalkerSpeed", self.CurrentSpeed)
			self.RunAnim:AdjustSpeed(self.CurrentHumanoid.WalkSpeed / 16)
		elseif self.RunAnim.IsPlaying then
			self.RunAnim:Stop()
		end
	end,
	UpdateActive = function(self)
		self.Active = self.CurrentCharacter ~= nil and self.CurrentCharacter:GetAttribute("Soulwalker") == true

		if self.CurrentCharacter then
			self.CurrentCharacter:SetAttribute("SoulwalkerJump", self.Active and 1.5 or nil)
		end

		self:Reset()
	end,
	InitCharacter = function(self, currentCharacter)
		self.Trove:Clean()
		self.Trove:Add(function()
			self:Reset()
			self.CurrentCharacter = nil
			self.CurrentHumanoid = nil
			self.CurrentRoot = nil

			if self.RunAnim then
				self.RunAnim:Destroy()
				self.RunAnim = nil
			end
		end)
		self.CurrentCharacter = currentCharacter
		self.CurrentHumanoid = currentCharacter:WaitForChild("Humanoid")
		self.CurrentRoot = currentCharacter:WaitForChild("HumanoidRootPart")
		self.RunAnim = self.CurrentHumanoid:WaitForChild("Animator"):LoadAnimation(script.Animations.Run)
		self.Trove:Add(currentCharacter:GetAttributeChangedSignal("Soulwalker"):Connect(function()
			self:UpdateActive()
		end))
		self:UpdateActive()
	end
}

function SoulwalkerController.Start(_)
	RunService.Heartbeat:Connect(function(dt: number)
		SoulwalkerController:Tick(dt)
	end)
	localPlayer.CharacterAdded:Connect(function(character)
		SoulwalkerController:InitCharacter(character)
	end)

	if localPlayer.Character then
		SoulwalkerController:InitCharacter(localPlayer.Character)
	end

	playerDataReplicator:Observe({ "EquippedAccessories", "Soulwalker" }, function(p)
		SoulwalkerController.IsVisible = p == true

		if not p and SoulwalkerController.RunAnim and SoulwalkerController.RunAnim.IsPlaying then
			SoulwalkerController.RunAnim:Stop()
		end
	end)
end

return SoulwalkerController