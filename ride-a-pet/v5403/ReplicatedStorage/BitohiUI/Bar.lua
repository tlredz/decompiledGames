local Spring = require(script.Parent:WaitForChild("Spring"))
local Store = require(script.Parent:WaitForChild("Store"))
local spr = Spring.spr
local v = Store.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function size(instance, value)
	local fullScale = instance:GetAttribute("FullScale") or 1
	return UDim2.new(fullScale * math.clamp(value, 0, 1), 0, instance.Size.Y.Scale, instance.Size.Y.Offset)
end

local Bar = {}

function Bar.fill(instance, value, value2)
	Spring.to(instance, value2 or "Bar", {
		Size = size(instance, value)
	})
end

function Bar:snap(value)
	spr.stop(self, "Size")
	self.Size = size(self, value)
end

function Bar.phantom(instance, p, value, options)
	local v2 = options or {}
	local v3 = instance.Size.X.Scale / (instance:GetAttribute("FullScale") or 1)
	local v4 = (v[instance] or 0) + 1
	v[instance] = v4
	local size2 = size(instance, value) -- equivalent call inferred; original call site unknown

	if v3 <= value then
		spr.stop(p, "Size")
		p.Size = size2
		Spring.to(instance, v2.Heal or "Bar", {
			Size = size2
		})
	else
		Spring.to(instance, v2.Snap or "BarSnap", {
			Size = size2
		})
		task.delay(v2.Hold or 0.35, function()
			if v[instance] ~= v4 then
				return
			end

			Spring.to(p, v2.Trail or "Trail", {
				Size = size2
			})
		end)
	end
end

function Bar:ghostDrop(parent, options)
	local v2 = options or {}
	local absolutePosition = self.AbsolutePosition
	local absoluteSize = self.AbsoluteSize
	local absolutePosition2 = parent.AbsolutePosition
	local canvasGroup = Instance.new("CanvasGroup")
	canvasGroup.Name = "Ghost"
	canvasGroup.BackgroundTransparency = 1
	canvasGroup.BorderSizePixel = 0
	canvasGroup.AnchorPoint = Vector2.new(0.5, 0.5)
	canvasGroup.Size = UDim2.fromOffset(absoluteSize.X, absoluteSize.Y)
	canvasGroup.Position = UDim2.fromOffset(
		absolutePosition.X - absolutePosition2.X + absoluteSize.X / 2,
		absolutePosition.Y - absolutePosition2.Y + absoluteSize.Y / 2
	)
	canvasGroup.ZIndex = v2.ZIndex or 50
	canvasGroup.Parent = parent
	local clone = self:Clone()
	clone.Visible = true
	clone.AnchorPoint = Vector2.new(0, 0)
	clone.Position = UDim2.fromScale(0, 0)
	clone.Size = UDim2.fromScale(1, 1)
	clone.Parent = canvasGroup
	self.Visible = false
	local random = Random.new()
	local rotation = (random:NextNumber() < 0.5 and -1 or 1) * random:NextInteger(8, 18)
	local v4 = absoluteSize.Y * (v2.Distance or 2.6)
	Spring.to(canvasGroup, v2.Fall or { 1, 1.8 }, {
		Position = canvasGroup.Position + UDim2.fromOffset(0, v4),
		Rotation = rotation
	})
	task.delay(0.15, function()
		if canvasGroup.Parent then
			Spring.to(canvasGroup, v2.FadeTuning or { 1, 2.2 }, {
				GroupTransparency = 1
			})
		end
	end)
	task.delay(v2.Settle or 0.9, function()
		if canvasGroup.Parent then
			spr.stop(canvasGroup)
			canvasGroup:Destroy()
		end
	end)
	return canvasGroup
end

return Bar