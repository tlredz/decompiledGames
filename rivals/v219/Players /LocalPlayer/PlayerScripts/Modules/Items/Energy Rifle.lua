local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local WrapController = require(Players.LocalPlayer.PlayerScripts.Controllers.WrapController)
local Gun = require(Players.LocalPlayer.PlayerScripts.Modules.ItemTypes.Gun)
local object = setmetatable({}, Gun)
object.__index = object

function object.new(...)
	local self = setmetatable(Gun.new(...), object)
	self:_Init()
	return self
end

function object._ImpactMarker(p, p2)
	local v = {
		Color = Color3.fromRGB(0, 0, 0),
		NoTween = true
	}
	return Gun._ImpactMarker(p, p2, v)
end

function object._Tracers(object2, p)
	local v = {}
	local v2 = {
		MaxLength = 1e999,
		MaxLengthFirstPerson = 1e999,
		NoDistanceDelay = true,
		PlayFlyBySound = function(p2, p3, p4)
			Utility:CreateSound("rbxassetid://14767954026", 1 * p3, 1.4 + 0.2 * math.random(), p2, true, 10, p4, p4)
			Utility:CreateSound(
				"rbxassetid://17640978498",
				0.15 * p3,
				1.25 + 0.25 * math.random(),
				p2,
				true,
				10,
				p4,
				p4
			)
		end,
		Template = object2.ViewModel:GetTracerTemplate(),
		InitCallback = function(folder, p2)
			for _, descendant in pairs(folder:GetDescendants()) do
				if descendant:IsA("Beam") then
					descendant.Width1 = p2 == 1 and 0 or descendant.Width1
					v[descendant] = {
						IsBeam = true,
						Width0 = descendant.Width0,
						Width1 = descendant.Width1
					}
				elseif descendant:IsA("Light") then
					v[descendant] = {
						IsLight = true,
						Brightness = descendant.Brightness
					}
				end
			end
		end,
		CustomUpdate = function(_, p2, p3, p4, worldPosition, worldPosition2)
			p3.WorldPosition = worldPosition
			p2.WorldPosition = worldPosition2
			local v3 = 1 - p4 ^ 3

			for k, v4 in pairs(v) do
				if v4.IsBeam then
					k.Width0 = v4.Width0 * v3
					k.Width1 = v4.Width1 * v3
				elseif v4.IsLight then
					k.Brightness = v4.Brightness * v3
				end
			end
		end,
		UpdateSpeed = 5
	}
	WrapController:ApplyWrap(WrapController:RecordOriginalWrapProperties(v2.Template), object2:GetWrap(), true)
	return Gun._Tracers(object2, p, v2)
end

function object:_Init() end

return object