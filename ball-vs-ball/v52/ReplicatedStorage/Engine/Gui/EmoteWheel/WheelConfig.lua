local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Engine.Service.Config)
local PlayerData = require(ReplicatedStorage.Engine.Service.PlayerData)
local client = PlayerData.client
local EmoteWheelLoadoutService = require(ReplicatedStorage.Engine.Service.EmoteWheelLoadoutService)
local WheelConfig = {
	SlotCount = 8,
	FlyerOnlySlots = EmoteWheelLoadoutService.FLYER_ONLY_SLOTS
}
WheelConfig.AnglePerSlot = 360 / WheelConfig.SlotCount
WheelConfig.DeadZoneRatio = 0.22
WheelConfig.SummonKey = Enum.KeyCode.R
WheelConfig.SlotKeyCodes = {
	Enum.KeyCode.One,
	Enum.KeyCode.Two,
	Enum.KeyCode.Three,
	Enum.KeyCode.Four,
	Enum.KeyCode.Five,
	Enum.KeyCode.Six,
	Enum.KeyCode.Seven,
	Enum.KeyCode.Eight
}
WheelConfig.SlotNames = {}
WheelConfig.SlotContents = {}

local function slotEquipmentKey(p: number)
	return "表情轮盘_" .. tostring(p)
end

local v = {}

function WheelConfig.onLoadoutChanged(callback)
	table.insert(v, callback)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function notifyLoadoutChanged()
	for _, callback in v do
		task.spawn(callback)
	end
end

function WheelConfig.contentKey(p)
	if typeof(p) == "table" then
		return tostring(p.kind) .. ":" .. tostring(p.id)
	end

	return nil
end

function WheelConfig.refreshFromLoadout()
	local equipment = client.equipment()
	local items = client.items()

	for i = 1, WheelConfig.SlotCount do
		WheelConfig.SlotNames[i] = nil
		WheelConfig.SlotContents[i] = nil
		local v2

		if typeof(equipment) == "table" then
			v2 = equipment["表情轮盘_" .. tostring(i)]
		else
			v2 = false
		end

		if typeof(v2) == "table" and v2.kind == "freeEmote" and typeof(v2.id) == "string" then
			local v3 = Config.freeEmote.byCnId[v2.id]

			if v3 then
				WheelConfig.SlotNames[i] = v3.name
				WheelConfig.SlotContents[i] = {
					kind = "freeEmote",
					id = v3.cnId,
					name = v3.name,
					nameCn = v3.nameCn,
					rating = v3.rating,
					animation = v3.animation
				}
			end
		elseif typeof(v2) == "table" and v2.kind == "flyer" and typeof(v2.id) == "string" then
			local v3

			if typeof(items) == "table" then
				v3 = items[v2.id]
			else
				v3 = false
			end

			local v4

			if v3 then
				if v3.itemType == "飞行器" then
					v4 = Config.skin.byCnId[v3.itemId]
				else
					v4 = false
				end
			else
				v4 = v3
			end

			if v4 then
				WheelConfig.SlotNames[i] = v4.name
				WheelConfig.SlotContents[i] = {
					kind = "flyer",
					id = v2.id,
					itemId = v3.itemId,
					name = v4.name,
					nameCn = v4.nameCn,
					rating = v4.rating,
					assetName = v4.assetName
				}
			end
		end
	end

	notifyLoadoutChanged() -- equivalent call inferred; original call site unknown
end

WheelConfig.refreshFromLoadout()
client.equipment.Changed(WheelConfig.refreshFromLoadout)
client.items.Changed(WheelConfig.refreshFromLoadout)
WheelConfig.DefaultTitle = "Emotes"
WheelConfig.OpenDuration = 0.22
WheelConfig.CloseDuration = 0.16
WheelConfig.HighlightDuration = 0.12
WheelConfig.StaggerStep = 0.02
WheelConfig.PreviewBaseScale = 0.34
WheelConfig.PreviewHighlightMultiplier = 1.12
WheelConfig.PreviewConfirmMultiplier = 1.28
return WheelConfig