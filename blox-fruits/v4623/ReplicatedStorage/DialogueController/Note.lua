local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local Note = {}
local flag = false
local v = nil
local v2 = nil

local function getRefs()
	if v2 then
		return v2
	end

	local note = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Main", 9999):WaitForChild("Note")
	local textLabel = note.ScrollingFrame.TextLabel
	v2 = {
		frame = note,
		fadeIn = TweenService:Create(note, TweenInfo.new(0.25), {
			Size = UDim2.new(1, 0, 0.5, 0),
			BackgroundTransparency = 0.4
		}),
		fadeOut = TweenService:Create(note, TweenInfo.new(0.25), {
			Size = UDim2.new(1, 0, 0.15, 0),
			BackgroundTransparency = 1
		}),
		textFadeIn = TweenService:Create(textLabel, TweenInfo.new(0.1), {
			TextTransparency = 0
		}),
		textFadeOut = TweenService:Create(textLabel, TweenInfo.new(0.1), {
			TextTransparency = 1
		}),
		scrollBarFadeIn = TweenService:Create(note.ScrollingFrame, TweenInfo.new(0.1), {
			ScrollBarImageTransparency = 0
		}),
		scrollBarFadeOut = TweenService:Create(note.ScrollingFrame, TweenInfo.new(0.1), {
			ScrollBarImageTransparency = 1
		})
	}
	return v2
end

local function yieldDismiss(frame)
	local character = Players.LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if not humanoid or humanoid.Health <= 0 then
		return
	end

	local thread = coroutine.running()
	local flag2 = false
	local connections = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function continueNow()
		if flag2 then
			return
		end

		flag2 = true
		v = nil

		for _, connection in connections do
			connection:Disconnect()
		end

		task.defer(thread)
	end

	v = continueNow
	table.insert(connections, UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			continueNow() -- equivalent call inferred; original call site unknown
		elseif input.UserInputType == Enum.UserInputType.Touch then
			local position = input.Position
			local v3

			if frame.AbsolutePosition.X <= position.X and frame.AbsolutePosition.X + frame.AbsoluteSize.X >= position.X and frame.AbsolutePosition.Y <= position.Y then
				v3 = frame.AbsolutePosition.Y + frame.AbsoluteSize.Y >= position.Y
			else
				v3 = false
			end

			if not v3 then
				continueNow() -- equivalent call inferred; original call site unknown
			end
		elseif GuiService.SelectedObject == nil then
			local keyCode = input.KeyCode

			if keyCode == Enum.KeyCode.ButtonA or keyCode == Enum.KeyCode.ButtonB or keyCode == Enum.KeyCode.ButtonX or keyCode == Enum.KeyCode.ButtonY or keyCode == Enum.KeyCode.ButtonR1 or keyCode == Enum.KeyCode.ButtonR2 or keyCode == Enum.KeyCode.ButtonR3 or keyCode == Enum.KeyCode.ButtonL1 or keyCode == Enum.KeyCode.ButtonL2 or keyCode == Enum.KeyCode.ButtonL3 then
				continueNow() -- equivalent call inferred; original call site unknown
			end
		end
	end))
	table.insert(connections, humanoid.Died:Connect(continueNow))
	coroutine.yield()
end

function Note.isActive()
	return flag
end

function Note.dismiss()
	if v then
		v()
	end
end

function Note.show(p)
	if flag then
		warn("[DIALOGUE]", "there's already an active note")
		return
	end

	local character = Players.LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if not humanoid or humanoid.Health <= 0 then
		return
	end

	flag = true
	local refs = getRefs()
	local frame = refs.frame
	local textLabel = frame.ScrollingFrame.TextLabel
	textLabel.TextTransparency = 1
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.Text = p.Content
	frame.Size = UDim2.new(1, 0, 0.15, 0)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.ScrollingFrame.CanvasSize = UDim2.fromScale(0, 0)
	frame.ScrollingFrame.ScrollBarImageTransparency = 1
	frame.Visible = true
	refs.fadeIn:Play()
	task.wait(refs.fadeIn.TweenInfo.Time)

	for _ = 1, 2 do
		local textBounds = textLabel.TextBounds

		if textBounds.Y > frame.ScrollingFrame.AbsoluteSize.Y then
			textLabel.Size = UDim2.new(1, -13, 1, 0)
		end

		task.wait()
		frame.ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, textBounds.Y)
	end

	refs.textFadeIn:Play()
	refs.scrollBarFadeIn:Play()
	task.wait(refs.textFadeIn.TweenInfo.Time)
	yieldDismiss(frame)
	refs.fadeOut:Play()
	refs.textFadeOut:Play()
	refs.scrollBarFadeOut:Play()
	task.wait(refs.fadeOut.TweenInfo.Time)
	frame.Visible = false
	flag = false
end

function Note:hook(p2: string)
	self.RequiresLineOfSight = false
	self.ActionText = "Read"
	self.Triggered:Connect(function()
		local character = Players.LocalPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local busy = character and character:FindFirstChild("Busy")

		if not (character and humanoid and busy) or busy.Value then
			return
		end

		self.Enabled = false
		busy.Value = true
		task.wait()
		local walkSpeed = humanoid.WalkSpeed
		humanoid.WalkSpeed = 0
		local v3 = false
		task.spawn(function()
			while not v3 do
				busy.Value = true
				humanoid.WalkSpeed = 0
				task.wait()
			end

			busy.Value = false
		end)
		local show = Note.show
		local NotesList = require(game.ReplicatedStorage.NotesList)
		show(NotesList[p2])
		humanoid.WalkSpeed = walkSpeed
		v3 = true
		busy.Value = false
		self.Enabled = true
	end)
end

return Note