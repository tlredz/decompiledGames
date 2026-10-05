local createVector = vector.create
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
local Builders = require(game.ReplicatedStorage.Definitions.Map.Builders)
require(game.ReplicatedStorage.Definitions.Map.Types)
local v = Builders.Island.Builder.new(script.Name, script.Parent.Name):setDisplay(Builders.Display.Builder.new():setIcon(
	SpriteMap.All["middle-town-s1"],
	SpriteMap.All["middle-town-s1-outline"],
	SpriteMap.All["middle-town-s1-sketch"],
	SpriteMap.WireframeIslands["middle-town-s1-wireframe"]
):setColor(Color3.fromHex("c6b58e")):setPosition(Vector2.new(0.5, 0.45)):setDiameter(6500):build()):setReference(Builders.Reference.Builder.new():setLocation("Middle Town"):setPlayerSpawn("Town"):setMap("Town"):setLOD("Town"):build()):setWorld(Builders.World.Builder.new():setPosition(createVector(
	-833.21,
	-3.782,
	1628.137
)):setDiameter(1050):build()):insertTag("GatewayBlocked"):insertTeleportPoint(Builders.TeleportPoint.new(createVector(
	-703.1675,
	9.5518875,
	1575.1864
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