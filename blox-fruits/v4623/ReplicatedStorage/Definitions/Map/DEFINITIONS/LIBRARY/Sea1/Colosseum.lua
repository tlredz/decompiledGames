local createVector = vector.create
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
local Builders = require(game.ReplicatedStorage.Definitions.Map.Builders)
require(game.ReplicatedStorage.Definitions.Map.Types)
local v = Builders.Island.Builder.new(script.Name, script.Parent.Name):setDisplay(Builders.Display.Builder.new():setIcon(
	SpriteMap.All["colosseum-s1"],
	SpriteMap.All["colosseum-s1-outline"],
	SpriteMap.SketchIslands["colosseum-s1-sketch"],
	SpriteMap.WireframeIslands["colosseum-s1-wireframe"]
):setColor(Color3.fromHex("d3b184")):setPosition(Vector2.new(0.325, 0.175)):setDiameter(6500):build()):setReference(Builders.Reference.Builder.new():setLocation("Colosseum"):setPlayerSpawn("Colosseum"):setMap("Colosseum"):setLOD("Colosseum"):build()):setWorld(Builders.World.Builder.new():setPosition(createVector(
	-1685.21,
	-13.782,
	-3200.863
)):setDiameter(1350):build()):insertRequirement(Builders.Requirement.Level.new(250)):insertTeleportPoint(Builders.TeleportPoint.new(createVector(
	-2143.4133,
	152.07433,
	-3025.5461
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