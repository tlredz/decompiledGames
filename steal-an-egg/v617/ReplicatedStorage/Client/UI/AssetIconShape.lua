local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage.Data.Assets)
local AssetItem = require(ReplicatedStorage.Shared.Types.AssetItem)
local Assets = require(ReplicatedStorage.Data.Assets)
local Mutations = require(ReplicatedStorage.Shared.Modules.Mutations)
local Rarity = require(ReplicatedStorage.Data.Rarity)
local Trove = require(ReplicatedStorage.Packages.Trove)
local t = require(ReplicatedStorage.Packages.t)
local uDim = UDim2.fromScale(0.5, 0.5)
local vector = Vector2.new(0.5, 0.5)
local uDim2 = UDim2.fromScale(1, 1)
local uDim3 = UDim2.fromScale(0.77, 0.77)
local uDim4 = UDim2.fromScale(0.85, 0.85)
local uDim5 = UDim2.fromScale(0, 0)
local color = Color3.fromRGB(0, 0, 0)
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.6, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
local strict = t.strict(t.instanceIsA("ImageLabel"))
local strict2 = t.strict(t.string)
local strict3 = t.strict(t.Color3)
local strict4 = t.strict(t.number)
local strict5 = t.strict(t.instanceIsA("GuiObject"))
local strict6 = t.strict(t.optional(t.callback))
local AssetIconShape = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function carries(p, p2: string)
	return p.BaseMutation == p2 or table.find(p.Mutations, p2) ~= nil
end

local function zoomFor(_)
	return 1, nil
end

local function iconFor(p, p2)
	local mutationIcons = p.MutationIcons

	if mutationIcons == nil then
		return p.Icon or ""
	end

	local ids = Mutations.Ids()

	for _, v in { ids.Golden, ids.Silver } do
		if carries(p2, v) and mutationIcons[v] ~= nil then
			return mutationIcons[v]
		end
	end

	return p.Icon or ""
end

local function imagesFor(p, p2)
	local icon = iconFor(p, p2)
	local rainbowOverlay

	if carries(p2, Mutations.Ids().Rainbow) then
		rainbowOverlay = p.WhiteImage or icon
	end

	return {
		Icon = icon,
		RainbowOverlay = rainbowOverlay
	}
end

local function stretchBy(udim: UDim2, p: number, p2: number)
	return UDim2.new(udim.X.Scale * p, udim.X.Offset * p, udim.Y.Scale * p2, udim.Y.Offset * p2)
end

local function makeCanvas(name: string, size: UDim2, zIndex: number, parent)
	local canvasGroup = Instance.new("CanvasGroup")
	canvasGroup.Name = name
	canvasGroup.Size = size
	canvasGroup.Position = uDim
	canvasGroup.AnchorPoint = vector
	canvasGroup.BackgroundTransparency = 1
	canvasGroup.ClipsDescendants = true
	canvasGroup.ZIndex = zIndex
	canvasGroup.Parent = parent
	return canvasGroup
end

local function makeZoomedImage(name: string, image: string, p: number, udim: UDim2, zIndex: number)
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = name
	imageLabel.Image = image
	imageLabel.Size = UDim2.fromScale(p, p)
	imageLabel.Position = uDim + udim
	imageLabel.AnchorPoint = vector
	imageLabel.BackgroundTransparency = 1
	imageLabel.ScaleType = Enum.ScaleType.Fit
	imageLabel.ZIndex = zIndex
	return imageLabel
end

function AssetIconShape.OverlayRainbow(parent, image: string)
	strict(parent)
	strict2(image)
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "RainbowOverlayImage"
	imageLabel.Image = image
	imageLabel.ImageTransparency = 0.5
	imageLabel.Size = uDim2
	imageLabel.Position = uDim
	imageLabel.AnchorPoint = vector
	imageLabel.BackgroundTransparency = 1
	imageLabel.ScaleType = Enum.ScaleType.Fit
	imageLabel.ZIndex = parent.ZIndex + 1
	imageLabel.Parent = parent
	local clone = Rarity.Rarities.Rainbow.RarityGradient:Clone()
	clone.Parent = imageLabel
	return imageLabel
end

function AssetIconShape:Strip()
	strict(self)
	local rainbowOverlayImage = self:FindFirstChild("RainbowOverlayImage")

	if rainbowOverlayImage and rainbowOverlayImage:IsA("ImageLabel") then
		rainbowOverlayImage:Destroy()
	end

	local assetIconShapeLayer = self:FindFirstChild("AssetIconShapeLayer")

	if assetIconShapeLayer ~= nil then
		assetIconShapeLayer:Destroy()
	end

	self.ImageTransparency = 0
end

function AssetIconShape:Tint(imageColor: Color3, imageTransparency: number)
	strict(self)
	strict3(imageColor)
	strict4(imageTransparency)
	self.ImageColor3 = imageColor
	self.ImageTransparency = imageTransparency
	local assetIconShapeLayer = self:FindFirstChild("AssetIconShapeLayer")

	if assetIconShapeLayer == nil then
		return
	end

	local imageColor2

	if imageColor == color then
		imageColor2 = imageColor
	else
		imageColor2 = color
	end

	for _, image in assetIconShapeLayer:GetDescendants() do
		if not image:IsA("ImageLabel") then
			continue
		end

		image.ImageTransparency = imageTransparency
		local imageColor3

		if image.Name == "IconStrokeImage" then
			imageColor3 = imageColor2
		else
			imageColor3 = imageColor
		end

		image.ImageColor3 = imageColor3
	end
end

function AssetIconShape.ResolveImages(p)
	assert(AssetItem.AssetItemData(p))
	local v = Assets.Directory[p.Category]
	assert(v ~= nil, (`no asset directory entry for category {p.Category}`))
	return (imagesFor(v, p))
