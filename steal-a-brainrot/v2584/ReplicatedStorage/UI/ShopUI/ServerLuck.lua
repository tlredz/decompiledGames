local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("Packages")
require(packages.Synchronizer)
local vide = require(packages.vide)
local CustomRichTextController = require(ReplicatedStorage.Controllers.CustomRichTextController)
local ServerLuck = require(ReplicatedStorage.Datas.ServerLuck)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local ShopFlags = require(ReplicatedStorage.Shared.Flags.ShopFlags)
local TimeUtils = require(ReplicatedStorage.Utils.TimeUtils)
local Layout = require(script.Parent.Layout)
local Prices = require(script.Parent.Prices)
local Reactive = require(script.Parent.Reactive)
require(script.Parent.State)
local effect = vide.effect
local derive = vide.derive

local function maxTierIndex()
	local v2 = 1

	for k, v3 in ServerLuck do
		if (not v3.IsEnabled or v3.IsEnabled()) and v2 < k then
			v2 = k
		end
	end

	return v2
end

local function amountText(p: number, p2: number)
	if p2 <= p then
		if p2 == 3 then
			return "<rainbow>MAX</rainbow>"
		end

		return "<font color=\"#FFFF00\">MAX</font>"
	else
		local v2 = math.min(p + 1, p2)
		local v3 = p == 0 and 1 or ServerLuck[p].Multiplier
		local multiplier = ServerLuck[v2].Multiplier
		local tag = ServerLuck[v2].Tag
		local v4

		if tag then
			v4 = `<{tag}>{multiplier}x</{tag}>`
		else
			v4 = `<font color="#FFFF00">{multiplier}x</font>`
		end

		return (`<font color="#FFFFFF">{v3}x</font> &gt; {v4}`)
	end
end

return table.freeze({
	Mount = function(p, data, object)
		local resolved = Layout.Resolve(p, data.ServerLuck)

		if not resolved then
			return
		end

		local serverLuck = data.Sections.ServerLuck
		local resolved2 = Layout.Resolve(p, data.List)
		local fFlag = Reactive.FFlag(ShopFlags.ServerLuckEnabled)

		for _, v2 in { serverLuck and serverLuck.Frame, serverLuck and serverLuck.Title } do
			local resolved3

			if v2 and resolved2 then
				resolved3 = Layout.Resolve(resolved2, v2)
			end

			if not (resolved3 and resolved3:IsA("GuiObject")) then
				continue
			end

			if ServerData.IsTradePlaza() then
				resolved3.Visible = false
			else
				local visible = resolved3.Visible
				Reactive.Hydrate(resolved3, {
					Visible = function()
						return visible and fFlag()
					end
				})
			end
		end

		local resolved3 = Layout.Resolve(p, data.Close)
		local parent = resolved3 and resolved3.Parent
		local parentMain = parent and parent:FindFirstChild("Main")
		local serverLuck2 = parentMain and parentMain:FindFirstChild("ServerLuck")

		if serverLuck2 and serverLuck2:IsA("GuiObject") then
			if ServerData.IsTradePlaza() then
				serverLuck2.Visible = false
			else
				local visible = serverLuck2.Visible
				Reactive.Hydrate(serverLuck2, {
					Visible = function()
						return visible and fFlag()
					end
				})
			end
		end

		if ServerData.IsTradePlaza() then
			return
		end

		local v2 = Reactive.FromChannelOf("ServerLuck", function(object2)
			return object2:Get("Index") or 0
		end, 0, {
			{
				Method = "OnChanged",
				Path = "Index"
			}
		})
		local v3 = Reactive.FromChannelOf("ServerLuck", function(object2)
			return object2:Get("EndTime")
		end, nil, {
			{
				Method = "OnChanged",
				Path = "EndTime"
			}
		})
		local v4 = derive(function()
			object.UpdatesRevision()
			local v5 = maxTierIndex()
			return ServerLuck[math.min(v2() + 1, v5)]
		end)
		local v5 = derive(function()
			local v6 = v3()

			if not v6 then
				return nil
			end

			local v7 = math.floor(v6 - object.Clock())

			if v7 > 0 then
				return v7
			end

			return nil
		end)
		local amount = resolved:FindFirstChild("Amount")

		if amount and amount:IsA("TextLabel") then
			effect(function()
				object.UpdatesRevision()
				CustomRichTextController.apply(amount, (amountText(v2(), maxTierIndex())))
			end)
		end

		for _, timer in resolved:GetChildren() do
			if not (timer.Name == "Timer" and timer:IsA("GuiObject")) then
				continue
			end

			Reactive.Hydrate(timer, {
				Visible = function()
					return v5() ~= nil
				end
			})

			if not timer:IsA("TextLabel") then
				timer = timer:FindFirstChild("Timer")
			end

			if timer and timer:IsA("TextLabel") then
				Reactive.Hydrate(timer, {
					Text = function()
						local v6 = v5()

						if v6 then
							return (TimeUtils:A(v6))
						end

						return ""
					end
				})
			end
		end

		local v6 = derive(function()
			local v7 = v4()

			if v7 then
				return v7.Icon
			end

			return nil
		end)

		for _, childName in { "LuckVector", "Pattern", "LuckPattern" } do
			local image = resolved:FindFirstChild(childName, true)

			if not (image and image:IsA("ImageLabel")) then
				continue
			end

			local v7 = image
			Reactive.Hydrate(image, {
				Image = function()
					return v6() or v7.Image
				end
			})
		end

		local buy = resolved:FindFirstChild("Buy")

		if not (buy and buy:IsA("GuiButton")) then
			return
		end

		local price = buy:FindFirstChild("Price")

		if price and price:IsA("TextLabel") then
			local text = Prices.Text(function()
				local v7 = v4()

				if v7 then
					return v7.ProductId
				end

				return 0
			end, "Product")
			Reactive.Hydrate(price, {
				Text = text
			})
		end

		Reactive.Button(buy, function()
			local v7 = v4()

			if fFlag() and v7 then
				object:BuyDirect(v7.ProductId)
			end
		end)
	end
})