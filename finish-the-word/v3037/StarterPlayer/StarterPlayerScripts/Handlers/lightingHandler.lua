local _ = game.ReplicatedStorage.ReplicatedAssets.LightingPresets
local import = _G.import("event")
local import2 = _G.import("cameraUtil")
return {
	Priority = 1,
	Run = function()
		import.connect("setLighting", import2.setLighting)
	end
}