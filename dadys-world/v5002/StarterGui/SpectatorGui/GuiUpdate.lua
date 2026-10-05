local Players = game:GetService("Players")
local _ = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local events = ReplicatedStorage:WaitForChild("Events")
events:WaitForChild("GeneratorUpdate")
events:WaitForChild("SkillcheckUpdate")
local TweenService = game:GetService("TweenService")
local parent = script.Parent
game:GetService("UserInputService")
ReplicatedStorage:FindFirstChild("Towers")
local AdminUsers = require(ReplicatedStorage:WaitForChild("SharedUtils"):WaitForChild("AdminUsers"))
local _ = AdminUsers.Devs
ReplicatedStorage.Events:WaitForChild("SprintEvent")
game.ReplicatedStorage:WaitForChild("TrinketData")
game:GetService("StarterGui")
local position = parent.InfoFrame.FloorNumber.Position

local function onSpectatorFloorChanged(value)
	parent.InfoFrame.FloorNumber.Text = "FLOOR " .. value
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	parent.InfoFrame.FloorNumber.Position = UDim2.new(0.246, 0, 0, 0)
	TweenService:Create(parent.InfoFrame.FloorNumber, tweenInfo, {
		Position = position
	}):Play()
end

workspace.Info.Floor.Changed:Connect(onSpectatorFloorChanged)

if workspace.Info.Floor.Value > 0 then
	onSpectatorFloorChanged(workspace.Info.Floor.Value)
end

workspace.Info.FloorActive.Changed:Connect(function(p)
	if p == true then
		local v = workspace.Info.GeneratorsCompleted.Value / workspace.Info.RequiredGenerators.Value
		parent.InfoFrame.GeneratorFrame.Message.Text = "Machines Completed: " .. workspace.Info.GeneratorsCompleted.Value .. "/" .. workspace.Info.RequiredGenerators.Value
		local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
		TweenService:Create(parent.InfoFrame.GeneratorFrame.CurrentAmount, tweenInfo, {
			Size = UDim2.new(math.clamp(v, 0, 1), 0, 1, 0)
		}):Play()
	else
		parent.InfoFrame.GeneratorFrame.Message.Text = "Intermission"
		local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
		TweenService:Create(parent.InfoFrame.GeneratorFrame.CurrentAmount, tweenInfo, {
			Size = UDim2.new(0, 0, 1, 0)
		}):Play()
	end
end)

local function updateGeneratorGui()
	if workspace.Info.FloorActive.Value == true then
		local v = workspace.Info.GeneratorsCompleted.Value / workspace.Info.RequiredGenerators.Value
		parent.InfoFrame.GeneratorFrame.Message.Text = "Machines Completed: " .. workspace.Info.GeneratorsCompleted.Value .. "/" .. workspace.Info.RequiredGenerators.Value
		local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
		TweenService:Create(parent.InfoFrame.GeneratorFrame.CurrentAmount, tweenInfo, {
			Size = UDim2.new(math.clamp(v, 0, 1), 0, 1, 0)
		}):Play()
	end
end

updateGeneratorGui()
local value = 0
workspace.Info.GeneratorsCompleted.Changed:Connect(function()
	updateGeneratorGui()
	value = workspace.Info.GeneratorsCompleted.Value
end)
workspace.Info.RequiredGenerators.Changed:Connect(function()
	updateGeneratorGui()
end)
local lastTime = tick()
local v = nil
local v2 = nil
local v3 = false
workspace.Info.Message.Changed:Connect(function(text)
	if v then
		v:Pause()
		v:Destroy()
		v3 = true
	end

	if v2 then
		v2:Pause()
		v2:Destroy()
		v3 = true
	end

	parent.InfoFrame.Message.Visible = true
	parent.InfoFrame.Message.Transparency = 0.5
	parent.InfoFrame.Message.TextTransparency = 0
	lastTime = tick()
	local message = parent.InfoFrame.Message
	local _ = parent.InfoFrame.Message
	local tweenInfo = TweenInfo.new(1)
	TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, 0, false)
	v = TweenService:Create(message, tweenInfo, {
		Transparency = 1
	})
	v2 = TweenService:Create(message, tweenInfo, {
		TextTransparency = 1
	})
	parent.InfoFrame.Message.Transparency = 0.5
	parent.InfoFrame.Message.TextTransparency = 0
	parent.InfoFrame.Message.Text = text

	if text == "" then
		parent.InfoFrame.Message.Visible = false
	else
		parent.InfoFrame.Message.Visible = true
	end

	task.spawn(function()
		task.wait(3)
		local _ = parent.InfoFrame.Message.Text

		if tick() - lastTime >= 3 then
			v3 = false
			v:Play()
			v2:Play()
			task.delay(1, function()
				if v3 == false then
					parent.InfoFrame.Message.Visible = false
				end
			end)
		end
	end)
end)