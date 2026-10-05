local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local ServerOsTime = require(ReplicatedStorage.Modules.ServerOsTime)
local DuelLibrary = require(ReplicatedStorage.Modules.DuelLibrary)
local Signal = require(ReplicatedStorage.Modules.Signal)
local VoteBanFrame = require(Players.LocalPlayer.PlayerScripts.Modules.VoteBanFrame)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules.ButtonEffect)
local voterSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("VoterSlot")
local mapSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("MapSlot")
local v = {
	ReleaseRatio = 1.025,
	HoverRatio = 1.025
}
local MapSlot = {}
MapSlot.__index = MapSlot

function MapSlot.new(name, ignore_button_effect)
	local self = setmetatable({}, MapSlot)
	self.CreateSound = Signal.new()
	self.Name = name
	self.Frame = mapSlot:Clone()
	self.VoteBanFrame = VoteBanFrame.new(self.Frame.Button)
	self._ignore_button_effect = ignore_button_effect
	self._voter_slots = {}
	self._is_banned = false
	self._tag_background = self.Frame.Button.Tag.Background
	self._tag_title = self.Frame.Button.Tag.Title
	self:_Init()
	return self
end

function MapSlot.SetParent(p, parent)
	p.Frame.Parent = parent
end

function MapSlot:UpdateVotes(p, p2, options, p3, p4, p5)
	local v2 = {}

	for _, v3 in pairs(options or {}) do
		v2[tostring(v3)] = true

		if self._voter_slots[tostring(v3)] then
			continue
		end

		local clone = voterSlot:Clone()
		clone.Headshot.Image = string.format(CONSTANTS.HEADSHOT_IMAGE, v3)
		clone.Background.ImageColor3 = DuelLibrary:GetTeamColor(p3[tostring(v3)])
		clone.Parent = self.Frame.Button.Votes
		self._voter_slots[tostring(v3)] = clone
	end

	local v3 = {}

	for k, _voter_slot in pairs(self._voter_slots) do
		if v2[k] then
			continue
		end

		v3[k] = true
		_voter_slot:Destroy()
	end

	for k in pairs(v3) do
		self._voter_slots[k] = nil
	end

	self.Frame.Button.Votes.Visible = p ~= nil
	self.Frame.Button.Title.Text = self.Name .. ((p5 ~= "Chance" or not (p and p > 0)) and "" or " [" .. math.floor(p / p2 * 100) .. "%]")
	self.Frame.Button.Title.TextColor3 = p4 and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
	self.Frame.Button.Background.ImageColor3 = p4 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0)
	self.Frame.Button.Votes.Chance.Visible = false
end

function MapSlot:Destroy()
	self.CreateSound:Destroy()
	self.VoteBanFrame:Destroy()
	self.Frame:Destroy()
end

function MapSlot:_Update()
	self._tag_background.Size = UDim2.new(0.5, self._tag_title.TextBounds.X, 1, 0)
end

function MapSlot:_Setup()
	local visible = self.Name == "Random"
	local map = DuelLibrary.Maps[self.Name]
	local image = visible and "" or map.Image
	local mapDifficulty = DuelLibrary.MapDifficulties[visible and "None" or map.Difficulty]
	local visible2 = not visible and ServerOsTime:Get() < map.ReleaseTime + DuelLibrary.NEW_MAP_RELEASE_DURATION and "tag_newrelease" or map and map.MapTag
	local mapTag = DuelLibrary.MapTags[visible2]
	self.Frame.Button.Picture.Image = image
	self.Frame.Button.Random.Visible = visible
	self.Frame.Button.Background.Texture.ImageColor3 = mapDifficulty.Color
	self.Frame.Button.Difficulty.BackgroundColor3 = mapDifficulty.Color
	self.Frame.Button.Difficulty.UIStroke.Color = mapDifficulty.Color
	self.Frame.Button.DifficultyVignette.ImageColor3 = mapDifficulty.Color
	self.Frame.Button.DifficultyVignette.ImageTransparency = mapDifficulty.Value >= DuelLibrary.MapDifficulties.Hard.Value and 0 or 0.5
	self.Frame.Button.Tag.Visible = visible2
	self._tag_title.Text = not mapTag and "" or mapTag.DisplayName or ""
	self._tag_title.TextColor3 = mapTag and mapTag.SecondaryColor or Color3.fromRGB(255, 255, 255)
	self._tag_background.ImageColor3 = mapTag and mapTag.Color or Color3.fromRGB(0, 0, 0)

	if not self._ignore_button_effect then
		ButtonEffect:Add(self.Frame.Button, nil, v)
	end
end

function MapSlot:_Init()
	self.VoteBanFrame.CreateSound:Connect(function(...)
		self.CreateSound:Fire(...)
	end)
	self._tag_title:GetPropertyChangedSignal("TextBounds"):Connect(function()
		self:_Update()
	end)
	self:_Setup()
	self:_Update()
	self:UpdateVotes()
end

return MapSlot