game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "PlaySoundOnZoneEnter"
})
local ClientZoneEmitter = require(ReplicatedStorage.Modules.Client.Components.World.ClientZoneEmitter)

function v:Construct()
	self._Janitor = Janitor.new()
	self.debounceTimestamp = 0
	self.debounceDuration = 10
	self.holdsReference = false
end

function v:CheckDebounce()
	return tick() - self.debounceTimestamp >= self.debounceDuration
end

function v:GetReferenceCount()
	local zoneSoundReferenceCount = self.sound:GetAttribute("ZoneSoundReferenceCount")

	if typeof(zoneSoundReferenceCount) == "number" then
		return zoneSoundReferenceCount
	end

	return 0
end

function v:AcquireReference()
	local v2 = self:GetReferenceCount() + 1
	self.sound:SetAttribute("ZoneSoundReferenceCount", v2)
	self.holdsReference = true
	return v2
end

function v:ReleaseReference()
	local v2 = math.max(self:GetReferenceCount() - 1, 0)
	self.sound:SetAttribute("ZoneSoundReferenceCount", v2)
	self.holdsReference = false
	return v2
end

function v:CancelVolumeTween()
	local tween = TweenService:Create(self.sound, TweenInfo.new(0), {
		Volume = self.sound.Volume
	})
	tween:Play()
	tween:Cancel()
end

function v:PlaySound()
	if self.stopOnExit == true then
		if self.holdsReference or self:AcquireReference() > 1 then
			return
		end

		self:CancelVolumeTween()

		if self.fadeIn == nil then
			self.sound.Volume = self.origVolume
		else
			self.sound.Volume = 0
			TweenService:Create(
				self.sound,
				TweenInfo.new(self.fadeIn, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{
					Volume = self.origVolume
				}
			):Play()
		end

		if not self.sound.IsPlaying then
			self.sound:Play()
		end
	else
		if not self:CheckDebounce() then
			return
		end

		self.debounceTimestamp = tick()
		self.sound:Play()

		if self.fadeIn ~= nil then
			self:CancelVolumeTween()
			self.sound.Volume = 0
			TweenService:Create(
				self.sound,
				TweenInfo.new(self.fadeIn, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{
					Volume = self.origVolume
				}
			):Play()
		end
	end
end

function v:StopSound()
	if not self.holdsReference or self:ReleaseReference() > 0 then
		return
	end

	local v2 = (self.sound.TimeLength - self.sound.TimePosition) / self.sound.PlaybackSpeed

	if self.fadeOut == nil then
		self.sound:Stop()
		return
	end

	self:CancelVolumeTween()
	local tween = TweenService:Create(
		self.sound,
		TweenInfo.new(math.min(v2, self.fadeOut), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
		{
			Volume = 0
		}
	)
	tween.Completed:Once(function(p)
		if p == Enum.PlaybackState.Completed and self:GetReferenceCount() == 0 then
			self.sound:Stop()
		end
	end)
	tween:Play()
end

function v:Start()
	self.debounceDuration = self.Instance:GetAttribute("Debounce") or 0
	self.pitchVariance = self.Instance:GetAttribute("PitchVariance") or 0.2
	self.stopOnExit = self.Instance:GetAttribute("StopOnExit")
	self.fadeIn = self.Instance:GetAttribute("FadeIn")
	self.fadeOut = self.Instance:GetAttribute("FadeOut")
	self.sound = self.Instance:WaitForChild("ZoneSoundLink").Value

	if not self.sound then
		warn("No sound found for PlaySoundOnZoneEnter:", self.Instance)
		return
	end

	local zoneSoundBaseVolume = self.sound:GetAttribute("ZoneSoundBaseVolume")

	if typeof(zoneSoundBaseVolume) ~= "number" then
		zoneSoundBaseVolume = self.sound.Volume
		self.sound:SetAttribute("ZoneSoundBaseVolume", zoneSoundBaseVolume)
	end

	self.origVolume = zoneSoundBaseVolume
	local expect = ClientZoneEmitter:WaitForInstance(self.Instance):expect()
	self._Janitor:Add(expect.PlayerEntered:Connect(function()
		self:PlaySound()
	end))

	if self.stopOnExit then
		self._Janitor:Add(expect.PlayerLeft:Connect(function()
			self:StopSound()
		end))
	elseif self.fadeOut then
		error("StopOnExit is false and FadeOut is true, this is not a supported edge-case due to the nature of the two")
	end
end

function v:Stop()
	if self.holdsReference then
		self:StopSound()
	end

	self._Janitor:Destroy()
end

return v