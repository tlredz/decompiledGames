local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ibds = {
	dataStoreName = game.ServerStorage:WaitForChild("DataStoreKey").Value,
	serverSessId = game.JobId,
	lockExpiryTime = 360,
	retryTime = 5,
	retryLimit = 15,
	getRetryLimit = 80,
	errorKickLimit = 12
}
local dataStore = DataStoreService:GetDataStore(Ibds.dataStoreName)
local v = {}
local v2 = {}
local deepCopy

deepCopy = function(p)
	local clone = table.clone(p)

	for k, v3 in clone do
		if type(v3) == "table" then
			clone[k] = deepCopy(v3)
		end
	end

	return clone
end

local dataserializer = require(ReplicatedStorage.Packages["data-serializer"])

-- equivalent calls inferred from this helper; original call sites unknown
local function describeWait(p: number)
	if p < 60 then
		return "less than a minute"
	end

	local v3 = math.ceil(p / 60)

	if v3 == 1 then
		return "about 1 minute"
	end

	return (`about {v3} minutes`)
end

local function lockedKick(p: number?)
	if p == nil then
		return "Your data is still in use by another server. Please try again in a few minutes."
	end

	local v5 = describeWait(math.max(p, 0)) -- equivalent call inferred; original call site unknown
	return (`Your data is still in use by another server. Please try again in {v5}.`)
end

function Ibds.ReleaseLock(userId)
	if typeof(userId) == "Instance" then
		userId = userId.UserId
	end

	v2[userId] = (v2[userId] or 0) + 1
	v[userId] = true
	local count = 0
	local v3 = false

	while count < Ibds.retryLimit do
		if pcall(function()
			dataStore:UpdateAsync(userId, function(p)
				if p == nil or p.sessId ~= Ibds.serverSessId then
					return nil
				end

				p.sessId = nil
				p.lastSessId = Ibds.serverSessId
				return p, { userId }
			end)
		end) then
			v3 = true
			break
		else
			count += 1
			task.wait(Ibds.retryTime)
		end
	end

	v[userId] = nil

	if not v3 then
		warn((`[IBDS] ReleaseLock failed for {userId} after {Ibds.retryLimit} retries`))
	end

	return v3
end

function Ibds.GetData(instance, p, callback, flag: boolean?, p2, flag2: boolean?)
	if instance == nil then
		warn("Player not provided for data loading")
		return
	end

	while v[instance.UserId] and instance.Parent ~= nil do
		task.wait(0.1)
	end

	local data = nil
	local v3 = 1
	local v4 = nil

	if flag2 then
		while instance.Parent ~= nil and data == nil do
			local success, result = pcall(function()
				return dataStore:GetAsync(instance.UserId)
			end)

			if success then
				if result == nil then
					if p == nil then
						warn((`Failed to get player data for {instance.Name} - Default data must be provided when fetching for a new player.`))
						instance:Kick("Your data could not be set up, please rejoin!")
						break
					else
						data = deepCopy(p)
						v4 = true
					end
				else
					data = result.data
				end
			end

			if data ~= nil then
				continue
			end

			if Ibds.retryLimit < v3 then
				instance:Kick("Roblox's data services are currently unavailable. Please try again in a few minutes.")
				break
			else
				v3 += 1
				task.wait(Ibds.retryTime)
			end
		end
	end

	local v5 = nil
	local count = 0

	while not flag2 and instance ~= nil and instance.Parent ~= nil and data == nil do
		local flag3 = false
		local flag4 = false
		local success, result = pcall(function(...)
			dataStore:UpdateAsync(instance.UserId, function(state, p3)
				if instance.Parent == nil then
					return nil
				end

				if state == nil then
					if p == nil then
						warn((`Failed to get player data for {instance.Name} - Default data must be provided when fetching for a new player.`))
						flag3 = true
						flag4 = true
					else
						data = deepCopy(p)
						v4 = true
						return {
							sessId = Ibds.serverSessId,
							data = p
						}, { instance.UserId }
					end
				else
					if state.sessId == nil or state.sessId == Ibds.serverSessId or os.time() - p3.UpdatedTime / 1000 > Ibds.lockExpiryTime then
						data = state.data

						if state.sessId ~= Ibds.serverSessId then
							state.sessId = Ibds.serverSessId
							return state, { instance.UserId }
						end
					else
						v5 = Ibds.lockExpiryTime - (os.time() - p3.UpdatedTime / 1000)
						warn((`[IBDS] Session locked for {instance.Name} - owned by {state.sessId}, retrying...`))
					end

					return nil
				end
			end)
		end)

		if success then
			count = 0
		else
			warn((`[IBDS] GetData attempt failed for {instance.Name}: {result}`))
			data = nil
			v4 = nil
			count += 1

			if Ibds.errorKickLimit <= count then
				warn((`[IBDS] Kicking {instance.Name}: {count} consecutive DataStore errors`))
				instance:Kick("Roblox's data services are currently unavailable. Please try again in a few minutes.")
				break
			end
		end

		if Ibds.getRetryLimit < v3 and data == nil then
			flag3 = true
		else
			v3 += 1
		end

		if flag3 then
			local v6

			if flag4 then
				v6 = "Your data could not be set up, please rejoin!"
			else
				local v7 = v5

				if v7 == nil then
					v6 = "Your data is still in use by another server. Please try again in a few minutes."
				else
					local v10 = describeWait(math.max(v7, 0)) -- equivalent call inferred; original call site unknown
					v6 = `Your data is still in use by another server. Please try again in {v10}.`
				end
			end

			instance:Kick(v6)
			break
		elseif data == nil then
			task.wait(Ibds.retryTime)
		end
	end

	if data == nil then
		return nil
	end

	if not flag2 and instance.Parent == nil then
		Ibds.ReleaseLock(instance.UserId)
		return nil
	end

	if callback and data then
		local success, result = pcall(callback, data)

		if success then
			data = result or data
		else
			warn((`[IBDS] Middleware failed for {instance.Name}: {result}`))

			if not flag2 then
				Ibds.ReleaseLock(instance.UserId)
			end

			instance:Kick("Your data could not be loaded, please rejoin!")
			return nil
		end
	end

	local v6

	if flag then
		v6 = data
	else
		v6 = dataserializer.tofold(data, nil, nil, p2)
	end

	return v6, v4
