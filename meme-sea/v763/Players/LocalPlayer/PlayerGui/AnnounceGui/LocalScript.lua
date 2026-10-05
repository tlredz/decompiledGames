local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local localPlayer = Players.LocalPlayer
local otherEvent = ReplicatedStorage:WaitForChild("OtherEvent")
local guiTemplate = ReplicatedStorage:WaitForChild("GuiTemplate")
local rewardScreen = ReplicatedStorage:WaitForChild("RewardScreen")
ReplicatedStorage:WaitForChild("Modules")
local colorAssets = guiTemplate:WaitForChild("ColorAssets")
local miscEvents = otherEvent:WaitForChild("MiscEvents")
local reward = rewardScreen:WaitForChild("Reward")
local makeChat = miscEvents:WaitForChild("MakeChat")
local parent = script.Parent
local container = parent:WaitForChild("Container")
local uIPadding = container:WaitForChild("UIPadding")
local templateFrame = parent:WaitForChild("Templates"):WaitForChild("TemplateFrame")
local rainbow_UIGradient2 = colorAssets:WaitForChild("Rainbow_UIGradient2")
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
local tweenInfo3 = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
local thaiLanguage = localPlayer:WaitForChild("PlayerSettings", 60):WaitForChild("ThaiLanguage")
local v = nil
local flag = false
local touchEnabled = UserInputService.TouchEnabled == true
local v2 = {
	Yellow = Color3.fromRGB(255, 230, 50),
	Green = Color3.fromRGB(100, 255, 100),
	Red = Color3.fromRGB(255, 100, 100),
	Cyan = Color3.fromRGB(100, 215, 255),
	Black = Color3.fromRGB(0, 0, 0),
	White = Color3.fromRGB(255, 255, 255),
	Purple = Color3.fromRGB(255, 0, 255),
	Blue = Color3.fromRGB(150, 150, 255),
	Orange = Color3.fromRGB(255, 125, 50)
}

local function SetupTween(textlabel, _, p)
	local v3 = p == nil and 2 or p
	textlabel:SetAttribute("LastTime", tick())
	local v4 = nil

	if container:GetAttribute("Direction") == "Right" then
		v4 = TweenService:Create(textlabel, tweenInfo, {
			Position = UDim2.new(-0.5, 0, 1, 0)
		})
		container:SetAttribute("Direction", "Left")
	elseif container:GetAttribute("Direction") == "Left" then
		v4 = TweenService:Create(textlabel, tweenInfo, {
			Position = UDim2.new(1.5, 0, 1, 0)
		})
		container:SetAttribute("Direction", "Right")
	end

	TweenService:Create(textlabel, tweenInfo2, {
		TextTransparency = 0,
		TextStrokeTransparency = 0.5
	}):Play()
	coroutine.wrap(function()
		while tick() - textlabel:GetAttribute("LastTime") < v3 do
			task.wait(1)
		end

		if v4 then
			if v == textlabel.Parent then
				v = nil
			end

			v4:Play()

			if textlabel and textlabel.Parent then
				Debris:AddItem(textlabel.Parent, 0.35)
			end
		end
	end)()
end

local function removeTags(value)
	return (value:gsub("<br%s*/>", "\n"):gsub("<[^<>]->", ""))
end

local function MatchText(p, p2)
	return p == p2
end

local function Generate_Textlabel(text, textColor, p, p2, size, p3)
	local clone = templateFrame:Clone()
	clone.Textlabel.TextColor3 = textColor
	clone.Textlabel.TextTransparency = 1
	clone.Textlabel.TextStrokeTransparency = 1
	clone.Textlabel.Text = text

	if flag then
	end

	if size then
		clone.Size = size
	else
		clone.Size = UDim2.new(1, 0, 0.025, 8)
	end

	if p2 then
		local clone_2 = rainbow_UIGradient2:Clone()
		clone_2.Parent = clone.Textlabel
	end

	if p then
		clone.Textlabel:SetAttribute("Type", p)
	end

	clone.Parent = container
	clone.Visible = true
	v = clone
	SetupTween(clone.Textlabel, text, p3)
end

