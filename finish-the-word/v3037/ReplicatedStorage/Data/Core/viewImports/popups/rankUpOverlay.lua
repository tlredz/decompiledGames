local import = _G.import("romodel")
local import2 = _G.import("rankData")
local basic = _G.import("viewImports"):get("basic")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local model = import.model(basic.EmptyElement)

function model.init(data)
	local v = import2[data.OldRank] or import2.Unranked
	local v2 = import2[data.NewRank] or import2.Unranked
	return {
		Location = "Center",
		Size = UDim2.new(0.35, 0, 0.72, 0)
	}, {
		ResultLabel = import.make(basic.TextLabel, {
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1, 0, 0.125, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Text = data.Win and "WIN" or "LOSE",
			TextColor3 = Color3.fromRGB(64, 255, 62),
			StrokeWidth = 5,
			ZIndex = 2
		}),
		RankIcon = import.make(basic.ImageLabel, {
			Position = UDim2.new(0.5, 0, 0.7, 0),
			Size = UDim2.new(0.8, 0, 0.8, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Image = v.Icon
		}),
		RankUpLabel = import.make(basic.TextLabel, {
			Position = UDim2.new(0.5, 0, 0.84, 0),
			Size = UDim2.new(1, 0, 0.12, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Text = "RANK UP",
			StrokeWidth = 3
		}),
		RankNameLabel = import.make(basic.TextLabel, {
			Position = UDim2.new(0.5, 0, 0.97, 0),
			Size = UDim2.new(1, 0, 0.12, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Text = v2.DisplayName,
			TextColor3 = v2.Color,
			StrokeWidth = 3
		}),
		Flash = import.make(basic.Element, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(10, 0, 10, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			ZIndex = 10
		})
	}
end

function model.spawn(data)
	local v = import2[data.NewRank] or import2.Unranked
	data.RankIcon.ImageTransparency = 1
	data.RankUpLabel.Size = UDim2.new()
	data.RankNameLabel.Size = UDim2.new()
	TweenService:Create(data.RankIcon.Instance, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, 0, 0.35, 0),
		ImageTransparency = 0
	}):Play()
	local lastTime = tick()
	local renderSteppedConnection = nil
	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		local v2 = tick() - lastTime

		if v2 >= 0.5 then
			data.RankIcon.Rotation = 0
			renderSteppedConnection:Disconnect()
		else
			local v3 = 10 * (1 - v2 / 0.5)
			data.RankIcon.Rotation = math.sin(v2 * 38) * v3
		end
	end)
	data.ResultLabel.Size = UDim2.new()
	TweenService:Create(
		data.ResultLabel.Instance,
		TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{
			Size = UDim2.new(1, 0, 0.125, 0)
		}
	):Play()
	task.delay(0.75, function()
		TweenService:Create(
			data.ResultLabel.Instance,
			TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
			{
				Position = UDim2.new(0.5, 0, 1.5, 0)
			}
		):Play()
		TweenService:Create(
			data.RankIcon.Instance,
			TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
			{
				Size = UDim2.new(2.5, 0, 2.5, 0)
			}
		):Play()
		TweenService:Create(
			data.RankIcon.AspectRatioConstraint.Instance,
			TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
			{
				AspectRatio = 1
			}
		):Play()
		local lastTime2 = tick()
		local renderSteppedConnection2 = nil
		renderSteppedConnection2 = RunService.RenderStepped:Connect(function()
			local v2 = tick() - lastTime2

			if v2 >= 1 then
				data.RankIcon.Rotation = 0
				renderSteppedConnection2:Disconnect()
			else
				data.RankIcon.Rotation = math.sin(v2 * 40) * 28 + math.sin(v2 * 13) * 10
			end
		end)
		task.wait(0.5)
		TweenService:Create(data.Flash.Instance, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0
		}):Play()
		task.wait(0.4)
		data.RankIcon.Image = v.Icon
		data.RankIcon.Rotation = 0
		TweenService:Create(data.Flash.Instance, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 1
		}):Play()
		TweenService:Create(
			data.RankIcon.Instance,
			TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{
				Size = UDim2.new(0.8, 0, 0.8, 0)
			}
		):Play()
		TweenService:Create(
			data.RankIcon.AspectRatioConstraint.Instance,
			TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{
				AspectRatio = 1
			}
		):Play()
		local lastTime3 = tick()
		local renderSteppedConnection3 = nil
		renderSteppedConnection3 = RunService.RenderStepped:Connect(function()
			if not data.RankIcon.Instance:IsDescendantOf(game) then
				renderSteppedConnection3:Disconnect()
				return
			end

			local v2 = tick() - lastTime3
			local v3 = math.exp(-v2 * 2) * 20 + 1.2
			local v4 = math.exp(-v2 * 1.2) * 30 + 8
			data.RankIcon.Rotation = math.sin(v2 * v4) * v3
		end)
		task.wait(0.5)
		TweenService:Create(
			data.RankUpLabel.Instance,
			TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{
				Size = UDim2.new(1, 0, 0.12, 0)
			}
		):Play()
		task.wait(0.25)
		TweenService:Create(
			data.RankNameLabel.Instance,
			TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{
				Size = UDim2.new(1, 0, 0.12, 0)
			}
		):Play()
		task.wait(2)
		TweenService:Create(data.RankIcon.Instance, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Position = UDim2.new(0.5, 0, 0.45, 0),
			ImageTransparency = 1
		}):Play()
		TweenService:Create(
			data.RankUpLabel.Instance,
			TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{
				Position = UDim2.new(0.5, 0, 0.9, 0),
				TextTransparency = 1
			}
		):Play()
		TweenService:Create(data.RankUpLabel.UIStroke.Instance, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
			Transparency = 1
		}):Play()
		TweenService:Create(
			data.RankNameLabel.Instance,
			TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{
				Position = UDim2.new(0.5, 0, 1.04, 0),
				TextTransparency = 1
			}
		):Play()
		TweenService:Create(data.RankNameLabel.UIStroke.Instance, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
			Transparency = 1
		}):Play()
		task.wait(1)
		data.Ui:Destroy()
	end)
end

local model2 = import.model("ScreenGui", basic.Ui)

function model2.init(p)
	return {
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		DisplayOrder = 5,
		Name = "RankUpOverlay",
		Scale = 0.85,
		AspectRatio = 1.777,
		Location = "Center",
		Background = {
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 0.4
		},
		Content = {
			Card = import.make(model, p)
		}
	}
end

function model2.spawn(instance)
	task.delay(6.5, function()
		instance:Destroy()
	end)
end

return {
	RankUpOverlay = model2
}