end

function Ibds.SaveData(p, instance, flag: boolean?, p2)
	if p == nil then
		warn("Player not provided for data saving")
		return false, "error"
	end

	if typeof(instance) == "Instance" then
		instance = dataserializer.toraw(instance, p2)
	end

	local userId = p.UserId

	if flag then
		v2[userId] = (v2[userId] or 0) + 1
		v[userId] = true
	end

	local v3 = v2[userId] or 0
	local v4 = false
	local count = 0
	local v5 = false
	local v6 = false
	local v7 = false
	local v8 = false

	while not v4 and count < Ibds.retryLimit do
		if not flag and (v2[userId] or 0) ~= v3 then
			v5 = true
			break
		end

		local v9 = false
		v8 = false
		v7 = false
		local v10 = pcall(function()
			dataStore:UpdateAsync(userId, function(state, _)
				if not flag and (v2[userId] or 0) ~= v3 then
					v5 = true
					return nil
				end

				if flag then
					if state == nil then
						v9 = true
						return {
							sessId = nil,
							lastSessId = Ibds.serverSessId,
							data = instance
						}, { userId }
					end

					if state.sessId == Ibds.serverSessId then
						state.sessId = nil
						state.lastSessId = Ibds.serverSessId
						state.data = instance
						v9 = true
						return state, { userId }
					else
						if state.sessId == nil then
							v8 = true
							v6 = state.lastSessId == Ibds.serverSessId
						else
							warn((`[IBDS] Cannot release session for {p.Name} - owned by {state.sessId}`))
							v7 = true
						end

						return nil
					end
				else
					if state == nil then
						v9 = true
						return {
							sessId = Ibds.serverSessId,
							data = instance
						}, { userId }
					end

					if state.sessId ~= Ibds.serverSessId then
						v7 = true
						return nil
					end

					state.data = instance
					v9 = true
					return state, { userId }
				end
			end)
		end)

		if v10 and v9 then
			v4 = true
			break
		end

		if v10 and (v7 or v5 or v8) then
			v4 = v8 and v6 and true or v4
			break
		else
			count += 1
			task.wait(Ibds.retryTime)
		end
	end

	if flag then
		v[userId] = nil
	end

	if v4 then
		return true
	end

	warn((`[IBDS] SaveData did not write for {p.Name} (releaseSession={tostring(flag)})`))
	return false, v5 and "superseded" or (v7 or v8) and "locked" or "error"
end

return Ibds