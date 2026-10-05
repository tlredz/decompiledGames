local instance = nil
local Component = require(game.ReplicatedStorage.Modules.Component)
local v = Component.new({
	Name = "DungeonCameraClient",
	Tag = "DungeonCameraClient",
	Module = {}
})

function v.OnStart(p)
	if not p.Instance:IsDescendantOf(game.Players.LocalPlayer) then
		return
	end

	instance = p.Instance
end

return v