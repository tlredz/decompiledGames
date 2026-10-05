local remotePlus = game.ReplicatedStorage:FindFirstChild("RemotePlus")
local Utility = require(remotePlus.Handlers.Utility)
local typeof2 = typeof
local InvokerMain = {}

function InvokerMain.Connect(p, callback)
	return Utility.Connect(p, callback)
end

function InvokerMain.ToAll(p, callback, ...)
	local result = nil

	for _, player in ipairs(Utility.Players) do
		local v = callback(p, player, ...)

		if v == nil then
			continue
		end

		result = result == nil and {} or result
		result[player.Name] = v
	end

	return result
end

function InvokerMain.To(p, callback, p2, ...)
	if p2 and p2.Parent == game.Players or not Utility.IsServer then
		return callback(p, p2, ...)
	end
end

function InvokerMain.ToAllExcept(p, callback, p2, ...)
	if not Utility.IsServer then
		return
	end

	local result = nil

	for _, player in ipairs(Utility.Players) do
		if player == p2 then
			continue
		end

		local v = callback(p, player, ...)

		if v == nil then
			continue
		end

		result = result == nil and {} or result
		result[player.Name] = v
	end

	return result
end

function InvokerMain.ToAllInRange(p, callback, player, p2: number, ...)
	if not Utility.IsServer then
		return
	end

	local position = nil

	if player ~= nil then
		local typeName = typeof2(player)

		if typeName == "Instance" then
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
	local result = nil

	for _, player2 in ipairs(Utility.Players) do
		local v = Utility.WatchPosition(player2)

		if not (v ~= nil and vector.magnitude(v - position) <= p2) then
			continue
		end

		local v2 = callback(p, player2, ...)

		if v2 == nil then
			continue
		end

		result = result == nil and {} or result
		result[player2.Name] = v2
	end

	return result
end

function InvokerMain.ToOthersInRange(p, callback, player, p2: number, ...)
	if not Utility.IsServer then
		return
	end

	local position = nil

	if player ~= nil then
		local typeName = typeof2(player)

		if typeName == "Instance" then
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
	local result = nil

	for _, player2 in ipairs(Utility.Players) do
		if player2 == player then
			continue
		end

		local v = Utility.WatchPosition(player2)

		if not (v ~= nil and vector.magnitude(v - position) <= p2) then
			continue
		end

		local v2 = callback(p, player2, ...)

		if v2 == nil then
			continue
		end

		result = result == nil and {} or result
		result[player2.Name] = v2
	end

	return result
end

return InvokerMain