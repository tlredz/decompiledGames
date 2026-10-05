local AudioPolicy = {}

function AudioPolicy.music(p, p2)
	if p2 == "Lobby" or p == "Lobby" or p == "Countdown" then
		return "LobbyMusic"
	end

	return "MatchMusic"
end

function AudioPolicy.surface(p, instance, p2)
	if not instance then
		return p2.Materials[p.Name] or p2.DefaultSurface
	end

	local audioSurface = instance:GetAttribute("AudioSurface")

	if type(audioSurface) == "string" and audioSurface ~= "" then
		return audioSurface
	end

	if instance.Name == "Grass" then
		return "Grass"
	end

	return p2.Materials[p.Name] or p2.DefaultSurface
end

function AudioPolicy.crossed(p, p2, items)
	if p == nil then
		return false
	end

	for _, item in items do
		if p <= p2 then
			if p < item and item <= p2 then
				return true
			end
		elseif p < item or item <= p2 then
			return true
		end
	end

	return false
end

return AudioPolicy