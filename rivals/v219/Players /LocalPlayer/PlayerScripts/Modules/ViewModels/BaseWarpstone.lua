local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local ClientViewModel = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ClientReplicatedClasses"):WaitForChild("ClientFighter"):WaitForChild("ClientItem"):WaitForChild("ClientViewModel"))
local object = setmetatable({}, ClientViewModel)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientViewModel.new(...), object)
	self:_Init()
	return self
end

function object:_PlayWarpstoneSounds(...)
	local volumes = {}

	for _, v in pairs({ ... }) do
		volumes[v] = v.Volume
		v.Looped = true
	end

	Utility:RenderstepForLoop(0, 100, 2, function(p2)
		if self._destroyed then
			return true
		end

		local v = p2 / 100

		for k, v2 in pairs(volumes) do
			k.Volume = v2 * v
		end
	end)
end

function object:_Init() end

return object