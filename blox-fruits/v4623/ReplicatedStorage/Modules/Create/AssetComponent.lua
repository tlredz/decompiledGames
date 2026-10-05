game:GetService("ReplicatedStorage")
game:GetService("RunService")
local Mount = require(game.ReplicatedStorage.React.Components.FruitShop.FruitCard.Card.Profile.FruitTile.DragonAnimation.Mount)
local ImageUtil = require(game.ReplicatedStorage.Modules.Asset.ImageUtil)
local RarityUtil = require(game.ReplicatedStorage.Modules.Asset.RarityUtil)
local ChromaticSprites = require(game.ReplicatedStorage.Modules.SpriteSheets.ChromaticSprites)
local RaritySprites = require(script.RaritySprites)
local AccessoriesShared = require(game.ReplicatedStorage.AccessoriesShared)
local ModifierStatsImageComponent = require(game.ReplicatedStorage.Modules.Create.ModifierStatsImageComponent)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local LoggerBuilder = require(game.ReplicatedStorage.Util.LoggerBuilder)
local v = LoggerBuilder.new():tag("UI"):display():traceback():build()
local numberRange = NumberRange.new(2, 3)
local BACKGROUND_RECT_SIZE = RaritySprites.BACKGROUND_RECT_SIZE
local backgrounds = RaritySprites.Backgrounds
local random = Random.new()
local count = 0
local now = 1
local v2 = {}
local v3 = {
	Fruit = {
		DisplayName = "Blox Fruit"
	},
	FruitSkin = {
		DisplayName = "Skin"
	},
	AuraSkin = {
		DisplayName = "Skin"
	},
	Potion = {
		DisplayName = "Potion"
	}
}
local heartbeatConnection = nil

local function log(...) end

local function wlog(...) end

