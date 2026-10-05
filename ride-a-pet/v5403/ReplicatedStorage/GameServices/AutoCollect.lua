local Players = game:GetService("Players")
local AutoCollect = {}

function AutoCollect.Enabled(p)
	local v = p or Players.LocalPlayer

	if not v then
		return true
	end

	local autoCollectCash = v:GetAttribute("AutoCollectCash")
	return autoCollectCash == nil or autoCollectCash == true
end

function AutoCollect.Changed(p)
	return (p or Players.LocalPlayer):GetAttributeChangedSignal("AutoCollectCash")
end

return AutoCollect