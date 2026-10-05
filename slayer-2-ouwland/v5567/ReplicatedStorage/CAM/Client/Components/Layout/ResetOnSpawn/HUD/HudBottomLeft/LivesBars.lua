local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local faye = require(ReplicatedStorage.Packages.faye)
local localPlayer = Players.LocalPlayer
local info = faye.Info(0.125, Enum.EasingStyle.Sine)
local tweenInfo = TweenInfo.new(0.2)

local function screenFlash()
	local playerGui = localPlayer:FindFirstChild("PlayerGui")
	local misc

	if playerGui == nil then
		misc = false
	else
		misc = playerGui:FindFirstChild("Misc")
	end

	if not misc then
		return
	end

	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Image = "rbxassetid://101053692073571"
	imageLabel.BackgroundTransparency = 1
	imageLabel.Size = UDim2.fromScale(1, 1)
	imageLabel.ImageColor3 = Color3.new(1)
	imageLabel.Parent = misc
	TweenService:Create(imageLabel, tweenInfo, {
		ImageTransparency = 1
	}):Play()
	DebrisModule:AddItem(imageLabel, 0.3)
end

return function(object)
	if not gameSettings.IsMinigame then
		return nil
	end

	local value = object:Value(localPlayer:GetAttribute("Hearts") ~= nil)
	local value2 = object:Value(localPlayer:GetAttribute("Hearts") or 0)
	local value3 = object:Value((math.max(3, localPlayer:GetAttribute("Hearts") or 0)))
	object:Connect(localPlayer:GetAttributeChangedSignal("Hearts"), function()
		local hearts = localPlayer:GetAttribute("Hearts")

		if hearts ~= nil and value3:Get() < hearts then
			value3:Set(hearts)
		end

		if hearts ~= nil and not value2:Compare(hearts) then
			value2:Set(hearts)
		end

		if not value:Compare(hearts ~= nil) then
			value:Set(hearts ~= nil)
		end
	end)
	return object:State(function(callback, object2)
		if not callback(value) then
			return nil
		end

		local v = callback(value3)
		local v2 = value2:Get() or 0
		local v3 = {}

		for i = 1, v do
			local was = i <= v2
			local v6

			if was then
				v6 = UDim2.fromScale(1, 1)
			else
				v6 = UDim2.fromScale(0, 0)
			end

			local v5 = {
				Was = was,
				Fg = object2:Value(v6),
				Bg = 0
			}
			local v7

			if was then
				v7 = UDim2.fromScale(1.2, 1.2)
			else
				v7 = UDim2.fromScale(0.85, 0.85)
			end

			v5.Bg = object2:Value(v7)
			v3[i] = v5
		end

		object2:Connect(value2.Changed, function()
			local v4 = value2:Get() or 0

			for i = 1, v do
				local v5 = v3[i]
				local was = i <= v4

				if v5.Was == was then
					continue
				end

				v5.Was = was
				local fg = v5.Fg
				local v7

				if was then
					v7 = UDim2.fromScale(1, 1)
				else
					v7 = UDim2.fromScale(0, 0)
				end

				fg:Set(v7)
				local bg = v5.Bg
				local v8

				if was then
					v8 = UDim2.fromScale(1.2, 1.2)
				else
					v8 = UDim2.fromScale(0.85, 0.85)
				end

				bg:Set(v8)

				if not was then
					screenFlash()
				end
			end
		end)
		return object2:Create("Frame")({
			Name = "Lives",
			ZIndex = 5,
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 0.08),
			Size = UDim2.fromScale(0.45, 0.675),
			BackgroundTransparency = 1,
			object2:Create("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 4)
			}),
			object2:Iterate(v3, function(layoutOrder, p2, object3)
				return object3:Create("Frame")({
					Name = `life{layoutOrder}`,
					LayoutOrder = layoutOrder,
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					object3:Create("UIAspectRatioConstraint")({
						AspectRatio = 1
					}),
					object3:Create("ImageLabel")({
						Name = "Bg",
						BackgroundTransparency = 1,
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = object3:Animation(p2.Bg, info),
						ImageColor3 = Color3.new(0.45, 0.2, 0.2),
						Image = "rbxassetid://14484728741",
						ImageTransparency = 0.35
					}),
					object3:Create("ImageLabel")({
						Name = "Fg",
						BackgroundTransparency = 1,
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = object3:Animation(p2.Fg, info),
						ImageColor3 = Color3.new(1, 0, 0),
						Image = "rbxassetid://14484728741"
					})
				})
			end)
		})
	end)
end