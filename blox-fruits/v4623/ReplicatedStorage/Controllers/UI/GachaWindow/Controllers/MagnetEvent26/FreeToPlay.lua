local React = require(game.ReplicatedStorage.Packages.React)
local FreeToPlay = require(game.ReplicatedStorage.React.Components.Gacha.Windows.MagnetEvent26.FreeToPlay)
local GachaClient = require(game.ReplicatedStorage.Controllers.GachaClient)
require(game.ReplicatedStorage.Modules.Gacha.SharedGachaTypes)
local TextUtil = require(game.ReplicatedStorage.Modules.Util.TextUtil)
require(game.ReplicatedStorage.React.Components.Gacha.Notification)
local SceneController = require(game.ReplicatedStorage.Controllers.SceneController)
local SceneEffect = require(game.ReplicatedStorage.React.Components.Gacha.SceneEffect)
local use = require(game.ReplicatedStorage.React.Hooks.Item.Quantity.use)
local usePolicyService = require(game.ReplicatedStorage.React.Hooks.Player.usePolicyService)
local useGacha = require(game.ReplicatedStorage.React.Hooks.Gacha.useGacha)
return function(props)
	React.useEffect(function()
		return function()
			SceneController.Destroy()
		end
	end, {})
	local cost = props.Cost
	local v = usePolicyService()
	local v2 = useGacha("PremiumChromaticMagnetGacha26")
	local state, setState = React.useState(false)
	local v3 = use(cost.Name, "Material")
	local state2, setState2 = React.useState(nil)
	local state3, setState3 = React.useState(false)
	React.useEffect(function()
		local v4 = false

		if state2 then
			local v5 = state2.Cooldown.RequirementMet and state2.Price.RequirementMet and true or false
			v4 = state2.Keys.Silver.RequirementMet and true or v5

			if state2.PaidRandomItemsRestricted.Value then
				v4 = false
			end
		end

		setState3(v4 == true)
	end, { state2 })
	React.useEffect(function()
		setState2(GachaClient.CheckGachaAsync(props.BoxName))
	end, { v3, props.BoxName })
	return React.createElement(FreeToPlay, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		Visible = state,
		OpenGacha = function(p, p2)
			if v2 and v2.POLICY_SERVICE_REQUIREMENTS and v2.POLICY_SERVICE_REQUIREMENTS.ArePaidRandomItemsRestricted and v and v.ArePaidRandomItemsRestricted then
				props.SendNotification("This gacha is disabled in your region.")
			else
				props.OpenGacha(p, p2)
			end
		end,
		Cost = React.useMemo(function()
			local formatted = cost.Value == 0 and "FREE" or `{TextUtil.commaValue(cost.Value)} {cost.Name}`
			return {
				Name = cost.Name,
				Value = cost.Value,
				Formatted = formatted
			}
		end, { state2 }),
		PreviewFrameEffect = function(itemId, p2)
			local sequenceHistory = SceneController.SequenceHistory("Magnet-Magnet")
			local wasSequencePlayedFromLocation = sequenceHistory.WasSequencePlayedFromLocation(
				"Gacha.FreeToPlay",
				"Primary"
			)

			local function fn(_, p3)
				sequenceHistory.SetSequencePlayedFromLocation("Gacha.FreeToPlay", "Primary")

				if p3 then
					p3.Camera.SetCameraType("Inspect", function()
						return p2.AbsoluteSize - p2.AbsoluteSize * 0.4
					end, 1)
				end

				setState(true)
			end

			return (SceneEffect({
				OnSequenceFinished = function(p3, p4)
					if not wasSequencePlayedFromLocation or p4 == nil then
						fn(p3, p4)
					end
				end,
				OnSequenceStarted = function(p3, p4)
					if wasSequencePlayedFromLocation or p4 == nil then
						fn(p3, p4)
					elseif p4 then
						p4.Camera.SetCameraType("CameraSubject", nil, 0)
						setState(false)
					end
				end,
				SequenceType = "Primary",
				ItemId = itemId
			}))
		end,
		CanPurchase = state3,
		Notification = props.Notification,
		TryPurchase = props.TryPurchase,
		OnClose = props.Close
	})
end