local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local TextUtil = require(game.ReplicatedStorage.Modules.Util.TextUtil)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
local TimeUtil = require(game.ReplicatedStorage.Modules.Util.TimeUtil)
local Cousin = require(game.ReplicatedStorage.React.Components.Gacha.Windows.Cousin)
require(game.ReplicatedStorage.Modules.Gacha.SharedGachaTypes)
require(game.ReplicatedStorage.Modules.Gacha.ClientBannerTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local v = {
	{
		Ids = { 814 },
		Sprite = SpriteMap.PhysicalMovesets["Werewolf (Tiger)-Werewolf (Tiger)1"],
		Starts = DateTime.now().UnixTimestamp + 0,
		Ends = DateTime.now().UnixTimestamp + 172800,
		Title = "<Werewolf (Tiger)> Rollable!",
		BoxName = "ZiolesGacha",
		UID = 2
	},
	{
		Ids = { 884, 885 },
		Sprite = SpriteMap.All["Dragon-Dragon1"],
		Starts = DateTime.now().UnixTimestamp + 0,
		Ends = DateTime.now().UnixTimestamp + 172800,
		Title = "<Dragon (West)> and <Dragon (East)> Rollable!",
		BoxName = "ZiolesGacha",
		UID = 3
	}
}
local UIDs = { 1 }
local v2 = {
	BoxName = "ZiolesGacha",
	Cost = {
		Name = "Money",
		Value = 90
	}
}

for _, v3 in pairs(v) do
	table.insert(UIDs, v3.UID)
end

local createElement = React.createElement

local function tryFindBannerItem(p: number)
	for _, v3 in pairs(v) do
		if p == v3.UID then
			return v3
		end
	end

	return nil
end

return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		BannerItem = UILabs.Choose(UIDs, 2),
		Money = UILabs.Number(0, 0, v2.Cost.Value, (math.clamp(v2.Cost.Value / 10, 1, v2.Cost.Value))),
		Cost = UILabs.Number(90, 0, v2.Cost.Value, (math.clamp(v2.Cost.Value / 10, 1, v2.Cost.Value))),
		SilverKeys = UILabs.Number(0, 0, 20, 1)
	}
}, function(p)
	local cost = v2.Cost
	local state, setState = React.useState(true)
	local state2, setState2 = React.useState({
		Value = nil,
		UID = 1
	})
	local v3 = React.useMemo(function()
		return {
			Name = cost.Name,
			Value = p.controls.Cost
		}
	end, { p.controls.Cost })

	-- equivalent calls inferred from this helper; original call sites unknown
	local function sendNotif(p2: string?)
		setState2({
			Value = p2,
			UID = state2.UID + 1
		})
	end

	local state3, setState3 = React.useState(nil)
	local state4, setState4 = React.useState(false)
	local bannerItem2 = React.useMemo(function()
		local bannerItem = p.controls.BannerItem

		for _, v5 in pairs(v) do
			if bannerItem == v5.UID then
				return v5
			end
		end

		return nil
	end, { p.controls.BannerItem })
	React.useEffect(function()
		local flag = false

		if state3 then
			local v5 = state3.Cooldown.RequirementMet and state3.Price.RequirementMet and true or false
			flag = state3.Keys.Silver.RequirementMet and true or v5

			if state3.PaidRandomItemsRestricted.Value then
				flag = false
			end
		end

		setState4(flag == true)
	end, { state3 })
	local timeEnds = React.useState(os.time() + 5)
	React.useEffect(function()
		local requirementMet

		if p.controls.SilverKeys >= 1 then
			requirementMet = true
		else
			requirementMet = timeEnds < os.time()
		end

		local v6 = {
			Cooldown = {
				RequirementMet = requirementMet,
				TimeEnds = timeEnds
			},
			Price = {
				RequirementMet = p.controls.SilverKeys >= 1 or p.controls.Money >= v3.Value
			},
			PaidRandomItemsRestricted = {
				Value = false
			},
			Keys = {
				Silver = {
					RequirementMet = p.controls.SilverKeys >= 1,
					Value = 1
				}
			}
		}

		if v6.Cooldown.RequirementMet == false then
			v6.ErrorMessage = "nil"
		elseif v6.Price.RequirementMet == false then
			local v9 = v3.Value - p.controls.Money
			v6.ErrorMessage = `You need ${TextUtil.commaValue(v9)} more to roll!`
		elseif v6.PaidRandomItemsRestricted.Value then
			v6.ErrorMessage = "Gacha is disabled in your region."
		end

		setState3(v6)
	end, {
		p.controls.money,
		p.controls.SilverKeys,
		bannerItem2,
		p.controls.Money
	})
	local tryPurchase = React.useCallback(function()
		if state3 then
			if state3.Cooldown.RequirementMet == false then
				local v7 = state3.Cooldown.TimeEnds - os.time()
				sendNotif(`Cooldown ends in {TimeUtil.format(v7, "short")}`) -- equivalent call inferred; original call site unknown
			elseif state3.ErrorMessage then
				sendNotif(state3.ErrorMessage) -- equivalent call inferred; original call site unknown
			else
				print("purchased")
			end
		end
	end)
	return createElement(Cousin, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.7, 0.7),
		ZIndex = CONSTANTS.LAYER.RAISED,
		Cost = React.useMemo(function()
			if v3.Value == 0 then
				return {
					Formatted = "FREE",
					Name = v3.Name,
					Value = v3.Value
				}
			end

			if state3 and state3.Keys.Silver.RequirementMet then
				return {
					Formatted = `Keys x{TextUtil.commaValue(state3.Keys.Silver.Value)}`,
					Name = "Silver Key",
					Value = state3.Keys.Silver.Value
				}
			end

			return {
				Formatted = `${TextUtil.commaValue(v3.Value)}`,
				Value = v3.Value,
				Name = v3.Name
			}
		end, { state3 }),
		CanPurchase = state4,
		Notification = state2,
		IsOpen = state,
		OnClose = function()
			print("close")
			setState(false)
		end,
		TryPurchase = tryPurchase,
		OnCloseFinished = function()
			print("close finished")
		end,
		BannerItem = bannerItem2,
		CommonsCrossedOut = bannerItem2 ~= nil,
		CooldownTimeEnds = (not state3 or state3.Cooldown.RequirementMet ~= false) and 0 or timeEnds
	})
end)