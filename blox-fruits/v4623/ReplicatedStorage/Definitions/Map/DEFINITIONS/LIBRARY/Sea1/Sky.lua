local createVector = vector.create
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
local Builders = require(game.ReplicatedStorage.Definitions.Map.Builders)
require(game.ReplicatedStorage.Definitions.Map.Types)
local v = Builders.Island.Builder.new(script.Name, script.Parent.Name):setDisplay(Builders.Display.Builder.new():setName("Lower Skylands"):setIcon(
	SpriteMap.All["sky-s1"],
	SpriteMap.All["sky-s1-outline"],
	SpriteMap.SketchIslands["sky-s1-sketch"],
	SpriteMap.WireframeIslands["sky-s1-wireframe"]
):setColor(Color3.fromHex("c1dddc")):setPosition(Vector2.new(0.2, 0.3)):setDiameter(6000):build()):setReference(Builders.Reference.Builder.new():setLocation("Skylands"):setPlayerSpawn("Sky"):setMap("Sky"):setLOD("Sky"):build()):setWorld(Builders.World.Builder.new():setPosition(createVector(
	-5024.21,
	1065.906,
	-2359.314
)):setDiameter(2500):build()):insertRequirement(Builders.Requirement.Level.new(150)):insertTeleportPoint(Builders.TeleportPoint.new(createVector(
	-4808.769,
	721.32635,
	-2668.8179
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