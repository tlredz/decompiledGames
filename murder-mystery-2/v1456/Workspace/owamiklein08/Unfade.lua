local FadeModule = require(game.ReplicatedStorage.Modules.FadeModule)
local v = false
spawn(function()
	repeat
		wait()
	until v == true

	wait(1)
	_G.ShowResults()
end)
FadeModule.SpawnFade()
v = true