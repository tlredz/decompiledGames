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
		0.5 + 0.25 * math.random(),
		0.9 + 0.2 * math.random(),
		p,
		true,
		10
	)
	Utility:CreateSound(
		"rbxassetid://129922197154277",
		0.5 + 0.25 * math.random(),
		0.9 + 0.2 * math.random(),
		p,
		true,
		10
	)
	Utility:CreateSound("rbxassetid://10730819", 2 + 0.25 * math.random(), 0.9 + 0.2 * math.random(), p, true, 10)
end

function object:_Init() end

return object