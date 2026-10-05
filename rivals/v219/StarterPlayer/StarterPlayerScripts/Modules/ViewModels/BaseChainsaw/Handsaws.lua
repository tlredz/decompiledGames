local Players = game:GetService("Players")
local BaseChainsaw = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels:WaitForChild("BaseChainsaw"))
local object = setmetatable({}, BaseChainsaw)
object.__index = object

function object.new(...)
	local self = setmetatable(BaseChainsaw.new(...), object)
	self:_Init()
	return self
end

function object:_Init()
	self:_RegisterBlade(self.ItemModel:WaitForChild("RightBlade"):WaitForChild("Blade"))
	self:_RegisterBlade(self.ItemModel:WaitForChild("LeftBlade"):WaitForChild("Blade"))
	self:_RegisterSpikesPart(self.ItemModel:WaitForChild("RightBlade"):WaitForChild("Spikes1"), true)
	self:_RegisterSpikesPart(self.ItemModel:WaitForChild("RightBlade"):WaitForChild("Spikes2"), false)
	self:_RegisterSpikesPart(self.ItemModel:WaitForChild("LeftBlade"):WaitForChild("Spikes1"), false)
	self:_RegisterSpikesPart(self.ItemModel:WaitForChild("LeftBlade"):WaitForChild("Spikes2"), true)
end

return object