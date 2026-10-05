local RunService = game:GetService("RunService")
local parent = script.Parent
local cells = script:GetAttribute("Cells")
local FPS = script:GetAttribute("FPS")
assert(cells, "PlaySprite needs a Cells attribute (Vector2) on " .. script:GetFullName())
assert(FPS and FPS > 0, "PlaySprite needs a positive FPS attribute on " .. script:GetFullName())
local v = cells.X * cells.Y
local v2 = 1 / FPS
local v3 = 0
local v4 = 0
local vectors = nil
local heartbeatConnection = nil

local function buildOffsets()
	vectors = table.create(v)
	local imageRectSize = parent.ImageRectSize

	for i = 0, v - 1 do
		vectors[i + 1] = Vector2.new(imageRectSize.X * (i % cells.X), imageRectSize.Y * (i // cells.X))
	end
end

local function advance(p)
	v4 += p

	if v4 < v2 then
		return
	end

	while v2 <= v4 do
		v4 -= v2
		v3 = (v3 + 1) % v
	end

	parent.ImageRectOffset = vectors[v3 + 1]
end

local parent2 = script.Parent
local v5 = {}
local ancestryChangedConnection = nil
local v6 = false

local function isVisible()
	local parent3 = parent2

	while parent3 do
		if parent3:IsA("GuiObject") then
			if not parent3.Visible then
				return false
			end
		elseif parent3:IsA("LayerCollector") then
			return parent3.Enabled
		end

		parent3 = parent3.Parent
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setActive(visible)
	if visible == v6 then
		return
	end

	v6 = visible

	if visible then
		if not vectors then
			buildOffsets()
		end

		v4 = 0
		heartbeatConnection = RunService.Heartbeat:Connect(advance)
	else
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function evaluate()
	setActive(isVisible()) -- equivalent call inferred; original call site unknown
end

local function watchAncestors()
	for i = #v5, 1, -1 do
		v5[i]:Disconnect()
		v5[i] = nil
	end

	local parent3 = parent2

	while parent3 do
		if parent3:IsA("GuiObject") then
			v5[#v5 + 1] = parent3:GetPropertyChangedSignal("Visible"):Connect(evaluate)
		elseif parent3:IsA("LayerCollector") then
			v5[#v5 + 1] = parent3:GetPropertyChangedSignal("Enabled"):Connect(evaluate)
			break
		end

		parent3 = parent3.Parent
	end

	evaluate() -- equivalent call inferred; original call site unknown
end

local function teardown()
	if v6 ~= false then
		v6 = false
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	for i = #v5, 1, -1 do
		v5[i]:Disconnect()
		v5[i] = nil
	end

	if ancestryChangedConnection then
		ancestryChangedConnection:Disconnect()
		ancestryChangedConnection = nil
	end

	vectors = nil
end

script.Destroying:Once(teardown)
ancestryChangedConnection = parent2.AncestryChanged:Connect(watchAncestors)
watchAncestors()