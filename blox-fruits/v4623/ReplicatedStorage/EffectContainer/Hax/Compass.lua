local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Maid = require(game.ReplicatedStorage.Util.Maid)
local maid = Maid.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function tweenIfSupported(p, tweenInfo, items)
	pcall(function()
		local v = {}

		for k, item in pairs(items) do
			local v2 = k

			if not pcall(function()
				p[v2] = p[v2]
			end) then
				continue
			end

			v[k] = item
		end

		if next(v) ~= nil then
			TweenService:Create(p, tweenInfo, v):Play()
		end
	end)
end

local burstCompass

burstCompass = function(instance, value: number?, point: Vector2?, p, p2)
	if (value or 0) > 4 then
		return
	end

	local guiObject = p2 or instance:FindFirstChild("Frame") or instance

	if not guiObject:IsA("GuiObject") then
		return
	end

	local v = point or guiObject.AbsolutePosition + guiObject.AbsoluteSize / 2
	local absoluteSize = guiObject.AbsoluteSize
	local v2 = (value or 0) >= 1 and 2 or 5

	for i = 1, v2 do
		local v3 = i
		task.delay(0, function()
			local clone = guiObject:Clone()
			clone.Name = "CompassBurstClone"
			clone.AnchorPoint = Vector2.new(0.5, 0.5)
			clone.Position = UDim2.fromOffset(v.X, v.Y)
			clone.Size = UDim2.fromOffset(absoluteSize.X, absoluteSize.Y)
			clone.ZIndex = math.max(clone.ZIndex, guiObject.ZIndex + 15)
			clone.Visible = true

			for i2, guiObject2 in ipairs(clone:GetDescendants()) do
				if guiObject2:IsA("GuiButton") then
					guiObject2.Active = false
					guiObject2.AutoButtonColor = false
				elseif guiObject2:IsA("GuiObject") then
					guiObject2.Active = false
				end
			end

			local parent = p or Instance.new("ScreenGui")

			if not p then
				parent.Name = "CompassBurstLayer"
				parent.IgnoreGuiInset = true
				parent.DisplayOrder = 1000
				parent.ResetOnSpawn = false
				parent.Parent = game.Players.LocalPlayer.PlayerGui
				task.delay(3, function()
					if parent.Parent then
						parent:Destroy()
					end
				end)
			end

			clone.Parent = parent
			maid:GiveTask(clone)
			local v5 = v3 / v2 * 3.141592653589793 * 2 + math.random() * 0.45
			local v6 = 120 + math.random(80, 360)
			local uDim = UDim2.fromOffset(v.X + math.cos(v5) * v6, v.Y + math.sin(v5) * v6)
			local tweenInfo = TweenInfo.new(
				0.45 + math.random() * 0.35,
				Enum.EasingStyle.Quart,
				Enum.EasingDirection.Out
			)
			task.spawn(function()
				local v7 = math.random(-300, 300)

				while clone.Parent do
					clone.Rotation += v7 * task.wait()
				end
			end)
			tweenIfSupported(clone, tweenInfo, {
				Position = uDim
			}) -- equivalent call inferred; original call site unknown
			tweenIfSupported(clone, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				BackgroundTransparency = 1,
				TextTransparency = 1,
				ImageTransparency = 1
			}) -- equivalent call inferred; original call site unknown

			for i2, descendant in ipairs(clone:GetDescendants()) do
				tweenIfSupported(descendant, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					BackgroundTransparency = 1,
					TextTransparency = 1,
					TextStrokeTransparency = 1,
					ImageTransparency = 1,
					Transparency = 1
				}) -- equivalent call inferred; original call site unknown
			end

			task.delay(0.18, function()
				burstCompass(instance, (value or 0) + 1, Vector2.new(uDim.X.Offset, uDim.Y.Offset), parent, guiObject)
			end)
			task.delay(2, function()
				if clone.Parent then
					clone:Destroy()
				end
			end)
		end)
	end
end

return function(p)
	if p.Stage == "Start" then
		local main = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Main")
		local clone = game.ReplicatedStorage.GuideModule.HackedCompass:Clone()
		clone.Parent = main
		local compass = main:WaitForChild("Compass")
		maid:GiveTask(clone)
		maid:GiveTask(compass:GetPropertyChangedSignal("Visible"):Connect(function()
			if compass.Visible then
				compass.Visible = false
			end
		end))
		compass.Visible = false
		maid:GiveTask(function()
			task.delay(1, function()
				compass.Visible = true
			end)
		end)
		maid:GiveTask(task.spawn(function()
			local map = workspace:FindFirstChild("Map")

			while task.wait() do
				local character = game.Players.LocalPlayer.Character
				local position = character and character:GetPivot().Position

				if not position then
					continue
				end

				local heavenDimension = map:FindFirstChild("HeavenDimension")

				if not heavenDimension then
					continue
				end

				local center = heavenDimension:FindFirstChild("Center", true)

				if not center then
					continue
				end

				if (position - center.Position).Magnitude > 2000 then
					clone.Visible = true
				else
					clone.Visible = false
				end
			end
		end))
		local flag = false
		maid:GiveTask(clone.Frame.Button.TextButton.Activated:Connect(function()
			if flag then
				return
			end

			burstCompass(clone)
			flag = true
			task.delay(10, function()
				flag = false
			end)
			assert(ReplicatedStorage.Remotes:FindFirstChild("AprilFOOLS")):FireServer("CompassClicked")
		end))
	elseif p.Stage == "End" then
		maid:DoCleaning()
	end
end