local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local flag = false
local flag2 = false
local otherEvent = ReplicatedStorage:WaitForChild("OtherEvent")
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
local modules = ReplicatedStorage:WaitForChild("Modules")
local sound_Effect = ReplicatedStorage:WaitForChild("Sound_Effect")
ReplicatedStorage:WaitForChild("GuiTemplate")
local leaderboard = workspace:WaitForChild("Leaderboard")
local time = leaderboard:WaitForChild("Time")
require(modules:WaitForChild("robloxPrompt"))
local Setting = require(moduleScript:WaitForChild("Setting"))
require(moduleScript:WaitForChild("Abbreviate"))
require(moduleScript:WaitForChild("PlaySound"))
local Translate = require(moduleScript:WaitForChild("Translate"))
local SetText = require(moduleScript:WaitForChild("SetText"))
local Jumpscare = require(moduleScript:WaitForChild("Jumpscare"))
local playerGui = localPlayer:WaitForChild("PlayerGui", 60)
local playerData = localPlayer:WaitForChild("PlayerData", 60)
local playerSettings = localPlayer:WaitForChild("PlayerSettings")
local musicVolume = playerSettings:WaitForChild("MusicVolume")
local soundEffects = playerSettings:WaitForChild("SoundEffects")
local fastMode = playerSettings:WaitForChild("FastMode")
local partyInvites = playerSettings:WaitForChild("PartyInvites")
local tradeRequests = playerSettings:WaitForChild("TradeRequests")
local damageCounter = playerSettings:WaitForChild("DamageCounter")
local airJumpText = playerSettings:WaitForChild("AirJumpText")
local instinctText = playerSettings:WaitForChild("InstinctText")
local cameraShake = playerSettings:WaitForChild("CameraShake")
local thaiLanguage = playerSettings:WaitForChild("ThaiLanguage")
local cooldownBar = playerSettings:WaitForChild("CooldownBar")
local partyIcon = playerSettings:WaitForChild("PartyIcon")
local autoEnablePvp = playerSettings:WaitForChild("AutoEnablePvp")
local country = playerData:WaitForChild("Country")
otherEvent.GuiEvents:WaitForChild("GuiEvent")
local settings = otherEvent.MainEvents:WaitForChild("Settings")
local code = otherEvent.MainEvents:WaitForChild("Code")
local parent = script.Parent.Parent.Parent.Parent
local parent2 = parent.Parent
local _ = parent.HeadBar
local container = script.Parent.Parent.Frame.Container
local mainGui = parent2.Parent.Parent:WaitForChild("MainGui", 30)
local pvpDisabled = mainGui:WaitForChild("PvpDisabled", 30)
local safezoneInfo = mainGui:WaitForChild("SafezoneInfo", 30)
local inCombat = mainGui:WaitForChild("InCombat", 30)
local musicFrame = container.MusicFrame
local sFXFrame = container.SFXFrame
local fastModeFrame = container.FastModeFrame
local partyInvites2 = container.PartyInvites
local tradeRequests2 = container.TradeRequests
local damageCounter2 = container.DamageCounter
local jumpLeftFrame = container.JumpLeftFrame
local instinctFrame = container.InstinctFrame
local cameraShakeFrame = container.CameraShakeFrame
local thaiLanguageFrame = container.ThaiLanguageFrame
local abilityBarFrame = container.AbilityBarFrame
local partyIconFrame = container.PartyIconFrame
local autoPvpFrame = container.AutoPvpFrame
local codeFrame = container.CodeFrame
local redeemBox = codeFrame.RedeemFrame.RedeemBox
local confirm = codeFrame.Confirm
local lastTime = tick()
local uIGridLayout = container:WaitForChild("UIGridLayout")
local codeLevel_Required = Setting.Setting.CodeLevel_Required
local v = {}

local function OpeningThisFrame()
	return parent2.Visible == true and parent2.Position == UDim2.new(0.5, 0, 0.5, 0)
end

local function GameMusic_Changed()
	musicVolume.Value = musicFrame.SlideFrame.Slide:GetAttribute("Percentage")
end

local function SoundEffects_Changed()
	soundEffects.Value = sFXFrame.SlideFrame.Slide:GetAttribute("Percentage")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SetContentSize()
	container.CanvasSize = UDim2.new(0, uIGridLayout.AbsoluteContentSize.X, 0, uIGridLayout.AbsoluteContentSize.Y)
end

local function snap(p, p2)
	if p2 == 0 then
		return p
	end

	return math.floor(p / p2 + 0.5) * p2
end

local function TextColor(p, p2)
	if p and p2 then
		return (`<font color="rgb({p2})">{p}</font>`)
	end
end

local function StartSliding(p, p2, p3)
	if p3 == "Music" then
		if flag == false then
			if SlidingConnection then
				SlidingConnection:Disconnect()
				SlidingConnection = nil
			end

			flag = true
			SlidingConnection = RunService.RenderStepped:Connect(function()
				if flag then
					local X = UserInputService:GetMouseLocation().X
					local X2 = p.SlideFrame.AbsoluteSize.X
					local v2 = math.floor((X - p.SlideFrame.AbsolutePosition.X) / X2 / 0.05 + 0.5) * 0.05
					p2.Value = math.clamp(v2, 0, 1)
				elseif SlidingConnection then
					SlidingConnection:Disconnect()
					SlidingConnection = nil
				end
			end)
		end
	elseif p3 == "SFX" and flag2 == false then
		if SlidingConnection then
			SlidingConnection:Disconnect()
			SlidingConnection = nil
		end

		flag2 = true
		SlidingConnection = RunService.RenderStepped:Connect(function()
			if flag2 then
				local X = UserInputService:GetMouseLocation().X
				local X2 = p.SlideFrame.AbsoluteSize.X
				local v2 = math.floor((X - p.SlideFrame.AbsolutePosition.X) / X2 / 0.05 + 0.5) * 0.05
				p2.Value = math.clamp(v2, 0, 1)
			elseif SlidingConnection then
				SlidingConnection:Disconnect()
				SlidingConnection = nil
			end
		end)
	end
