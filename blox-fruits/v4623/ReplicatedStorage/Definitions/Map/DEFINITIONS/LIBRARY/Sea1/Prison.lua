local createVector = vector.create
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
local Builders = require(game.ReplicatedStorage.Definitions.Map.Builders)
require(game.ReplicatedStorage.Definitions.Map.Types)
local v = Builders.Island.Builder.new(script.Name, script.Parent.Name):setDisplay(Builders.Display.Builder.new():setIcon(
	SpriteMap.All["prison-s1"],
	SpriteMap.All["prison-s1-outline"],
	SpriteMap.SketchIslands["prison-s1-sketch"],
	SpriteMap.WireframeIslands["prison-s1-wireframe"]
):setColor(Color3.fromHex("7b9eb4")):setPosition(Vector2.new(0.872, 0.46)):setDiameter(5000):build()):setReference(Builders.Reference.Builder.new():setLocation("Prison"):setPlayerSpawn("Prison"):setMap("Prison"):setLOD("Prison"):build()):setWorld(Builders.World.Builder.new():setPosition(createVector(
	5277.79,
	-13.782,
	743.137
)):setDiameter(900):build()):insertRequirement(Builders.Requirement.Level.new(190)):insertTeleportPoint(Builders.TeleportPoint.new(createVector(
	5270.5693,
	163.50847,
	844.7282
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