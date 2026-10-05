local localPlayer = game.Players.LocalPlayer
local mouse = localPlayer:GetMouse()
local RunService = game:GetService("RunService")
local renderStepped = RunService.RenderStepped
local UserInputService = game:GetService("UserInputService")
local UI = require(game.ReplicatedStorage.Modules.UI)
local parent = script.Parent
local flag = false
local flag2 = false
local flag3 = false
local clone = nil

local function get_percent(p)
	return (p - 0.35) / 3.65
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function step(p, p2)
	return p - p % p2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function get_mover_value(p)
	if p.Y > 0.8 then
		return 1
	end

	if p.Y < -0.8 then
		return -1
	end

	return 0
end

parent.Equipped:connect(function()
	clone = script.Scaler:Clone()
	clone.Parent = localPlayer.PlayerGui
	local frame = clone:WaitForChild("Frame")
	local dragger = frame:WaitForChild("Dragger")
	local currentScale = frame:WaitForChild("CurrentScale")
	local growthScale = localPlayer.Character:GetAttribute("GrowthScale") or 1
	flag3 = false
	local connections = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update_label()
		currentScale.Text = "Scale: " .. math.round(growthScale * 100) .. "%"
	end

	local function set_dragger_position(p, p2)
		local v = 0.35 + 3.65 * p
		dragger.Position = dragger.Position:Lerp(UDim2.new(p, 0, 0.5, 0), p2 * 15)

		if v ~= growthScale and not flag then
			script.Parent.UpdateScale:FireServer(v)
			flag = true
			task.delay(0.15, function()
				flag = false
			end)
		end

		growthScale = v
		update_label() -- equivalent call inferred; original call site unknown
		return v
	end

	dragger.Position = UDim2.new((growthScale - 0.35) / 3.65, 0, 0.5, 0)
	update_label() -- equivalent call inferred; original call site unknown
	dragger.MouseButton1Down:connect(function()
		if flag2 then
			return
		end

		if flag then
			flag2 = true

			repeat
				task.wait()
			until not flag

			flag2 = false
		end

		flag = true
		flag3 = true
		task.delay(0.15, function()
			flag = false
		end)
		local v = 1

		while flag3 do
			local v2 = renderStepped:wait()
			local X = frame.AbsoluteSize.X
			local v3 = frame.AbsolutePosition.X + X * 0.5
			local v4 = math.clamp((mouse.X - v3) / X, -0.5, 0.5) + 0.5
			v = set_dragger_position(v4 - v4 % 0.05, v2)
		end

		repeat
			task.wait()
		until not flag

		script.Parent.UpdateScale:FireServer(v)
	end)
	dragger.MouseButton1Up:connect(function()
		flag3 = false
	end)
	frame:WaitForChild("Default").MouseButton1Down:connect(function()
		growthScale = 1
		dragger.Position = UDim2.new((growthScale - 0.35) / 3.65, 0, 0.5, 0)
		update_label() -- equivalent call inferred; original call site unknown
		script.Parent.UpdateScale:FireServer(1)
	end)
	clone:WaitForChild("VR"):WaitForChild("Default").MouseButton1Down:connect(function()
		growthScale = 1
		dragger.Position = UDim2.new((growthScale - 0.35) / 3.65, 0, 0.5, 0)
		update_label() -- equivalent call inferred; original call site unknown
		script.Parent.UpdateScale:FireServer(1)
	end)
	local total = 0
	local v = 0
	table.insert(connections, UserInputService.InputChanged:connect(function(p, p2)
		if not p2 and p.KeyCode == Enum.KeyCode.Thumbstick2 then
			v = get_mover_value(p.Position)
		end
	end))
	table.insert(connections, renderStepped:connect(function(p)
		total += p

		if total > 0.15 then
			total = 0
			set_dragger_position(math.clamp((growthScale - 0.35) / 3.65 + v * 0.05, 0, 1), 0.06666666666666667)
		end
	end))
	parent.Unequipped:Once(function()
		for _, connection in connections do
			connection:disconnect()
		end

		connections = nil
	end)
	UI:Bind(frame.Default)
end)
mouse.Button1Up:connect(function()
	flag3 = false
end)
parent.Unequipped:connect(function()
	if clone then
		flag3 = false
		clone:Destroy()
		clone = nil
	end
end)