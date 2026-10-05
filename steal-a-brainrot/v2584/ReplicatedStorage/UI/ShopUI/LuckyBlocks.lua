local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("Packages")
local vide = require(packages.vide)
local Animals = require(ReplicatedStorage.Shared.Animals)
local MutationText = require(ReplicatedStorage.Shared.MutationText)
local Mutations = require(ReplicatedStorage.Datas.Mutations)
local LuckyBlocks = require(ReplicatedStorage.Datas.LuckyBlocks)
local TimeUtils = require(ReplicatedStorage.Utils.TimeUtils)
local Layout = require(script.Parent.Layout)
local Odds = require(script.Parent.Odds)
local Prices = require(script.Parent.Prices)
local Reactive = require(script.Parent.Reactive)
local State = require(script.Parent.State)
local effect = vide.effect
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function mountViewports(instance, id: string, p, p2: string)
	effect(function()
		local opened = p.Opened()
		local mutation = p.Mutation()

		if not opened then
			return
		end

		local trove = Reactive.Trove()

		for _, viewportFrame in instance:QueryDescendants("#IconViewport, #LuckyBlockViewport") do
			if not (viewportFrame:IsA("ViewportFrame") and (viewportFrame.Name == p2 or viewportFrame.Name == "LuckyBlockViewport")) then
				continue
			end

			local luckyBlock = viewportFrame:GetAttribute("LuckyBlock") or id
			local v2 = Animals:AttachOnViewport(luckyBlock, viewportFrame, true, mutation)

			if v2 then
				trove:Add(v2)
			end
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function mountAuthoredViewports(instance, id: string, p)
	effect(function()
		local mutation = p.Mutation()

		if not p.Opened() or not mutation or mutation == "Default" then
			return
		end

		local maid = Reactive.Trove()

		for _, v2 in instance:QueryDescendants("#LuckyBlockViewport") do
			local beeLuckyBlock = v2:FindFirstChild("BeeLuckyBlock", true)

			if beeLuckyBlock and beeLuckyBlock:IsA("Model") then
				maid:Add(Animals:ApplyMutation(beeLuckyBlock, id, mutation))
			end
		end
	end)
end

local function mountMutationLabel(instance, p)
	local mutation = instance:FindFirstChild("Mutation", true)

	if mutation and mutation:IsA("TextLabel") then
		effect(function()
			local mutation2 = p.Mutation()

			if mutation2 and Mutations[mutation2] and mutation2 then
				MutationText.apply(mutation, mutation2, "Rich")
				mutation.Visible = true
			else
				mutation.Visible = false
			end
		end)
	end
end

local function mountOdds(instance, id: string, p)
	for _, v2 in instance:QueryDescendants("#Odds") do
		local luckyBlock = v2:GetAttribute("LuckyBlock") or id
		Odds.Mount(v2, luckyBlock, p)
	end
end

local function mountBuyButton(button, p: number, object, p2: number?)
	if not button:IsA("GuiButton") then
		return
	end

	local price = button:FindFirstChild("Price")

	if price and price:IsA("TextLabel") then
		local text = Prices.Text(function()
			return object:ResolveProductId(p)
		end, "Product", p2)
		Reactive.Hydrate(price, {
			Text = text
		})
	end

	Reactive.Button(button, function()
		object:Buy(p)
	end)
end

function v.MountCard(instance, p, options)
	local v2 = options or {}
	local id = v2.Id or instance.Name
	local luckyBlock = LuckyBlocks[id]

	if not luckyBlock then
		return
	end

	mountOdds(instance, id, p)
	mountMutationLabel(instance, p)

	if v2.PreserveViewportModel then
		mountAuthoredViewports(instance, id, p) -- equivalent call inferred; original call site unknown
	else
		mountViewports(instance, id, p, "IconViewport") -- equivalent call inferred; original call site unknown
	end

	local multiBuy = v2.MultiBuy

	if multiBuy then
		local buttons = instance:FindFirstChild("Buttons", true)

		if not buttons then
			return
		end

		for childName, v3 in multiBuy do
			local child = buttons:FindFirstChild(childName)

			if child then
				mountBuyButton(child, v3, p)
			end
		end

		local countedProductId = v2.CountedProductId
		local buy3 = buttons:FindFirstChild("Buy3")
		local buy10 = buttons:FindFirstChild("Buy10")

		if countedProductId and buy3 and buy10 and buy3:IsA("GuiObject") and buy10:IsA("GuiObject") then
			local v3 = Reactive.FromChannelPath({ "LuckyBlocks", (tostring(countedProductId)) }, 0)
			Reactive.Hydrate(buy10, {
				Visible = function()
					return v3() >= 5
				end
			})
			Reactive.Hydrate(buy3, {
				Visible = function()
					return v3() < 5
				end
			})
		end
	else
		local productId = v2.ProductId or luckyBlock.ProductId

		if not productId then
			return
		end

		local buy = instance:FindFirstChild("Buy", true)

		if buy then
			mountBuyButton(buy, productId, p, 100)
		end
	end
end

function v.Mount(p, data, p2)
	local resolved = Layout.Resolve(p, data.LuckyBlocks.List)

	if not resolved then
		return
	end

	local title = data.LuckyBlocks.Title
	local resolved2

	if title then
		resolved2 = Layout.Resolve(p, title)
	end

	local resolved3 = Layout.Resolve(p, data.List)
	local luckyBlocks = data.Sections.LuckyBlocks
	local v2

	if resolved3 and luckyBlocks then
		v2 = Layout.Resolve(resolved3, luckyBlocks.Frame)
	end

	for _, guiObject in { resolved, v2 } do
		if guiObject and guiObject:IsA("GuiObject") then
			Reactive.Hydrate(guiObject, {
				Visible = function()
					return not State.PaidRandomRestricted(p2)
				end
			})
		end
	end

	if resolved2 and resolved2:IsA("TextLabel") then
		local v3 = Reactive.FromFlag("LuckyBlockEndTimer", 1753545600)
		Reactive.Hydrate(resolved2, {
			Text = function()
				local v4 = v3() - p2.Clock()

				if v4 <= 0 then
					return "LUCKY BLOCKS"
				end

				return (`LUCKY BLOCKS (<font color="#ffff00">{TimeUtils:E(v4)}</font>)`)
			end
		})
	end

	for _, guiObject in resolved:GetChildren() do
		if guiObject:IsA("GuiObject") then
			v.MountCard(guiObject, p2)
		end
	end
end

return table.freeze(v)