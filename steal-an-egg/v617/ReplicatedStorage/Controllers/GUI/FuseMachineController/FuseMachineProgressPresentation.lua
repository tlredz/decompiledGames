local ReplicatedStorage = game:GetService("ReplicatedStorage")
local fusion = require(ReplicatedStorage.Shared.Flags.GameplayBalance).Fusion
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local t = require(ReplicatedStorage2.Packages.t)
require(ReplicatedStorage2.Shared.Types.FuseMachine)
local Log = require(ReplicatedStorage2.Packages.Log)
local Trove = require(ReplicatedStorage2.Packages.Trove)
local v = Log.new()
local FuseMachineProgressPresentation = {}
FuseMachineProgressPresentation.__index = FuseMachineProgressPresentation
FuseMachineProgressPresentation.__class = "FuseMachineProgressPresentation"
local v2 = { "LeftBar", "MiddleBar", "RightBar" }
local color = Color3.new(1, 1, 1)
local color2 = Color3.new(0, 0, 0)
local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo3 = TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)

function FuseMachineProgressPresentation.new(p, instance)
	t.strict(t.instanceIsA("Frame"))(p)
	t.strict(t.instanceIsA("Frame"))(instance)
	local object = setmetatable({}, FuseMachineProgressPresentation)
	object._barFills = {}
	object._barFilled = {}
	object._barLitTransparencies = {}
	object._barOriginalVisible = {}
	object._barTroves = {}
	object._barTweenInfo = TweenInfo.new(
		instance:GetAttribute("FillFadeSeconds") or 0.25,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out
	)

	for i, childName in ipairs(v2) do
		local child = instance:FindFirstChild(childName)
		assert(child ~= nil, (`PetFuse.FuseMain.DesignBars.{childName} is missing`))
		local fill = child:FindFirstChild("Fill")
		local v3

		if fill == nil then
			v3 = false
		else
			v3 = fill:IsA("ImageLabel")
		end

		assert(v3, (`PetFuse.FuseMain.DesignBars.{childName}.Fill must be an ImageLabel`))
		object._barFills[i] = fill
		object._barLitTransparencies[i] = fill.ImageTransparency
		object._barOriginalVisible[i] = fill.Visible
		object._barTroves[i] = Trove.new()
	end

	object._icon = p.OutputEgg
	t.strict(t.instanceIsA("ImageLabel"))(object._icon)
	object._iconOriginalBackgroundColor = object._icon.BackgroundColor3
	object._iconOriginalColor = object._icon.ImageColor3
	object._iconOriginalImage = object._icon.Image
	object._iconOriginalTransparency = object._icon.ImageTransparency
	object._iconScale = Instance.new("UIScale")
	object._iconScale.Name = "FuseProgressScale"
	object._iconScale.Parent = object._icon
	object._iconOriginalScale = object._iconScale.Scale
	object._iconTrove = Trove.new()
	object._outputFill = p.Fill
	t.strict(t.instanceIsA("Frame"))(object._outputFill)
	object._outputOriginalPosition = object._outputFill.Position
	object._outputOriginalSize = object._outputFill.Size
	object._outputAnchorY = object._outputFill.AnchorPoint.Y
	object._outputBottomScale = object._outputOriginalPosition.Y.Scale + (1 - object._outputAnchorY) * object._outputOriginalSize.Y.Scale
	object._outputBottomOffset = object._outputOriginalPosition.Y.Offset + (1 - object._outputAnchorY) * object._outputOriginalSize.Y.Offset
	object._outputTrove = Trove.new()
	object._selectedCount = nil
	object._trove = Trove.new()
	object._trove:Add(object._iconScale)
	object._trove:Add(object._iconTrove)
	object._trove:Add(object._outputTrove)

	for _, _barTrove in ipairs(object._barTroves) do
		object._trove:Add(_barTrove)
	end

	return object
end

function FuseMachineProgressPresentation:_setBarFilled(p: number, visible: boolean, flag: boolean)
	if self._barFilled[p] == visible then
		return
	end

	self._barFilled[p] = visible
	local _barTrove = self._barTroves[p]
	_barTrove:Clean()
	local _barFill = self._barFills[p]
	local imageTransparency = not visible and 1 or self._barLitTransparencies[p]

	if flag then
		if visible and not _barFill.Visible then
			_barFill.ImageTransparency = 1
			_barFill.Visible = true
		end

		local tween = TweenService:Create(_barFill, self._barTweenInfo, {
			ImageTransparency = imageTransparency
		})
		_barTrove:Add(function()
			tween:Cancel()
			tween:Destroy()
		end)
		_barTrove:Add(tween.Completed:Connect(function(p2)
			if p2 ~= Enum.PlaybackState.Completed then
				return
			end

			_barFill.Visible = self._barFilled[p]
		end))
		tween:Play()
	else
		_barFill.ImageTransparency = imageTransparency
		_barFill.Visible = visible
	end
