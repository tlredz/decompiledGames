local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "PlayAnimationOnEquip"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._animTrack = nil
end

function v:Start()
	self._Janitor:Add(self.Instance.Equipped:Connect(function()
		self:Equipped()
	end))
	self._Janitor:Add(self.Instance.Unequipped:Connect(function()
		self:Unequipped()
	end))
end

function v:Equipped()
	if self._animTrack then
		self._animTrack:Play()
		return
	end

	local animationName = self.Instance:GetAttribute("AnimationName") or "Idle"
	local child = self.Instance:FindFirstChild(animationName)

	if not child then
		warn("PlayAnimationOnEquip:Start() - Animation not found:", self.Instance)
		return
	end

	local humanoid = self.Instance.Parent:FindFirstChild("Humanoid")

	if not humanoid then
		warn("PlayAnimationOnEquip:Equipped() - Humanoid not found:", self.Instance)
		return
	end

	local animator = humanoid:FindFirstChild("Animator")

	if not animator then
		warn("PlayAnimationOnEquip:Equipped() - Animator not found:", self.Instance)
		return
	end

	self._animTrack = self._Janitor:Add(animator:LoadAnimation(child))
	local animPriority = self.Instance:GetAttribute("AnimPriority")

	if animPriority ~= nil then
		local priority = Enum.AnimationPriority[animPriority]

		if priority == nil then
			warn("PlayAnimationOnEquip:Equipped() - Invalid AnimPriority:", animPriority, self.Instance)
		else
			self._animTrack.Priority = priority
		end
	end

	self._animTrack:Play()
end

function v:Unequipped()
	if self._animTrack then
		self._animTrack:Stop()
		self._animTrack = nil
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v