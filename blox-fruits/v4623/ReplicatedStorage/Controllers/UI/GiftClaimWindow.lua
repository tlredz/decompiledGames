local GiftClaimWindow = {}
local GuiService = game:GetService("GuiService")
local Net = require(game.ReplicatedStorage.Modules.Net)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local Shop = require(game.ReplicatedStorage.Shop)
local LastInput = require(game.ReplicatedStorage.Modules.LastInput)
local Trove = require(game.ReplicatedStorage.Modules.Util.Trove)
local Signal = require(game.ReplicatedStorage.Modules.Util.Signal)
local TextButtonComponent = require(game.ReplicatedStorage.Modules.Create.TextButtonComponent)
local AssetComponent = require(game.ReplicatedStorage.Modules.Create.AssetComponent)
local VirtualList = require(script.VirtualList)
local HUD = require(game.ReplicatedStorage.Controllers.UI.HUD)
local TextUtil = require(game.ReplicatedStorage.Modules.Util.TextUtil)
local remoteEvent = Net:RemoteEvent("ShopNetwork")
local remoteFunction = Net:RemoteFunction("GiftFunction")
local v = {}
local localPlayer = game.Players.LocalPlayer
local v2 = nil
local v3 = nil
local scrollingFrame = nil
local inside = nil
local text = "Gifts"
local connection = nil
local connection2 = nil
local maid = nil
local v5 = nil
local v6 = false
local flag = true
local flag2 = true
local v7 = {}
local v8 = {}
local v9 = {}
local v10 = {}
local v11 = {}
local giftsChanged = Signal.new()
GiftClaimWindow.TotalGifts = 0
GiftClaimWindow.MaxGifts = 0
GiftClaimWindow.GiftsChanged = giftsChanged

local function tweenWindow(callback)
	if not v2 then
		return
	end

	if v5 then
		v5:Destroy()
	end

	local v13, TweenService

	if maid then
		local TweenService2 = game:GetService("TweenService")
		v13 = TweenService2:Create(v3, TweenInfo.new(0.3), {
			Position = UDim2.new(0.5, 0, 0.475, 0)
		})

		if not v13 then
			TweenService = game:GetService("TweenService")
			v13 = TweenService:Create(v3, TweenInfo.new(0.3), {
				Position = UDim2.new(0.5, 0, 1.5, 0)
			})
		end
	else
		TweenService = game:GetService("TweenService")
		v13 = TweenService:Create(v3, TweenInfo.new(0.3), {
			Position = UDim2.new(0.5, 0, 1.5, 0)
		})
	end

	v13:Play()

	if maid then
		v2.Enabled = true
	end

	v13.Completed:Connect(function(p)
		v5 = nil

		if p == Enum.PlaybackState.Completed then
			if not maid then
				v2.Enabled = false
			end

			if callback then
				callback()
			end
		end
	end)
	v5 = v13
end

