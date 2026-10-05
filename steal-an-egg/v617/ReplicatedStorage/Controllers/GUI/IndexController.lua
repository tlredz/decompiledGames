local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local AreaIndexProgressComponent = require(script.AreaIndexProgressComponent)
local Areas = require(ReplicatedStorage.Data.Areas)
require(ReplicatedStorage.Shared.Types.AssetItem)
local AssetItems = require(ReplicatedStorage.Shared.Util.AssetItems)
local AssetOddsDisplay = require(ReplicatedStorage.Client.Util.AssetOddsDisplay)
local Assets = require(ReplicatedStorage.Data.Assets)
local personalities = Assets.Personalities
local Assets2 = require(ReplicatedStorage.Data.Assets)
local ButtonFX = require(ReplicatedStorage.Client.UI.VFX.ButtonFX)
local ClaimRewardPanel = require(script.ClaimRewardPanel)
local Simple = require(ReplicatedStorage.Packages.FormatNumber.Simple)
local GUI = require(ReplicatedStorage.Client.GUI)
local Hud = require(ReplicatedStorage.Client.Hud)
require(script.Types.Interface)
local ItemDisplay = require(ReplicatedStorage.Shared.Modules.ItemDisplay)
local EnsureUIScale = require(ReplicatedStorage.Shared.Utils.EnsureUIScale)
local BrainrotEgg = require(ReplicatedStorage.Data.BrainrotEgg)
local Constants = require(ReplicatedStorage.Shared.Globals.Constants)
local LimitedEgg = require(ReplicatedStorage.Data.LimitedEgg)
local Log = require(ReplicatedStorage.Packages.Log)
local LuminousEgg = require(ReplicatedStorage.Data.LuminousEgg)
local MonsterEgg = require(ReplicatedStorage.Data.MonsterEgg)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Rift = require(ReplicatedStorage.Data.Rift)
local RiftEligibility = require(ReplicatedStorage.Shared.Util.RiftEligibility)
local RiftMachineSchedule = require(ReplicatedStorage.Shared.Util.RiftMachineSchedule)
local ScrambleTradeIn = require(ReplicatedStorage.Data.ScrambleTradeIn)
local Save = require(ReplicatedStorage.Shared.Save)
local SurfaceButton = require(ReplicatedStorage.Client.UI.VFX.SurfaceButton)
local Tabs = require(ReplicatedStorage.Client.Tabs)
local Trove = require(ReplicatedStorage.Packages.Trove)
local TryLock = require(ReplicatedStorage.Shared.Utils.TryLock)
local class = {}
class.__index = class
class.__class = "IndexController"
local v = { "World", "Limited" }
local color = Color3.fromRGB(255, 55, 55)
local color2 = Color3.fromRGB(255, 255, 255)
local color3 = Color3.fromRGB(0, 0, 0)
local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.7, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, -1, true)
local color4 = Color3.fromRGB(104, 111, 122)
local tweenInfo3 = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- equivalent calls inferred from this helper; original call sites unknown
local function updateLive()
	return workspace:GetServerTimeNow() >= Constants.UPDATE_LIVE_AT
end

