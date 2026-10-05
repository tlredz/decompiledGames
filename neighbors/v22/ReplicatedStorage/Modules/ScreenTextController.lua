local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ScreenTextController = {}
ScreenTextController.activeLabels = {}

function ScreenTextController.Init(p, screenGui, templateTextLabel)
	p.ScreenGui = screenGui
	templateTextLabel.Visible = false
	templateTextLabel.Active = false
	templateTextLabel.AutoLocalize = false
	templateTextLabel.TextWrapped = false
	p.TemplateTextLabel = templateTextLabel
	p.Random = Random.new()

	if screenGui.AbsoluteSize.X == 0 or screenGui.AbsoluteSize.Y == 0 then
		RunService.RenderStepped:Wait()
	end

	return p
end

function ScreenTextController:Burst(p: number, items, items2, p2: number, p3: number, p4: number, duration: number?)
	if not (self.ScreenGui and self.TemplateTextLabel) or (next(items) == nil or next(items2) == nil) then
		return
	end

	if p3 < p2 then
		p3, p2 = p2, p3
	end

	local v = p2 < 1 and 1 or p2
	local v2 = p3 < 1 and 1 or p3
	local v3 = p4 <= 0 and 0.75 or p4

	for _ = 1, p do
		self:_spawnOne(items, items2, v, v2, v3)

		if duration and duration > 0 then
			task.wait(duration)
		end
	end
end

function ScreenTextController:BurstForDuration(p: number, items, items2, p2: number, p3: number, p4: number, duration: number?)
	if not (self.ScreenGui and self.TemplateTextLabel) or p <= 0 then
		return
	end

	if next(items) == nil or next(items2) == nil then
		return
	end

	if p3 < p2 then
		p3, p2 = p2, p3
	end

	local v = p2 < 1 and 1 or p2
	local v2 = p3 < 1 and 1 or p3
	local v3 = p4 <= 0 and 0.75 or p4
	task.spawn(function()
		local lastTime = os.clock()

		while os.clock() - lastTime < p do
			self:_spawnOne(items, items2, v, v2, v3)

			if duration and duration > 0 then
				task.wait(duration)
			else
				RunService.RenderStepped:Wait()
			end
		end
	end)
end

function ScreenTextController.Clear(p)
	for k in next, p.activeLabels, nil do
		if k then
			k:Destroy()
		end
	end

	table.clear(p.activeLabels)
end

function ScreenTextController:_spawnOne(list, list2, p: number, p2: number, duration: number)
	local screenGui = self.ScreenGui
	local templateTextLabel = self.TemplateTextLabel

	if not (screenGui and templateTextLabel) then
		return
	end

	local absoluteSize = screenGui.AbsoluteSize

	if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
		return
	end

	local clone = templateTextLabel:Clone()
	clone.Visible = true
	clone.Parent = screenGui
	clone.AnchorPoint = Vector2.new(0.5, 0.5)
	clone.BackgroundTransparency = 1
	clone.Text = list[self.Random:NextInteger(1, #list)]
	clone.TextScaled = false
	clone.TextSize = self.Random:NextInteger(p, p2)
	clone.TextColor3 = list2[self.Random:NextInteger(1, #list2)]
	local v = math.max(10, absoluteSize.X - 10)
	local v2 = math.max(10, absoluteSize.Y - 10)
	local integer = self.Random:NextInteger(10, v)
	local integer2 = self.Random:NextInteger(10, v2)
	clone.Position = UDim2.fromScale(integer / absoluteSize.X, integer2 / absoluteSize.Y)
	clone.TextTransparency = 1
	clone.TextStrokeTransparency = 1
	TweenService:Create(clone, TweenInfo.new(0.12), {
		TextTransparency = 0,
		TextStrokeTransparency = 0.25
	}):Play()
	local v3 = (integer2 - self.Random:NextInteger(8, 24)) / absoluteSize.Y
	local v4 = (integer + self.Random:NextInteger(-12, 12)) / absoluteSize.X
	local tween = TweenService:Create(clone, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(v4, v3),
		TextTransparency = 1,
		TextStrokeTransparency = 1
	})
	self.activeLabels[clone] = true
	tween.Completed:Connect(function()
		if clone then
			self.activeLabels[clone] = nil
			clone:Destroy()
		end
	end)
	task.delay(0.05, function()
		tween:Play()
	end)
end

return ScreenTextController