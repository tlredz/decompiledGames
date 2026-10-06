local TweenService = game:GetService("TweenService")
local WheelConfig = require(script.Parent.WheelConfig)
local WheelPreview = require(script.Parent.WheelPreview)
local WheelAnimator = {}
WheelAnimator.__index = WheelAnimator

local function collectSlots(sectorContainer)
	local result = {}

	for i = 1, WheelConfig.SlotCount do
		result[i] = sectorContainer:FindFirstChild("槽位" .. i)
	end

	return result
end

function WheelAnimator.new(p)
	local object = setmetatable({}, WheelAnimator)
	p["屏幕居中层"].Visible = true
	object.root = p["屏幕居中层"]["缩放偏移层"]["内容根"]
	object.scaleObj = object.root["缩放"]
	object.sectorContainer = object.root["扇区容器"]
	object.slots = collectSlots(object.sectorContainer)
	object.innerLayer = object.sectorContainer["内层"]
	object.titleLabel = object.innerLayer["标题文本"]
	object.highlighted = nil
	object.highlightChangedListeners = {}
	object.preview = WheelPreview.new(p)
	WheelConfig.onLoadoutChanged(function()
		object.preview:RefreshAll()
	end)
	object:ResetHidden()
	return object
end

function WheelAnimator:ResetHidden()
	self.highlighted = nil
	self.scaleObj.Scale = 0
	self.titleLabel.Text = WheelConfig.DefaultTitle

	for _, slot in ipairs(self.slots) do
		if slot then
			self:_setSelected(slot, false, true)
		end
	end
end

function WheelAnimator.Open(data)
	data.scaleObj.Scale = 0
	TweenService:Create(
		data.scaleObj,
		TweenInfo.new(WheelConfig.OpenDuration, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{
			Scale = 1
		}
	):Play()
	data.preview:Play()

	for i, slot in ipairs(data.slots) do
		if not slot then
			continue
		end

		local firstChild = slot:FindFirstChild("扇形底图")
		local firstChild2 = slot:FindFirstChild("键位标签")

		if firstChild then
			local imageTransparency = firstChild.ImageTransparency
			firstChild.ImageTransparency = 1
			local v = firstChild
			task.delay((i - 1) * WheelConfig.StaggerStep, function()
				TweenService:Create(
					v,
					TweenInfo.new(WheelConfig.HighlightDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						ImageTransparency = imageTransparency
					}
				):Play()
			end)
		end

		if not firstChild2 then
			continue
		end

		firstChild2.BackgroundTransparency = 1
		local v = firstChild2
		task.delay((i - 1) * WheelConfig.StaggerStep, function()
			TweenService:Create(
				v,
				TweenInfo.new(WheelConfig.HighlightDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					BackgroundTransparency = 0
				}
			):Play()
		end)
	end
end

function WheelAnimator:Close()
	self:SetHighlight(nil)
	self.preview:Stop()
	TweenService:Create(
		self.scaleObj,
		TweenInfo.new(WheelConfig.CloseDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{
			Scale = 0
		}
	):Play()
end

function WheelAnimator:SetHighlight(highlighted)
	if self.highlighted == highlighted then
		return
	end

	local v = self.highlighted and self.slots[self.highlighted]

	if v then
		self:_setSelected(v, false)
	end

	self.highlighted = highlighted

	for _, callback in ipairs(self.highlightChangedListeners) do
		task.spawn(callback, highlighted)
	end

	if not highlighted then
		self.titleLabel.Text = WheelConfig.DefaultTitle
		return
	end

	local slot = self.slots[highlighted]

	if slot then
		self:_setSelected(slot, true)
	end

	self.titleLabel.Text = WheelConfig.SlotNames[highlighted] or tostring(highlighted)
end

function WheelAnimator.OnHighlightChanged(p, p2)
	table.insert(p.highlightChangedListeners, p2)
end

function WheelAnimator:_setSelected(instance, p, p2)
	local firstChild = instance:FindFirstChild("选中高光")
	local firstChild2 = instance:FindFirstChild("选中分隔点")
	local firstChild3 = instance:FindFirstChild("预览容器")
	local imageTransparency = p and 0 or 1
	local previewHighlightMultiplier = p and WheelConfig.PreviewHighlightMultiplier or 1
	local uDim = UDim2.fromScale(
		WheelConfig.PreviewBaseScale * previewHighlightMultiplier,
		WheelConfig.PreviewBaseScale * previewHighlightMultiplier
	)

	if p2 then
		if firstChild then
			firstChild.ImageTransparency = imageTransparency
		end

		local v2 = firstChild2 and firstChild2:FindFirstChild("圆环图标")

		if v2 then
			v2.ImageTransparency = imageTransparency
		end

		if firstChild3 then
			firstChild3.Size = uDim
		end
	else
		if firstChild then
			TweenService:Create(
				firstChild,
				TweenInfo.new(WheelConfig.HighlightDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					ImageTransparency = imageTransparency
				}
			):Play()
		end

		local v2 = firstChild2 and firstChild2:FindFirstChild("圆环图标")

		if v2 then
			TweenService:Create(
				v2,
				TweenInfo.new(WheelConfig.HighlightDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					ImageTransparency = imageTransparency
				}
			):Play()
		end

		if firstChild3 then
			TweenService:Create(
				firstChild3,
				TweenInfo.new(WheelConfig.HighlightDuration, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{
					Size = uDim
				}
			):Play()
		end
	end
end

function WheelAnimator.PulseConfirm(p, p2)
	local slot = p.slots[p2]

	if not slot then
		return
	end

	local firstChild = slot:FindFirstChild("预览容器")

	if not firstChild then
		return
	end

	local uDim = UDim2.fromScale(WheelConfig.PreviewBaseScale, WheelConfig.PreviewBaseScale)
	local uDim2 = UDim2.fromScale(
		WheelConfig.PreviewBaseScale * WheelConfig.PreviewConfirmMultiplier,
		WheelConfig.PreviewBaseScale * WheelConfig.PreviewConfirmMultiplier
	)
	local tween = TweenService:Create(
		firstChild,
		TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			Size = uDim2
		}
	)
	local tween2 = TweenService:Create(
		firstChild,
		TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{
			Size = uDim
		}
	)
	tween.Completed:Once(function()
		tween2:Play()
	end)
	tween:Play()
end

return WheelAnimator