return {
	Start = function()
		local v2 = Log.new()
		local tryLock = TryLock()
		local frame = GUI.Index().Frame
		local every = Hud.Every("IndexButton")
		local every2 = Hud.Every("IndexNotificationBadge")
		local claimAll = frame:FindFirstChild("ClaimAll")

		if claimAll == nil or not claimAll:IsA("GuiObject") then
			claimAll = nil
		end

		local notificationBadge

		if claimAll == nil then
			notificationBadge = nil
		else
			notificationBadge = claimAll:FindFirstChild("NotificationBadge")
		end

		local function renderNotificationBadge(guiObject, p: number)
			if guiObject == nil or not guiObject:IsA("GuiObject") then
				return
			end

			guiObject.Visible = p > 0

			if p == 0 then
				return
			end

			for _, label in guiObject:GetDescendants() do
				if label:IsA("TextLabel") then
					label.Text = tostring(p)
				end
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function seesTheRift()
			local localPlayer = Players.LocalPlayer

			if localPlayer == nil then
				return false
			end

			local v4 = Save.Await()
			local v5 = v4 == nil and 0 or v4.SpeedPower
			local v6 = v4 == nil and 0 or v4.LastLogout
			return RiftEligibility.IsRevealed(localPlayer, v5, v6)
		end

		local scrollingFrame = frame.List.ScrollingFrame
		local section = scrollingFrame:FindFirstChild("Section")
		assert(section ~= nil, "Index list is missing its Section template")
		local viewing = frame.Side.Viewing
		local icon = viewing.Icon
		local petName = viewing.PetName
		local petRarity = viewing.PetRarity
		local petOdds = viewing.PetOdds
		local rewards = frame.Side.Rewards
		local claim = rewards.Claim
		local unlocked = frame.Unlocked
		local fill = unlocked.Fill
		local textLabel = unlocked.TextLabel
		local tabButtons = frame:FindFirstChild("TabButtons")
		local v4 = {}

		for i, childName in ipairs(v) do
			local button

			if tabButtons ~= nil then
				button = tabButtons:FindFirstChild(childName)
			end

			if not (button ~= nil and button:IsA("GuiButton")) then
				continue
			end

			button.LayoutOrder = i
			local strokeHolder = button:FindFirstChild("StrokeHolder")
			local uIStroke

			if strokeHolder ~= nil then
				uIStroke = strokeHolder:FindFirstChildOfClass("UIStroke")
			end

			local textLabel2 = button:FindFirstChild("TextLabel")
			local icon2 = button:FindFirstChild("Icon")
			local label

			if not (textLabel2 == nil or not textLabel2:IsA("TextLabel")) then
				label = textLabel2
			end

			local icon3

			if not (icon2 == nil or not icon2:IsA("ImageLabel")) then
				icon3 = icon2
			end

			v4[childName] = {
				Button = button,
				Stroke = uIStroke,
				Label = label,
				Icon = icon3,
				Tint = button.BackgroundColor3,
				StrokeTransparency = uIStroke == nil and 0 or uIStroke.Transparency,
				TextTransparency = (textLabel2 == nil or not textLabel2:IsA("TextLabel")) and 0 or textLabel2.TextTransparency,
				IconTransparency = (icon2 == nil or not icon2:IsA("ImageLabel")) and 0 or icon2.ImageTransparency
			}
		end

		local images = {}
		local v5 = 0

		for _, image in section.Pets:GetChildren() do
			local v6 = tonumber(string.match(image.Name, "^Clr(%d+)$"))

			if not (v6 ~= nil and image:IsA("ImageLabel")) then
				continue
			end

			images[v6] = image
			v5 = math.max(v5, v6)
		end

		assert(v5 > 0, "Index Section.Pets has no Clr cell templates")

		-- equivalent calls inferred from this helper; original call sites unknown
		local function variantForRarity(rank: number)
			return (math.clamp(rank, 1, v5))
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function dressWithRarityGradient(clone, rarityGradient)
			local uIGradient = clone:FindFirstChildOfClass("UIGradient")

			if uIGradient ~= nil then
				uIGradient:Destroy()
			end

			clone.BackgroundColor3 = Color3.new(1, 1, 1)
			local clone_2 = rarityGradient:Clone()
			clone_2.Parent = clone
		end

		local uIGridLayout = section.Pets:FindFirstChildOfClass("UIGridLayout")
		assert(uIGridLayout ~= nil, "Index Section.Pets needs a UIGridLayout")
		local scale = section.Size.Y.Scale
		local scale2 = section.Pets.Size.Y.Scale
		local scale3 = uIGridLayout.CellSize.Y.Scale
		local scale4 = uIGridLayout.CellPadding.Y.Scale
		local scale5 = uIGridLayout.CellSize.X.Scale
		local scale6 = uIGridLayout.CellPadding.X.Scale
		local perRow = math.max(1, (math.floor((1 + scale6) / (scale5 + scale6))))
		local v7 = scale2 * scale
		local cellAbs = scale3 * v7
		local padAbs = scale4 * v7
		local bgPosAbs = section.BgFrame.Position.Y.Scale * scale
		local v11 = section.Unlocked.Position.Y.Scale * scale
		local barSizeAbs = section.Unlocked.Size.Y.Scale * scale
		local v13 = {
			PerRow = perRow,
			PetsPosAbs = section.Pets.Position.Y.Scale * scale,
			BgPosAbs = bgPosAbs,
			BarSizeAbs = barSizeAbs,
			BottomAbs = math.max(0, scale - v11 - barSizeAbs),
			CellAbs = cellAbs,
			PadAbs = padAbs
		}

		function class._build()
			local self = setmetatable({}, class)
			self._trove = Trove.new()
			self._openTrove = nil
			self._sections = {}
			self._sectionsByPage = {}
			self._currentPage = "World"
			self._selectedCategory = nil
			self._isOpen = false
			self._claimAllArmed = false
			self._builtLive = false
			self._builtLaboratory = false
			self._badgePulseTweens = {}
			self:_buildEntries()
			self:_init()
			return self
		end

		function class:_buildEntries()
			self._builtLive = updateLive()
			self._builtLaboratory = RiftMachineSchedule.IsLaboratoryTime()

			for _, v14 in ipairs(v) do
				self._sectionsByPage[v14] = {}
			end

			for k, v14 in Areas.Directory do
				local entries = {}

				for _, v16 in v14.DropTable do
					local category = v16[1]
					local v18 = v16[2]
					local config = Assets2.Directory[category]

					if v18 <= 0 or config.DontRoll == true then
						continue
					end

					table.insert(entries, {
						Category = category,
						Config = config,
						ItemData = {
							Category = category,
							Mutations = {},
							Scale = 1,
							Personality = personalities.Personalities.Normal,
							HasBeenFirstPlaced = true
						}
					})
				end

				table.sort(entries, function(a, b)
					local rank = a.Config.Rarity.Rank
					local rank2 = b.Config.Rarity.Rank

					if rank ~= rank2 then
						return rank < rank2
					end

					if a.Config.DropWeight == b.Config.DropWeight then
						return a.Category < b.Category
					end

					return a.Config.DropWeight > b.Config.DropWeight
				end)

				if #entries > 0 then
					table.insert(self._sectionsByPage.World, {
						SectionId = k,
						DisplayName = v14.DisplayName,
						Icon = v14.Icon,
						HeaderGradient = v14.Rarity.RarityGradient,
						SortOrder = v14.Rarity.Rank,
						RewardKind = "AreaBat",
						RewardGearId = v14.IndexBatGearId,
						Entries = entries
					})
				end
			end

			local function limitedEntryOrder(p, p2)
				if p.Config.Rarity.Rank ~= p2.Config.Rarity.Rank then
					return p.Config.Rarity.Rank < p2.Config.Rarity.Rank
				end

				local earningRate = p.Config.EarningRate or 0
				local earningRate2 = p2.Config.EarningRate or 0

				if earningRate == earningRate2 then
					return p.Category < p2.Category
				end

				return earningRate < earningRate2
			end

			local function collectLimitedEntries(list)
				local result = {}

				for _, v14 in ipairs(list) do
					local assetId = v14.AssetId
					local config = Assets2.Directory[assetId]

					if config ~= nil then
						table.insert(result, {
							Category = assetId,
							Config = config,
							ItemData = {
								Category = assetId,
								Mutations = {},
								Scale = 1,
								Personality = personalities.Personalities.Normal,
								HasBeenFirstPlaced = true
							}
						})
					end
				end

				table.sort(result, limitedEntryOrder)
				return result
			end

			local entries2 = collectLimitedEntries(LimitedEgg.Entries)
			local mechaReroll = LimitedEgg.MechaReroll

			if mechaReroll ~= nil then
				for _, v15 in ipairs((collectLimitedEntries(mechaReroll.Entries))) do
					table.insert(entries2, v15)
				end
			end

			table.sort(entries2, limitedEntryOrder)
			table.insert(self._sectionsByPage.Limited, {
				SectionId = "LimitedEgg",
				DisplayName = LimitedEgg.DisplayName,
				Icon = self._builtLive and "rbxassetid://97935712077919" or "rbxassetid://108209625322017",
				HeaderGradient = nil,
				SortOrder = 1000000,
				RewardKind = "GearClaim",
				RewardGearId = "GravityDisruptor",
				Entries = entries2
			})

			if self._builtLive then
				local entries = collectLimitedEntries(LuminousEgg.Entries)

				for _, v16 in ipairs((collectLimitedEntries(LuminousEgg.MechaEntries))) do
					table.insert(entries, v16)
				end

				table.sort(entries, limitedEntryOrder)
				table.insert(self._sectionsByPage.Limited, {
					SectionId = "LuminousEgg",
					DisplayName = LuminousEgg.DisplayName,
					Icon = LuminousEgg.BackgroundImage,
					HeaderGradient = nil,
					SortOrder = 1500000,
					RewardKind = "GearClaim",
					RewardGearId = "GravityDisruptor",
					Entries = entries
				})
			end

			local entries3 = collectLimitedEntries(BrainrotEgg.Entries)
			table.insert(self._sectionsByPage.Limited, {
				SectionId = "BrainrotEgg",
				DisplayName = BrainrotEgg.DisplayName,
				Icon = BrainrotEgg.BackgroundImage,
				HeaderGradient = nil,
				SortOrder = 1e999,
				RewardKind = "GearClaim",
				RewardGearId = "BeeLauncher",
				Entries = entries3
			})
			local entries4 = collectLimitedEntries(MonsterEgg.Entries)

			for _, v17 in ipairs((collectLimitedEntries(MonsterEgg.MechaEntries))) do
				table.insert(entries4, v17)
			end

			table.sort(entries4, limitedEntryOrder)
			table.insert(self._sectionsByPage.Limited, {
				SectionId = "MonsterEgg",
				DisplayName = MonsterEgg.DisplayName,
				Icon = MonsterEgg.BackgroundImage,
				HeaderGradient = nil,
				SortOrder = 3000000,
				RewardKind = "GearClaim",
				RewardGearId = "BeeLauncher",
				Entries = entries4
			})
			local pets, entries5

			if RiftEligibility.IsFeatureLive() then
				-- equivalent call inferred; original call site unknown
				if seesTheRift() then
					pets = {}

					for i, banner in ipairs(Rift.Banners) do
						for i2, pet in ipairs(banner.Pets) do
							table.insert(pets, pet)
						end
					end

					entries5 = collectLimitedEntries(pets)

					if #entries5 > 0 then
						table.insert(self._sectionsByPage.Limited, {
							SectionId = "Rift",
							DisplayName = "Rift",
							Icon = "rbxassetid://137708974138911",
							HeaderGradient = nil,
							SortOrder = 2000000,
							RewardKind = "Collection",
							RewardGearId = "",
							RewardIcon = "",
							Entries = entries5
						})
					end
				end
			else
				pets = {}

				for i, banner in ipairs(Rift.Banners) do
					for i2, pet in ipairs(banner.Pets) do
						table.insert(pets, pet)
					end
				end

				entries5 = collectLimitedEntries(pets)

				if #entries5 > 0 then
					table.insert(self._sectionsByPage.Limited, {
						SectionId = "Rift",
						DisplayName = "Rift",
						Icon = "rbxassetid://137708974138911",
						HeaderGradient = nil,
						SortOrder = 2000000,
						RewardKind = "Collection",
						RewardGearId = "",
						RewardIcon = "",
						Entries = entries5
					})
				end
			end

			if self._builtLaboratory then
				local pets2 = {}

				for _, banner in ipairs(ScrambleTradeIn.Banners) do
					for _, pet in ipairs(banner.Pets) do
						table.insert(pets2, pet)
					end
				end

				local entries = collectLimitedEntries(pets2)

				if #entries > 0 then
					table.insert(self._sectionsByPage.Limited, {
						SectionId = "DrScramble",
						DisplayName = "Dr. Scramble",
						Icon = "rbxassetid://86377465284767",
						HeaderGradient = nil,
						SortOrder = 500000,
						RewardKind = "Collection",
						RewardGearId = "",
						RewardIcon = "",
						Entries = entries
					})
				end
			end

			for _, v18 in ipairs(v) do
				table.sort(self._sectionsByPage[v18], function(a, b)
					if a.SortOrder == b.SortOrder then
						return a.SectionId < b.SectionId
					end

					return a.SortOrder < b.SortOrder
				end)
			end
		end

		function class:_getSave()
			return Save.Await()
		end

		function class:_isDiscovered(p)
			local _getSave = self:_getSave()
			return _getSave ~= nil and _getSave.Index[p.Category] == true
		end

		function class:_isClaimed(p)
			local _getSave = self:_getSave()
			return _getSave ~= nil and _getSave.IndexClaimedCategories[p.Category] == true
		end

		function class:_isClaimable(p)
			return self:_isDiscovered(p) and not self:_isClaimed(p)
		end

		function class:_getEntryDisplayName(p)
			return ItemDisplay.GetNameFromItemData(p.ItemData)
		end

		function class:_getEntryByCategory(p2: string?)
			if p2 == nil then
				return nil
			end

			for _, v14 in ipairs(self._sectionsByPage[self._currentPage]) do
				for _, entry in ipairs(v14.Entries) do
					if entry.Category == p2 then
						return entry
					end
				end
			end

			return nil
		end

		function class:_renderHiddenIcon(p)
			p.ImageColor3 = color3
			p.ImageTransparency = 0.35
		end

		function class:_renderVisibleIcon(p)
			p.ImageColor3 = Color3.fromRGB(255, 255, 255)
			p.ImageTransparency = 0
		end

		function class:_renderEntryIcon(p, p2, flag: boolean)
			p.Image = Assets2.Directory[p2.Category].Icon or ""
			p.ScaleType = Enum.ScaleType.Fit

			if flag then
				self:_renderVisibleIcon(p)
			else
				self:_renderHiddenIcon(p)
			end
		end

		function class:_sizeSection(state, p: number)
			local v14 = math.max(1, (math.ceil(p / v13.PerRow)))
			local v15 = v14 * v13.CellAbs + (v14 - 1) * v13.PadAbs
			local v16 = v13.PetsPosAbs + v15 + 0.04
			local v17 = v16 + v13.BarSizeAbs
			local v18 = v17 + v13.BottomAbs
			local v19 = math.max(0, v17 - v13.BgPosAbs)
			state.Size = UDim2.new(state.Size.X.Scale, state.Size.X.Offset, v18, 0)
			state.BgFrame.Size = UDim2.new(state.BgFrame.Size.X.Scale, 0, v19 / v18, 0)
			state.BgFrame.Position = UDim2.new(state.BgFrame.Position.X.Scale, 0, v13.BgPosAbs / v18, 0)
			state.Unlocked.Size = UDim2.new(state.Unlocked.Size.X.Scale, 0, v13.BarSizeAbs / v18, 0)
			state.Unlocked.Position = UDim2.new(
				state.Unlocked.Position.X.Scale,
				0,
				(v16 + v13.BarSizeAbs * state.Unlocked.AnchorPoint.Y) / v18,
				0
			)
			state.Pets.Position = UDim2.new(state.Pets.Position.X.Scale, 0, v13.PetsPosAbs / v18, 0)
			state.Pets.Size = UDim2.new(state.Pets.Size.X.Scale, 0, v15 / v18, 0)
			local uIGridLayout2 = state.Pets:FindFirstChildOfClass("UIGridLayout")

			if uIGridLayout2 ~= nil then
				uIGridLayout2.CellSize = UDim2.new(uIGridLayout2.CellSize.X.Scale, 0, v13.CellAbs / v15, 0)
				uIGridLayout2.CellPadding = UDim2.new(uIGridLayout2.CellPadding.X.Scale, 0, v13.PadAbs / v15, 0)
			end
		end

		function class:_ensureSectionPool(p: number)
			if self._openTrove == nil then
				return
			end

			while #self._sections < p do
				local clone = section:Clone()
				clone.Name = `IndexArea{#self._sections + 1}`
				clone.Visible = false
				clone.Parent = scrollingFrame
				local v14 = {
					Frame = clone,
					Section = nil,
					Slots = {},
					ProgressComponent = AreaIndexProgressComponent.new(clone.Unlocked, function(p2: string)
						tryLock(function()
							if p2 == "LimitedEgg" or p2 == "BrainrotEgg" or p2 == "MonsterEgg" or p2 == "LuminousEgg" then
								self:_claimLimitedEggReward(p2)
							else
								self:_equipAreaBat(p2)
							end
						end)
					end)
				}
				table.insert(self._sections, v14)
				self._openTrove:Add(clone)
				self._openTrove:Add(function()
					v14.ProgressComponent:Destroy()
				end)
			end
		end

		function class:_ensureSlotPool(p, p2)
			if self._openTrove == nil then
				return
			end

			for i, entry in ipairs(p2.Entries) do
				local rarity = entry.Config.Rarity
				local v14 = variantForRarity(rarity.Rank) -- equivalent call inferred; original call site unknown
				local formatted = `Clr{v14}`
				local rarityGradient

				if v14 < rarity.Rank then
					rarityGradient = rarity.RarityGradient
				end

				local variant

				if rarityGradient == nil then
					variant = formatted
				else
					variant = `{formatted}:{rarity._id}`
				end

				local slot = p.Slots[i]

				if slot ~= nil and slot.Variant ~= variant then
					slot.Teardown()
					slot.Frame:Destroy()
					slot = nil
				end

				if slot ~= nil then
					continue
				end

				local image = p.Frame.Pets:FindFirstChild(formatted)
				local v16

				if image == nil then
					v16 = false
				else
					v16 = image:IsA("ImageLabel")
				end

				assert(v16, (`Index section lost its {formatted} template`))
				local clone = image:Clone()
				clone.Name = `IndexEntry{i}`
				clone.Visible = false
				clone.LayoutOrder = i
				clone.Parent = p.Frame.Pets

				if rarityGradient ~= nil then
					dressWithRarityGradient(clone, rarityGradient) -- equivalent call inferred; original call site unknown
				end

				local v17 = {
					Frame = clone,
					Variant = variant,
					Entry = nil,
					Teardown = function() end
				}
				v17.Teardown = SurfaceButton(clone, 1.08, function()
					local entry2 = v17.Entry

					if entry2 == nil or self._selectedCategory == entry2.Category then
						return
					end

					self:_selectEntry(entry2.Category)
				end)
				p.Slots[i] = v17
				local v19 = v17
				self._openTrove:Add(function()
					v19.Teardown()
				end)
				self._openTrove:Add(clone)
			end
		end

		function class:_renderSlot(p, entry)
			local frame2 = p.Frame
			p.Entry = entry

			if entry == nil then
				frame2.Visible = false
				return
			end

			local _isDiscovered = self:_isDiscovered(entry)
			local _isClaimed = self:_isClaimed(entry)
			local v14 = self._selectedCategory == entry.Category
			frame2.Visible = true

			if _isDiscovered then
				frame2.TextLabel.Text = self:_getEntryDisplayName(entry)
			else
				frame2.TextLabel.Text = "???"
			end

			self:_renderEntryIcon(frame2.Icon, entry, _isDiscovered)
			local uIStroke = frame2:FindFirstChildOfClass("UIStroke")

			if uIStroke ~= nil then
				local v15 = _isDiscovered and not _isClaimed
				local color5

				if v14 then
					color5 = color2
				elseif v15 then
					color5 = color
				else
					color5 = Color3.fromRGB(0, 0, 0)
				end

				uIStroke.Color = color5
			end
		end

		function class:_renderSlots()
			local v14 = self._sectionsByPage[self._currentPage]
			self:_ensureSectionPool(#v14)

			for i, _section in ipairs(self._sections) do
				local section2 = v14[i]
				_section.Section = section2

				if section2 == nil then
					_section.Frame.Visible = false

					for _, slot in ipairs(_section.Slots) do
						self:_renderSlot(slot, nil)
					end
				else
					_section.Frame.Visible = true
					_section.Frame.Name = section2.SectionId
					_section.Frame.LayoutOrder = i
					_section.Frame.BgFrame.TextLabel.Text = section2.DisplayName
					_section.Frame.BgFrame.Image = section2.Icon
					_section.Frame.BgFrame.ScaleType = Enum.ScaleType.Crop
					local count = 0

					for _, entry in section2.Entries do
						if self:_isDiscovered(entry) then
							count += 1
						end
					end

					local _getSave = self:_getSave()
					local v16

					if _getSave == nil then
						v16 = false
					else
						v16 = (_getSave.GearInventory[section2.RewardGearId] or 0) > 0
					end

					if section2.RewardKind == "AreaBat" then
						local v17

						if _getSave == nil then
							v17 = false
						else
							v17 = _getSave.VisitedGears[section2.RewardGearId] == true
						end

						_section.ProgressComponent:RenderAreaBat(
							section2.SectionId,
							section2.RewardGearId,
							count,
							#section2.Entries,
							v17,
							v16
						)
					elseif section2.RewardKind == "Collection" then
						_section.ProgressComponent:RenderCollection(
							section2.SectionId,
							section2.RewardIcon or "",
							count,
							#section2.Entries
						)
					else
						_section.ProgressComponent:RenderGearClaim(
							section2.SectionId,
							section2.RewardGearId,
							count,
							#section2.Entries,
							v16
						)
					end

					self:_sizeSection(_section.Frame, #section2.Entries)
					self:_ensureSlotPool(_section, section2)

					for i2, slot in ipairs(_section.Slots) do
						self:_renderSlot(slot, section2.Entries[i2])
					end
				end
			end
		end

		function class:_selectEntry(selectedCategory: string)
			self._selectedCategory = selectedCategory
			self:_renderSlots()
			self:_renderInfo()
			self:_renderRewards()
		end

		function class:_selectDefaultEntry()
			if self:_getEntryByCategory(self._selectedCategory) ~= nil then
				return
			end

			for _, v14 in ipairs(self._sectionsByPage[self._currentPage]) do
				local entry = v14.Entries[1]

				if entry == nil then
					continue
				end

				self._selectedCategory = entry.Category
				break
			end
		end

		function class:_renderInfo()
			local _getEntryByCategory = self:_getEntryByCategory(self._selectedCategory)

			if _getEntryByCategory == nil then
				return
			end

			local _isDiscovered = self:_isDiscovered(_getEntryByCategory)
			self:_renderEntryIcon(icon, _getEntryByCategory, _isDiscovered)
			petRarity.Text = _getEntryByCategory.Config.Rarity._id
			local uIGradient = petOdds:FindFirstChildOfClass("UIGradient")

			if uIGradient then
				uIGradient:Destroy()
			end

			if _getEntryByCategory.Config.Rarity.RarityGradient then
				viewing.BackgroundColor3 = _getEntryByCategory.Config.Rarity.Color
				viewing.UIStroke.Color = _getEntryByCategory.Config.Rarity.Color:Lerp(Color3.new(0, 0, 0), 0.5)
			end

			AssetOddsDisplay.DescribeItem(_getEntryByCategory.Config, _getEntryByCategory.ItemData, false)

			if _isDiscovered then
				petName.Text = self:_getEntryDisplayName(_getEntryByCategory)
				petOdds.Text = `${Simple.FormatCompact(AssetItems.IndexMoneyReward(_getEntryByCategory.Category) / 100, ".#")}/s`
			else
				petName.Text = "???"
				petOdds.Text = "???"
			end
		end

		function class:_renderRewards()
			local _getEntryByCategory = self:_getEntryByCategory(self._selectedCategory)
			local v14

			if _getEntryByCategory == nil then
				v14 = false
			else
				v14 = self:_isClaimed(_getEntryByCategory)
			end

			local v15

			if _getEntryByCategory == nil then
				v15 = false
			else
				v15 = self:_isClaimable(_getEntryByCategory)
			end

			ClaimRewardPanel.Render(rewards, _getEntryByCategory, v14, v15)
		end

		function class:_countUnclaimedByPage(p: string)
			local count = 0

			for _, v14 in ipairs(self._sectionsByPage[p]) do
				for _, entry in ipairs(v14.Entries) do
					if self:_isClaimable(entry) then
						count += 1
					end
				end
			end

			return count
		end

		function class:_countDiscoveredByPage(p: string)
			local count = 0

			for _, v14 in ipairs(self._sectionsByPage[p]) do
				for _, entry in ipairs(v14.Entries) do
					if self:_isDiscovered(entry) then
						count += 1
					end
				end
			end

			return count
		end

		function class:_countEntriesByPage(p2: string)
			local total = 0

			for _, v14 in ipairs(self._sectionsByPage[p2]) do
				total += #v14.Entries
			end

			return total
		end

		function class:_startBadgePulse()
			if #self._badgePulseTweens > 0 then
				return
			end

			for _, guiObject in ipairs(every2) do
				if not guiObject:IsA("GuiObject") then
					continue
				end

				local uIScale = EnsureUIScale(guiObject)
				uIScale.Scale = 0.8
				local tween = TweenService:Create(uIScale, tweenInfo2, {
					Scale = 1.2
				})
				table.insert(self._badgePulseTweens, tween)
				tween:Play()
			end
		end

		function class:_stopBadgePulse()
			if #self._badgePulseTweens == 0 then
				return
			end

			for _, _badgePulseTween in ipairs(self._badgePulseTweens) do
				_badgePulseTween:Cancel()
				_badgePulseTween:Destroy()
			end

			table.clear(self._badgePulseTweens)

			for _, guiObject in ipairs(every2) do
				if not guiObject:IsA("GuiObject") then
					continue
				end

				local ensureUIScale = EnsureUIScale(guiObject)
				ensureUIScale.Scale = 1
			end
		end

		function class:_renderNotificationBadges(p: number)
			for _, v14 in ipairs(every2) do
				renderNotificationBadge(v14, p)
			end

			renderNotificationBadge(notificationBadge, p)

			if p > 0 then
				self:_startBadgePulse()
			else
				self:_stopBadgePulse()
			end
		end

		function class:_renderProgress()
			local _countEntriesByPage = self:_countEntriesByPage(self._currentPage)
			local _countDiscoveredByPage = self:_countDiscoveredByPage(self._currentPage)
			local total = 0

			for _, v14 in ipairs(v) do
				total += self:_countUnclaimedByPage(v14)
			end

			self._claimAllArmed = total > 0
			self:_renderNotificationBadges(total)

			if claimAll == nil then
				unlocked.Visible = true
				unlocked.Active = self._claimAllArmed

				if self._claimAllArmed then
					textLabel.Text = `CLAIM ALL ({total})!`
					TweenService:Create(fill, tweenInfo, {
						Size = UDim2.fromScale(1, 1)
					}):Play()
					return
				end
			else
				claimAll.Visible = self._claimAllArmed
				unlocked.Visible = not self._claimAllArmed
				unlocked.Active = false
			end

			textLabel.Text = `Unlocked: {_countDiscoveredByPage}/{_countEntriesByPage}`
			local v14 = _countEntriesByPage == 0 and 0 or math.clamp(_countDiscoveredByPage / _countEntriesByPage, 0, 1)
			TweenService:Create(fill, tweenInfo, {
				Size = UDim2.fromScale(v14, 1)
			}):Play()
		end

		function class:_renderTabs()
			for k, v14 in v4 do
				local v15 = k == self._currentPage
				local button = v14.Button
				local backgroundColor

				if v15 then
					backgroundColor = v14.Tint
				else
					backgroundColor = color4
				end

				TweenService:Create(button, tweenInfo3, {
					BackgroundColor3 = backgroundColor
				}):Play()

				if v14.Stroke ~= nil then
					TweenService:Create(v14.Stroke, tweenInfo3, {
						Transparency = not v15 and 1 or v14.StrokeTransparency
					}):Play()
				end

				if v14.Label ~= nil then
					TweenService:Create(v14.Label, tweenInfo3, {
						TextTransparency = not v15 and 0.3 or v14.TextTransparency
					}):Play()
				end

				if v14.Icon ~= nil then
					TweenService:Create(v14.Icon, tweenInfo3, {
						ImageTransparency = not v15 and 0.8 or v14.IconTransparency
					}):Play()
				end
			end
		end

		function class:_selectPage(currentPage: string)
			if self._currentPage == currentPage or self._sectionsByPage[currentPage] == nil then
				return
			end

			self._currentPage = currentPage
			self._selectedCategory = nil
			scrollingFrame.CanvasPosition = Vector2.zero
			self:_render()
		end

		function class:_render()
			if self._builtLive ~= updateLive() or self._builtLaboratory ~= RiftMachineSchedule.IsLaboratoryTime() then
				self:_buildEntries()
				self._selectedCategory = nil
			end

			if not self._isOpen then
				self:_renderProgress()
				return
			end

			self:_renderTabs()
			self:_selectDefaultEntry()
			self:_renderSlots()
			self:_renderInfo()
			self:_renderRewards()
			self:_renderProgress()
		end

		function class:_open()
			if self._isOpen then
				return
			end

			self._isOpen = true
			self._currentPage = "World"
			self._selectedCategory = nil
			self._openTrove = Trove.new()
			self:_buildEntries()
			self:_render()
		end

		function class:_close()
			self._isOpen = false
			self._currentPage = "World"
			self._selectedCategory = nil

			if self._openTrove ~= nil then
				self._openTrove:Destroy()
				self._openTrove = nil
			end

			table.clear(self._sections)
			self:_render()
		end

		function class:_processClaimResults(list)
			if list == nil then
				return
			end

			for _, v14 in ipairs(list) do
				local v15 = v14
				Save.Amend("IndexClaimedCategories", function(p)
					p[v15.Category] = true
				end)
			end
		end

		function class:_claimSelected()
			local _getEntryByCategory = self:_getEntryByCategory(self._selectedCategory)

			if _getEntryByCategory == nil or not self:_isClaimable(_getEntryByCategory) then
				return
			end

			local v14, v15, v16 = Remotes.Codex.AskRedeem:InvokeServer(_getEntryByCategory.Category)

			if not v14 then
				v2:AtWarning():Log((`[Index] Claim failed: {v15}`))
				return
			end

			self:_processClaimResults(v16)
			self:Refresh()
		end

		function class:_claimAll()
			local v14, v15, v16 = Remotes.Codex.AskRedeemAll:InvokeServer()

			if not v14 then
				v2:AtWarning():Log((`[Index] Claim all failed: {v15}`))
				return
			end

			self:_processClaimResults(v16)
			self:Refresh()
		end

		function class:_equipAreaBat(p: string)
			local v14, v15 = Remotes.Codex.AskWearFieldBat:InvokeServer(p)

			if v14 then
				self:Refresh()
			else
				v2:AtWarning():Log((`[Index] Equip area bat failed: {v15}`))
			end
		end

		function class:_claimLimitedEggReward(p: string)
			local v14, v15 = Remotes.Codex.AskRedeemLimitedEgg:InvokeServer(p)

			if v14 then
				self:Refresh()
			else
				v2:AtWarning():Log((`[Index] Limited Egg reward claim failed: {v15}`))
			end
		end

		function class:Refresh()
			self:_render()
		end

		function class:_init()
			section.Visible = false

			for _, v14 in images do
				v14.Visible = false
			end

			for _, v14 in every do
				self._trove:Add(ButtonFX(v14, 1.08, function()
					Tabs.Toggle("Index")
				end))
			end

			for k, v14 in v4 do
				local v15 = k
				self._trove:Add(ButtonFX(v14.Button, 1.06, function()
					self:_selectPage(v15)
				end))
			end

			self._trove:Add(ButtonFX(claim, nil, function()
				tryLock(function()
					self:_claimSelected()
				end)
			end))

			local function fn()
				if self._claimAllArmed then
					tryLock(function()
						self:_claimAll()
					end)
				end
			end

			self._trove:Add(SurfaceButton(unlocked, 1.04, fn))

			if claimAll ~= nil then
				local _trove = self._trove
				local v14

				if claimAll:IsA("GuiButton") then
					v14 = ButtonFX(claimAll, 1.04, fn)
				else
					v14 = SurfaceButton(claimAll, 1.04, fn)
				end

				_trove:Add(v14)
			end

			self._trove:Add(Save.WatchFields({
				"Index",
				"IndexClaimedCategories",
				"VisitedGears",
				"GearInventory"
			}, function()
				self:Refresh()
			end))
			self._trove:Connect(Tabs.Activated, function(p: string)
				if p == "Index" then
					self:_open()
				end
			end)
			self._trove:Connect(Tabs.Deactivated, function(p: string)
				if p == "Index" then
					self:_close()
				end
			end)
			self:_render()
		end

		return class._build()
	end
}