local createVector = vector.create
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
local Builders = require(game.ReplicatedStorage.Definitions.Map.Builders)
require(game.ReplicatedStorage.Definitions.Map.Types)
local v = Builders.Island.Builder.new(script.Name, script.Parent.Name):setDisplay(Builders.Display.Builder.new():setIcon(
	SpriteMap.All["pirate-village-s1"],
	SpriteMap.All["pirate-village-s1-outline"],
	SpriteMap.SketchIslands["pirate-village-s1-sketch"],
	SpriteMap.WireframeIslands["pirate-village-s1-wireframe"]
):setColor(Color3.fromHex("c3a172")):setPosition(Vector2.new(0.45, 0.69)):setDiameter(6500):build()):setReference(Builders.Reference.Builder.new():setLocation("Pirate Village"):setPlayerSpawn("Pirate"):setMap("Pirate"):setLOD("Pirate"):build()):setWorld(Builders.World.Builder.new():setPosition(createVector(
	-1133.21,
	-3.782,
	4176.137
)):setDiameter(950):build()):insertRequirement(Builders.Requirement.Level.new(30)):insertTeleportPoint(Builders.TeleportPoint.new(createVector(
	-807.6621,
	27.802052,
	4119.3013
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