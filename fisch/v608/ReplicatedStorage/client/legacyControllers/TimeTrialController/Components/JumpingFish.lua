local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
game:GetService("Debris")
game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local GliderController = require(ReplicatedStorage.client.legacyControllers.Items.GliderController)
local v = Component.new({
	Tag = "TimeTrial/JumpingFish",
	Ancestors = { Workspace },
	Extensions = nil
})

function v:Construct()
	self.Trove = Trove.new()
end

function v:UpdatePositions(p)
	if localPlayer.GameplayPaused then
		return
	end

	local all = v:GetAll()

	for _, v2 in all do
		if not v2.Active then
			continue
		end

		v2:CheckShouldJump()

		if v2.IsJumping then
			v2.Instance:PivotTo(v2:GetPosition(p))
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function arc(p)
	return 1 - math.pow(2 * p - 1, 2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function outInSemiCubic(p)
	return (math.lerp(p, (math.pow(2 * p - 1, 3) + 1) / 2, 0.5))
end

function v:GetPosition(p)
	local v2 = self.RootCFrame.Position.Y - 100
	self.CurrentJumpTime += p

	if self.CurrentJumpTime > self.TotalJumpTime then
		self.IsJumping = false
		self:SetVisible(false)
		return self.RootCFrame
	else
		local v4 = outInSemiCubic(self.CurrentJumpTime / self.TotalJumpTime) -- equivalent call inferred; original call site unknown
		local v5 = math.lerp(-v2, v2, v4)
		local v6 = (arc(v4) - 1) * v2
		local v7 = math.lerp(-v2, v2, v4 + 0.01)
		local v8 = (arc(v4 + 0.01) - 1) * v2
		local v9 = self.RootCFrame * CFrame.new(0, v6, -v5)
		local v10 = self.RootCFrame * CFrame.new(0, v8, -v7)
		return CFrame.lookAt(v9.Position, v10.Position)
	end
end

function v:Jump()
	self.IsJumping = true
	self.CanJump = false
	self.CurrentJumpTime = 0
	self.TotalJumpTime = self.Instance:GetAttribute("AnimTime")
	self:SetVisible(true)
	task.delay(self.Instance:GetAttribute("AnimTime") + self.Instance:GetAttribute("TriggerCooldown"), function()
		self.CanJump = true
	end)
end

function v:CheckShouldJump()
	if self.IsJumping or not (self.CanJump and localPlayer.Character and localPlayer.Character.PrimaryPart) then
		return
	end

	if localPlayer:DistanceFromCharacter(self.Instance:GetPivot().Position) < self.Instance:GetAttribute("TriggerRange") then
		self:Jump()
	end
end

local v2 = false

function v:OnTouched(object)
	if not self.Active or not self.IsJumping or v2 then
		return
	end

	v2 = true

	if localPlayer.Character and object.Parent == localPlayer.Character then
		local humanoid = object.Parent:FindFirstChildWhichIsA("Humanoid")

		if humanoid and object.Parent:FindFirstChildWhichIsA("Tool") then
			GliderController:UnequipGlider()
			object.Parent:SetAttribute("GetSmackedByAFishIdiot", 0)
			task.wait()
			humanoid:ChangeState(Enum.HumanoidStateType.Physics)
			object:ApplyImpulse(self.Instance:GetPivot().LookVector * object.AssemblyMass * 250)
			object:ApplyAngularImpulse(Random.new():NextUnitVector() * 100)
			task.wait(2)
			object.Parent:SetAttribute("GetSmackedByAFishIdiot", nil)
			humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
	end

	v2 = false
end

function v:SetVisible(p2)
	for _, descendant in self.Instance:GetDescendants() do
		if not (descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam") or descendant:IsA("Fire") or descendant:IsA("Smoke") or descendant:IsA("Sparkles") or descendant:IsA("Explosion")) then
			continue
		end

		descendant.LocalTransparencyModifier = p2 and 0 or 1
	end
end

function v:Start()
	if not self.Instance then
		return
	end

	if not self.RootCFrame then
		self.RootCFrame = self.Instance:GetPivot()
	end

	self.Active = true
	self.CanJump = true
	self:SetVisible(false)
	self.Trove:Connect(self.Instance:WaitForChild("Hitbox").Touched, function(p)
		self:OnTouched(p)
	end)
end

function v:Stop()
	self.Active = false
	self.Trove:Clean()
end

RunService.Stepped:Connect(function(_, dt)
	v:UpdatePositions(dt)
end)
return v