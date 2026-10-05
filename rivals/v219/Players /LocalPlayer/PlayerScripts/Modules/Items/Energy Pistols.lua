local Players = game:GetService("Players")
local Gun = require(Players.LocalPlayer.PlayerScripts.Modules.ItemTypes.Gun)
local energyTracerEffect = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("EnergyTracerEffect")
local object = setmetatable({}, Gun)
object.__index = object

function object.new(...)
	local self = setmetatable(Gun.new(...), object)
	self:_Init()
	return self
end

function object._ImpactMarker(_, _) end

function object._Tracers(p, p2)
	return Gun._Tracers(p, p2, {
		PlayFlyBySound = function(_, _) end,
		Template = energyTracerEffect,
		InitCallback = function(folder, _)
			for _, beam in pairs(folder:GetDescendants()) do
				if beam:IsA("Beam") then
					beam.Width1 = 0
				end
			end
		end
	})
end

function object:_Init() end

return object