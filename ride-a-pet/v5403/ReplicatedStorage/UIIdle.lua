local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BitohiUI = require(ReplicatedStorage:WaitForChild("BitohiUI"))
local UIQuality = require(ReplicatedStorage:WaitForChild("UIQuality"))
local ticker = BitohiUI.Ticker
local spring = BitohiUI.Spring
local spr = spring.spr
local UIIdle = {
	Tags = {
		Float = "UIFloat",
		Breathe = "UIBreathe",
		Shine = "UIShine",
		Spin = "UISpin",
		Sparkle = "UISparkle",
		Sprite = "UISprite",
		Gradient = "UIGradientLoop"
	}
}

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function smooth(p)
	return p * p * (3 - 2 * p)
end

local sparkle = BitohiUI.Sparkle
local store = BitohiUI.Store.new()
local store2 = BitohiUI.Store.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function rate()
	if UIQuality.low() or UserInputService.TouchEnabled then
		return 0.03
	end

	return 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function attr(instance, attributeName, p)
	local attribute = instance:GetAttribute(attributeName)
	return type(attribute) == "number" and attribute or p
end

local function below(p, p2)
	return (math.min(p, p2))
end

local store3 = BitohiUI.Store.new()

local function cellsOf(instance)
	local cells = instance:GetAttribute("Cells")

	if typeof(cells) == "Vector2" then
		return math.max(1, (math.floor(cells.X))), (math.max(1, (math.floor(cells.Y))))
	end

	if type(cells) == "string" then
		local match, v = cells:match("(%d+)%s*[xX,]%s*(%d+)")

		if match then
			return math.max(1, (tonumber(match))), (math.max(1, (tonumber(v))))
		end
	end

	return 1, 1
end

local store4 = BitohiUI.Store.new()

local function sheetKey(instance)
	local sheetSize = instance:GetAttribute("SheetSize")
	return tostring(instance:GetAttribute("Cells")) .. "|" .. tostring(instance:GetAttribute("Frames")) .. "|" .. (typeof(sheetSize) == "Vector2" and tostring(sheetSize) or "r" .. tostring(instance.ImageRectSize))
end

local function sheetFor(guiObject)
	local v = sheetKey(guiObject)
	local v2 = store3[guiObject]

	if v2 and v2.key == v then
		return v2
	end

	local rest = v2 and v2.rest or guiObject.ImageRectOffset
	local v3, v4 = cellsOf(guiObject)
	local imageRectSize = guiObject.ImageRectSize
	local sheetSize = guiObject:GetAttribute("SheetSize")

	if typeof(sheetSize) == "Vector2" then
		imageRectSize = Vector2.new(sheetSize.X / v3, sheetSize.Y / v4)
		guiObject.ImageRectSize = imageRectSize
	end

	if imageRectSize.X <= 0 or imageRectSize.Y <= 0 then
		if not store4[guiObject] then
			store4[guiObject] = true
			warn("[UIIdle] UISprite on " .. guiObject:GetFullName() .. ": set SheetSize (Vector2 px) or ImageRectSize to one cell; skipped")
		end

		return nil
	else
		local v5 = v3 * v4
		local frames = math.clamp(math.floor(attr(guiObject, "Frames", v5)), 1, v3 * v4)
		local vectors = table.create(frames)

		for i = 0, frames - 1 do
			vectors[i + 1] = Vector2.new(i % v3 * imageRectSize.X, math.floor(i / v3) * imageRectSize.Y)
		end

		local v7 = {
			offsets = vectors,
			frames = frames,
			rest = rest,
			key = v
		}
		store3[guiObject] = v7
		return v7
	end
end

local random = Random.new()
local v = {}
local store5 = BitohiUI.Store.new()
local store6 = BitohiUI.Store.new()

local function lerpAt(keypoints, p)
	for i = 1, #keypoints - 1 do
		local v2 = keypoints[i]
		local v3 = keypoints[i + 1]

		if not (p <= v3.Time) then
			continue
		end

		local v4 = v3.Time - v2.Time
		return v2.Value:Lerp(v3.Value, v4 > 0 and (p - v2.Time) / v4 or 0)
	end

	return keypoints[#keypoints].Value
end

local function wraps(sequence)
	local keypoints = sequence.Keypoints
	local value = keypoints[1].Value
	local value2 = keypoints[#keypoints].Value
	return #keypoints <= 19 and math.abs(value.R - value2.R) + math.abs(value.G - value2.G) + math.abs(value.B - value2.B) < 0.03
end

local function shifted(color, p)
	local keypoints = color.Keypoints
	local v2 = lerpAt(keypoints, (1 - p) % 1)
	local colorSequenceKeypoints = { ColorSequenceKeypoint.new(0, v2) }
	local v3 = {}

	for i = 1, #keypoints - 1 do
		local v4 = (keypoints[i].Time + p) % 1

		if v4 > 0.0005 and v4 < 0.9995 then
			table.insert(v3, { v4, keypoints[i].Value })
		end
	end

	table.sort(v3, function(a, b)
		return a[1] < b[1]
	end)

	for _, v4 in ipairs(v3) do
		table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(v4[1], v4[2]))
	end

	table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(1, v2))
	return ColorSequence.new(colorSequenceKeypoints)
