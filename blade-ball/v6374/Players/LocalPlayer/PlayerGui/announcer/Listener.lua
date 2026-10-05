local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local replicatedStorage = game.ReplicatedStorage

while not workspace:GetAttribute("ClientModulesLoaded") do
	workspace:GetAttributeChangedSignal("ClientModulesLoaded"):Wait()
end

local rankedQueue = script.Parent.Parent:WaitForChild("RankedQueue")
local ServerInfo = require(ReplicatedStorage.ServerInfo)
local Replion = require(ReplicatedStorage.Packages.Replion)
local parent = script.Parent
local textBox = parent.TextBox
local uIStroke = textBox.UIStroke
local size = textBox.Size
local v = Replion.Client:WaitReplion("Data")
replicatedStorage.Remotes.SetMessage.OnClientEvent:Connect(function(p, text, duration)
	if text == nil then
		warn("COULD NOT PRINTOUT NIL TEXT", p, nil, duration)
		return
	end

	local v2 = rankedQueue.Enabled and rankedQueue.Frame.Visible and 0.15 or 0
	textBox.RichText = false
	textBox.UIStroke.Color = Color3.fromRGB(38, 35, 126)

	if string.len(text) >= 25 then
		textBox.UIAspectRatioConstraint.AspectRatio = 7
		textBox.AutomaticSize = Enum.AutomaticSize.X
	elseif textBox.AutomaticSize == Enum.AutomaticSize.X then
		textBox.UIAspectRatioConstraint.AspectRatio = 7
		textBox.AutomaticSize = Enum.AutomaticSize.None
		task.wait()
		textBox.Size = size
	end

	if p == 0 then
		textBox.Position = UDim2.fromScale(0.5, v2 + 0.09285714285714286)
		textBox.Text = text
		TweenService:Create(textBox, TweenInfo.new(1), {
			TextTransparency = 0
		}):Play()
		TweenService:Create(uIStroke, TweenInfo.new(1), {
			Transparency = 0
		}):Play()
	elseif p == 1 then
		textBox.Position = UDim2.fromScale(0.5, v2 + 0.09285714285714286)
		TweenService:Create(textBox, TweenInfo.new(1), {
			TextTransparency = 0
		}):Play()
		TweenService:Create(uIStroke, TweenInfo.new(1), {
			Transparency = 0
		}):Play()
		textBox.Text = text
	elseif p == 5 then
		textBox.Position = UDim2.fromScale(0.5, v2 + 0.12380952380952381)
		textBox.Text = text
		task.wait(duration)
		TweenService:Create(textBox, TweenInfo.new(1), {
			TextTransparency = 1
		}):Play()
		TweenService:Create(uIStroke, TweenInfo.new(1), {
			Transparency = 1
		}):Play()
	elseif p == 6 then
		textBox.RichText = true
		textBox.UIStroke.Color = Color3.fromRGB(30, 54, 32)
		textBox.Position = UDim2.fromScale(0.5, v2 + 0.09285714285714286)
		textBox.Text = text
		TweenService:Create(textBox, TweenInfo.new(0.5), {
			TextTransparency = 0
		}):Play()
		TweenService:Create(uIStroke, TweenInfo.new(0.5), {
			Transparency = 0
		}):Play()
	else
		textBox.Position = UDim2.fromScale(0.5, v2 + 0.09285714285714286)
		textBox.Text = text
		task.wait(duration)
		TweenService:Create(textBox, TweenInfo.new(1), {
			TextTransparency = 1
		}):Play()
		TweenService:Create(uIStroke, TweenInfo.new(1), {
			Transparency = 1
		}):Play()
	end
end)
local hookUpHumanoid

hookUpHumanoid = function()
	if ServerInfo.isMedalServer() then
		return
	end

	local humanoid = (game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()):WaitForChild("Humanoid")
	local kills = v:Get("Kills")

	if humanoid and kills < 1 then
		local diedConnection = nil
		diedConnection = humanoid.Died:Connect(function()
			diedConnection:Disconnect()
			hookUpHumanoid()
			local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
			TweenService:Create(script.Parent.tip, tweenInfo, {
				TextTransparency = 0,
				TextStrokeTransparency = 0
			}):Play()
			task.wait(3)
			local tweenInfo2 = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
			TweenService:Create(script.Parent.tip, tweenInfo2, {
				TextTransparency = 1,
				TextStrokeTransparency = 1
			}):Play()
		end)
	end
end

hookUpHumanoid()
local dav = script.Parent.Dav
replicatedStorage.Remotes.ProServerNoti.OnClientEvent:Connect(function(p)
	if p == "nWins" then
		dav.Text = "Not enough wins to access."
		TweenService:Create(dav, TweenInfo.new(1), {
			TextTransparency = 0
		}):Play()
		task.wait(4)
		TweenService:Create(dav, TweenInfo.new(1), {
			TextTransparency = 1
		}):Play()
	elseif p == "tping" then
		dav.Text = "Teleporting"
		TweenService:Create(dav, TweenInfo.new(1), {
			TextTransparency = 0
		}):Play()
	end
end)
local ServerInfo2 = require(ReplicatedStorage.ServerInfo)

if ServerInfo2.isDungeonsLobbyServer() then
	parent.Enabled = false
end