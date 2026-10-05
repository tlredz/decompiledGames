local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepadUI = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("GamepadUI"))
local DialogueModule = {}
local TweenService = game:GetService("TweenService")
game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local remotes = script.Parent.Parent:WaitForChild("Remotes")
local dialogueSend = remotes:WaitForChild("DialogueSend")
local dialogueSelect = remotes:WaitForChild("DialogueSelect")
local dialogueRegistered = remotes:WaitForChild("DialogueRegistered")
local requestDialogues = remotes:WaitForChild("RequestDialogues")
local dialogueUpdate = remotes:WaitForChild("DialogueUpdate")
local dialogueTypingDone = remotes:WaitForChild("DialogueTypingDone")
local dialogue = script.Parent.Parent:WaitForChild("Dialogue")
local v = nil
local clone = nil
local SFX = game.SoundService:WaitForChild("SFX")
local count = 0
local v2 = 0
local count2 = 0
local flag = false
local count3 = 0
local flag2 = false
local count4 = 0

local function SetupDialogueModel(model)
	if not (model and model:IsA("Model")) then
		return
	end

	local primaryPart = model:FindFirstChild("PrimaryPart") or model.PrimaryPart

	if not primaryPart then
		return
	end

	local proximityPrompt = primaryPart:FindFirstChildOfClass("ProximityPrompt")

	if not proximityPrompt or model:FindFirstChildOfClass("Highlight") then
		return
	end

	local highlight = Instance.new("Highlight")
	highlight.Adornee = model
	highlight.FillTransparency = 1
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.Enabled = false
	highlight.Parent = model
	proximityPrompt.PromptShown:Connect(function()
		highlight.Enabled = true
	end)
	proximityPrompt.PromptHidden:Connect(function()
		highlight.Enabled = false
	end)
end

local function MakeCharacterSay(instance, text)
	if not instance then
		return
	end

	local head = instance:FindFirstChild("Head") or instance:FindFirstChild("HumanoidRootPart")

	if not head then
		return
	end

	local clone2 = dialogue:Clone()
	clone2.Parent = head
	clone2.Frame.Main.Visible = true
	clone2.Frame.Main.Size = UDim2.new(1, 0, 1, 0)
	local textLabel = clone2.Frame.Main:FindFirstChildWhichIsA("TextLabel")

	if not textLabel then
		return
	end

	textLabel.RichText = true
	textLabel.Text = text
	textLabel.MaxVisibleGraphemes = 0
	local v3 = (text or ""):gsub("<[^>]->", "")
	local v4 = utf8.len(v3) or #v3
	local dialogue2 = SFX:FindFirstChild("Dialogue")
	count3 += 1
	local v5 = count3
	flag = true

	for i = 1, v4 do
		textLabel.MaxVisibleGraphemes = i

		if dialogue2 then
			dialogue2:Play()
		end

		task.wait(0.021)
	end

	textLabel.MaxVisibleGraphemes = -1

	if count3 == v5 then
		flag = false
	end

	task.wait(2)
	TweenService:Create(clone2.Frame.Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Size = UDim2.new(0, 0, 0, 0)
	}):Play()
	task.delay(0.35, function()
		clone2:Destroy()
	end)
end

local function ResetCameraFOV()
	local currentCamera = workspace.CurrentCamera

	if not currentCamera or currentCamera.FieldOfView < 65 then
		return
	end

	TweenService:Create(currentCamera, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		FieldOfView = 70
	}):Play()
end

