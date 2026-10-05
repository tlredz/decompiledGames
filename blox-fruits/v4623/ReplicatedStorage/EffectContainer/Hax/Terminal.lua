local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local Maid = require(game.ReplicatedStorage.Util.Maid)
local v = nil
return function(instance)
	if instance.Phase == "Warn" then
		local imageLabel = instance.Seat.Target.ImageLabel
		local TweenService2 = game:GetService("TweenService")
		TweenService2:Create(
			imageLabel,
			TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 1e999, true),
			{
				Size = UDim2.fromScale(2, 2)
			}
		):Play()
		local TweenService3 = game:GetService("TweenService")
		TweenService3:Create(
			imageLabel,
			TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 1e999, true),
			{
				Rotation = 70
			}
		):Play()
	else
		if v then
			v:DoCleaning()
		end

		local maid = Maid.new()
		local maid2 = Maid.new()
		local flag = false
		maid:GiveTask(maid2)
		v = maid
		local v2 = false
		local UserInputService = game:GetService("UserInputService")
		maid:GiveTask(UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch or input.KeyCode == Enum.KeyCode.ButtonA or input.KeyCode == Enum.KeyCode.ButtonB then
				v2 = true
			end
		end))
		local playerGui = localPlayer:FindFirstChild("PlayerGui")
		local character = localPlayer.Character

		if not (playerGui and character) then
			maid:DoCleaning()
			return
		end

		local humanoid = character:FindFirstChild("Humanoid")

		if not humanoid then
			maid:DoCleaning()
			return
		end

		instance.Seat.AncestryChanged:Connect(function()
			if not instance.Seat:IsDescendantOf(game) then
				maid:DoCleaning()
			end
		end)
		local nerfedOverworldChair = instance.Seat:GetAttribute("NerfedOverworldChair")
		local terminal = playerGui:WaitForChild("FakeCrash"):WaitForChild("Terminal")
		local content = terminal:WaitForChild("Content")
		local bottom = terminal:WaitForChild("Bottom")
		local bottomButtons = terminal:WaitForChild("BottomButtons")
		local uIScale = terminal:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
		uIScale.Parent = terminal
		local v3 = {
			AnchorPoint = terminal.AnchorPoint,
			Position = terminal.Position,
			Scale = uIScale.Scale,
			Visible = terminal.Visible,
			ContentText = content.Text,
			BottomText = bottom.Text
		}
		content.TextColor3 = Color3.fromRGB(88, 206, 148)
		content.UIStroke.Color = Color3.fromRGB(0, 54, 9)
		content.TextWrapped = true
		local v4 = {}

		for _, button in ipairs(bottomButtons:GetChildren()) do
			if not button:IsA("ImageButton") then
				continue
			end

			local textLabel = button:FindFirstChild("TextLabel")
			local uIStroke = textLabel and textLabel:FindFirstChildOfClass("UIStroke")
			v4[button] = {
				Visible = button.Visible,
				Text = not textLabel and "" or textLabel.Text or "",
				TextColor = textLabel and textLabel.TextColor3,
				StrokeColor = uIStroke and uIStroke.Color
			}
		end

		local color = Color3.fromRGB(90, 90, 90)
		local color2 = Color3.fromRGB(60, 60, 60)

		local function setButtonsEnabled(flag2: boolean)
			for k, v5 in pairs(v4) do
				local textLabel = k:FindFirstChild("TextLabel")

				if not textLabel then
					continue
				end

				local uIStroke = textLabel:FindFirstChildOfClass("UIStroke")

				if flag2 then
					textLabel.TextColor3 = v5.TextColor or Color3.new(1, 1, 1)

					if uIStroke and v5.StrokeColor then
						uIStroke.Color = v5.StrokeColor
					end
				else
					textLabel.TextColor3 = color

					if uIStroke then
						uIStroke.Color = color2
					end
				end
			end
		end

		setButtonsEnabled(false)
		local v5 = false
		local v6 = false
		local v7 = false
		local v8 = false
		local v9 = "user@admin:~$ "
		local v10 = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function tween(p, tweenInfo, p2)
			local tween2 = TweenService:Create(p, tweenInfo, p2)
			tween2:Play()
			return tween2
		end

		local function waitTweens(list)
			local count = #list

			if count == 0 then
				return true
			end

			local maid3 = Maid.new()
			local v11 = false

			for _, v12 in ipairs(list) do
				maid3:GiveTask(v12.Completed:Connect(function()
					count -= 1

					if count <= 0 then
						v11 = true
					end
				end))
			end

			while not (v11 or v5) do
				task.wait()
			end

			maid3:DoCleaning()
			return not v5
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function applyPrompt()
			bottom.Text = v9 .. (v8 and "_" or "")
		end

		local function resetButtons()
			for k, v11 in pairs(v4) do
				k.Visible = v11.Visible
				local textLabel = k:FindFirstChild("TextLabel")

				if textLabel then
					textLabel.Text = v11.Text
				end
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function hardResetUi()
			resetButtons()
			content.Text = ""
			v9 = "user@admin:~$ "
			v8 = false
			v7 = false
			v10 = false
			applyPrompt() -- equivalent call inferred; original call site unknown
			terminal.AnchorPoint = Vector2.new(0.5, 0)
			terminal.Position = v3.Position
			uIScale.Scale = 0
			terminal.Visible = false
		end

		local function beginExit()
			if v6 or v5 then
				return
			end

			v6 = true
			v7 = true
			v8 = false
			applyPrompt() -- equivalent call inferred; original call site unknown
			local tween2 = tween(terminal, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.fromScale(0.5, 1)
			}) -- equivalent call inferred; original call site unknown
			local tween22 = tween(uIScale, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Scale = 0
			}) -- equivalent call inferred; original call site unknown
			waitTweens({ tween2, tween22 })

			if not v5 then
				maid:DoCleaning()
			end
		end

		local function typeAppend(p, value: string, value2: number?)
			local v11 = value2 or 0.012

			for i = 1, #value do
				if v5 or v6 then
					return false
				end

				p.Text ..= value:sub(i, i)

				if not v2 then
					task.wait(v11)
				end
			end

			return true
		end

		local textBox

		if nerfedOverworldChair then
			terminal.BottomButtons.Visible = false
			local remoteFunction = instance.Seat:FindFirstChild("RemoteFunction")
			terminal.UIGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(123, 255, 160)),
				ColorSequenceKeypoint.new(0.0984456, Color3.fromRGB(123, 255, 160)),
				ColorSequenceKeypoint.new(0.1019, Color3.fromRGB(55, 138, 76)),
				ColorSequenceKeypoint.new(0.696028, Color3.fromRGB(55, 138, 76)),
				ColorSequenceKeypoint.new(0.702936, Color3.fromRGB(123, 255, 160)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(84, 211, 116))
			})
			textBox = Instance.new("TextBox", terminal)
			textBox.Visible = false
			maid:GiveTask(textBox)
			textBox.Position = UDim2.fromScale(0, 0.7)
			textBox.Size = UDim2.fromScale(1, 0.1)
			textBox.BackgroundTransparency = 1
			textBox.TextColor3 = terminal.Bottom.TextColor3
			textBox.TextScaled = true
			textBox.Font = terminal.Bottom.Font
			textBox.PlaceholderText = ""
			textBox.TextXAlignment = Enum.TextXAlignment.Left
			textBox.TextYAlignment = Enum.TextYAlignment.Bottom
			textBox.Text = ""
			textBox.TextTransparency = 1
			local flag2 = false
			textBox.FocusLost:Connect(function()
				flag = true

				if flag2 then
					return
				end

				if textBox.Text ~= "" then
					flag2 = true
					task.spawn(function()
						local v11, v12 = remoteFunction:InvokeServer(textBox.Text)
						v2 = false

						if v12 then
							local v13 = " " .. v12
							content.RichText = true

							if not v11 then
								content.TextColor3 = Color3.fromRGB(222, 0, 0)
								content.UIStroke.Color = Color3.fromRGB(0, 0, 0)
							end

							typeAppend(content, v13, 0.012)
						end

						task.wait(2.5)
						beginExit()
					end)
				end
			end)
			maid:GiveTask(task.spawn(function()
				while not v5 do
					task.wait()
					v9 = "user@admin:~$ " .. textBox.Text
					applyPrompt() -- equivalent call inferred; original call site unknown
				end
			end))
		else
			textBox = nil
		end

		local function typeSet(p, p2: string, p3: number?)
			p.Text = ""
			return (typeAppend(p, p2, p3))
		end

		local function typePromptAppend(text: string, value: number?)
			local v11 = value or 0.01

			for i = 1, #text do
				if v5 or v6 then
					return false
				end

				v9 ..= text:sub(i, i)
				applyPrompt() -- equivalent call inferred; original call site unknown

				if not v2 then
					task.wait(v11)
				end
			end

			return true
		end

		local function waitLineGap()
			local total = 0

			while total < 0.25 do
				if v5 or v6 then
					return false
				else
					total += task.wait()
				end
			end

			return true
		end

		maid:GiveTask(function()
			v5 = true
			hardResetUi() -- equivalent call inferred; original call site unknown
		end)

		if instance.Humanoid then
			maid:GiveTask(instance.Humanoid.Died:Once(function()
				beginExit()
			end))
		end

		maid:GiveTask(humanoid.Died:Once(function()
			beginExit()
		end))
		maid:GiveTask(humanoid:GetPropertyChangedSignal("SeatPart"):Connect(function()
			if flag then
				return
			end

			if not humanoid.SeatPart then
				beginExit()
			end
		end))
		hardResetUi() -- equivalent call inferred; original call site unknown
		terminal.Visible = true
		local tween23 = tween(terminal, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5)
		}) -- equivalent call inferred; original call site unknown
		local tween24 = tween(uIScale, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Scale = 1
		}) -- equivalent call inferred; original call site unknown

		if not waitTweens({ tween23, tween24 }) then
			return
		end

		if v5 or v6 then
			beginExit()
			return
		end

		maid:GiveTask(task.spawn(function()
			while not v5 do
				task.wait(0.35)

				if v7 then
					continue
				end

				v8 = not v8
				applyPrompt() -- equivalent call inferred; original call site unknown
			end
		end))

		if instance.AwaitingHeal == true then
			local v14 = nil

			for _, button in ipairs(bottomButtons:GetChildren()) do
				if not button:IsA("ImageButton") then
					continue
				end

				if v14 then
					button.Visible = false
				else
					v14 = button
				end
			end

			if v14 then
				v14.Visible = true
				local textLabel = v14:FindFirstChild("TextLabel")

				if textLabel then
					textLabel.Text = ":Unheal"
					textLabel.RichText = true
					maid:GiveTask(task.spawn(function()
						local v15 = {
							":",
							"U",
							"n",
							"h",
							"e",
							"a",
							"l"
						}

						while task.wait() do
							local text = ""

							for i, v17 in ipairs(v15) do
								local color3 = Color3.fromHSV((tick() * 0.5 + i * 0.1) % 1, 1, 1)
								text ..= `<font color="rgb({math.floor(color3.R * 255)},{math.floor(color3.G * 255)},{math.floor(color3.B * 255)})">{v17}</font>`
							end

							textLabel.Text = text
						end
					end))
				end
			end
		end

		content.Text = ""
		local clone = nil

		for i, v14 in ipairs({
			{
				text = "Initializing terminal session..."
			},
			{
				text = "Connecting to target..."
			},
			{
				text = "Bypassing firewall..."
			},
			{
				text = "Granting Level 7 Access...",
				success = true
			},
			{
				text = ""
			},
			{
				text = "ENTER COMMAND:"
			}
		}) do
			local GetSounds = require(script.Parent.GetSounds)
			local sounds = GetSounds()
			local v16 = {
				sounds.HackEvent_Hacker_Typing_Dialogue_Loop_02,
				sounds.HackEvent_Hacker_Typing_Dialogue_Loop_01,
				sounds.HackEvent_Hacker_Typing_Dialogue_Loop_03
			}

			if clone then
				clone:Stop()
				clone:Destroy()
			end

			clone = v16[math.random(1, #v16)]:Clone()
			maid:GiveTask(clone)
			clone.Parent = game.Players.LocalPlayer.PlayerGui
			clone:Play()
			v2 = false

			if v5 or v6 then
				beginExit()
				return
			end

			if i > 1 then
				local total = 0
				local v17

				while true do
					if not (total < 0.25) then
						v17 = true
						break
					end

					if v5 or v6 then
						v17 = false
						break
					else
						total += task.wait()
					end
				end

				if not v17 then
					beginExit()
					return
				end

				local v18 = 0.003 or 0.012
				local v19

				if v5 or v6 then
					v19 = false
				else
					content.Text ..= ("\n"):sub(1, 1)

					if not v2 then
						task.wait(v18)
					end

					v19 = true
				end

				if not v19 then
					beginExit()
					return
				end
			end

			if not typeAppend(content, v14.text, 0.01) then
				beginExit()
				return
			end

			if not v14.success then
				continue
			end

			task.wait(0.3)

			if v5 or v6 then
				beginExit()
				return
			end

			if typeAppend(content, " SUCCESS", 0.01) then
				continue
			end

			beginExit()
			return
		end

		if clone then
			clone:Stop()
			clone:Destroy()
		end

		v10 = true
		v2 = false
		applyPrompt() -- equivalent call inferred; original call site unknown

		if textBox then
			textBox.Visible = true
			textBox:CaptureFocus()
		end

		if not nerfedOverworldChair then
			setButtonsEnabled(true)
		end

		local function onCommand(instance2)
			local GetSounds = require(script.Parent.GetSounds)
			local clone2 = GetSounds()["HackEvent_Run_Command_01 (1)"]:Clone()
			maid:GiveTask(function()
				task.delay(2, function()
					if clone2 and clone2.Parent then
						clone2:Stop()
						clone2:Destroy()
					end
				end)
			end)
			clone2.Parent = game.Players.LocalPlayer.PlayerGui
			clone2:Play()
			v2 = false

			if v5 or v6 or not v10 then
				return
			end

			maid2:DoCleaning()
			v7 = true
			v8 = false
			applyPrompt() -- equivalent call inferred; original call site unknown
			local textLabel = instance2:FindFirstChild("TextLabel")
			local text = textLabel and textLabel.Text or instance2.Name

			if not text:match("^:") then
				text = ":" .. text
			end

			if instance.Seat and instance.Seat:FindFirstChild("RemoteEvent") then
				instance.Seat.RemoteEvent:FireServer(instance2.Name)
			end

			v2 = false

			if not typePromptAppend(text, 0.01) then
				beginExit()
				return
			end

			task.wait(0.15)

			if v5 or v6 then
				beginExit()
				return
			end

			v9 = "user@admin:~$ "
			applyPrompt() -- equivalent call inferred; original call site unknown
			content.Text ..= text
			local total = 0
			local v15

			while true do
				if not (total < 0.25) then
					v15 = true
					break
				end

				if v5 or v6 then
					v15 = false
					break
				else
					total += task.wait()
				end
			end

			if not v15 then
				beginExit()
				return
			end

			if not typeAppend(content, "\nRunning command...", 0.01) then
				beginExit()
				return
			end

			task.wait(1)

			if v5 or v6 then
				beginExit()
				return
			end

			local Sound = require(game.ReplicatedStorage.Util.Sound)
			Sound:Play("HackEvent_Run_Command_01")

			if not typeAppend(content, " SUCCESS", 0.01) then
				beginExit()
				return
			end

			task.wait(1)

			if v5 or v6 then
			end

			beginExit()
		end

		for _, button in ipairs(bottomButtons:GetChildren()) do
			if not (button:IsA("ImageButton") and button.Visible) then
				continue
			end

			local v14 = button
			maid2:GiveTask(button.Activated:Once(function()
				onCommand(v14)
			end))
		end
	end
end