local function deserializeGift(UID: string, data)
	local s = data.s
	return {
		SortWeight = ItemConfig.match(s, "Redeemable"):unwrap().Quality.RarityValue or 0,
		UID = UID,
		StorageName = s,
		SenderName = data.n,
		SenderUserId = data.u,
		TimeIn = data.t,
		Message = data.m
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function deserializeClaim(k, p)
	local v13 = deserializeGift(k, p)
	v13.Claimed = {
		TimeClaimed = p.claimed.tc,
		Failure = p.claimed.failure and true or false
	}
	return v13
end

local function deleteInstances(instance, items)
	for _, childName in pairs(items) do
		local child = instance:FindFirstChild(childName, true)

		if child then
			child:Destroy()
		end
	end
end

local function getAssetTileTemplate(i: number)
	local v13 = v9[i]

	if not v13 then
		local Create = require(game.ReplicatedStorage.Modules.Create)
		v13 = Create.Template("AssetComponentTemplate")
	end

	if not v13:FindFirstChild("Pulse") then
		local clone = script.Pulse:Clone()
		local v14 = { v13.Filled.Icon, v13.Filled.IconOutline }
		local frame = clone.Frame
		frame.Size = UDim2.new(0, 0, 0, 0)
		frame.BackgroundTransparency = 0
		clone.Visible = true
		clone.Parent = v13.Filled
		v[clone] = {
			Timeout = tick() + math.random(1, 2),
			Odds = math.random(),
			Tween = nil,
			Play = function(self)
				if not (self.Timeout - tick() <= 0) then
					return false
				end

				if Random.new():NextNumber() <= self.Odds then
					local tween = self.Tween

					if not tween or tween.PlaybackState ~= Enum.PlaybackState.Playing then
						self.Odds = 0
						self.Timeout = tick() + Random.new():NextInteger(0.4, 0.6000000000000001)
						frame.Size = UDim2.new(0, 0, 0, 0)
						frame.BackgroundTransparency = 0

						for _, v15 in pairs(v14) do
							local originalSize = v15:GetAttribute("OriginalSize")

							if not originalSize then
								v15:SetAttribute("OriginalSize", v15.Size)
								originalSize = v15.Size
							end

							local TweenService = game:GetService("TweenService")
							TweenService:Create(
								v15,
								TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0),
								{
									Size = UDim2.fromScale(originalSize.X.Scale * 0.9, originalSize.Y.Scale * 0.9)
								}
							):Play()
						end

						local TweenService = game:GetService("TweenService")
						local tween2 = TweenService:Create(
							frame,
							TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
							{
								BackgroundTransparency = 1,
								Size = UDim2.fromScale(2, 2)
							}
						)
						tween2:Play()
						self.Tween = tween2
						return true
					end
				else
					self.Odds = math.clamp(self.Odds + 0.1, 0, 1)
				end

				return false
			end
		}
	end

	local v14 = v9[i] ~= nil
	v9[i] = v13

	if not v14 then
		deleteInstances(v13, {
			"Blank",
			"Counter",
			"EquippedTag",
			"NewTag",
			"ItemLine1",
			"ItemLine2",
			"ItemName",
			"SelectedImage"
		})
		v13.Size = UDim2.new(1, 0, 1, 0)
	end

	return v13, v14
end

local function getHistoryFrameTemplate(p: number)
	local v13 = v10[p] or inside.History:Clone()
	local v14 = v10[p] ~= nil
	v10[p] = v13
	return v13, v14
end

local function getGiftFrameTemplate(p: number)
	return getHistoryFrameTemplate(p)
end

