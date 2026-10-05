local PlayerLocalizationController = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("Packages")
local PlayerLocalizationConstants = require(ReplicatedStorage.Modules.Shared.Player.PlayerLocalizationConstants)
local Signal = require(packages.Signal)
local Remotes = require(packages.Remotes)
PlayerLocalizationController.CountryRegionChanged = Signal.new()
PlayerLocalizationController.CountryRegion = nil

function PlayerLocalizationController.GetCountryRegion()
	if PlayerLocalizationController.CountryRegion then
		return PlayerLocalizationController.CountryRegion
	end

	local v = Remotes.invokeServer(PlayerLocalizationConstants.RemoteEventGetCountryRegion)
	PlayerLocalizationController.SetCountryRegion(v)
	return PlayerLocalizationController.CountryRegion
end

function PlayerLocalizationController.SetCountryRegion(p: string)
	local v = false

	for _, v3 in PlayerLocalizationConstants.CountryRegion do
		if v3.Code ~= p then
			continue
		end

		v = true
		break
	end

	local countryRegion = not v and "OTHER" or p

	if countryRegion and countryRegion ~= PlayerLocalizationController.CountryRegion then
		PlayerLocalizationController.CountryRegion = countryRegion
		PlayerLocalizationController.CountryRegionChanged:Fire(countryRegion)
	end
end

function PlayerLocalizationController.FrameworkInit() end

function PlayerLocalizationController.FrameworkStart()
	Remotes.connect(PlayerLocalizationConstants.RemoteEventNotifyCountryChanged, function(p: string)
		PlayerLocalizationController.SetCountryRegion(p)
	end)
end

function PlayerLocalizationController.IsPlayerFromUS()
	return PlayerLocalizationController.GetCountryRegion() == "US"
end

return PlayerLocalizationController