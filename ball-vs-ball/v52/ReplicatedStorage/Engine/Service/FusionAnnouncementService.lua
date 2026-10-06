local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local MessagingService = game:GetService("MessagingService")
local Net = require(ReplicatedStorage.Packages.Net)
local Config = require(script.Parent.Config)
local remoteEvent = Net:RemoteEvent("RainbowFusionAnnouncements")
local FusionAnnouncementService = {
	remote = remoteEvent
}
local v = {}
local v2 = {}
local ids = {}
local v3 = false
local flag = false
local v4 = nil

local function validItem(data)
	if type(data) == "table" and type(data.displayName) == "string" and #data.displayName <= 160 and type(data.ballName) == "string" and #data.ballName > 0 and #data.ballName <= 160 and type(data.serial) == "number" and data.serial >= 1 and data.serial <= 9007199254740991 then
		return data.serial % 1 == 0
	else
		return false
	end
end

local function receive(data)
	if type(data) ~= "table" or data.v ~= 1 or type(data.id) ~= "string" or #data.id > 64 or type(data.items) ~= "table" or #data.items == 0 or #data.items > 100 then
		return
	end

	for _, item in ipairs(data.items) do
		if not validItem(item) then
			return
		end
	end

	if v2[data.id] then
		return
	end

	v2[data.id] = true
	table.insert(ids, data.id)

	if #ids > 256 then
		v2[table.remove(ids, 1)] = nil
	end

	remoteEvent:FireAllClients(data.items)
end

local function publish(items)
	local v5 = {
		v = 1,
		id = HttpService:GenerateGUID(false),
		items = items
	}
	receive(v5)
	local success, result = pcall(function()
		MessagingService:PublishAsync("RainbowFusionAnnouncement_v1", v5)
	end)

	if not success then
		warn("[FusionAnnouncement] Publish failed; batch dropped: " .. tostring(result))
	end
end

local function flush()
	while #v > 0 do
		local v5 = v
		v = {}
		local items = {}

		for _, v7 in ipairs(v5) do
			table.insert(items, v7)

			if not (#HttpService:JSONEncode({
				v = 1,
				id = string.rep("x", 36),
				items = items
			}) > 900) then
				continue
			end

			table.remove(items)

			if #items > 0 then
				publish(items)
			end

			items = { v7 }
		end

		if #items > 0 then
			publish(items)
		end

		if #v > 0 then
			task.wait(5)
		end
	end

	v3 = false
end

function FusionAnnouncementService.enqueue(p, p2, serial)
	assert(RunService:IsServer(), "Server only")
	local v5 = Config.ball.byCnId[p2]
	local v6 = {
		displayName = p.Name,
		ballName = v5 and v5.displayName,
		serial = serial
	}

	if not validItem(v6) or #v >= 100 then
		return false
	end

	table.insert(v, v6)

	if not v3 then
		v3 = true
		task.delay(5, function()
			local success, result = pcall(flush)

			if not success then
				v = {}
				v3 = false
				warn("[FusionAnnouncement] Flush failed: " .. tostring(result))
			end
		end)
	end

	return true
end

function FusionAnnouncementService.init()
	assert(RunService:IsServer(), "Server only")

	if flag then
		return
	end

	flag = true
	task.spawn(function()
		local v5 = 5

		while not v4 do
			local success, result = pcall(function()
				return MessagingService:SubscribeAsync("RainbowFusionAnnouncement_v1", function(p)
					local success2, result2 = pcall(receive, p.Data)

					if not success2 then
						warn("[FusionAnnouncement] Receive failed: " .. tostring(result2))
					end
				end)
			end)

			if success then
				v4 = result
				break
			end

			warn("[FusionAnnouncement] Subscribe failed; retrying: " .. tostring(result))
			task.wait(v5 + math.random())
			v5 = math.min(v5 * 2, 60)
		end
	end)
end

return FusionAnnouncementService