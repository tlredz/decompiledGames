local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local Replion = require(packages.Replion)
local v = Component.new({
	Tag = "BellonaWaraxeDoor",
	Ancestors = { Workspace }
})

function v:Construct()
	self.trove = Trove.new()
	local instance = self.Instance

	if not instance:IsA("Model") then
		return
	end

	self.model = instance
	self.primary = instance.PrimaryPart

	if not self.primary then
		return
	end

	self.closedCF = CFrame.new(-8434.23535, -2356.72461, 720.139221, -1, 0, 0, 0, 1, 0, 0, 0, -1)
	self.openCF = CFrame.new(-8434.23535, -2356.72461, 746.291931, -1, 0, 0, 0, 1, 0, 0, 0, -1)
	self.replion = Replion.Client:WaitReplion("BellonaRoyalGuards")
	self._opened = false
	self._tween = nil
end

function v:_apply()
	if not (self.replion and self.primary) then
		return
	end

	local royalGuards = self.replion:Get("RoyalGuards")

	if royalGuards then
		if royalGuards.Guard1 == true and royalGuards.Guard2 == true then
			royalGuards = royalGuards.Guard3 == true
		else
			royalGuards = false
		end
	end

	if royalGuards and not self._opened then
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

	local royalGuards = self.replion:Get("RoyalGuards")

	if royalGuards and royalGuards.Guard1 == true and royalGuards.Guard2 == true and royalGuards.Guard3 == true then
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