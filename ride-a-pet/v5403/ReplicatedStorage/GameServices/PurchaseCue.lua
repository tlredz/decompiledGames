local SoundService = game:GetService("SoundService")

local function PlayNow()
	local SFX = SoundService:FindFirstChild("SFX")
	local bell = SFX and SFX:FindFirstChild("Bell")

	if not (bell and bell:IsA("Sound")) then
		return
	end

	if bell:HasTag("ComboSound") then
		bell:SetAttribute("Play", (tonumber(bell:GetAttribute("Play")) or 0) + 1)
	else
		bell:Play()
	end
end

return {
	Play = function()
		task.delay(0.35, PlayNow)
	end
}