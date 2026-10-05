local TweenService = game:GetService("TweenService")
local random = Random.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function fastTween(p, tweenInfo, p2)
	local tween = TweenService:Create(p, tweenInfo, p2)
	tween.Completed:Once(function()
		tween:Destroy()
	end)
	tween:Play()
	return tween
end

local function fastAudio(soundId: string, parent, value: number?, value2: number?, value3: number?)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Parent = parent
	sound.Volume = value or 0.5
	sound.PlaybackSpeed = value2 or 1
	sound.TimePosition = value3 or 0
	sound:Play()
	sound.Ended:Once(function()
		sound:Destroy()
	end)
	return sound
end

return function(parent)
	local crates = parent.Crates
	local v = nil
	local flag = false

	local function highlight(child, value: number?, value2: number?, flag2: boolean?)
		local canvas = child.Canvas
		canvas.Glow.ImageTransparency = value or 0
		fastTween(canvas.Glow, TweenInfo.new(1 / (value2 or 1), Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			ImageTransparency = 1
		}) -- equivalent call inferred; original call site unknown
		canvas.Highlight.ImageTransparency = 0.55
		fastTween(
			canvas.Highlight,
			TweenInfo.new(0.15 / (value2 or 1), Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
			{
				ImageTransparency = 1
			}
		) -- equivalent call inferred; original call site unknown

		if not flag2 then
			canvas.GroupTransparency = 0
			local tween = TweenService:Create(
				canvas,
				TweenInfo.new(1 / (value2 or 1), Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
				{
					GroupTransparency = flag and 0 or 0.5
				}
			)
			tween.Completed:Once(function()
				tween:Destroy()
			end)
			tween:Play()
		end
	end

	local grid = crates.Grid

	-- equivalent calls inferred from this helper; original call sites unknown
	local function loop()
		flag = true
		local count = 0
		task.spawn(function()
			while flag do
				count += 1
				local child = grid:FindFirstChild((`Slot{(count - 1) % 8 + 1}`))

				if v then
					local sound = Instance.new("Sound")
					sound.SoundId = "rbxassetid://6895079853"
					sound.Parent = parent
					sound.Volume = 0.2
					sound.PlaybackSpeed = 0.5
					sound.TimePosition = 0
					sound:Play()
					sound.Ended:Once(function()
						sound:Destroy()
					end)
				end

				highlight(child, 0, 0.15)
				task.wait(0.75)
			end
		end)
	end

	local v2 = {}
	local flag2 = false
	local roll

	roll = function(p2: number)
		flag2 = true
		flag = false

		for _, guiObject in grid:GetChildren() do
			if not guiObject:IsA("GuiObject") then
				continue
			end

			local tween = TweenService:Create(guiObject.Canvas, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
				GroupTransparency = 0.65
			})
			tween.Completed:Once(function()
				tween:Destroy()
			end)
			tween:Play()
		end

		local integer = random:NextInteger(4, 6)
		local child = nil

		for i = 1, integer do
			local v3 = i == integer
			local v4 = not v3 and 8 or p2

			for i2 = 1, v4 do
				local v5 = (i - 1) * 8 + i2
				local v6 = v5 ^ 2 * 0.0005 + v5 * 0.01 + 1
				child = grid:FindFirstChild((`Slot{i2}`))
				local sound = Instance.new("Sound")
				sound.SoundId = "rbxassetid://9114464537"
				sound.Parent = parent
				sound.Volume = 0.5
				sound.PlaybackSpeed = v6 * 1.5 or 1
				sound.TimePosition = 0.085
				sound:Play()
				sound.Ended:Once(function()
					sound:Destroy()
				end)
				highlight(child, 0, v6, v3 and i2 == v4)
				task.wait(0.15 / v6)
			end
		end

		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://15505714069"
		sound.Parent = parent
		sound.Volume = 0.5
		sound.PlaybackSpeed = 1
		sound.TimePosition = 0
		sound:Play()
		sound.Ended:Once(function()
			sound:Destroy()
		end)
		child.Canvas.GroupTransparency = 0
		crates.White.BackgroundTransparency = 0
		fastTween(crates.White, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
			BackgroundTransparency = 1
		}) -- equivalent call inferred; original call site unknown
		local rewardBoom = crates.RewardBoom
		local v4 = child.AbsolutePosition - crates.AbsolutePosition + child.AbsoluteSize / 2
		rewardBoom.Visible = true
		rewardBoom.Position = UDim2.fromOffset(v4.X, v4.Y)
		rewardBoom.Rotation = 0
		fastTween(rewardBoom, TweenInfo.new(3, Enum.EasingStyle.Linear), {
			Rotation = 359.9
		}) -- equivalent call inferred; original call site unknown

		for _, guiObject in rewardBoom:GetChildren() do
			if not guiObject:IsA("GuiObject") then
				continue
			end

			guiObject.ImageTransparency = guiObject.Name == "Circle" and 0.5 or 0
			local tween = TweenService:Create(
				guiObject,
				TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0.75),
				{
					ImageTransparency = 1
				}
			)
			tween.Completed:Once(function()
				tween:Destroy()
			end)
			tween:Play()
		end

		task.spawn(function()
			task.wait(1)
			rewardBoom.Visible = false
		end)
		task.wait(1)

		for _, guiObject in grid:GetChildren() do
			if not guiObject:IsA("GuiObject") then
				continue
			end

			local tween = TweenService:Create(guiObject.Canvas, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
				GroupTransparency = 0
			})
			tween.Completed:Once(function()
				tween:Destroy()
			end)
			tween:Play()
		end

		task.wait(0.5)
		flag2 = false
		local v5 = table.remove(v2, 1)

		if v5 then
			task.spawn(roll, v5.Index)
		elseif not flag then
			task.wait(1)

			if flag2 then
				return
			end

			loop() -- equivalent call inferred; original call site unknown
		end
	end

	local function addToQueue(p2: number)
		if #v2 > 0 or flag2 then
			table.insert(v2, {
				Index = p2
			})
		else
			roll(p2)
		end
	end

	flag = true
	local count = 0
	task.spawn(function()
		while flag do
			count += 1
			local child = grid:FindFirstChild((`Slot{(count - 1) % 8 + 1}`))

			if v then
				local sound = Instance.new("Sound")
				sound.SoundId = "rbxassetid://6895079853"
				sound.Parent = parent
				sound.Volume = 0.2
				sound.PlaybackSpeed = 0.5
				sound.TimePosition = 0
				sound:Play()
				sound.Ended:Once(function()
					sound:Destroy()
				end)
			end

			highlight(child, 0, 0.15)
			task.wait(0.75)
		end
	end)
	return {
		roll = roll,
		addToQueue = addToQueue,
		setVisible = function(flag3: boolean?)
			v = flag3
		end,
		getIsRolling = function()
			return flag2
		end
	}
end