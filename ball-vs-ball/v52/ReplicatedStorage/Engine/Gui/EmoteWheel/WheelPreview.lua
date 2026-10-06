local WheelConfig = require(script.Parent.WheelConfig)
local PreviewRenderer = require(script.Parent.PreviewRenderer)
local WheelPreview = {}
WheelPreview.__index = WheelPreview

function WheelPreview.new(p)
	local object = setmetatable({}, WheelPreview)
	object.viewports = {}
	object.cleanups = {}
	object.currentKeys = {}
	object.revisions = {}
	object.isPlaying = false
	object.flyerOnlyLabels = {}
	local v = p["屏幕居中层"]["缩放偏移层"]["内容根"]["扇区容器"]

	for i = 1, WheelConfig.SlotCount do
		local child = v:FindFirstChild("槽位" .. i)
		local v2 = child and child:FindFirstChild("预览容器")
		local v3 = v2 and v2:FindFirstChild("角色预览")

		if v3 then
			for _, child2 in ipairs(v3:GetChildren()) do
				child2:Destroy()
			end
		end

		object.viewports[i] = v3
		object.revisions[i] = 0
		object.flyerOnlyLabels[i] = v2 and v2:FindFirstChild("仅限飞行器")
	end

	return object
end

function WheelPreview:_updateFlyerOnlyHint(p2, p3)
	local flyerOnlyLabel = self.flyerOnlyLabels[p2]

	if not flyerOnlyLabel then
		return
	end

	local visible

	if WheelConfig.FlyerOnlySlots[p2] == true then
		visible = p3 == nil
	else
		visible = false
	end

	flyerOnlyLabel.Visible = visible
	local viewport = self.viewports[p2]

	if viewport then
		viewport.Visible = not visible
	end
end

function WheelPreview:_clear(p)
	self.revisions[p] = (self.revisions[p] or 0) + 1
	local cleanup = self.cleanups[p]

	if cleanup then
		cleanup()
		self.cleanups[p] = nil
	end

	self.currentKeys[p] = nil
end

function WheelPreview:_render(p, p2)
	self:_clear(p)

	if not (self.isPlaying and p2) then
		return
	end

	local viewportFrame = self.viewports[p]

	if not (viewportFrame and viewportFrame:IsA("ViewportFrame")) then
		return
	end

	local revision = self.revisions[p]
	local contentKey = WheelConfig.contentKey(p2)
	task.spawn(function()
		local v = PreviewRenderer.render(viewportFrame, p2)

		if revision == self.revisions[p] and self.isPlaying and viewportFrame.Parent ~= nil then
			self.cleanups[p] = v
			self.currentKeys[p] = contentKey
		elseif v then
			v()
		end
	end)
end

function WheelPreview:RefreshAll(p)
	if not self.isPlaying then
		return
	end

	for i = 1, WheelConfig.SlotCount do
		local slotContent = WheelConfig.SlotContents[i]
		local contentKey = WheelConfig.contentKey(slotContent)

		if p or contentKey ~= self.currentKeys[i] then
			self:_render(i, slotContent)
		end

		self:_updateFlyerOnlyHint(i, slotContent)
	end
end

function WheelPreview:Play()
	self.isPlaying = true
	self:RefreshAll(true)
end

function WheelPreview:Stop()
	self.isPlaying = false

	for i = 1, WheelConfig.SlotCount do
		self:_clear(i)
	end
end

return WheelPreview