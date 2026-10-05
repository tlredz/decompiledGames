local parent = script.Parent
local Guard = require(parent.Guard)
local Signal = require(parent.Signal)
local Network = require(parent.Network)
local Promise = require(parent.Promise)
local PlayerData = require(parent.PlayerData)
local RunContext = require(parent.RunContext)
local Players = game:GetService("Players")

local function validateWheelSlot(data)
	if data == nil then
		return nil
	end

	if type(data) ~= "table" then
		error("Expected wheel slot to be a table")
	end

	local string = Guard.String(data.Type)
	local string2 = Guard.String(data.Id)

	if string ~= "AURA" and string ~= "EMOTE" and string ~= "SKIN" then
		error("Invalid wheel item type")
	end

	return {
		Type = string,
		Id = string2
	}
end

local function validateSetSlotPayload(p)
	if type(p) ~= "table" then
		error("Expected payload to be a table")
	end

	return {
		Slot = Guard.Number(p.Slot),
		Data = validateWheelSlot(p.Data)
	}
end

local event = Network.Event("RELICSxyz_EquipWheelSetSlot", validateSetSlotPayload)
local wheelChanged = Signal.new()
local v2 = {
	WheelChanged = wheelChanged,
	NUM_SLOTS = 8,
	GetWheelData = function(p: number?)
		local v3 = p or Players.LocalPlayer and Players.LocalPlayer.UserId

		if not v3 then
			return {}
		end

		local v4 = PlayerData.Read(v3)

		if v4 and v4.EquipWheel then
			return v4.EquipWheel
		end

		return {}
	end
}

function v2.GetSlot(p: number, p2: number?)
	if p < 1 or p > 8 then
		return nil
	end

	return v2.GetWheelData(p2)[p]
end

function v2.SetSlot(slot: number, p2)
	if slot < 1 or slot > 8 then
		return Promise.reject("Invalid slot number")
	end

	if RunContext.IsClient or RunContext.IsEdit then
		event:Client():Fire({
			Slot = slot,
			Data = p2
		})
		wheelChanged:Fire(slot, p2)
		return Promise.resolve()
	else
		return Promise.reject("SetSlot must be called from client")
	end
end

function v2.ClearSlot(p: number)
	return v2.SetSlot(p, nil)
end

function v2.ClearAll()
	local v3 = {}

	for i = 1, 8 do
		table.insert(v3, v2.ClearSlot(i))
	end

	return Promise.all(v3)
end

if RunContext.IsServer then
	event:Server():On(function(p, p2)
		local userId = p.UserId
		local v3 = PlayerData.Get(userId)

		if not (v3 and v3.IsLoaded) then
			return
		end

		local slot = p2.Slot
		local data = p2.Data

		if slot < 1 or slot > 8 then
			return
		end

		v3:Patch(function(p3)
			if not p3.EquipWheel then
				p3.EquipWheel = {}
			end

			p3.EquipWheel[slot] = data
		end):andThen(function()
			wheelChanged:Fire(slot, data)
		end)
	end)
end

return table.freeze(v2)