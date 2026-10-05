local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local ContentProvider = game:GetService("ContentProvider")
game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(packages.Net)
local controllers = ReplicatedStorage:WaitForChild("Controllers")
local SoundController = require(controllers.SoundController)
local FFlags = require(ReplicatedStorage.Packages.FFlags)
require(ReplicatedStorage.Packages.Gradients)
local CreateTween = require(ReplicatedStorage.Packages.CreateTween)
local CustomRichTextController = require(ReplicatedStorage.Controllers.CustomRichTextController)
local playerGui = Players.LocalPlayer.PlayerGui
local notification = playerGui:WaitForChild("Notification").Notification
local template = notification.Template
local remoteEvent = Net:RemoteEvent("NotificationService/Notify")
local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear)
local position = notification.Position
local v = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function applyNotificationOffset()
	notification.Position = position - UDim2.fromOffset(0, v)
end

local NotificationController = {}

local function applyNotificationText(instance, text: string)
	if string.find(text, "<image", 1, true) then
		CustomRichTextController.cleanup(instance)
		instance.Text = text
		instance:AddTag("RicherText")
	else
		instance:RemoveTag("RicherText")
		CustomRichTextController.apply(instance, text)
	end
end

function NotificationController.SetBottomOffset(_, value: number?)
	v = math.max(0, value or 0)
	applyNotificationOffset() -- equivalent call inferred; original call site unknown
end

function NotificationController.Error(_, p: string)
	NotificationController:Notify(`<font color="#FA0103">{p}</font>`, 5, "Sounds.Sfx.Error")
end

function NotificationController.Success(_, p: string)
	NotificationController:Notify(`<font color="#92FF67">{p}</font>`, 5, "Sounds.Sfx.Success")
end

local v2 = {}

function NotificationController:Notify(text: string, duration: number?, p2: string?, p3: string?, p4: number?, p5: string?, flag: boolean?)
	task.spawn(function()
		duration = duration or 5

		if flag and p5 ~= nil and v2[p5] then
			v2[p5]:Destroy()
			v2[p5] = nil
		elseif text == "" then
			if p2 then
				SoundController:PlaySound(p2)
			end
		else
			local v3

			if p5 == nil then
				v3 = false
			else
				v3 = v2[p5]
			end

			if v3 then
				if v3:IsDescendantOf(playerGui) then
					applyNotificationText(v3, text)
					return
				else
					v2[p5] = nil
				end
			end

			local clone = template:Clone()

			if p5 ~= nil then
				v2[p5] = clone
			end

			if p2 then
				SoundController:PlaySound(p2)
			end

			clone.Visible = true

			if p3 == "Top" then
				clone.Size = UDim2.fromScale(1, 0.3)
			end

			if p3 == "Top" and p4 and FFlags:GetInstant("Messages/ShowIconV2", true) and text ~= "" then
				local uDim = UDim2.fromScale(0, 0.4)
				local imageLabel = Instance.new("ImageLabel")
				imageLabel.BackgroundTransparency = 1
				imageLabel.Size = UDim2.fromScale(1, 1)
				imageLabel.SizeConstraint = Enum.SizeConstraint.RelativeYY
				imageLabel.Position = uDim + UDim2.fromOffset(-12, 0)
				imageLabel.AnchorPoint = Vector2.new(1, 0.5)
				imageLabel.Image = `rbxthumb://type=AvatarHeadShot&id={p4}&w=420&h=420`
				imageLabel.Parent = clone
				local uICorner = Instance.new("UICorner")
				uICorner.CornerRadius = UDim.new(0.12, 0)
				uICorner.Parent = imageLabel
				clone.AutomaticSize = Enum.AutomaticSize.X
				clone.Size = UDim2.fromScale(0, clone.Size.Y.Scale)
			end

			applyNotificationText(clone, text)
			local parent

			if p3 == "Top" then
				parent = playerGui:WaitForChild("TopNotification").TopNotification
			else
				parent = notification
			end

			clone.Parent = parent
			task.wait(duration)

			if clone:IsDescendantOf(playerGui) then
				for _, label in clone:GetChildren() do
					if not label:IsA("TextLabel") then
						continue
					end

					CreateTween(clone, tweenInfo, {
						TextTransparency = 1
					})
					CreateTween(clone.UIStroke, tweenInfo, {
						Transparency = 1
					})
				end

				task.wait(tweenInfo.Time)
				clone:Destroy()
			end

			if p5 ~= nil and v2[p5] == clone then
				v2[p5] = nil
			end
		end
	end)
end

function NotificationController.Start(_)
	task.spawn(function()
		ContentProvider:PreloadAsync({ script.ImageLabel1, script.ImageLabel2, script.ImageLabel3 })
	end)
	task.spawn(function()
		if not UserInputService:GetLastInputType() then
			UserInputService.LastInputTypeChanged:Wait()
		end

		if UserInputService.PreferredInput ~= Enum.PreferredInput.Touch then
			return
		end

		local v3 = (GuiService:IsTenFootInterface() and 100 or 60) + 5 + 5
		notification.AnchorPoint = Vector2.new(0.5, 1)
		position = UDim2.fromScale(0.5, 1) - UDim2.fromOffset(0, v3)
		applyNotificationOffset() -- equivalent call inferred; original call site unknown
	end)
	remoteEvent.OnClientEvent:Connect(function(...)
		NotificationController:Notify(...)
	end)
	local poll = playerGui:WaitForChild("TopUI").Frame.Poll
	local countdown = playerGui:WaitForChild("TopUI").Frame.Countdown

	local function onTopbarInsetUpdate()
		local total = 0

		if poll.Visible then
			total += poll.AbsoluteSize.Y - poll.Template.AbsoluteSize.Y
		end

		if countdown.Visible then
			total += countdown.AbsoluteSize.Y
		end

		local topNotification = playerGui:WaitForChild("TopNotification")
		topNotification.TopNotification.Position = UDim2.fromScale(0.5, 0.075) + UDim2.fromOffset(0, total)
	end

	GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(onTopbarInsetUpdate)
	countdown:GetPropertyChangedSignal("AbsoluteSize"):Connect(onTopbarInsetUpdate)
	countdown:GetPropertyChangedSignal("Visible"):Connect(onTopbarInsetUpdate)
	poll:GetPropertyChangedSignal("AbsoluteSize"):Connect(onTopbarInsetUpdate)
	poll:GetPropertyChangedSignal("Visible"):Connect(onTopbarInsetUpdate)
	onTopbarInsetUpdate()
end

return NotificationController