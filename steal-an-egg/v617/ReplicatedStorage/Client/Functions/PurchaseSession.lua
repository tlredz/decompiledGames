local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CashPacks = require(ReplicatedStorage.Data.CashPacks)
local GameFlags = require(ReplicatedStorage.Shared.Flags.GameFlags)
local Gamepasses = require(ReplicatedStorage.Data.Gamepasses)
local PurchaseLedger = require(ReplicatedStorage.Client.Functions.PurchaseLedger)
local Products = require(ReplicatedStorage.Data.Products)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local v = {
	Busy = "Wrap up the purchase window that's already open before starting another one.",
	Disabled = "Purchases are paused for a moment while Roblox catches up. Please try again shortly.",
	Owned = "You already own this!",
	Pending = "Roblox is still confirming your last attempt to buy this. If it never arrives, rejoin and it will sync.",
	Screened = "This item isn't available to buy right now.",
	Settled = "This one-time item already went through on your account. Rejoin if it hasn't shown up yet.",
	Unavailable = "The shop couldn't open that purchase. Please try again in a moment.",
	UnknownSku = "We couldn't find that item in the shop. If this keeps happening, let our support team know."
}
local v2 = {
	Owned = true
}
local v3 = {
	Silent = true
}
local localPlayer = Players.LocalPlayer

