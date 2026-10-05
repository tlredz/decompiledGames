local Players = game:GetService("Players")
local BaseChainsaw = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.BaseChainsaw)
local object = setmetatable({}, BaseChainsaw)
object.__index = object

function object.new(...)
	local self = setmetatable(BaseChainsaw.new(...), object)
	self:_Init()
	return self
end

function object:_Init()
	self:_RegisterBlade(self.ItemModel:WaitForChild("Body"):WaitForChild("Blade"))
	self:_RegisterSpikesPart(self.ItemModel:WaitForChild("Body"):WaitForChild("Spikes1"), true)
	self:_RegisterSpikesPart(self.ItemModel:WaitForChild("Body"):WaitForChild("Spikes2"), false)
end

return object