end

local function ForceSlide(p, state)
	local X = UserInputService:GetMouseLocation().X
	local X2 = p.SlideFrame.AbsoluteSize.X
	state.Value = math.clamp(math.floor((X - p.SlideFrame.AbsolutePosition.X) / X2 / 0.05 + 0.5) * 0.05, 0, 1)
	settings:FireServer({
		Target = state.Name,
		Value = state.Value
	})
end

local function Toggle(state)
	if tick() - lastTime >= 0.35 then
		lastTime = tick()

		if state.Value == true then
			state.Value = false
			settings:FireServer({
				Target = state.Name,
				Value = state.Value
			})
		else
			state.Value = true
			settings:FireServer({
				Target = state.Name,
				Value = state.Value
			})
		end
	end
end

local function ShowMusic()
	musicFrame.Value.Text = `{math.floor(musicVolume.Value * 100)}%`
	TweenService:Create(
		musicFrame.SlideFrame.Slide,
		TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
		{
			Position = UDim2.new(
				musicVolume.Value,
				0,
				musicFrame.SlideFrame.Slide.Position.Y.Scale,
				musicFrame.SlideFrame.Slide.Position.Y.Offset
			)
		}
	):Play()
	musicFrame.SlideFrame.Bar.Size = UDim2.new(musicVolume.Value, 0, 1, 0)
end

local function ShowSFX()
	sFXFrame.Value.Text = `{math.floor(soundEffects.Value * 100)}%`
	TweenService:Create(
		sFXFrame.SlideFrame.Slide,
		TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
		{
			Position = UDim2.new(
				soundEffects.Value,
				0,
				sFXFrame.SlideFrame.Slide.Position.Y.Scale,
				sFXFrame.SlideFrame.Slide.Position.Y.Offset
			)
		}
	):Play()
	sFXFrame.SlideFrame.Bar.Size = UDim2.new(soundEffects.Value, 0, 1, 0)
end

local function ThaiLanguage_On()
	if script:GetAttribute("ThaiLanguage_Enabled") == nil then
		for _, instance in ipairs(CollectionService:GetTagged("Translate")) do
			if instance:IsA("TextLabel") or instance:IsA("TextButton") then
				if instance:GetAttribute("OriginalText") == nil and Translate[instance.Text] then
					instance:SetAttribute("OriginalText", instance.Text)
					instance.Text = Translate[instance.Text]
				end

				if instance:IsDescendantOf(container) then
					if instance.Name == "Description" then
						instance.Size = UDim2.new(instance.Size.X.Scale, 0, 0.3, 0)
					end
				elseif instance:IsDescendantOf(pvpDisabled) then
					if instance.Name == "Title" then
						instance.FontFace = Font.fromId(11598121416, Enum.FontWeight.Bold)
					elseif instance.Name == "Message" then
						instance.FontFace = Font.fromId(11598121416, Enum.FontWeight.Medium)
					elseif instance.Name == "Text" then
						instance.FontFace = Font.fromId(11598121416, Enum.FontWeight.Bold)
					elseif instance.Name == "FooterText" then
						instance.FontFace = Font.fromId(11598121416, Enum.FontWeight.Medium)
					end
				elseif instance:IsDescendantOf(safezoneInfo) then
					if instance.Name == "Title" then
						instance.FontFace = Font.fromId(11598121416, Enum.FontWeight.Bold)
					elseif instance.Name == "Message" then
						instance.FontFace = Font.fromId(11598121416, Enum.FontWeight.Medium)
					elseif instance.Name == "Okay" then
						instance.FontFace = Font.fromId(11598121416, Enum.FontWeight.Bold)
					end
				elseif instance:IsDescendantOf(inCombat) then
					if instance.Name == "Title" then
						instance.FontFace = Font.fromId(11598121416, Enum.FontWeight.Bold)
					elseif instance.Name == "Message" then
						instance.FontFace = Font.fromId(11598121416, Enum.FontWeight.Medium)
					elseif instance.Name == "Okay" then
						instance.FontFace = Font.fromId(11598121416, Enum.FontWeight.Bold)
					end
				elseif instance:IsDescendantOf(leaderboard) then
					if not instance:IsDescendantOf(time) then
						instance.FontFace = Font.fromId(12187607287, Enum.FontWeight.SemiBold)
					end

					if instance.Name == "Number" then
						instance.Position = UDim2.new(0, 5, 0.75, 0)
					elseif instance.Name == "Username" then
						instance.Position = UDim2.new(0.5, 0, 0.75, 0)
					elseif instance.Name == "Value" then
						if instance.Text == "เพชรทั้งหมด" then
							instance.Position = UDim2.new(1.02, 0, 0.75, 0)
						else
							instance.Position = UDim2.new(1.03, 0, 0.75, 0)
						end
					end
				elseif instance.Name == "Info_HeadTitle" then
					instance.Size = UDim2.new(0.95, 0, 0.15, 0)
				end
			elseif instance:IsA("TextBox") then
				if instance:GetAttribute("OriginalText") == nil and Translate[instance.PlaceholderText] then
					instance:SetAttribute("OriginalText", instance.PlaceholderText)
					instance.PlaceholderText = Translate[instance.PlaceholderText]
				end
			elseif instance:IsA("ProximityPrompt") then
				if instance:GetAttribute("OriginalText") == nil and Translate[instance.ActionText] then
					instance:SetAttribute("OriginalText", instance.ActionText)
					instance.ActionText = Translate[instance.ActionText]
				end
			elseif instance:IsA("Dialog") then
				if instance:GetAttribute("OriginalText") == nil and Translate[instance.InitialPrompt] then
					instance:SetAttribute("OriginalText", instance.InitialPrompt)
					instance.InitialPrompt = Translate[instance.InitialPrompt]
				end
			elseif instance:IsA("DialogChoice") then
				if instance:GetAttribute("Original_ResponseDialog") == nil and Translate[instance.ResponseDialog] then
					instance:SetAttribute("Original_ResponseDialog", instance.ResponseDialog)
					instance.ResponseDialog = Translate[instance.ResponseDialog]
				end

				if instance:GetAttribute("Original_UserDialog") == nil and Translate[instance.UserDialog] then
					instance:SetAttribute("Original_UserDialog", instance.UserDialog)
					instance.UserDialog = Translate[instance.UserDialog]
				end
			end
		end

		script:SetAttribute("ThaiLanguage_Enabled", true)
	end
