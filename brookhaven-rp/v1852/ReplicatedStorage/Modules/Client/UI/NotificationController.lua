local NotificationController = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local IntroController = require(ReplicatedStorage.Modules.Client.UI.IntroController)
local v = false
local v2 = false
local _1Message1s = game.ReplicatedStorage.RE:WaitForChild("1Message1s")
local notification = nil
local centerNotificationSmall = nil
local centerNotification = nil
local slideCenterNotification = nil
local centerNotification2 = nil
local editorMessages = nil
local v3 = nil
local flag = false
local v4 = {}
local v5 = {
	"Slow down!",
	"Whoa there, slow down!",
	"Try clicking a bit slower.",
	"You're clicking too fast!",
	"Try again in a second!"
}
local v6 = {
	"Working… please wait",
	"Still processing…",
	"One at a time…",
	"Hold on—still busy",
	"Action in progress…",
	"Still loading—try again shortly",
	"Busy… hang tight",
	"Processing… not ready yet"
}

local function showNotification(p, value: string, value2: number?, textColor: Color3?, p2: string?)
	if flag then
		return
	end

	flag = true

	if p2 and v3 then
		if v3.Data.notificationsToMute[p2] and v3.Data.notificationsToMute[p2] >= 5 then
			flag = false
			return
		else
			Remotes.fireServer("IncreaseFatigueNotificationCount", p2)
		end
	end

	pcall(function()
		p.TextColor3 = textColor
		p.Text = value or ""

		if value ~= "" then
			p.Parent.Visible = true
		end

		task.wait(value2 or 2)
		p.Parent.Visible = false
		p.Text = ""
	end)
	flag = false
end

function NotificationController.IsWarningAcknowledged(p: string)
	while not v3 do
		task.wait(0.2)
	end

	if p and v3 then
		return v3.Data.notificationsToMute[p]
	end

	return false
end

function NotificationController.AcknowledgeWarning(p: string)
	if p and v3 then
		if v3.Data.notificationsToMute[p] and v3.Data.notificationsToMute[p] >= 5 then
			return
		else
			Remotes.fireServer("IncreaseFatigueNotificationCount", p)
		end
	end
end

function NotificationController.Notify(p: string, p2: number?, color: Color3?, p3: string?)
	local textColor = color or Color3.fromRGB(0, 0, 0)
	showNotification(notification.TextMessage, p, p2, textColor, p3)
end

function NotificationController.NotifyCenterSmall(p: string, p2: number?, color: Color3?, p3: string?)
	local textColor = color or Color3.fromRGB(0, 0, 0)
	showNotification(centerNotificationSmall.TextMessage, p, p2, textColor, p3)
end

function NotificationController.SlideNotification(text: string, timeOut: number?, color: Color3?, holdTime: number?, flag2: boolean?)
	local v7 = color or Color3.fromRGB(0, 0, 0)

	if flag then
		if flag2 == false then
			return
		end

		table.insert(v4, {
			text = text,
			timeOut = timeOut,
			color = v7,
			holdTime = holdTime,
			canQueue = flag2
		})
	else
		flag = true
		slideCenterNotification.Visible = true
		slideCenterNotification.Position = UDim2.new(-1, 0, 0.12, 0)
		TweenService:Create(slideCenterNotification, TweenInfo.new(timeOut or 1), {
			Position = UDim2.new(0.5, 0, 0.12, 0)
		}):Play()
		slideCenterNotification.TextMessage.Text = text
		slideCenterNotification.TextMessage.TextColor3 = v7
		slideCenterNotification.Visible = true
		task.wait(holdTime or timeOut or 3)
		TweenService:Create(slideCenterNotification, TweenInfo.new(timeOut or 1), {
			Position = UDim2.new(2, 0, 0.12, 0)
		}):Play()
		task.wait(timeOut or 3)
		slideCenterNotification.Visible = false
		slideCenterNotification.TextMessage.Text = ""
		flag = false

		if #v4 > 0 then
			local v8 = table.remove(v4, 1)
			NotificationController.SlideNotification(v8.text, v8.timeOut, v8.color, v8.holdTime, v8.canQueue)
		end
	end
end

