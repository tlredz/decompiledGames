local parent = script.Parent
local ContentProvider = game:GetService("ContentProvider")
local Guard = require(parent.Guard)
local Signal = require(parent.Signal)
local Network = require(parent.Network)
local Promise = require(parent.Promise)
local RunContext = require(parent.RunContext)
local ClientReady = require(parent.ClientReady)
local NetworkServer

if RunContext.IsServer then
	NetworkServer = game:GetService("NetworkServer")
else
	NetworkServer = nil
end

local event = Network.Event("RELICSxyz_RegisterSecret", function(p, p2)
	return Guard.String(p), Guard.String(p2)
end)
local v = {}
local v2 = {}
local v3 = Signal.new()

local function isSongOfEmote(p: string)
	return v2[p] or false
end

local function isSecretRegistered(p: string)
	return v[p] ~= nil
end

local function waitForSecretRegistered(p: string, value: number?)
	local v4 = value or 10
	return Promise.new(function(callback, _)
		if v[p] then
			callback(true)
			return
		end

		local connection = nil
		local thread = task.delay(v4, function()
			if connection then
				connection:Disconnect()
			end

			local count = 0

			for _ in v do
				count += 1
			end
		end)
		connection = v3:Connect(function(p2, _)
			if p2 == p then
				if thread then
					task.cancel(thread)
				end

				connection:Disconnect()
				callback(true)
			end
		end)
	end)
end

local function preloadSongs(list)
	if #list == 0 then
		return
	end

	local v4 = {}

	for _, soundId in ipairs(list) do
		local sound = Instance.new("Sound")
		sound.SoundId = soundId
		table.insert(v4, sound)
	end

	task.spawn(function()
		ContentProvider:PreloadAsync(v4, function(p, p2)
			if p2 == Enum.AssetFetchStatus.Failure then
				warn((`[RelicsXYZ.Secrets] Failed to preload song asset: {p}`))
			elseif p2 == Enum.AssetFetchStatus.TimedOut then
				warn((`[RelicsXYZ.Secrets] Timed out while preloading song asset: {p}`))
			end
		end)
	end)
end

local function registerSecretForUser(p, id: string, secret: string, flag: boolean?)
	if not NetworkServer then
		return false
	end

	ClientReady.WaitForClient(p)
	local success, result = pcall(function()
		return NetworkServer:EncryptStringForPlayerId(secret, p.UserId)
	end)

	if flag then
		v2[id] = true
	end

	if success and result then
		event:Server():Fire(p, id, result, flag)
		return success
	end

	warn((`[RelicsXYZ.Secrets] Failed to encrypt for player {p.Name}: {id}`))
	return success
end

local function loadEncryptedSongs(p, list)
	local ids = {}

	for _, v4 in ipairs(list) do
		if v4.secret and #v4.secret == 64 then
			if not (registerSecretForUser(p, v4.id, v4.secret) or RunContext.IsEdit) then
				warn("[RelicsXYZ] Failed to encrypt asset for song:", v4.artist, "-", v4.title)
			end
		else
			table.insert(ids, v4.id)
		end
	end

	preloadSongs(ids)
end

local function registerEncryptedAsset(p: string, p2: string)
	if not pcall(function()
		ContentProvider:RegisterEncryptedAsset(p, p2)
	end) then
		warn((`[RelicsXYZ.Secrets] Failed to register encrypted asset: "{p}"`))
		return
	end

	v3:Fire(p, p2)
	v[p] = p2
end

if RunContext.IsClient and not RunContext.IsEdit then
	event:Client():On(function(p, p2, p3)
		local success, result = pcall(function()
			ContentProvider:RegisterSessionEncryptedAsset(p, p2)
		end)

		if p3 then
			v2[p] = true
			preloadSongs({ p })
		end

		if success then
			v3:Fire(p, p2)
			v[p] = p2
		else
			warn(`[RelicsXYZ.Secrets] ✗ Failed to register encrypted secret: {p}`, result)
			Promise.retryWithDelay(function()
				return Promise.new(function(callback, callback2)
					local success2, result2 = pcall(function()
						ContentProvider:RegisterSessionEncryptedAsset(p, p2)
					end)

					if not success2 then
						callback2(result2)
						return
					end

					v3:Fire(p, p2)
					v[p] = p2
					callback()
				end)
			end, 3, 0.15):catch(function(p4)
				warn(`[RelicsXYZ.Secrets] ✗ Failed to register encrypted secret after retries: {p}`, p4)
			end)
		end
	end)
end

return table.freeze({
	PreloadSongs = preloadSongs,
	IsSongOfEmote = isSongOfEmote,
	LoadEncryptedSongs = loadEncryptedSongs,
	IsSecretRegistered = isSecretRegistered,
	RegisterSecretForUser = registerSecretForUser,
	RegisterEncryptedAsset = registerEncryptedAsset,
	WaitForSecretRegistered = waitForSecretRegistered
})