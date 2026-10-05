local Cutscene = require(game.ReplicatedStorage.Modules.Cutscene)
local parent = script.Parent
local cutscene = parent:WaitForChild("Cutscene", 10)
local v, v2 = xpcall(function()
	assert(cutscene and cutscene:IsA("ModuleScript"), "Cutscene package source is not a ModuleScript")
	local _runReplicated, v3 = Cutscene._runReplicated(cutscene, parent)

	if _runReplicated == "Failed" then
		error(v3 or `Cutscene "{parent.Name}" failed`, 0)
	end
end, debug.traceback)

if not v then
	warn((`[Cutscene] Replicated runner failed: {tostring(v2)}`))
end

parent:Destroy()