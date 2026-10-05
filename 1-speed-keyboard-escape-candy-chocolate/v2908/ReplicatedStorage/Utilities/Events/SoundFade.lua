local TweenService = game:GetService("TweenService")
local SoundFade = {}
SoundFade.__index = SoundFade

function SoundFade.new(sound, data)
	local object = setmetatable({}, SoundFade)
	object._sound = sound
	object._fadeIn = not data and 0.5 or data.fadeIn or 0.5
	object._fadeOut = not data and 1 or data.fadeOut or 1
	object._volume = data and data.volume or 0.8
	object._tween = nil
	sound:GetAttributeChangedSignal("AdminAbuseMuted"):Connect(function()
		if sound:GetAttribute("AdminAbuseMuted") == true and object._tween then
			object._tween:Cancel()
			object._tween = nil
		end
	end)
	return object
end

function SoundFade:fadeIn()
	if self._tween then
		self._tween:Cancel()
	end

	if self._sound:GetAttribute("AdminAbuseMuted") == true then
		self._sound:SetAttribute("AdminAbusePrevVolume", self._volume)
		return
	end

	local tweenInfo = TweenInfo.new(self._fadeIn, Enum.EasingStyle.Linear)
	self._tween = TweenService:Create(self._sound, tweenInfo, {
		Volume = self._volume
	})
	self._tween:Play()
end

function SoundFade:fadeOut(callback)
	if self._tween then
		self._tween:Cancel()
	end

	local tweenInfo = TweenInfo.new(self._fadeOut, Enum.EasingStyle.Linear)
	self._tween = TweenService:Create(self._sound, tweenInfo, {
		Volume = 0
	})
	self._tween:Play()

	if callback then
		self._tween.Completed:Once(function(p)
			if p == Enum.PlaybackState.Completed then
				callback()
			end
		end)
	end
end

function SoundFade:cancel()
	if self._tween then
		self._tween:Cancel()
		self._tween = nil
	end
end

return SoundFade