end

function AssetIconShape:Paint(p)
	strict(self)
	assert(AssetItem.AssetItemData(p))
	local v = Assets.Directory[p.Category]
	assert(v ~= nil, (`no asset directory entry for category {p.Category}`))
	local v2 = imagesFor(v, p)
	local icon = v2.Icon
	local v3 = 1
	local v4 = nil or uDim5
	assert(v4, "the icon zoom offset fell through its own default")
	AssetIconShape.Strip(self)
	self.BackgroundTransparency = 1
	self.ScaleType = Enum.ScaleType.Fit

	if v3 <= 1 then
		self.Image = icon
		self.ImageTransparency = 0

		if v2.RainbowOverlay ~= nil then
			AssetIconShape.OverlayRainbow(self, v2.RainbowOverlay)
		end
	else
		self.Image = ""
		self.ImageTransparency = 1
		local frame = Instance.new("Frame")
		frame.Name = "AssetIconShapeLayer"
		frame.Size = uDim2
		frame.Position = uDim
		frame.AnchorPoint = vector
		frame.BackgroundTransparency = 1
		frame.ZIndex = self.ZIndex
		frame.Parent = self
		local zIndex = self.ZIndex
		local canvasGroup = Instance.new("CanvasGroup")
		canvasGroup.Name = "IconStrokeFrame"
		canvasGroup.Size = uDim4
		canvasGroup.Position = uDim
		canvasGroup.AnchorPoint = vector
		canvasGroup.BackgroundTransparency = 1
		canvasGroup.ClipsDescendants = true
		canvasGroup.ZIndex = zIndex
		canvasGroup.Parent = frame
		local zIndex2 = self.ZIndex
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Name = "IconStrokeImage"
		imageLabel.Image = icon
		imageLabel.Size = UDim2.fromScale(v3, v3)
		imageLabel.Position = uDim + v4
		imageLabel.AnchorPoint = vector
		imageLabel.BackgroundTransparency = 1
		imageLabel.ScaleType = Enum.ScaleType.Fit
		imageLabel.ZIndex = zIndex2
		imageLabel.ImageColor3 = color
		imageLabel.Parent = canvasGroup
		local zIndex3 = self.ZIndex + 1
		local canvasGroup2 = Instance.new("CanvasGroup")
		canvasGroup2.Name = "IconClipFrame"
		canvasGroup2.Size = uDim3
		canvasGroup2.Position = uDim
		canvasGroup2.AnchorPoint = vector
		canvasGroup2.BackgroundTransparency = 1
		canvasGroup2.ClipsDescendants = true
		canvasGroup2.ZIndex = zIndex3
		canvasGroup2.Parent = frame
		local zIndex4 = self.ZIndex + 1
		local imageLabel2 = Instance.new("ImageLabel")
		imageLabel2.Name = "IconImage"
		imageLabel2.Image = icon
		imageLabel2.Size = UDim2.fromScale(v3, v3)
		imageLabel2.Position = uDim + v4
		imageLabel2.AnchorPoint = vector
		imageLabel2.BackgroundTransparency = 1
		imageLabel2.ScaleType = Enum.ScaleType.Fit
		imageLabel2.ZIndex = zIndex4
		imageLabel2.Parent = canvasGroup2

		if v2.RainbowOverlay ~= nil then
			AssetIconShape.OverlayRainbow(imageLabel2, v2.RainbowOverlay)
		end
	end
end

function AssetIconShape.WireHoverSquash(data, folder, callback)
	strict5(data)
	strict(folder)
	strict6(callback)
	local size = folder.Size
	local v = Trove.new()
	local v2 = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function drop()
		local v3 = v2

		if v3 then
			v3:Cancel()
			v3:Destroy()
			v2 = nil
		end
	end

	local function applyScaleType(scaleType)
		folder.ScaleType = scaleType

		for _, image in folder:GetDescendants() do
			if image:IsA("ImageLabel") then
				image.ScaleType = scaleType
			end
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function snapTo(udim: UDim2?)
		drop() -- equivalent call inferred; original call site unknown

		if not folder then
			return
		end

		local size2 = udim or size

		if size2 then
			folder.Size = size2
		end

		applyScaleType(Enum.ScaleType.Fit)
	end

	local function relax(flag: boolean?)
		if folder and size then
			if flag == false then
				snapTo(size) -- equivalent call inferred; original call site unknown
			else
				drop() -- equivalent call inferred; original call site unknown
				local tween = TweenService:Create(folder, tweenInfo2, {
					Size = size
				})
				v2 = tween
				tween.Completed:Once(function(p)
					if p == Enum.PlaybackState.Cancelled then
						return
					end

					applyScaleType(Enum.ScaleType.Fit)
					v2 = nil
				end)
				tween:Play()
			end
		else
			snapTo() -- equivalent call inferred; original call site unknown
		end
	end

	local function squash()
		if not folder or callback and not callback() then
			return
		end

		drop() -- equivalent call inferred; original call site unknown
		applyScaleType(Enum.ScaleType.Stretch)
		local size2 = size
		local v8 = TweenService:Create(folder, tweenInfo, {
			Size = UDim2.new(size2.X.Scale * 1.2, size2.X.Offset * 1.2, size2.Y.Scale * 0.43, size2.Y.Offset * 0.43)
		})
		v2 = v8
		v8:Play()
	end

	v:Add(drop)
	v:Connect(data.MouseEnter, squash)
	v:Connect(data.MouseLeave, relax)
	v:Connect(data.InputEnded, function(p)
		if p.UserInputType == Enum.UserInputType.MouseButton1 or p.UserInputType == Enum.UserInputType.Touch then
			relax()
		end
	end)
	return v, relax
end

return AssetIconShape