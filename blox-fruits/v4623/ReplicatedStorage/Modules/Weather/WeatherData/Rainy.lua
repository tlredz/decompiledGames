local Rain = require(script.Parent.Rain)
local clone2 = table.clone(Rain.Rain)
clone2.Intensity = 0.5
clone2.Id = "Rainy"
local Clouds = require(script.Parent.Clouds)
local clone4 = table.clone(Clouds.Clouds)
clone4.Id = "Rainy"
clone4.Cover = 1
clone4.Density = 0.7
clone4.Color = Color3.fromRGB(88, 88, 88)
return {
	Rain = clone2,
	Clouds = clone4
}