end

local function ThaiLanguage_Off()
	if script:GetAttribute("ThaiLanguage_Enabled") == true then
		for _, instance in ipairs(CollectionService:GetTagged("Translate")) do
			if instance:IsA("TextLabel") or instance:IsA("TextButton") then
				if instance:GetAttribute("OriginalText") then
					instance.Text = instance:GetAttribute("OriginalText")
					instance:SetAttribute("OriginalText", nil)
				end

				if instance:IsDescendantOf(container) then
					if instance.Name == "Description" then
						instance.Size = UDim2.new(instance.Size.X.Scale, 0, 0.275, 0)
					end
				elseif instance:IsDescendantOf(pvpDisabled) then
					if instance.Name == "Title" then
						instance.Font = Enum.Font.BuilderSansBold
					elseif instance.Name == "Message" then
						instance.Font = Enum.Font.BuilderSansMedium
					elseif instance.Name == "Text" then
						instance.Font = Enum.Font.BuilderSansBold
					elseif instance.Name == "FooterText" then
						instance.Font = Enum.Font.BuilderSansMedium
					end
				elseif instance:IsDescendantOf(safezoneInfo) then
					if instance.Name == "Title" then
						instance.Font = Enum.Font.BuilderSansBold
					elseif instance.Name == "Message" then
						instance.Font = Enum.Font.BuilderSansMedium
					elseif instance.Name == "Okay" then
						instance.Font = Enum.Font.BuilderSansBold
					end
				elseif instance:IsDescendantOf(inCombat) then
					if instance.Name == "Title" then
						instance.Font = Enum.Font.BuilderSansBold
					elseif instance.Name == "Message" then
						instance.Font = Enum.Font.BuilderSansMedium
					elseif instance.Name == "Okay" then
						instance.Font = Enum.Font.BuilderSansBold
					end
				elseif instance:IsDescendantOf(leaderboard) then
					if not instance:IsDescendantOf(time) then
						instance.FontFace = Font.fromId(11598121416, Enum.FontWeight.ExtraBold)
					end

					if instance.Name == "Number" then
						instance.Position = UDim2.new(0, 5, 0.56, 0)
					elseif instance.Name == "Username" then
						instance.Position = UDim2.new(0.5, 0, 0.6, 0)
					elseif instance.Name == "Value" then
						if instance.Text == "Total Money" then
							instance.Position = UDim2.new(1.01, 0, 0.6, 0)
						else
							instance.Position = UDim2.new(1.02, 0, 0.6, 0)
						end
					end
				elseif instance.Name == "Info_HeadTitle" then
					instance.Size = UDim2.new(0.95, 0, 0.175, 0)
				end
			elseif instance:IsA("TextBox") then
				if instance:GetAttribute("OriginalText") then
					instance.PlaceholderText = instance:GetAttribute("OriginalText")
					instance:SetAttribute("OriginalText", nil)
				end
			elseif instance:IsA("ProximityPrompt") then
				if instance:GetAttribute("OriginalText") then
					instance.ActionText = instance:GetAttribute("OriginalText")
					instance:SetAttribute("OriginalText", nil)
				end
			elseif instance:IsA("Dialog") then
				if instance:GetAttribute("OriginalText") then
					instance.InitialPrompt = instance:GetAttribute("OriginalText")
					instance:SetAttribute("OriginalText", nil)
				end
			elseif instance:IsA("DialogChoice") then
				if instance:GetAttribute("Original_ResponseDialog") then
					instance.ResponseDialog = instance:GetAttribute("Original_ResponseDialog")
					instance:SetAttribute("Original_ResponseDialog", nil)
				end

				if instance:GetAttribute("Original_UserDialog") then
					instance.UserDialog = instance:GetAttribute("Original_UserDialog")
					instance:SetAttribute("Original_UserDialog", nil)
				end
			end
		end

		script:SetAttribute("ThaiLanguage_Enabled", nil)
	end
end

