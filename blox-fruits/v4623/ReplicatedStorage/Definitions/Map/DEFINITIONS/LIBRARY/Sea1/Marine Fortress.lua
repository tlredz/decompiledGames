local createVector = vector.create
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
local Builders = require(game.ReplicatedStorage.Definitions.Map.Builders)
require(game.ReplicatedStorage.Definitions.Map.Types)
local v = Builders.Island.Builder.new(script.Name, script.Parent.Name):setDisplay(Builders.Display.Builder.new():setIcon(
	SpriteMap.All["marine-fortress-s1"],
	SpriteMap.All["marine-fortress-s1-outline"],
	SpriteMap.SketchIslands["marine-fortress-s1-sketch"],
	SpriteMap.WireframeIslands["marine-fortress-s1-wireframe"]
):setColor(Color3.fromHex("c5b8b7")):setPosition(Vector2.new(0.18, 0.6)):setDiameter(5200):build()):setReference(Builders.Reference.Builder.new():setLocation("Marine Fortress"):setPlayerSpawn("MarineBase"):setMap("MarineBase"):setLOD("MarineBase"):build()):setWorld(Builders.World.Builder.new():setPosition(createVector(
	-4935.21,
	-13.782,
	4318.137
)):setDiameter(1000):build()):insertRequirement(Builders.Requirement.Level.new(120)):insertTeleportPoint(Builders.TeleportPoint.new(createVector(
	-5180.2383,
	281.34344,
	4383.0317
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