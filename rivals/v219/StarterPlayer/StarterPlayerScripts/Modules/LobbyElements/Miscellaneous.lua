local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SeasonLibrary = require(ReplicatedStorage.Modules.SeasonLibrary)
local LobbyElement = require(Players.LocalPlayer.PlayerScripts.Modules.LobbyElement)
local object = setmetatable({}, LobbyElement)
object.__index = object

function object._new(...)
	local self = setmetatable(LobbyElement.new(...), object)
	self:_Init()
	return self
end

function object.Update(object2, _)
	local v = math.sin(tick() * 0.25) ^ 30 * 1
	local v2 = tick() * 0.1 % 6.283185307179586
	Vector3.new(0, v, 0)
	CFrame.Angles(0, v2, 0)
	local v3 = math.sin(tick() * 0.75) ^ 30 * 1
	local v4 = tick() * -0.2 % 6.283185307179586
	local vector = Vector3.new(0, v3, 0)
	local cframe = CFrame.Angles(0, v4, 0)

	for _, v5 in pairs(CollectionService:GetTagged("LobbyFloatingDisplay")) do
		if not v5:IsDescendantOf(workspace) then
			continue
		end

		local _GetOriginalPivot = object2:_GetOriginalPivot(v5)
		local v6

		if v5:GetAttribute("NoSpin") then
			v6 = CFrame.identity or cframe
		else
			v6 = cframe
		end

		v5:PivotTo(_GetOriginalPivot * v6 + vector)
	end

	for _, v5 in pairs(CollectionService:GetTagged("LobbyRing")) do
		local multiplier = v5:GetAttribute("Multiplier") or 1
		local isGlobalSpace = v5:GetAttribute("IsGlobalSpace") or false
		local _GetOriginalPivot = object2:_GetOriginalPivot(v5)
		local cframe2 = CFrame.Angles(0, tick() * 0.1 * multiplier % 6.283185307179586, 0)

		if isGlobalSpace then
			v5:PivotTo(CFrame.new(_GetOriginalPivot.Position) * cframe2 * _GetOriginalPivot.Rotation)
		else
			v5:PivotTo(_GetOriginalPivot * cframe2)
		end
	end

	for _, v5 in pairs(CollectionService:GetTagged("LobbyHologramGift")) do
		v5:PivotTo(object2:_GetOriginalPivot(v5) * cframe + vector)
	end

	for _, v5 in pairs(CollectionService:GetTagged("LobbyHologramMobile")) do
		v5.Earth:PivotTo(object2:_GetOriginalPivot(v5.Earth) * CFrame.Angles(0, tick() * 0.35 % 6.283185307179586, 0))
		v5.Phone:PivotTo(object2:_GetOriginalPivot(v5.Phone) + Vector3.new(0, math.sin(tick() * 0.75) * 0.75, 0))
		v5.Tablet:PivotTo(object2:_GetOriginalPivot(v5.Tablet) + Vector3.new(0, math.cos(tick() * 0.375), 0))
	end
end

function object:_UpdateSeasonTexts()
	for _, v in pairs(CollectionService:GetTagged("SeasonNameDisplay")) do
		v.Text = string.upper(SeasonLibrary.CurrentSeason.Name)
	end

	for _, v in pairs(CollectionService:GetTagged("SeasonVersionDisplay")) do
		v.Text = "SEASON " .. SeasonLibrary.CurrentSeason.Version
	end
end

function object:_Init()
	CollectionService:GetInstanceAddedSignal("SeasonNameDisplay"):Connect(function()
		self:_UpdateSeasonTexts()
	end)
	CollectionService:GetInstanceAddedSignal("SeasonVersionDisplay"):Connect(function()
		self:_UpdateSeasonTexts()
	end)
	self:_UpdateSeasonTexts()
end

return object._new()