function NotificationController.PlaySound(soundId: string?)
	if soundId then
		local sound = Instance.new("Sound")
		sound.SoundId = soundId
		sound.Parent = SoundService
		sound.Ended:Once(function()
			sound:Destroy()
		end)
		SoundService:PlayLocalSound(sound)
	end
end

function NotificationController.NotifyCenter(p: string, p2: number?, color: Color3?, p3: string?, p4: string?)
	task.spawn(function()
		if not color then
			color = Color3.fromRGB(0, 0, 0)
		end

		if p4 then
			NotificationController.PlaySound(p4)
		end

		showNotification(centerNotification.TextMessage, p, p2, color, p3)
	end)
end

function NotificationController.NotifyCenterAlwaysVisible(p: string, p2: number?, color: Color3?, p3: string?)
	local textColor = color or Color3.fromRGB(0, 0, 0)
	showNotification(centerNotification2.TextMessage, p, p2, textColor, p3)
end

function NotificationController.NotifyClickDebounce(value: number, flag2: boolean?)
	local v7 = flag2 and v6 or v5
	local v8 = v7[math.random(1, #v7)]
	NotificationController.NotifyEditor(v8, value or 1, Color3.new(1, 0, 0))
end

function NotificationController.NotifyEditor(p: string, p2: number?, color: Color3?, p3: string?)
	task.spawn(function()
		if not color then
			color = Color3.fromRGB(255, 0, 0)
		end

		showNotification(editorMessages.Label, p, p2, color, p3)
	end)
end

function NotificationController.FrameworkInit()
	local ReplicatedDataController = require(ReplicatedStorage.Modules.Client.Data.ReplicatedDataController)
	v = ReplicatedDataController
	local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
	v2 = PanelController
end

function NotificationController.FrameworkStart()
	local Players = game:GetService("Players")
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local mainGUIHandler = playerGui:WaitForChild("MainGUIHandler")
	local mainGUIAlwaysVisible = playerGui:WaitForChild("MainGUIAlwaysVisible")
	local messages = mainGUIHandler:WaitForChild("Messages")
	local messages2 = mainGUIAlwaysVisible:WaitForChild("Messages")
	notification = messages:WaitForChild("Notification")
	centerNotificationSmall = messages:WaitForChild("CenterNotificationSmall")
	centerNotification = messages:WaitForChild("CenterNotification")
	slideCenterNotification = messages:WaitForChild("SlideCenterNotification")
	centerNotification2 = messages2:WaitForChild("CenterNotification")
	editorMessages = v2.GetPanel("NoResetGUIHandler", "AvatarEditorMenu").Instance:WaitForChild("EditorMessages")
	_1Message1s.OnClientEvent:Connect(NotificationController.Notify)
	Remotes.connect("Notify", NotificationController.Notify)
	Remotes.connect("NotifyEditor", NotificationController.NotifyEditor)
	Remotes.connect("SlideNotification", NotificationController.SlideNotification)
	Remotes.connect("CenterNotification", NotificationController.NotifyCenter)
	local v7, v8 = v.GetSessionReplicaPromise():await()

	if not v7 then
		return
	end

	if not IntroController.HasPassedIntro() then
		IntroController.OnPlayButtonPressed:Wait()
		task.wait(2)
	end

	if v8.Data.Notifications then
		NotificationController.Notify(
			v8.Data.Notifications.text,
			v8.Data.Notifications.timeOut,
			v8.Data.Notifications.color
		)
	end

	if v8.Data.NotifyEditor then
		NotificationController.NotifyEditor(
			v8.Data.NotifyEditor.text,
			v8.Data.NotifyEditor.timeOut,
			v8.Data.NotifyEditor.color
		)
	end

	if v8.Data.SlideNotification then
		NotificationController.SlideNotification(
			v8.Data.SlideNotification.text,
			v8.Data.SlideNotification.timeOut,
			v8.Data.SlideNotification.color,
			v8.Data.SlideNotification.holdTime
		)
	end

	if v8.Data.CenterNotification then
		NotificationController.NotifyCenter(
			v8.Data.CenterNotification.text,
			v8.Data.CenterNotification.timeOut,
			v8.Data.CenterNotification.color,
			v8.Data.CenterNotification.soundID
		)
	end

	Remotes.fireServer("ConsumeNotification")
	local _, v9 = v.GetClientReplicaPromise():await()

	if v9 then
		v3 = v9
	end
end

return NotificationController