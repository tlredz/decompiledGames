local createVector = vector.create
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
local Builders = require(game.ReplicatedStorage.Definitions.Map.Builders)
require(game.ReplicatedStorage.Definitions.Map.Types)
local v = Builders.Island.Builder.new(script.Name, script.Parent.Name):setDisplay(Builders.Display.Builder.new():setName("Upper Skylands"):setIcon(
	SpriteMap.All["upper-sky-s1"],
	SpriteMap.All["upper-sky-s1-outline"],
	SpriteMap.SketchIslands["upper-sky-s1-sketch"],
	SpriteMap.WireframeIslands["upper-sky-s1-wireframe"]
):setColor(Color3.fromHex("c1dddc")):setPosition(Vector2.new(0.075, 0.15)):setDiameter(5000):build()):setReference(Builders.Reference.Builder.new():setLocation("Skylands"):setPlayerSpawn("Sky2"):setMap("SkyArea2"):setLOD("SkyArea2"):build()):setWorld(Builders.World.Builder.new():setPosition(createVector(
	-6774.626,
	5719.218,
	1237.132
)):setDiameter(3500):build()):insertRequirement(Builders.Requirement.Level.new(450)):insertRequirement(Builders.Requirement.Unlockable.new("UpperSkylandsAccess")):insertTeleportPoint(Builders.TeleportPoint.new(createVector(
	-7950.0366,
	5815.6846,
	-1968.3374
)))
local moduleScripts = {}
local bonusMoments = script:FindFirstChild("BonusMoments")

if bonusMoments then
	for _, moduleScript in bonusMoments:GetChildren() do
		assert(moduleScript:IsA("ModuleScript"), (`bad bonusMoment definition: {moduleScript:GetFullName()}`))
		table.insert(moduleScripts, moduleScript)
	end
end

table.sort(moduleScripts, function(a, b)
	return a.Name < b.Name
end)

for _, v2 in moduleScripts do
	v = v:insertBonusMoment(require(v2))
end

return v:build()