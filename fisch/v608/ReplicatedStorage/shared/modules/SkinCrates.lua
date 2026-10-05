local modulesByName = {}
local SkinCrates = {}

for _, moduleScript in script:GetChildren() do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local name = moduleScript.Name
	local module = require(moduleScript)
	modulesByName[name] = module
end

SkinCrates.Banner = {
	"Mariana’s",
	"Ancient",
	"Moosewood",
	"Desolate",
	"Atlantis",
	"Cthulhu"
}
SkinCrates.List = modulesByName
return SkinCrates