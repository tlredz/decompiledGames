local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local v = {
	"pause_gameplay",
	"Stun",
	"CombatStun",
	"Strict_Stun"
}
local ToolLock = {
	Attribute = "LockedToolSlot"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function characterOf(player)
	if typeof(player) == "Instance" and player:IsA("Player") then
		return player.Character
	end

	return nil
end

function ToolLock.SlotOf(player)
	local v2 = characterOf(player) -- equivalent call inferred; original call site unknown

	if v2 == nil then
		return nil
	end

	local lockedToolSlot = v2:GetAttribute("LockedToolSlot")

	if typeof(lockedToolSlot) == "number" then
		return lockedToolSlot
	end

	return nil
end

function ToolLock.Lock(instance)
	local v2 = characterOf(instance) -- equivalent call inferred; original call site unknown

	if v2 == nil then
		return
	end

	local items_Config = instance:FindFirstChild("Items_Config") or instance:FindFirstChild("Items_ConfigServer")
	local equipped

	if items_Config ~= nil then
		equipped = items_Config:FindFirstChild("Equipped") or nil
	end

	if equipped == nil or not equipped:IsA("ValueBase") then
		return
	end

	v2:SetAttribute("LockedToolSlot", equipped.Value)
end

function ToolLock.Busy(player)
	local v2 = characterOf(player) -- equivalent call inferred; original call site unknown

	if v2 == nil then
		return false
	end

	local SHCS = v2:FindFirstChild("SHCS")

	if SHCS ~= nil and SHCS:IsA("StringValue") and SHCS.Value ~= "" then
		return true
	end

	local getvaluesfolder = Utility.getvaluesfolder(player)

	if getvaluesfolder == nil then
		return false
	end

	for _, childName in v do
		if getvaluesfolder:FindFirstChild(childName) ~= nil then
			return true
		end
	end

	return false
end

function ToolLock.Take(player)
	local v2 = characterOf(player) -- equivalent call inferred; original call site unknown

	if v2 == nil then
		return
	end

	local lockedToolRefs = v2:GetAttribute("LockedToolRefs")
	v2:SetAttribute("LockedToolRefs", (typeof(lockedToolRefs) ~= "number" and 0 or lockedToolRefs) + 1)
end

function ToolLock.Release(player)
	local v2 = characterOf(player) -- equivalent call inferred; original call site unknown

	if v2 == nil then
		return
	end

	local lockedToolRefs = v2:GetAttribute("LockedToolRefs")
	local v3 = (typeof(lockedToolRefs) ~= "number" and 0 or lockedToolRefs) - 1

	if not (v3 > 0) then
		v3 = nil
	end

	v2:SetAttribute("LockedToolRefs", v3)
	ToolLock.ReleaseIfFree(player)
end

function ToolLock.ReleaseIfFree(player)
	local v2 = characterOf(player) -- equivalent call inferred; original call site unknown

	if not (v2 ~= nil and v2:GetAttribute("LockedToolSlot") ~= nil and typeof(v2:GetAttribute("LockedToolRefs")) ~= "number") then
		return false
	end

	if ToolLock.Busy(player) then
		return false
	end

	v2:SetAttribute("LockedToolSlot", nil)
	return true
end

function ToolLock.Clear(player)
	local v2 = characterOf(player) -- equivalent call inferred; original call site unknown

	if v2 == nil then
		return
	end

	v2:SetAttribute("LockedToolSlot", nil)
	v2:SetAttribute("LockedToolRefs", nil)
end

return ToolLock