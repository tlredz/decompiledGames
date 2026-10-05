local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local modules = ReplicatedStorage.Modules
local Janitor = require(modules.Janitor)
require(modules.Network)
local House = require(modules.Neighbors.House)
local ShopUtil = require(modules.ShopUtil)
local Data = require(modules.Data)
local assets = ReplicatedStorage.Assets
local HouseSkins = require(assets.Data.Store.HouseSkins)
Players.LocalPlayer.PlayerGui:WaitForChild("Neighbors"):WaitForChild("Shop")
local maid = Janitor.new()
local tweens = {}
local joint = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function stopTweens()
	for _, v in tweens do
		v:Cancel()
	end

	table.clear(tweens)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playTween(tweenInfo, p)
	stopTweens() -- equivalent call inferred; original call site unknown
	local tween = TweenService:Create(joint, tweenInfo, p)
	tween:Play()
	table.insert(tweens, tween)
end

local function doesOwnSkin(p: string)
	return Data.HouseSkins:Get(p) ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getSkin(name: string)
	for _, houseSkin in HouseSkins do
		if houseSkin.Name == name then
			return houseSkin
		end
	end

	return nil
end

local function onSkinChanged()
	local currentPrefab = House:GetCurrentPrefab()
	maid:Cleanup()

	if joint then
		stopTweens() -- equivalent call inferred; original call site unknown
		joint.C0 = joint:GetAttribute("Origin")
	end

	if currentPrefab then
		local model = currentPrefab.Model
		local mailbox = model:WaitForChild("Client"):WaitForChild("Shared").Mailbox
		local proximityPrompt = mailbox.Attachment.ProximityPrompt
		joint = mailbox.Joint
		joint:SetAttribute("Origin", joint.C0)
		proximityPrompt.ActionText = "View House"
		proximityPrompt.Enabled = true
		maid:Add(proximityPrompt.PromptShown:Connect(function()
			mailbox.PrimaryPart.Open:Play()
			playTween(TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
				C0 = joint:GetAttribute("Origin") * CFrame.Angles(0, 0, -1.5707963267948966)
			}) -- equivalent call inferred; original call site unknown
		end))
		maid:Add(proximityPrompt.PromptHidden:Connect(function()
			mailbox.PrimaryPart.Close:Play()
			playTween(TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				C0 = joint:GetAttribute("Origin")
			}) -- equivalent call inferred; original call site unknown
		end))
		maid:Add(proximityPrompt.Triggered:Connect(function()
			local skin = getSkin(model.Name) -- equivalent call inferred; original call site unknown

			if skin then
				ShopUtil:DisplayItemInfo(skin.Name)
			end
		end))
	end
end

House.ActiveHouseChanged:Connect(onSkinChanged)
House.ActiveSkinChanged:Connect(onSkinChanged)
Data.HouseSkins:GetPropertyChangedSignal("Items"):Connect(onSkinChanged)