local function PlayDialogue(proximityPrompt, head, list)
	if proximityPrompt then
		proximityPrompt:SetAttribute("InDialogue", true)
	end

	local dialogue2 = head.Parent:FindFirstChild("Head") and head.Parent.Head:FindFirstChild("Dialogue")

	if not dialogue2 then
		return
	end

	dialogue2:SetAttribute("CloseId", (dialogue2:GetAttribute("CloseId") or 0) + 1)
	local v3 = (dialogue2:GetAttribute("TypingId") or 0) + 1
	dialogue2:SetAttribute("TypingId", v3)
	local text = list[math.random(1, #list)]
	dialogue2.Frame.Main.Visible = true
	dialogue2.Frame.Main.Size = UDim2.new(0, 0, 0, 0)
	TweenService:Create(dialogue2.Frame.Main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(1, 0, 1, 0)
	}):Play()
	TweenService:Create(workspace.CurrentCamera, TweenInfo.new(3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		FieldOfView = 65
	}):Play()
	local textLabel = dialogue2.Frame.Main:FindFirstChildWhichIsA("TextLabel")

	if not textLabel then
		return
	end

	textLabel.RichText = true
	textLabel.Text = text
	textLabel.MaxVisibleGraphemes = 0
	local v5 = (text or ""):gsub("<[^>]->", "")
	local v6 = utf8.len(v5) or #v5
	local dialogue3 = SFX:FindFirstChild("Dialogue")

	for i = 1, v6 do
		if dialogue2:GetAttribute("TypingId") ~= v3 then
			break
		end

		textLabel.MaxVisibleGraphemes = i

		if dialogue3 then
			dialogue3:Play()
		end

		task.wait(0.021)
	end

	if dialogue2:GetAttribute("TypingId") == v3 then
		textLabel.MaxVisibleGraphemes = -1
	end
end

local function CloseDialogueUI(model, callback)
	if model then
		local head = model:FindFirstChild("Head")

		if head then
			local primaryPart = model.PrimaryPart

			if primaryPart then
				local dialogue2 = head:FindFirstChild("Dialogue")

				if dialogue2 and dialogue2:FindFirstChild("Frame") then
					local v3 = (dialogue2:GetAttribute("CloseId") or 0) + 1
					dialogue2:SetAttribute("CloseId", v3)
					local main = dialogue2.Frame.Main
					main.Visible = true
					TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
						Size = UDim2.new(0, 0, 0, 0)
					}):Play()
					local textLabel = main:FindFirstChildWhichIsA("TextLabel")

					if textLabel then
						TweenService:Create(
							textLabel,
							TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
							{
								TextTransparency = 1
							}
						):Play()
					end

					task.delay(0.45, function()
						if dialogue2:GetAttribute("CloseId") ~= v3 then
							return
						end

						main.Visible = false

						if textLabel then
							textLabel.TextTransparency = 0
						end

						local proximityPrompt = primaryPart:FindFirstChildOfClass("ProximityPrompt")

						if proximityPrompt then
							proximityPrompt:SetAttribute("InDialogue", false)
						end

						if callback then
							callback()
						end
					end)
				elseif callback then
					callback()
				end

				if clone then
					count += 1
					local v3 = count

					for _, button in ipairs(clone:GetChildren()) do
						if button:IsA("TextButton") and button.Visible then
							TweenService:Create(
								button,
								TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
								{
									Size = UDim2.new(1, 0, 0.01, 0)
								}
							):Play()
						end
					end

					task.delay(0.45, function()
						if count ~= v3 then
							return
						end

						clone.Enabled = false
					end)
				end

				if workspace.CurrentCamera.FieldOfView >= 60 then
					ResetCameraFOV()
				end

				return
			end
		end

		if callback then
			callback()
		end
	elseif callback then
		callback()
	end
end

function DialogueModule.SelectOption(p)
	if not v or flag2 then
		return
	end

	flag2 = true
	dialogueSelect:FireServer(v.Model, p)
	local character = localPlayer.Character

	if character and p then
		task.spawn(MakeCharacterSay, character, p)
	end
end

local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local v3 = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local function EnsureOptionsUI()
	local playerGui = localPlayer:FindFirstChild("PlayerGui")

	if not playerGui then
		return clone
	end

	if not clone or clone.Parent ~= playerGui then
		local options = playerGui:FindFirstChild("Options")

		if options then
			clone = options
		else
			local StarterGui = game:GetService("StarterGui")
			clone = StarterGui:WaitForChild("Options"):Clone()
			clone.Parent = playerGui
		end
	end

	if not clone:IsA("BillboardGui") then
		return clone
	end

	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		clone.Adornee = humanoidRootPart
	end

	if v3 then
		clone.StudsOffset = createVector(0, 2, 0)
	end

	return clone
end

local v4 = {}
local v5 = 0
local flag3 = false
local v6 = 0

local function HighlightGamepadOption(p)
	if #v4 == 0 then
		return
	end

	local v7 = (p - 1) % #v4 + 1

	if v7 == v5 then
		return
	end

	local v8 = v4[v5]

	if v8 and v8.Button.Parent then
		v8.Unhighlight()
	end

	v5 = v7
	local v9 = v4[v5]

	if v9 and v9.Button.Parent then
		v9.Highlight()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ClearGamepadOptions()
	table.clear(v4)
	v5 = 0
	v6 = 0

	if flag3 then
		ContextActionService:UnbindAction("DialogueOptionMove")
		ContextActionService:UnbindAction("DialogueOptionPick")
		flag3 = false
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CommitGamepadOption()
	local v7 = v4[v5]

	if not (v7 and v7.Button.Parent and v7.Button.Active) then
		return
	end

	local commit = v7.Commit
	ClearGamepadOptions() -- equivalent call inferred; original call site unknown

	if commit then
		commit()
	end
