local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local TeleportService = game:GetService("TeleportService")
local Language = require(ReplicatedStorage.Modules.Language)
local Worlds = require(ReplicatedStorage.Assets.Data.Worlds)
local Modules = {
	Servers = {
		Neighborhood = "Neighborhood",
		Sandbox = "Sandbox",
		Night = "Night",
		Apartment = "Apartment"
	},
	GetCurrentWorldInfo = function(self)
		return Worlds.Neighborhood
	end,
	IsTestServer = function(_)
		return game.GameId == 4253037040
	end,
	IsAdultServer = function(_)
		return game.GameId == 4924789901
	end
}

function Modules.GetRealServerType(_)
	return Modules.Servers.Neighborhood
end

function Modules.GetServerType(_)
	return Modules.Servers.Neighborhood
end

function Modules.IsVCServer(_)
	local Places = require(ReplicatedStorage.Assets.Data.Worlds.Places)
	return game.PlaceId ~= Places.Places.NON_VC
end

function Modules.IsCustomServer(_)
	if workspace:GetAttribute("IsCustomServer") == nil then
		workspace:GetAttributeChangedSignal("IsCustomServer"):Wait()
	end

	return workspace:GetAttribute("IsCustomServer")
end

function Modules.IsOpenWorld(_)
	return false
end

function Modules.GetLightingType(_)
	return Enum.Technology.Future
end

function Modules.GetServerLocaleId(_)
	local Places = require(ReplicatedStorage.Assets.Data.Worlds.Places)

	for k, place in next, Places.Places, nil do
		if place == game.PlaceId then
			return Language:GetLocaleInfoFromName(k).Locale
		end
	end

	return "en"
end

function Modules:GetRootPlaceId()
	return Modules:GetCurrentWorldInfo().PlaceId
end

function Modules.GetWorldInfoFromPlaceId(_, _: number)
	return Modules:GetCurrentWorldInfo()
end

function Modules:GetWorldName()
	return Modules:GetCurrentWorldInfo().Name
end

function Modules:GetPlaceId(p: string, options)
	local Places = require(ReplicatedStorage.Assets.Data.Worlds.Places)
	local v = options or {}
	local world = Worlds[p]

	if v.IsNonVC and world.NonVoiceId then
		return world.NonVoiceId
	end

	if not v.Locale or world.GameId ~= game.GameId then
		return world.PlaceId
	end

	local localeInfo = Language:GetLocaleInfo(v.Locale)
	local v2 = localeInfo and Places.Places[localeInfo.Name]
	return v2 or world.PlaceId
end

if RunService:IsServer() then
	local Client = require(ServerStorage.Modules.Client)
	local Voice = require(ServerStorage.Modules.Voice)
	local Server = require(ReplicatedStorage.Modules.GameConfig.Server)

	function Modules.DidPlayerJoinFromOutsideGame(_, object)
		return object:GetJoinData().SourceGameId ~= game.GameId and game.PlaceId == Modules:GetRootPlaceId()
	end

	function Modules:GetBestPlaceId(p, _)
		Client:GetStats(p)
		local savedLanguage = Language:GetSavedLanguage(p) or Language:GetInternalLanguage(p)

		if not Server:GetPlayerValue(p, "EnableRegionalServers") then
			savedLanguage = nil
		end

		return (Modules:GetPlaceId(Modules:GetWorldName(), {
			IsNonVC = not Voice:DoesPlayerHaveVC(p),
			Locale = savedLanguage
		}))
	end

	function Modules.TeleportToBestServer(_, instance, data)
		local bestPlaceId = Modules:GetBestPlaceId(instance, data)

		if bestPlaceId == game.PlaceId then
			return true
		end

		print((`Sending {instance} to best server. Sending to: {bestPlaceId}`))
		instance:SetAttribute("ServerTeleport", true)

		if data.InitialJoin then
			instance:SetAttribute("DoNotLoadData", true)
		end

		if pcall(function()
			return TeleportService:Teleport(bestPlaceId, instance, {
				ShowMenuScreen = true
			})
		end) then
			return true
		end

		instance:SetAttribute("ServerTeleport", false)

		if data.KickOnFail then
			instance:Kick(data.KickMessage or "Please rejoin the game!")
			return false
		end

		if data.InitialJoin then
			instance:SetAttribute("DoNotLoadData", false)
		end

		return false
	end
end

task.spawn(function()
	require(ReplicatedStorage.Assets.Data.Worlds.Places)
end)
return Modules