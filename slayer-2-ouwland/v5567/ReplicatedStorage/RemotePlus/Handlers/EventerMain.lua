local remotePlus = game.ReplicatedStorage:FindFirstChild("RemotePlus")
local Utility = require(remotePlus.Handlers.Utility)
local typeof2 = typeof
local EventerMain = {}

function EventerMain.Connect(p, callback)
	return Utility.Connect(p, callback)
end

function EventerMain.ToAll(p, callback, ...)
	callback(p, ...)
end

function EventerMain.To(p, callback, p2, ...)
	if (not p2 or p2.Parent ~= game.Players) and Utility.IsServer then
		return
	end

	callback(p, p2, ...)
end

function EventerMain.ToAllExcept(p, callback, p2, ...)
	if not Utility.IsServer then
		return
	end

	for _, player in ipairs(Utility.Players) do
		if player ~= p2 then
			callback(p, player, ...)
		end
	end
end

function EventerMain.ToAllInRange(p, callback, player, p2: number, ...)
	if not Utility.IsServer then
		return
	end

	local position = nil

	if player ~= nil then
		local typeName = typeof2(player)

		if typeName == "Instance" then
			if player.Parent == nil then
				return
			end

			if player.ClassName == "Model" then
				if player.PrimaryPart ~= nil then
					position = player.PrimaryPart.Position
				end
			elseif player.Parent == game.Players then
				if player.Character ~= nil and player.Character.PrimaryPart ~= nil then
					position = player.Character.PrimaryPart.Position
				end
			else
				position = player.Position
			end
		elseif typeName == "Vector3" then
			position = player
		elseif typeName == "CFrame" then
			position = player.Position
		end
	end

	assert(position ~= nil, "From character must be valid")

	for _, player2 in ipairs(Utility.Players) do
		local v = Utility.WatchPosition(player2)

		if v ~= nil and vector.magnitude(v - position) <= p2 then
			callback(p, player2, ...)
		end
	end
end

function EventerMain.ToOthersInRange(p, callback, player, p2: number, ...)
	if not Utility.IsServer then
		return
	end

	local position = nil

	if player ~= nil then
		local typeName = typeof2(player)

		if typeName == "Instance" then
			if player.Parent == nil then
				return
			end

			if player.ClassName == "Model" then
				if player.PrimaryPart ~= nil then
					position = player.PrimaryPart.Position
				end
			elseif player.Parent == game.Players then
				if player.Character ~= nil and player.Character.PrimaryPart ~= nil then
					position = player.Character.PrimaryPart.Position
				end
			else
				position = player.Position
			end
		elseif typeName == "Vector3" then
			position = player
		elseif typeName == "CFrame" then
			position = player.Position
		end
	end

	assert(position ~= nil, "From character must be valid")

	for _, player2 in ipairs(Utility.Players) do
		if player2 == player then
			continue
		end

		local v = Utility.WatchPosition(player2)

		if v ~= nil and vector.magnitude(v - position) <= p2 then
			callback(p, player2, ...)
		end
	end
end

return EventerMain