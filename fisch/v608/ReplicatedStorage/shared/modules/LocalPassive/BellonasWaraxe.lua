local TweenService = game:GetService("TweenService")
game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
game:GetService("RunService")
game:GetService("Lighting")
game:GetService("GuiService")
local module = require("./PassiveHandler")
require(ReplicatedStorage.shared.modules.fx)
local ReelController = require(ReplicatedStorage.client.legacyControllers.ReelController)
local HudController = require(ReplicatedStorage.client.legacyControllers.HudController)
require(ReplicatedStorage.client.legacyControllers.ReelController.Types)
local evalColorSequence = require(ReplicatedStorage.shared.utils.evalColorSequence)
local rarities = require(ReplicatedStorage.shared.modules.library.rarities)
local fish = require(ReplicatedStorage.shared.modules.library.fish)
require(ReplicatedStorage.shared.modules.fishing.FishInstance.Types)
local allowedInputs = {
	MouseButton1 = true,
	Space = true,
	A = true,
	ButtonA = true,
	ButtonL2 = true
}
local allowedInputs2 = {
	MouseButton2 = true,
	D = true,
	ButtonY = true,
	ButtonR2 = true
}
local _ = {
	MouseButton1 = true,
	MouseButton2 = true,
	Space = true,
	A = true,
	D = true,
	ButtonA = true,
	ButtonY = true,
	ButtonL2 = true,
	ButtonR2 = true
}
local v3 = {
	Mouse = "rbxassetid://110334034485734",
	Xbox = "rbxassetid://104522092634526",
	PS = "rbxassetid://123667000286295",
	Touch = "rbxassetid://12786639297"
}
local v4 = {
	Mouse = "rbxassetid://121617671654696",
	Xbox = "rbxassetid://80366441861909",
	PS = "rbxassetid://114477797658861",
	Touch = "rbxassetid://12786639297"
}
local BellonasWaraxe = {
	NoMock = true,
	GetInputIcon = function(self, flag: boolean)
		local v5 = flag and v4 or v3

		if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
			if UserInputService:GetStringForKeyCode(Enum.KeyCode.ButtonX) == "ButtonSquare" then
				return v5.PS
			end

			return v5.Xbox
		elseif UserInputService.PreferredInput == Enum.PreferredInput.Touch then
			return v5.Touch
		else
			return v5.Mouse
		end
	end,
	PlayInputThing = function(self)
		local clone = script.BellonaInput:Clone()
		clone.divider.Size = UDim2.fromScale(0, 1)
		local content = clone.leftSide.content
		clone.leftSide.bg.Size = UDim2.fromScale(0, 1)
		content.exclamation.ImageTransparency = 1
		content.inputIcon.ImageTransparency = 1
		content.inputIcon.Image = self:GetInputIcon(false)
		content.UIScale.Scale = 1.5
		local content2 = clone.rightSide.content
		clone.rightSide.bg.Size = UDim2.fromScale(0, 1)
		content2.exclamation.ImageTransparency = 1
		content2.inputIcon.ImageTransparency = 1
		content2.inputIcon.Image = self:GetInputIcon(true)
		content2.UIScale.Scale = 1.5
		local v5 = fish[self.current.fish.Name]
		local v6 = fish[self.SecondFish.Name]
		local biteColor = v5.BiteColor or rarities.Rarities[v5.Rarity].ColorGradient or rarities.Rarities[v5.Rarity].Color
		local biteColor2 = v6.BiteColor or rarities.Rarities[v6.Rarity].ColorGradient or rarities.Rarities[v6.Rarity].Color
		local onLogicStepConnection = nil
		local v7 = typeof(biteColor) == "ColorSequence"
		local v8 = typeof(biteColor2) == "ColorSequence"

		if not v7 then
			content.exclamation.ImageColor3 = biteColor
		end

		if not v8 then
			content2.exclamation.ImageColor3 = biteColor2
		end

		if v7 or v8 then
			onLogicStepConnection = self.current.OnLogicStep:Connect(function()
				if v7 then
					content.exclamation.ImageColor3 = evalColorSequence(biteColor, os.clock() * 2 % 1)
				end

				if v8 then
					content2.exclamation.ImageColor3 = evalColorSequence(biteColor2, os.clock() * 2 % 1)
				end
			end)
		end

		clone.Parent = HudController:GetPlayerGui()
		TweenService:Create(clone.divider, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
			Size = UDim2.new(0, 5, 1, 0)
		}):Play()
		TweenService:Create(clone.leftSide.bg, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
			Size = UDim2.fromScale(1, 1)
		}):Play()
		TweenService:Create(clone.rightSide.bg, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
			Size = UDim2.fromScale(1, 1)
		}):Play()

		for _, v9 in { content, content2 } do
			TweenService:Create(v9.UIScale, TweenInfo.new(1.75, Enum.EasingStyle.Quint), {
				Scale = 0.75
			}):Play()
			TweenService:Create(v9.exclamation, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
				ImageTransparency = 0
			}):Play()
			TweenService:Create(v9.inputIcon, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
				ImageTransparency = 0
			}):Play()
		end

		TweenService:Create(clone.divider, TweenInfo.new(2.5, Enum.EasingStyle.Linear), {
			BackgroundTransparency = 1
		}):Play()
		task.delay(1.5, function()
			TweenService:Create(
				clone.leftSide.bg,
				TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut),
				{
					Position = UDim2.fromScale(0, 0)
				}
			):Play()
			TweenService:Create(
				clone.rightSide.bg,
				TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut),
				{
					Position = UDim2.fromScale(1, 0)
				}
			):Play()
			TweenService:Create(content, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
				Position = UDim2.fromScale(-0.5, 0.5)
			}):Play()
			TweenService:Create(content2, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
				Position = UDim2.fromScale(1.5, 0.5)
			}):Play()
			task.wait(1)

			if onLogicStepConnection then
				onLogicStepConnection:Disconnect()
			end

			task.wait(0.5)
			clone:Destroy()
		end)
	end,
	Morph = function(self, p, data)
		p.AnchorPoint = Vector2.new(0, 1)
		p.Position = UDim2.new(0.075, 0, 0.882, -20)
		data.core.rod.AllowedInputs = allowedInputs
		data.core.ui.InputGuide_Enabled = false
		local secondReelData = data.data.SecondReelData
		secondReelData.mock = "BellonasWaraxe"
		secondReelData.data.screenpos = UDim2.new(0.925, 0, 0.882, -20)
		secondReelData.reel_name = data.reel_name
		self.SecondFish = secondReelData.fish

		function secondReelData.precore_callback(p2)
			p2.core.rod.AllowedInputs = allowedInputs2
			p2.core.ui.InputGuide_Enabled = false
		end

		self:PlayInputThing()
		local v5 = ReelController.StartReel(secondReelData)
		v5.reel_bar.AnchorPoint = Vector2.new(1, 1)
		local v6 = nil
		local v7 = nil
		self.reelTrove:Add(UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch then
				if input.Position.X / data.reel.AbsoluteSize.X < 0.5 and data.active or not v5.active then
					data.core.rod:InputBegan(input)
					v6 = input
				else
					v5.core.rod:InputBegan(input)
					v7 = input
				end
			end
		end))
		self.reelTrove:Add(UserInputService.InputEnded:Connect(function(input)
			if v6 == input then
				data.core.rod:InputEnded(input)
				v6 = nil
			elseif v7 == input then
				v5.core.rod:InputEnded(input)
				v7 = nil
			end
		end))
		local v8 = nil
		self.reelTrove:Add(v5.OnMinigameEnd:Once(function(_, _, p2)
			v8 = p2
		end))
		self.reelTrove:Add(data.BuildEndingData:BindAtPriority(10000, function(p2)
			if not v8 and v5.active then
				local _, _, v9 = v5.OnMinigameEnd:Wait()
				v8 = v9
			end

			if v8 then
				p2.SecondReel = {
					e = v5.progress,
					p = v5.perfect,
					l = {},
					d = v8
				}
			end

			return p2
		end))
		data.trove:Add(v5)
	end
}
setmetatable(BellonasWaraxe, module)
return BellonasWaraxe