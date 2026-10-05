local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local KnownUsers = require(ReplicatedStorage.Cmdr.Menus.AdminMenu.KnownUsers)
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local ItemSignatureLabel = require(ReplicatedStorage._FRAMEWORK.Libraries.uiComponents.ItemSignatureLabel)
local Items = require(ReplicatedStorage.FeatureConfigs.Items)
local remo = require(ReplicatedStorage.Packages.remo)
local t = require(ReplicatedStorage.Packages.t)
local isServer = RunService:IsServer()
local intersection = t.intersection(t.integer, t.numberMin(1))
local intersection2 = t.intersection(t.integer, t.numberConstrained(0, Items.MAX_TIER))
local v = {
	[KnownUsers.Secret_Lokii] = true,
	[KnownUsers.Chichine] = true,
	[KnownUsers.LuckyMatg] = true,
	[KnownUsers.Fabuss254] = true,
	[KnownUsers.Lyzrinn] = true,
	[KnownUsers.FoeCakes] = true,
	[KnownUsers.Sano] = true,
	[KnownUsers.X3ll3n] = true,
	[KnownUsers.Nextune] = true,
	[KnownUsers.leorizoto] = true,
	[KnownUsers.Pinpin] = true
}
local ItemSignatures = {
	remotes = remo.createRemotes({
		itemSignatures = remo.namespace({
			signItem = remo.remote(t.string, intersection2, t.optional(intersection), t.optional(t.integer)).middleware(remo.throttleMiddleware(0.3))
		})
	}).itemSignatures
}

-- equivalent calls inferred from this helper; original call sites unknown
local function selectorIsValid(p: string, p2: number?, p3: number?)
	if Items.ITEMS[p] == nil or p3 == 0 then
		return false
	end

	if Items.IsLimitedKey(p) then
		return p2 ~= nil
	end

	return p2 == nil
end

local function entryMatches(p, p2: string, p3: number, p4: number?, p5: number?)
	return Items.KeyOf(p) == p2 and Items.TierOf(p) == p3 and Items.LimitedNumberOf(p) == p4 and Items.SignatureOf(p) == p5
end

local function sendInventoryUpdate(player, object, object2)
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	local itemAction

	if remotes then
		itemAction = remotes:FindFirstChild("ItemAction")
	end

	if itemAction and itemAction:IsA("RemoteEvent") then
		itemAction:FireClient(player, "Update", {
			Items = object:Get({}),
			EquippedItems = object2:Get({})
		})
	end
end

local function applySignature(p, store, store2, p2: string, p3: number, p4: number?, p5: number?)
	for _, v2 in {
		{
			store = store,
			entries = store:Get({})
		},
		{
			store = store2,
			entries = store2:Get({})
		}
	} do
		if type(v2.entries) ~= "table" then
			continue
		end

		local clone = table.clone(v2.entries)

		for k, v3 in clone do
			local v4

			if Items.KeyOf(v3) == p2 and Items.TierOf(v3) == p3 and Items.LimitedNumberOf(v3) == p4 then
				v4 = Items.SignatureOf(v3) == p5
			else
				v4 = false
			end

			if not v4 then
				continue
			end

			local copyEntry = Items.CopyEntry(v3)
			copyEntry.Signature = p.UserId
			clone[k] = copyEntry
			v2.store:Set(clone)
			sendInventoryUpdate(p, store, store2)
			return true
		end
	end

	return false
end

local function handleSignRequest(p, p2: string, p3: number, p4: number?, p5: number?)
	if v[p.UserId] == true then
		local DataManager = require(ServerScriptService.DataManager)
		local v2 = selectorIsValid(p2, p4, p5) -- equivalent call inferred; original call site unknown
		local store = DataManager:GetStore(p, "Items")
		local store2 = DataManager:GetStore(p, "EquippedItems")

		if v2 and store and store2 then
			applySignature(p, store, store2, p2, p3, p4, p5)
		end
	end
end

function ItemSignatures.createLabel(p)
	local signature = Items.SignatureOf(p)

	if signature then
		return (ItemSignatureLabel({
			userId = signature
		}))
	end

	return nil
end

function ItemSignatures.requestSign(p)
	if not isServer then
		ItemSignatures.remotes.signItem:fire(
			Items.KeyOf(p),
			Items.TierOf(p),
			Items.LimitedNumberOf(p),
			Items.SignatureOf(p)
		)
	end
end

FeatureManager.RegisterFeature(script.Name, {
	OnInit = function()
		if isServer then
			ItemSignatures.remotes.signItem:connect(handleSignRequest)
		end
	end
})
return ItemSignatures