end

local function gradFor(instance)
	local gradientMode = instance:GetAttribute("GradientMode")
	local v2 = tostring(gradientMode)
	local v3 = store6[instance]

	if v3 and v3.key == v2 then
		return v3
	end

	local v4 = {
		color = v3 and v3.color or instance.Color,
		offset = v3 and v3.offset or instance.Offset,
		rot = v3 and v3.rot or instance.Rotation,
		key = v2
	}

	if gradientMode ~= "Sway" and gradientMode ~= "Spin" then
		local keypoints = v4.color.Keypoints
		local value = keypoints[1].Value
		local value2 = keypoints[#keypoints].Value
		local v5

		if #keypoints <= 19 then
			v5 = math.abs(value.R - value2.R) + math.abs(value.G - value2.G) + math.abs(value.B - value2.B) < 0.03
		else
			v5 = false
		end

		if v5 then
			local seqs = table.create(96)
			gradientMode = "Scroll"

			for i = 0, 95 do
				seqs[i + 1] = shifted(v4.color, i / 96)
			end

			v4.seqs = seqs
		else
			gradientMode = "Sway"
		end
	end

	v4.mode = gradientMode
	store6[instance] = v4
	return v4
end

local color = Color3.fromRGB(255, 250, 235)
local numberSequence = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.29, 1),
	NumberSequenceKeypoint.new(0.32, 0.9),
	NumberSequenceKeypoint.new(0.36, 0.72),
	NumberSequenceKeypoint.new(0.4, 0.9),
	NumberSequenceKeypoint.new(0.43, 1),
	NumberSequenceKeypoint.new(0.46, 1),
	NumberSequenceKeypoint.new(0.5, 0.93),
	NumberSequenceKeypoint.new(0.55, 0.78),
	NumberSequenceKeypoint.new(0.62, 0.6),
	NumberSequenceKeypoint.new(0.69, 0.78),
	NumberSequenceKeypoint.new(0.74, 0.93),
	NumberSequenceKeypoint.new(0.78, 1),
	NumberSequenceKeypoint.new(1, 1)
})
local store7 = BitohiUI.Store.new()

local function shimmerFor(guiObject)
	local v2 = store7[guiObject]

	if v2 and v2.overlay.Parent == guiObject then
		return v2
	end

	local image = not (guiObject:IsA("ImageLabel") or guiObject:IsA("ImageButton")) and "" or guiObject.Image or ""
	local v4

	if image == "" then
		v4 = Instance.new("Frame")
		v4.BackgroundColor3 = color
		v4.BackgroundTransparency = 0
		local uICorner = Instance.new("UICorner")
		local uICorner2 = guiObject:FindFirstChildOfClass("UICorner")
		uICorner.CornerRadius = uICorner2 and uICorner2.CornerRadius or UDim.new(0, 8)
		uICorner.Parent = v4
	else
		v4 = Instance.new("ImageLabel")
		v4.Image = image
		v4.ImageColor3 = color
		v4.ScaleType = guiObject.ScaleType
		v4.SliceCenter = guiObject.SliceCenter
		v4.SliceScale = guiObject.SliceScale
		v4.TileSize = guiObject.TileSize
		v4.ImageRectOffset = guiObject.ImageRectOffset
		v4.ImageRectSize = guiObject.ImageRectSize
		v4.ResampleMode = guiObject.ResampleMode
		v4.BackgroundTransparency = 1
	end

	v4.Name = "UIShimmer"
	v4.BorderSizePixel = 0
	v4.AnchorPoint = Vector2.zero
	v4.Position = UDim2.fromScale(0, 0)
	v4.Size = UDim2.fromScale(1, 1)
	local zIndex = guiObject.ZIndex
	local layerCollector = guiObject:FindFirstAncestorWhichIsA("LayerCollector")

	if not layerCollector or not layerCollector:IsA("ScreenGui") or layerCollector.ZIndexBehavior == Enum.ZIndexBehavior.Sibling then
		for _, guiObject2 in ipairs(guiObject:GetChildren()) do
			if guiObject2:IsA("GuiObject") and guiObject2.ZIndex - 1 < zIndex then
				zIndex = guiObject2.ZIndex - 1
			end
		end
	end

	v4.ZIndex = zIndex
	v4.Active = false
	v4.Visible = false
	local uIGradient = Instance.new("UIGradient")
	uIGradient.Transparency = numberSequence
	uIGradient.Rotation = 20
	uIGradient.Offset = Vector2.new(-1.2, 0)
	uIGradient.Parent = v4
	v4.Parent = guiObject
	local v5 = {
		overlay = v4,
		gradient = uIGradient
	}
	store7[guiObject] = v5
	return v5
end

local function inLayout(p)
	local parent = p.Parent
	return parent ~= nil and parent:FindFirstChildWhichIsA("UIGridStyleLayout") ~= nil
end

local function shownIn(p, p2)
	local parent = p.Parent

	while parent and parent ~= p2 do
		if parent:IsA("GuiObject") and not parent.Visible then
			return false
		else
			parent = parent.Parent
		end
	end

	return parent == p2
end

local store8 = BitohiUI.Store.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function dropCache()
	table.clear(store8)
end

local connections = {}

