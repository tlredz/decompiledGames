local createVector = vector.create
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
local Builders = require(game.ReplicatedStorage.Definitions.Map.Builders)
require(game.ReplicatedStorage.Definitions.Map.Types)
local v = Builders.Island.Builder.new(script.Name, script.Parent.Name):setDisplay(Builders.Display.Builder.new():setName("Fountain City"):setIcon(
	SpriteMap.All["fountain-s1"],
	SpriteMap.All["fountain-s1-outline"],
	SpriteMap.SketchIslands["fountain-s1-sketch"],
	SpriteMap.WireframeIslands["fountain-s1-wireframe"]
):setColor(Color3.fromHex("bab1a4")):setPosition(Vector2.new(0.825, 0.79)):setDiameter(5500):build()):setReference(Builders.Reference.Builder.new():setLocation("Fountain City"):setPlayerSpawn("Fountain"):setMap("Fountain"):setLOD("Fountain"):build()):setWorld(Builders.World.Builder.new():setPosition(createVector(
	5717.79,
	-13.782,
	4356.137
)):setDiameter(1600):build()):insertRequirement(Builders.Requirement.Level.new(625)):insertTeleportPoint(Builders.TeleportPoint.new(createVector(
	5420.3364,
	431.04068,
	4396.387
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