local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
require(script:FindFirstAncestor("Effects").Parent.Types)
local CreateTween = require(ReplicatedStorage.Packages.CreateTween)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Signal = require(ReplicatedStorage.Packages.Signal)
local _ = script.Name
local v = {
	Context = "Default",
	Color = Color3.fromRGB(99, 95, 98)
}
local v2 = v
local v3 = Signal.new()

local function update()
	local v4 = v
	local v5

	if ReplicatedStorage:GetAttribute("2026Event") then
		v5 = {
			Context = "2026",
			Color = Color3.fromRGB(82, 98, 136),
			TweenTime = 0
		}
	elseif ReplicatedStorage:GetAttribute("ConcertEvent") then
		v5 = {
			Context = "Concert",
			Color = Color3.fromRGB(17, 17, 17)
		}
	elseif ReplicatedStorage:GetAttribute("RapConcertEvent") then
		v5 = {
			Context = "RapConcert",
			Color = Color3.fromRGB(17, 17, 17)
		}
	elseif ReplicatedStorage:GetAttribute("JobJobJobSahurEvent") then
		v5 = {
			Context = "JobJobJobSahurEvent",
			Color = Color3.fromRGB(126, 108, 75)
		}
	elseif ReplicatedStorage:GetAttribute("DulDulDulEvent") then
		v5 = {
			Context = "DulDulDulEvent",
			Color = Color3.fromRGB(129, 124, 128)
		}
	elseif ReplicatedStorage:GetAttribute("AyMiGatitoEvent") then
		v5 = {
			Context = "AyMiGatitoEvent",
			Color = Color3.fromRGB(165, 115, 165)
		}
	elseif ReplicatedStorage:GetAttribute("MexicoEvent") then
		v5 = {
			Context = "MexicoEvent",
			Color = Color3.fromRGB(138, 81, 45)
		}
	elseif ReplicatedStorage:GetAttribute("SpainEvent") then
		v5 = {
			Context = "SpainEvent",
			Color = Color3.fromRGB(99, 82, 68)
		}
	elseif ReplicatedStorage:GetAttribute("IndonesiaEvent") then
		v5 = {
			Context = "IndonesiaEvent",
			Color = Color3.fromRGB(95, 44, 0)
		}
	elseif ReplicatedStorage:GetAttribute("MeowlEvent") then
		v5 = {
			Context = "MeowlEvent",
			Color = Color3.fromRGB(111, 71, 30)
		}
	elseif ReplicatedStorage:GetAttribute("ValentinesEvent") then
		v5 = {
			Context = "ValentinesEvent",
			Color = Color3.fromRGB(200, 0, 0)
		}
	elseif ReplicatedStorage:GetAttribute("TrickOrTreatEvent") then
		v5 = {
			Context = "TrickOrTreatEvent",
			Color = Color3.fromRGB(83, 56, 33)
		}
	elseif ReplicatedStorage:GetAttribute("GraveyardEvent") then
		v5 = {
			Context = "GraveyardEvent",
			Color = Color3.fromRGB(72, 63, 138)
		}
	elseif ReplicatedStorage:GetAttribute("GingerbreadTownEvent") then
		v5 = {
			Context = "GingerbreadTownEvent",
			Color = Color3.fromRGB(99, 42, 16),
			TweenTime = 0
		}
	elseif ReplicatedStorage:GetAttribute("WinterHourEvent") then
		v5 = {
			Context = "WinterHourEvent",
			Color = Color3.fromRGB(99, 42, 16),
			TweenTime = 0
		}
	elseif ReplicatedStorage:GetAttribute("EasterEvent") then
		v5 = {
			Context = "EasterEvent",
			Color = Color3.fromRGB(234, 173, 231),
			TweenTime = 0
		}
	elseif ReplicatedStorage:GetAttribute("WitchingHourEvent") then
		v5 = {
			Context = "WitchingHourEvent",
			Color = Color3.fromRGB(99, 95, 98),
			TweenTime = 0
		}
	elseif ReplicatedStorage:GetAttribute("YinYangEvent") then
		v5 = {
			Context = "YinYangEvent",
			Color = Color3.fromRGB(204, 204, 204),
			TweenTime = 0
		}
	elseif ReplicatedStorage:GetAttribute("RadioactiveEvent") then
		v5 = {
			Context = "RadioactiveEvent",
			Color = Color3.fromRGB(42, 42, 42),
			TweenTime = 0
		}
	elseif ReplicatedStorage:GetAttribute("CursedEvent") then
		v5 = {
			Context = "CursedEvent",
			Color = Color3.fromRGB(65, 0, 0),
			TweenTime = 0
		}
	elseif ReplicatedStorage:GetAttribute("DivineEvent") then
		v5 = {
			Context = "DivineEvent",
			Color = Color3.fromRGB(190, 136, 0),
			TweenTime = 0
		}
	elseif ReplicatedStorage:GetAttribute("PhantomEvent") then
		v5 = {
			Context = "PhantomEvent",
			Color = Color3.fromRGB(27, 42, 53),
			TweenTime = 0
		}
	elseif ReplicatedStorage:GetAttribute("EclipseEvent") then
		v5 = {
			Context = "EclipseEvent",
			Color = Color3.fromRGB(42, 34, 66),
			TweenTime = 0
		}
	elseif ReplicatedStorage:GetAttribute("CrystalEvent") then
		v5 = {
			Context = "CrystalEvent",
			Color = Color3.fromRGB(109, 115, 193),
			Material = Enum.Material.Plastic,
			MaterialVariant = "CrystalGridStudNoStripe",
			TweenTime = 0
		}
	elseif ReplicatedStorage:GetAttribute("CyberEvent") then
		v5 = {
			Context = "CyberEvent",
			Color = Color3.fromRGB(7, 15, 34),
			TweenTime = 0
		}
	elseif ReplicatedStorage:GetAttribute("EggCityEvent") then
		v5 = {
			Context = "EggCityEvent",
			Color = Color3.fromRGB(113, 65, 37),
			TweenTime = 0
		}
	elseif ReplicatedStorage:GetAttribute("LaserCityEvent") then
		v5 = {
			Context = "LaserCityEvent",
			Color = Color3.fromRGB(90, 95, 105),
			TweenTime = 0
		}
	elseif ReplicatedStorage:GetAttribute("SummerHourEvent") then
		v5 = {
			Context = "SummerHourEvent",
			Color = Color3.fromRGB(103, 81, 42)
		}
	else
		v5 = ReplicatedStorage:GetAttribute("SummerEvent") and {
			Context = "SummerEvent",
			Color = Color3.fromRGB(103, 81, 42)
		} or v4
	end

	if v2.Context == v5.Context then
		return
	end

	v2 = v5
	v3:Fire()
end

local WallBottomRecolor = {}

function WallBottomRecolor.OnStart(_)
	update()
end

function WallBottomRecolor.OnUpdate(_)
	update()
end

function WallBottomRecolor.OnLoad(_)
	Observers.observeTag("WallBottom", function(instance)
		local v4 = nil
		local material = instance.Material
		local materialVariant = instance.MaterialVariant

		local function runTween()
			if v4 then
				v4:Cancel()
			end

			instance.Material = v2.Material or material
			instance.MaterialVariant = v2.MaterialVariant or materialVariant
			local tweenInfo = TweenInfo.new(2)
			local color

			if type(v2.Color) == "table" then
				color = v2.Color[instance:GetAttribute("Side") or "Left"] or v2.Color.Left or select(2, next(v2))
			else
				color = v2.Color
			end

			v4 = CreateTween(instance, tweenInfo, {
				Color = color
			})
		end

		local connection = v3:Connect(runTween)
		task.spawn(runTween)
		return function()
			connection:Disconnect()
			v4:Cancel()
		end
	end, { workspace })
end

return WallBottomRecolor