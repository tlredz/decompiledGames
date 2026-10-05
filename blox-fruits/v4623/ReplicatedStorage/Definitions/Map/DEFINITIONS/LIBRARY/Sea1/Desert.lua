local createVector = vector.create
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
local Builders = require(game.ReplicatedStorage.Definitions.Map.Builders)
require(game.ReplicatedStorage.Definitions.Map.Types)
local v = Builders.Island.Builder.new(script.Name, script.Parent.Name):setDisplay(Builders.Display.Builder.new():setIcon(
	SpriteMap.All["desert-s1"],
	SpriteMap.All["desert-s1-outline"],
	SpriteMap.SketchIslands["desert-s1-sketch"],
	SpriteMap.WireframeIslands["desert-s1-wireframe"]
):setColor(Color3.fromHex("f6d062")):setPosition(Vector2.new(0.65, 0.74)):setDiameter(5500):build()):setReference(Builders.Reference.Builder.new():setLocation("Desert"):setPlayerSpawn("Desert"):setMap("Desert"):setLOD("Desert"):build()):setWorld(Builders.World.Builder.new():setPosition(createVector(
	1330.683,
	103.55368,
	4489.306
)):setDiameter(1100):build()):insertRequirement(Builders.Requirement.Level.new(60)):insertTeleportPoint(Builders.TeleportPoint.new(createVector(
	1330.683,
	103.55368,
	4489.306
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