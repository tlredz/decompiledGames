local import = _G.import("event")
_G.import("global")
local import2 = _G.import("aura")
_G.import("dictUtil")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")
local import3 = _G.import("class")
local import4 = _G.import("debounceState")
local import5 = _G.import("rewardState")
local import6 = _G.import("itemModules")
local import7 = _G.import("passState")
local import8 = _G.import("policyState")
local v = import3.new(import4, import5, import7, import8)

function v:resetCharacterData()
	return {
		AttackCombo = 1,
		CooldownInstances = {},
		Form = 1,
		Selected = 1,
		AbilityMana = {}
	}
end

function v:getSelectedItem(p)
	return import6:getLeaf(self:getSelectedItemInstance(p).Id).Value
end

function v:getSelectedItemInstance(p)
	return self.PlayerSave:get("Equip", p, self.Character.Selected)
end

function v:hasPass(p2)
	local gamePassCache = self.GamePassCache
	local v2 = tostring(p2)
	local selected = gamePassCache[v2] or MarketplaceService:UserOwnsGamePassAsync(self.UserId, (tonumber(p2)))
	gamePassCache[v2] = selected
	return selected
end

function v.addPass(p, p2)
	p.GamePassCache[tostring(p2)] = true
end

function v:hasSubscription(p)
	self.SubscriptionCache = self.SubscriptionCache or {}
	local v2 = tostring(p)
	local v3 = self.SubscriptionCache[v2]

	if v3 ~= nil then
		return v3
	end

	local playerByUserId = game.Players:GetPlayerByUserId(self.UserId)

	if not playerByUserId then
		return false
	end

	local success, result = pcall(function()
		return MarketplaceService:GetUserSubscriptionStatusAsync(playerByUserId, p)
	end)
	local v4 = success and result and result.IsSubscribed == true and true or false
	self.SubscriptionCache[v2] = v4
	return v4
end

function v:setSubscription(p2, p3)
	self.SubscriptionCache = self.SubscriptionCache or {}
	self.SubscriptionCache[tostring(p2)] = p3
end

function v.hasVip(p)
	return p.PlayerSave:hasPass(1854105063)
end

function v.itemInInventory(p, p2, p3, p4)
	return p.PlayerSave[p2][p3][p4]
end

function v.registerAura(p, p2, p3)
	local v2 = import2.applyAura(game.Players:GetPlayerByUserId(p.UserId), p2, p3)
	p.Auras[p2] = p.Auras[p2] or {}
	local aura = p.Auras[p2]
	aura:table_insert(#aura, v2)
	return v2
end

function v.popAura(p, p2)
	local aura = p.Auras[p2]

	if not aura then
		return
	end

	local table_remove = aura:table_remove(#aura)

	if not table_remove then
		return
	end

	import2.removeAuraInstance(game.Players:GetPlayerByUserId(p.UserId), table_remove)
end

function v.character(p)
	return game.Players:GetPlayerByUserId(p.UserId).Character
end

function v.stopActiveEmote(player)
	local character = game.Players:GetPlayerByUserId(player.UserId).Character

	if not character then
		return
	end

	local activeEmote = player.Character.ActiveEmote

	if not activeEmote then
		return
	end

	activeEmote.Animation:Stop()
	import2.removeAuraInstance(character, activeEmote.Rig)
	player.Character.ActiveEmote = nil
end

function v:new(p, playerSave)
	self.PlayerSave = playerSave
	self.UserId = p.UserId
	self.Connections = {}
	self.Auras = {}
	self.ActiveCooldowns = {}
	self.JoinTime = os.time()
	self.SessionId = HttpService:GenerateGUID(false)
	self.InvitePopupCount = 0
	self.GamePassCache = {}
	self.SubscriptionCache = {}
	import7.new(self, p, playerSave)
	import8.new(self, p)
	self.Character = self:resetCharacterData()
	import.connect("characterAdded", function(_, _, _, object2)
		object2.Character = object2:resetCharacterData()
	end)
end

function v.postShell(_) end

return v