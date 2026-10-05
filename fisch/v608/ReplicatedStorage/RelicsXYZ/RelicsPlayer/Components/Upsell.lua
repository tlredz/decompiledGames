local parent = script.Parent.Parent
local components = parent.Components
local Button = require(components.Button)
local View3D = require(components.View3D)
local shared = parent.Parent.Shared
local hooks = parent.Hooks
local Enums = require(parent.Enums)
local Util = require(parent.Util)
local State = require(parent.State)
local React = require(shared.React)
local useClock = require(hooks.useClock)
local usePlaylists = require(hooks.usePlaylists)
local useBoomboxData = require(hooks.useBoomboxData)
local Players = game:GetService("Players")
local Marketplace = require(shared.Marketplace)

local function BuyButton(p)
	return React.createElement("Frame", {
		[React.Tag] = "UpsellBuyButtonWrapper"
	}, {
		Buy = React.createElement(Button, {
			[React.Tag] = "UpsellBuyButton",
			HoverScale = 1.05,
			PressScale = 0.95,
			OnActivated = function()
				if Players.LocalPlayer then
					Marketplace.PromptPurchase(p.AssetId)
				end
			end
		}, {
			Text = React.createElement("TextLabel", {
				[React.Tag] = "UpsellBuyButtonLabel"
			})
		})
	})
end

local function Upsell(data)
	local v = React.useContext(State.Context)
	local status = v.Status
	local v2 = data.ReturnWhenPurchased == nil or data.ReturnWhenPurchased
	React.useEffect(function()
		local widget = v.Widget

		if not (widget and v2) then
			return
		end

		local returnFunc = status == Enums.UserStatus.BoomboxPurchased and widget.ReturnFunc

		if returnFunc then
			returnFunc()
		end
	end, { status, v2 })
	local windowState = v.WindowState
	local v3 = useBoomboxData()
	local v4 = windowState == Enums.WindowState.Full
	local assetId = not v3 and 0 or v3.AssetId or 0
	useClock(30, function()
		local model = v3 and v3.Model

		if model then
			model:PivotTo((CFrame.Angles(0, 3.141592653589793 + math.sin(os.clock() / 2) / 1.5, 0)))
		end
	end)
	local v6 = usePlaylists()
	local count = 0

	for _, v7 in v6 do
		if not v7.IsActive or v7.IsFree then
			continue
		end

		local productId = v7.ProductId

		if productId == nil or productId <= 0 then
			count += 1
		end
	end

	local createElement = React.createElement
	local v8

	if data[React.Tag] == nil then
		v8 = {}
		v8[React.Tag] = Util.ClassNames("UpsellContainer")
		v8.Size = data.Size or UDim2.new(1, -20, 1, -70)
		v8.AnchorPoint = data.AnchorPoint or Vector2.xAxis / 2
		v8.Position = data.Position or UDim2.fromScale(0.5, 0)
		v8.BackgroundTransparency = 1
	else
		v8 = {}
		v8[React.Tag] = Util.ClassNames("UpsellContainer", data[React.Tag])
	end

	return createElement("CanvasGroup", v8, {
		NoList = React.createElement("Folder", {}, {
			Image = React.createElement("ImageLabel", {
				[React.Tag] = "Design UpsellBackground"
			}),
			BuyButton = not v4 and React.createElement(BuyButton, {
				AssetId = assetId
			})
		}),
		Boombox = React.createElement("Frame", {
			[React.Tag] = "BoomboxWrapper"
		}, {
			Render = React.createElement(View3D, {
				Model = v3 and v3.Model,
				Transparency = 0.1,
				FieldOfView = 15,
				ZoomScale = 1
			})
		}),
		Info = React.createElement("Frame", {
			[React.Tag] = Util.ClassNames("UpsellInfoContainer", v4 and "isFull" or nil)
		}, {
			Title = React.createElement("TextLabel", {
				[React.Tag] = "UpsellTitle",
				Text = `Unlock <font color="#FFFF00">{count}</font> playlists`
			}),
			Description = React.createElement("TextLabel", {
				[React.Tag] = "UpsellDescription",
				Text = table.concat(
					{ "Play music for friends!", "Add your own song ids!", "Collect boombox skins!" },
					"\n"
				)
			})
		}),
		Button = v4 and React.createElement(BuyButton, {
			AssetId = assetId
		})
	}, data.children)
end

return Upsell