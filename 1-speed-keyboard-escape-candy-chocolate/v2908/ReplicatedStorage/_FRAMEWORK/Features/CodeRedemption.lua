local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
require(ReplicatedStorage.Utilities.Promise)
local remo = require(ReplicatedStorage.Packages.remo)
local t = require(ReplicatedStorage.Packages.t)
local Vide = require(ReplicatedStorage.Packages.Vide)
local AdminRemotes = require(script.AdminRemotes)
local CodeModal = require(script.CodeModal)
local Common = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.Common)
local Items = require(ReplicatedStorage.FeatureConfigs.Items)
local Skins = require(ReplicatedStorage.FeatureConfigs.PersonalTreadmill.Skins)
local PersonalTreadmill = require(ReplicatedStorage.FeatureConfigs.PersonalTreadmill)
local Config = require(script.Config)
require(script.Types)
local isServer = RunService:IsServer()
local CodeVault

if isServer then
	CodeVault = require(ServerScriptService._FRAMEWORK.ServerFeatures.CodeVault)
else
	CodeVault = nil
end

local ClientState

if isServer then
	ClientState = nil
else
	ClientState = require(ReplicatedStorage.ClientState)
end

local Icon

if isServer then
	Icon = nil
else
	Icon = require(ReplicatedStorage.TopbarPlus.Icon)
end

local status = nil
local message = nil
local label = nil
local ownerName = nil
local ownerUserId = nil
local rewards2 = nil
local v7 = nil
local v8 = nil
local flag = false
local v9 = false
local flag2 = false
local CodeRedemption = {
	remotes = remo.createRemotes({
		codeRedemption = remo.namespace({
			claimCode = remo.remote(t.string).returns().middleware(remo.throttleMiddleware({
				throttle = Config.CLAIM_THROTTLE
			}))
		})
	}).codeRedemption,
	admin = AdminRemotes
}

local function handleClaim(p, p2: string)
	local code = CodeRedemption.normalizeCode(p2)

	if #code >= Config.MIN_CODE_LENGTH and #code <= Config.MAX_CODE_LENGTH then
		return CodeVault.claim(p, code)
	end

	return {
		ok = false,
		reason = "invalid_code"
	}
end

local function rewardView(reward)
	if reward.kind == "wins" then
		return {
			icon = "rbxassetid://15540211845",
			title = "Wins",
			detail = "Added to this galaxy",
			amount = "x" .. reward.amount
		}
	end

	if reward.kind == "item" then
		local v10 = Items.ITEMS[reward.itemKey]
		local v11 = not reward.signature and "" or " - signed " .. reward.signature
		return {
			icon = v10.icon,
			title = v10.name,
			detail = "Tier " .. reward.tier .. v11,
			amount = "x" .. reward.amount
		}
	elseif reward.kind == "treadmillSkin" then
		local v10 = Skins.SKINS[reward.skinKey]
		return {
			icon = v10.icon,
			title = v10.displayName,
			detail = "Treadmill skin"
		}
	else
		local v10 = Skins.SKINS[PersonalTreadmill.TIER_ENTITLEMENTS[reward.treadmillTier].skinKey]
		return {
			icon = v10.icon,
			title = v10.displayName,
			detail = "Treadmill access"
		}
	end
end