local function CreateText(message, textColor, duration: number, type, rainbow, customSize, combo, message2)
	local frame = nil

	if type then
		for _, frame2 in ipairs(container:GetChildren()) do
			if not (frame2:IsA("Frame") and frame2:FindFirstChild("Textlabel") and message == frame2.Textlabel.Text and v == frame2 or frame2:IsA("Frame") and frame2:FindFirstChild("Textlabel") and v == frame2 and frame2.Textlabel:GetAttribute("Type") and frame2.Textlabel:GetAttribute("Type") == type) then
				continue
			end

			frame = frame2
			break
		end
	end

	if frame then
		if frame:IsA("Frame") and frame:FindFirstChild("Textlabel") and message == frame.Textlabel.Text and v == frame then
			task.spawn(function()
				frame.Textlabel:SetAttribute("LastTime", tick())
				local tween = TweenService:Create(frame.Textlabel, tweenInfo3, {
					Rotation = -5
				})
				tween:Play()
				tween.Completed:Wait()

				if frame and frame:FindFirstChild("Textlabel") then
					local tween2 = TweenService:Create(frame.Textlabel, tweenInfo3, {
						Rotation = 5
					})
					tween2:Play()
					tween2.Completed:Wait()

					if frame and frame:FindFirstChild("Textlabel") then
						TweenService:Create(frame.Textlabel, tweenInfo3, {
							Rotation = 0
						}):Play()
					end
				end
			end)
		elseif frame:IsA("Frame") and frame:FindFirstChild("Textlabel") and v == frame and frame.Textlabel:GetAttribute("Type") and frame.Textlabel:GetAttribute("Type") == type then
			task.spawn(function()
				frame.Textlabel:SetAttribute("LastTime", tick())
				frame.Textlabel.Text = message
				local tween = TweenService:Create(frame.Textlabel, tweenInfo3, {
					Rotation = -5
				})
				tween:Play()
				tween.Completed:Wait()

				if frame and frame:FindFirstChild("Textlabel") then
					local tween2 = TweenService:Create(frame.Textlabel, tweenInfo3, {
						Rotation = 5
					})
					tween2:Play()
					tween2.Completed:Wait()

					if frame and frame:FindFirstChild("Textlabel") then
						TweenService:Create(frame.Textlabel, tweenInfo3, {
							Rotation = 0
						}):Play()
					end
				end
			end)
		end
	elseif combo and combo == "Money/Exp" then
		Generate_Textlabel(message, textColor, type, rainbow, customSize, duration)

		if message2 then
			Generate_Textlabel(message2, textColor, type, rainbow, customSize, duration)
		end
	else
		Generate_Textlabel(message, textColor, type, rainbow, customSize, duration)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ChangeLanguage()
	if thaiLanguage.Value == true then
		flag = true
		templateFrame.Textlabel.FontFace = Font.fromId(11598121416, Enum.FontWeight.Bold)
	else
		flag = false
		templateFrame.Textlabel.Font = Enum.Font.BuilderSansBold
	end
end

local function Raid_Changed()
	if not localPlayer:GetAttribute("Raiding") then
		uIPadding.PaddingTop = UDim.new(0, 5)
	elseif touchEnabled then
		uIPadding.PaddingTop = UDim.new(0, 5)
	else
		uIPadding.PaddingTop = UDim.new(0, 55)
	end
end

ChangeLanguage() -- equivalent call inferred; original call site unknown
Raid_Changed()
thaiLanguage.Changed:Connect(ChangeLanguage)
localPlayer:GetAttributeChangedSignal("Raiding"):Connect(Raid_Changed)
reward.OnClientEvent:Connect(function(p, data)
	if p == "CustomMessage" and data then
		local message = data.Message
		local messageColor = data.MessageColor
		local duration = data.Duration
		local type = data.Type
		local rainbow = data.Rainbow
		local customSize = data.CustomSize
		local combo = data.Combo
		local message2

		if combo then
			message2 = data.Message2
		end

		if message then
			if messageColor and typeof(messageColor) == "Color3" then
				CreateText(message, messageColor, duration, type, rainbow, customSize, combo, message2)
			elseif messageColor and typeof(messageColor) == "string" and v2[messageColor] then
				CreateText(message, v2[messageColor], duration, type, rainbow, customSize, combo, message2)
			elseif messageColor then
				CreateText(message, Color3.fromRGB(255, 255, 255), duration, type, rainbow, customSize, combo, message2)
			else
				CreateText(message, Color3.fromRGB(255, 255, 255), duration, type, rainbow, customSize, combo, message2)
			end
		end
	end
end)
makeChat.Event:Connect(function(p, data)
	if p == "CustomMessage" and data then
		local message = data.Message
		local messageColor = data.MessageColor
		local duration = data.Duration
		local type = data.Type
		local rainbow = data.Rainbow
		local customSize = data.CustomSize
		local combo = data.Combo
		local message2

		if combo then
			message2 = data.Message2
		end

		if message then
			if messageColor and typeof(messageColor) == "Color3" then
				CreateText(message, messageColor, duration, type, rainbow, customSize, combo, message2)
			elseif messageColor and typeof(messageColor) == "string" and v2[messageColor] then
				CreateText(message, v2[messageColor], duration, type, rainbow, customSize, combo, message2)
			elseif messageColor then
				CreateText(message, Color3.fromRGB(255, 255, 255), duration, type, rainbow, customSize, combo, message2)
			else
				CreateText(message, Color3.fromRGB(255, 255, 255), duration, type, rainbow, customSize, combo, message2)
			end
		end
	end
end)