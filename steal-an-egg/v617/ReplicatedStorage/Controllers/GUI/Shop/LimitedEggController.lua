local Players = game:GetService("Players")
local PolicyService = game:GetService("PolicyService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local t = require(ReplicatedStorage.Packages.t)
local Assets = require(ReplicatedStorage.Data.Assets)
local ButtonFX = require(ReplicatedStorage.Client.UI.VFX.ButtonFX)
local GUI = require(ReplicatedStorage.Client.GUI)
local Gifting = require(ReplicatedStorage.Client.Gifting)
local Marketplace = require(ReplicatedStorage.Shared.Utils.Marketplace)
local price = Marketplace.Price
local HoverCard = require(ReplicatedStorage.Client.HoverCard)
local LimitedEgg = require(ReplicatedStorage.Data.LimitedEgg)
require(ReplicatedStorage.Data.LimitedEgg.Types.Interface)
local Log = require(ReplicatedStorage.Packages.Log)
local Products = require(ReplicatedStorage.Data.Products)
local Storefront = require(ReplicatedStorage.Client.Functions.Storefront)
local SwapGradient = require(ReplicatedStorage.Shared.Utils.SwapGradient)
local Tabs = require(ReplicatedStorage.Client.Tabs)
local Timer = require(ReplicatedStorage.Packages.Timer)
local Trove = require(ReplicatedStorage.Packages.Trove)
local TryCall = require(ReplicatedStorage.Shared.Utils.TryCall)
local TryLock = require(ReplicatedStorage.Shared.Utils.TryLock)
return {
	Start = function()
		local v = Log.new()
		local tryLock = TryLock()
		local v3 = nil
		local localPlayer = Players.LocalPlayer
		local scrollingFrame = GUI.Shop().Frame.ScrollingFrame
		local v4 = true

		local function requireChild(instance, childName: string, className: string, p: string)
			local child = instance:FindFirstChild(childName)
			assert(child ~= nil, (`Shop is missing {p}`))
			assert(child:IsA(className), (`Shop {p} must be a {className}`))
			return child
		end

		local function bindSlot(childName: string, frame, p: number)
			local formatted = `{childName}.Spacer.Frame.{p}`
			local guiObject = frame:FindFirstChild((tostring(p)))
			assert(guiObject ~= nil, (`Shop is missing {formatted}`))
			assert(guiObject:IsA("GuiObject"), (`Shop {formatted} must be a GuiObject`))
			local glow = guiObject:FindFirstChild("Glow")
			local formatted2 = `{formatted}.Icon`
			local icon = guiObject:FindFirstChild("Icon")
			assert(icon ~= nil, (`Shop is missing {formatted2}`))
			assert(icon:IsA("ImageLabel"), (`Shop {formatted2} must be a ImageLabel`))
			local formatted3 = `{formatted}.Amount`
			local amount = guiObject:FindFirstChild("Amount")
			assert(amount ~= nil, (`Shop is missing {formatted3}`))
			assert(amount:IsA("TextLabel"), (`Shop {formatted3} must be a TextLabel`))

			if glow == nil or not glow:IsA("ImageLabel") then
				glow = nil
			end

			return {
				Frame = guiObject,
				Icon = icon,
				Amount = amount,
				Glow = glow
			}
		end

		local function bindOfferUi(childName: string, btns, i: number)
			local formatted = `Buy{i}`
			local formatted2 = `{childName}.Spacer.Btns.{formatted}`
			local button = btns:FindFirstChild(formatted)
			assert(button ~= nil, (`Shop is missing {formatted2}`))
			assert(button:IsA("GuiButton"), (`Shop {formatted2} must be a GuiButton`))
			local amount = button:FindFirstChild("Amount")
			local formatted3 = `Gift{i}`
			local formatted4 = `{childName}.Spacer.Btns.Gift{i}`
			local button2 = btns:FindFirstChild(formatted3)
			assert(button2 ~= nil, (`Shop is missing {formatted4}`))
			assert(button2:IsA("GuiButton"), (`Shop {formatted4} must be a GuiButton`))
			local formatted5 = `{formatted2}.Price`
			local price2 = button:FindFirstChild("Price")
			assert(price2 ~= nil, (`Shop is missing {formatted5}`))
			assert(price2:IsA("TextLabel"), (`Shop {formatted5} must be a TextLabel`))

			if amount == nil or not amount:IsA("TextLabel") then
				amount = nil
			end

			return {
				Button = button,
				Gift = button2,
				Price = price2,
				Amount = amount
			}
		end

		local function formatCountdown(p: number)
			local v5 = math.max(0, (math.ceil(p)))
			local v6 = v5 // 86400
			local v7 = v5 % 86400 // 3600
			local v8 = v5 % 3600 // 60
			local v9 = v5 % 60

			if v6 > 0 then
				return string.format("%dd %02dh %02dm %02ds", v6, v7, v8, v9)
			end

			if v7 > 0 then
				return string.format("%02dh %02dm %02ds", v7, v8, v9)
			end

			if v8 > 0 then
				return string.format("%02dm %02ds", v8, v9)
			end

			return string.format("%02ds", v9)
		end

		local function formatChance(p: number)
			local v5 = not (p > 0 and p < 10) and 0 or math.clamp(math.ceil(-math.log10(p)) + 1, 0, 4)
			local v6 = string.format(`%.{v5}f`, p)

			if v5 > 0 then
				v6 = v6:gsub("0+$", ""):gsub("%.$", "")
			end

			return (`{v6}%`)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function formatEggAmount(p: number)
			if p == 1 then
				return "1 Egg"
			end

			return (`{p} Eggs`)
		end

		local function mechaLabelFor(p)
			local mechanicalVersion = p.Frame:FindFirstChild("MechanicalVersion") or p.Frame:FindFirstChild("Icon2")

			if mechanicalVersion == nil or not mechanicalVersion:IsA("ImageLabel") then
				return nil
			end

			return mechanicalVersion
		end

		local function bindPanel(childName: string, config)
			local guiObject = scrollingFrame:FindFirstChild(childName)
			assert(guiObject ~= nil, (`Shop is missing {childName}`))
			assert(guiObject:IsA("GuiObject"), (`Shop {childName} must be a GuiObject`))
			local formatted = `{childName}.Spacer`
			local spacer = guiObject:FindFirstChild("Spacer")
			assert(spacer ~= nil, (`Shop is missing {formatted}`))
			assert(spacer:IsA("GuiObject"), (`Shop {formatted} must be a GuiObject`))
			local formatted2 = `{childName}.Spacer.bg`
			local bg = spacer:FindFirstChild("bg")
			assert(bg ~= nil, (`Shop is missing {formatted2}`))
			assert(bg:IsA("ImageLabel"), (`Shop {formatted2} must be a ImageLabel`))
			local formatted3 = `{childName}.Spacer.Frame`
			local frame = spacer:FindFirstChild("Frame")
			assert(frame ~= nil, (`Shop is missing {formatted3}`))
			assert(frame:IsA("GuiObject"), (`Shop {formatted3} must be a GuiObject`))
			local formatted4 = `{childName}.Spacer.Btns`
			local btns = spacer:FindFirstChild("Btns")
			assert(btns ~= nil, (`Shop is missing {formatted4}`))
			assert(btns:IsA("GuiObject"), (`Shop {formatted4} must be a GuiObject`))
			local slots = {}

			for i = 1, #config.Entries do
				table.insert(slots, (bindSlot(childName, frame, i)))
			end

			local mechaRerollSlot = nil
			local mechaRerollIncoming = nil
			local v8 = #config.Entries + 1
			local guiObject2 = frame:FindFirstChild((tostring(v8)))
			local icon2

			if guiObject2 ~= nil then
				icon2 = guiObject2:FindFirstChild("Icon2")
			end

			if guiObject2 ~= nil and guiObject2:IsA("GuiObject") and icon2 ~= nil and icon2:IsA("ImageLabel") then
				mechaRerollSlot = bindSlot(childName, frame, v8)
				mechaRerollIncoming = icon2
			end

			local offerUis = {}

			for i = 1, #config.Offers do
				table.insert(offerUis, (bindOfferUi(childName, btns, i)))
			end

			local formatted5 = `{childName}.Spacer.Title`
			local title = spacer:FindFirstChild("Title")
			assert(title ~= nil, (`Shop is missing {formatted5}`))
			assert(title:IsA("TextLabel"), (`Shop {formatted5} must be a TextLabel`))
			local formatted6 = `{childName}.Spacer.bg.Icon`
			local icon = bg:FindFirstChild("Icon")
			assert(icon ~= nil, (`Shop is missing {formatted6}`))
			assert(icon:IsA("ImageLabel"), (`Shop {formatted6} must be a ImageLabel`))
			local formatted7 = `{childName}.Spacer.bg.MechanicalVersion`
			local mechanicalVersion = bg:FindFirstChild("MechanicalVersion")
			assert(mechanicalVersion ~= nil, (`Shop is missing {formatted7}`))
			assert(mechanicalVersion:IsA("ImageLabel"), (`Shop {formatted7} must be a ImageLabel`))
			local formatted8 = `{childName}.Spacer.Infos`
			local infos = spacer:FindFirstChild("Infos")
			assert(infos ~= nil, (`Shop is missing {formatted8}`))
			assert(infos:IsA("GuiButton"), (`Shop {formatted8} must be a GuiButton`))
			return {
				Frame = guiObject,
				Config = config,
				EndingTimer = title,
				RegularIcon = icon,
				MechanicalIcon = mechanicalVersion,
				InfoButton = infos,
				Slots = slots,
				MechaRerollSlot = mechaRerollSlot,
				MechaRerollIncoming = mechaRerollIncoming,
				OfferUis = offerUis
			}
		end

		local v5 = {
			Luminous = bindPanel("OldLimitedEgg", LimitedEgg.Luminous),
			Extinction = bindPanel("LimitedEgg", LimitedEgg.Extinction)
		}

		-- equivalent calls inferred from this helper; original call sites unknown
		local function activePanel()
			if Workspace:GetServerTimeNow() >= LimitedEgg.SwitchesAt then
				return v5.Extinction
			end

			return v5.Luminous
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function applyVisibility()
			local v6 = activePanel() -- equivalent call inferred; original call site unknown

			for _, v7 in v5 do
				local frame = v7.Frame
				frame.Visible = v7 == v6 and not v4
			end
		end

		local function bindIconAlternator(maid, p)
			local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

			local function fadeTo(p2, imageTransparency: number)
				return maid:Add(TweenService:Create(p2, tweenInfo, {
					ImageTransparency = imageTransparency
				}))
			end

			local v6 = {}

			local function addSwap(icon, mechanicalVersion)
				icon.ImageTransparency = 0
				mechanicalVersion.ImageTransparency = 1
				table.insert(v6, {
					RegularIn = maid:Add(TweenService:Create(icon, tweenInfo, {
						ImageTransparency = 0
					})),
					RegularOut = maid:Add(TweenService:Create(icon, tweenInfo, {
						ImageTransparency = 1
					})),
					MechaIn = maid:Add(TweenService:Create(mechanicalVersion, tweenInfo, {
						ImageTransparency = 0
					})),
					MechaOut = maid:Add(TweenService:Create(mechanicalVersion, tweenInfo, {
						ImageTransparency = 1
					}))
				})
			end

			for _, slot in ipairs(p.Slots) do
				local mechanicalVersion = slot.Frame:FindFirstChild("MechanicalVersion") or slot.Frame:FindFirstChild("Icon2")

				if mechanicalVersion == nil or not mechanicalVersion:IsA("ImageLabel") then
					mechanicalVersion = nil
				end

				if mechanicalVersion ~= nil then
					addSwap(slot.Icon, mechanicalVersion)
				end
			end

			maid:Add(task.spawn(function()
				while true do
					task.wait(1)

					for _, v7 in v6 do
						v7.RegularOut:Play()
						v7.MechaIn:Play()
					end

					task.wait(4)

					for _, v7 in v6 do
						v7.MechaOut:Play()
						v7.RegularIn:Play()
					end

					task.wait(1)
				end
			end))
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function bindEndingTimer(maid, p, endsAt: number)
			-- equivalent calls inferred from this helper; original call sites unknown
			local function update()
				local v6 = endsAt - Workspace:GetServerTimeNow()

				if v6 <= 0 then
					p.EndingTimer.Text = "Leaving Soon"
				else
					p.EndingTimer.Text = formatCountdown(v6)
				end
			end

			update() -- equivalent call inferred; original call site unknown
			maid:Add(Timer.Simple(1, update))
		end

		local function bindRarityGlow(maid, glow, rarityGradient)
			local uIGradient = glow:FindFirstChildWhichIsA("UIGradient")
			local clone

			if uIGradient == nil then
				clone = nil
			else
				clone = uIGradient:Clone()
			end

			SwapGradient(glow, rarityGradient)
			maid:Add(function()
				SwapGradient(glow, clone)

				if clone ~= nil then
					clone:Destroy()
				end
			end)
		end

		local function bindSlots(maid, p)
			local config = p.Config
			local total = 0

			for _, entry in ipairs(config.Entries) do
				assert(entry.Weight > 0, "Limited egg drop weights must be positive")
				total += entry.Weight
			end

			local v6 = 1 - (config.MechaReroll == nil and 0 or config.MechaReroll.DisplayChance)

			for i, entry in ipairs(config.Entries) do
				local slot = p.Slots[i]
				local v7 = Assets.Directory[entry.AssetId]
				assert(v7 ~= nil, (`Limited egg drop entry "{entry.AssetId}" is not in the asset directory`))
				local image = slot.Icon.Image
				slot.Icon.Image = v7.Icon or image
				maid:Add(function()
					slot.Icon.Image = image
				end)
				local entries = config.MechaReroll and config.MechaReroll.Entries
				local v10 = entries and entries[i]
				local v11 = v10 and Assets.Directory[v10.AssetId]
				local mechanicalVersion = slot.Frame:FindFirstChild("MechanicalVersion") or slot.Frame:FindFirstChild("Icon2")

				if mechanicalVersion == nil or not mechanicalVersion:IsA("ImageLabel") then
					mechanicalVersion = nil
				end

				if mechanicalVersion ~= nil and v11 ~= nil then
					local image2 = mechanicalVersion.Image
					mechanicalVersion.Image = v11.Icon or image2
					local v12 = mechanicalVersion
					maid:Add(function()
						v12.Image = image2
					end)
				end

				slot.Amount.Text = formatChance(v6 * (entry.Weight / total) * 100)
				local glow = slot.Glow

				if glow ~= nil then
					bindRarityGlow(maid, glow, v7.Rarity.RarityGradient)
				end
			end

			v:AtTrace():Log("Limited egg slot session opened")
		end

		local function bindMechaRerollSlot(maid, data)
			local mechaRerollSlot = data.MechaRerollSlot
			local mechaRerollIncoming = data.MechaRerollIncoming
			local mechaReroll = data.Config.MechaReroll

			if mechaRerollSlot == nil or mechaRerollIncoming == nil or mechaReroll == nil then
				return
			end

			local icons = {}

			for _, entry in ipairs(mechaReroll.Entries) do
				local v6 = Assets.Directory[entry.AssetId]
				assert(v6 ~= nil, (`Limited egg mecha entry "{entry.AssetId}" is not in the asset directory`))
				table.insert(icons, v6.Icon)
			end

			if #icons == 0 then
				return
			end

			local icon = mechaRerollSlot.Icon
			local text = mechaRerollSlot.Amount.Text
			local image = icon.Image
			local image2 = mechaRerollIncoming.Image
			maid:Add(function()
				mechaRerollSlot.Amount.Text = text
				icon.Image = image
				icon.ImageTransparency = 0
				mechaRerollIncoming.Image = image2
				mechaRerollIncoming.ImageTransparency = 1
			end)
			mechaRerollSlot.Amount.Text = formatChance(mechaReroll.DisplayChance * 100)
			icon.Image = icons[1]
			icon.ImageTransparency = 0
			mechaRerollIncoming.ImageTransparency = 1
			local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
			local v6 = {
				[icon] = maid:Add(TweenService:Create(icon, tweenInfo, {
					ImageTransparency = 0
				})),
				[mechaRerollIncoming] = maid:Add(TweenService:Create(mechaRerollIncoming, tweenInfo, {
					ImageTransparency = 0
				}))
			}
			local v7 = {
				[icon] = maid:Add(TweenService:Create(icon, tweenInfo, {
					ImageTransparency = 1
				})),
				[mechaRerollIncoming] = maid:Add(TweenService:Create(mechaRerollIncoming, tweenInfo, {
					ImageTransparency = 1
				}))
			}
			maid:Add(task.spawn(function()
				local v8 = icon
				local v9 = mechaRerollIncoming
				local v10 = 1

				while true do
					task.wait(1)
					v10 = v10 % #icons + 1
					v9.Image = icons[v10]
					v7[v8]:Play()
					local v11 = v6[v9]
					v11:Play()
					v11.Completed:Wait()
					v8, v9 = v9, v8
				end
			end))
			v:AtTrace():Log("Limited egg mecha re-roll slot session opened")
		end

		local function bindHoverInfo(maid, data)
			local config = data.Config

			for i, entry in ipairs(config.Entries) do
				local slot = data.Slots[i]
				local v6 = Assets.Directory[entry.AssetId]
				maid:Add(HoverCard.Attach(slot.Frame, {
					{
						kind = "heading",
						text = v6.DisplayName
					},
					{
						kind = "tier",
						rarity = v6.Rarity._id
					}
				}))
			end

			local mechaRerollSlot = data.MechaRerollSlot

			if mechaRerollSlot ~= nil then
				maid:Add(HoverCard.Attach(mechaRerollSlot.Frame, {
					{
						kind = "heading",
						text = config.RerollName
					}
				}))
			end

			local infoButton = data.InfoButton
			local infoText = config.InfoText

			if infoText ~= nil then
				maid:Add(HoverCard.Attach(infoButton, {
					{
						kind = "body",
						text = infoText
					}
				}))
				maid:Add(infoButton.Activated:Connect(function()
					HoverCard.Show(infoButton, {
						{
							kind = "body",
							text = infoText
						}
					})
				end))
			end

			maid:Add(function()
				HoverCard.Dismiss()
			end)
			v:AtTrace():Log("Limited egg hover info session opened")
		end

		local function applyPaidRandomItemPolicy()
			applyVisibility() -- equivalent call inferred; original call site unknown
			local v6, v7 = TryCall(function()
				return PolicyService:GetPolicyInfoForPlayerAsync(localPlayer).ArePaidRandomItemsRestricted
			end)

			if v6 then
				TryCall(function()
					t.strict(t.boolean)(v7)
					v4 = v7
					applyVisibility() -- equivalent call inferred; original call site unknown
				end)
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function closeSession()
			local v6 = v3

			if v6 == nil then
				return
			end

			v3 = nil
			v6:Destroy()
			v:AtTrace():Log("Limited egg shop session closed")
		end

		local function bindOffer(maid, data)
			maid:Add(Gifting.Bind(data.Ui.Gift, "Product", data.ProductId))
			local amount = data.Ui.Amount

			if amount ~= nil then
				amount.Text = formatEggAmount(data.Amount)
			end

			maid:Add(ButtonFX(data.Ui.Button, nil, function()
				tryLock(function()
					Storefront.Prompt(data.ProductId, true)
				end)
			end))
			maid:Add((task.spawn(function()
				local v6 = price(data.ProductId, Enum.InfoType.Product)

				if v3 ~= maid then
					return
				end

				if v6 == nil then
					data.Ui.Price.Text = "Loading..."
				else
					data.Ui.Price.Text = "" .. tostring(v6)
				end
			end)))
		end

		local openSession

		openSession = function()
			closeSession() -- equivalent call inferred; original call site unknown
			local maid = Trove.new()
			v3 = maid
			local v6 = activePanel() -- equivalent call inferred; original call site unknown
			applyVisibility() -- equivalent call inferred; original call site unknown
			local v7, v8 = TryCall(function()
				local endsAt = v6.Config.EndsAt
				v6.EndingTimer.Visible = endsAt ~= nil

				if endsAt ~= nil then
					bindEndingTimer(maid, v6, endsAt) -- equivalent call inferred; original call site unknown
				end

				bindSlots(maid, v6)
				bindMechaRerollSlot(maid, v6)
				bindHoverInfo(maid, v6)
				bindIconAlternator(maid, v6)
				maid:Add(Timer.Simple(1, function()
					local v9 = activePanel() -- equivalent call inferred; original call site unknown

					if v9 ~= v6 then
						task.defer(openSession)
					end
				end))

				for i, offer in ipairs(v6.Config.Offers) do
					local v9 = Products.Directory[offer.ProductName]
					assert(v9 ~= nil, (`Limited egg offer "{offer.ProductName}" is not in the product directory`))
					t.strict(t.number)(v9.ProductId)
					bindOffer(maid, {
						Ui = v6.OfferUis[i],
						Amount = offer.Amount,
						ProductId = v9.ProductId
					})
				end
			end)

			if not v7 then
				closeSession() -- equivalent call inferred; original call site unknown
				error(v8)
			end

			v:AtTrace():Log("Limited egg shop session opened")
		end

		task.spawn(applyPaidRandomItemPolicy)
		Tabs.Activated:Connect(function(p: string)
			if p == "Shop" then
				openSession()
			end
		end)
		Tabs.Deactivated:Connect(function(p: string?)
			if p == "Shop" then
				closeSession() -- equivalent call inferred; original call site unknown
			end
		end)

		if Tabs.Active() == "Shop" then
			openSession()
		end
	end
}