local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local UserInputService = game:GetService("UserInputService")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Trove = require(packages.Trove)
local utils = ReplicatedStorage:WaitForChild("Utils")
local CharacterUtils = require(utils.CharacterUtils)
local classes = ReplicatedStorage:WaitForChild("Classes")
local AnimatedButton = require(classes.AnimatedButton)
local datas = ReplicatedStorage:WaitForChild("Datas")
local Dialogues = require(datas.Dialogues)
local controllers = ReplicatedStorage:WaitForChild("Controllers")
local SoundController = require(controllers.SoundController)
local maid = Trove.new()
local localPlayer = Players.LocalPlayer
local dialogAnswers = localPlayer.PlayerGui:WaitForChild("DialogAnswers")
local v = false
local DialogController = {}

local function TypeEffect(clone, duration: number)
	local thread = coroutine.running()
	local tweenInfo = TweenInfo.new(duration or 1, Enum.EasingStyle.Linear)
	local maxVisibleGraphemesChangedConnection = clone:GetPropertyChangedSignal("MaxVisibleGraphemes"):Connect(function()
		SoundController:PlaySound("Sounds.Sfx.Type")
	end)
	local tween = TweenService:Create(clone, tweenInfo, {
		MaxVisibleGraphemes = #clone.Text:gsub("<.->", "")
	})
	tween.Completed:Once(function()
		maxVisibleGraphemesChangedConnection:Disconnect()
		coroutine.resume(thread)
	end)
	tween:Play()
	return coroutine.yield()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SetInDialogue(flag: boolean)
	ProximityPromptService.Enabled = not flag
	v = flag
end

-- equivalent calls inferred from this helper; original call sites unknown
local function FadeOutAndDestroy(clone, duration: number?)
	task.spawn(function()
		if duration then
			task.wait(duration)
		end

		local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Linear)
		local tween = TweenService:Create(clone, tweenInfo, {
			TextTransparency = 1
		})
		local uIStroke = clone:FindFirstChildOfClass("UIStroke")
		local v2

		if uIStroke then
			v2 = TweenService:Create(uIStroke, tweenInfo, {
				Transparency = 1
			})
		end

		tween:Play()

		if v2 then
			v2:Play()
		end

		tween.Completed:Once(function()
			clone:Destroy()
		end)
	end)
end

function DialogController.GetDialogText(_)
	return script.DialogText:Clone()
end

function DialogController:StartDialog(p: string, value: number?, parent, ...)
	if v == true then
		return
	end

	local v2 = { ... }
	local dialogue = Dialogues[p]

	if not dialogue then
		return
	end

	local dialog = dialogue.Dialogs[value or 1]

	if not dialog then
		return
	end

	SetInDialogue(true) -- equivalent call inferred; original call site unknown
	local text = dialog.Text

	for i = 1, #v2 do
		local v3 = v2[i]

		if not v3 then
			continue
		end

		local v4 = "%%param" .. tostring(i)
		text = string.gsub(text, v4, v3)
	end

	local clone = script.DialogText.Main:Clone()
	clone.Parent = parent
	clone.Text = text
	clone.MaxVisibleGraphemes = 0
	clone.Visible = true

	if dialog.Sound then
		SoundController:PlaySound(dialog.Sound)
	end

	TypeEffect(clone, dialog.Duration or 1)

	if dialog.Wait then
		task.wait(dialog.Wait)
	end

	if dialog.Next then
		FadeOutAndDestroy(clone, nil) -- equivalent call inferred; original call site unknown
		SetInDialogue(false) -- equivalent call inferred; original call site unknown
		return DialogController:StartDialog(p, dialog.Next, parent, ...)
	elseif dialog.Answers then
		local v3 = DialogController:ShowOptions(dialog.Answers)
		FadeOutAndDestroy(clone, nil) -- equivalent call inferred; original call site unknown

		if v3 == nil then
			SetInDialogue(false) -- equivalent call inferred; original call site unknown
		else
			local answer = dialog.Answers[v3]

			if answer.Function then
				local v5, v6, v7, v8 = answer.Function()

				if answer.FunctionResponse then
					task.defer(
						DialogController.StartDialog,
						DialogController,
						p,
						answer.FunctionResponse[v5],
						parent,
						v6,
						v7,
						v8
					)
				elseif answer.Next then
					SetInDialogue(false) -- equivalent call inferred; original call site unknown
					DialogController:StartDialog(p, answer.Next, parent)
					return
				end
			elseif answer.Next then
				SetInDialogue(false) -- equivalent call inferred; original call site unknown
				DialogController:StartDialog(p, answer.Next, parent)
				return
			end

			SetInDialogue(false) -- equivalent call inferred; original call site unknown
		end
	else
		SetInDialogue(false) -- equivalent call inferred; original call site unknown
		FadeOutAndDestroy(clone, nil) -- equivalent call inferred; original call site unknown
	end
end

function DialogController:SetupDialogBillboard(instance)
	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart", 25)

	if not humanoidRootPart then
		return
	end

	dialogAnswers.Adornee = humanoidRootPart
end

function DialogController:ShowOptions(list)
	local thread = coroutine.running()
	local character, _, v2 = CharacterUtils:GetCharacter()

	if not character then
		return
	end

	maid:Clean()

	for i = 1, #list do
		local v3 = list[i]
		local clone = dialogAnswers.Main.Template:Clone()
		local v4 = AnimatedButton.new(clone)
		v4:Animate()
		maid:Add(v4, "Destroy")
		maid:Add(clone, "Destroy")
		local v5 = i
		maid:Add(clone.MouseButton1Click:Connect(function()
			maid:Clean()
			coroutine.resume(thread, v5)
		end))
		clone.Text = `<font color="#FFECA1">{i}.</font> {v3.Text}`
		clone.Parent = dialogAnswers.Main
		clone.Visible = true
	end

	maid:Add(UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if gameProcessed == true then
			return
		end

		if input.KeyCode == Enum.KeyCode.ButtonB then
			maid:Clean()
			coroutine.resume(thread, nil)
		end
	end))
	maid:Add(v2.Died:Connect(function()
		maid:Clean()
		coroutine.resume(thread, nil)
	end))
	return coroutine.yield()
end

function DialogController.Start(_)
	localPlayer.CharacterAdded:Connect(function(character)
		DialogController:SetupDialogBillboard(character)
	end)

	if localPlayer.Character then
		DialogController:SetupDialogBillboard(localPlayer.Character)
	end
end

return DialogController