local function watchTags()
	local v2 = #connections > 0

	for i = 1, #connections do
		if connections[i].Connected then
			continue
		end

		v2 = false
		break
	end

	if v2 then
		return
	end

	for i = 1, #connections do
		connections[i]:Disconnect()
	end

	table.clear(connections)

	for _, tag in pairs(UIIdle.Tags) do
		table.insert(connections, CollectionService:GetInstanceAddedSignal(tag):Connect(dropCache))
		table.insert(connections, CollectionService:GetInstanceRemovedSignal(tag):Connect(dropCache))
	end

	dropCache() -- equivalent call inferred; original call site unknown
end

watchTags()

local function under(tag, ancestor)
	watchTags()
	local v2 = store8[ancestor]

	if not v2 then
		v2 = {}
		store8[ancestor] = v2
	end

	local instances = v2[tag]

	if instances then
		return instances
	end

	instances = {}

	for _, instance in ipairs(CollectionService:GetTagged(tag)) do
		if not ((instance:IsA("GuiObject") or tag == UIIdle.Tags.Gradient and instance:IsA("UIGradient")) and instance:IsDescendantOf(ancestor)) then
			continue
		end

		table.insert(instances, instance)
	end

	v2[tag] = instances
	return instances
end

local function tagged(p, instance)
	local result = {}

	for _, v2 in ipairs((under(p, instance))) do
		if v2.Parent and shownIn(v2, instance) then
			table.insert(result, v2)
		end
	end

	return result
end

local function clipOf(p, instance)
	local parent = p.Parent

	while parent and parent ~= instance do
		if parent:IsA("ScrollingFrame") then
			return parent
		else
			parent = parent.Parent
		end
	end

	return false
end

local function inView(p, p2)
	local absolutePosition = p.AbsolutePosition
	local absoluteSize = p.AbsoluteSize
	local absolutePosition2 = p2.AbsolutePosition
	local absoluteSize2 = p2.AbsoluteSize
	return absolutePosition.Y < absolutePosition2.Y + absoluteSize2.Y and absolutePosition.Y + absoluteSize.Y > absolutePosition2.Y and absolutePosition.X < absolutePosition2.X + absoluteSize2.X and absolutePosition.X + absoluteSize.X > absolutePosition2.X
end

local function canvasRect(p, p2)
	local absolutePosition = p.AbsolutePosition
	local absoluteSize = p.AbsoluteSize
	local absolutePosition2 = p2.AbsolutePosition
	local canvasPosition = p2.CanvasPosition
	local v2 = absolutePosition.Y - absolutePosition2.Y + canvasPosition.Y
	local v3 = absolutePosition.X - absolutePosition2.X + canvasPosition.X
	return v2, v2 + absoluteSize.Y, v3, v3 + absoluteSize.X
end

local function drawsNothing(instance)
	if instance.BackgroundTransparency < 1 then
		return false
	end

	if instance:IsA("ViewportFrame") then
		return #instance:GetChildren() == 0
	end

	if not ((instance:IsA("ImageLabel") or instance:IsA("ImageButton")) and instance.Image == "") then
		return false
	end

	for _, guiObject in ipairs(instance:GetChildren()) do
		if guiObject:IsA("GuiObject") then
			return false
		end
	end

	return true
end

local function sparkleFor(instance)
	local low = UIQuality.low()
	local v2 = store2[instance]

	if v2 and v2.low ~= low then
		v2:Destroy()
		v2 = nil
	end

	if v2 then
		return v2
	end

	v2 = sparkle.new(instance, {
		Rate = attr(instance, "SparkleRate", 2.5),
		Pool = attr(instance, "SparklePool", 5),
		Size = attr(instance, "SparkleSize", 0.22),
		Image = instance:GetAttribute("SparkleImage"),
		Low = low
	})
	store2[instance] = v2
	return v2
end

local function restore(data, p)
	for i, v2 in ipairs(data.fObj) do
		if not v2.Parent then
			continue
		end

		v2.Position = data.fHome[i]
		v2.Rotation = data.fRot[i]
	end

	for _, v2 in ipairs(data.bLayer) do
		if v2.Parent then
			v2.Scale = 1
		end
	end

	if not p then
		for i, v2 in ipairs(data.pObj) do
			if v2.Parent then
				v2.Rotation = data.pRot[i]
			end
		end
	end

	for _, v2 in ipairs(data.kObj) do
		local v3 = store6[v2]

		if not (v3 and v2.Parent) then
			continue
		end

		v2.Color = v3.color
		v2.Offset = v3.offset
		v2.Rotation = v3.rot
	end

	for _, v2 in ipairs(data.zObj) do
		local v3 = store3[v2]

		if v3 and v2.Parent then
			v2.ImageRectOffset = v3.rest
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unspin(p)
	local v2 = store5[p]

	if not v2 then
		return
	end

	store5[p] = nil
	restore(v2)
end

