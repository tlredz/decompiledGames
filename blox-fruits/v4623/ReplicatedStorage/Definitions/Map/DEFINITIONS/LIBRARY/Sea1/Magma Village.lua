local createVector = vector.create
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
local Builders = require(game.ReplicatedStorage.Definitions.Map.Builders)
require(game.ReplicatedStorage.Definitions.Map.Types)
local v = Builders.Island.Builder.new(script.Name, script.Parent.Name):setDisplay(Builders.Display.Builder.new():setIcon(
	SpriteMap.All["volcano-s1"],
	SpriteMap.All["volcano-s1-outline"],
	SpriteMap.SketchIslands["volcano-s1-sketch"],
	SpriteMap.WireframeIslands["volcano-s1-wireframe"]
):setColor(Color3.fromHex("f0682e")):setPosition(Vector2.new(0.125, 0.805)):setDiameter(6000):build()):setReference(Builders.Reference.Builder.new():setLocation("Magma Village"):setPlayerSpawn("Magma"):setMap("Magma"):setLOD("Magma"):build()):setWorld(Builders.World.Builder.new():setPosition(createVector(
	-5528.21,
	-13.782,
	8691.137
)):setDiameter(1100):build()):insertRequirement(Builders.Requirement.Level.new(300)):insertTeleportPoint(Builders.TeleportPoint.new(createVector(
	-5513.9785,
	64.494316,
	8577.4
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