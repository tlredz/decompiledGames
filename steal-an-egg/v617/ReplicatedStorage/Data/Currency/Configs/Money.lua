local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage.Shared.Globals.Constants)
local InstanceCache = require(ReplicatedStorage.Packages.InstanceCache)
local Rarity = require(ReplicatedStorage.Data.Rarity)
local money = ReplicatedStorage.Assets.Models.Orbs.Money

local function orbSource()
	if Constants.IS_SERVER then
		return money
	end

	return InstanceCache.new(money, 1):SetExpandAmount(1)
end

local v = {
	DisplayName = "Money",
	Rarity = Rarity.Rarities.Uncommon,
	Desc = "",
	Icon = "rbxassetid://119640363267627",
	Sounds = {
		Single = {
			Data = {
				Volume = 0.5,
				Speed = { 0.95, 1.05 }
			},
			Ids = { "rbxassetid://122083641072193" }
		}
	},
	Instance = 0,
	_id = "Money"
}

if not Constants.IS_SERVER then
	money = InstanceCache.new(money, 1):SetExpandAmount(1)
end

v.Instance = money
return table.freeze(v)