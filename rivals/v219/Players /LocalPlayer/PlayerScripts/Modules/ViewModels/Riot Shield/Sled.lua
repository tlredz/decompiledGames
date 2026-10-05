local Players = game:GetService("Players")
local RiotShield = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ViewModels"):WaitForChild("Riot Shield"))
local object = setmetatable({}, RiotShield)
object.__index = object

function object.new(...)
	local self = setmetatable(RiotShield.new(...), object)
	self:_Init()
	return self
end

function object:_Init() end

return object