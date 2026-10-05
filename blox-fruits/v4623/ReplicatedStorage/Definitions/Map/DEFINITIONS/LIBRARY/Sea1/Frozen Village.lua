local createVector = vector.create
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
local Builders = require(game.ReplicatedStorage.Definitions.Map.Builders)
require(game.ReplicatedStorage.Definitions.Map.Types)
local v = Builders.Island.Builder.new(script.Name, script.Parent.Name):setDisplay(Builders.Display.Builder.new():setIcon(
	SpriteMap.All["snow-s1"],
	SpriteMap.All["snow-s1-outline"],
	SpriteMap.SketchIslands["snow-s1-sketch"],
	SpriteMap.WireframeIslands["snow-s1-wireframe"]
):setColor(Color3.fromHex("d7d5e7")):setPosition(Vector2.new(0.665, 0.225)):setDiameter(6500):build()):setReference(Builders.Reference.Builder.new():setLocation("Frozen Village"):setPlayerSpawn("Ice"):setMap("Ice"):setLOD("Ice"):build()):setWorld(Builders.World.Builder.new():setPosition(createVector(
	1276.79,
	-13.782,
	-1472.863
)):setDiameter(1000):build()):insertRequirement(Builders.Requirement.Level.new(90)):insertTeleportPoint(Builders.TeleportPoint.new(createVector(
	1394.464,
	39.044888,
	-1321.639
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