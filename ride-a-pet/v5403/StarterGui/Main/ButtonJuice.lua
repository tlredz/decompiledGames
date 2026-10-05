local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BitohiUI = require(ReplicatedStorage:WaitForChild("BitohiUI"))
local spring = BitohiUI.Spring
local store = BitohiUI.Store
local _ = spring.spr
local parent = script.Parent
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local v = { 0.75, 8 }
local v2 = { 0.65, 10 }
local v3 = { 0.38, 6.5 }
local v4 = { 0.55, 5 }
local v5 = { 0.4, 7 }
local v6 = { parent:WaitForChild("OldShop") }
local v7 = {
	ProductExpander = true
}

local function skipped(button)
	if v7[button.Name] then
		return true
	end

	for _, ancestor in ipairs(v6) do
		if button:IsDescendantOf(ancestor) then
			return true
		end
	end

	local parent2 = button

	while parent2 and not parent2:IsA("LayerCollector") do
		if parent2:GetAttribute("UIJuice") == false then
			return true
		else
			parent2 = parent2.Parent
		end
	end

	if not (button.BackgroundTransparency >= 1) then
		return false
	end

	local isA = button:IsA("ImageButton")

	if isA then
		if button.Image == "" then
			isA = false
		else
			isA = button.ImageTransparency < 1
		end
	end

	local isA2 = button:IsA("TextButton")

	if isA2 then
		if button.Text == "" then
			isA2 = false
		else
			isA2 = button.TextTransparency < 1
		end
	end

	return not (isA or isA2)
end

local function closing(instance)
	local parent2 = instance.Parent

	while parent2 and not parent2:IsA("LayerCollector") do
		if parent2:GetAttribute("UIClosing") then
			return true
		else
			parent2 = parent2.Parent
		end
	end

	return false
end

local v8 = store.new()
local random = Random.new()

local function bind(button)
	if v8[button] or skipped(button) then
		return
	end

	v8[button] = true
	local v9

	if button.Parent == nil then
		v9 = false
	else
		v9 = button.Parent:FindFirstChildOfClass("UIListLayout") ~= nil
	end

	local v10 = not (CollectionService:HasTag(button, "RotateOnHover") or CollectionService:HasTag(button, "UIFloat") or CollectionService:HasTag(
		button,
		"UISpin"
	))

	if (v9 or CollectionService:HasTag(button, "EnlargeOnHover")) and not v10 then
		return
	end

	local v11 = not (v9 or CollectionService:HasTag(button, "EnlargeOnHover"))
	local v12 = nil
	local rotation = button.Rotation
	local v13 = false
	local v14 = false
	local v15 = rotation

	-- equivalent calls inferred from this helper; original call sites unknown
	local function lean()
		v15 = rotation + (random:NextInteger(0, 1) == 0 and -1 or 1) * random:NextNumber(2.5, 5.5)
		return v15
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function toScale(p, scale)
		if not v11 then
			return
		end

		v12 = v12 or spring.scale(button, "AnimScale")
		spring.to(v12, p, {
			Scale = scale
		})
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function toRotation(p, rotation2)
		if v10 then
			spring.to(button, p, {
				Rotation = rotation2
			})
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function enter()
		if closing(button) then
			return
		end

		v13 = true
		toScale(v, v14 and 0.9 or 1.07) -- equivalent call inferred; original call site unknown
		local rotation2 = lean() -- equivalent call inferred; original call site unknown
		toRotation(v4, rotation2) -- equivalent call inferred; original call site unknown
	end

	local inputEndedConnection = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function unlisten()
		if inputEndedConnection then
			inputEndedConnection:Disconnect()
			inputEndedConnection = nil
		end
	end

	local function release()
		unlisten() -- equivalent call inferred; original call site unknown

		if not v14 then
			return
		end

		v14 = false

		if closing(button) then
			return
		end

		toScale(v3, v13 and 1.07 or 1) -- equivalent call inferred; original call site unknown

		if v11 then
			if not v13 then
				toRotation(v4, rotation) -- equivalent call inferred; original call site unknown
			end
		else
			toRotation(v3, v13 and v15 or rotation) -- equivalent call inferred; original call site unknown
		end
	end

	local function leave()
		unlisten() -- equivalent call inferred; original call site unknown
		v13 = false
		v14 = false
		v15 = rotation
		toScale(v, 1) -- equivalent call inferred; original call site unknown
		toRotation(v4, rotation) -- equivalent call inferred; original call site unknown
	end

	button.MouseEnter:Connect(function()
		if UserInputService:GetLastInputType() ~= Enum.UserInputType.Touch then
			enter() -- equivalent call inferred; original call site unknown
		end
	end)
	button.MouseLeave:Connect(leave)
	button.SelectionGained:Connect(enter)
	button.SelectionLost:Connect(leave)
	button.MouseButton1Down:Connect(function()
		if closing(button) then
			return
		end

		v14 = true

		if not inputEndedConnection then
			inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
				local userInputType = input.UserInputType

				if userInputType == Enum.UserInputType.Touch or userInputType == Enum.UserInputType.MouseButton1 then
					release()
				end
			end)
		end

		toScale(v2, 0.9) -- equivalent call inferred; original call site unknown

		if v11 then
			if not v13 then
				local rotation2 = lean() -- equivalent call inferred; original call site unknown
				toRotation(v4, rotation2) -- equivalent call inferred; original call site unknown
			end
		else
			local v17 = v13 and v15 or rotation
			toRotation(v5, v17 + (v17 - rotation >= 0 and 1 or -1) * 6) -- equivalent call inferred; original call site unknown
		end
	end)
	button.MouseButton1Up:Connect(release)
end

local function watchRoot(folder)
	for _, button in ipairs(folder:GetDescendants()) do
		if button:IsA("GuiButton") then
			bind(button)
		end
	end

	folder.DescendantAdded:Connect(function(button)
		if button:IsA("GuiButton") then
			task.defer(function()
				if button.Parent then
					bind(button)
				end
			end)
		end
	end)
end

watchRoot(parent)
task.spawn(function()
	local reusable = playerGui:WaitForChild("Reusable", 30)

	if reusable then
		watchRoot(reusable)
	end
end)