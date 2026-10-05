local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
local Builders = require(game.ReplicatedStorage.Definitions.Map.Builders)
require(game.ReplicatedStorage.Definitions.Map.Types)
local v = Builders.Island.Builder.new(script.Name, script.Parent.Name):setDisplay(Builders.Display.Builder.new():setIcon(
	SpriteMap.All["bandit-village-s1"],
	SpriteMap.All["bandit-village-s1-outline"],
	SpriteMap.SketchIslands["bandit-village-s1-sketch"],
	SpriteMap.WireframeIslands["bandit-village-s1-wireframe"]
):setColor(Color3.fromHex("7b9eb4")):setPosition(Vector2.new(0.3, 0.7)):setDiameter(2000):build()):insertTag("NavigationBlocked"):setReference(Builders.Reference.Builder.new():setMap("MobBoss"):build()):setWorld(Builders.World.Builder.new():setPosition(vector.create(
	-2862.696,
	3.635,
	5394.688
)):setDiameter(442):build())
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