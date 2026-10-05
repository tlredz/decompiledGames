local parent = script.Parent
local Guard = require(parent.Guard)
local Network = require(parent.Network)
local PlayerData = require(parent.PlayerData)
local RunContext = require(parent.RunContext)
local MusicData = require(parent.MusicData)
local Players = game:GetService("Players")
local StudioService

if RunContext.IsEdit then
	StudioService = game:GetService("StudioService")
else
	StudioService = nil
end

local function OneString(...)
	local v = ...
	return Guard.String(v)
end

local event = Network.Event("RELICSxyz_PushRecentEmote", OneString)
local event2 = Network.Event("RELICSxyz_PushRecentSong", OneString)

local function getUserId()
	if RunContext.IsServer then
		return nil
	end

	if RunContext.IsEdit and StudioService then
		return StudioService:GetUserId()
	end

	local localPlayer = Players.LocalPlayer
	return localPlayer and localPlayer.UserId
end

local function pushRecentInternal(p: string, id: string, p3: number)
	local v = PlayerData.Get(p3)

	if not (v and v.IsLoaded) then
		warn("[Recents] Data not loaded for userId:", p3)
	elseif id == "" or id == nil then
		warn("[Recents] Empty itemId provided")
	else
		v:Patch(function(p4)
			local recents = p4.Recents
			local v2 = nil

			for k, recent in recents do
				if not (recent.Type == p and recent.Id == id) then
					continue
				end

				v2 = k
				break
			end

			if v2 then
				table.remove(recents, v2)
			end

			table.insert(recents, 1, {
				Type = p,
				Id = id
			})

			while #recents > 10 do
				table.remove(recents)
			end

			p4.Recents = recents
		end)
	end
end

local function pushRecentSong(id: string, p2: number?)
	if MusicData.IsSongOfEmote((`rbxassetid://{id}`)) then
		return
	end

	if RunContext.IsServer then
		if p2 then
			pushRecentInternal("SONG", id, p2)
		end
	elseif StudioService then
		pushRecentInternal("SONG", id, StudioService:GetUserId())
	else
		event2:Client():Fire(id)
	end
end

local function pushRecentAura(id: string, userId: number?)
	if not userId then
		if RunContext.IsServer then
			userId = nil
		elseif RunContext.IsEdit and StudioService then
			userId = StudioService:GetUserId()
		else
			local localPlayer = Players.LocalPlayer
			userId = localPlayer and localPlayer.UserId
		end
	end

	if userId then
		pushRecentInternal("AURA", id, userId)
	end
end

local function pushRecentEmote(id: string, p2: number?)
	if RunContext.IsServer then
		if p2 then
			pushRecentInternal("EMOTE", id, p2)
		end
	elseif StudioService then
		pushRecentInternal("EMOTE", id, StudioService:GetUserId())
	else
		event:Client():Fire(id)
	end
end

local function pushRecentSkin(id: string, userId: number?)
	if not userId then
		if RunContext.IsServer then
			userId = nil
		elseif RunContext.IsEdit and StudioService then
			userId = StudioService:GetUserId()
		else
			local localPlayer = Players.LocalPlayer
			userId = localPlayer and localPlayer.UserId
		end
	end

	if userId then
		pushRecentInternal("SKIN", id, userId)
	end
end

if RunContext.IsServer then
	event:Server():On(function(p, id: string)
		pushRecentInternal("EMOTE", id, p.UserId)
	end)
	event2:Server():On(function(p, id: string)
		pushRecentInternal("SONG", id, p.UserId)
	end)
end

return table.freeze({
	PushRecentSong = pushRecentSong,
	PushRecentAura = pushRecentAura,
	PushRecentEmote = pushRecentEmote,
	PushRecentSkin = pushRecentSkin,
	MAX_RECENTS = 10
})