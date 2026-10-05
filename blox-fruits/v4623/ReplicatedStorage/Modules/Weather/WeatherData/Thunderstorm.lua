local Lightning = require(script.Parent.Lightning)
local clone2 = table.clone(Lightning.Lightning)
clone2.Id = "Thunderstorm"
clone2.Damage = {
	Player = NumberRange.new(5, 30),
	Boat = NumberRange.new(5, 10)
}
local Rain = require(script.Parent.Rain)
local clone4 = table.clone(Rain.Rain)
clone4.Id = "Thunderstorm"
clone4.Intensity = 1
local Clouds = require(script.Parent.Clouds)
local clone6 = table.clone(Clouds.Clouds)
clone6.Id = "Thunderstorm"
clone6.Cover = 1
clone6.Density = 1
clone6.Color = Color3.fromRGB(22, 22, 22)
return {
	Lightning = clone2,
	Rain = clone4,
	Clouds = clone6
}