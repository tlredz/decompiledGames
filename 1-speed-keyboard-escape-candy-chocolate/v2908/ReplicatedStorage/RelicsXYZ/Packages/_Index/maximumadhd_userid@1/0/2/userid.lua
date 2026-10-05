local parent = script.Parent
local RunContext = require(parent.RunContext)
local StudioService

if RunContext.IsStudio then
	StudioService = game:GetService("StudioService")
else
	StudioService = nil
end

local Players = game:GetService("Players")

local function getUserId(playerByUserId, flag: boolean?)
	if typeof(playerByUserId) == "number" then
		playerByUserId = Players:GetPlayerByUserId(playerByUserId)
	end

	if RunContext.IsEdit and StudioService then
		local mockUserId = tonumber(StudioService:GetAttribute("MockUserId"))

		if flag then
			return StudioService:GetUserId(), false
		end

		return mockUserId or StudioService:GetUserId(), mockUserId ~= nil
	else
		if RunContext.IsClient and not playerByUserId then
			playerByUserId = Players.LocalPlayer
		end

		assert(playerByUserId, "Player must be provided on the server")
		local mockUserId = RunContext.IsStudio and not flag and tonumber(playerByUserId:GetAttribute("MockUserId"))

		if mockUserId then
			return mockUserId, true
		end

		local userId = playerByUserId.UserId

		if not (userId < 0) or flag then
			return userId, false
		end

		local characterAppearanceId = playerByUserId.CharacterAppearanceId

		if characterAppearanceId > 0 then
			return characterAppearanceId, true
		end

		return userId, false
	end
end

return table.freeze({
	Get = getUserId
})