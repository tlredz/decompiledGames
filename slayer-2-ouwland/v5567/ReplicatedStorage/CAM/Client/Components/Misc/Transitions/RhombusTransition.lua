local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local currentCamera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local vector2 = Vector2.new(0.5, 0.5)
local insert = table.insert
return function(options)
	local v = options or {}
	local v2 = faye.new()
	local timeBetween = v.TimeBetween or 0.5
	local viewportSize = currentCamera.ViewportSize
	local size = v.Size or vector.create(viewportSize.X * 0.055, viewportSize.X * 0.055, 0)
	local color = v.Color or Color3.new()
	local v3 = math.round(viewportSize.X / size.X)
	local v4 = math.round(viewportSize.Y / size.y)
	local screenGui = Instance.new("ScreenGui")
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	screenGui.DisplayOrder = v.DisplayOrder or 999999
	screenGui.ScreenInsets = Enum.ScreenInsets.None
	screenGui.Name = `{script.Name}-Transition`
	screenGui.Parent = game.Players.LocalPlayer.PlayerGui
	local v5 = {}
	local v6 = 0

	for i = 0, v3 do
		for i2 = 0, v4 do
			local range = i + i2 + 1

			if v5[range] == nil then
				v5[range] = {
					Range = range,
					ContentNumb = 0,
					Values = {},
					Cells = {}
				}
				v6 = range
			end

			v5[range].ContentNumb += 1
			insert(v5[range].Cells, { i, i2 })
		end
	end

	table.sort(v5, function(a, b)
		return a.Range < b.Range
	end)

	local function buildCell(p: number, p2: number)
		local frame = Instance.new("Frame")
		frame.Size = UDim2.fromOffset(0, 0)
		frame.Rotation = 45
		local uICorner = Instance.new("UICorner")
		uICorner.Parent = frame
		uICorner.CornerRadius = UDim.new(0.25)
		frame.BackgroundColor3 = color
		frame.BorderSizePixel = 0
		frame.AnchorPoint = vector2
		frame.Position = UDim2.fromScale(
			(size.X * p + size.X * 0.5) / viewportSize.X,
			(size.Y * p2 + size.x * 0.5) / viewportSize.Y
		)
		frame.Parent = screenGui
		return frame
	end

	task.spawn(function()
		for i = 1, v6 do
			local v7 = v5[i]

			for i2 = 1, v7.ContentNumb do
				local cell = v7.Cells[i2]
				local cell2 = buildCell(cell[1], cell[2])
				v7.Values[i2] = cell2
				TweenService:Create(cell2, tweenInfo, {
					Size = UDim2.fromOffset(size.X * 1.4832396974191326, size.y * 1.4832396974191326)
				}):Play()
			end

			task.wait()
		end

		task.wait(tweenInfo.Time)

		if v.OnCovered ~= nil then
			task.spawn(v.OnCovered)
		end
	end)
	v2:Add(screenGui)

	local function fn()
		for i = 1, v6 do
			local v7 = v5[i]

			for i2 = 1, v7.ContentNumb do
				local value = v7.Values[i2]

				if value ~= nil then
					TweenService:Create(value, tweenInfo, {
						Size = UDim2.fromOffset(0, 0)
					}):Play()
				end
			end

			task.wait()
		end

		task.wait(0.5)
		v2:Destroy()
	end

	if v == nil or v.Switch == nil then
		task.delay(timeBetween, fn)
	else
		task.spawn(function()
			repeat
				task.wait()
			until v.Switch

			fn()
		end)
	end
end