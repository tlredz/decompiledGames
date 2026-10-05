local TweenService = game:GetService("TweenService")
local React = require(game.ReplicatedStorage.Packages.React)
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local v = {
	Volume = 0.02,
	PlaybackSpeed = 1,
	SoundId = "rbxassetid://121979626315274",
	Looped = true
}
local createElement = React.createElement

function backgroundSound(p)
	local ref = React.useRef(nil)
	React.useEffect(function()
		local v2 = nil

		if ref.current then
			if p.IsEnabled and not ref.current.IsPlaying then
				ref.current:Play()
			elseif not p.IsEnabled and ref.current.IsPlaying then
				v2 = TweenService:Create(ref.current, tweenInfo, {
					Volume = 0
				})
				v2:Play()
			end
		end

		return function()
			if v2 then
				v2:Destroy()
			end
		end
	end, { ref.current, p.IsEnabled })
	return createElement("Sound", {
		ref = ref,
		Looped = p.SoundSettings.Looped,
		SoundId = p.SoundSettings.SoundId,
		Volume = p.SoundSettings.Volume,
		PlaybackSpeed = p.SoundSettings.PlaybackSpeed,
		RollOffMode = Enum.RollOffMode.Inverse
	})
end

return function(p)
	return createElement(backgroundSound, {
		IsEnabled = p.IsEnabled,
		SoundSettings = React.useMemo(function()
			local result = {}

			for k, v2 in pairs(v) do
				if p.SoundSettings and p.SoundSettings[k] ~= nil then
					v2 = p.SoundSettings[k]
				end

				result[k] = v2
			end

			return result
		end, { p.SoundSettings })
	})
end