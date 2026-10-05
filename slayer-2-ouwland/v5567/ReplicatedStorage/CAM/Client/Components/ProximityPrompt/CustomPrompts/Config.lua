local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local BunchaIcons = require(ReplicatedStorage2.CAM.Global.BunchaIcons)
local faye = require(ReplicatedStorage.Packages.faye)
local Config = {
	KeyCodeToTextMapping = {
		[Enum.KeyCode.LeftControl] = "Ctrl",
		[Enum.KeyCode.RightControl] = "Ctrl",
		[Enum.KeyCode.LeftAlt] = "Alt",
		[Enum.KeyCode.RightAlt] = "Alt",
		[Enum.KeyCode.F1] = "F1",
		[Enum.KeyCode.F2] = "F2",
		[Enum.KeyCode.F3] = "F3",
		[Enum.KeyCode.F4] = "F4",
		[Enum.KeyCode.F5] = "F5",
		[Enum.KeyCode.F6] = "F6",
		[Enum.KeyCode.F7] = "F7",
		[Enum.KeyCode.F8] = "F8",
		[Enum.KeyCode.F9] = "F9",
		[Enum.KeyCode.F10] = "F10",
		[Enum.KeyCode.F11] = "F11",
		[Enum.KeyCode.F12] = "F12"
	},
	ActionToImages = {
		Chat = "rbxassetid://71885888212735"
	},
	KeyHolder = {
		Positions = {
			p2 = UDim2.fromScale(0.4, 0.5),
			p1 = UDim2.fromScale(0.5, 0.5),
			p3 = UDim2.fromScale(0.3, 0.5)
		}
	},
	Holder = {
		Positions = {
			p2 = UDim2.fromScale(0.4, 0.5),
			p1 = UDim2.fromScale(0.6, 0.5),
			p3 = UDim2.fromScale(0.8, 0.5)
		}
	},
	TransitionInfo = faye.Info(0.15),
	TransitionInfoLong = faye.Info(0.3),
	TransitionInfoSmooth = faye.Info(0.4, Enum.EasingStyle.Sine),
	InTween = faye.Info(0.2, Enum.EasingStyle.Back),
	CleanDelay = 0.5,
	CoolDown = 2,
	TriggeredColor = Color3.new(1, 0.772549, 0.0901961)
}
local sounds = script:FindFirstChild("Sounds")

function Config.PlaySound(object, p, childName: string, instance)
	if not sounds then
		return
	end

	if instance then
		object:Remove(instance)
		instance:Destroy()
	end

	local child = sounds:FindFirstChild(childName)

	if not child then
		return
	end

	local clone = child:Clone()
	clone.Parent = p.Parent
	clone:Play()

	if childName == "Triggered" then
		task.delay(Config.CleanDelay, function()
			if clone then
				clone:Destroy()
			end
		end)
	else
		object:Add(clone)
	end
end

function Config.GetKeyContent(p, p2)
	if p2 == Enum.ProximityPromptInputType.Touch then
		return {
			Content = BunchaIcons.Mouse,
			Type = "Image"
		}
	end

	local gamepadKeyCode

	if p2 == Enum.ProximityPromptInputType.Gamepad then
		gamepadKeyCode = p.GamepadKeyCode
	else
		gamepadKeyCode = p.KeyboardKeyCode
	end

	local imageForKeyCode = UserInputService:GetImageForKeyCode(gamepadKeyCode)

	if imageForKeyCode ~= "" then
		return {
			Content = imageForKeyCode,
			Type = "Image"
		}
	end

	local content = Config.KeyCodeToTextMapping[gamepadKeyCode]

	if content then
		return {
			Content = content,
			Type = "Text"
		}
	end

	local stringForKeyCode = UserInputService:GetStringForKeyCode(gamepadKeyCode)

	if stringForKeyCode == "" then
		return {
			Content = gamepadKeyCode.Name,
			Type = "Text"
		}
	end

	return {
		Content = stringForKeyCode,
		Type = "Text"
	}
end

return Config