end

function FuseMachineProgressPresentation:_setOutputProgress(p: number, flag: boolean)
	self._outputTrove:Clean()
	local v3 = math.min(p / fusion.INPUT_COUNT, 1)
	local uDim = UDim2.new(self._outputOriginalSize.X.Scale, self._outputOriginalSize.X.Offset, v3, 0)
	local uDim2 = UDim2.new(
		self._outputOriginalPosition.X.Scale,
		self._outputOriginalPosition.X.Offset,
		self._outputBottomScale - (1 - self._outputAnchorY) * v3,
		self._outputBottomOffset
	)

	if flag then
		local tween = TweenService:Create(self._outputFill, tweenInfo, {
			Position = uDim2,
			Size = uDim
		})
		self._outputTrove:Add(function()
			tween:Cancel()
			tween:Destroy()
		end)
		tween:Play()
	else
		self._outputFill.Size = uDim
		self._outputFill.Position = uDim2
	end
end

function FuseMachineProgressPresentation:_setIncompleteIcon()
	self._iconTrove:Clean()
	self._icon.ImageTransparency = 0.1
	self._icon.ImageColor3 = color2
	self._icon.BackgroundColor3 = color2
	self._iconScale.Scale = self._iconOriginalScale
end

function FuseMachineProgressPresentation:_setReadyIcon(flag: boolean)
	self._iconTrove:Clean()
	self._icon.ImageTransparency = 0
	self._icon.ImageColor3 = color
	self._icon.BackgroundColor3 = color
	self._iconScale.Scale = self._iconOriginalScale

	if not flag then
		return
	end

	self._iconScale.Scale = 0.8
	local tween = TweenService:Create(self._iconScale, tweenInfo2, {
		Scale = self._iconOriginalScale * 1.2
	})
	self._iconTrove:Add(function()
		tween:Cancel()
		tween:Destroy()
	end)
	self._iconTrove:Add(tween.Completed:Connect(function(p)
		if p ~= Enum.PlaybackState.Completed or self._selectedCount ~= fusion.INPUT_COUNT then
			return
		end

		local tween2 = TweenService:Create(self._iconScale, tweenInfo3, {
			Scale = self._iconOriginalScale
		})
		self._iconTrove:Add(function()
			tween2:Cancel()
			tween2:Destroy()
		end)
		tween2:Play()
	end))
	tween:Play()
end

function FuseMachineProgressPresentation:Update(list, image: string?)
	t.strict(t.array(t.boolean))(list)
	assert(#list == 3, "Fuse progress needs one flag per input slot")
	t.strict(t.optional(t.string))(image)
	local count = 0

	for _, v3 in ipairs(list) do
		if v3 then
			count += 1
		end
	end

	if count == 0 then
		self._icon.Image = self._iconOriginalImage
	else
		local v3

		if image == nil then
			v3 = false
		else
			v3 = image ~= ""
		end

		assert(v3, "Selected FuseMachine category requires an egg icon")
		self._icon.Image = image
	end

	local _selectedCount = self._selectedCount
	self:_setBarFilled(1, list[1], _selectedCount ~= nil)
	self:_setBarFilled(2, list[2], _selectedCount ~= nil)
	self:_setBarFilled(3, list[3], _selectedCount ~= nil)

	if _selectedCount == count then
		return
	end

	self._selectedCount = count

	if _selectedCount == nil then
		self:_setOutputProgress(count, false)

		if count == fusion.INPUT_COUNT then
			self:_setReadyIcon(false)
		else
			self:_setIncompleteIcon()
		end
	else
		self:_setOutputProgress(count, true)

		if count == fusion.INPUT_COUNT then
			self:_setReadyIcon(true)
		else
			self:_setIncompleteIcon()
		end
	end
end

function FuseMachineProgressPresentation:Destroy()
	self._trove:Destroy()

	for i, _barFill in ipairs(self._barFills) do
		_barFill.ImageTransparency = self._barLitTransparencies[i]
		_barFill.Visible = self._barOriginalVisible[i]
	end

	self._outputFill.Position = self._outputOriginalPosition
	self._outputFill.Size = self._outputOriginalSize
	self._icon.Image = self._iconOriginalImage
	self._icon.ImageTransparency = self._iconOriginalTransparency
	self._icon.ImageColor3 = self._iconOriginalColor
	self._icon.BackgroundColor3 = self._iconOriginalBackgroundColor
	v:AtTrace():Log("Destroyed FuseMachine progress presentation")
end

return FuseMachineProgressPresentation