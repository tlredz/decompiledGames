local Blocking = {
	Id = 0
}
local Character_info_provider = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Character_info_provider"))
local track = nil

function Blocking.Hold(player)
	local character = player.Character or player

	if character == nil then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if humanoid ~= nil then
		local block = Character_info_provider.get_core_anim(player, "block")

		if block == nil then
			block = script.block
		end

		if track then
			track:Stop()
			track = nil
		end

		track = humanoid.Animator:LoadAnimation(block)
		track:Play()
	end
end

function Blocking.UnHold(p)
	Blocking.Cancel(p)
end

function Blocking.Cancel(player)
	if (player.Character or player) == nil then
		return
	end

	if track then
		track:Stop()
		track = nil
	end
end

return Blocking