local function updateCategory()
	v3.Content.Frame.GiftBanner.Total.Text = "..."
	inside.History.Visible = false
	v3.Content.Overlay.Visible = false
	local v13 = {
		Gifts = {
			UpdateGiftFrame = function(p, object, data)
				local unwrapped = ItemConfig.match(data.StorageName, "Redeemable"):unwrap()
				local category = unwrapped.Display.Category or ""
				p.Frame.Top.Thumbnail.Image = `rbxthumb://type=AvatarHeadShot&id={data.SenderUserId}&w=150&h=150`
				p.Frame.Top.Timestamp.Text = DateTime.fromUnixTimestamp(data.TimeIn):FormatLocalTime(
					"lll",
					game.Players.LocalPlayer.LocaleId
				)
				p.Frame.Bottom.Message.Text = data.Message or "..."
				p.Frame.Top.Title.Text = `@{data.SenderName} sent you {TextUtil.richColor(`<{unwrapped.Display.Name or unwrapped.Index.StorageKey}>`, "Green")} {category}`
				local rarityValue = Shop.LEGACY_BELI_ITEMS[data.StorageName] and unwrapped.Quality.RarityValue or Shop.mapToLegacy(Shop.LIBRARY.PRODUCT.ALL)[data.StorageName] and 5 or unwrapped.Quality.RarityValue
				object:UpdateAsset({
					Type = "",
					DisplayName = "",
					ItemId = unwrapped.Index.ItemId,
					StorageName = unwrapped.Index.StorageKey,
					Rarity = rarityValue or 0
				})
			end,
			EmptyEntry = function()
				return {
					UID = "",
					SortWeight = -1,
					StorageName = "",
					TimeIn = DateTime.now().UnixTimestamp,
					SenderUserId = 1,
					SenderName = "Roblox",
					Message = ""
				}
			end,
			Update = function(p)
				if flag then
					flag = false

					if not remoteFunction:InvokeServer({
						Context = "GetGifts"
					}) then
						return #p.Data > 0
					end
				end

				debug.profilebegin("GiftClaimWindow/Gifts/Update")
				local count = 0
				local v14 = {}

				for k, v15 in pairs(v7) do
					count += 1
					table.insert(v14, {
						TimeIn = v15.TimeIn,
						StorageName = v15.StorageName,
						SortWeight = v15.SortWeight,
						UID = k
					})
				end

				v3.Content.Frame.GiftBanner.Total.Text = count == 0 and `You have {count} unclaimed gifts.` or count > 1 and `You have {count} unclaimed gifts!` or `You have {count} unclaimed gift!`
				table.sort(v14, function(a, b)
					if a.TimeIn > b.TimeIn then
						return true
					end

					if a.TimeIn < b.TimeIn then
						return false
					end

					if a.SortWeight > b.SortWeight then
						return true
					end

					return not (a.SortWeight < b.SortWeight) and #a.StorageName < #b.StorageName
				end)
				p.Data = v14
				debug.profileend()
				v3.Content.Overlay.Visible = #p.Data == 0
				return true
			end
		},
		History = {
			UpdateGiftFrame = function(p, object, data)
				local unwrapped = ItemConfig.match(data.StorageName, "Redeemable"):unwrap()
				local category = unwrapped.Display.Category or ""
				p.Frame.Top.Thumbnail.Image = `rbxthumb://type=AvatarHeadShot&id={data.SenderUserId}&w=150&h=150`
				p.Frame.Top.Timestamp.Text = DateTime.fromUnixTimestamp(data.TimeIn):FormatLocalTime(
					"lll",
					game.Players.LocalPlayer.LocaleId
				)
				p.Frame.Bottom.Message.Text = data.Message or "..."
				p.Frame.Top.Title.Text = `@{data.SenderName} sent you {TextUtil.richColor(`<{unwrapped.Display.Name or unwrapped.Index.StorageKey}>`, "Green")} {category}`
				object:UpdateAsset({
					Type = "",
					DisplayName = "",
					ItemId = unwrapped.Index.ItemId,
					StorageName = data.StorageName,
					Rarity = 0
				})
			end,
			EmptyEntry = function()
				return {
					UID = "",
					SortWeight = -1,
					StorageName = "",
					TimeIn = DateTime.now().UnixTimestamp,
					SenderUserId = 1,
					SenderName = "Roblox",
					Message = ""
				}
			end,
			Update = function(p)
				if flag2 then
					flag2 = false

					if not remoteFunction:InvokeServer({
						Context = "GetHistory"
					}) then
						return #p.Data > 0
					end
				end

				debug.profilebegin("GiftClaimWindow/History/Update")
				local count = 0
				local v14 = {}

				for k, v15 in pairs(v8) do
					count += 1
					table.insert(v14, {
						TimeClaimed = v15.Claimed.TimeClaimed,
						StorageName = v15.StorageName,
						SortWeight = v15.SortWeight,
						UID = k
					})
				end

				v3.Content.Frame.GiftBanner.Total.Text = count == 0 and "You have no claim history" or `Viewing [{count}] claimed gifts`
				table.sort(v14, function(a, b)
					if a.TimeClaimed > b.TimeClaimed then
						return true
					end

					if a.TimeClaimed < b.TimeClaimed then
						return false
					end

					if a.SortWeight > b.SortWeight then
						return true
					end

					return not (a.SortWeight < b.SortWeight) and #a.StorageName < #b.StorageName
				end)
				p.Data = v14
				debug.profileend()
				v3.Content.Overlay.Visible = #p.Data == 0
				return true
			end
		}
	}

	if connection2 then
		connection2:Disconnect()
	end

	if connection then
		connection:Disconnect()
	end

	if text == "Gifts" then
		v3.Content.Header.TextLabel.Text = text
		v3.Content.Overlay.TextLabel.Text = "Ask your friends to send you a gift!"

		if not connection then
			local v14 = {}
			local v15 = {}
			local v16 = {
				ScrollPaddingX = 5,
				List = {},
				Data = {},
				Update = function(p)
					return v13.Gifts.Update(p)
				end,
				OnConnect = function(_, maid2)
					local v17 = LastInput:Get()

					for _, v18 in pairs(v11) do
						if v17 == "Mobile" then
							v18:EnableHoverHighlight(false)
						else
							v18:EnableHoverHighlight(true)
						end

						v18:EnableAutoShine(true)
					end

					for _, v18 in pairs(v15) do
						v18.tile.Parent = v18.parent
					end

					maid2:Add((task.spawn(function()
						while task.wait() do
							local count = 0

							for _, v19 in pairs(v) do
								if v19:Play() then
									count += 1
								end

								if count >= 3 then
									break
								end
							end

							task.wait(count > 0 and math.random(2, 3.5) or 1)
						end
					end)))
				end,
				OnDestroy = function()
					table.clear(v15)
				end
			}
			local _ = LastInput:Get() == "Gamepad"

			for i = 1, 4 do
				local guiObject3 = v10[i] or inside.History:Clone()
				local _ = v10[i] == nil
				v10[i] = guiObject3
				local assetTileTemplate = getAssetTileTemplate(i)
				v15[i] = {
					parent = guiObject3.Frame.Right,
					tile = assetTileTemplate,
					capture = assetTileTemplate.Filled.TextButton
				}
				local v20 = v11[i] or AssetComponent(assetTileTemplate)
				v11[i] = v20

				local function claim()
					if text ~= "Gifts" or v14[guiObject3.Name] or guiObject3.Name == "" then
						return
					end

					local name = guiObject3.Name
					v14[name] = true
					local _AssetInfo = v20._AssetInfo
					local rarity = _AssetInfo.Rarity
					_AssetInfo.Rarity = nil
					v20:UpdateAsset(_AssetInfo)
					local v23 = remoteFunction:InvokeServer({
						Context = "Claim",
						UID = guiObject3.Name
					})
					v14[name] = nil

					if not v23 and name == guiObject3.Name then
						_AssetInfo.Rarity = rarity
						v20:UpdateAsset(_AssetInfo)
					end
				end

				maid:Add(assetTileTemplate.Filled.TextButton.Activated:Connect(claim))
				local v24 = v20
				v16.List[i] = {
					Select = function(p)
						return assetTileTemplate.Filled.TextButton
					end,
					GuiObject = guiObject3,
					Render = function(p, p2, p3)
						local v25 = p2 and v7[p2.UID] or nil

						if p3 == 0 then
							v25 = v13.Gifts.EmptyEntry()
						end

						local guiObject = p.GuiObject
						guiObject.Frame.Visible = p3 > 0
						guiObject.BorderSizePixel = v25 and p3 > 0 and 2 or 0
						guiObject.Name = not (p3 > 0 and v25) and "" or v25.UID or ""
						local guiObject2 = p.GuiObject
						local v27

						if v25 then
							v27 = v25.UID or nil
						end

						guiObject2:SetAttribute("CurrentSelection", v27)

						if v25 then
							if p3 ~= 0 then
								v13.Gifts.UpdateGiftFrame(guiObject, v24, v25)
							end

							guiObject.Visible = true
						else
							guiObject.Visible = false
							v24:UpdateAsset(nil)
						end
					end
				}
				guiObject3.Parent = inside
				maid:Add(function()
					table.clear(v15)
				end)
			end

			connection = VirtualList(v16, scrollingFrame, inside)
		end

		assert(connection):Connect()
	elseif text == "History" then
		v3.Content.Header.TextLabel.Text = "Claimed Gifts"
		v3.Content.Overlay.TextLabel.Text = "You haven't claimed any gifts!"

		if not connection2 then
			local v14 = {}
			local v15 = {
				ScrollPaddingX = 5,
				ButtonMapToIndex = {},
				List = {},
				Data = {},
				Update = function(p)
					return v13.History.Update(p)
				end,
				OnConnect = function()
					LastInput:Get()

					for _, v16 in pairs(v11) do
						v16:EnableHoverHighlight(false)
						v16:EnableAutoShine(false)
					end

					for _, v16 in pairs(v14) do
						v16.tile.Parent = v16.parent
					end
				end,
				OnDestroy = function()
					table.clear(v14)
				end
			}
			local _ = LastInput:Get() == "Gamepad"

			for i = 1, 4 do
				local guiObject3 = v10[i] or inside.History:Clone()
				local _ = v10[i] == nil
				v10[i] = guiObject3
				local assetTileTemplate = getAssetTileTemplate(i)
				v14[i] = {
					parent = guiObject3.Frame.Right,
					capture = assetTileTemplate.Filled.TextButton,
					tile = assetTileTemplate
				}
				local v21 = v11[i] or AssetComponent(assetTileTemplate)
				v15.List[i] = {
					Select = function(p)
						return assetTileTemplate.Filled.TextButton
					end,
					GuiObject = guiObject3,
					Render = function(p, p2, p3)
						local v22 = p2 and v8[p2.UID] or nil

						if p3 == 0 then
							v22 = v13.History.EmptyEntry()
						end

						local guiObject = p.GuiObject
						guiObject.Frame.Visible = p3 > 0
						guiObject.BorderSizePixel = v22 and p3 > 0 and 2 or 0
						guiObject.Name = not (p3 > 0 and v22) and "" or v22.UID or ""
						local guiObject2 = p.GuiObject
						local v24

						if v22 then
							v24 = v22.UID or nil
						end

						guiObject2:SetAttribute("CurrentSelection", v24)

						if v22 then
							if p3 > 0 then
								v13.History.UpdateGiftFrame(guiObject, v21, v22)
							end

							guiObject.Visible = true
						else
							v21:UpdateAsset(nil)
							guiObject.Visible = false
						end
					end
				}
				guiObject3.Parent = inside
				maid:Add(function()
					table.clear(v14)
				end)
			end

			connection2 = VirtualList(v15, scrollingFrame, inside)
		end

		assert(connection2):Connect()
	end
