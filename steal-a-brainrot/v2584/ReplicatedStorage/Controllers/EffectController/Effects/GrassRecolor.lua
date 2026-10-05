local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
require(script:FindFirstAncestor("Effects").Parent.Types)
local CreateTween = require(ReplicatedStorage.Packages.CreateTween)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Signal = require(ReplicatedStorage.Packages.Signal)
local _ = script.Name
local v = { "WitchingHourEvent", "IndonesiaEvent" }
local v2 = {
	Context = "Default",
	Top = Color3.fromRGB(31, 128, 29),
	Bottom = Color3.fromRGB(31, 128, 29),
	TweenTime = 0,
	Carpet = Color3.fromRGB(196, 40, 28)
}
local v3 = v2
local v4 = Signal.new()

local function update()
	local v5 = v2
	local v6

	if ReplicatedStorage:GetAttribute("1YearClawsPhase") then
		v6 = {
			Context = "1YearClawsPhase",
			Top = Color3.fromRGB(235, 178, 55),
			Bottom = Color3.fromRGB(235, 178, 55),
			TweenTime = 1
		}
	elseif ReplicatedStorage:GetAttribute("1YearBrazilPhase") then
		v6 = {
			Context = "1YearBrazilPhase",
			Top = Color3.fromRGB(215, 92, 31),
			Bottom = Color3.fromRGB(215, 92, 31),
			TweenTime = 1
		}
	elseif ReplicatedStorage:GetAttribute("1YearMexicoPhase") then
		v6 = {
			Context = "1YearMexicoPhase",
			Top = Color3.fromRGB(180, 130, 75),
			Bottom = Color3.fromRGB(150, 100, 55),
			TweenTime = 1
		}
	elseif ReplicatedStorage:GetAttribute("LanceEvent") then
		v6 = {
			Context = "Lance",
			Bottom = Color3.fromRGB(209, 97, 45),
			Top = Color3.fromRGB(111, 59, 24),
			TweenTime = 0
		}
	elseif ReplicatedStorage:GetAttribute("RipMyGrannyEvent") then
		v6 = {
			Context = "RipMyGrannyEvent",
			Bottom = Color3.fromRGB(31, 128, 29),
			Top = Color3.fromRGB(120, 101, 48),
			TweenTime = 0
		}
	elseif ReplicatedStorage:GetAttribute("EidEvent") then
		v6 = {
			Context = "EidEvent",
			Top = Color3.fromRGB(0, 85, 255),
			Bottom = Color3.fromRGB(0, 85, 255),
			TweenTime = 0,
			Carpet = Color3.fromRGB(27, 42, 53)
		}
	elseif ReplicatedStorage:GetAttribute("2026Event") then
		v6 = {
			Context = "2026",
			Top = Color3.fromRGB(48, 57, 79),
			Bottom = Color3.fromRGB(35, 35, 35),
			TweenTime = 0,
			Carpet = Color3.fromRGB(60, 60, 60)
		}
	elseif ReplicatedStorage:GetAttribute("ConcertEvent") then
		v6 = {
			Context = "Concert",
			Top = Color3.fromRGB(157, 155, 151),
			Bottom = Color3.fromRGB(46, 71, 89),
			TweenTime = 2
		}
	elseif ReplicatedStorage:GetAttribute("RapConcertEvent") then
		v6 = {
			Context = "RapConcert",
			Top = Color3.fromRGB(157, 155, 151),
			Bottom = Color3.fromRGB(46, 71, 89),
			TweenTime = 2
		}
	elseif ReplicatedStorage:GetAttribute("BrazilEvent") then
		v6 = {
			Context = "Brazil",
			Top = Color3.fromRGB(215, 92, 31),
			Bottom = Color3.fromRGB(215, 92, 31),
			TweenTime = 2
		}
	elseif ReplicatedStorage:GetAttribute("AyMiGatitoEvent") then
		v6 = {
			Context = "AyMiGatitoEvent",
			Top = Color3.fromRGB(103, 185, 87),
			Bottom = Color3.fromRGB(81, 162, 59),
			TweenTime = 2
		}
	elseif ReplicatedStorage:GetAttribute("MexicoEvent") then
		v6 = {
			Context = "MexicoEvent",
			Top = Color3.fromRGB(160, 95, 53),
			Bottom = Color3.fromRGB(175, 126, 67),
			TweenTime = 0
		}
	elseif ReplicatedStorage:GetAttribute("SpainEvent") then
		v6 = {
			Context = "SpainEvent",
			Top = Color3.fromRGB(165, 135, 92),
			Bottom = Color3.fromRGB(61, 61, 61),
			TweenTime = 0,
			Carpet = Color3.fromRGB(61, 61, 61)
		}
	elseif ReplicatedStorage:GetAttribute("IndonesiaEvent") then
		v6 = {
			Context = "IndonesiaEvent",
			Top = Color3.fromRGB(160, 95, 53),
			Bottom = Color3.fromRGB(56, 109, 63),
			TweenTime = 0
		}
	elseif ReplicatedStorage:GetAttribute("CrabRave") then
		v6 = {
			Context = "CrabRave",
			Top = Color3.fromRGB(235, 178, 55),
			Bottom = Color3.fromRGB(235, 178, 55),
			TweenTime = 1.95
		}
	elseif ReplicatedStorage:GetAttribute("WaterEvent") then
		v6 = {
			Context = "WaterEvent",
			Top = Color3.fromRGB(226, 155, 64),
			Bottom = Color3.fromRGB(226, 155, 64),
			TweenTime = 0
		}
	elseif ReplicatedStorage:GetAttribute("StrawberryEvent") then
		v6 = {
			Context = "StrawberryEvent",
			Top = Color3.fromRGB(255, 255, 255),
			Bottom = Color3.fromRGB(255, 255, 255),
			TweenTime = 0,
			MaterialVariant = "Strawberry Stud",
			Carpet = Color3.fromRGB(31, 128, 29)
		}
	elseif ReplicatedStorage:GetAttribute("MeowlEvent") then
		v6 = {
			Context = "MeowlEvent",
			Top = Color3.fromRGB(69, 97, 44),
			Bottom = Color3.fromRGB(18, 65, 29),
			TweenTime = 0
		}
	elseif ReplicatedStorage:GetAttribute("ValentinesEvent") then
		v6 = {
			Context = "ValentinesEvent",
			Top = Color3.fromRGB(226, 153, 255),
			Bottom = Color3.fromRGB(188, 69, 71),
			TweenTime = 0,
			Carpet = Color3.fromRGB(200, 0, 0)
		}
	elseif ReplicatedStorage:GetAttribute("JobJobJobSahurEvent") then
		v6 = {
			Context = "JobJobJobSahurEvent",
			Top = Color3.fromRGB(172, 141, 69),
			Bottom = Color3.fromRGB(143, 114, 81),
			TweenTime = 0
		}
	elseif ReplicatedStorage:GetAttribute("DulDulDulEvent") then
		v6 = {
			Context = "DulDulDulEvent",
			Top = Color3.fromRGB(137, 136, 139),
			Bottom = Color3.fromRGB(87, 127, 41),
			TweenTime = 0
		}
	elseif ReplicatedStorage:GetAttribute("ChicleteiraBicicleteiraEvent") then
		v6 = {
			Context = "ChicleteiraBicicleteiraEvent",
			Top = Color3.fromRGB(85, 67, 67),
			Bottom = Color3.fromRGB(31, 128, 29),
			TweenTime = 0,
			Carpet = Color3.fromRGB(61, 53, 57)
		}
	elseif ReplicatedStorage:GetAttribute("TrickOrTreatEvent") then
		v6 = {
			Context = "TrickOrTreatEvent",
			Top = Color3.fromRGB(56, 109, 60),
			Bottom = Color3.fromRGB(56, 109, 60),
			TweenTime = 0,
			Carpet = Color3.fromRGB(27, 42, 53)
		}
	elseif ReplicatedStorage:GetAttribute("GraveyardEvent") then
		v6 = {
			Context = "GraveyardEvent",
			Top = Color3.fromRGB(47, 102, 72),
			Bottom = Color3.fromRGB(255, 255, 255),
			TweenTime = 0
		}
	elseif ReplicatedStorage:GetAttribute("GingerbreadTownEvent") then
		v6 = {
			Context = "GingerbreadTownEvent",
			Top = Color3.fromRGB(145, 161, 168),
			Bottom = Color3.fromRGB(145, 161, 168),
			TweenTime = 0
		}
	elseif ReplicatedStorage:GetAttribute("WinterHourEvent") then
		v6 = {
			Context = "WinterHourEvent",
			Top = Color3.fromRGB(145, 161, 168),
			Bottom = Color3.fromRGB(145, 161, 168),
			Carpet = Color3.fromRGB(87, 153, 166),
			TweenTime = 0
		}
	elseif ReplicatedStorage:GetAttribute("EasterEvent") then
		v6 = {
			Context = "EasterEvent",
			Top = Color3.fromRGB(87, 204, 51),
			Bottom = Color3.fromRGB(87, 204, 51),
			Carpet = Color3.fromRGB(193, 105, 196),
			TweenTime = 0
		}
	elseif ReplicatedStorage:GetAttribute("WitchingHourEvent") then
		v6 = {
			Context = "WitchingHourEvent",
			Top = Color3.fromRGB(39, 10, 59),
			Bottom = Color3.fromRGB(39, 10, 59),
			TweenTime = 0
		}
	elseif ReplicatedStorage:GetAttribute("YinYangEvent") then
		v6 = {
			Context = "YinYangEvent",
			Top = Color3.fromRGB(204, 204, 204),
			Bottom = Color3.fromRGB(0, 0, 0),
			TweenTime = 0
		}
	elseif ReplicatedStorage:GetAttribute("RadioactiveEvent") then
		v6 = {
			Context = "RadioactiveEvent",
			Top = Color3.fromRGB(31, 128, 29),
			Bottom = Color3.fromRGB(27, 42, 53),
			TweenTime = 0,
			Carpet = Color3.fromRGB(196, 147, 0)
		}
	elseif ReplicatedStorage:GetAttribute("CursedEvent") then
		v6 = {
			Context = "CursedEvent",
			Top = Color3.fromRGB(0, 0, 0),
			Bottom = Color3.fromRGB(42, 17, 0),
			TweenTime = 0
		}
	elseif ReplicatedStorage:GetAttribute("DivineEvent") then
		v6 = {
			Context = "DivineEvent",
			Top = Color3.fromRGB(203, 187, 166),
			Bottom = Color3.fromRGB(203, 177, 45),
			TweenTime = 0,
			Carpet = Color3.fromRGB(190, 136, 0)
		}
	elseif ReplicatedStorage:GetAttribute("PhantomEvent") then
		v6 = {
			Context = "PhantomEvent",
			Top = Color3.fromRGB(27, 42, 53),
			Bottom = Color3.fromRGB(46, 56, 62),
			TweenTime = 0,
			Material = Enum.Material.Glass
		}
	elseif ReplicatedStorage:GetAttribute("EclipseEvent") then
		v6 = {
			Context = "EclipseEvent",
			Top = Color3.fromRGB(81, 62, 122),
			Top2 = Color3.fromRGB(190, 135, 48),
			Bottom = Color3.fromRGB(81, 62, 122),
			TweenTime = 0,
			Carpet = Color3.fromRGB(190, 135, 48)
		}
	elseif ReplicatedStorage:GetAttribute("CrystalEvent") then
		v6 = {
			Context = "CrystalEvent",
			Top = Color3.fromRGB(152, 162, 255),
			Bottom = Color3.fromRGB(118, 130, 204),
			TweenTime = 0,
			Material = Enum.Material.Plastic,
			MaterialVariant = "CrystalGridStudNoStripe"
		}
	elseif ReplicatedStorage:GetAttribute("CyberEvent") then
		v6 = {
			Context = "CyberEvent",
			Top = Color3.fromRGB(30, 34, 47),
			Top2 = Color3.fromRGB(0, 170, 196),
			Bottom = Color3.fromRGB(30, 34, 47),
			TweenTime = 0,
			Carpet = Color3.fromRGB(15, 33, 75)
		}
	elseif ReplicatedStorage:GetAttribute("GalaxyEvent") then
		v6 = {
			Context = "GalaxyEvent",
			Top = Color3.fromRGB(42, 99, 255),
			Bottom = Color3.fromRGB(42, 99, 255),
			TweenTime = 2
		}
	elseif ReplicatedStorage:GetAttribute("ExtinctEvent") then
		v6 = {
			Context = "ExtinctEvent",
			Top = Color3.fromRGB(108, 83, 58),
			Bottom = Color3.fromRGB(108, 83, 58),
			TweenTime = 0.5
		}
	elseif ReplicatedStorage:GetAttribute("MoltenEvent") then
		v6 = {
			Context = "Molten",
			Top = Color3.fromRGB(0, 0, 0),
			Bottom = Color3.fromRGB(0, 0, 0),
			TweenTime = 0.5
		}
	elseif ReplicatedStorage:GetAttribute("EggCityEvent") then
		v6 = {
			Context = "EggCityEvent",
			Top = Color3.fromRGB(93, 136, 61),
			Bottom = Color3.fromRGB(93, 136, 61),
			TweenTime = 0
		}
	elseif ReplicatedStorage:GetAttribute("BackroomsEvent") then
		v6 = {
			Context = "BackroomsEvent",
			Top = Color3.fromRGB(120, 108, 83),
			Bottom = Color3.fromRGB(120, 108, 83),
			TweenTime = 0
		}
	elseif ReplicatedStorage:GetAttribute("LaserCityEvent") then
		v6 = {
			Context = "LaserCityEvent",
			Top = Color3.fromRGB(149, 117, 61),
			Bottom = Color3.fromRGB(68, 129, 39),
			TweenTime = 0
		}
	elseif ReplicatedStorage:GetAttribute("Snow") then
		v6 = {
			Context = "Snow",
			Top = Color3.fromRGB(190, 190, 190),
			Bottom = Color3.fromRGB(190, 190, 190),
			TweenTime = 8
		}
	elseif ReplicatedStorage:GetAttribute("SummerHourEvent") then
		v6 = {
			Context = "SummerHourEvent",
			Top = Color3.fromRGB(162, 127, 66),
			Bottom = Color3.fromRGB(67, 141, 36),
			TweenTime = 0,
			Carpet = v2.Carpet
		}
	else
		v6 = ReplicatedStorage:GetAttribute("SummerEvent") and {
			Context = "SummerEvent",
			Top = Color3.fromRGB(162, 127, 66),
			Bottom = Color3.fromRGB(67, 141, 36),
			TweenTime = 0,
			Carpet = v2.Carpet
		} or v5
	end

	if v3.Context == v6.Context then
		return
	end

	v3 = v6
	v4:Fire()
