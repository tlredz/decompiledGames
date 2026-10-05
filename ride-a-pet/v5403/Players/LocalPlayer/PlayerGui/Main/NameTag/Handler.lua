local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local gameServices = ReplicatedStorage:WaitForChild("GameServices")
local Confirmation = require(gameServices:WaitForChild("Confirmation"))
local PetNameRules = require(gameServices:WaitForChild("PetNameRules"))
local localPlayer = Players.LocalPlayer
local PetRenderer = require(localPlayer:WaitForChild("PlayerScripts"):WaitForChild("Game"):WaitForChild("Pets"):WaitForChild("PetRenderer"))
local game2 = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game")
local checkPetName = game2:WaitForChild("CheckPetName")
local namePet = game2:WaitForChild("NamePet")
assert(checkPetName:IsA("RemoteFunction"), "Remotes.Game.CheckPetName must be a RemoteFunction")
assert(namePet:IsA("RemoteFunction"), "Remotes.Game.NamePet must be a RemoteFunction")
local feed = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Prompts"):WaitForChild("Feed")
assert(feed:IsA("ProximityPrompt"), "Assets.Prompts.Feed must be a ProximityPrompt")
local color = Color3.fromRGB(120, 230, 90)
local color2 = Color3.fromRGB(255, 90, 90)
local color3 = Color3.fromRGB(220, 220, 220)
local rbxassetfontsfamiliesComicNeueAngularjson = Font.new(
	"rbxasset://fonts/families/ComicNeueAngular.json",
	Enum.FontWeight.Bold,
	Enum.FontStyle.Normal
)
local parent = script.Parent
assert(parent:IsA("Frame"), "NameTag must be a Frame")
local holder = parent:WaitForChild("Holder")
local mainTitle = holder:WaitForChild("MainTitle")
local title = parent:WaitForChild("TopLeft"):WaitForChild("Title")
assert(title:IsA("TextLabel"), "NameTag.TopLeft.Title must be a TextLabel")
local choices = holder:WaitForChild("Choices")
local yes = choices:WaitForChild("Yes")
local no = choices:WaitForChild("No")
assert(mainTitle:IsA("TextLabel"), "NameTag.Holder.MainTitle must be a TextLabel")
assert(yes:IsA("GuiButton"), "NameTag Choices.Yes must be a GuiButton")
assert(no:IsA("GuiButton"), "NameTag Choices.No must be a GuiButton")

local function BuildInput()
	local nameInput = holder:FindFirstChild("NameInput")

	if nameInput and nameInput:IsA("TextBox") then
		return nameInput
	end

	mainTitle.Position = UDim2.fromScale(0, 0.04)
	mainTitle.Size = UDim2.fromScale(1, 0.28)
	local textBox = Instance.new("TextBox")
	textBox.Name = "NameInput"
	textBox.AnchorPoint = Vector2.new(0.5, 0)
	textBox.Position = UDim2.fromScale(0.5, 0.39)
	textBox.Size = UDim2.fromScale(0.82, 0.2)
	textBox.BackgroundColor3 = Color3.new(0, 0, 0)
	textBox.BackgroundTransparency = 0.45
	textBox.BorderSizePixel = 0
	textBox.ClearTextOnFocus = false
	textBox.FontFace = rbxassetfontsfamiliesComicNeueAngularjson
	textBox.PlaceholderText = "Letters only..."
	textBox.PlaceholderColor3 = Color3.fromRGB(189, 189, 189)
	textBox.Text = ""
	textBox.TextColor3 = Color3.new(1, 1, 1)
	textBox.TextScaled = true
	textBox.TextWrapped = true
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0.2, 0)
	uICorner.Parent = textBox
	local uIPadding = Instance.new("UIPadding")
	uIPadding.PaddingLeft = UDim.new(0.04, 0)
	uIPadding.PaddingRight = UDim.new(0.04, 0)
	uIPadding.PaddingTop = UDim.new(0.12, 0)
	uIPadding.PaddingBottom = UDim.new(0.12, 0)
	uIPadding.Parent = textBox
	local uIStroke = Instance.new("UIStroke")
	uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uIStroke.Color = Color3.fromRGB(90, 50, 30)
	uIStroke.Thickness = 2
	uIStroke.Parent = textBox
	textBox.Parent = holder
	return textBox