local function showResult(data)
	local v10 = status
	local v11 = message
	local v12 = label
	local v13 = ownerName
	local v14 = ownerUserId
	local v15 = rewards2

	if data.ok then
		local rewards = data.rewards
		local v16 = table.create(#rewards)

		for k, reward in rewards do
			v16[k] = rewardView(reward)
		end

		v10("success")
		v11(Config.SUCCESS_MESSAGE)
		v12(data.label)
		v13(data.ownerName)
		v14(data.ownerUserId)
		v15(v16)
	else
		v10("error")

		if data.retryAfter then
			v11(string.format(Config.RETRY_AFTER_TEMPLATE, data.retryAfter))
		else
			v11(CodeRedemption.getReasonMessage(data.reason))
		end

		v12("")
		v13("")
		v14(0)
		v15({})
	end
end

local function submitCode(p: string)
	if flag2 then
		return
	end

	local code = CodeRedemption.normalizeCode(p)
	local v10 = status
	local v11 = message

	if #code < Config.MIN_CODE_LENGTH then
		v10("error")
		v11(string.format(Config.SHORT_MESSAGE_TEMPLATE, Config.MIN_CODE_LENGTH))
	else
		flag2 = true
		v10("sending")
		v11(Config.SENDING_MESSAGE)
		CodeRedemption.claim(code):andThen(function(p2)
			flag2 = false
			showResult(p2)
		end):catch(function()
			flag2 = false
			showResult({
				ok = false,
				reason = "internal"
			})
		end)
	end
end

local v10 = {
	OnClose = function()
		flag = false
		v9 = true

		if v8 then
			v8:deselect()
		end

		v9 = false
	end
}

local function openModal()
	local v11 = v7

	if v11 then
		flag = true
		ClientState:ToggleModal(v11, v10)
	end
end

local function mountTopBarIcon()
	v8 = Icon.new():setName(Config.BUTTON_NAME):setLabel(Config.BUTTON_LABEL)
	v8.selected:Connect(function()
		local v11 = not v9 and v7

		if v11 then
			flag = true
			ClientState:ToggleModal(v11, v10)
		end
	end)
	v8.deselected:Connect(function()
		if not v9 and flag then
			ClientState:CloseCurrentModal()
		end
	end)
end

local function clientUIInit()
	local speedGameUI = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("SpeedGameUI")
	status = Vide.source("idle")
	message = Vide.source(Config.IDLE_MESSAGE)
	label = Vide.source("")
	ownerName = Vide.source("")
	ownerUserId = Vide.source(0)
	rewards2 = Vide.source({})
	Vide.mount(function()
		local codeModal = CodeModal({
			Visible = false,
			Status = status,
			Message = message,
			Label = label,
			OwnerName = ownerName,
			OwnerUserId = ownerUserId,
			Rewards = rewards2,
			OnSubmit = submitCode,
			OnClose = function()
				ClientState:CloseCurrentModal()
			end
		})
		codeModal:SetAttribute("ModalVisibleY", Config.MODAL_VISIBLE_Y)
		v7 = codeModal
		return codeModal
	end, speedGameUI)
	mountTopBarIcon()
end

function CodeRedemption.normalizeCode(value: string)
	return (string.gsub(string.upper(value), "[^A-Z0-9]", ""))
end

function CodeRedemption.generateCode()
	local random = Common.GetRandom()
	local GENERATED_ALPHABET = Config.GENERATED_ALPHABET
	local v11 = table.create(Config.GENERATED_CODE_LENGTH)

	for i = 1, Config.GENERATED_CODE_LENGTH do
		local integer = random:NextInteger(1, #GENERATED_ALPHABET)
		v11[i] = string.sub(GENERATED_ALPHABET, integer, integer)
	end

	return table.concat(v11)
end

function CodeRedemption.getLimits()
	return Config
end

function CodeRedemption.getReasonMessage(p)
	return Config.REASON_MESSAGES[p]
end

function CodeRedemption.claim(p: string)
	assert(not isServer, "CodeRedemption.claim is client-only")
	return (CodeRedemption.remotes.claimCode:request(CodeRedemption.normalizeCode(p)))
end

function CodeRedemption.toggle()
	assert(not isServer, "CodeRedemption.claim is client-only")
	local v11 = v8

	if v11 then
		if flag then
			v11:deselect()
		else
			v11:select()
		end
	end
end

FeatureManager.RegisterFeature(script.Name, {
	OnInit = function()
		if Config.ENABLED and isServer then
			CodeRedemption.remotes.claimCode:onRequest(handleClaim)
		end
	end,
	OnUIInit = function()
		if Config.ENABLED and not isServer then
			clientUIInit()
		end
	end
})
return CodeRedemption