local function startShineThread()
	local integer = random:NextInteger(numberRange.Min, numberRange.Max)

	if not heartbeatConnection and next(v2) then
		local count2 = 0
		local RunService = game:GetService("RunService")
		heartbeatConnection = RunService.Heartbeat:Connect(function(_)
			if tick() - now < integer then
				return
			end

			debug.profilebegin("AssetComponent/Shine")
			now = tick()
			integer = random:NextInteger(numberRange.Min, numberRange.Max)
			local count3 = 0
			local _UIDs = {}

			for _, v4 in pairs(v2) do
				if v4._Rbx.instance.Parent then
					if not v4._Destroyed and v4._Rbx.Shine then
						if v4._Rbx.instance.Visible and v4._Rbx.Filled.Visible then
							local v5 = assert(RarityUtil.tryGetRarity("Premium"))

							if v4._AssetInfo and v4._AssetInfo.Rarity and v4._AssetInfo.Rarity == v5.Value and v4._AutoShineEnabled then
								count3 += 1

								if not v4._ShineTween then
									table.insert(_UIDs, v4._UID)
								end
							end
						else
							print("not shining, tile not visible")
						end
					end
				else
					warn("TILE HAS NO PARENT, did you forget to destroy the component?")
					v4:Destroy()
				end
			end

			if #_UIDs > 0 then
				wlog("Num Shine Options", #_UIDs)
				local count4 = 0

				for _ = 1, #_UIDs do
					local v4 = _UIDs[random:NextInteger(1, #_UIDs)]
					local v5 = v2[v4]

					if v5 then
						if v5._ShineRNG:NextNumber() <= v5._ShineOdds then
							v5._ShineOdds = 0
							table.remove(_UIDs, table.find(_UIDs, v4))
							v5:Shine(true)
							count4 += 1
						else
							v5._ShineOdds = math.clamp(v5._ShineOdds + 0.1, 0, 1)
						end
					end

					if count4 == 2 then
						break
					end
				end
			elseif heartbeatConnection and count3 == 0 then
				if count2 >= 2 then
					log("No shinies, disconnecting ShinebeatConnection.")
					heartbeatConnection:Disconnect()
					heartbeatConnection = nil
				else
					count2 += 1
					log("DisconnectWaitFrames", count2)
				end
			end

			debug.profileend()
		end)
	end
end

local function cleanupIconComponents(object, list)
	if object.FruitIcon and (list == nil or not table.find(list, "FruitIcon")) then
		object.FruitIcon()
		object.FruitIcon = nil
	end

	if object.ModifierIcon and (list == nil or not table.find(list, "ModifierIcon")) then
		object.ModifierIcon.Destroy()
		object.ModifierIcon = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function disconnectHover(object)
	if object._MouseEnter then
		object._MouseEnter:Disconnect()
		object._MouseEnter = nil
	end

	if object._MouseLeave then
		object._MouseLeave:Disconnect()
		object._MouseLeave = nil
	end

	object._Hovering = false
	object:_UpdateBackground()
end

local function connectHover(object)
	local _Rbx = object._Rbx

	if _Rbx.TextButton then
		if not object._MouseEnter then
			object._MouseEnter = _Rbx.TextButton.MouseEnter:Connect(function()
				object._Hovering = true
				object:_UpdateBackground()
			end)
		end

		if not object._MouseLeave then
			object._MouseLeave = _Rbx.TextButton.MouseLeave:Connect(function()
				object._Hovering = false
				object:_UpdateBackground()
			end)
		end
	end
end

local class = {}
class.__index = class

function class:Destroy(p)
	if self._Destroyed then
		return
	end

	log((`Destroyed:{self._Rbx.instance:GetFullName()}`))
	self._Destroyed = true
	self._AssetInfo = nil
	self:EnableHoverHighlight(false)
	self:EnableAutoShine(false)

	if self.FruitIcon then
		self.FruitIcon()
		self.FruitIcon = nil
	end

	if self.ModifierIcon then
		self.ModifierIcon.Destroy()
		self.ModifierIcon = nil
	end

	if p then
		pcall(function(...)
			if self._Rbx.instance and self._Rbx.instance.Parent then
				self._Rbx.instance:Destroy()
			end
		end)
	end

	for _, v4 in pairs(self._Rbx) do
		if typeof(v4) == "table" then
			table.clear(v4)
		end
	end

	table.clear(self._Rbx)
end

function class:Shine(flag: boolean)
	if flag then
		if self._ShineTween then
			warn("Already shining")
			return
		end

		local vector = Vector2.new(0, -1.2)
		local vector2 = Vector2.new(0, 1.2)
		local shine = self._Rbx.Shine
		local v4 = assert(
			assert(shine, "Tile doesn't have Filled.Shine"):FindFirstChildOfClass("UIGradient"),
			"Tile doesn't have Filled.Shine.UIGradient"
		)
		shine.Visible = false
		v4.Offset = vector
		shine.Visible = true
		local TweenService = game:GetService("TweenService")
		local tween = TweenService:Create(v4, TweenInfo.new(0.4), {
			Offset = vector2
		})
		tween:Play()
		self._ShineTween = tween
		tween.Completed:Connect(function()
			shine.Visible = false
			v4.Offset = vector
			shine.Visible = true
			self._ShineTween = nil
		end)
	elseif self._ShineTween then
		self._ShineTween:Cancel()
		self._ShineTween = nil
	end
end

function class:UpdateAsset(state, ...)
	if self._Destroyed then
		print("AssetTile Destroyed", debug.traceback())
		return false
	end

	local _AssetInfo = self._AssetInfo
	local v4 = false

	if state then
		if state.ItemId == nil then
			v.fatal(function()
				return "assetInfoInput missing itemId", state
			end)
			local first = ItemConfig.Query.selectFirst({
				Index = {
					StorageKey = state.StorageName
				}
			})

			if first:isOk() then
				state.ItemId = first:unwrap().Index.ItemId
				print((`assetInfoInput.ItemId={state.ItemId}`))
			elseif state.Type then
				print("did not find itemId for", state.StorageName, state.Type)
			else
				warn((`missing item-id for assetInfoInput={state.StorageName}`))
			end
		end

		debug.profilebegin("AssetComponent/Update")
		local type = state.Type

		if type then
			assert(typeof(type) == "string")

			if type == "FruitSkin" and state.StorageName then
				local nullable = ItemConfig.match(state.StorageName, "Skin"):asNullable()
				type = nullable and nullable.Quality.Rarity == "Premium" and "Chromatic" or "FruitSkin"
			end
		end

		local storageName = state.StorageName

		if storageName then
			assert(typeof(storageName) == "string")
		end

		local rarity = state.Rarity

		if rarity then
			assert(typeof(rarity) == "number")
		end

		local displayName = state.DisplayName
		local itemId = state.ItemId

		if displayName == nil and storageName then
			local v5

			if itemId then
				v5 = ItemConfig.match(itemId):asNullable()
			else
				v5 = ItemConfig.Query.selectOne({
					Index = {
						StorageKey = storageName
					}
				}):asNullable()
			end

			if v5 then
				displayName = v5.Display.Name or v5.Index.StorageKey
			else
				displayName = storageName
			end
		end

		if displayName then
			assert(typeof(displayName) == "string")
		end

		local image = state.Image

		if itemId then
			image = ImageUtil.getImageFromItemId(itemId)
		elseif image == nil then
			image = ImageUtil.getAssetSprite(storageName)
		elseif typeof(image) == "number" then
			image = ImageUtil.getAssetSprite(image)
		end

		local imageBottomLeft = state.ImageBottomLeft

		if imageBottomLeft == nil and storageName and itemId then
			local v5 = itemId and ItemConfig.match(itemId):asNullable()

			if v5 then
				if v5.Index.IdType == "Skin" then
					local v6
					v6, imageBottomLeft = ChromaticSprites.Try(storageName)
				elseif rarity == 5 and v5.Display.CornerIcon then
					imageBottomLeft = ImageUtil.getImageFromSprite(v5.Display.CornerIcon, nil)
				end
			end
		end

		if image then
			assert(typeof(image) == "table")
		end

		if imageBottomLeft then
			assert(typeof(imageBottomLeft) == "table")
		end

		local count2 = state.Count

		if count2 then
			assert(typeof(count2) == "number")
		end

		local selected = state.Selected

		if selected ~= nil then
			assert(typeof(selected) == "boolean")
		end

		local equipped = state.Equipped

		if equipped ~= nil then
			assert(typeof(equipped) == "boolean")
		end

		local upgrades = state.Upgrades

		if upgrades then
			assert(typeof(upgrades) == "number")
		end

		local isNew = state.IsNew

		if isNew ~= nil then
			assert(typeof(isNew) == "boolean" or typeof(isNew) == "number")
		end

		local hidden = state.Hidden

		if hidden ~= nil then
			assert(typeof(hidden) == "boolean")
		end

		local isDimmed = state.IsDimmed

		if isDimmed ~= nil then
			assert(typeof(isDimmed) == "boolean")
		end

		if type and not v3[type] then
			v3[type] = {
				DisplayName = type
			}
		end

		local assetInfo = {
			StorageName = storageName,
			Rarity = rarity,
			Type = type,
			ItemId = itemId,
			Image = image,
			ImageBottomLeft = imageBottomLeft,
			DisplayName = displayName,
			Upgrades = upgrades,
			Selected = selected,
			Count = count2,
			Equipped = equipped,
			IsNew = isNew,
			Hidden = hidden,
			IsDimmed = isDimmed
		}
		self._AssetInfo = assetInfo
		debug.profileend()

		if assetInfo.Rarity and assetInfo.Rarity == 5 and self._AutoShineEnabled then
			v2[self._UID] = self
			startShineThread()
		else
			v2[self._UID] = nil
		end

		local icon = self._Rbx.Icon

		if icon then
			local v6 = {}

			if assetInfo.StorageName == "Permanent Dragon-Dragon" then
				table.insert(v6, "FruitIcon")

				if self.FruitIcon == nil then
					self.FruitIcon = Mount(icon, 0)
				end
			elseif AccessoriesShared.GetAllModifiers()[assetInfo.StorageName] then
				table.insert(v6, "ModifierIcon")

				if self.ModifierIcon == nil then
					self.ModifierIcon = ModifierStatsImageComponent()
				end
			end

			cleanupIconComponents(self, v6)
		else
			if self.FruitIcon then
				self.FruitIcon()
				self.FruitIcon = nil
			end

			if self.ModifierIcon then
				self.ModifierIcon.Destroy()
				self.ModifierIcon = nil
			end
		end

		return (self:_Render(...))
	else
		if not _AssetInfo then
			return false
		end

		v2[self._UID] = nil
		self._AssetInfo = nil

		if self.FruitIcon then
			self.FruitIcon()
			self.FruitIcon = nil
		end

		if self.ModifierIcon then
			self.ModifierIcon.Destroy()
			self.ModifierIcon = nil
		end

		if self._Rbx.DimOverlay then
			self._Rbx.DimOverlay.Visible = false
		end

		return (self:_Render(...))
	end
end

function class:EnableAutoShine(autoShineEnabled: boolean)
	self._AutoShineEnabled = autoShineEnabled

	if not self._AutoShineEnabled then
		local v4 = v2[self._UID]
		v2[self._UID] = nil

		if v4 then
			self:Shine(false)
		end
	end
end

function class:EnableHoverHighlight(flag: boolean)
	self._HoverHighlightEnabled = flag == true

	if self._HoverHighlightEnabled then
		connectHover(self)
		return
	end

	disconnectHover(self) -- equivalent call inferred; original call site unknown
end

function class:GetValue(p2: string)
	if self._AssetInfo then
		return self._AssetInfo[p2]
	end

	return nil
end

function class:IsSelected()
	if self._AssetInfo then
		return self._AssetInfo.Selected == true
	end

	return nil
end

function class:IsEquipped()
	if self._AssetInfo then
		return self._AssetInfo.Equipped == true
	end

	return nil
end

function class:IsNew()
	if self._AssetInfo then
		return self._AssetInfo.IsNew ~= nil
	end

	return nil
end

function class:_UpdateBackground()
	if self._AssetInfo then
		local _Rbx = self._Rbx

		if _Rbx.Background then
			local v4 = assert(RarityUtil.tryGetRarity(self._AssetInfo.Rarity or 0))
			local hover = self._Hovering and self._HoverHighlightEnabled and backgrounds[v4.Value].hover or backgrounds[v4.Value].idle
			local vector = Vector2.new(hover.X, hover.Y)
			_Rbx.Background.ImageRectOffset = vector
			_Rbx.Background.ImageRectSize = BACKGROUND_RECT_SIZE
		end
	end
end

function class:_Render(p)
	if not self._AssetInfo then
		return false
	end

	if self._Destroyed then
		print("AssetTile Destroyed", debug.traceback())
		return false
	end

	debug.profilebegin("AssetComponent/Render")
	local v4 = not self._AssetInfo and 0 or self._AssetInfo.Rarity or 0

	if self._ShineTween and self._AutoShineEnabled and (not self._AssetInfo or v4 < 5) then
		self:Shine(false)
	end

	self._RenderThread += 1
	local _RenderThread = self._RenderThread

	if p and p.PreRender then
		p.PreRender()
	end

	local v5 = false

	if _RenderThread == self._RenderThread then
		local _AssetInfo = self._AssetInfo

		if _AssetInfo then
			v5 = true
			local equipped = _AssetInfo.Equipped == true
			local visible = _AssetInfo.IsNew and true or false

			if self._Rbx.EquippedTag then
				self._Rbx.EquippedTag.Visible = equipped
			end

			if self._Rbx.NewTag then
				local newTag = self._Rbx.NewTag

				if equipped ~= false then
					visible = false
				end

				newTag.Visible = visible
			end

			if self._Rbx.SelectedImage then
				self._Rbx.SelectedImage.Visible = _AssetInfo.Selected == true
			end

			local v7 = assert(RarityUtil.tryGetRarity(v4), (`No rarity for {_AssetInfo.StorageName} from {v4}`))
			local value = v7.Value
			local color = v7.Color
			local v8 = value == 5
			local v9

			if v8 and _AssetInfo.Type then
				v9 = _AssetInfo.Type == "Fruit"
			else
				v9 = false
			end

			if v7.Outline == true and not _AssetInfo.Selected and self._Rbx.OutlineGlow then
				self._Rbx.OutlineGlow.ImageColor3 = color
				self._Rbx.OutlineGlow.Visible = true
			elseif self._Rbx.OutlineGlow then
				self._Rbx.OutlineGlow.Visible = false
			end

			if v8 then
				if self._Rbx.GodRays then
					self._Rbx.GodRays.ImageColor3 = Color3.fromRGB(255, 220, 130)
					self._Rbx.GodRays.Visible = true
				end
			elseif self._Rbx.GodRays then
				self._Rbx.GodRays.Visible = false
			end

			if self._Rbx.ItemName then
				local displayName = _AssetInfo.DisplayName or ""
				self._Rbx.ItemName.ItemName.Text = displayName
				self._Rbx.ItemName.TextLabel.Text = displayName
				self._Rbx.ItemName.ItemName.RichText = v9 == true
				self._Rbx.ItemName.TextLabel.RichText = self._Rbx.ItemName.ItemName.RichText
			end

			if v9 then
				if self._Rbx.ItemLine1 then
					self._Rbx.ItemLine1.ItemLine1.Visible = false
				end

				if self._Rbx.ItemLine2 then
					local itemLine2 = self._Rbx.ItemLine2.ItemLine2
					local textLabel = self._Rbx.ItemLine2.TextLabel
					itemLine2.Text = not _AssetInfo.Type and "" or v3[_AssetInfo.Type].DisplayName or ""
					textLabel.Text = itemLine2.Text
					itemLine2.Visible = true
				end

				if self._Rbx.RedBanner then
					self._Rbx.RedBanner.RedBanner.Visible = true
				end
			else
				if self._Rbx.RedBanner then
					self._Rbx.RedBanner.RedBanner.Visible = false
				end

				if self._Rbx.ItemLine1 then
					local itemLine1 = self._Rbx.ItemLine1.ItemLine1
					local textLabel = self._Rbx.ItemLine1.TextLabel
					itemLine1.Text = not _AssetInfo.Type and "" or v3[_AssetInfo.Type].DisplayName or ""
					textLabel.Text = itemLine1.Text
					itemLine1.Visible = itemLine1.Text ~= ""
				end

				if self._Rbx.ItemLine2 then
					local itemLine2 = self._Rbx.ItemLine2.ItemLine2
					local textLabel = self._Rbx.ItemLine2.TextLabel

					if _AssetInfo.Upgrades and _AssetInfo.Upgrades > 0 then
						itemLine2.Text = string.rep("★", _AssetInfo.Upgrades)
					else
						itemLine2.Text = ""
					end

					textLabel.Text = itemLine2.Text
					itemLine2.Visible = itemLine2.Text ~= ""
				end
			end

			if self._Rbx.Counter then
				if _AssetInfo.Count and _AssetInfo.Count > 0 then
					self._Rbx.Counter.Shadow.Text = tostring(_AssetInfo.Count)
					self._Rbx.Counter.TextLabel.Text = self._Rbx.Counter.Shadow.Text
				end

				local counter = self._Rbx.Counter.Counter
				counter.Visible = _AssetInfo.Count ~= nil and _AssetInfo.Count > 0
			end

			local icon = self._Rbx.Icon

			if icon then
				if self.FruitIcon or self.ModifierIcon then
					icon.Image = ""

					if self.ModifierIcon then
						self.ModifierIcon.Update(_AssetInfo.StorageName, icon)
					end
				else
					ImageUtil.applySprite(_AssetInfo.Image, self._Rbx.Filled, self._AssetInfo.Hidden == true)
				end
			end

			local iconOutline = self._Rbx.IconOutline

			if iconOutline and (self.FruitIcon or self.ModifierIcon) then
				iconOutline.Image = ""
			end

			local imageBottomLeft = self._Rbx.ImageBottomLeft

			if imageBottomLeft then
				if _AssetInfo.ImageBottomLeft then
					ImageUtil.applySprite(_AssetInfo.ImageBottomLeft, {
						Icon = imageBottomLeft
					}, self._AssetInfo.Hidden == true)
				end

				imageBottomLeft.Visible = _AssetInfo.ImageBottomLeft ~= nil
			end

			local dimOverlay = self._Rbx.DimOverlay

			if self._AssetInfo.IsDimmed then
				if not dimOverlay then
					local frame = Instance.new("Frame")
					frame.Name = "DimOverlay"
					frame.Size = UDim2.fromScale(1, 1)
					frame.BackgroundTransparency = 1
					frame.AnchorPoint = Vector2.new(0.5, 0.5)
					frame.Position = UDim2.fromScale(0.5, 0.48)
					frame.ZIndex = 3
					local imageLabel = Instance.new("ImageLabel")
					imageLabel.BackgroundTransparency = 1
					imageLabel.Size = UDim2.fromScale(1, 1.03)
					imageLabel.Image = "rbxassetid://120434692968914"
					imageLabel.ImageRectSize = Vector2.new(218, 225)
					imageLabel.ImageRectOffset = Vector2.new(218, 225)
					imageLabel.ImageTransparency = 0.4
					imageLabel.ZIndex = 3
					imageLabel.ImageColor3 = Color3.fromRGB(0, 0, 0)
					imageLabel.Parent = frame
					frame.Parent = self._Rbx.instance
					self._Rbx.DimOverlay = frame
				end

				local assert_2 = assert(self._Rbx.DimOverlay)
				assert_2.Visible = true
			elseif dimOverlay then
				dimOverlay.Visible = false
			end

			self:_UpdateBackground()
		end
	end

	if p and p.PostRender and _RenderThread == self._RenderThread then
		p.PostRender(v5)
	end

	debug.profileend()
	return v5
end

return function(instance)
	assert(instance, "No object provided")
	debug.profilebegin("AssetComponent/Init")
	count += 1
	local filled = assert(instance:FindFirstChild("Filled"), "Filled not a valid member of frame")
	local itemInformation = filled:FindFirstChild("ItemInformation")
	local rbx = {
		instance = instance,
		Filled = filled,
		TextButton = filled:FindFirstChildOfClass("TextButton"),
		Icon = filled:FindFirstChild("Icon"),
		ImageBottomLeft = filled:FindFirstChild("BottomLeft"),
		IconOutline = filled:FindFirstChild("IconOutline"),
		Background = filled:FindFirstChild("Background"),
		Shine = filled:FindFirstChild("Shine"),
		OutlineGlow = filled:FindFirstChild("OutlineGlow"),
		GodRays = filled:FindFirstChild("GodRays"),
		SelectedImage = filled:FindFirstChild("SelectedImg"),
		DimOverlay = instance:FindFirstChild("DimOverlay"),
		NewTag = itemInformation and itemInformation:FindFirstChild("NewTag"),
		EquippedTag = itemInformation and itemInformation:FindFirstChild("EquippedTag"),
		ItemName = itemInformation and itemInformation:FindFirstChild("ItemName") and ({
			ItemName = itemInformation.ItemName,
			TextLabel = itemInformation.ItemName.TextLabel
		} or nil) or nil,
		ItemLine1 = itemInformation and itemInformation:FindFirstChild("ItemLine1") and ({
			ItemLine1 = itemInformation.ItemLine1,
			TextLabel = itemInformation.ItemLine1.TextLabel
		} or nil) or nil,
		ItemLine2 = itemInformation and itemInformation:FindFirstChild("ItemLine2") and ({
			ItemLine2 = itemInformation.ItemLine2,
			TextLabel = itemInformation.ItemLine2.TextLabel
		} or nil) or nil,
		Counter = itemInformation and itemInformation:FindFirstChild("Counter") and ({
			Counter = itemInformation.Counter,
			Shadow = itemInformation.Counter.Shadow,
			TextLabel = itemInformation.Counter.Shadow.TextLabel
		} or nil) or nil,
		RedBanner = itemInformation and itemInformation:FindFirstChild("RedBanner") and {
			RedBanner = itemInformation.RedBanner,
			BannerText = itemInformation.RedBanner.BannerText,
			TextLabel = itemInformation.RedBanner.BannerText.TextLabel
		} or nil
	}
	debug.profileend()
	return (setmetatable({
		_UID = tostring(count),
		_AssetInfo = nil,
		_Destroyed = false,
		_RenderThread = 0,
		_MouseEnter = nil,
		_MouseLeave = nil,
		_Hovering = false,
		_HoverHighlightEnabled = false,
		_AutoShineEnabled = false,
		_ShineRNG = Random.new(math.random() * (10 * math.random())),
		_ShineOdds = 1,
		_Rbx = rbx
	}, class))
end