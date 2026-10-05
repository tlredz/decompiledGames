local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local debris = require(ReplicatedStorage.shared.modules.fx.debris)
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local playerGui = Players.LocalPlayer.PlayerGui
local statChangeList = playerGui:WaitForChild("hud"):WaitForChild("safezone"):WaitForChild("StatChangeList")
local backpack = playerGui:WaitForChild("backpack")
local over = playerGui:WaitForChild("over", 1e999)
local GeneralUIModule = {}
local bindableEvent = Instance.new("BindableEvent")
bindableEvent.Event:Connect(function(instance, instance2)
	local destroyingConnection = nil
	local destroyingConnection2 = nil
	destroyingConnection2 = instance2.Destroying:Once(function()
		task.defer(function()
			if instance.Parent then
				instance:Destroy()
				destroyingConnection2:Disconnect()
				destroyingConnection:Disconnect()
			end
		end)
	end)
	destroyingConnection = instance.Destroying:Once(function()
		destroyingConnection2:Disconnect()
		destroyingConnection:Disconnect()
	end)
end)

function GeneralUIModule.GiveToolTip(_, _, text: string, p)
	local v = {}

	if backpack:FindFirstChild("ToolTip") then
		backpack:FindFirstChild("ToolTip"):Destroy()
	end

	v.Tip = script.toolTip:Clone()
	v.Tip.Text = text
	v.Tip.Parent = backpack
	v.Tip.Name = "ToolTip"

	if p then
		bindableEvent:Fire(v.Tip, p)
	end

	function v.Remove(_)
		if v.Tip then
			v.Tip:Destroy()
		end

		v = nil
	end

	return v
end

function GeneralUIModule.FadedBorder(_, p, p2: number, p3: number)
	if SettingsController:GetSettingValue("photosensitiveMode") then
		return
	end

	local v = p3 == nil and 0.6 or p3
	local imageTransparency = p2 == nil and 0.8 or p2
	local clone = script.ColouredBorder:Clone()

	if typeof(p) == "ColorSequence" then
		clone.UIGradient.Color = p
		clone.ImageColor3 = Color3.new(1, 1, 1)
	else
		clone.ImageColor3 = p
	end

	clone.ImageTransparency = imageTransparency
	clone.BackgroundTransparency = 1
	clone.Parent = over
	TweenService:Create(clone, TweenInfo.new(v, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 0), {
		ImageTransparency = 1
	}):Play()
	debris:AddItem(clone, v)
end

function GeneralUIModule.ListOnBottomRight(_, p: string, textColor: Color3, p2: number)
	local labels = {}

	for _, label in statChangeList:GetChildren() do
		if label:IsA("TextLabel") then
			table.insert(labels, label)
		end
	end

	for i = 1, #labels - 2 do
		labels[i]:Destroy()
	end

	local clone = script.ListStatChange:Clone()
	clone.Name = tostring(p)
	clone.Text = tostring(p)

	if textColor == nil then
		clone.TextColor3 = Color3.fromRGB(162, 162, 162)
	else
		clone.TextColor3 = textColor
	end

	clone.Size = UDim2.new(1, 0, 0, 0)
	clone.Parent = statChangeList
	TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(1, 0, 1, 0)
	}):Play()
	local v = p2 <= 0 and 5 or p2
	TweenService:Create(clone, TweenInfo.new(v, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
		TextTransparency = 1
	}):Play()
	debris:AddItem(clone, v)
end

return GeneralUIModule