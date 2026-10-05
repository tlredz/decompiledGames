local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Spinner = {}
local FormatUtil = require(ReplicatedStorage.React.FormatUtil)
local spr = require(game.ReplicatedStorage.Modules.Util.spr)
local RarityUtil = require(game.ReplicatedStorage.Modules.Asset.RarityUtil)
local Trove = require(game.ReplicatedStorage.Modules.Util.Trove)
local Signal = require(game.ReplicatedStorage.Modules.Util.Signal)
local Replicator = require(game.ReplicatedStorage.Controllers.UI.Spinner.Helpers.Replicator)
require(game.ReplicatedStorage.Modules.Gacha.SharedGachaTypes)
local Confetti = require(game.ReplicatedStorage.Controllers.UI.Spinner.Components.Confetti)
local Notification = require(game.ReplicatedStorage.Notification)
local Shop = require(game.ReplicatedStorage.Shop)
local SpinnerUtil = require(script.SpinnerUtil)
require(script.SpinnerTypes)
local SpinnerConfig = require(script.SpinnerConfig)
local Error = require(game.ReplicatedStorage.Packages.Error)
local Locks = require(game.ReplicatedStorage.Controllers.Locks)
local Rage = require(script.Components.Rage)
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local v = {}
local v2 = {}
local result = nil
local random = Random.new()
local v3 = nil
local v4 = Signal.new()
local RunService = game:GetService("RunService")
local isStudio = RunService:IsStudio()

-- equivalent calls inferred from this helper; original call sites unknown
local function log(formatted)
	if isStudio then
		warn(`[{script.Name}]`, Error.displayAsJson(formatted, 4, true))
	end
end

local v5 = Signal.new()

function Spinner.OnOpen(callback)
	local v6 = Signal.new()

	if SpinnerUtil.Window and SpinnerUtil.Window.Screen and SpinnerUtil.Window.Screen.Enabled then
		task.defer(function()
			v6:Fire()
			v6:Destroy()
		end)
		return v6:Connect(callback)
	else
		return v5:Connect(callback)
	end
end

local v6 = Signal.new()

function Spinner.OnClose(callback)
	return v6:Connect(callback)
end

