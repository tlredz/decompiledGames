local createVector = vector.create
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
local Builders = require(game.ReplicatedStorage.Definitions.Map.Builders)
require(game.ReplicatedStorage.Definitions.Map.Types)
local v = Builders.Island.Builder.new(script.Name, script.Parent.Name):setDisplay(Builders.Display.Builder.new():setName("Starter Island"):setIcon(
	SpriteMap.All["starter-island-s1"],
	SpriteMap.All["starter-island-s1-outline"],
	SpriteMap.SketchIslands["starter-island-s1-sketch"],
	SpriteMap.WireframeIslands["starter-island-s1-wireframe"]
):setColor(Color3.fromHex("60aa58")):setPosition(Vector2.new(0.675, 0.525)):setDiameter(5500):build()):insertTag("Starter"):setReference(Builders.Reference.Builder.new():setLocation("Pirate Starter"):setPlayerSpawn("Default"):setMap("Windmill"):setLOD("Windmill"):build()):setWorld(Builders.World.Builder.new():setPosition(createVector(
	1014.48,
	15.83,
	1462.93
)):setDiameter(800):build()):insertTeleportPoint(Builders.TeleportPoint.new(createVector(
	1038.2997,
	112.136505,
	1287.8345
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