function UIIdle.warm(instance)
	if instance.Visible or v[instance] then
		return
	end

	local function hidden()
		return instance.Parent ~= nil and not (instance.Visible or v[instance])
	end

	for _, v2 in ipairs({ UIIdle.Tags.Float, UIIdle.Tags.Spin }) do
		for _, v3 in ipairs((under(v2, instance))) do
			if not store[v3] then
				store[v3] = {
					pos = v3.Position,
					rot = v3.Rotation
				}
			end
		end
	end

	for _, v2 in ipairs((under(UIIdle.Tags.Gradient, instance))) do
		gradFor(v2)
	end

	for _, instance2 in ipairs((under(UIIdle.Tags.Breathe, instance))) do
		local parent = instance2.Parent
		local v2

		if parent == nil then
			v2 = false
		else
			v2 = parent:FindFirstChildWhichIsA("UIGridStyleLayout") ~= nil
		end

		if not (v2 or CollectionService:HasTag(instance2, "EnlargeOnHover")) then
			spring.scale(instance2, "BreatheScale")
		end
	end

	for _, v2 in ipairs((under(UIIdle.Tags.Sparkle, instance))) do
		local v3 = sparkleFor(v2)

		if v3.built then
			continue
		end

		v3:Warm()
		task.wait()
		local v4

		if instance.Parent == nil then
			v4 = false
		else
			v4 = not (instance.Visible or v[instance])
		end

		if not v4 then
			return
		end
	end

	for _, v2 in ipairs((under(UIIdle.Tags.Shine, instance))) do
		local v3 = store7[v2]

		if not (not v3 or v3.overlay.Parent ~= v2) then
			continue
		end

		shimmerFor(v2)
		task.wait()
		local v4

		if instance.Parent == nil then
			v4 = false
		else
			v4 = not (instance.Visible or v[instance])
		end

		if not v4 then
			break
		end
	end
end

