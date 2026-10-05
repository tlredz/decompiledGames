local ZLib = {}

for _, childName in ipairs({
	"MeshEmit",
	"Lighting",
	"BeamEmit",
	"Particles",
	"Bezier",
	"Crater",
	"Sparks",
	"BezierCharge",
	"Mesh"
}) do
	local child = script:FindFirstChild(childName)

	if child then
		local module = require(child)
		ZLib[childName] = module
	else
		warn("[ZLib] Module missing:", childName)
	end
end

return ZLib