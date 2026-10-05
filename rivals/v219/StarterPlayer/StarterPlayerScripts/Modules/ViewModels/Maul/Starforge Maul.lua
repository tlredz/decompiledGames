local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local Maul = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ViewModels"):WaitForChild("Maul"))
local object = setmetatable({}, Maul)
object.__index = object

function object.new(...)
	local self = setmetatable(Maul.new(...), object)
	self:_Init()
	return self
end

function object.SlamSoundEffect(_, p, _)
	Utility:CreateSound(
		"rbxassetid://72483809453170",
		0.75 + 0.25 * math.random(),
		0.9 + 0.2 * math.random(),
		p,
		true,
		10
	)
	Utility:CreateSound(
		"rbxassetid://129922197154277",
		0.75 + 0.25 * math.random(),
		0.9 + 0.2 * math.random(),
		p,
		true,
		10
	)
	Utility:CreateSound(
		"rbxassetid://122278439418848",
		1.25 + 0.125 * math.random(),
		0.9 + 0.2 * math.random(),
		p,
		true,
		10
	)
	Utility:CreateSound(
		"rbxassetid://118428196202943",
		1.25 + 0.125 * math.random(),
		0.95 + 0.1 * math.random(),
		p,
		true,
		10
	)
end

function object:_Init() end

return object