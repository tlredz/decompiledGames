local modules = script.Modules
local Library = {
	Beam = require(modules.Beam),
	Mesh = require(modules.Mesh),
	Lighting = require(modules.Lighting),
	Particles = require(modules.Particles),
	Highlight = require(modules.Highlight),
	BezierProjectile = require(modules.BezierProjectile),
	BezierCharge = require(modules.BezierCharge)
}

for _, v in pairs({
	Library.Beam,
	Library.Mesh,
	Library.Lighting,
	Library.Particles,
	Library.Highlight,
	Library.BezierCharge
}) do
	for k, v2 in pairs(v) do
		if type(v2) == "function" then
			Library[k] = v2
		end
	end
end

return Library