local function FastMode_On()
	if script:GetAttribute("FastMode_Enabled") == nil then
		for _, descendant in ipairs(workspace.Island:GetDescendants()) do
			if descendant:IsA("BasePart") or descendant:IsA("UnionOperation") or descendant:IsA("MeshPart") then
				if not v[descendant] then
					v[descendant] = descendant.Material
				end

				if descendant.Material == Enum.Material.Ground then
					descendant:SetAttribute("Original_Color", descendant.Color)
					descendant.Color = Color3.fromRGB(84, 68, 42)
				elseif descendant.Name == "Sand_Path" then
					descendant:SetAttribute("Original_Color", descendant.Color)
					descendant.Color = Color3.fromRGB(189, 163, 114)
				end

				descendant.Material = Enum.Material.SmoothPlastic
			elseif descendant:IsA("ParticleEmitter") and descendant.Enabled == true then
				if not v[descendant] then
					v[descendant] = true
				end

				descendant.Enabled = false
			end
		end

		script:SetAttribute("FastMode_Enabled", true)
	end
end

local function FastMode_Off()
	if script:GetAttribute("FastMode_Enabled") == true then
		for _, descendant in ipairs(workspace.Island:GetDescendants()) do
			if descendant:IsA("BasePart") or descendant:IsA("UnionOperation") or descendant:IsA("MeshPart") then
				if v[descendant] then
					descendant.Material = v[descendant]
				end

				if descendant:GetAttribute("Original_Color") then
					descendant.Color = descendant:GetAttribute("Original_Color")
					descendant:SetAttribute("Original_Color", nil)
				end
			elseif descendant:IsA("ParticleEmitter") and descendant.Enabled == false and v[descendant] then
				descendant.Enabled = v[descendant]
			end
		end

		if v then
			table.clear(v)
		end

		script:SetAttribute("FastMode_Enabled", nil)
	end
end

local function ShowFastMode()
	if fastMode.Value == true then
		TweenService:Create(
			fastModeFrame.ToggleFrame.Toggle,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				Position = UDim2.new(0.775, 0, 0.5, 0),
				ImageColor3 = Color3.fromRGB(227, 225, 219)
			}
		):Play()
		TweenService:Create(
			fastModeFrame.ToggleFrame,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				ImageColor3 = Color3.fromRGB(88, 101, 242)
			}
		):Play()
		fastModeFrame.ToggleFrame.Toggle.Disable.Visible = false
		fastModeFrame.ToggleFrame.Toggle.Enable.Visible = true
		FastMode_On()
	else
		TweenService:Create(
			fastModeFrame.ToggleFrame.Toggle,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				Position = UDim2.new(0.225, 0, 0.5, 0),
				ImageColor3 = Color3.fromRGB(227, 225, 219)
			}
		):Play()
		TweenService:Create(
			fastModeFrame.ToggleFrame,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				ImageColor3 = Color3.fromRGB(75, 79, 86)
			}
		):Play()
		fastModeFrame.ToggleFrame.Toggle.Enable.Visible = false
		fastModeFrame.ToggleFrame.Toggle.Disable.Visible = true
		FastMode_Off()
	end
end

local function ShowThaiLanguage()
	if thaiLanguage.Value == true then
		TweenService:Create(
			thaiLanguageFrame.ToggleFrame.Toggle,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				Position = UDim2.new(0.775, 0, 0.5, 0),
				ImageColor3 = Color3.fromRGB(227, 225, 219)
			}
		):Play()
		TweenService:Create(
			thaiLanguageFrame.ToggleFrame,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				ImageColor3 = Color3.fromRGB(88, 101, 242)
			}
		):Play()
		thaiLanguageFrame.ToggleFrame.Toggle.Disable.Visible = false
		thaiLanguageFrame.ToggleFrame.Toggle.Enable.Visible = true
		ThaiLanguage_On()
	else
		TweenService:Create(
			thaiLanguageFrame.ToggleFrame.Toggle,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				Position = UDim2.new(0.225, 0, 0.5, 0),
				ImageColor3 = Color3.fromRGB(227, 225, 219)
			}
		):Play()
		TweenService:Create(
			thaiLanguageFrame.ToggleFrame,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				ImageColor3 = Color3.fromRGB(75, 79, 86)
			}
		):Play()
		thaiLanguageFrame.ToggleFrame.Toggle.Enable.Visible = false
		thaiLanguageFrame.ToggleFrame.Toggle.Disable.Visible = true
		ThaiLanguage_Off()
	end
end

local function ShowPartyInvites()
	if partyInvites.Value == true then
		TweenService:Create(
			partyInvites2.ToggleFrame.Toggle,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				Position = UDim2.new(0.775, 0, 0.5, 0),
				ImageColor3 = Color3.fromRGB(227, 225, 219)
			}
		):Play()
		TweenService:Create(
			partyInvites2.ToggleFrame,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				ImageColor3 = Color3.fromRGB(88, 101, 242)
			}
		):Play()
		partyInvites2.ToggleFrame.Toggle.Disable.Visible = false
		partyInvites2.ToggleFrame.Toggle.Enable.Visible = true
	else
		TweenService:Create(
			partyInvites2.ToggleFrame.Toggle,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				Position = UDim2.new(0.225, 0, 0.5, 0),
				ImageColor3 = Color3.fromRGB(227, 225, 219)
			}
		):Play()
		TweenService:Create(
			partyInvites2.ToggleFrame,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				ImageColor3 = Color3.fromRGB(75, 79, 86)
			}
		):Play()
		partyInvites2.ToggleFrame.Toggle.Enable.Visible = false
		partyInvites2.ToggleFrame.Toggle.Disable.Visible = true
	end
end

