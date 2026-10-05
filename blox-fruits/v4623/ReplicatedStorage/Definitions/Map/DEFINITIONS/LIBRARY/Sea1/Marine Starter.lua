local createVector = vector.create
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
local Builders = require(game.ReplicatedStorage.Definitions.Map.Builders)
require(game.ReplicatedStorage.Definitions.Map.Types)
local v = Builders.Island.Builder.new(script.Name, script.Parent.Name):setDisplay(Builders.Display.Builder.new():setName("Starter Marine"):setIcon(
	SpriteMap.All["starter-marine-s1"],
	SpriteMap.All["starter-marine-s1-outline"],
	SpriteMap.SketchIslands["starter-marine-s1-sketch"],
	SpriteMap.WireframeIslands["starter-marine-s1-wireframe"]
):setColor(Color3.fromHex("6d7090")):setPosition(Vector2.new(0.325, 0.525)):setDiameter(5500):build()):insertTag("Starter"):setReference(Builders.Reference.Builder.new():setLocation("Marine Starter"):setPlayerSpawn("Default"):setMap("MarineStart"):build()):setWorld(Builders.World.Builder.new():setPosition(createVector(
	-2921.05,
	-10.77,
	2111.768
)):setDiameter(1250):build()):insertTeleportPoint(Builders.TeleportPoint.new(createVector(-3088.355, 217.162, 2099.874)))
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