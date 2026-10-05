local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local AdminPermissions = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminPermissions)
local AdminRemote = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminRemote)
require(ReplicatedStorage.Utilities.Promise)
local t = require(ReplicatedStorage.Packages.t)
local Items = require(ReplicatedStorage.FeatureConfigs.Items)
local Skins = require(ReplicatedStorage.FeatureConfigs.PersonalTreadmill.Skins)
local PersonalTreadmill = require(ReplicatedStorage.FeatureConfigs.PersonalTreadmill)
local Config = require(script.Parent.Config)
require(script.Parent.Types)
local isServer = RunService:IsServer()
local CodeVault

if isServer then
	CodeVault = require(ServerScriptService._FRAMEWORK.ServerFeatures.CodeVault)
else
	CodeVault = nil
end

for _, v in {
	"cui.admin.codes.reward.wins",
	"cui.admin.codes.reward.item",
	"cui.admin.codes.reward.signature",
	"cui.admin.codes.reward.limited",
	"cui.admin.codes.reward.skin",
	"cui.admin.codes.reward.treadmill"
} do
	AdminPermissions.registerPermission(v)
end

local strictInterface = t.strictInterface({
	kind = t.literal("wins", "item", "treadmillSkin", "treadmill"),
	amount = t.optional(t.integer),
	itemKey = t.optional(t.string),
	tier = t.optional(t.integer),
	signature = t.optional(t.integer),
	skinKey = t.optional(t.string),
	treadmillTier = t.optional(t.string)
})
local strictInterface2 = t.strictInterface({
	id = t.string,
	label = t.string,
	ownerUserId = t.intersection(t.integer, t.numberMin(1)),
	rewards = t.array(strictInterface),
	maxUses = t.intersection(t.integer, t.numberConstrained(0, Config.MAX_USES)),
	active = t.boolean,
	expiresInHours = t.intersection(t.integer, t.numberConstrained(0, Config.MAX_EXPIRY_HOURS))
})
local string2 = t.string

-- equivalent calls inferred from this helper; original call sites unknown
local function normalizeCode(id: string)
	return (string.gsub(string.upper(id), "[^A-Z0-9]", ""))
end

local function checkReward(p, reward, ownerUserId: number)
	if reward.kind == "wins" then
		local amount = reward.amount

		if not AdminPermissions.hasPermission(p.UserId, "cui.admin.codes.reward.wins") then
			return "You cannot add a Wins reward"
		end

		if amount == nil or amount < 1 or Config.MAX_WINS_PER_REWARD < amount then
			return (`Wins amount must be between 1 and {Config.MAX_WINS_PER_REWARD}`)
		end
	elseif reward.kind == "item" then
		local itemKey = reward.itemKey
		local amount = reward.amount
		local tier = reward.tier
		local signature = reward.signature

		if not AdminPermissions.hasPermission(p.UserId, "cui.admin.codes.reward.item") then
			return "You cannot add an item reward"
		end

		if itemKey == nil or Items.ITEMS[itemKey] == nil then
			return "Select a valid item"
		end

		if tier == nil or tier < 0 or Items.MAX_TIER < tier then
			return (`Item tier must be between 0 and {Items.MAX_TIER}`)
		end

		if amount == nil or amount < 1 or Config.MAX_ITEM_AMOUNT < amount then
			return (`Item amount must be between 1 and {Config.MAX_ITEM_AMOUNT}`)
		end

		if Items.IsLimitedKey(itemKey) and not AdminPermissions.hasPermission(
			p.UserId,
			"cui.admin.codes.reward.limited"
		) then
			return "You cannot add a limited item reward"
		end

		if signature ~= nil and signature < 1 then
			return "The signature UserId is invalid"
		end

		if signature ~= nil and signature ~= p.UserId and signature ~= ownerUserId and not AdminPermissions.hasPermission(
			p.UserId,
			"cui.admin.codes.reward.signature"
		) then
			return "You can only sign items with your own UserId or the code owner's"
		end
	elseif reward.kind == "treadmillSkin" then
		local skinKey = reward.skinKey

		if not AdminPermissions.hasPermission(p.UserId, "cui.admin.codes.reward.skin") then
			return "You cannot add a treadmill skin reward"
		end

		if skinKey == nil or Skins.SKINS[skinKey] == nil then
			return "Select a valid treadmill skin"
		end
	else
		local treadmillTier = reward.treadmillTier

		if not AdminPermissions.hasPermission(p.UserId, "cui.admin.codes.reward.treadmill") then
			return "You cannot add a treadmill reward"
		end

		if treadmillTier == nil or PersonalTreadmill.TIER_ENTITLEMENTS[treadmillTier] == nil then
			return "Select a valid treadmill tier"
		end
	end

	return nil
end

local function checkDefinition(p, data)
	local code = normalizeCode(data.id) -- equivalent call inferred; original call site unknown

	if #code < Config.MIN_CODE_LENGTH or #code > Config.MAX_CODE_LENGTH then
		return nil, (`The code must be {Config.MIN_CODE_LENGTH} to {Config.MAX_CODE_LENGTH} letters or digits`)
	end

	if #data.label < 1 or #data.label > Config.MAX_LABEL_LENGTH then
		return nil, (`The label must be 1 to {Config.MAX_LABEL_LENGTH} characters`)
	end

	if utf8.len(data.label) == nil then
		return nil, "The label contains invalid characters"
	end

	if #data.rewards < 1 or #data.rewards > Config.MAX_REWARDS_PER_CODE then
		return nil, (`A code carries 1 to {Config.MAX_REWARDS_PER_CODE} rewards`)
	end

	for k, reward in data.rewards do
		local v = checkReward(p, reward, data.ownerUserId)

		if v then
			return nil, (`Reward {k}: {v}`)
		end
	end

	return code, nil
