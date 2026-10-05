local UI = require(game.ReplicatedStorage.Modules.UI)
local UserInputService = game:GetService("UserInputService")

if not UserInputService.TouchEnabled then
	return
end

local tabs = script.Parent.Tabs
tabs.UIListLayout:Destroy()

local function update()
	local frames = {}

	for _, frame in tabs:GetChildren() do
		if frame:IsA("Frame") and frame.Visible then
			table.insert(frames, frame)
		end
	end

	table.sort(frames, function(a, b)
		return a.LayoutOrder > b.LayoutOrder
	end)
	local v = #frames >= 7 and 4 or 3
	local v2 = 40 * (v - 1)
	local count = 0
	local count2 = 0

	for _, v3 in frames do
		v3.AnchorPoint = Vector2.new(0.5, 0)
		v3.Position = UDim2.new(0.5, -count * 40, 0, v2 - count2 * 40)
		count2 += 1

		if not (v <= count2) then
			continue
		end

		count += 1
		count2 = 0
	end

	local deviceType = UI:GetDeviceType()

	if deviceType == "Mobile" then
		script.Parent.Position = UDim2.new(1, -15, 0, 10)
		script.Parent.AnchorPoint = Vector2.new(1, 0)
	elseif deviceType == "Tablet" then
		script.Parent.Position = UDim2.new(1, -15, 0.5, 0)
		script.Parent.AnchorPoint = Vector2.new(1, 0.5)

		for _, v3 in frames do
			v3.AnchorPoint = Vector2.new(0.5, 0.5)
			v3.Position = UDim2.new(
				v3.Position.X.Scale,
				v3.Position.X.Offset,
				0.5,
				v3.Position.Y.Offset - count2 * 40 * 0.5
			)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function register_button(frame)
	if frame:IsA("Frame") then
		frame:GetPropertyChangedSignal("Visible"):connect(update)
		update()
	end
end

for _, child in tabs:GetChildren() do
	register_button(child) -- equivalent call inferred; original call site unknown
end

tabs.ChildAdded:connect(register_button)
update()