local function ShowTradeRequests()
	if tradeRequests.Value == true then
		TweenService:Create(
			tradeRequests2.ToggleFrame.Toggle,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				Position = UDim2.new(0.775, 0, 0.5, 0),
				ImageColor3 = Color3.fromRGB(227, 225, 219)
			}
		):Play()
		TweenService:Create(
			tradeRequests2.ToggleFrame,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				ImageColor3 = Color3.fromRGB(88, 101, 242)
			}
		):Play()
		tradeRequests2.ToggleFrame.Toggle.Disable.Visible = false
		tradeRequests2.ToggleFrame.Toggle.Enable.Visible = true
	else
		TweenService:Create(
			tradeRequests2.ToggleFrame.Toggle,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				Position = UDim2.new(0.225, 0, 0.5, 0),
				ImageColor3 = Color3.fromRGB(227, 225, 219)
			}
		):Play()
		TweenService:Create(
			tradeRequests2.ToggleFrame,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				ImageColor3 = Color3.fromRGB(75, 79, 86)
			}
		):Play()
		tradeRequests2.ToggleFrame.Toggle.Enable.Visible = false
		tradeRequests2.ToggleFrame.Toggle.Disable.Visible = true
	end
end

local function ShowDamageCounter()
	if damageCounter.Value == true then
		TweenService:Create(
			damageCounter2.ToggleFrame.Toggle,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				Position = UDim2.new(0.775, 0, 0.5, 0),
				ImageColor3 = Color3.fromRGB(227, 225, 219)
			}
		):Play()
		TweenService:Create(
			damageCounter2.ToggleFrame,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				ImageColor3 = Color3.fromRGB(88, 101, 242)
			}
		):Play()
		damageCounter2.ToggleFrame.Toggle.Disable.Visible = false
		damageCounter2.ToggleFrame.Toggle.Enable.Visible = true
	else
		TweenService:Create(
			damageCounter2.ToggleFrame.Toggle,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				Position = UDim2.new(0.225, 0, 0.5, 0),
				ImageColor3 = Color3.fromRGB(227, 225, 219)
			}
		):Play()
		TweenService:Create(
			damageCounter2.ToggleFrame,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				ImageColor3 = Color3.fromRGB(75, 79, 86)
			}
		):Play()
		damageCounter2.ToggleFrame.Toggle.Enable.Visible = false
		damageCounter2.ToggleFrame.Toggle.Disable.Visible = true
	end
end

local function ShowAirJump()
	if airJumpText.Value == true then
		TweenService:Create(
			jumpLeftFrame.ToggleFrame.Toggle,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				Position = UDim2.new(0.775, 0, 0.5, 0),
				ImageColor3 = Color3.fromRGB(227, 225, 219)
			}
		):Play()
		TweenService:Create(
			jumpLeftFrame.ToggleFrame,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				ImageColor3 = Color3.fromRGB(88, 101, 242)
			}
		):Play()
		jumpLeftFrame.ToggleFrame.Toggle.Disable.Visible = false
		jumpLeftFrame.ToggleFrame.Toggle.Enable.Visible = true
	else
		TweenService:Create(
			jumpLeftFrame.ToggleFrame.Toggle,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				Position = UDim2.new(0.225, 0, 0.5, 0),
				ImageColor3 = Color3.fromRGB(227, 225, 219)
			}
		):Play()
		TweenService:Create(
			jumpLeftFrame.ToggleFrame,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				ImageColor3 = Color3.fromRGB(75, 79, 86)
			}
		):Play()
		jumpLeftFrame.ToggleFrame.Toggle.Enable.Visible = false
		jumpLeftFrame.ToggleFrame.Toggle.Disable.Visible = true
	end
end

local function ShowInstinct()
	if instinctText.Value == true then
		TweenService:Create(
			instinctFrame.ToggleFrame.Toggle,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				Position = UDim2.new(0.775, 0, 0.5, 0),
				ImageColor3 = Color3.fromRGB(227, 225, 219)
			}
		):Play()
		TweenService:Create(
			instinctFrame.ToggleFrame,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				ImageColor3 = Color3.fromRGB(88, 101, 242)
			}
		):Play()
		instinctFrame.ToggleFrame.Toggle.Disable.Visible = false
		instinctFrame.ToggleFrame.Toggle.Enable.Visible = true
	else
		TweenService:Create(
			instinctFrame.ToggleFrame.Toggle,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				Position = UDim2.new(0.225, 0, 0.5, 0),
				ImageColor3 = Color3.fromRGB(227, 225, 219)
			}
		):Play()
		TweenService:Create(
			instinctFrame.ToggleFrame,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				ImageColor3 = Color3.fromRGB(75, 79, 86)
			}
		):Play()
		instinctFrame.ToggleFrame.Toggle.Enable.Visible = false
		instinctFrame.ToggleFrame.Toggle.Disable.Visible = true
	end
end

local function ShowCameraShake()
	if cameraShake.Value == true then
		TweenService:Create(
			cameraShakeFrame.ToggleFrame.Toggle,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				Position = UDim2.new(0.775, 0, 0.5, 0),
				ImageColor3 = Color3.fromRGB(227, 225, 219)
			}
		):Play()
		TweenService:Create(
			cameraShakeFrame.ToggleFrame,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				ImageColor3 = Color3.fromRGB(88, 101, 242)
			}
		):Play()
		cameraShakeFrame.ToggleFrame.Toggle.Disable.Visible = false
		cameraShakeFrame.ToggleFrame.Toggle.Enable.Visible = true
	else
		TweenService:Create(
			cameraShakeFrame.ToggleFrame.Toggle,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				Position = UDim2.new(0.225, 0, 0.5, 0),
				ImageColor3 = Color3.fromRGB(227, 225, 219)
			}
		):Play()
		TweenService:Create(
			cameraShakeFrame.ToggleFrame,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				ImageColor3 = Color3.fromRGB(75, 79, 86)
			}
		):Play()
		cameraShakeFrame.ToggleFrame.Toggle.Enable.Visible = false
		cameraShakeFrame.ToggleFrame.Toggle.Disable.Visible = true
	end
