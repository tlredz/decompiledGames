local Modal = {}
require(game.ReplicatedStorage.Modules.Util.Signal)
local Lock = require(game.ReplicatedStorage.Modules.Util.Lock)
local v = Lock.new(true)

function Modal.ToggleModalEnabled(_, flag: boolean, p: string)
	assert(p, "Provide a lock name for ToggleModalEnabled")

	if flag then
		v:Unlock(p)
	else
		v:Lock(p)
	end

	local playerGui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
	local touchGui = playerGui and playerGui:FindFirstChild("TouchGui")
	local enabled = v:IsLocked() == false

	if touchGui then
		touchGui.Enabled = enabled
	end

	return enabled
end

function Modal.IsModalEnabled(_)
	return v:IsLocked() == false
end

return Modal