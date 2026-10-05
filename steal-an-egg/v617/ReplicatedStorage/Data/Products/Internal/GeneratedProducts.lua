local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trails = require(ReplicatedStorage.Data.Trails)
local Treadmills = require(ReplicatedStorage.Data.Treadmills)
require(script.Parent.ProductTypes)
local Trail = require(script.Parent.Parent.Builders.Trail)
local Treadmill = require(script.Parent.Parent.Builders.Treadmill)
local TreadmillSpeedEquivalent = require(script.Parent.Parent.Builders.TreadmillSpeedEquivalent)
local frozen = table.freeze({
	table.freeze({
		ProductName = "TreadmillSpeed_5Minutes",
		DurationSeconds = 300,
		ProductId = 3612508008
	}),
	table.freeze({
		ProductName = "TreadmillSpeed_30Minutes",
		DurationSeconds = 1800,
		ProductId = 3612508088
	}),
	table.freeze({
		ProductName = "TreadmillSpeed_1Hour",
		DurationSeconds = 3600,
		ProductId = 3612508192
	}),
	table.freeze({
		ProductName = "TreadmillSpeed_4Hours",
		DurationSeconds = 14400,
		ProductId = 3612508244
	})
})
local v = {}

for k, v2 in Treadmills.Directory do
	local productId = v2.ProductId

	if type(productId) == "number" then
		table.insert(v, Treadmill(`Treadmill_{k}`, k, productId))
	end
end

for k, v2 in Trails.Directory do
	local productId = v2.ProductId

	if type(productId) == "number" then
		table.insert(v, Trail(`Trail_{k}`, k, productId))
	end
end

for _, v2 in frozen do
	assert(v2.ProductId > 0, (`Treadmill speed product "{v2.ProductName}" must have a positive ProductId`))
	table.insert(v, TreadmillSpeedEquivalent(v2.ProductName, v2.ProductId, v2.DurationSeconds))
end

return table.freeze({
	Records = table.freeze(v),
	TreadmillSpeedEquivalentOffers = frozen
})