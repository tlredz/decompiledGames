local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local RepeatableDevProducts = {
	All = TableUtil.Lock({
		BIRTHDAY_PARTY = {
			__REPEATABLE_DEV_PRODUCT = true
		},
		DANCE_PARTY = {
			__REPEATABLE_DEV_PRODUCT = true
		},
		TACO_PARTY = {
			__REPEATABLE_DEV_PRODUCT = true
		}
	})
}
RepeatableDevProducts.BIRTHDAY_PARTY = RepeatableDevProducts.All.BIRTHDAY_PARTY
RepeatableDevProducts.DANCE_PARTY = RepeatableDevProducts.All.DANCE_PARTY
RepeatableDevProducts.TACO_PARTY = RepeatableDevProducts.All.TACO_PARTY
local v = {
	[RepeatableDevProducts.All.BIRTHDAY_PARTY] = {
		id = 3512926612
	},
	[RepeatableDevProducts.All.DANCE_PARTY] = {
		id = 3519681840
	},
	[RepeatableDevProducts.All.TACO_PARTY] = {
		id = 3519680250
	}
}
local v2 = {}

for k, v3 in v do
	v2[v3.id] = k
end

local v3 = {}

for k, v4 in RepeatableDevProducts.All do
	v3[v4] = k
end

function RepeatableDevProducts.Exists(p: number)
	return v2[p] ~= nil
end

function RepeatableDevProducts.GetId(p)
	if p == nil then
		error("dev product is nil")
		return
	end

	if v[p] ~= nil then
		return v[p].id
	end

	error("In RepeatableDevProducts.GetId: received unknown product")
end

function RepeatableDevProducts.GetName(p)
	if p == nil then
		error("dev product is nil")
		return
	end

	if v3[p] ~= nil then
		return v3[p]
	end

	error("In RepeatableDevProducts.GetName: received unknown product")
end

function RepeatableDevProducts.GetById(p: number)
	if v2[p] ~= nil then
		return v2[p]
	end

	error("In RepeatableDevProducts.GetById: received unknown product id")
end

return RepeatableDevProducts