end

local function resolveOwnerName(p: number)
	local playerByUserId = Players:GetPlayerByUserId(p)

	if playerByUserId then
		return playerByUserId.Name, nil
	end

	local success, nameFromUserIdAsync = pcall(Players.GetNameFromUserIdAsync, Players, p)

	if success then
		return tostring(nameFromUserIdAsync), nil
	end

	return nil, "Could not resolve the owner UserId"
end

local function buildRecord(p, id: string, name: string, data)
	local rewards = {}

	for k, reward in data.rewards do
		rewards[k] = {
			kind = reward.kind,
			amount = reward.amount,
			itemKey = reward.itemKey,
			tier = reward.tier,
			signature = reward.signature,
			skinKey = reward.skinKey,
			treadmillTier = reward.treadmillTier
		}
	end

	return {
		id = id,
		label = data.label,
		ownerUserId = data.ownerUserId,
		ownerName = name,
		rewards = rewards,
		maxUses = data.maxUses,
		uses = 0,
		active = data.active,
		createdAt = os.time(),
		createdBy = p.UserId,
		expiresAt = not (data.expiresInHours > 0) and 0 or os.time() + data.expiresInHours * 3600
	}
end

local function handleWrite(p, p2, flag: boolean)
	local v, v2 = strictInterface2(p2)

	if not v then
		return {
			ok = false,
			message = `Invalid code definition: {v2 or "unknown validation error"}`
		}
	end

	local id, message = checkDefinition(p, p2)

	if id == nil then
		return {
			ok = false,
			message = message
		}
	end

	local ownerUserId = p2.ownerUserId
	local playerByUserId = Players:GetPlayerByUserId(ownerUserId)
	local name, message2

	if playerByUserId then
		name = playerByUserId.Name
	else
		local success, nameFromUserIdAsync = pcall(Players.GetNameFromUserIdAsync, Players, ownerUserId)

		if success then
			name = tostring(nameFromUserIdAsync)
		else
			message2 = "Could not resolve the owner UserId"
		end
	end

	if name == nil then
		return {
			ok = false,
			message = message2
		}
	end

	local record = buildRecord(p, id, name, p2)
	local v6 = CodeVault

	if flag then
		local ok, message3 = v6.updateCode(id, {
			label = record.label,
			ownerUserId = record.ownerUserId,
			ownerName = record.ownerName,
			rewards = record.rewards,
			maxUses = record.maxUses,
			active = record.active,
			expiresAt = record.expiresAt
		})

		if ok then
			message3 = `Code {id} saved`
		end

		return {
			ok = ok,
			message = message3
		}
	else
		local code, message3 = v6.createCode(record)

		if code then
			message3 = `Code {id} created`
		end

		return {
			ok = code,
			message = message3
		}
	end
end

local clientEvent = AdminRemote.RegisterClientEvent("CodeSystem_Create", "cui.admin.codes.create", true, function(p, p2)
	return (handleWrite(p, p2, false))
end)
local clientEvent2 = AdminRemote.RegisterClientEvent(
	"CodeSystem_Update",
	"cui.admin.codes.create",
	true,
	function(p, p2)
		return (handleWrite(p, p2, true))
	end
)
local clientEvent3 = AdminRemote.RegisterClientEvent(
	"CodeSystem_Revoke",
	"cui.admin.codes.revoke",
	true,
	function(_, value: string)
		if not string2(value) then
			return {
				ok = false,
				message = "Invalid code id"
			}
		end

		local ok, v2 = CodeVault.revokeCode((string.gsub(string.upper(value), "[^A-Z0-9]", "")))
		return {
			ok = ok,
			message = ok and "Code revoked" or v2
		}
	end
)
local clientEvent4 = AdminRemote.RegisterClientEvent(
	"CodeSystem_Delete",
	"cui.admin.codes.revoke",
	true,
	function(_, value: string)
		if not string2(value) then
			return {
				ok = false,
				message = "Invalid code id"
			}
		end

		local ok, v2 = CodeVault.deleteCode((string.gsub(string.upper(value), "[^A-Z0-9]", "")))
		return {
			ok = ok,
			message = ok and "Code deleted" or v2
		}
	end
)
local clientEvent5 = AdminRemote.RegisterClientEvent("CodeSystem_List", "cui.admin.codes", false, function()
	return {
		ok = true,
		message = "",
		codes = CodeVault.listCodes()
	}
end)
local AdminRemotes = {}

function AdminRemotes.create(p)
	assert(not isServer, "CodeRedemption admin requests can only be sent from the client")
	return clientEvent:Fire(p)
end

function AdminRemotes.update(p)
	assert(not isServer, "CodeRedemption admin requests can only be sent from the client")
	return clientEvent2:Fire(p)
end

function AdminRemotes.revoke(p: string)
	assert(not isServer, "CodeRedemption admin requests can only be sent from the client")
	return clientEvent3:Fire(p)
end

function AdminRemotes.delete(p: string)
	assert(not isServer, "CodeRedemption admin requests can only be sent from the client")
	return clientEvent4:Fire(p)
end

function AdminRemotes.list()
	assert(not isServer, "CodeRedemption admin requests can only be sent from the client")
	return clientEvent5:Fire(nil)
end

function AdminRemotes.getPermissions()
	return {
		view = "cui.admin.codes",
		create = "cui.admin.codes.create",
		revoke = "cui.admin.codes.revoke"
	}
end

return AdminRemotes