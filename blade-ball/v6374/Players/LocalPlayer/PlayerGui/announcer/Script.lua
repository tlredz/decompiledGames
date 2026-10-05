local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage2:WaitForChild("UserInputService"))
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
local playerGui = Players.LocalPlayer.PlayerGui
local bossUI = playerGui:WaitForChild("BossUI")
local monthlyWins = playerGui:WaitForChild("MonthlyWins")
local parent = script.Parent
local standoff = parent.Standoff
local standoffShadow = parent.StandoffShadow
local flag = false
local v = {
	"A",
	"E",
	"I",
	"O",
	"U"
}
local uDim = UDim2.fromScale(0.5, 0.117)
local uDim2 = UDim2.fromScale(0.5, 0.18)

local function standoffText()
	local elementalNotifications = script.Parent.Parent:FindFirstChild("ElementalNotifications")

	if elementalNotifications then
		elementalNotifications.Enabled = false
	end

	local clone = standoff:Clone()
	local clone2 = standoffShadow:Clone()
	clone.Visible = true
	clone2.Visible = true
	clone.Parent = standoff.Parent
	clone2.Parent = clone.Parent
	Debris:AddItem(clone, 5)
	Debris:AddItem(clone2, 5)
	local v2 = {
		TextTransparency = 0,
		TextStrokeTransparency = 0
	}
	TweenService:Create(clone, tweenInfo, v2):Play()
	TweenService:Create(clone2, tweenInfo, v2):Play()
	ReplicatedStorage.Misc.ShowdownThuds.Boom:Play()
	task.wait(1)
	TweenService:Create(clone, tweenInfo, {
		Size = UDim2.fromScale(0, 0)
	}):Play()
	TweenService:Create(clone2, tweenInfo, {
		Size = UDim2.fromScale(0, 0)
	}):Play()
	ReplicatedStorage.Misc.ShowdownThuds.Boom2:Play()
	local elementalNotifications2 = script.Parent.Parent:FindFirstChild("ElementalNotifications")

	if elementalNotifications2 then
		elementalNotifications2.Enabled = true
	end
end

local function winnertext(text: string)
	local elementalNotifications = script.Parent.Parent:FindFirstChild("ElementalNotifications")

	if elementalNotifications then
		elementalNotifications.Enabled = false
	end

	local winner = script.Parent.Winner
	local clone = winner:Clone()
	local positionChangedConnection = winner:GetPropertyChangedSignal("Position"):Connect(function()
		clone.Position = winner.Position
	end)
	clone.Text = text
	clone.Parent = script.Parent
	Debris:AddItem(clone, 5)
	TweenService:Create(clone, tweenInfo, {
		TextTransparency = 0,
		TextStrokeTransparency = 0
	}):Play()
	winner.Winner:Play()
	task.wait(0.2)
	local clone2 = winner.Uno:Clone()
	local clone3 = winner.Dos:Clone()
	clone2.Parent = clone
	clone3.Parent = clone
	Debris:AddItem(clone2, 4)
	Debris:AddItem(clone3, 4)
	TweenService:Create(clone2, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true, 0), {
		Size = UDim2.fromScale(0.2, 1.75)
	}):Play()
	TweenService:Create(clone2, TweenInfo.new(0.8, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0), {
		Rotation = 210
	}):Play()
	task.wait(0.3)
	TweenService:Create(clone3, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true, 0), {
		Size = UDim2.new(0.15, 0, 1.75, 0)
	}):Play()
	TweenService:Create(clone3, TweenInfo.new(0.7, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0), {
		Rotation = -160
	}):Play()
	task.wait(4)
	local tween = TweenService:Create(clone, tweenInfo, {
		TextTransparency = 1,
		TextStrokeTransparency = 1
	})
	tween:Play()
	tween.Destroying:Once(function()
		positionChangedConnection:Disconnect()
	end)
	local elementalNotifications2 = script.Parent.Parent:FindFirstChild("ElementalNotifications")

	if elementalNotifications2 then
		elementalNotifications2.Enabled = true
	end
