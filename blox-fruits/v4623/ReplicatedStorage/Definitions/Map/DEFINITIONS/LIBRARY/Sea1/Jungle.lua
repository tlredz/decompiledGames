local createVector = vector.create
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
local Builders = require(game.ReplicatedStorage.Definitions.Map.Builders)
require(game.ReplicatedStorage.Definitions.Map.Types)
local v = Builders.Island.Builder.new(script.Name, script.Parent.Name):setDisplay(Builders.Display.Builder.new():setIcon(
	SpriteMap.All["jungle-s1"],
	SpriteMap.All["jungle-s1-outline"],
	SpriteMap.SketchIslands["jungle-s1-sketch"],
	SpriteMap.WireframeIslands["jungle-s1-wireframe"]
):setColor(Color3.fromHex("9ab223")):setPosition(Vector2.new(0.48, 0.25)):setDiameter(6000):build()):setReference(Builders.Reference.Builder.new():setLocation("Jungle"):setPlayerSpawn("Jungle"):setMap("Jungle"):setLOD("Jungle"):build()):setWorld(Builders.World.Builder.new():setPosition(createVector(
	-1419.21,
	-3.782,
	-76.863
)):setDiameter(1500):build()):insertRequirement(Builders.Requirement.Level.new(10)):insertTeleportPoint(Builders.TeleportPoint.new(createVector(
	-1340.2195,
	136.02054,
	-101.374214
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