end

local function BindGamepadOptions()
	if flag3 or #v4 == 0 or not UserInputService.GamepadEnabled or flag2 then
		return
	end

	flag3 = true
	v5 = 0
	HighlightGamepadOption(1)
	ContextActionService:BindAction("DialogueOptionMove", function(_, p, p2)
		if GamepadUI.CursorActive() then
			return Enum.ContextActionResult.Pass
		end

		if p ~= Enum.UserInputState.Change then
			return Enum.ContextActionResult.Sink
		end

		local Y = p2.Position.Y

		if math.abs(Y) < 0.6 then
			v6 = 0
			return Enum.ContextActionResult.Sink
		end

		if os.clock() < v6 then
			return Enum.ContextActionResult.Sink
		end

		v6 = os.clock() + 0.18
		HighlightGamepadOption(v5 + (Y > 0 and -1 or 1))
		return Enum.ContextActionResult.Sink
	end, false, Enum.KeyCode.Thumbstick2)
	ContextActionService:BindAction("DialogueOptionPick", function(_, p)
		if GamepadUI.CursorActive() then
			return Enum.ContextActionResult.Pass
		end

		if p == Enum.UserInputState.Begin then
			CommitGamepadOption() -- equivalent call inferred; original call site unknown
		end

		return Enum.ContextActionResult.Sink
	end, false, Enum.KeyCode.ButtonA)
end

UserInputService.GamepadConnected:Connect(function()
	if #v4 > 0 then
		BindGamepadOptions()
	end
end)

local function CreateOptionsUI(options)
	ClearGamepadOptions() -- equivalent call inferred; original call site unknown
	EnsureOptionsUI()

	if not clone then
		return
	end

	flag2 = false
	count4 += 1
	local v7 = count4
	count += 1

	for _, button in ipairs(clone:GetChildren()) do
		if button:IsA("TextButton") and button.Name ~= "Template" then
			button:Destroy()
		end
	end

	local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local v8 = 1

	for _, v9 in ipairs(options) do
		local text = v9.Text
		local clone2 = clone.Template:Clone()
		clone2.Name = text
		clone2.Visible = true
		clone2.Index.Text = tostring(v8) .. "."
		clone2.Option.Text = text
		clone2.Parent = clone
		clone2.Size = UDim2.new(1, 0, 0.01, 0)
		clone2.ClipsDescendants = false
		local stroke = clone2:FindFirstChild("Stroke")
		local index = clone2:FindFirstChild("Index")
		local option = clone2:FindFirstChild("Option")
		local imageColor3 = stroke and stroke.ImageColor3 or Color3.fromRGB(150, 150, 150)
		local textColor3 = index and index.TextColor3 or Color3.fromRGB(200, 200, 200)
		local color = Color3.fromRGB(255, 255, 255)
		local ChooseOption
		local uDim = UDim2.new(0.125, 0, 0.5, 0)
		local uDim2 = UDim2.new(0.175, 0, 0.5, 0)

		if option then
			option.Position = uDim
		end

		task.delay((v8 - 1) * 0.08, function()
			TweenService:Create(clone2, tweenInfo, {
				Size = UDim2.new(1, 0, 0.125, 0)
			}):Play()
		end)
		clone2.MouseEnter:Connect(function()
			if stroke then
				TweenService:Create(stroke, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					ImageColor3 = color
				}):Play()
			end

			if index then
				TweenService:Create(index, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					TextColor3 = color
				}):Play()
			end

			if option then
				TweenService:Create(option, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					Position = uDim2
				}):Play()
			end
		end)
		local v16 = stroke
		local v18 = index
		local v20 = option
		clone2.MouseLeave:Connect(function()
			if v16 then
				TweenService:Create(v16, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					ImageColor3 = imageColor3
				}):Play()
			end

			if v18 then
				TweenService:Create(v18, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					TextColor3 = textColor3
				}):Play()
			end

			if v20 then
				TweenService:Create(v20, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					Position = uDim
				}):Play()
			end
		end)
		local v22 = stroke
		local v23 = color
		local v24 = index
		local v25 = option
		local position = uDim2
		local v27 = stroke
		local imageColor = imageColor3
		local v29 = index
		local textColor = textColor3
		local v31 = option
		local position2 = uDim
		table.insert(v4, {
			Button = clone2,
			Commit = function()
				ChooseOption()
			end,
			Highlight = function()
				if v22 then
					TweenService:Create(v22, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						ImageColor3 = v23
					}):Play()
				end

				if v24 then
					TweenService:Create(v24, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						TextColor3 = v23
					}):Play()
				end

				if v25 then
					TweenService:Create(v25, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						Position = position
					}):Play()
				end
			end,
			Unhighlight = function()
				if v27 then
					TweenService:Create(v27, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						ImageColor3 = imageColor
					}):Play()
				end

				if v29 then
					TweenService:Create(v29, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						TextColor3 = textColor
					}):Play()
				end

				if v31 then
					TweenService:Create(v31, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						Position = position2
					}):Play()
				end
			end
		})
		local v33 = clone2
		local v34 = v9

		ChooseOption = function()
			if not (v7 == count4 and clone) then
				return
			end

			for i, button in ipairs(clone:GetChildren()) do
				if not (button:IsA("TextButton") and button.Name ~= "Template") then
					continue
				end

				button.Active = false
				button.AutoButtonColor = false
			end

			local tweenInfo2 = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

			for i, button in ipairs(clone:GetChildren()) do
				if button:IsA("TextButton") and button ~= v33 and button.Name ~= "Template" then
					TweenService:Create(button, tweenInfo2, {
						Size = UDim2.new(1, 0, 0.0001, 0)
					}):Play()
				end
			end

			count += 1
			local v35 = count
			task.delay(0.5, function()
				if count ~= v35 then
					return
				end

				TweenService:Create(v33, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
					Size = UDim2.new(1, 0, 0.0001, 0)
				}):Play()
				task.delay(0.3, function()
					if count ~= v35 then
						return
					end

					clone.Enabled = false
				end)
			end)
			DialogueModule.SelectOption(v34.Text)
		end

		clone2.Activated:Connect(ChooseOption)
		v8 += 1
	end

	clone.Enabled = true
	BindGamepadOptions()
	GamepadUI.Focus(clone)
