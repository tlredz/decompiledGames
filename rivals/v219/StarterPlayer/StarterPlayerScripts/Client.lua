local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.EnumBuilder)
require(ReplicatedStorage.Modules.Utility)
local v = {
	"PlayerDataController",
	"ComplianceController",
	"FunctionsController",
	"UserInterfaceController",
	"MonetizationController",
	"EnemyController",
	"CameraController",
	"MechanicsController",
	"FighterController",
	"SpectateController",
	"TightropeController",
	"EntityController",
	"DuelController",
	"GameComponentsController",
	"ControlsController",
	"LeaderboardController",
	"LobbyController",
	"QueuePadController",
	"LightingController",
	"ShootingRangeController",
	"CoreGuiController",
	"MusicController",
	"MobileController",
	"ShopController",
	"ProximityPromptController",
	"PlayerInteractionController",
	"DebugController",
	"MatchmakingController",
	"ChattingController",
	"EventController",
	"PrivateServerController",
	"TestingController",
	"ShadyChickenController",
	"WrapController",
	"ScavengerHuntController",
	"SocialController",
	"FFlagController",
	"AudioController",
	"BirthdayController",
	"ArcadeController",
	"EmoteController",
	"SeasonController",
	"PartyController",
	"MiscellaneousController"
}
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self:_Init()
	return self
end

function class:LoadModule(childName)
	tick()
	local module = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild(childName))
	self[childName] = module
end

function class:_LoadModules()
	for _, v2 in pairs(v) do
		self:LoadModule(v2)
	end
end

function class:_Init()
	self:_LoadModules()
end

return class._new()