end

function GiftClaimWindow.GetSummary(_)
	if not v6 then
		v6 = true
		local v13 = remoteFunction:InvokeServer({
			Context = "GetSummary"
		})
		GiftClaimWindow.TotalGifts = v13.TotalGifts
		GiftClaimWindow.MaxGifts = v13.MaxGifts
	end

	return {
		TotalGifts = GiftClaimWindow.TotalGifts,
		MaxGifts = GiftClaimWindow.MaxGifts
	}
end

function GiftClaimWindow:Open()
	if maid then
		maid:Destroy()
	end

	maid = Trove.new()
	maid:Add(function()
		maid = nil

		if connection then
			connection:Destroy()
		end

		if connection2 then
			connection2:Destroy()
		end

		for _, v13 in pairs(v11) do
			v13:Destroy()
		end

		table.clear(v11)
		connection = nil
		connection2 = nil
	end)

	if v2 then
		maid:Add(function()
			tweenWindow()
		end)
		local textButtonComponent = TextButtonComponent(v3.Content.Frame.Category)
		maid:Add(textButtonComponent)

		local function updateCategoryComponent()
			textButtonComponent:UpdateProperties({
				Appearance = text == "Gifts" and "Inactive" or "Active",
				TextLabel = {
					Text = text == "Gifts" and "History" or "Gifts"
				}
			})
		end

		maid:Add(v3.Content.Frame.Category.Activated:Connect(function()
			if text == "Gifts" then
				text = "History"
			elseif text == "History" then
				text = "Gifts"
			end

			updateCategoryComponent()
			updateCategory()
		end))
		task.spawn(updateCategoryComponent)

		local function controllerAction(_: string, p, p2)
			if p ~= Enum.UserInputState.End or p2.UserInputType ~= Enum.UserInputType.Gamepad1 then
				return Enum.ContextActionResult.Pass
			end

			local GuiService2 = game:GetService("GuiService")
			GuiService2.SelectedObject = v3.Exit
			return Enum.ContextActionResult.Sink
		end

		game.ContextActionService:BindActionAtPriority(
			"GiftClaimExit",
			controllerAction,
			false,
			3,
			Enum.KeyCode.ButtonB
		)
		maid:Add(function()
			game.ContextActionService:UnbindAction("GiftClaimExit")
		end)
		maid:Add(v3.Exit.Activated:Connect(function()
			local Global = require(game.ReplicatedStorage.Global)
			Global.openMenu("Shop")
		end))
		tweenWindow(function()
			if LastInput:Get() == "Gamepad" then
				GuiService.SelectedObject = v3.Content.Frame.ScrollingFrame
			end
		end)
		updateCategory()
	else
		if not localPlayer.PlayerGui:FindFirstChild("GiftClaimWindow") then
			local clone = script.GiftClaimWindow:Clone()
			clone.Parent = localPlayer.PlayerGui
		end

		local maid2 = maid
		local PlayerUtil = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("PlayerUtil"))
		maid2:Add(PlayerUtil.ScreenReady({ "GiftClaimWindow" }, function(p)
			local v13 = assert(p.GiftClaimWindow)
			local window = v13:WaitForChild("Window", 5)

			if window then
				v2 = v13
				v3 = window
				scrollingFrame = v3.Content.Frame.ScrollingFrame
				inside = v3.Content.Frame.FakeScroll.Inside
				v3.AnchorPoint = Vector2.new(0.5, 0.5)
				v3.Position = UDim2.new(0.5, 0, 1.5, 0)
			end

			if maid and v2 then
				GiftClaimWindow:Open()
			else
				GiftClaimWindow:Close()
			end
		end, (`Init {script.Name}`)))
	end