end

local function HideOptionsImmediately()
	ClearGamepadOptions() -- equivalent call inferred; original call site unknown

	if not clone then
		return
	end

	count += 1
	count4 += 1

	for _, button in ipairs(clone:GetChildren()) do
		if button:IsA("TextButton") and button.Name ~= "Template" then
			button:Destroy()
		end
	end

	clone.Enabled = false
end

local fn

fn = function()
	if not v then
		return
	end

	local model = v.Model
	count2 += 1
	count3 += 1
	flag = false
	HideOptionsImmediately()
	v = nil
	GamepadUI.SetContext("Dialogue", v ~= nil, function()
		if fn then
			fn()
		end
	end, clone)
	CloseDialogueUI(model)
	ResetCameraFOV()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function OnCharacterAdded(character)
	character:WaitForChild("HumanoidRootPart", 10)
	local optionsUI = EnsureOptionsUI()

	if optionsUI then
		optionsUI.Enabled = false
	end
end

if localPlayer.Character then
	OnCharacterAdded(localPlayer.Character) -- equivalent call inferred; original call site unknown
end

localPlayer.CharacterAdded:Connect(OnCharacterAdded)
RunService.Heartbeat:Connect(function()
	if not v then
		return
	end

	local model = v.Model

	if model and model.Parent then
		local primaryPart = model.PrimaryPart
		local character = localPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if not (primaryPart and humanoidRootPart) then
			return
		end

		local proximityPrompt = primaryPart:FindFirstChildOfClass("ProximityPrompt")

		if (proximityPrompt and proximityPrompt.MaxActivationDistance or 15) + 5 < (humanoidRootPart.Position - primaryPart.Position).Magnitude then
			count2 += 1
			v = nil
			GamepadUI.SetContext("Dialogue", v ~= nil, function()
				if fn then
					fn()
				end
			end, clone)
			CloseDialogueUI(model)
			ResetCameraFOV()
		end
	else
		count2 += 1
		v = nil
		GamepadUI.SetContext("Dialogue", v ~= nil, function()
			if fn then
				fn()
			end
		end, clone)
		ResetCameraFOV()
	end
end)
dialogueSend.OnClientEvent:Connect(function(data)
	local now = tick()

	if now - v2 < 0.2 then
		return
	end

	v2 = now
	count2 += 1
	local v7 = count2

	if v then
		CloseDialogueUI(v.Model)
		ResetCameraFOV()
		v = nil
		GamepadUI.SetContext("Dialogue", v ~= nil, function()
			if fn then
				fn()
			end
		end, clone)
	end

	v = data
	GamepadUI.SetContext("Dialogue", v ~= nil, function()
		if fn then
			fn()
		end
	end, clone)
	local model = data.Model
	local head = model:FindFirstChild("Head")

	if not head then
		return
	end

	local primaryPart = model.PrimaryPart

	if not primaryPart then
		return
	end

	local proximityPrompt = primaryPart:FindFirstChildOfClass("ProximityPrompt")
	HideOptionsImmediately()
	PlayDialogue(proximityPrompt, head, { data.Text })

	if count2 ~= v7 then
		return
	end

	if data.AwaitComplete then
		dialogueTypingDone:FireServer(data.Model, data.CompleteToken)
	end

	if data.Options and #data.Options > 0 then
		CreateOptionsUI(data.Options)
		return
	end

	if data.Text and data.Text ~= "" and data.Text ~= " " then
		task.delay(2.5, function()
			if count2 ~= v7 then
				return
			end

			CloseDialogueUI(data.Model)
			ResetCameraFOV()
			v = nil
			GamepadUI.SetContext("Dialogue", v ~= nil, function()
				if fn then
					fn()
				end
			end, clone)
		end)
		return
	end

	CloseDialogueUI(data.Model)
	v = nil
	GamepadUI.SetContext("Dialogue", v ~= nil, function()
		if fn then
			fn()
		end
	end, clone)
end)
dialogueRegistered.OnClientEvent:Connect(function(p)
	SetupDialogueModel(p)
end)
dialogueUpdate.OnClientEvent:Connect(function(data)
	if not v then
		return
	end

	count2 += 1
	local v7 = count2
	local model = data.Model

	if not model then
		return
	end

	local head = model:FindFirstChild("Head")

	if not head then
		return
	end

	local dialogue2 = head:FindFirstChild("Dialogue")

	if not dialogue2 then
		return
	end

	local textLabel = dialogue2.Frame.Main:FindFirstChildWhichIsA("TextLabel")

	if not textLabel then
		return
	end

	local v8 = (dialogue2:GetAttribute("TypingId") or 0) + 1
	dialogue2:SetAttribute("TypingId", v8)

	if v.Model == data.Model then
		HideOptionsImmediately()
		local lastTime = os.clock()

		while flag do
			if count2 ~= v7 then
				return
			end

			if os.clock() - lastTime > 5 then
				break
			else
				task.wait()
			end
		end

		task.wait(0.73)

		if count2 ~= v7 then
			return
		end

		textLabel.Text = data.Text
		textLabel.MaxVisibleGraphemes = 0
		local dialogue3 = SFX:FindFirstChild("Dialogue")
		local v9 = (data.Text or ""):gsub("<[^>]->", "")

		for i = 1, utf8.len(v9) or #v9 do
			if dialogue2:GetAttribute("TypingId") ~= v8 then
				break
			end

			textLabel.MaxVisibleGraphemes = i

			if dialogue3 then
				dialogue3:Play()
			end

			task.wait(0.021)
		end

		if dialogue2:GetAttribute("TypingId") == v8 then
			textLabel.MaxVisibleGraphemes = -1
		end

		if count2 ~= v7 then
			return
		end

		if data.AwaitComplete then
			dialogueTypingDone:FireServer(data.Model, data.CompleteToken)
		end

		if data.Options and #data.Options > 0 then
			CreateOptionsUI(data.Options)
			return
		end

		if data.Text and data.Text ~= "" and data.Text ~= " " then
			task.delay(2.5, function()
				if count2 ~= v7 then
					return
				end

				CloseDialogueUI(data.Model)
				ResetCameraFOV()
				v = nil
				GamepadUI.SetContext("Dialogue", v ~= nil, function()
					if fn then
						fn()
					end
				end, clone)
			end)
			return
		end

		CloseDialogueUI(data.Model)
		v = nil
		GamepadUI.SetContext("Dialogue", v ~= nil, function()
			if fn then
				fn()
			end
		end, clone)
	else
		CloseDialogueUI(v.Model)
		ResetCameraFOV()
		v = nil
		GamepadUI.SetContext("Dialogue", v ~= nil, function()
			if fn then
				fn()
			end
		end, clone)
	end
end)
task.spawn(function()
	local success, result = pcall(function()
		return requestDialogues:InvokeServer()
	end)

	if not success or typeof(result) ~= "table" then
		warn("Failed to request dialogues")
		return
	end

	for _, v7 in ipairs(result) do
		SetupDialogueModel(v7)
	end
end)
return DialogueModule