function UIIdle.start(instance)
	if v[instance] or not instance.Parent then
		return
	end

	local v2 = store5[instance]
	store5[instance] = nil
	local v3 = {}

	if v2 then
		restore(v2, true)

		for i, v4 in ipairs(v2.pObj) do
			v3[v4] = v2.pRot[i]
		end
	end

	local viewportFrames = {}
	local pos = {}
	local rots = {}
	local v4 = {}
	local v5 = {}
	local v6 = {}
	local v7 = {}
	local v8 = {}
	local scales = {}
	local offsets = {}
	local scales2 = {}
	local offsets2 = {}
	local v9 = {}
	local visibility = {}
	local v10 = {}
	local v11 = {}
	local v12 = {}
	local v13 = {}
	local v14 = {}
	local connections2 = {}
	local v15 = {}
	local v16 = {}
	local v17 = {}
	local v18 = {}
	local v19 = {}
	local v20 = {}
	local count = 0

	local function clipSlot(p)
		local v21 = v20[p]

		if v21 then
			return v21
		end

		count += 1
		v21 = count
		v20[p] = v21
		v19[v21] = p
		return v21
	end

	local v21 = {}
	local v22 = {}
	local v23 = {}
	local v24 = {}
	local v25 = {}
	local v26 = {}
	local v27 = {}

	local function cullSlot(guiObject)
		if not (guiObject and guiObject:IsA("GuiObject")) then
			return false
		end

		local v28 = clipOf(guiObject, instance)

		if not v28 then
			return false
		end

		local v29 = #v21 + 1
		local v30 = v21
		local v31 = v22
		local v32 = v23
		local v33 = v20[v28]

		if not v33 then
			count += 1
			v33 = count
			v20[v28] = v33
			v19[v33] = v28
		end

		v30[v29] = guiObject
		v31[v29] = v33
		v32[v29] = true
		local v34 = v25
		local v35 = v26
		local v36 = v27
		v24[v29] = 0
		v34[v29] = 0
		v35[v29] = 0
		v36[v29] = 0
		return v29
	end

	for _, viewportFrame in ipairs((tagged(UIIdle.Tags.Float, instance))) do
		local v28 = #viewportFrames + 1
		local v29 = attr(viewportFrame, "FloatDuration", 2.4) * random:NextNumber(0.9, 1.1)
		spr.stop(viewportFrame, "Position")
		spr.stop(viewportFrame, "Rotation")
		viewportFrames[v28] = viewportFrame
		local v30 = store[viewportFrame]

		if not v30 then
			v30 = {
				pos = viewportFrame.Position,
				rot = viewportFrame.Rotation
			}
			store[viewportFrame] = v30
		end

		local pos2 = v30.pos
		pos[v28] = pos2
		local scale = pos2.X.Scale
		local offset = pos2.X.Offset
		local scale2 = pos2.Y.Scale
		local offset2 = pos2.Y.Offset
		scales[v28] = scale
		offsets[v28] = offset
		scales2[v28] = scale2
		offsets2[v28] = offset2
		rots[v28] = v30.rot
		local v31 = not viewportFrame.Parent:IsA("GuiObject") and 0 or viewportFrame.Parent.AbsoluteSize.Y or 0
		local v32 = attr(viewportFrame, "FloatDistance", 5) * random:NextNumber(0.85, 1.15)
		v4[v28] = not (v31 > 1) and 0 or v32 / v31 or 0
		v6[v28] = 3.141592653589793 / v29
		local v33

		if CollectionService:HasTag(viewportFrame, "RotateOnHover") then
			v33 = 0
		else
			v33 = attr(viewportFrame, "FloatSway", 2)
		end

		v7[v28] = v33
		v10[v28] = not (v31 > 1) and 0 or math.min(0.25 / v31, v4[v28] / 8) or 0
		local absoluteSize = viewportFrame.AbsoluteSize
		local v34 = math.sqrt(absoluteSize.X * absoluteSize.X + absoluteSize.Y * absoluteSize.Y) * 0.5
		v11[v28] = not (v34 > 1) and 0.05 or math.min(math.deg(0.25 / v34), math.abs(v7[v28]) / 8) or 0.05
		local scale3 = pos2.Y.Scale
		local v35 = rots[v28]
		v12[v28] = scale3
		v13[v28] = v35
		v5[v28] = random:NextNumber(0, 6.283185307179586)
		local parent = viewportFrame.Parent
		v8[v28] = parent == nil or parent:FindFirstChildWhichIsA("UIGridStyleLayout") == nil
		v14[v28] = drawsNothing(viewportFrame)

		if v14[v28] then
			local v37 = viewportFrame
			local v38 = v28

			local function recheck()
				local v39 = drawsNothing(v37)

				if v39 and not v14[v38] then
					v37.Position = pos[v38]
					v37.Rotation = rots[v38]
					local v40 = v12
					local v42 = v13
					local v44 = scales2[v38]
					local v45 = rots[v38]
					v40[v38] = v44
					v42[v38] = v45
				end

				v14[v38] = v39
			end

			table.insert(connections2, viewportFrame.ChildAdded:Connect(recheck))
			table.insert(connections2, viewportFrame.ChildRemoved:Connect(recheck))
			table.insert(
				connections2,
				viewportFrame:GetPropertyChangedSignal("BackgroundTransparency"):Connect(recheck)
			)

			if not viewportFrame:IsA("ViewportFrame") then
				table.insert(connections2, viewportFrame:GetPropertyChangedSignal("Image"):Connect(recheck))
			end
		end

		local v37 = clipOf(viewportFrame, instance)
		local visible = viewportFrame.Visible

		if visible then
			visible = not v37

			if not visible then
				local absolutePosition = viewportFrame.AbsolutePosition
				local absoluteSize2 = viewportFrame.AbsoluteSize
				local absolutePosition2 = v37.AbsolutePosition
				local absoluteSize3 = v37.AbsoluteSize

				if absolutePosition.Y < absolutePosition2.Y + absoluteSize3.Y and absolutePosition.Y + absoluteSize2.Y > absolutePosition2.Y and absolutePosition.X < absolutePosition2.X + absoluteSize3.X then
					visible = absolutePosition.X + absoluteSize2.X > absolutePosition2.X
				else
					visible = false
				end
			end
		end

		visibility[v28] = visible

		if v37 then
			local absolutePosition = viewportFrame.AbsolutePosition
			local absoluteSize2 = viewportFrame.AbsoluteSize
			local absolutePosition2 = v37.AbsolutePosition
			local canvasPosition = v37.CanvasPosition
			local v38 = absolutePosition.Y - absolutePosition2.Y + canvasPosition.Y
			local v39 = absolutePosition.X - absolutePosition2.X + canvasPosition.X
			local v40 = v38 + absoluteSize2.Y
			local v41 = v39 + absoluteSize2.X
			v15[v28] = v38
			v16[v28] = v40
			v17[v28] = v39
			v18[v28] = v41
			local v42 = v20[v37]

			if not v42 then
				count += 1
				v42 = count
				v20[v37] = v42
				v19[v42] = v37
			end

			v9[v28] = v42
		else
			v9[v28] = false
		end
	end

	local low = UIQuality.low()
	local values = {}
	local instances = {}
	local v28 = {}
	local v29 = {}
	local v30 = {}
	local v31 = {}
	local v32 = {}
	local v33 = {}
	local v34 = {}
	local v35 = {}
	local v36 = {}

	for _, instance2 in ipairs((tagged(UIIdle.Tags.Breathe, instance))) do
		local parent = instance2.Parent
		local v37

		if parent == nil then
			v37 = false
		else
			v37 = parent:FindFirstChildWhichIsA("UIGridStyleLayout") ~= nil
		end

		if v37 or CollectionService:HasTag(instance2, "EnlargeOnHover") or low and CollectionService:HasTag(
			instance2,
			UIIdle.Tags.Spin
		) then
			continue
		end

		local v38 = #values + 1
		values[v38] = spring.scale(instance2, "BreatheScale")
		instances[v38] = instance2
		v28[v38] = attr(instance2, "BreatheAmount", 0.04)
		v29[v38] = 6.283185307179586 / attr(instance2, "BreatheDuration", 1.4)
		v30[v38] = random:NextNumber(0, 6.283185307179586)
		local absoluteSize = instance2.AbsoluteSize
		local v39 = math.max(absoluteSize.X, absoluteSize.Y)
		v31[v38] = not (v39 > 1) and 0.001 or math.min(0.5 / v39, v28[v38] / 8) or 0.001
		v32[v38] = values[v38].Scale
		v33[v38] = cullSlot(instance2)
	end

	local overlays = {}
	local gradients = {}
	local v37 = {}
	local v38 = {}
	local v39 = {}

	for _, guiObject in ipairs((tagged(UIIdle.Tags.Shine, instance))) do
		local v40 = #overlays + 1
		local v41 = shimmerFor(guiObject)
		overlays[v40] = v41.overlay
		gradients[v40] = v41.gradient
		v37[v40] = math.max(0, attr(guiObject, "ShinePause", 2.2)) + 1.3
		v38[v40] = v37[v40] - 0.3
		v39[v40] = false
		v41.gradient.Offset = Vector2.new(-1.2, 0)
		local overlay = v41.overlay

		if not (overlay:IsA("ImageLabel") and (guiObject:IsA("ImageLabel") or guiObject:IsA("ImageButton"))) then
			continue
		end

		if overlay.Image ~= guiObject.Image then
			overlay.Image = guiObject.Image
		end

		if overlay.ImageRectOffset ~= guiObject.ImageRectOffset then
			overlay.ImageRectOffset = guiObject.ImageRectOffset
		end

		if overlay.ImageRectSize ~= guiObject.ImageRectSize then
			overlay.ImageRectSize = guiObject.ImageRectSize
		end
	end

	local instances2 = {}
	local rots2 = {}
	local v40 = {}
	local v41 = {}

	for _, instance2 in ipairs((tagged(UIIdle.Tags.Spin, instance))) do
		if CollectionService:HasTag(instance2, "RotateOnHover") then
			continue
		end

		local v42 = #instances2 + 1
		spr.stop(instance2, "Rotation")
		local rotation = instance2.Rotation
		local rot = v3[instance2]

		if rot == nil then
			if store[instance2] then
				rot = store[instance2].rot or rotation
			else
				rot = rotation
			end
		end

		v3[instance2] = nil
		local v43 = attr(instance2, "SpinSpeed", 25) -- equivalent call inferred; original call site unknown
		instances2[v42] = instance2
		rots2[v42] = rot
		v40[v42] = v43
		v41[v42] = (rotation - rot) % 360
		v34[v42] = cullSlot(instance2)
	end

	for k, rotation in pairs(v3) do
		if k.Parent then
			k.Rotation = rotation
		end
	end

	local guiObjects = {}
	local offsets3 = {}
	local frames = {}
	local v42 = {}
	local v43 = {}
	local v44 = {}
	local v45 = {}

	for _, guiObject in ipairs((tagged(UIIdle.Tags.Sprite, instance))) do
		if not (guiObject:IsA("ImageLabel") or guiObject:IsA("ImageButton")) then
			continue
		end

		local v46 = #guiObjects + 1
		local v47 = sheetFor(guiObject)

		if not v47 then
			continue
		end

		local offsets4 = v47.offsets
		local frames2 = v47.frames
		guiObjects[v46] = guiObject
		offsets3[v46] = offsets4
		frames[v46] = frames2
		v42[v46] = math.max(1, attr(guiObject, "FPS", 24)) * (low and 0.5 or 1)
		v43[v46] = guiObject:GetAttribute("Loop") ~= false
		v44[v46] = math.max(0, attr(guiObject, "Pause", 0))
		v45[v46] = -1
		v35[v46] = cullSlot(guiObject)
	end

	local kObj = {}
	local modes = {}
	local seqs = {}
	local Xs = {}
	local Ys = {}
	local rots3 = {}
	local v47 = {}
	local v48 = {}
	local v49 = {}
	local v50 = {}
	local v51 = {}
	local v52 = {}
	local v53 = {}

	for _, v54 in ipairs((tagged(UIIdle.Tags.Gradient, instance))) do
		local v55 = gradFor(v54)
		local v56 = #kObj + 1
		local mode = v55.mode
		local seqs2 = v55.seqs
		kObj[v56] = v54
		modes[v56] = mode
		seqs[v56] = seqs2
		local X = v55.offset.X
		local Y = v55.offset.Y
		local rot = v55.rot
		Xs[v56] = X
		Ys[v56] = Y
		rots3[v56] = rot

		if v55.mode == "Scroll" then
			v52[v56] = attr(v54, "GradientSpeed", 0.25) * 96
			v51[v56] = random:NextInteger(0, 95)
		elseif v55.mode == "Spin" then
			local gradientSpeed = v54:GetAttribute("GradientSpeed")
			v52[v56] = type(gradientSpeed) == "number" and (gradientSpeed or 40) or 40
		else
			local rot2 = math.rad(v55.rot)
			local v57 = math.cos(rot2)
			local v58 = math.sin(rot2)
			v47[v56] = v57
			v48[v56] = v58
			v49[v56] = attr(v54, "GradientSway", 0.25)
			v50[v56] = 6.283185307179586 / math.max(0.2, attr(v54, "GradientDuration", 3))
			v51[v56] = random:NextNumber(0, 6.283185307179586)
		end

		v53[v56] = -1
		v36[v56] = cullSlot(v54.Parent)
	end

	local Xs2 = table.create(count, 0)
	local Ys2 = table.create(count, 0)

	for i = 1, count do
		local absoluteSize = v19[i].AbsoluteSize
		local X = absoluteSize.X
		local Y = absoluteSize.Y
		Xs2[i] = X
		Ys2[i] = Y
	end

	local v54 = table.create(count, 0)
	local v55 = table.create(count, 0)
	local v56 = table.create(count, 0)
	local v57 = table.create(count, 0)
	local count2 = #v21
	local flag = false

	local function remeasure()
		for i = 1, count do
			local absoluteSize = v19[i].AbsoluteSize
			local v58 = Xs2
			local v59 = Ys2
			local X = absoluteSize.X
			local Y = absoluteSize.Y
			v58[i] = X
			v59[i] = Y
		end

		for i = 1, #viewportFrames do
			local v58 = viewportFrames[i]
			local v59 = v9[i]

			if v59 then
				local v60 = v15
				local v61 = v16
				local v62 = v17
				local v63 = v18
				local v64 = v19[v59]
				local absolutePosition = v58.AbsolutePosition
				local absoluteSize = v58.AbsoluteSize
				local absolutePosition2 = v64.AbsolutePosition
				local canvasPosition = v64.CanvasPosition
				local v65 = absolutePosition.Y - absolutePosition2.Y + canvasPosition.Y
				local v66 = absolutePosition.X - absolutePosition2.X + canvasPosition.X
				local v67 = v65 + absoluteSize.Y
				local v68 = v66 + absoluteSize.X
				v60[i] = v65
				v61[i] = v67
				v62[i] = v66
				v63[i] = v68
			end

			local parent = v58.Parent
			local Y = parent and parent:IsA("GuiObject") and parent.AbsoluteSize.Y or 0
			v10[i] = not (Y > 1) and 0 or math.min(0.25 / Y, v4[i] / 8) or 0
			local absoluteSize = v58.AbsoluteSize
			local v60 = math.sqrt(absoluteSize.X * absoluteSize.X + absoluteSize.Y * absoluteSize.Y) * 0.5
			v11[i] = not (v60 > 1) and 0.05 or math.min(math.deg(0.25 / v60), math.abs(v7[i]) / 8) or 0.05
		end

		for i = 1, #instances do
			local absoluteSize = instances[i].AbsoluteSize
			local v58 = math.max(absoluteSize.X, absoluteSize.Y)
			v31[i] = not (v58 > 1) and 0.001 or math.min(0.5 / v58, v28[i] / 8) or 0.001
		end

		for i = 1, count2 do
			local v58 = v24
			local v59 = v25
			local v60 = v26
			local v61 = v27
			local v62 = v21[i]
			local v63 = v19[v22[i]]
			local absolutePosition = v62.AbsolutePosition
			local absoluteSize = v62.AbsoluteSize
			local absolutePosition2 = v63.AbsolutePosition
			local canvasPosition = v63.CanvasPosition
			local v64 = absolutePosition.Y - absolutePosition2.Y + canvasPosition.Y
			local v65 = absolutePosition.X - absolutePosition2.X + canvasPosition.X
			local v66 = v64 + absoluteSize.Y
			local v67 = v65 + absoluteSize.X
			v58[i] = v64
			v59[i] = v66
			v60[i] = v65
			v61[i] = v67
		end
	end

	local v58 = rate() -- equivalent call inferred; original call site unknown
	local glitter = {}
	local v60 = {}

	for _, v61 in ipairs((tagged(UIIdle.Tags.Sparkle, instance))) do
		local v62 = sparkleFor(v61)
		local v63 = v62:Start(v58, true)

		if not v63 then
			continue
		end

		table.insert(glitter, v62)
		table.insert(v60, v63)
	end

	local v61 = {
		fObj = viewportFrames,
		fHome = pos,
		fRot = rots,
		bLayer = values,
		shines = overlays,
		sGrad = gradients,
		step = nil,
		pObj = instances2,
		pRot = rots2,
		glitter = glitter,
		zObj = guiObjects,
		conns = connections2,
		kObj = kObj
	}
	v[instance] = v61
	v61.destroying = instance.Destroying:Connect(function()
		UIIdle.stop(instance)
	end)
	local count3 = #viewportFrames
	local count4 = #values
	local count5 = #instances2
	local count6 = #overlays
	local count7 = #guiObjects
	local count8 = #v60
	local count9 = #kObj

	if count3 + count4 + count5 + count6 + count7 + count8 + count9 == 0 then
		return
	end

	local floor = math.floor
	local total = 0
	local v62 = 0.25
	local sin = math.sin
	local cos = math.cos
	local new = UDim2.new
	local new2 = Vector2.new

	local function step(p)
		total += p
		local v63

		if total >= 0.6 then
			v63 = 1
		else
			v63 = smooth(total / 0.6)
		end

		if v62 <= total then
			v62 = total + 0.25

			if not flag and total >= 1 then
				flag = true
				remeasure()
			end

			for i = 1, count do
				local canvasPosition = v19[i].CanvasPosition
				local v64 = Xs2[i] * 0.25
				local v65 = Ys2[i] * 0.25
				local v66 = v54
				local v67 = v55
				local v68 = canvasPosition.X - v64
				local v69 = canvasPosition.X + Xs2[i] + v64
				v66[i] = v68
				v67[i] = v69
				local v70 = v56
				local v71 = v57
				local v72 = canvasPosition.Y - v65
				local v73 = canvasPosition.Y + Ys2[i] + v65
				v70[i] = v72
				v71[i] = v73
			end

			if flag then
				for i = 1, count2 do
					local v64 = v22[i]
					v23[i] = v24[i] < v57[v64] and v25[i] > v56[v64] and v26[i] < v55[v64] and v27[i] > v54[v64]
				end
			end

			for i = 1, count3 do
				local v64 = viewportFrames[i]
				local visible = v64.Visible
				local v65 = v9[i]

				if visible and v65 then
					if v15[i] < v57[v65] and v16[i] > v56[v65] and v17[i] < v55[v65] then
						visible = v18[i] > v54[v65]
					else
						visible = false
					end

					if visibility[i] and not visible then
						v64.Position = pos[i]
						v64.Rotation = rots[i]
						local v66 = v12
						local v67 = v13
						local v68 = scales2[i]
						local v69 = rots[i]
						v66[i] = v68
						v67[i] = v69
					end
				end

				visibility[i] = visible
			end
		end

		for i = 1, count3 do
			if not visibility[i] or v14[i] then
				continue
			end

			local v64 = viewportFrames[i]
			local v65 = total * v6[i] + v5[i]

			if v8[i] then
				local v66 = scales2[i] - v4[i] * v63 * sin(v65)
				local v67 = v66 - v12[i]
				local v68 = v10[i]

				if v68 < v67 or v67 < -v68 then
					v12[i] = v66
					v64.Position = new(scales[i], offsets[i], v66, offsets2[i])
				end
			end

			local v66 = v7[i]

			if v66 == 0 then
				continue
			end

			local rotation = rots[i] + v66 * v63 * sin(v65 - 0.9)
			local v71 = rotation - v13[i]
			local v72 = v11[i]

			if not (v72 < v71 or v71 < -v72) then
				continue
			end

			v13[i] = rotation
			v64.Rotation = rotation
		end

		for i = 1, count4 do
			local v64 = v33[i]

			if not (not v64 or v23[v64]) then
				continue
			end

			local scale = 1 + v28[i] * v63 * (0.5 - cos(total * v29[i] + v30[i]) * 0.5)
			local v68 = scale - v32[i]
			local v69 = v31[i]

			if not (v69 < v68 or v68 < -v69) then
				continue
			end

			v32[i] = scale
			values[i].Scale = scale
		end

		for i = 1, count8 do
			v60[i](p)
		end

		for i = 1, count5 do
			local v64 = v34[i]

			if not v64 or v23[v64] then
				instances2[i].Rotation = rots2[i] + (v41[i] + v40[i] * total) % 360
			end
		end

		for i = 1, count7 do
			local v64 = guiObjects[i]
			local v65 = v35[i]

			if not (v64.Visible and (not v65 or v23[v65])) then
				continue
			end

			local v66 = frames[i]
			local v68 = floor(total * v42[i])

			if v43[i] then
				v68 %= v66 + floor(v44[i] * v42[i])
			end

			if v66 <= v68 then
				v68 = v66 - 1
			end

			if v68 == v45[i] then
				continue
			end

			v45[i] = v68
			v64.ImageRectOffset = offsets3[i][v68 + 1]
		end

		for i = 1, count9 do
			local v64 = modes[i]
			local v65 = v36[i]

			if not (not v65 or v23[v65]) then
				continue
			end

			if v64 == "Scroll" then
				local v67 = (floor(total * v52[i]) + v51[i]) % 96

				if v67 ~= v53[i] then
					v53[i] = v67
					kObj[i].Color = seqs[i][v67 + 1]
				end
			elseif v64 == "Spin" then
				kObj[i].Rotation = rots3[i] + v52[i] * total % 360
			else
				local v68 = v49[i] * v63 * sin(total * v50[i] + v51[i])
				local v69 = v68 - v53[i]

				if v69 > 0.002 or v69 < -0.002 then
					v53[i] = v68
					kObj[i].Offset = new2(Xs[i] + v47[i] * v68, Ys[i] + v48[i] * v68)
				end
			end
		end

		for i = 1, count6 do
			local v64 = (total + v38[i]) % v37[i]

			if v64 < 1.3 then
				if not v39[i] then
					v39[i] = true
					overlays[i].Visible = true
				end

				local v66 = 0.5 - cos(3.141592653589793 * v64 / 1.3) * 0.5
				gradients[i].Offset = new2(v66 * 2.4 + -1.2, 0)
			elseif v39[i] then
				v39[i] = false
				overlays[i].Visible = false
				gradients[i].Offset = new2(-1.2, 0)
			end
		end
	end

	v61.step = v58 > 0 and ticker.every(v58, step) or ticker.add(step)
end

function UIIdle.stop(p, p2)
	local v2 = v[p]

	if v2 then
		v[p] = nil
		v2.destroying:Disconnect()

		for _, conn in ipairs(v2.conns) do
			conn:Disconnect()
		end

		if v2.step then
			v2.step:Stop()
		end

		for i, shine in ipairs(v2.shines) do
			if not shine.Parent then
				continue
			end

			shine.Visible = false
			v2.sGrad[i].Offset = Vector2.new(-1.2, 0)
		end

		for _, v3 in ipairs(v2.glitter) do
			v3:Stop()
		end

		if p2 then
			store5[p] = v2
		else
			restore(v2)
		end
	elseif not p2 then
		unspin(p) -- equivalent call inferred; original call site unknown
	end
end

function UIIdle.isRunning(p)
	return v[p] ~= nil
end

return UIIdle