end

function GiftClaimWindow:Close()
	if maid then
		maid:Destroy()
	elseif v2 then
		v2.Enabled = false
	end
end

function GiftClaimWindow:OnStart()
	remoteEvent.OnClientEvent:Connect(function(data)
		if data.Context == "GiftsChanged" or data.Context == "UpdateGifts" then
			local totalGifts = GiftClaimWindow.TotalGifts

			if data.Context == "GiftsChanged" then
				for _, v13 in pairs(data.Removed or {}) do
					v7[v13] = nil
					GiftClaimWindow.TotalGifts = math.max(0, GiftClaimWindow.TotalGifts - 1)
				end

				for k, v13 in pairs(data.Added or {}) do
					v7[k] = deserializeGift(k, v13)
					GiftClaimWindow.TotalGifts += 1
				end

				if data.History then
					for _, v13 in pairs(data.History.Removed or {}) do
						v8[v13] = nil
					end

					for k, v13 in pairs(data.History.Added or {}) do
						v8[k] = deserializeClaim(k, v13)
					end
				end
			elseif data.Context == "UpdateGifts" then
				flag = true
			end

			GiftClaimWindow.TotalGifts = data.TotalGifts or GiftClaimWindow.TotalGifts

			if GiftClaimWindow.TotalGifts ~= totalGifts and not data.Bulk then
				giftsChanged:Fire(GiftClaimWindow.TotalGifts, totalGifts)
			end

			if connection and text == "Gifts" then
				connection:UpdateRender(data.Bulk == true)
			elseif connection2 and text == "History" then
				connection2:UpdateRender(data.Bulk == true)
			end
		end
	end)
	task.spawn(function()
		while not HUD.IsInitialized do
			task.wait()
		end

		assert(HUD.IsInitialized, "bad HUD")
		HUD:RegisterPage("GiftClaim", function(...)
			return self:Open(...)
		end, function(...)
			return self:Close(...)
		end, function()
			return maid ~= nil or v2 ~= nil
		end)
	end)
end

return GiftClaimWindow