end

local function ShowCooldownBar()
	if cooldownBar.Value == true then
		TweenService:Create(
			abilityBarFrame.ToggleFrame.Toggle,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				Position = UDim2.new(0.775, 0, 0.5, 0),
				ImageColor3 = Color3.fromRGB(227, 225, 219)
			}
		):Play()
		TweenService:Create(
			abilityBarFrame.ToggleFrame,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				ImageColor3 = Color3.fromRGB(88, 101, 242)
			}
		):Play()
		abilityBarFrame.ToggleFrame.Toggle.Disable.Visible = false
		abilityBarFrame.ToggleFrame.Toggle.Enable.Visible = true

		if localPlayer:GetAttribute("No_CooldownBar") then
			localPlayer:SetAttribute("No_CooldownBar", nil)
		end
	else
		TweenService:Create(
			abilityBarFrame.ToggleFrame.Toggle,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				Position = UDim2.new(0.225, 0, 0.5, 0),
				ImageColor3 = Color3.fromRGB(227, 225, 219)
			}
		):Play()
		TweenService:Create(
			abilityBarFrame.ToggleFrame,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				ImageColor3 = Color3.fromRGB(75, 79, 86)
			}
		):Play()
		abilityBarFrame.ToggleFrame.Toggle.Enable.Visible = false
		abilityBarFrame.ToggleFrame.Toggle.Disable.Visible = true

		if localPlayer:GetAttribute("No_CooldownBar") == nil then
			localPlayer:SetAttribute("No_CooldownBar", true)
		end
	end
end

local function ShowPartyIcon()
	if partyIcon.Value == true then
		TweenService:Create(
			partyIconFrame.ToggleFrame.Toggle,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				Position = UDim2.new(0.775, 0, 0.5, 0),
				ImageColor3 = Color3.fromRGB(227, 225, 219)
			}
		):Play()
		TweenService:Create(
			partyIconFrame.ToggleFrame,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				ImageColor3 = Color3.fromRGB(88, 101, 242)
			}
		):Play()
		partyIconFrame.ToggleFrame.Toggle.Disable.Visible = false
		partyIconFrame.ToggleFrame.Toggle.Enable.Visible = true
	else
		TweenService:Create(
			partyIconFrame.ToggleFrame.Toggle,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				Position = UDim2.new(0.225, 0, 0.5, 0),
				ImageColor3 = Color3.fromRGB(227, 225, 219)
			}
		):Play()
		TweenService:Create(
			partyIconFrame.ToggleFrame,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				ImageColor3 = Color3.fromRGB(75, 79, 86)
			}
		):Play()
		partyIconFrame.ToggleFrame.Toggle.Enable.Visible = false
		partyIconFrame.ToggleFrame.Toggle.Disable.Visible = true
	end
end

local function ShowAutoPvp()
	if autoEnablePvp.Value == true then
		TweenService:Create(
			autoPvpFrame.ToggleFrame.Toggle,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				Position = UDim2.new(0.775, 0, 0.5, 0),
				ImageColor3 = Color3.fromRGB(227, 225, 219)
			}
		):Play()
		TweenService:Create(
			autoPvpFrame.ToggleFrame,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				ImageColor3 = Color3.fromRGB(88, 101, 242)
			}
		):Play()
		autoPvpFrame.ToggleFrame.Toggle.Disable.Visible = false
		autoPvpFrame.ToggleFrame.Toggle.Enable.Visible = true
	else
		TweenService:Create(
			autoPvpFrame.ToggleFrame.Toggle,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				Position = UDim2.new(0.225, 0, 0.5, 0),
				ImageColor3 = Color3.fromRGB(227, 225, 219)
			}
		):Play()
		TweenService:Create(
			autoPvpFrame.ToggleFrame,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				ImageColor3 = Color3.fromRGB(75, 79, 86)
			}
		):Play()
		autoPvpFrame.ToggleFrame.Toggle.Enable.Visible = false
		autoPvpFrame.ToggleFrame.Toggle.Disable.Visible = true
	end
end

