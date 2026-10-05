local Players = game:GetService("Players")
local Fists = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Fists)
local object = setmetatable({}, Fists)
object.__index = object

function object.new(...)
	local self = setmetatable(Fists.new(...), object)
	self:_Init()
	return self
end

function object.PlayHitmarkerSound(object2, p, p2)
	if p then
		Fists.PlayHitmarkerSound(object2, p, p2)
	else
		object2:_CreateHitmarkerSound(
			"rbxassetid://88497957004619",
			1.5 / p2,
			0.75 + 0.25 * math.random(),
			script,
			true,
			1
		)
	end
end

function object:_Init() end

return object