local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Net = require(ReplicatedStorage.Packages.Net)
local Config = require(script.Parent.Config)
local PlayerData = require(script.Parent.PlayerData)
local v = {
	[4] = true,
	[5] = true,
	[6] = true
}
local v2 = { 4, 5, 6 }
local remoteFunction = Net:RemoteFunction("EmoteWheelLoadout/SetSlot")
local flag = false

local function normalizeSlotIndex(value)
	if typeof(value) == "number" and value % 1 == 0 and not (value < 1 or value > 8) then
		return value
	end

	return nil
end

local function validateSelection(p, value: number, p2)
	if typeof(p2) ~= "table" or typeof(p2.kind) ~= "string" or typeof(p2.id) ~= "string" then
		return nil
	end

	if p2.kind == "freeEmote" then
		if v[value] or Config.freeEmote.byCnId[p2.id] == nil then
			return nil
		end

		return {
			kind = "freeEmote",
			id = p2.id
		}
	else
		if p2.kind ~= "flyer" then
			return nil
		end

		local v3 = PlayerData.server[p].items[p2.id]()

		if typeof(v3) == "table" and v3.ownerUserId == p.UserId and v3.itemType == "飞行器" and next(v3.locks or {}) == nil then
			return {
				kind = "flyer",
				id = p2.id
			}
		end

		return nil
	end
end

local function setSlot(p, value, p2)
	assert(RunService:IsServer(), "EmoteWheelLoadoutService.setSlot 只能在服务器调用")

	if typeof(value) ~= "number" or value % 1 ~= 0 or value < 1 or value > 8 then
		value = nil
	end

	if not value then
		return false
	end

	PlayerData.server.Service:waitForData(p)

	if p.Parent == nil then
		return false
	end

	local v3 = validateSelection(p, value, p2)

	if not v3 then
		return false
	end

	PlayerData.server[p].equipment(function(p3)
		local selected = typeof(p3) ~= "table" and {} or table.clone(p3)
		selected["表情轮盘_" .. tostring(value)] = v3
		return selected
	end)
	return true
end

return {
	SLOT_COUNT = 8,
	FLYER_ONLY_SLOTS = v,
	slotKey = function(p: number)
		return "表情轮盘_" .. tostring(p)
	end,
	server = {
		init = function()
			assert(RunService:IsServer(), "EmoteWheelLoadoutService.server.init 只能在服务器调用")

			if flag then
				return
			end

			flag = true
			remoteFunction.OnServerInvoke = setSlot
		end,
		setSlot = setSlot,
		autoEquipFlyer = function(p, id: string)
			assert(RunService:IsServer(), "EmoteWheelLoadoutService.autoEquipFlyer 只能在服务器调用")
			PlayerData.server.Service:waitForData(p)

			if p.Parent == nil then
				return false
			end

			local equipment = PlayerData.server[p].equipment()

			for _, v3 in ipairs(v2) do
				if equipment["表情轮盘_" .. tostring(v3)] == nil then
					return (setSlot(p, v3, {
						kind = "flyer",
						id = id
					}))
				end
			end

			return false
		end
	},
	client = {
		setSlot = function(p: number, p2)
			return remoteFunction:InvokeServer(p, p2) == true
		end
	}
}