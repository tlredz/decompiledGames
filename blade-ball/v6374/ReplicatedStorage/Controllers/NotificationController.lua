local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.ServerInfo)
local notifications = Players.LocalPlayer.PlayerGui:WaitForChild("Notifications")
local notifications2 = notifications:WaitForChild("Notifications")
local template = notifications2:WaitForChild("Template")
local remotes = ReplicatedStorage2.Remotes
local v2 = nil
local v3 = nil
local sine = Enum.EasingStyle.Sine
local tweenInfo = TweenInfo.new(0.2, sine)
local NotificationController = {}

function NotificationController.Start(_)
	remotes.Notification.OnClientEvent:Connect(NotificationController.sendNotification)
	_G.SendNotification = NotificationController.sendNotification
	notifications.Enabled = true
	local currentLTM = require3(ReplicatedStorage2.Shared.LTM).getCurrentLTM()

	if v.isLTMServer() and currentLTM and currentLTM.getGameMode() == "Rebirth" then
		notifications.Notifications.Position = UDim2.fromScale(0, 0.06)
		notifications.Notifications.AnchorPoint = Vector2.new(0, 0.06)
	end
end

function tweenOut(instance)
	if not instance then
		return
	end

	TweenService:Create(instance, tweenInfo, {
		TextTransparency = 1
	}):Play()
	local uIStroke = instance:FindFirstChild("UIStroke")

	if uIStroke then
		TweenService:Create(uIStroke, tweenInfo, {
			Transparency = 1
		}):Play()
	end
end

function NotificationController.SendNotification(p, p2: string, p3: number?, flag: boolean?)
	return p.sendNotification(p2, p3, flag)
end

function NotificationController.sendNotification(text: string, value: number?, flag: boolean?)
	notifications2.Visible = true
	local now = tick()
	v2 = now
	local v4 = value or 3
	local clone = template:Clone()
	local uIStroke = clone:WaitForChild("UIStroke")
	clone.Text = text

	if v.isTrainingServer() or flag then
		clone.Position = UDim2.new(0.5, 0, 0.275, 5)
	end

	if v3 and v3.Parent == notifications2 then
		tweenOut(v3)
	end

	clone.TextTransparency = 1
	uIStroke.Transparency = 1
	TweenService:Create(clone, tweenInfo, {
		TextTransparency = 0
	}):Play()
	TweenService:Create(uIStroke, tweenInfo, {
		Transparency = 0
	}):Play()
	v3 = clone
	task.delay(v4, function()
		if v2 == now and clone then
			tweenOut(clone)
			task.wait(0.4)

			if v2 == now and v3 == clone then
				v3 = nil
			end
		end
	end)
	Debris:AddItem(clone, v4 + 0.4)
	clone.Visible = true
	clone.Parent = notifications2
end

return NotificationController