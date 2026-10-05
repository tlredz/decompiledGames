local ReplicatedStorage = game:GetService("ReplicatedStorage")
local OfflineItem = require(ReplicatedStorage.Modules.Shared.Item.OfflineItem)
require(ReplicatedStorage.Modules.Shared.PlayerData.DevProducts)
require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local PayerTestItem = {}
PayerTestItem.__index = PayerTestItem
PayerTestItem.Inherits = { OfflineItem }

function PayerTestItem.Cast(p)
	return p
end

function PayerTestItem.new(id: string, payer: boolean, payerTimestamp: number, testName: string, testVariable: string, flag2: boolean, excludeGamepasses, flag3: boolean, product)
	return (setmetatable({
		id = id,
		payer = payer,
		payerTimestamp = payerTimestamp,
		testName = testName,
		testVariable = testVariable,
		test = flag2,
		excludeGamepasses = excludeGamepasses,
		inverted = flag3,
		product = product
	}, PayerTestItem))
end

function PayerTestItem.GetName(p)
	return p.id
end

function PayerTestItem.IsUnlockedServer(_, _)
	error("not implemented")
end

function PayerTestItem:IsUnlockedClient()
	return self:_IsUnlockedClient(nil) ~= self.inverted
end

function PayerTestItem:_IsUnlockedClient(_: number?)
	local ReplicatedDataController = require(ReplicatedStorage.Modules.Client.Data.ReplicatedDataController)
	local expect = ReplicatedDataController.GetReplicatedDataPromise():expect()

	if self.payer then
		if expect.payer == nil or expect.payer >= self.payerTimestamp then
			return true
		end
	elseif expect.payer ~= nil and expect.payer < self.payerTimestamp then
		return true
	end

	local v, v2 = ABTest.GetExperimentVariable(self.testName, self.testVariable):await()

	if self.test and not (v and v2) then
		return true
	end

	local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)

	for _, excludeGamepass in self.excludeGamepasses do
		if GamepassController.IsOwnedBefore(excludeGamepass, self.payerTimestamp) then
			return true
		end
	end

	return false
end

function PayerTestItem:IsUnlockedOrJustBoughtClient(p: number?)
	return self:_IsUnlockedClient(p) ~= self.inverted
end

return PayerTestItem