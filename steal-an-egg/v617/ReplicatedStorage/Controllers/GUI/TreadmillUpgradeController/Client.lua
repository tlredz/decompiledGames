local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
require(ReplicatedStorage.Shared.Globals.Constants)
local Log = require(ReplicatedStorage.Packages.Log)
local Toast = require(ReplicatedStorage.Client.Notifications.Toast)
local Storefront = require(ReplicatedStorage.Client.Functions.Storefront)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Save = require(ReplicatedStorage.Shared.Save)
require(ReplicatedStorage.Data.Treadmills)
local Treadmills = require(ReplicatedStorage.Data.Treadmills)
local color = Color3.fromRGB(255, 64, 64)
local v = Log.new()
local TreadmillUpgradeController = {
	GetNextConfig = function(p)
		t.strict(t.intersection(t.integer, t.numberMin(0)))(p.TreadmillUpgradeLevel)
		local v2 = p.TreadmillUpgradeLevel + 1
		return v2, Treadmills.GetByUpgradeLevel(v2)
	end
}

function TreadmillUpgradeController.CanAffordNext(p)
	local _, v2 = TreadmillUpgradeController.GetNextConfig(p)
	return v2 ~= nil and p.Money >= v2.Price
end

function TreadmillUpgradeController.RequestCashUpgrade()
	local v2 = Save.Await()
	assert(v2 ~= nil, "Treadmill cash upgrade requires loaded data")
	local _, v3 = TreadmillUpgradeController.GetNextConfig(v2)

	if v3 == nil then
		Toast.Show({
			Text = "Max treadmill upgrade reached",
			Seconds = 2
		})
		return false
	end

	if v2.Money < v3.Price then
		Toast.Show({
			Text = "Not enough money",
			Seconds = 2,
			Color = color
		})
		return false
	end

	local v4, v5 = Remotes.Treadmill.AskTierRaise:InvokeServer(v3._id)

	if v4 == true then
		return true
	end

	local text = v5 or "Treadmill upgrade failed"
	v:AtWarning():Log(text)
	Toast.Show({
		Text = text,
		Seconds = 2,
		Color = color
	})
	return false
end

function TreadmillUpgradeController.PromptRobuxUpgrade()
	local v2 = Save.Await()
	assert(v2 ~= nil, "Treadmill Robux upgrade requires loaded data")
	local _, v3 = TreadmillUpgradeController.GetNextConfig(v2)

	if v3 == nil then
		Toast.Show({
			Text = "Max treadmill upgrade reached",
			Seconds = 2
		})
		return false
	end

	local productId = v3.ProductId

	if productId == nil then
		v:AtWarning():Log((`Treadmill "{v3._id}" has no Robux upgrade product`))
		return false
	end

	Storefront.Prompt(productId, true)
	return true
end

return TreadmillUpgradeController