end

local GrassRecolor = {}

function GrassRecolor.OnStart(_)
	update()
end

function GrassRecolor.OnUpdate(_)
	update()
end

function GrassRecolor.OnLoad(_)
	Observers.observeTag("Grass", function(instance)
		local v5 = nil
		local material = instance.Material

		local function runTween()
			if v5 then
				v5:Cancel()
			end

			instance.MaterialVariant = v3.MaterialVariant or ""
			local v6 = instance:GetAttribute("Bottom") and "Bottom" or "Top"
			local v7 = v6 == "Top" and v3.Top2 and instance:GetAttribute("Top2") and "Top2" or v6

			if v3.Material and v7 ~= "Bottom" then
				instance.Material = v3.Material
			else
				instance.Material = material
			end

			local tweenInfo = TweenInfo.new(v3.TweenTime)
			local color

			if type(v3[v7]) == "table" then
				color = v3[v7][instance:GetAttribute("Side") or "Left"] or v3[v7].Left or select(2, next(v3[v7]))
			else
				color = v3[v7]
			end

			v5 = CreateTween(instance, tweenInfo, {
				Color = color
			})
		end

		local connection = v4:Connect(runTween)
		task.spawn(runTween)
		return function()
			connection:Disconnect()
			v5:Cancel()
		end
	end, { workspace })
	Observers.observeTag("Carpet", function(p)
		local v5 = nil

		local function runTween()
			if v5 then
				v5:Cancel()
			end

			local v6 = false

			for _, attributeName in v do
				if not ReplicatedStorage:GetAttribute(attributeName) then
					continue
				end

				v6 = true
				break
			end

			p.Transparency = v6 and 1 or 0
			v5 = CreateTween(p, TweenInfo.new(v3.TweenTime), {
				Color = v3.Carpet or v2.Carpet
			})
		end

		local connections = { v4:Connect(runTween) }

		for _, v6 in v do
			table.insert(connections, ReplicatedStorage:GetAttributeChangedSignal(v6):Connect(runTween))
		end

		task.spawn(runTween)
		return function()
			for _, connection in connections do
				connection:Disconnect()
			end

			v5:Cancel()
		end
	end, { workspace })
end

return GrassRecolor