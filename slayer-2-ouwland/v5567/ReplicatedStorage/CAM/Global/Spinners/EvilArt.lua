local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DemonArts = require(ReplicatedStorage.CAM.Global.Powers.DemonArts)
local parentModule = require(script.Parent)
local pool = {}

for k in pairs(DemonArts) do
	pool[k] = 1
end

return parentModule.new({
	Nothing = 0.5,
	Cost = 3,
	Pool = pool
})