local function CodeFunction()
	if redeemBox.Text ~= "" then
		local text = string.lower(redeemBox.Text)

		if string.gsub(text, "%s+", "") == "nevergonnagiveyouup" or string.gsub(text, "%s+", "") == "rickroll" or string.gsub(
			text,
			"%s+",
			""
		) == "rickastley" then
			local rickroll = playerGui.Jumpscare:FindFirstChild("Rickroll")

			if rickroll and localPlayer:GetAttribute("Jumpscaring") == nil then
				sound_Effect.RickRoll:Play()
				Jumpscare.SetJumpscare(localPlayer, rickroll)
			end
		elseif string.gsub(text, "%s+", "") == "amogus" or string.gsub(text, "%s+", "") == "sus" then
			local amongus = playerGui.Jumpscare:FindFirstChild("Amongus")

			if amongus and localPlayer:GetAttribute("Jumpscaring") == nil then
				sound_Effect.Amongus:Play()
				Jumpscare.SetJumpscare(localPlayer, amongus)
			end

			return
		end

		local v2 = code:InvokeServer(redeemBox.Text)

		if v2 == "Correct" then
			sound_Effect.Success2:Play()
		elseif v2 == "Incorrect" then
			sound_Effect.Scare1:Play()

			if thaiLanguage.Value == true then
				SetText.SetText(localPlayer, "CustomMessage", {
					Message = "โค้ดของคุณไม่ถูกต้อง!",
					MessageColor = "Red"
				})
			else
				SetText.SetText(localPlayer, "CustomMessage", {
					Message = "Your code is invalid!",
					MessageColor = "Red"
				})
			end
		elseif v2 == "Expired" then
			sound_Effect.Bonk:Play()

			if thaiLanguage.Value == true then
				SetText.SetText(localPlayer, "CustomMessage", {
					Message = "โค้ดของคุณหมดอายุแล้ว!",
					MessageColor = "Red"
				})
			else
				SetText.SetText(localPlayer, "CustomMessage", {
					Message = "Your code has expired!",
					MessageColor = "Red"
				})
			end
		elseif v2 == "LowLevel" then
			sound_Effect.Scare1:Play()

			if localPlayer:GetAttribute("TH") then
				SetText.SetText(localPlayer, "CustomMessage", {
					Message = `{"<font color=\"rgb(255,100,100)\">เลเวลไม่เพียงพอ!</font>"} ต้องการเลเวล {codeLevel_Required} ขึ้นไปในการใช้งานโค้ด.`,
					Duration = 4
				})
			else
				SetText.SetText(localPlayer, "CustomMessage", {
					Message = `{"<font color=\"rgb(255,100,100)\">Insufficient Level!</font>"} Lv. {codeLevel_Required} required to redeem codes.`,
					Duration = 4
				})
			end
		elseif v2 == "Redeemed" then
			sound_Effect.Scare1:Play()

			if thaiLanguage.Value == true then
				SetText.SetText(localPlayer, "CustomMessage", {
					Message = "คุณได้ใช้โค้ดนี้ไปแล้ว!",
					MessageColor = "Red"
				})
			else
				SetText.SetText(localPlayer, "CustomMessage", {
					Message = "You've already redeemed this code!",
					MessageColor = "Red"
				})
			end
		end
	end
end

task.spawn(function()
	while localPlayer:GetAttribute("LoadedData") == nil do
		task.wait(1)
	end

	if country.Value == "🇹🇭" and thaiLanguageFrame.Visible == false then
		thaiLanguageFrame.Visible = true
	end
end)

local function ShowAll()
	ShowMusic()
	ShowSFX()
	ShowFastMode()
	ShowPartyInvites()
	ShowTradeRequests()
	ShowDamageCounter()
	ShowAirJump()
	ShowInstinct()
	ShowCameraShake()
	ShowThaiLanguage()
	ShowCooldownBar()
	ShowPartyIcon()
	ShowAutoPvp()
end

ShowAll()
musicVolume.Changed:Connect(ShowMusic)
soundEffects.Changed:Connect(ShowSFX)
fastMode.Changed:Connect(ShowFastMode)
partyInvites.Changed:Connect(ShowPartyInvites)
tradeRequests.Changed:Connect(ShowTradeRequests)
damageCounter.Changed:Connect(ShowDamageCounter)
airJumpText.Changed:Connect(ShowAirJump)
instinctText.Changed:Connect(ShowInstinct)
cameraShake.Changed:Connect(ShowCameraShake)
thaiLanguage.Changed:Connect(ShowThaiLanguage)
cooldownBar.Changed:Connect(ShowCooldownBar)
partyIcon.Changed:Connect(ShowPartyIcon)
autoEnablePvp.Changed:Connect(ShowAutoPvp)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if flag == true then
			flag = false

			if SlidingConnection then
				SlidingConnection:Disconnect()
				SlidingConnection = nil
			end

			settings:FireServer({
				Target = musicVolume.Name,
				Value = musicVolume.Value
			})
		end

		if flag2 == true then
			flag2 = false

			if SlidingConnection then
				SlidingConnection:Disconnect()
				SlidingConnection = nil
			end

			settings:FireServer({
				Target = soundEffects.Name,
				Value = soundEffects.Value
			})
		end
	elseif input.UserInputType == Enum.UserInputType.Touch then
		if flag == true then
			flag = false

			if SlidingConnection then
				SlidingConnection:Disconnect()
				SlidingConnection = nil
			end

			settings:FireServer({
				Target = musicVolume.Name,
				Value = musicVolume.Value
			})
		end

		if flag2 == true then
			flag2 = false

			if SlidingConnection then
				SlidingConnection:Disconnect()
				SlidingConnection = nil
			end

			settings:FireServer({
				Target = soundEffects.Name,
				Value = soundEffects.Value
			})
		end
	end
