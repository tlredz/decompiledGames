local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local Replion = require(packages.Replion)
local v = Component.new({
	Tag = "BellonaHelmetDoor",
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

	self.closedCF = CFrame.new(
		-8519.7666,
		-2345.46606,
		745.374023,
		0.0101856878,
		-0.195081323,
		-0.980734169,
		0.19442232,
		0.962454021,
		-0.18942593,
		0.980865002,
		-0.188747182,
		0.0477314182
	)
	self.openCF = CFrame.new(
		-8520.3252,
		-2356.12012,
		691.623901,
		0.0101856915,
		-0.195081323,
		-0.98073411,
		0.194422305,
		0.962454021,
		-0.189425915,
		0.980864942,
		-0.188747182,
		0.0477314107
	)
	self.replion = Replion.Client:WaitReplion("BellonaRoyalGuards")
	self._opened = false
	self._tween = nil
end

function v:_apply()
	if not (self.replion and self.primary) then
		return
	end

	if (self.replion:Get("SwordsPlaced") or 0) >= 5 and not self._opened then
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

	if (self.replion:Get("SwordsPlaced") or 0) >= 5 then
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