local function refusal(refusal2: string, note: string?)
	return {
		Refusal = refusal2,
		Note = note
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refuse(refusal2: string, note: string?)
	local Message = require(ReplicatedStorage.Client.Message)
	local v5 = note or v[refusal2]

	if v2[refusal2] then
		Message.Notice(v5)
	else
		Message.Warn(v5)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function chime()
	local Audio = require(ReplicatedStorage.Shared.Audio)
	Audio.Play(129627240635324, script, {
		PlaybackSpeed = 1.3,
		Volume = 0.6
	})
end

local function askServer(object, p: number)
	local success, result, v5 = pcall(function()
		return object:InvokeServer(p)
	end)
	local v6 = success and result == true

	if success and type(v5) == "string" then
		return v6, v5
	end

	return v6, nil
end

local function storefrontOpen(_)
	if GameFlags.StorefrontOpen:Get() then
		return nil
	end

	return {
		Refusal = "Disabled",
		Note = nil
	}
end

local function knownSku(p)
	if p.Config == nil then
		return {
			Refusal = "UnknownSku",
			Note = nil
		}
	end

	return nil
end

local function configVeto(p)
	local precheck = p.Config.Precheck

	if precheck == nil then
		return nil
	end

	local success, result, note = pcall(precheck)

	if not success then
		warn((`purchase precheck raised an error: {result}`))
		return {
			Refusal = "Screened",
			Note = nil
		}
	end

	if result == true then
		return nil
	end

	if type(note) ~= "string" then
		note = nil
	end

	return {
		Refusal = "Screened",
		Note = note
	}
end

local function playCue(_)
	chime() -- equivalent call inferred; original call site unknown
	return nil
end

local function noOpenPrompt(_)
	if PurchaseLedger.HasOpenTicket() then
		return {
			Refusal = "Busy",
			Note = nil
		}
	end

	return nil
end

local function oneTimeNotRepeated(p)
	if not (p.Config.OneTime and GameFlags.OneTimeRepeatGuard:Get()) then
		return nil
	end

	if PurchaseLedger.OwnedPerProfile(p.SkuId) then
		return {
			Refusal = "Settled",
			Note = nil
		}
	end

	if PurchaseLedger.AwaitingReceipt(p.SkuId) then
		return {
			Refusal = "Pending",
			Note = nil
		}
	end

	return nil
end

local function serverApproves(p)
	local ticket = PurchaseLedger.OpenTicket(p.SkuId)
	p.Ticket = ticket

	if CashPacks.FindSlot(p.SkuId) then
		return nil
	end

	local askServerProbe = Remotes.Storefront.AskServerProbe
	local skuId = p.SkuId
	local success, result, note = pcall(function()
		return askServerProbe:InvokeServer(skuId)
	end)
	local v6 = success and result == true

	if not success or type(note) ~= "string" then
		note = nil
	end

	if not ticket.Live then
		return v3
	end

	if v6 then
		return nil
	end

	PurchaseLedger.CloseTicket(p.SkuId)
	return {
		Refusal = "Unavailable",
		Note = note
	}
end

local function promptFromClient(p)
	local ticket = p.Ticket

	if pcall(MarketplaceService.PromptProductPurchase, MarketplaceService, localPlayer, p.SkuId) or not ticket.Live then
		return v3
	end

	PurchaseLedger.CloseTicket(p.SkuId)
	return {
		Refusal = "Unavailable",
		Note = nil
	}
end

local function promptFromServer(p)
	local ticket = p.Ticket
	local askPurchaseOffer = Remotes.Storefront.AskPurchaseOffer
	local skuId = p.SkuId
	local success, result, note = pcall(function()
		return askPurchaseOffer:InvokeServer(skuId)
	end)
	local v6 = success and result == true

	if not success or type(note) ~= "string" then
		note = nil
	end

	if not ticket.Live then
		return v3
	end

	if v6 then
		return nil
	end

	PurchaseLedger.CloseTicket(p.SkuId)
	return {
		Refusal = "Unavailable",
		Note = note
	}
end

local function openProductPrompt(p)
	if CashPacks.FindSlot(p.SkuId) == nil and GameFlags.ClientSidePrompts:Get() then
		local ticket = p.Ticket

		if pcall(MarketplaceService.PromptProductPurchase, MarketplaceService, localPlayer, p.SkuId) or not ticket.Live then
			return v3
		end

		PurchaseLedger.CloseTicket(p.SkuId)
		return {
			Refusal = "Unavailable",
			Note = nil
		}
	else
		local ticket = p.Ticket
		local askPurchaseOffer = Remotes.Storefront.AskPurchaseOffer
		local skuId = p.SkuId
		local success, result, note = pcall(function()
			return askPurchaseOffer:InvokeServer(skuId)
		end)
		local v6 = success and result == true

		if not success or type(note) ~= "string" then
			note = nil
		end

		if not ticket.Live then
			return v3
		end

		if v6 then
			return nil
		end

		PurchaseLedger.CloseTicket(p.SkuId)
		return {
			Refusal = "Unavailable",
			Note = note
		}
	end
end

local function passNotOwned(p)
	local Gamepasses2 = require(ReplicatedStorage.Client.Gamepasses)

	if Gamepasses2.Owns(p.Config.Name) then
		return {
			Refusal = "Owned",
			Note = nil
		}
	end

	return nil
end

local function openPassPrompt(p)
	MarketplaceService:PromptGamePassPurchase(localPlayer, p.SkuId)
	return nil
end

local v5 = {
	storefrontOpen,
	knownSku,
	noOpenPrompt,
	oneTimeNotRepeated,
	configVeto,
	serverApproves,
	playCue,
	openProductPrompt
}
local v6 = {
	storefrontOpen,
	knownSku,
	passNotOwned,
	configVeto,
	playCue,
	openPassPrompt
}

local function run(items, p)
	for _, item in items do
		local v7 = item(p)

		if v7 == nil then
			continue
		end

		if v7.Refusal == nil then
			break
		end

		refuse(v7.Refusal, v7.Note) -- equivalent call inferred; original call site unknown
		break
	end
end

return table.freeze({
	Request = function(skuId: number, flag: boolean?)
		assert(RunService:IsClient(), "purchases are requested from the client")
		assert(type(skuId) == "number", "PurchaseSession.Request needs a numeric SKU id")

		if flag then
			run(v5, {
				SkuId = skuId,
				Config = Products.FromProductId(skuId),
				Ticket = nil
			})
		else
			run(v6, {
				SkuId = skuId,
				Config = Gamepasses.FromProductId(skuId),
				Ticket = nil
			})
		end
	end
})