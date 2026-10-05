local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local SeasonLibrary = require(ReplicatedStorage.Modules.SeasonLibrary)
local StaticViewModel = require(Players.LocalPlayer.PlayerScripts.Modules.StaticModel.StaticViewModel)
local LobbyElement = require(Players.LocalPlayer.PlayerScripts.Modules.LobbyElement)
local object = setmetatable({}, LobbyElement)
object.__index = object

function object._new(...)
	local self = setmetatable(LobbyElement.new(...), object)
	self:_Init()
	return self
end

function object:_ModelAdded(instance)
	local topPlayerRewardSkinName = SeasonLibrary.CurrentSeason.TopPlayerRewardSkinName
	local neonCone = instance:WaitForChild("NeonCone")
	neonCone.Transparency = not topPlayerRewardSkinName and 1 or instance:WaitForChild("NeonCone").Transparency
	local neon = instance:WaitForChild("Neon")
	local material

	if topPlayerRewardSkinName then
		material = Enum.Material.Neon
	else
		material = Enum.Material.SmoothPlastic
	end

	neon.Material = material

	if not topPlayerRewardSkinName then
		return
	end

	local v2 = StaticViewModel.new(topPlayerRewardSkinName)
	v2:ScaleTo(3.25)
	v2:PivotTo(instance:WaitForChild("Preview").CFrame)
	v2:SetParent(instance:WaitForChild("Preview"))
end

function object:_Init()
	CollectionService:GetInstanceAddedSignal("LobbyTopPlayerReward"):Connect(function(p)
		self:_ModelAdded(p)
	end)

	for _, v in pairs(CollectionService:GetTagged("LobbyTopPlayerReward")) do
		task.defer(self._ModelAdded, self, v)
	end
end

return object._new()