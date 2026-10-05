local Config = {
	DASH_SPEED = 70,
	DASH_FORCE_DURATION = 0.165,
	DASH_DURATION = 0.48,
	DASH_FACTOR_SCALE = 0.5,
	AIR_DASH_FLAG_DURATION = 0.55,
	BLOCK_ESCAPE_IFRAME_DURATION = 0.125,
	AcceptedDashes = { "Sleepless Knight Mode", "Reaper" }
}
local v = {}

for _, acceptedDash in Config.AcceptedDashes do
	v[acceptedDash] = true
end

local Character_info_provider = require(game.ReplicatedStorage.CAM.Global.Character_info_provider)
local Utility = require(game.ReplicatedStorage.CAM.Global.Utility)

function Config.ResolveCustomDash(character, p: string?)
	local getvaluesfolder = Utility.getvaluesfolder(character)

	if getvaluesfolder ~= nil then
		for _, child in getvaluesfolder:GetChildren() do
			if v[child.Name] and child:GetAttribute("_ClanAura") == true then
				return child.Name
			end
		end
	end

	if character:IsA("Player") then
		for _, v2 in Character_info_provider.GetEquippedPowers(character) do
			if v[v2] then
				return v2
			end
		end

		character = character.Character
	end

	local clan

	if character ~= nil then
		clan = character:GetAttribute("Clan") or nil
	end

	if clan ~= nil and v[clan] then
		return clan
	end

	if p == nil or not v[p] then
		return nil
	end

	return p
end

return Config