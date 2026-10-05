local player = game.ReplicatedStorage.Modules.Player
local Guard = require(game.ReplicatedStorage.Modules.Util.Guard)
require(player.PlayerAdded)
local GetCharacterInfo = require(player.GetCharacter.GetCharacterInfo)
require(player.GetPlayer)
local Trove = require(game.ReplicatedStorage.Modules.Util.Trove)
local _ = {
	Server = {},
	Client = {}
}
return function(player2, callback)
	Guard.Function(callback)
	Guard.Player(player2)
	local maid = Trove.new()
	debug.traceback()
	maid:Add(function()
		maid = nil
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function fn()
		if maid then
			maid:Destroy()
		end
	end

	local function onCharacterAdded()
		local character = player2.Character

		while player2.Parent and character == player2.Character and maid do
			if player2.Team then
				local characterInfo = GetCharacterInfo(player2)

				if characterInfo and maid then
					task.spawn(callback, characterInfo)
					break
				end
			end

			task.wait(0.1)
		end

		if not player2.Parent and maid then
			maid:Destroy()
		end
	end

	task.defer(function()
		if player2.Parent then
			if maid then
				if player2.Character then
					task.spawn(onCharacterAdded)
				end

				if maid then
					maid:Add(player2.CharacterAdded:Connect(onCharacterAdded))
					maid:Add(player2.AncestryChanged:Connect(function(_, parent)
						if not parent and maid then
							maid:Destroy()
						end
					end))
				end
			end
		else
			fn() -- equivalent call inferred; original call site unknown
		end
	end)
	return fn
end