local function updateRender(list)
	debug.profilebegin("Spinner/Render")
	local v7 = assert(SpinnerUtil.Window)
	local X = v7.ScrollingFrame.AbsoluteSize.X
	local v8 = SpinnerUtil.getTileWidth() + (X * v7.UIListLayout.Padding.Scale + v7.UIListLayout.Padding.Offset)
	local v9 = v8 / X
	local uDim = UDim2.fromOffset(X * (v9 * #list), 0)

	if uDim ~= v7.ScrollingFrame.CanvasSize then
		v7.ScrollingFrame.CanvasSize = uDim
	end

	local v10 = math.max(
		v7.ScrollingFrame.AbsoluteWindowSize.X - v7.VirtualList.AbsoluteSize.X,
		v7.ScrollingFrame.CanvasPosition.X
	)
	v7.VirtualList.Position = UDim2.new(
		v7.VirtualList.Position.X.Scale,
		-v10 % v8 - v8,
		v7.VirtualList.Position.Y.Scale,
		0
	)
	local v11 = math.ceil(v10 / X / v9)

	for i = 1, #v do
		local renderIndex = v11 + i - 1
		v[i].Rbx.Name = tostring(renderIndex)
		v[i].RenderIndex = renderIndex
		v[i].WithinExtents = renderIndex == v3
		local withinExtents = list[renderIndex]

		if renderIndex == 0 or not withinExtents then
			v[i].Rbx.Visible = false
		else
			local _RenderUID = withinExtents._RenderUID
			v[i].Data = withinExtents
			v[i].Render(withinExtents, renderIndex, i)
			v[i]._RenderUID = _RenderUID

			if result and v[i].WithinExtents then
				result._WithinExtents = withinExtents
			end
		end
	end

	debug.profileend()
end

local function displaySelectorTiles()
	if result == nil then
		return true
	end

	local currentPack = result:GetCurrentPack()
	local v7 = {}
	local winnerFromUIDs = {}

	for _, v8 in pairs(currentPack.WinnersLeft) do
		table.insert(v7, v8)
	end

	for _, _SelectorTile in pairs(result._SelectorTiles) do
		table.insert(v7, _SelectorTile.UID)
	end

	for _, v8 in pairs(currentPack.WinnersAll) do
		local winnerFromUID = result:GetWinnerFromUID(v8)

		if winnerFromUID.Attributes.IgnoreInSelector then
			table.insert(v7, winnerFromUID._UID)
		end

		if not table.find(v7, winnerFromUID._UID) then
			table.insert(winnerFromUIDs, winnerFromUID)
		end
	end

	local function updateTiles(p: string?)
		for _, _SelectorTile in pairs(result._SelectorTiles) do
			local assetTile = _SelectorTile.AssetTile
			local winnerFromUID = result:GetWinnerFromUID(_SelectorTile.UID)

			if not (p == nil or assetTile._UID == p) then
				continue
			end

			local v8 = assert(assetTile._AssetInfo)
			assetTile:UpdateAsset({
				Type = winnerFromUID.Attributes.BonusItem and "BONUS" or winnerFromUID.Attributes.GrandPrize and "GRAND PRIZE" or nil,
				Image = v8.Image,
				Selected = result.CurrentPreview == v8.ItemId,
				DisplayName = v8.DisplayName,
				StorageName = winnerFromUID.StorageName,
				Rarity = v8.Rarity,
				ItemType = winnerFromUID.ItemType,
				ItemId = v8.ItemId
			})
		end
	end

	local v8 = #currentPack.WinnersLeft == 0

	for _, v9 in pairs(winnerFromUIDs) do
		local Selector = require(script.Selector)
		local assetTile = Selector(result, v9)
		local v11 = {
			AssetTile = assetTile,
			UID = v9._UID
		}
		local v12 = v9
		assert(assetTile._Rbx.TextButton).Activated:Connect(function()
			if v12.ItemId and SpinnerUtil.previewInstance(result, v12.ItemId, true) then
				updateTiles()
			end
		end)
		table.insert(result._SelectorTiles, v11)

		if v8 == false then
			updateTiles(assetTile._UID)
		end
	end

	if v8 then
		result.WindowMaid:Add(task.defer(updateTiles))
	end

	return true
end

local function revealItem(object, p)
	local currentPack = object:GetCurrentPack()
	local winnerFromUID

	if currentPack.RarestWinner then
		winnerFromUID = object:GetWinnerFromUID(currentPack.RarestWinner)
	end

	local itemId = winnerFromUID and winnerFromUID.ItemId or p.ItemId
	local v7 = #currentPack.WinnersLeft > 1
	local v8 = SpinnerConfig.PREVIEW_MODEL and object.Replicator and itemId and object.Replicator.GetAllItems()[itemId]
	local awards

	if v8 then
		awards = false
	else
		awards = p.Awards or false
	end

	local v9

	if v7 then
		v8 = false
		awards = false
		v9 = true
	else
		v9 = not (v8 or awards)
	end

	if v8 and itemId then
		local v10 = object.SessionMaid:Add(Instance.new("DepthOfFieldEffect"))
		v10.FarIntensity = 1
		v10.FocusDistance = 0
		v10.InFocusRadius = 14.5
		v10.NearIntensity = 1
		v10.Parent = game:GetService("Lighting")
		local tweenPreview = SpinnerUtil.tweenPreview(object.WinnerTile.Frame)
		tweenPreview:Play()
		object.SessionMaid:Add(tweenPreview)
		object.SessionMaid:Add(tweenPreview.Completed:Connect(function(_)
			v4:Fire()
		end))
		task.spawn(SpinnerUtil.previewInstance, object, itemId)

		if object._Blur.Parent then
			object._Blur:Destroy()
		end
	elseif awards then
		v4:Fire()
	elseif v9 then
		if v7 then
			object.SessionMaid:Add(task.delay(0.1, function()
				SpinnerUtil.playSound("Blox_Bonus_Roll_01")
				v4:Fire()
			end))
			return
		end

		SpinnerUtil.scalePreview(object, UDim2.fromScale(0.7, 0.7))
		local TweenService = game:GetService("TweenService")
		local tween = TweenService:Create(object.WinnerTile.Frame, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
			Size = UDim2.fromScale(1.3, 1.3)
		})
		tween:Play()
		object.SessionMaid:Add(tween)
		object.SessionMaid:Add(tween.Completed:Connect(function(_)
			v4:Fire()
		end))
		object.WinnerTile.Frame.Visible = true
	else
		log("idk man") -- equivalent call inferred; original call site unknown
	end
end

local function fullClose()
	v6:Fire()
	local v7 = assert(result)

	if v7.Replicator then
		v7.Replicator.Destroy()
		v7.Replicator = nil
	end

	local flag = false
	local v8 = {}
	local v9 = nil

	for _, _AllWinner in pairs(result._AllWinners) do
		if flag then
			break
		end

		if _AllWinner.Attributes.IgnoreInNotifications then
			continue
		end

		if _AllWinner.Awards then
			local v10 = 1

			for _, award in pairs(_AllWinner.Awards) do
				local name = award.Name

				if award.NoStack == true then
					name ..= `_{v10}`
				end

				v10 += 1
				local v11 = {
					Accessory = `<Color=Green><{award.Name}><Color=/>`,
					Material = `<Color=Purple><{award.Name}><Color=/>`,
					Trinket = `<Color=Yellow><{award.Name}><Color=/>`,
					ProfileBackground = `<Color=Green><{award.Name}><Color=/>`,
					Redeemable = `<Color=Yellow><{award.Name}><Color=/>`
				}
				local v12 = nil

				if award.ItemType == "Trinket" then
					if award.Accessory then
						local grade = award.Accessory.Grade
						local v13

						if award.Accessory.Modifiers then
							v13 = table.concat(award.Accessory.Modifiers, ",")
						end

						name = `{name}_{grade}_{v13}`
					else
						warn((`{name} doesn't have an accessory input`))
					end
				elseif award.ItemType == "Modifier" then
					local accessory = award.Accessory

					if accessory then
						v12 = `<Color=Green><{table.concat(accessory.Modifiers or {}, " ")} {accessory.Name} {FormatUtil.romanNumeral(accessory.Grade)}><Color=/>`
						flag = true
						v9 = "Your Trinket has been reforged into..."
					end
				end

				if v8[name] == nil then
					v8[name] = {
						Text = "",
						Amount = 0
					}
				end

				v8[name].Amount += award.Amount
				local text = v12 or v11[award.ItemType] or award.Name

				if v8[name].Amount > 1 and (award.ItemType == "Accessory" or award.ItemType == "Material" or award.ItemType == "Trinket" or award.ItemType == "Redeemable") then
					text = `{text} <Color=White>(%dx)<Color=/>`
				end

				v8[name].Text = text
			end
		else
			local formatted = `{_AllWinner.ItemId or _AllWinner.StorageName}`

			if v8[formatted] == nil then
				v8[formatted] = {
					Text = "",
					Amount = 0
				}
			end

			v8[formatted].Amount += 1
			local formatted2 = `<Color=Green><{_AllWinner.DisplayName}><Color=/>`

			if v8[formatted].Amount > 1 then
				formatted2 = `<Color=Green><{_AllWinner.DisplayName}><Color=/> <Color=White>(%dx)<Color=/>`
			end

			v8[formatted].Text = formatted2
		end
	end

	if next(v8) then
		Notification.new(v9 or "💰 Congratulations! You unboxed... 💰", 7.5):Display()

		for _, v10 in pairs(v8) do
			local text = v10.Text

			if text:lower():match("%%d") then
				text = text:format(v10.Amount)
			end

			Notification.new(text):Display()
		end
	end

	local pivot

	if localPlayer.Character then
		pivot = localPlayer.Character:GetPivot()
	else
		pivot = workspace.CurrentCamera.CFrame
	end

	if result.Winner.StorageName:match("Money") then
		local Effect = require(game.ReplicatedStorage.Effect)
		Effect.new("Gacha.CurrencyExplosion"):replicate({
			ID = 1,
			Character = localPlayer.Character,
			CFrame = pivot
		})
	elseif result.Winner.StorageName:match("Fragments") then
		local Effect = require(game.ReplicatedStorage.Effect)
		Effect.new("Gacha.CurrencyExplosion"):replicate({
			ID = 2,
			Character = localPlayer.Character,
			CFrame = pivot
		})
	end

	return true
end

local function newSession(list, items, boxName: string)
	if result and result:GetCurrentPack().BoxName ~= boxName then
		result.WindowMaid:Destroy()
	end

	Locks.SpinnerLock:Lock()
	local windowMaid

	if result then
		windowMaid = result.WindowMaid
		windowMaid:Remove(result.SessionMaid)
	else
		windowMaid = Trove.new()
		windowMaid:Add(function()
			if SpinnerUtil.Window.CurrentTheme then
				SpinnerUtil.Window.CurrentTheme.Destroy()
			end
		end)
		windowMaid:Add(function()
			local success, result2 = pcall(fullClose)

			if not success then
				task.spawn(error, result2)
			end

			result = nil
		end)

		local function controllerAction(_: string, p2, p3)
			if p2 ~= Enum.UserInputState.End or p3.UserInputType ~= Enum.UserInputType.Gamepad1 or result == nil then
				return Enum.ContextActionResult.Pass
			end

			if result._CloseButton then
				result._CloseButton.Instance(function(p4)
					local GuiService = game:GetService("GuiService")
					GuiService.SelectedObject = p4.TextButton
				end)
			elseif result._FastForwardButton then
				result:FastForwardPack()
			elseif result._NextPackButton then
				local currentPack = result:GetCurrentPack()
				local pack = result.Packs[currentPack.Index + 1]
				local winnersLeft = result:GetWinnersFromPack(pack).WinnersLeft

				if #winnersLeft > 0 then
					Spinner:Open(winnersLeft, items, currentPack.BoxName)
				end
			elseif result._SkipButton then
				result:SkipPack()
			end

			return Enum.ContextActionResult.Sink
		end

		local ContextActionService = game:GetService("ContextActionService")
		ContextActionService:BindActionAtPriority(
			"SpinnerWindowCloseAction",
			controllerAction,
			false,
			4,
			Enum.KeyCode.ButtonB
		)
		windowMaid:Add(function()
			local ContextActionService2 = game:GetService("ContextActionService")
			ContextActionService2:UnbindAction("SpinnerWindowCloseAction")
		end)
	end

	local v7 = SpinnerUtil.initWindow()
	local maid = windowMaid:Extend()
	local tile = SpinnerUtil.newTile()
	maid:Add(function()
		tile:Destroy()
	end)
	tile.Frame.Visible = false
	tile.Frame.Name = "Frame"
	tile.AnimationFrame.Size = v7.EndSize
	tile.ImageFrame.Frame.Size = UDim2.fromScale(0, 0)
	tile.Frame.BackgroundTransparency = 1
	tile.Frame.Position = UDim2.fromScale(0.5, 0.5)
	tile.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
	tile.Frame.ZIndex = 3
	tile.Frame.Parent = v7.WinnersContainerFrame

	if result == nil then
		local blur = windowMaid:Add(Instance.new("BlurEffect", game:GetService("Lighting")))
		result = {
			WindowMaid = windowMaid,
			SessionMaid = maid,
			WinnerTile = tile,
			Winner = list[1],
			Packs = {},
			FastForwardPack = function(self)
				local currentPack = self:GetCurrentPack()

				for _, v9 in pairs(currentPack.WinnersLeft) do
					self._FastForward[v9] = true
				end

				if self._FastForwardButton then
					self._FastForwardButton.Destroy()
				end
			end,
			GetWinnersFromPack = function(self, p2)
				local winnerFromUIDs = {}

				for _, v9 in pairs(p2.WinnersLeft) do
					table.insert(winnerFromUIDs, self:GetWinnerFromUID(v9))
				end

				local winnerFromUIDs2 = {}

				for _, v9 in pairs(p2.WinnersAll) do
					table.insert(winnerFromUIDs2, self:GetWinnerFromUID(v9))
				end

				return {
					WinnersLeft = winnerFromUIDs,
					WinnersAll = winnerFromUIDs2
				}
			end,
			GetSpinSettings = function(self)
				local DAMPENING = SpinnerConfig.DAMPENING
				local FREQUENCY = SpinnerConfig.FREQUENCY
				local NUM_DATA = SpinnerConfig.NUM_DATA
				local TWEEN_MIDDLE_TIME = SpinnerConfig.TWEEN_MIDDLE_TIME
				local MIN_SNAP_VELOCITY = SpinnerConfig.MIN_SNAP_VELOCITY

				if self._Skipped then
					DAMPENING = SpinnerConfig.SKIPPED_SPIN_DAMPENING
					FREQUENCY = SpinnerConfig.SKIPPED_SPIN_FREQUENCY
				elseif self._FastForwarded then
					DAMPENING = SpinnerConfig.FAST_SPIN_DAMPENING
					FREQUENCY = SpinnerConfig.FAST_SPIN_FREQUENCY
					TWEEN_MIDDLE_TIME = SpinnerConfig.FAST_SPIN_TWEEN_MIDDLE_TIME
					MIN_SNAP_VELOCITY = SpinnerConfig.MIN_SNAP_VELOCITY
				end

				return {
					Dampening = DAMPENING,
					Frequency = FREQUENCY,
					MinSnapVelocity = MIN_SNAP_VELOCITY,
					NumData = NUM_DATA,
					TweenMiddleTime = TWEEN_MIDDLE_TIME
				}
			end,
			IsFullDone = function(self)
				return #self:GetCurrentPack().WinnersLeft == 0 and self:GetCurrentPack().Index == #self.Packs
			end,
			SkipPack = function(self)
				for _, v9 in pairs(self:GetCurrentPack().WinnersAll) do
					self._Skip[v9] = true
				end
			end,
			GetWinnerFromUID = function(self, p3, p4)
				for _, v9 in pairs(p4 or self._AllWinners) do
					if v9._UID == p3 then
						return v9
					end
				end

				error((`no winner found from uid={p3}`))
			end,
			GetCurrentPack = function(self)
				local pack = self.Packs[self._CurrentPackId]

				if pack == nil then
					return {
						BoxName = "GachaData",
						WinnersAll = {},
						WinnersLeft = {},
						Index = -1,
						_UID = "-1"
					}
				end

				return pack
			end,
			DestroySelectorTiles = function(self)
				for i = #self._SelectorTiles, 1, -1 do
					local _SelectorTile = self._SelectorTiles[i]
					table.remove(self._SelectorTiles, i)
					_SelectorTile.AssetTile:Destroy(true)
				end
			end,
			CountWinnersAll = function(self, callback)
				local count = 0

				for _, _AllWinner in pairs(self._AllWinners) do
					if not (callback and callback(_AllWinner)) then
						count += 1
					end
				end

				return count
			end,
			_Blur = blur,
			_SelectorTiles = {},
			_PackNumber = 1,
			_NumData = 0,
			_MinSnapVelocity = 0,
			_TweenMiddleTime = 0,
			_Dampening = 0,
			_Frequency = 0,
			_CurrentPackId = 1,
			_CurrentSpin = 0,
			_AllWinners = {},
			_Cycles = 0,
			_Skip = {},
			_FastForward = {},
			_Skipped = false,
			_FastForwarded = false
		}
		SpinnerUtil.reflectTheme(boxName)
	end

	SpinnerUtil.toggleSpinnerAssetsVisible(true)
	assert(result)
	local allWinners = {}
	local v9 = {}
	local flag = false

	for _, _AllWinner in pairs(result._AllWinners) do
		table.insert(allWinners, _AllWinner)
	end

	for _, v10 in pairs(list) do
		table.insert(v9, v10)
	end

	for _, v10 in pairs(v9) do
		local flag2 = true

		for _, _AllWinner in pairs(result._AllWinners) do
			if v10._UID ~= _AllWinner._UID then
				continue
			end

			flag2 = false
			break
		end

		if not flag2 then
			continue
		end

		table.insert(allWinners, v10)
		flag = true
	end

	if flag then
		local v10 = #allWinners >= 20 and 10 or nil
		local v11 = {}

		for _, _AllWinner in pairs(result._AllWinners) do
			v11[_AllWinner._UID] = true
		end

		local pack = result.Packs[#result.Packs]

		if pack and (pack.BoxName ~= boxName or v10 and v10 <= #pack.WinnersAll) then
			pack = nil
		end

		local packs = result.Packs

		for _, v12 in ipairs(allWinners) do
			if v12.Attributes.SkipSpin then
				result._Skip[v12._UID] = true
			end

			if v12.Attributes.FastSpin then
				result._FastForward[v12._UID] = true
			end

			if v11[v12._UID] then
				continue
			end

			local bonusItem = v12.Attributes.BonusItem == true
			local HttpService

			if pack then
				if v10 and (bonusItem and 9999 or v10) <= #pack.WinnersLeft then
					pack = {
						Index = #packs + 1,
						BoxName = boxName,
						WinnersAll = {},
						WinnersLeft = {},
						_UID = 0
					}
					HttpService = game:GetService("HttpService")
					pack._UID = HttpService:GenerateGUID(false)
					table.insert(packs, pack)
				end
			else
				pack = {
					Index = #packs + 1,
					BoxName = boxName,
					WinnersAll = {},
					WinnersLeft = {},
					_UID = 0
				}
				HttpService = game:GetService("HttpService")
				pack._UID = HttpService:GenerateGUID(false)
				table.insert(packs, pack)
			end

			if not pack then
				continue
			end

			table.insert(pack.WinnersAll, v12._UID)
			table.insert(pack.WinnersLeft, v12._UID)
			v11[v12._UID] = true
		end

		result.Packs = packs
	end

	local _CurrentPackId = result._CurrentPackId
	local index = #result.Packs

	for _, pack in pairs(result.Packs) do
		if not (#pack.WinnersLeft > 0) then
			continue
		end

		index = pack.Index
		break
	end

	result._CurrentPackId = index

	if (_CurrentPackId ~= result._CurrentPackId or flag) and #result.Packs > 1 then
		result:DestroySelectorTiles()
	end

	if flag then
		result._Cycles += 1
	end

	local itemIds = {}

	for _, v11 in pairs(allWinners) do
		if v11.ItemId then
			table.insert(itemIds, v11.ItemId)
		end
	end

	if result.Replicator == nil then
		result.Replicator = Replicator()
	end

	assert(result.Replicator).Update(itemIds)
	local currentPack = result:GetCurrentPack()
	local winnerFromUID = result:GetWinnerFromUID(currentPack.WinnersLeft[1], allWinners)
	result._AllWinners = allWinners
	result._CurrentSpin += 1

	if not result._Skip[winnerFromUID._UID] then
		result._Skipped = false
	end

	if not result._FastForward[winnerFromUID._UID] then
		result._FastForwarded = false
	end

	result.SessionMaid = maid
	result.WinnerTile = tile
	result.Winner = winnerFromUID

	local function fn()
		local allItems = result.Replicator.GetAllItems()

		for _, pack in pairs(result.Packs) do
			local rarestWinner = nil
			local price = -1
			local stockChance = 1e999
			local value = -1

			for _, v13 in pairs(pack.WinnersAll) do
				local winnerFromUID2 = result:GetWinnerFromUID(v13)
				local v14 = Shop.mapToLegacy(Shop.LIBRARY.PRODUCT.ALL)[winnerFromUID2.StorageName]

				if not winnerFromUID2.ItemId or not allItems[winnerFromUID2.ItemId] or winnerFromUID2.Attributes.IgnoreInSelector then
					continue
				end

				if rarestWinner == nil then
					rarestWinner = v13
				end

				if v14 then
					if v14.Price and price < v14.Price then
						price = v14.Price
						rarestWinner = v13
					end

					if v14.StockChance and v14.StockChance < stockChance then
						stockChance = v14.StockChance
						rarestWinner = v13
					end
				end

				if not (value < winnerFromUID2.Rarity.Value) then
					continue
				end

				value = winnerFromUID2.Rarity.Value
				rarestWinner = v13
			end

			pack.RarestWinner = rarestWinner
		end
	end

	if result.Replicator and result._CurrentSpin == 1 then
		result.Replicator.OnItemAdded(function()
			fn()
		end)
	end

	if flag then
		fn()
	end

	local v12 = result._FastForward[winnerFromUID._UID]
	local RunService2 = game:GetService("RunService")
	local v13 = RunService2:IsStudio() or SpinnerUtil.canSkipBox(result)
	local RunService3 = game:GetService("RunService")
	local v14 = RunService3:IsStudio() or SpinnerUtil.canFastForwardBox(result)
	local v15 = false
	local v16 = false

	if v12 then
		if (result:CountWinnersAll(SpinnerUtil.IgnoreBonusItems()) == 1 or #currentPack.WinnersLeft > 1) and winnerFromUID.Attributes.FastSpin == nil then
			v15 = true
		end
	elseif v14 then
		v16 = true
	elseif v13 then
		v15 = true
	end

	if not v13 then
		v15 = false
	end

	if not v14 then
		v16 = false
	end

	if v13 and v15 then
		if result._Skipped == false then
			local skipButton = SpinnerUtil.skipButton(result)
			skipButton.OnClick(function()
				result:SkipPack()
				skipButton.Destroy()
			end).Init()
		end
	elseif v14 and v16 and result._FastForwarded == false then
		SpinnerUtil.fastFowardButton(result).OnClick(function()
			result:FastForwardPack()
		end).Init()
	end

	local function fn2(flag2: boolean?)
		if not flag2 and maid and maid.Add and SpinnerUtil.Window and SpinnerUtil.Window.Navigation then
			return false
		end

		if flag2 then
			warn("wasError[1]")
		end

		if maid then
			if not maid.Add then
				warn("maid.Add is missing")
			end
		else
			warn("no maid")
		end

		if SpinnerUtil.Window then
			if SpinnerUtil.Window.Navigation == nil then
				warn("no navigation")
			end
		else
			warn("no window")
		end

		return true
	end

	maid:Add(v4:Connect(function(p2)
		if result._SkipButton then
			result._SkipButton.Destroy()
		end

		if result._FastForwardButton then
			result._FastForwardButton.Destroy()
		end

		local v17 = fn2(p2) and true or p2
		local currentPack2 = result:GetCurrentPack()

		if v17 then
			table.clear(currentPack2.WinnersLeft)
		end

		if #currentPack2.WinnersLeft > 0 then
			table.remove(currentPack2.WinnersLeft, 1)
		end

		if v17 then
			warn("was error")
			Spinner:Close()
		else
			local success, result2 = pcall(displaySelectorTiles)

			if not success then
				warn(result2)
			end

			local winnersLeft = result:GetWinnersFromPack(currentPack2).WinnersLeft

			if #currentPack2.WinnersLeft ~= 0 then
				Spinner:Open(winnersLeft, items, currentPack2.BoxName)
				return
			end

			SpinnerUtil.playSound("Blox_UnboxingReveal_01")
			local count = 0

			if result.Replicator then
				for k in pairs(result.Replicator.GetAllItems()) do
					for _, v19 in pairs(currentPack2.WinnersAll) do
						if result:GetWinnerFromUID(v19).ItemId ~= k then
							continue
						end

						count += 1
						break
					end
				end
			end

			local isFullDone = result:IsFullDone()

			if count == 0 and isFullDone then
				Spinner:Close()
				task.spawn(function()
					local Enchant = require(localPlayer.PlayerGui.Main.UIController.Enchant)
					Enchant(nil)
				end)
			else
				if isFullDone then
					SpinnerUtil.closeButton(result).OnClick(function()
						Spinner:Close()
					end).Init()
					return
				end

				local pack = result.Packs[currentPack2.Index + 1]

				if pack then
					SpinnerUtil.nextPackButton(result).Instance(function(p3)
						p3.TextLabel.RichText = true
						p3.TextLabel.TextStrokeTransparency = 0
					end).SetSuffix("<i>Next</i>").OnClick(function()
						Spinner:Open(result:GetWinnersFromPack(pack).WinnersLeft, items, currentPack2.BoxName)
					end).Init()
				else
					warn("UHHH??", result.Packs)
				end
			end
		end
	end))
	local thread = nil
	thread = task.delay(15, function()
		thread = nil

		if fn2() or result == nil or not (result._CloseButton or result._SkipButton or result._NextPackButton or result._FastForwardButton) then
			v4:Fire(true)
			local error2 = error
			local v18

			if result then
				v18 = result:GetCurrentPack().BoxName
			end

			task.spawn(error2, (`TIMEOUT HIT {v18}`))
		end
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function cleanupTimeoutThread()
		if thread then
			pcall(function()
				task.cancel(thread)
				thread = nil
			end)
		end
	end

	maid:Add(v4:Connect(cleanupTimeoutThread))
	maid:Add(function()
		v3 = nil
		cleanupTimeoutThread() -- equivalent call inferred; original call site unknown
		spr.stop(SpinnerUtil.Window.ScrollingFrame)

		for _, v17 in pairs(v) do
			v17.WithinExtents = false
			spr.stop(v17.AnimationFrame)

			if result == nil then
				v17.Rbx:Destroy()
			end
		end

		if result == nil then
			table.clear(v)
		end
	end)
	return result
end

function Spinner:Open(p, items, boxName: string)
	local v7 = nil
	local success, result2 = pcall(function(...)
		v7 = newSession(p, items, boxName)
	end)

	if success then
		local v8 = assert(v7.Winner)

		if v8.Attributes.NoSpin then
			revealItem(v7, v8)
			return
		end

		local Players2 = game:GetService("Players")
		local accessoryMerge = Players2.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("AccessoryMerge")

		if accessoryMerge then
			accessoryMerge.Enabled = false
		end

		local v9 = {}

		if v8.Filter then
			for _, item in pairs(items) do
				if v8.Filter.FilterType == "Whitelist" then
					if table.find(v8.Filter.FilterList, item.StorageName) then
						table.insert(v9, item)
					end
				elseif v8.Filter.FilterType == "Blacklist" and not table.find(v8.Filter.FilterList, item.StorageName) then
					table.insert(v9, item)
				end
			end
		else
			v9 = items
		end

		local v10 = {
			Common = 0,
			Uncommon = 1,
			Rare = 2,
			Legendary = 3,
			Mythical = 4,
			Premium = 5
		}
		local v11 = {
			"Common",
			"Uncommon",
			"Rare",
			"Legendary",
			"Mythical",
			"Premium"
		}

		local function buildPoolByRarity(items2)
			local result3 = {}

			for _, v12 in pairs(v11) do
				result3[v12] = {}
			end

			for _, item in pairs(items2) do
				if result3[item.Rarity.Name] then
					table.insert(result3[item.Rarity.Name], item)
				else
					log(`Unknown rarity in pool: {item.Rarity.Name}`) -- equivalent call inferred; original call site unknown
				end
			end

			return result3
		end

		local function getRarityWeight(p3, p4: string?, p5: string?, p6: number)
			local v12 = v10[p3] or 0
			local v13

			if p3 == "Common" then
				v13 = 100
			elseif p3 == "Uncommon" then
				v13 = 35
			elseif p3 == "Rare" then
				v13 = 12
			elseif p3 == "Legendary" then
				v13 = 3
			elseif p3 == "Mythical" then
				v13 = 0.5
			elseif p3 == "Premium" then
				v13 = 0.1
			else
				v13 = 1
			end

			if p3 == p4 then
				v13 *= 0.12
			end

			if p3 == p5 then
				v13 *= 0.5
			end

			if p4 then
				local v14 = math.abs(v12 - (v10[p4] or 0))

				if v14 == 1 then
					v13 *= 1.15
				elseif v14 == 2 then
					v13 *= 1.35
				elseif v14 >= 3 then
					v13 *= 1.15
				end
			end

			if p6 > 0 then
				return v13 * (1 + v12 * p6 * 0.4)
			end

			return v13
		end

		local function chooseRarity(random2, name: string?, p3: string?, p4: number, p5)
			local v12 = {}
			local total = 0

			for _, rarity in pairs(v11) do
				local rarityWeight = getRarityWeight(rarity, name, p3, p4)
				local weight = rarity == p5 and 0 or rarityWeight
				table.insert(v12, {
					Rarity = rarity,
					Weight = weight
				})
				total += weight
			end

			local number = random2:NextNumber(0, total)
			local total2 = 0

			for _, v13 in ipairs(v12) do
				total2 += v13.Weight

				if number <= total2 then
					return v13.Rarity
				end
			end

			return v11[1]
		end

		local random2 = Random.new()
		local poolByRarity = buildPoolByRarity(v9)
		local spinSettings = v7:GetSpinSettings()
		local halfNumData = spinSettings.NumData / 2
		local name = nil
		local v13 = nil
		local v14 = {}

		for i = 1, spinSettings.NumData do
			local isWinner = i == halfNumData
			local v16 = math.abs(i - halfNumData) == 1
			local v17

			if isWinner then
				v17 = v8
			else
				local v18 = 1 - math.clamp(math.abs(i - halfNumData) / 30, 0, 1)
				local v19

				if v16 then
					v19 = v8.Rarity.Name
				end

				local v20 = poolByRarity[chooseRarity(random2, name, v13, v18, v19)]

				if v20 and #v20 > 0 then
					v17 = v20[random2:NextInteger(1, #v20)]
				else
					v17 = v9[random2:NextInteger(1, #v9)]
				end
			end

			if not isWinner then
				v13 = name
				name = v17.Rarity.Name
			end

			local v18 = {
				DisplayName = v17.DisplayName,
				Rarity = v17.Rarity,
				ImageName = v17.ImageName,
				StorageName = v17.StorageName,
				Attributes = v17.Attributes,
				Filter = v17.Filter,
				ItemType = v17.ItemType,
				ItemId = v17.ItemId,
				_IsWinner = isWinner,
				_RenderUID = i
			}

			if isWinner then
				v7.WinnerTile:Render(v18)
			end

			table.insert(v14, v18)
		end

		local v15 = 0
		local v16 = nil
		local tileWidth = SpinnerUtil.getTileWidth()

		local function updateTargetSpring()
			spr.stop(SpinnerUtil.Window.ScrollingFrame)
			local spinSettings2 = v7:GetSpinSettings()
			local v17 = v7._Skipped and v7._Skip[v7.Winner._UID] or v7._FastForward and v7._FastForward[v7.Winner._UID]
			spr.target(SpinnerUtil.Window.ScrollingFrame, spinSettings2.Dampening, spinSettings2.Frequency, {
				CanvasPosition = Vector2.new(
					v15 + (v17 and 0 or random:NextInteger(-tileWidth / 2.5, tileWidth / 2.5)),
					0
				)
			})
		end

		local function updateList(flag: boolean?)
			if v16 then
				pcall(function()
					task.cancel(v16)
					v16 = nil
				end)
			end

			v16 = v7.SessionMaid:Add(task.delay(flag and 0 or 0.1, function()
				v16 = nil
				tileWidth = SpinnerUtil.getTileWidth()
				v15 = (v7:GetSpinSettings().NumData / 2 - 1) * tileWidth - SpinnerUtil.Window.ScrollingFrame.AbsoluteSize.X / 2 + tileWidth / 2

				for i = 1, SpinnerUtil.getNumFillFrames(tileWidth) do
					if v[i] then
						continue
					end

					local tile = SpinnerUtil.newTile()
					local animationFrame = tile.AnimationFrame
					animationFrame.Size = SpinnerUtil.Window.StartSize
					tile.Frame.Name = tostring(i)
					tile.Frame.Parent = SpinnerUtil.Window.VirtualList
					local v17 = {}
					v17 = {
						Data = nil,
						RenderIndex = i,
						WithinExtents = false,
						Rbx = tile.Frame,
						AnimationFrame = animationFrame,
						_RenderUID = nil,
						Render = function(p3)
							if p3._RenderUID ~= v17._RenderUID then
								tile:Render(p3)
							end

							animationFrame.Size = v17.WithinExtents and SpinnerUtil.Window.EndSize or SpinnerUtil.Window.StartSize
							tile.Frame.Visible = true
							tile.Frame.ZIndex = (p3.Attributes.BonusItem or p3.Attributes.GrandPrize) and 3 or v17.WithinExtents and 2 or 1
						end
					}
					table.insert(v, v17)
				end

				updateTargetSpring()
			end))
		end

		SpinnerUtil.Window.Screen.Enabled = true
		SpinnerUtil.Window.ScrollingFrame.CanvasPosition = Vector2.zero
		updateList(true)
		updateRender(v14)
		local maid = v7.SessionMaid:Extend()
		maid:Add(SpinnerUtil.Window.TileTemplateRef.Frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateList))
		local RunService2 = game:GetService("RunService")
		maid:Add(RunService2.Heartbeat:Connect(function(_: number)
			updateRender(v14)
		end))
		local v17 = {}
		local currentPack = v7:GetCurrentPack()
		local theme = SpinnerUtil.getTheme(currentPack.BoxName)
		local v18 = theme
		local ThemeTransition = require(script.Helpers.ThemeTransition)
		local v19 = ThemeTransition.new(v18, 0)
		local v20 = {
			Enabled = currentPack.BoxName == "DogHouseGacha26",
			ParticleMod = 0.5
		}
		local v21 = {
			Enabled = false,
			Speed = 0.25,
			Elapsed = 0,
			MinTransparency = 0.3,
			MaxTransparency = 0.6
		}
		local v22 = {}

		if v20.Enabled then
			local v23 = {
				{
					AnchorPoint = Vector2.new(),
					Position = UDim2.new(0, 1),
					Rotation = 0,
					Size = UDim2.fromScale(1, 0.025)
				},
				{
					AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.fromScale(1, 1),
					Rotation = 180,
					Size = UDim2.fromScale(1, 0.025)
				}
			}

			for i = 1, #v23 do
				local frame = Instance.new("Frame")
				frame.BackgroundTransparency = 1
				frame.Size = v23[i].Size
				frame.Rotation = v23[i].Rotation
				frame.Position = v23[i].Position
				frame.AnchorPoint = v23[i].AnchorPoint
				frame.Parent = SpinnerUtil.Window.AboveSpinnerFrame
				frame.Name = "Rage" .. i
				local v24 = Rage.new(frame)
				v24:SetRateWithMod(v20.ParticleMod)
				v24:SetColorFunction(nil)
				v24:SetColor(v18.Colors.UnderGlowColor)
				v24:Start()
				table.insert(v22, v24)
			end

			maid:Add(function()
				for _, v24 in pairs(v22) do
					v24:Stop()
				end
			end)
			v7.SessionMaid:Add(function()
				for _, v24 in pairs(v22) do
					v24:Destroy()
				end
			end)
		end

		local RunService3 = game:GetService("RunService")
		maid:Add(RunService3.Heartbeat:Connect(function(dt)
			debug.profilebegin("Spinner.Theme.Update")

			if v7 and SpinnerUtil.Window.CurrentTheme then
				local underGlowColor = theme.Colors.UnderGlowColor

				if v7._WithinExtents and v7._WithinExtents.Attributes.GrandPrize then
					local unwrapped = RarityUtil.matchRarity("Premium"):unwrap()
					underGlowColor = unwrapped.Color
					local v23 = v17[unwrapped.Name]

					if not v23 then
						v23 = {
							Name = unwrapped,
							HeaderTitleText = theme.HeaderTitleText,
							Colors = 0
						}
						local ThemeColors = require(script.ThemeColors)
						v23.Colors = ThemeColors[unwrapped.Name]
					end

					v17[unwrapped] = v23
					v18 = v23
				else
					v18 = theme
				end

				local currentTheme = SpinnerUtil.Window.CurrentTheme.GetCurrentTheme()

				if v18.Name ~= currentTheme.Name then
					v19:SetTarget(v18, 0)

					for _, v23 in pairs(v22) do
						v23:SetColor(underGlowColor)
					end
				end

				local v23 = v19:Update(dt)
				SpinnerUtil.Window.CurrentTheme.Reflect(v23)

				if v21.Enabled then
					v21.Elapsed += dt
					local v25 = (math.sin(v21.Elapsed * 3.141592653589793 * 2 * v21.Speed) + 1) * 0.5
					local backgroundTransparency = v21.MinTransparency + (v21.MaxTransparency - v21.MinTransparency) * v25
					SpinnerUtil.Window.CurrentTheme.Gui.GradientFrameTop.BackgroundTransparency = backgroundTransparency
					SpinnerUtil.Window.CurrentTheme.Gui.GradientFrameBottom.BackgroundTransparency = backgroundTransparency
				end
			end

			debug.profileend()
		end))
		maid:Add(function()
			spr.stop(SpinnerUtil.Window.ScrollingFrame, "CanvasPosition")
			table.clear(v17)
		end)
		local v23 = 1
		local flag = false

		local function fn(duration: number?)
			if flag then
				return
			end

			flag = true
			maid:Destroy()
			local winner = v7.Winner

			if winner.Attributes["Particles.Celebration"] or winner.Attributes["Particles.Premium"] then
				local colors

				if winner.Attributes["Particles.Premium"] then
					colors = {}
					table.insert(colors, Color3.fromRGB(255, 204, 0))
					table.insert(colors, Color3.new(1, 0.862745, 0.309804))
					theme = SpinnerUtil.getTheme("PremiumBox")
					v18 = theme
				end

				Confetti().spawnAt(
					Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2),
					{
						CONFETTI_COLORS = colors,
						CONFETTI_COUNT = 30,
						CONFETTI_GRAVITY = Vector2.new(0, 600),
						CONFETTI_LIFETIME = 10,
						CONFETTI_AIR_DRAG = 0.7
					}
				)
			end

			if duration == nil or duration <= 0 then
				revealItem(v7, winner)
			else
				v7.SessionMaid:Add(task.delay(duration, revealItem, v7, winner))
			end
		end

		local v24 = nil
		local v25 = 0
		local flag2 = false
		local RunService4 = game:GetService("RunService")
		maid:Add(RunService4.Heartbeat:Connect(function(_)
			if v16 then
				return
			end

			if v7._Skip[v7.Winner._UID] and not v7._Skipped then
				v7._Skipped = true

				if SpinnerConfig.SKIP_ALL then
					table.clear(v7:GetCurrentPack().WinnersLeft)
				end

				fn()
			elseif v7._FastForward[v7.Winner._UID] and not (v7._FastForwarded or v7._Skipped) then
				v7._FastForwarded = true
				updateTargetSpring()
			else
				local state = spr.getState(SpinnerUtil.Window.ScrollingFrame, "CanvasPosition")
				local v26 = state and state.v[1] or 0

				if v26 == 0 then
					if v24 then
						if v25 >= 30 then
							if flag2 then
								warn("end early", v24)
								fn()
							else
								v25 /= 2
								warn("try update target spring")
								flag2 = true
								updateTargetSpring()
							end

							return
						else
							if v25 > 10 then
								warn((`framesAt0={v25}`))
							end

							v25 += 1
						end
					end
				else
					v25 = 0

					if v[math.floor(#v / 2)].Data then
						local v27 = math.ceil((SpinnerUtil.Window.ScrollingFrame.CanvasPosition.X + SpinnerUtil.Window.ScrollingFrame.AbsoluteSize.X / 2) / SpinnerUtil.getTileWidth())

						if not v3 or v27 ~= v3 and v3 < v27 then
							v3 = v27

							if v26 >= 1400 then
								SpinnerUtil.playSound(SpinnerConfig.TICK_SOUND_MAP[v23])
								v23 = v23 + 1 > #SpinnerConfig.TICK_SOUND_MAP and 1 or v23 + 1
							else
								SpinnerUtil.playSound(SpinnerConfig.TICK_SOUND_MAP[1])
							end
						end
					end

					local spinSettings2 = v7:GetSpinSettings()

					if v26 <= spinSettings2.MinSnapVelocity then
						spr.stop(SpinnerUtil.Window.ScrollingFrame, "CanvasPosition")
						local maid2 = maid
						local TweenService = game:GetService("TweenService")
						local v27 = maid2:Add(TweenService:Create(
							SpinnerUtil.Window.ScrollingFrame,
							TweenInfo.new(v7._Skipped and 0 or spinSettings2.TweenMiddleTime),
							{
								CanvasPosition = Vector2.new(v15, 0)
							}
						))
						v27:Play()
						SpinnerUtil.playSound("Wind")
						maid:Add(v27.Completed:Connect(function()
							fn(0.1)
						end))
					end
				end

				v24 = v26
			end
		end))
	else
		warn(result2)
		v4:Fire(true)
	end
end

function Spinner:Close()
	if SpinnerUtil.Window.Screen then
		SpinnerUtil.Window.Screen.Enabled = false
	end

	local Players2 = game:GetService("Players")
	local accessoryMerge = Players2.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("AccessoryMerge")

	if accessoryMerge then
		accessoryMerge.Enabled = true
	end

	if result and result.WindowMaid then
		result.WindowMaid:Destroy()
	end
end

function Spinner:IsOpen()
	return SpinnerUtil.Window.Screen and SpinnerUtil.Window.Screen.Enabled
end

local v7 = 1

function Spinner.OnStart(_)
	task.spawn(function()
		local Net = require(game.ReplicatedStorage.Modules.Net)
		local remoteEvent = Net:RemoteEvent("SpinGacha")
		local Net2 = require(game.ReplicatedStorage.Modules.Net)
		local remoteEvent2 = Net2:RemoteEvent("PrepClientSpin")
		local thread = nil
		v5:Connect(function(_: nil)
			if thread then
				task.cancel(thread)
				thread = nil
			end

			Locks.SpinnerLock:Lock()
		end)
		v6:Connect(function(_: nil)
			Locks.SpinnerLock:Unlock()
		end)
		remoteEvent2.OnClientEvent:Connect(function(...)
			if thread then
				task.cancel(thread)
				thread = nil
			end

			Locks.SpinnerLock:Lock()
			thread = task.delay(3, function()
				thread = nil
				local GachaWindow = require(game.ReplicatedStorage.Controllers.UI.GachaWindow)

				if not GachaWindow:IsOpen() then
					Locks.SpinnerLock:Unlock()
				end
			end)
		end)
		remoteEvent.OnClientEvent:Connect(function(data)
			assert(data)
			assert(data.Winners)
			assert(data.BoxName)
			v7 += 1
			local v8 = v7

			if localPlayer:GetAttribute("RobuxPurchasePrompt") ~= nil then
				local MarketplaceService = game:GetService("MarketplaceService")
				MarketplaceService.PromptProductPurchaseFinished:Wait()
			end

			task.spawn(function()
				local Global = require(game.ReplicatedStorage.Global)
				Global.closeMenu("Shop")
				local Inventory = require(game.ReplicatedStorage:WaitForChild("Controllers"):WaitForChild("UI"):WaitForChild("Inventory"))
				Inventory:Close()
			end)

			if v7 ~= v8 then
				warn("new spin was called before last processed")
				return
			end

			if data.RaffleData then
				local values = {}
				v2[data.BoxName] = values

				for _, v9 in pairs(data.RaffleData) do
					local rarity = assert(RarityUtil.tryGetRarity(v9.Rarity))
					table.insert(values, (table.freeze({
						StorageName = v9.StorageName,
						Attributes = v9.Attributes,
						DisplayName = v9.DisplayName,
						ImageName = v9.ImageName,
						Rarity = rarity,
						ItemType = v9.ItemType,
						ItemId = v9.ItemId
					})))
				end

				table.freeze(values)
			end

			local v9 = assert(v2[data.BoxName], (`no raffle cache found: {data.BoxName}`))
			local v10 = {}

			for i = 1, #data.Winners do
				local winner = data.Winners[i]
				local v11 = {
					StorageName = winner.StorageName,
					ImageName = winner.ImageName,
					DisplayName = winner.DisplayName,
					Awards = winner.Awards,
					Attributes = winner.Attributes,
					Filter = winner.Filter,
					Rarity = assert(RarityUtil.tryGetRarity(winner.Rarity)),
					_UID = 0,
					ItemType = 0,
					ItemId = 0
				}
				local HttpService = game:GetService("HttpService")
				v11._UID = HttpService:GenerateGUID(false)
				v11.ItemType = winner.ItemType
				v11.ItemId = winner.ItemId
				table.insert(v10, v11)
			end

			v5:Fire()
			Spinner:Open(v10, v9, data.BoxName)
		end)
	end)
end

return Spinner