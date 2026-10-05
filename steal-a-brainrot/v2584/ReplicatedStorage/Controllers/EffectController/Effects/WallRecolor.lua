local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
require(script:FindFirstAncestor("Effects").Parent.Types)
local CreateTween = require(ReplicatedStorage.Packages.CreateTween)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Signal = require(ReplicatedStorage.Packages.Signal)
local _ = script.Name
local v = {
	Context = "Default",
	Color = Color3.fromRGB(106, 57, 9)
}
local v2 = v
local v3 = Signal.new()

local function update()
	local v4 = v
	local v5

	if ReplicatedStorage:GetAttribute("2026Event") then
		v5 = {
			Context = "2026",
			Color = Color3.fromRGB(65, 78, 108),
			TweenTime = 0
		}
	elseif ReplicatedStorage:GetAttribute("ConcertEvent") then
		v5 = {
			Context = "Concert",
			Color = Color3.fromRGB(46, 71, 89)
		}
	elseif ReplicatedStorage:GetAttribute("RapConcertEvent") then
		v5 = {
			Context = "RapConcert",
			Color = Color3.fromRGB(46, 71, 89)
		}
	elseif ReplicatedStorage:GetAttribute("AyMiGatitoEvent") then
		v5 = {
			Context = "AyMiGatitoEvent",
			Color = Color3.fromRGB(105, 120, 180)
		}
	elseif ReplicatedStorage:GetAttribute("MexicoEvent") then
		v5 = {
			Context = "MexicoEvent",
			Color = Color3.fromRGB(180, 91, 68)
		}
	elseif ReplicatedStorage:GetAttribute("SpainEvent") then
		v5 = {
			Context = "SpainEvent",
			Color = Color3.fromRGB(152, 111, 61)
		}
	elseif ReplicatedStorage:GetAttribute("IndonesiaEvent") then
		v5 = {
			Context = "IndonesiaEvent",
			Color = Color3.fromRGB(113, 61, 31)
		}
	elseif ReplicatedStorage:GetAttribute("JobJobJobSahurEvent") then
		v5 = {
			Context = "JobJobJobSahurEvent",
			Color = Color3.fromRGB(168, 145, 100)
		}
	elseif ReplicatedStorage:GetAttribute("DulDulDulEvent") then
		v5 = {
			Context = "DulDulDulEvent",
			Color = Color3.fromRGB(84, 81, 83)
		}
	elseif ReplicatedStorage:GetAttribute("ChicleteiraBicicleteiraEvent") then
		v5 = {
			Context = "ChicleteiraBicicleteiraEvent",
			Color = Color3.fromRGB(116, 85, 85)
		}
	elseif ReplicatedStorage:GetAttribute("MeowlEvent") then
		v5 = {
			Context = "MeowlEvent",
			Color = Color3.fromRGB(125, 93, 58)
		}
	elseif ReplicatedStorage:GetAttribute("ValentinesEvent") then
		v5 = {
			Context = "ValentinesEvent",
			Color = Color3.fromRGB(227, 100, 187)
		}
	elseif ReplicatedStorage:GetAttribute("TrickOrTreatEvent") then
		v5 = {
			Context = "TrickOrTreatEvent",
			Color = Color3.fromRGB(148, 71, 33)
		}
	elseif ReplicatedStorage:GetAttribute("GraveyardEvent") then
		v5 = {
			Context = "GraveyardEvent",
			Color = Color3.fromRGB(92, 94, 180)
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
			Color = Color3.fromRGB(108, 120, 136),
			TweenTime = 0
		}
	elseif ReplicatedStorage:GetAttribute("WitchingHourEvent") then
		v5 = {
			Context = "WitchingHourEvent",
			Color = Color3.fromRGB(68, 42, 77),
			TweenTime = 0
		}
	elseif ReplicatedStorage:GetAttribute("YinYangEvent") then
		v5 = {
			Context = "YinYangEvent",
			Color = Color3.fromRGB(0, 0, 0),
			TweenTime = 0
		}
	elseif ReplicatedStorage:GetAttribute("RadioactiveEvent") then
		v5 = {
			Context = "RadioactiveEvent",
			Color = Color3.fromRGB(128, 136, 117),
			TweenTime = 0
		}
	elseif ReplicatedStorage:GetAttribute("CursedEvent") then
		v5 = {
			Context = "CursedEvent",
			Color = Color3.fromRGB(143, 0, 0),
			TweenTime = 0
		}
	elseif ReplicatedStorage:GetAttribute("DivineEvent") then
		v5 = {
			Context = "DivineEvent",
			Color = Color3.fromRGB(157, 129, 108),
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
			Color = Color3.fromRGB(57, 49, 80),
			TweenTime = 0
		}
	elseif ReplicatedStorage:GetAttribute("CrystalEvent") then
		v5 = {
			Context = "CrystalEvent",
			Color = Color3.fromRGB(122, 127, 200),
			Material = Enum.Material.Plastic,
			MaterialVariant = "CrystalGridStudNoStripe",
			TweenTime = 0
		}
	elseif ReplicatedStorage:GetAttribute("CyberEvent") then
		v5 = {
			Context = "CyberEvent",
			Color = Color3.fromRGB(15, 33, 75),
			TweenTime = 0
		}
	elseif ReplicatedStorage:GetAttribute("GalaxyEvent") then
		v5 = {
			Context = "GalaxyEvent",
			Color = Color3.fromRGB(20, 57, 67)
		}
	elseif ReplicatedStorage:GetAttribute("EggCityEvent") then
		v5 = {
			Context = "EggCityEvent",
			Color = Color3.fromRGB(159, 91, 172),
			TweenTime = 0
		}
	elseif ReplicatedStorage:GetAttribute("LaserCityEvent") then
		v5 = {
			Context = "LaserCityEvent",
			Color = Color3.fromRGB(100, 110, 120),
			TweenTime = 0
		}
	elseif ReplicatedStorage:GetAttribute("SummerHourEvent") then
		v5 = {
			Context = "SummerHourEvent",
			Color = Color3.fromRGB(134, 105, 55)
		}
	else
		v5 = ReplicatedStorage:GetAttribute("SummerEvent") and {
			Context = "SummerEvent",
			Color = Color3.fromRGB(134, 105, 55)
		} or v4
	end

	if v2.Context == v5.Context then
		return
	end

	v2 = v5
	v3:Fire()
end

local WallRecolor = {}

function WallRecolor.OnStart(_)
	update()
end

function WallRecolor.OnUpdate(_)
	update()
end

function WallRecolor.OnLoad(_)
	Observers.observeTag("Wall", function(instance)
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

return WallRecolor