end)
musicFrame.SlideFrame.Slide.MouseButton1Down:Connect(function()
	local musicFrame2 = musicFrame
	local v3 = musicVolume

	if flag == false then
		if SlidingConnection then
			SlidingConnection:Disconnect()
			SlidingConnection = nil
		end

		flag = true
		SlidingConnection = RunService.RenderStepped:Connect(function()
			if flag then
				local X = UserInputService:GetMouseLocation().X
				local X2 = musicFrame2.SlideFrame.AbsoluteSize.X
				local v4 = math.floor((X - musicFrame2.SlideFrame.AbsolutePosition.X) / X2 / 0.05 + 0.5) * 0.05
				v3.Value = math.clamp(v4, 0, 1)
			elseif SlidingConnection then
				SlidingConnection:Disconnect()
				SlidingConnection = nil
			end
		end)
	end
end)
sFXFrame.SlideFrame.Slide.MouseButton1Down:Connect(function()
	local sFXFrame2 = sFXFrame
	local v3 = soundEffects

	if flag2 == false then
		if SlidingConnection then
			SlidingConnection:Disconnect()
			SlidingConnection = nil
		end

		flag2 = true
		SlidingConnection = RunService.RenderStepped:Connect(function()
			if flag2 then
				local X = UserInputService:GetMouseLocation().X
				local X2 = sFXFrame2.SlideFrame.AbsoluteSize.X
				local v4 = math.floor((X - sFXFrame2.SlideFrame.AbsolutePosition.X) / X2 / 0.05 + 0.5) * 0.05
				v3.Value = math.clamp(v4, 0, 1)
			elseif SlidingConnection then
				SlidingConnection:Disconnect()
				SlidingConnection = nil
			end
		end)
	end
end)
musicFrame.SlideFrame.MouseButton1Down:Connect(function()
	local musicFrame2 = musicFrame
	local v3 = musicVolume

	if flag == false then
		if SlidingConnection then
			SlidingConnection:Disconnect()
			SlidingConnection = nil
		end

		flag = true
		SlidingConnection = RunService.RenderStepped:Connect(function()
			if flag then
				local X = UserInputService:GetMouseLocation().X
				local X2 = musicFrame2.SlideFrame.AbsoluteSize.X
				local v4 = math.floor((X - musicFrame2.SlideFrame.AbsolutePosition.X) / X2 / 0.05 + 0.5) * 0.05
				v3.Value = math.clamp(v4, 0, 1)
			elseif SlidingConnection then
				SlidingConnection:Disconnect()
				SlidingConnection = nil
			end
		end)
	end
end)
sFXFrame.SlideFrame.MouseButton1Down:Connect(function()
	local sFXFrame2 = sFXFrame
	local v3 = soundEffects

	if flag2 == false then
		if SlidingConnection then
			SlidingConnection:Disconnect()
			SlidingConnection = nil
		end

		flag2 = true
		SlidingConnection = RunService.RenderStepped:Connect(function()
			if flag2 then
				local X = UserInputService:GetMouseLocation().X
				local X2 = sFXFrame2.SlideFrame.AbsoluteSize.X
				local v4 = math.floor((X - sFXFrame2.SlideFrame.AbsolutePosition.X) / X2 / 0.05 + 0.5) * 0.05
				v3.Value = math.clamp(v4, 0, 1)
			elseif SlidingConnection then
				SlidingConnection:Disconnect()
				SlidingConnection = nil
			end
		end)
	end
end)
fastModeFrame.ToggleFrame.Toggle.Activated:Connect(function()
	Toggle(fastMode)
end)
partyInvites2.ToggleFrame.Toggle.Activated:Connect(function()
	Toggle(partyInvites)
end)
tradeRequests2.ToggleFrame.Toggle.Activated:Connect(function()
	Toggle(tradeRequests)
end)
damageCounter2.ToggleFrame.Toggle.Activated:Connect(function()
	Toggle(damageCounter)
end)
jumpLeftFrame.ToggleFrame.Toggle.Activated:Connect(function()
	Toggle(airJumpText)
end)
instinctFrame.ToggleFrame.Toggle.Activated:Connect(function()
	Toggle(instinctText)
end)
cameraShakeFrame.ToggleFrame.Toggle.Activated:Connect(function()
	Toggle(cameraShake)
end)
thaiLanguageFrame.ToggleFrame.Toggle.Activated:Connect(function()
	Toggle(thaiLanguage)
end)
abilityBarFrame.ToggleFrame.Toggle.Activated:Connect(function()
	Toggle(cooldownBar)
end)
partyIconFrame.ToggleFrame.Toggle.Activated:Connect(function()
	Toggle(partyIcon)
end)
autoPvpFrame.ToggleFrame.Toggle.Activated:Connect(function()
	Toggle(autoEnablePvp)
end)
fastModeFrame.ToggleFrame.Activated:Connect(function()
	Toggle(fastMode)
end)
partyInvites2.ToggleFrame.Activated:Connect(function()
	Toggle(partyInvites)
end)
tradeRequests2.ToggleFrame.Activated:Connect(function()
	Toggle(tradeRequests)
end)
damageCounter2.ToggleFrame.Activated:Connect(function()
	Toggle(damageCounter)
end)
jumpLeftFrame.ToggleFrame.Activated:Connect(function()
	Toggle(airJumpText)
end)
instinctFrame.ToggleFrame.Activated:Connect(function()
	Toggle(instinctText)
end)
cameraShakeFrame.ToggleFrame.Activated:Connect(function()
	Toggle(cameraShake)
end)
thaiLanguageFrame.ToggleFrame.Activated:Connect(function()
	Toggle(thaiLanguage)
end)
abilityBarFrame.ToggleFrame.Activated:Connect(function()
	Toggle(cooldownBar)
end)
partyIconFrame.ToggleFrame.Activated:Connect(function()
	Toggle(partyIcon)
end)
autoPvpFrame.ToggleFrame.Activated:Connect(function()
	Toggle(autoEnablePvp)
end)
confirm.Activated:Connect(CodeFunction)
redeemBox.FocusLost:Connect(function(flag3: boolean)
	if flag3 then
		CodeFunction()
	end
end)
uIGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(SetContentSize)
SetContentSize() -- equivalent call inferred; original call site unknown