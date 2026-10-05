local createVector = vector.create
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
local Builders = require(game.ReplicatedStorage.Definitions.Map.Builders)
require(game.ReplicatedStorage.Definitions.Map.Types)
local v = Builders.Island.Builder.new(script.Name, script.Parent.Name):setDisplay(Builders.Display.Builder.new():setIcon(
	SpriteMap.All["underwater-s1"],
	SpriteMap.All["underwater-s1-outline"],
	SpriteMap.SketchIslands["underwater-s1-sketch"],
	SpriteMap.WireframeIslands["underwater-s1-wireframe"]
):setColor(Color3.fromHex("d3b184")):setPosition(Vector2.new(0.825, 0.125)):setDiameter(5500):build()):setReference(Builders.Reference.Builder.new():setLocation("Underwater City"):setPlayerSpawn("Fishman"):setMap("Fishmen"):build()):setWorld(Builders.World.Builder.new():setPosition(createVector(
	4087.789,
	-13.782,
	-1814.863
)):setBackendPosition(createVector(61379.79, -13.782, 1221.75)):setDiameter(1600):build()):insertRequirement(Builders.Requirement.Level.new(375)):insertTeleportPoint(Builders.TeleportPoint.new(createVector(
	61147.977,
	20.57084,
	1366.0984
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