end

local function teamEliminated(p: string, textColor: Color3)
	local elementalNotifications = script.Parent.Parent:FindFirstChild("ElementalNotifications")

	if elementalNotifications then
		elementalNotifications.Enabled = false
	end

	local teamEliminated2 = script.Parent.TeamEliminated
	local clone = teamEliminated2:Clone()
	local positionChangedConnection = teamEliminated2:GetPropertyChangedSignal("Position"):Connect(function()
		clone.Position = teamEliminated2.Position
	end)
	clone.Text = string.upper((`{p} team eliminated!`))
	clone.TextColor3 = textColor
	clone.Parent = script.Parent
	Debris:AddItem(clone, 5)
	TweenService:Create(clone, tweenInfo, {
		TextTransparency = 0,
		TextStrokeTransparency = 0
	}):Play()
	task.wait(4)
	local tween = TweenService:Create(clone, tweenInfo, {
		TextTransparency = 1,
		TextStrokeTransparency = 1
	})
	tween:Play()
	tween.Destroying:Once(function()
		positionChangedConnection:Disconnect()
	end)
	local elementalNotifications2 = script.Parent.Parent:FindFirstChild("ElementalNotifications")

	if elementalNotifications2 then
		elementalNotifications2.Enabled = true
	end
end

ReplicatedStorage.Remotes.StandoffStart.OnClientEvent:Connect(standoffText)
ReplicatedStorage.Remotes.WinnerText.OnClientEvent:Connect(winnertext)
ReplicatedStorage.Remotes.TeamEliminated.OnClientEvent:Connect(teamEliminated)

local function updateAnnouncerPosition()
	local killed = parent.Killed
	local uDim3

	if bossUI.Enabled then
		uDim3 = UDim2.fromScale(0.5, 0.119) + UDim2.fromOffset(
			0,
			not UserInputService.KeyboardEnabled and 0 or GuiService.TopbarInset.Height
		)
	elseif monthlyWins.Enabled then
		uDim3 = UDim2.fromScale(0.5, 0.3)
	else
		uDim3 = UDim2.fromScale(0.5, 0.119)
	end

	killed.Position = uDim3
end

bossUI:GetPropertyChangedSignal("Enabled"):Connect(updateAnnouncerPosition)
monthlyWins:GetPropertyChangedSignal("Enabled"):Connect(updateAnnouncerPosition)
ReplicatedStorage.Remotes.Killed.OnClientEvent:Connect(function(p: string)
	local killed = parent.Killed
	updateAnnouncerPosition()
	killed.Text = `- You eliminated {p}! -`
	ReplicatedStorage.Misc.KillSFXNew:Play()
	TweenService:Create(killed, tweenInfo, {
		TextTransparency = 0,
		TextStrokeTransparency = 0
	}):Play()
	task.wait(2)
	TweenService:Create(killed, tweenInfo, {
		TextTransparency = 1,
		TextStrokeTransparency = 1
	}):Play()
end)
ReplicatedStorage.Remotes.BallDamaged.OnClientEvent:Connect(function(value: string, flag2: boolean?)
	while flag do
		task.wait()
	end

	flag = true
	local clone = parent.HitLabel:Clone()
	clone.Name = "animation"

	if flag2 then
		local v2 = string.sub(string.upper(value), 1, 1)
		clone.Text = `You were hit by {table.find(v, v2) and "an" or "a"} {value}!`
	else
		clone.Text = `You Hit {value}!`
	end

	clone.Position = uDim2
	clone.Parent = parent
	TweenService:Create(clone, tweenInfo, {
		TextTransparency = 0,
		TextStrokeTransparency = 0,
		Position = uDim
	}):Play()
	task.wait(2)
	local tween = TweenService:Create(clone, tweenInfo, {
		TextTransparency = 1,
		TextStrokeTransparency = 1
	})
	tween:Play()
	tween.Completed:Once(function()
		clone:Destroy()
	end)
	flag = nil
end)