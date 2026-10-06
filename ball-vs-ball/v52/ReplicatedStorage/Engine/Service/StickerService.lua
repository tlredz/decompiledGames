local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.Packages.Net)
local Config = require(ReplicatedStorage.Engine.Service.Config)
local PlayerData = require(ReplicatedStorage.Engine.Service.PlayerData)
local TimeService = require(ReplicatedStorage.Engine.Service.TimeService)
local v = {
	server = {},
	client = {}
}
local remoteEvent = Net:RemoteEvent("StickerSend")

if RunService:IsServer() then
	local v2 = {}

	local function pickRandomStickers(p)
		local v3 = {}

		for _, v4 in Config.skin.bySkinType["贴纸"] or {} do
			if not (p and p[v4.cnId]) then
				table.insert(v3, v4.cnId)
			end
		end

		if #v3 < 6 then
			return nil
		end

		for i = #v3, 2, -1 do
			local v4 = math.random(i)
			local v5 = v3[v4]
			local v6 = v3[i]
			v3[i] = v5
			v3[v4] = v6
		end

		return {
			v3[1],
			v3[2],
			v3[3],
			v3[4],
			v3[5],
			v3[6]
		}
	end

	local function ensureAssigned(p)
		local stickers = PlayerData.server[p].stickers()

		if typeof(stickers) == "table" and #stickers == 6 then
			return
		end

		local v3 = pickRandomStickers(nil)

		if v3 then
			PlayerData.server[p].stickers(v3)
		else
			warn((`[StickerService] 表情池不足 {6} 种，跳过初始随机分配（玩家 {p.UserId}）`))
		end
	end

	function v.server.reroll(p)
		local stickers = PlayerData.server[p].stickers()
		local v3 = {}

		if typeof(stickers) == "table" then
			for _, sticker in stickers do
				v3[sticker] = true
			end
		end

		local v4 = pickRandomStickers(v3)

		if v4 then
			PlayerData.server[p].stickers(v4)
			return true
		end

		warn((`[StickerService] 表情池不足以避开当前持有的 {6} 个重新分配（玩家 {p.UserId}）`))
		return false
	end

	function v.server.init()
		-- equivalent calls inferred from this helper; original call sites unknown
		local function onPlayerAdded(p)
			task.spawn(function()
				PlayerData.server.Service:waitForData(p)

				if p.Parent ~= Players then
					return
				end

				ensureAssigned(p)
			end)
		end

		Players.PlayerAdded:Connect(onPlayerAdded)

		for _, v3 in Players:GetPlayers() do
			onPlayerAdded(v3) -- equivalent call inferred; original call site unknown
		end

		remoteEvent.OnServerEvent:Connect(function(p, value)
			if typeof(value) ~= "number" or value % 1 ~= 0 or value < 1 or value > 6 then
				return
			end

			local stickers = PlayerData.server[p].stickers()
			local v3

			if typeof(stickers) == "table" then
				v3 = stickers[value]
			else
				v3 = false
			end

			if typeof(v3) ~= "string" then
				return
			end

			local v4 = Config.skin.byCnId[v3]

			if not v4 then
				return
			end

			local now = TimeService.now()

			if now - (v2[p] or 0) < 2 then
				return
			end

			v2[p] = now

			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= p then
					remoteEvent:FireClient(player, p, v4.cnId)
				end
			end
		end)
		Players.PlayerRemoving:Connect(function(player)
			v2[player] = nil
		end)
	end

	return v
else
	local StickerEffects = require(ReplicatedStorage.Engine.Service.StickerEffects)
	remoteEvent.OnClientEvent:Connect(function(p, p2: string)
		StickerEffects.playForPlayer(p, p2)
	end)

	function v.client.send(p: number, p2: string)
		local localPlayer = Players.LocalPlayer

		if localPlayer then
			StickerEffects.playForPlayer(localPlayer, p2)
		end

		remoteEvent:FireServer(p)
	end

	return v
end