end

local function BuildFeedback()
	local feedback = holder:FindFirstChild("Feedback")

	if feedback and feedback:IsA("TextLabel") then
		return feedback
	end

	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Feedback"
	textLabel.AnchorPoint = Vector2.new(0.5, 0)
	textLabel.Position = UDim2.fromScale(0.5, 0.61)
	textLabel.Size = UDim2.fromScale(0.9, 0.11)
	textLabel.BackgroundTransparency = 1
	textLabel.FontFace = rbxassetfontsfamiliesComicNeueAngularjson
	textLabel.Text = ""
	textLabel.TextColor3 = color3
	textLabel.TextScaled = true
	textLabel.TextWrapped = true
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Thickness = 1.5
	uIStroke.Parent = textLabel
	textLabel.Parent = holder
	return textLabel
end

local input = BuildInput()
input.PlaceholderText = "Letters only..."
local feedback2 = BuildFeedback()
local position = feedback2.Position
local position2 = parent.Position
local v3 = nil
local v4 = "Empty"
local v5 = ""
local v6 = nil
local count = 0
local v7 = false
local v8 = false
local v9 = nil
local rotation = nil
local v10 = false
local v11 = nil
local thread = nil
local v12 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function PlayClick()
	local SFX = SoundService:FindFirstChild("SFX")
	local click = SFX and SFX:FindFirstChild("Click")

	if click and click:IsA("Sound") then
		click:Play()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function IsNameTag(instance)
	return instance.Name == "NameTag" or instance:HasTag("NameTag")
end

local function HoldingNameTag()
	local character = localPlayer.Character
	local tool = character and character:FindFirstChildOfClass("Tool")
	return tool ~= nil and IsNameTag(tool)
end

local function SpeciesName(instance)
	local petName = instance:GetAttribute("PetName")

	if type(petName) == "string" then
		return petName
	end

	return instance.Name
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetNickname(petKey: string)
	local petNicknames = localPlayer:FindFirstChild("PetNicknames")
	local stringValue = petNicknames and petNicknames:FindFirstChild(petKey)

	if stringValue and stringValue:IsA("StringValue") and stringValue.Value ~= "" then
		return stringValue.Value
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SetFeedback(text: string, textColor: Color3)
	feedback2.Text = text
	feedback2.TextColor3 = textColor
end

local function SetState(p: string, text: string, p2: string?)
	v4 = p
	v5 = text
	v6 = p2
	mainTitle.Text = (p ~= "Valid" or not p2) and "Name your pet" or `Name your pet "{p2}"`

	if p == "Empty" then
		SetFeedback("", color3) -- equivalent call inferred; original call site unknown
	elseif p == "Checking" then
		SetFeedback(text, color3) -- equivalent call inferred; original call site unknown
	elseif p == "Valid" then
		SetFeedback(text, color) -- equivalent call inferred; original call site unknown
	else
		SetFeedback(text, color2) -- equivalent call inferred; original call site unknown
	end
end

