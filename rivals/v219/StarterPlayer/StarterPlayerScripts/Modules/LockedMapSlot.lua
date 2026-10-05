local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local DuelLibrary = require(ReplicatedStorage.Modules.DuelLibrary)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules.ButtonEffect)
local lockedMapSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("LockedMapSlot")
local v = {
	ReleaseRatio = 1.025,
	HoverRatio = 1.025
}
local LockedMapSlot = {}
LockedMapSlot.__index = LockedMapSlot

function LockedMapSlot.new(name, ignore_button_effect)
	local self = setmetatable({}, LockedMapSlot)
	self.Name = name
	self.Frame = lockedMapSlot:Clone()
	self._ignore_button_effect = ignore_button_effect
	self:_Init()
	return self
end

function LockedMapSlot.SetParent(p, parent)
	p.Frame.Parent = parent
end

function LockedMapSlot:Destroy()
	self.Frame:Destroy()
end

function LockedMapSlot:_Setup()
	local map = DuelLibrary.Maps[self.Name]
	local mapDifficulty = DuelLibrary.MapDifficulties[map.Difficulty]
	local _, _, v2 = mapDifficulty.Color:ToHSV()
	self.Frame.Button.Background.ImageColor3 = v2 < 0.1 and Color3.fromRGB(31, 31, 31) or Color3.fromRGB(0, 0, 0)
	self.Frame.Button.Background.Texture.ImageColor3 = mapDifficulty.Color
	self.Frame.Button.Difficulty.BackgroundColor3 = mapDifficulty.Color
	self.Frame.Button.Difficulty.ImageColor3 = mapDifficulty.Color
	self.Frame.Button.Difficulty.UIStroke.Color = mapDifficulty.Color
	self.Frame.Button.DifficultyVignette.ImageColor3 = mapDifficulty.Color

	if not self._ignore_button_effect then
		ButtonEffect:Add(self.Frame.Button, nil, v)
	end
end

function LockedMapSlot:_Init()
	self:_Setup()
end

return LockedMapSlot