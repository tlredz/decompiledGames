local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CheckIn = require(ReplicatedStorage.Engine.Gui.CheckIn)
local OnlineReward = require(ReplicatedStorage.Engine.Gui.OnlineReward)
local UpdateLog = require(ReplicatedStorage.Engine.Gui.UpdateLog)
local RedeemCode = require(ReplicatedStorage.Engine.Gui.RedeemCode)
local Mail = require(ReplicatedStorage.Engine.Gui.Mail)
local DiamondDraw = require(ReplicatedStorage.Engine.Gui.DiamondDraw)
local TopbarPlus = require(ReplicatedStorage.Packages.TopbarPlus)
local RewardAutoOpenQueue = require(ReplicatedStorage.Engine.Gui.RewardAutoOpenQueue)
local RewardBadge = require(script.RewardBadge)
local v = nil
local RewardsMenu = {}

function RewardsMenu.SetTopbarEnabled(flag: boolean)
	RewardAutoOpenQueue.SetEnabled(flag)
	local RewardNotification = require(script.Parent.RewardNotification)
	RewardNotification.SetEnabled(flag)

	if v then
		v:setEnabled(flag)
	end

	CheckIn.SetTopbarEnabled(flag)
	OnlineReward.SetTopbarEnabled(flag)
	UpdateLog.SetTopbarEnabled(flag)
	RedeemCode.SetTopbarEnabled(flag)
	Mail.SetTopbarEnabled(flag)
	DiamondDraw.SetTopbarEnabled(flag)
end

function RewardsMenu.Init()
	v = TopbarPlus.new()
	v:setImage("rbxassetid://138140671021878"):setImageScale(0.85)
	v:setLeft()
	v:setOrder(4)
	local icon = CheckIn.GetIcon()
	local icon2 = OnlineReward.GetIcon()
	local icon3 = UpdateLog.GetIcon()
	local icon4 = RedeemCode.GetIcon()
	local icon5 = Mail.GetIcon()
	local icons = {}

	if icon4 then
		table.insert(icons, icon4)
	end

	if icon2 then
		table.insert(icons, icon2)
	end

	if icon5 then
		table.insert(icons, icon5)
	end

	if icon then
		table.insert(icons, icon)
	end

	if icon3 then
		table.insert(icons, icon3)
	end

	v:setDropdown(icons)
	RewardAutoOpenQueue.SetCanOpen(function()
		if v.isSelected then
			return false
		end

		for _, v2 in icons do
			if v2.isSelected then
				return false
			end
		end

		return true
	end)
	v:bindEvent("deselected", RewardAutoOpenQueue.Resume)

	for _, v2 in icons do
		v2:bindEvent("deselected", RewardAutoOpenQueue.Resume)
	end

	local function collapseDropdown()
		if v.isSelected then
			v:deselect()
		end
	end

	if icon then
		icon:bindEvent("selected", collapseDropdown)
	end

	if icon2 then
		icon2:bindEvent("selected", collapseDropdown)
	end

	if icon3 then
		icon3:bindEvent("selected", collapseDropdown)
	end

	if icon4 then
		icon4:bindEvent("selected", collapseDropdown)
	end

	if icon5 then
		icon5:bindEvent("selected", collapseDropdown)
	end

	for _, v2 in icons do
		local v3 = v2
		v2:bindEvent("selected", function()
			for k, v4 in icons do
				if v4 ~= v3 and v4.isSelected then
					v4:deselect()
				end
			end
		end)
	end

	RewardBadge.SetRoot(v)
end

return RewardsMenu