local function Shake()
	if thread and coroutine.status(thread) == "suspended" then
		task.cancel(thread)
	end

	thread = task.spawn(function()
		for _, v13 in {
			8,
			-8,
			6,
			-6,
			3,
			0
		} do
			feedback2.Position = position + UDim2.fromOffset(v13, 0)
			task.wait(0.04)
		end

		feedback2.Position = position
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SetPromptsEnabled(enabled: boolean)
	for _, v13 in v12 do
		if v13.Parent then
			v13.Enabled = enabled
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ShowError(text: string)
	SetFeedback(text, color2) -- equivalent call inferred; original call site unknown
	Shake()
end

local function ScheduleCheck()
	count += 1
	local v13 = count
	local text = input.Text
	local normalized = PetNameRules.Normalize(text)

	if normalized == "" then
		v4 = "Empty"
		v5 = ""
		v6 = nil
		mainTitle.Text = "Name your pet"
		SetFeedback("", color3) -- equivalent call inferred; original call site unknown
	else
		local v14, v15 = PetNameRules.Check(normalized)

		if v14 then
			v4 = "Checking"
			v5 = "Checking..."
			v6 = nil
			mainTitle.Text = "Name your pet"
			SetFeedback("Checking...", color3) -- equivalent call inferred; original call site unknown
			task.delay(0.4, function()
				if v13 ~= count or not v3 then
					return
				end

				local success, result, text2 = pcall(function()
					return checkPetName:InvokeServer(text)
				end)

				if v13 ~= count or not v3 then
					return
				end

				if success and type(result) == "boolean" and type(text2) == "string" then
					if result then
						v4 = "Valid"
						v5 = "Name is available!"
						v6 = text2
						mainTitle.Text = not text2 and "Name your pet" or `Name your pet "{text2}"`
						SetFeedback("Name is available!", color) -- equivalent call inferred; original call site unknown
					else
						v4 = "Invalid"
						v5 = text2
						v6 = nil
						mainTitle.Text = "Name your pet"
						SetFeedback(text2, color2) -- equivalent call inferred; original call site unknown
					end
				else
					v4 = "Invalid"
					v5 = "Couldn't check name, try again"
					v6 = nil
					mainTitle.Text = "Name your pet"
					SetFeedback("Couldn't check name, try again", color2) -- equivalent call inferred; original call site unknown
				end
			end)
		else
			local text2 = v15 or "That name isn't allowed"
			v4 = "Invalid"
			v5 = text2
			v6 = nil
			mainTitle.Text = "Name your pet"
			SetFeedback(text2, color2) -- equivalent call inferred; original call site unknown
		end
	end
end

local function SetShown(flag: boolean)
	if v10 == flag then
		return
	end

	v10 = flag

	if v11 then
		v11:Cancel()
		v11 = nil
	end

	local uDim = UDim2.new(position2.X.Scale, position2.X.Offset, -0.5, 0)

	if flag then
		parent.Position = uDim
		parent.Visible = true
	end

	local attribute = parent:GetAttribute(flag and "SlideInSeconds" or "SlideOutSeconds")
	local v13 = math.clamp(type(attribute) ~= "number" and 0.3 or attribute, 0.05, 2)
	local quad = Enum.EasingStyle.Quad
	local v16

	if flag then
		v16 = Enum.EasingDirection.Out
	else
		v16 = Enum.EasingDirection.In
	end

	local tweenInfo = TweenInfo.new(v13, quad, v16)

	if flag then
		uDim = position2
	end

	local v18 = TweenService:Create(parent, tweenInfo, {
		Position = uDim
	})
	v11 = v18
	v18.Completed:Once(function(p)
		if v11 ~= v18 then
			return
		end

		v11 = nil

		if p == Enum.PlaybackState.Completed and not v10 then
			parent.Visible = false
			parent.Position = position2
		end
	end)
	v18:Play()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ReleaseFacing()
	local v13 = v9
	v9 = nil
	rotation = nil

	if v13 then
		v13:SetAttribute("NamingHold", nil)
	end
end

local function HoldFacing(instance)
	if v9 == instance then
		return
	end

	local v13 = v9

	if v13 and rotation and v13.Parent then
		v13:PivotTo(CFrame.new(v13:GetPivot().Position) * rotation)
	end

	ReleaseFacing() -- equivalent call inferred; original call site unknown
	v9 = instance
	rotation = instance:GetPivot().Rotation
	instance:SetAttribute("NamingHold", true)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ShowMessage(p: string)
	pcall(function()
		local Handler = require(localPlayer.PlayerGui.Reusable.GameMessages.Handler)
		Handler:AddMessage(p)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Close()
	if not v3 then
		return
	end

	v3 = nil
	count += 1
	input:ReleaseFocus()

	if Confirmation.IsOpen() then
		Confirmation.Cancel()
	end

	SetShown(false)
	local character = localPlayer.Character
	local tool = character and character:FindFirstChildOfClass("Tool")
	SetPromptsEnabled(tool ~= nil and IsNameTag(tool)) -- equivalent call inferred; original call site unknown
end

local function Open(petKey: string, instance)
	v3 = {
		PetKey = petKey,
		Model = instance
	}
	local v13 = title
	local petName = instance:GetAttribute("PetName")

	if type(petName) ~= "string" then
		petName = instance.Name
	end

	v13.Text = petName
	HoldFacing(instance)
	input.Text = ""
	count += 1
	v4 = "Empty"
	v5 = ""
	v6 = nil
	mainTitle.Text = "Name your pet"
	SetFeedback("", color3) -- equivalent call inferred; original call site unknown
	SetPromptsEnabled(false) -- equivalent call inferred; original call site unknown
	SetShown(true)
	input:CaptureFocus()
end

local function Submit()
	local v13 = v3

	if not v13 or v7 then
		return
	end

	if v4 == "Empty" then
		ShowError("Enter a name first") -- equivalent call inferred; original call site unknown
	elseif v4 == "Checking" then
		ShowError("Still checking that name...") -- equivalent call inferred; original call site unknown
	elseif v4 == "Invalid" or not v6 then
		ShowError(v5 == "" and "That name isn't allowed" or v5) -- equivalent call inferred; original call site unknown
	else
		local v14 = v6
		v7 = true
		input:ReleaseFocus()
		SetShown(false)
		local ask = Confirmation.Ask(`Name your pet "{v14}"? This uses your Name Tag.`, {
			Title = "Name Tag",
			YesText = "Confirm",
			NoText = "Cancel"
		})

		if v3 ~= v13 then
			v7 = false
		elseif ask then
			v8 = true
			local success, result, v15 = pcall(function()
				return namePet:InvokeServer(v13.PetKey, v14)
			end)
			v8 = false
			v7 = false

			if v3 ~= v13 then
				return
			end

			if success and result == true then
				Close() -- equivalent call inferred; original call site unknown
			else
				SetShown(true)
				ShowError((not success or type(v15) ~= "string") and "Something went wrong, try again" or v15) -- equivalent call inferred; original call site unknown
			end
		else
			v7 = false
			Close() -- equivalent call inferred; original call site unknown
		end
	end
end

input:GetPropertyChangedSignal("Text"):Connect(function()
	if v3 then
		ScheduleCheck()
	end
end)
input.FocusLost:Connect(function(flag: boolean)
	if flag and v3 then
		task.spawn(Submit)
	end
end)
yes.Activated:Connect(function()
	PlayClick() -- equivalent call inferred; original call site unknown
	task.spawn(Submit)
end)
no.Activated:Connect(function()
	PlayClick() -- equivalent call inferred; original call site unknown
	Close() -- equivalent call inferred; original call site unknown
end)

local function TurnToward(instance, cframe: CFrame, dt: number)
	local pivot = instance:GetPivot()
	local rotation2 = pivot.Rotation
	local lerped = rotation2:Lerp(cframe, 1 - math.exp(dt * -8))
	instance:PivotTo(CFrame.new(pivot.Position) * lerped)
	return rotation2.LookVector:Dot(cframe.LookVector) > 0.9995
end

RunService.RenderStepped:Connect(function(dt: number)
	local v13 = v3
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if v13 and not v8 then
		local model = v13.Model
		local character2 = localPlayer.Character
		local tool = character2 and character2:FindFirstChildOfClass("Tool")
		local v14

		if tool == nil then
			v14 = false
		else
			v14 = IsNameTag(tool)
		end

		if v14 and model.Parent and humanoidRootPart and humanoidRootPart:IsA("BasePart") then
			if (model:GetPivot().Position - humanoidRootPart.Position).Magnitude > math.max(model:GetScale(), 1) * 25 then
				Close() -- equivalent call inferred; original call site unknown
				ShowMessage("You walked too far from your pet") -- equivalent call inferred; original call site unknown
			end
		else
			Close() -- equivalent call inferred; original call site unknown
		end
	end

	local v14 = v9

	if not v14 then
		return
	end

	if v14.Parent then
		if v3 and v3.Model == v14 and humanoidRootPart and humanoidRootPart:IsA("BasePart") then
			local v15 = (humanoidRootPart.Position - v14:GetPivot().Position) * createVector(1, 0, 1)

			if v15.Magnitude > 0.05 then
				TurnToward(v14, CFrame.lookAt(createVector(0, 0, 0), v15.Unit), dt)
			end
		elseif rotation and TurnToward(v14, rotation, dt) then
			v14:PivotTo(CFrame.new(v14:GetPivot().Position) * rotation)
			ReleaseFacing() -- equivalent call inferred; original call site unknown
		elseif not rotation then
			ReleaseFacing() -- equivalent call inferred; original call site unknown
		end
	else
		ReleaseFacing() -- equivalent call inferred; original call site unknown
	end
end)

local function RefreshPrompts()
	local character = localPlayer.Character
	local tool = character and character:FindFirstChildOfClass("Tool")
	local v13

	if tool == nil then
		v13 = false
	else
		v13 = IsNameTag(tool)
	end

	local v14 = {}

	for _, v15 in PetRenderer.GetAll() do
		local model = v15.Model

		if not (v15.OwnerUserId == localPlayer.UserId and typeof(model) == "Instance" and model:IsA("Model") and model.Parent) then
			continue
		end

		if not model.PrimaryPart then
			continue
		end

		local petKey = v15.PetKey

		if type(petKey) ~= "string" then
			continue
		end

		v14[petKey] = true
		local clone = v12[petKey]

		if not (clone and clone.Parent) then
			clone = feed:Clone()
			assert(clone:IsA("ProximityPrompt"))
			clone.Name = "NameTagPrompt"
			clone.ActionText = "Name"
			clone.Enabled = false
			clone.Parent = model.PrimaryPart
			local model2 = model
			local petKey2 = petKey
			clone.Triggered:Connect(function()
				local character2 = localPlayer.Character
				local tool2 = character2 and character2:FindFirstChildOfClass("Tool")
				local v18

				if tool2 == nil then
					v18 = false
				else
					v18 = IsNameTag(tool2)
				end

				if v18 and model2.Parent then
					Open(petKey2, model2)
				end
			end)
			v12[petKey] = clone
		end

		clone.Enabled = v13 and v3 == nil

		if not v13 then
			continue
		end

		local display = PetNameRules.Display
		local nickname = GetNickname(petKey) -- equivalent call inferred; original call site unknown
		local petName = model:GetAttribute("PetName")

		if type(petName) ~= "string" then
			petName = model.Name
		end

		clone.ObjectText = display(nickname, petName)
	end

	for k, v15 in v12 do
		if v14[k] then
			continue
		end

		v12[k] = nil
		v15:Destroy()
	end
end

local function HookCharacter(character)
	character.ChildAdded:Connect(function()
		task.defer(RefreshPrompts)
	end)
	character.ChildRemoved:Connect(function()
		task.defer(RefreshPrompts)
	end)
	task.defer(RefreshPrompts)
end

localPlayer.CharacterAdded:Connect(HookCharacter)

if localPlayer.Character then
	HookCharacter(localPlayer.Character)
end

localPlayer.CharacterRemoving:Connect(Close)
parent.Visible = false
task.spawn(function()
	while true do
		task.wait(0.5)
		RefreshPrompts()
	end
end)