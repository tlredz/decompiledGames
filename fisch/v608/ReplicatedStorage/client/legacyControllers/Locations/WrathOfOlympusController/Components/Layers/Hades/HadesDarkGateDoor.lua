local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local Replion = require(packages.Replion)
local v = Component.new({
	Tag = "HadesDarkGateDoor",
	Ancestors = { Workspace }
})

function v:Construct()
	self.trove = Trove.new()
	local instance = self.Instance

	if not instance:IsA("Model") then
		warn("[DarkGateDoor] Tag must be on a Model:", instance:GetFullName())
		return
	end

	self.model = instance
	self.primary = instance.PrimaryPart

	if not self.primary then
		warn("[DarkGateDoor] Missing PrimaryPart:", instance:GetFullName())
		return
	end

	local position = self.primary.Position
	self.closedCF = CFrame.new(position.X, -4160.30225, position.Z)
	self.openCF = CFrame.new(position.X, -4063.17065, position.Z)
	self.replion = Replion.Client:WaitReplion("HadesDarkGate")
	self._opened = false
	self._tween = nil
end

function v:_apply()
	if not (self.replion and self.primary) then
		return
	end

	if self.replion:Get("GateOpen") == true and not self._opened then
		self._opened = true

		if self._tween then
			self._tween:Cancel()
			self._tween:Destroy()
		end

		self._tween = TweenService:Create(
			self.primary,
			TweenInfo.new(4, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{
				CFrame = self.openCF
			}
		)
		self._tween:Play()
		self.primary.Door:Play()
		self.primary.Door2:Play()
		self.primary.Whisper:Play()
	end
end

function v:Start()
	if not self.replion then
		return
	end

	if self.replion:Get("GateOpen") == true then
		self._opened = true
		self.primary.CFrame = self.openCF
	end

	self.trove:Add(self.replion:OnDataChange(function()
		self:_apply()
	end))
end

function v:Stop()
	if self._tween then
		self._tween:Cancel()
		self._tween:Destroy()
		self._tween = nil
	end

	self.trove:Clean()
end

return v