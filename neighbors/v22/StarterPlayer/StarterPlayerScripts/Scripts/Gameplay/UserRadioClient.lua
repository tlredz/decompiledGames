local createVector = vector.create
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local userRadio = playerGui:WaitForChild("UserRadio", 30)
local userRadioFlat = playerGui:WaitForChild("UserRadioFlat", 30)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Server = require(ReplicatedStorage.Modules.Server)

if Server:GetServerType() == Server.Servers.Neighborhood then
	local RunService = game:GetService("RunService")
	game:GetService("SoundService")
	local TweenService = game:GetService("TweenService")
	game:GetService("CollectionService")
	game:GetService("UserInputService")
	game:GetService("GuiService")
	local UI = require(ReplicatedStorage.Modules.UI)
	local Network = require(ReplicatedStorage.Modules.Network)
	local House = require(ReplicatedStorage.Modules.Neighbors.House)
	local ThumbnailGenerator = require(ReplicatedStorage.Modules.ThumbnailGenerator)
	local radiosConnected = ReplicatedStorage:WaitForChild("RadiosConnected")
	local flag = false
	local frame = userRadioFlat.Frame
	Color3.fromRGB(84, 84, 84)
	Color3.fromRGB(230, 230, 230)
	local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In, 0, false, 0)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function CreateWire(p, targetInstance)
		local wire = Instance.new("Wire")
		wire.SourceInstance = p
		wire.TargetInstance = targetInstance
		wire.Parent = p
		return wire
	end

	local function CheckPlayerHouseConnectedToRadio()
		local currentInternalMap = localPlayer:GetAttribute("CurrentInternalMap")

		for _, child in radiosConnected:GetChildren() do
			local currentInternalMap2 = Players:FindFirstChild(child.Name):GetAttribute("CurrentInternalMap")

			if currentInternalMap2 and currentInternalMap and currentInternalMap2 == currentInternalMap then
				return true
			end
		end
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = "FakeAttachment"
	local audioListener = Instance.new("AudioListener")
	audioListener.Name = "FakeListener"
	audioListener.AudioInteractionGroup = "RadioEmit"
	audioListener.Parent = attachment
	local audioAnalyzer = Instance.new("AudioAnalyzer")
	audioAnalyzer.Name = "FakeAnalyzer"
	CreateWire(audioListener, audioAnalyzer) -- equivalent call inferred; original call site unknown
	local clone = script:WaitForChild("AudioEmitter"):Clone()
	local audioFader = Instance.new("AudioFader")
	audioFader.Volume = 1
	local attachment2 = Instance.new("Attachment")
	local audioListener2 = Instance.new("AudioListener")
	audioListener2.Parent = attachment2
	local audioAnalyzer2 = Instance.new("AudioAnalyzer")
	CreateWire(audioListener2, audioAnalyzer2) -- equivalent call inferred; original call site unknown

	local function OpenPanelHolder()
		userRadioFlat.Frame.Visible = true
		userRadioFlat.Enabled = true
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function ClosePanelHolder()
		userRadioFlat.Frame.Visible = false
		userRadioFlat.Enabled = false
	end

	userRadio.Buttons.Rent.Button.MouseButton1Click:Connect(OpenPanelHolder)
	frame.Close.Button.MouseButton1Click:Connect(ClosePanelHolder)
	local visible = false
	local reactions = userRadio.Buttons.Reactions
	reactions.Button.MouseButton1Click:Connect(function()
		if flag then
			return
		end

		flag = true
		TweenService:Create(userRadio.Reactions.UIScale, tweenInfo, {
			Scale = visible and 0 or 1
		}):Play()
		reactions.ImageLabel.Visible = visible
		reactions.TextLabel.Visible = not visible
		visible = not visible
		task.wait(tweenInfo.Time)
		flag = false
	end)
	local textBox = userRadio.Reactions.Input.TextBox
	textBox:GetPropertyChangedSignal("Text"):Connect(function()
		local textBox2 = textBox
		local text

		if string.len(textBox.Text) > 20 then
			text = string.sub(textBox.Text, 1, 20)
		else
			text = textBox.Text
		end

		textBox2.Text = text
	end)
	local flag2 = false

	local function SendReaction(p)
		local v2 = p or textBox.Text
		assert(typeof(v2) == "string", "reaction is not a valid format")
		assert(v2 == v2, "reaction is NaN")
		assert(string.len(v2) > 0, "empty reaction")

		if flag2 then
			return _G.DisplayError("Please wait before sending another reaction..", 5)
		end

		flag2 = true
		task.delay(5, function()
			flag2 = false
		end)
		Network:fire("RequestReaction", v2)
		textBox.Text = ""
	end

	for _, frame2 in userRadio.Reactions.Emojis:GetChildren() do
		if not frame2:IsA("Frame") then
			continue
		end

		UI:AddShadowOnHover(frame2.Button, 0.5, frame2.Shadow)
		local v2 = frame2
		frame2.Button.MouseButton1Click:Connect(function()
			SendReaction(v2.Button.Text)
		end)
	end

	local notifications = userRadio.Notifications
	local template = notifications.Template
	local v2 = 1
	local v3 = {
		0.1,
		0.9,
		0.3,
		0.7,
		0.5
	}

	local function GetEndXPosition()
		local v4 = v3[v2]

		if v2 == 5 then
			v2 = 1
			return v4
		end

		v2 += 1
		return v4
	end

	Network:listen("RequestReaction", function(p)
		local clone2 = template:Clone()
		clone2.TextLabel.Text = p.Reaction
		clone2.Reacter.Text = `@{p.Name}`
		clone2.Parent = notifications
		local tween = TweenService:Create(clone2.UIScale, tweenInfo, {
			Scale = 1
		})
		tween:Play()
		tween.Completed:Wait()
		local tweenInfo2 = TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
		local v6 = v3[v2]

		if v2 == 5 then
			v2 = 1
		else
			v2 += 1
		end

		local v7 = TweenService:Create(clone2, tweenInfo2, {
			Position = UDim2.fromScale(v6, 0.1)
		})
		v7:Play()
		v7.Completed:Once(function()
			clone2:Destroy()
		end)
		TweenService:Create(
			clone2.UIScale,
			TweenInfo.new(20, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, false, 2),
			{
				Scale = 0
			}
		):Play()
	end)
	textBox.FocusLost:Connect(function(p)
		if p then
			SendReaction()
		end
	end)
	userRadio.Reactions.Button.MouseButton1Click:Connect(SendReaction)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function GetMinutesFormattedFromCost(value)
		local v4 = value / 25
		return (`{v4} {v4 == 1 and "Minute" or "Minutes"}`)
	end

	for _, button in userRadio:GetDescendants() do
		if button:IsA("GuiButton") then
			UI:AddShadowOnHover(button, 0.5, button.Parent:FindFirstChild("Shadow"))
		end
	end

	for _, button in userRadioFlat:GetDescendants() do
		if button:IsA("GuiButton") then
			UI:AddShadowOnHover(button, 0.5, button.Parent:FindFirstChild("Shadow"))
		end
	end

	local selectedGradient = nil
	local v4 = 0

	for _, frame2 in frame.Rent.List:GetChildren() do
		if not (frame2:IsA("Frame") and frame2:FindFirstChild("Button") and frame2.Name == "Option") then
			continue
		end

		local button = frame2:FindFirstChild("Button")
		local value = frame2:FindFirstChild("Cost").Value
		button.Text = ("$%* - (%*)"):format(value, GetMinutesFormattedFromCost(value))
		local v5 = frame2
		button.MouseButton1Click:Connect(function()
			if selectedGradient then
				selectedGradient.Enabled = false

				if selectedGradient == v5.SelectedGradient then
					v4 = 0
					selectedGradient = nil
					return
				end
			end

			selectedGradient = v5.SelectedGradient

			if v5.SelectedGradient.Enabled then
				v4 = 0
			else
				v4 = value / 25
			end

			v5.SelectedGradient.Enabled = not v5.SelectedGradient.Enabled
		end)
	end

	frame.Rent.List.Confirm.Button.MouseButton1Click:Connect(function()
		if selectedGradient then
			selectedGradient.Enabled = false
		end

		if math.floor(v4) ~= v4 or v4 == 0 or not v4 then
			return
		end

		if #radiosConnected:GetChildren() >= 4 then
			return _G.DisplayError("The Neighbors radio currently has no slots available, please try again later..", 5)
		end

		ClosePanelHolder() -- equivalent call inferred; original call site unknown
		Network:fire("RequestRadioRent", v4)
		v4 = 0
		selectedGradient = nil
	end)
	local v5 = false
	userRadio.Buttons.Mute.Button.MouseButton1Click:Connect(function()
		userRadio.Buttons.Mute.ImageLabel.Image = v5 and "rbxassetid://15604215436" or "rbxassetid://15604215554"
		audioFader.Volume = v5 and 1 or 0
		v5 = not v5
	end)
	local v6 = {}
	local effects = clone.Effects
	CreateWire(audioFader, effects["1"]) -- equivalent call inferred; original call site unknown
	CreateWire(effects["1"], effects["2"]) -- equivalent call inferred; original call site unknown
	local _22 = effects["2"]
	local wire = Instance.new("Wire")
	wire.SourceInstance = _22
	wire.TargetInstance = clone
	wire.Parent = _22
	local userRadio2 = nil
	local flag3 = false
	RunService.RenderStepped:Connect(function()
		if not (userRadio2 and userRadio2.Root and localPlayer and localPlayer.Character) then
			return
		end

		if not localPlayer.Character.PrimaryPart then
			return
		end

		if (userRadio2.Root.Position - localPlayer.Character.PrimaryPart.Position).Magnitude < 20 and not CheckPlayerHouseConnectedToRadio() and #radiosConnected:GetChildren() > 0 then
			if not flag3 then
				flag3 = true
				Network:fire("UpdateRadioListenerCount", 1)
			end
		elseif flag3 then
			flag3 = false
			Network:fire("UpdateRadioListenerCount", -1)
		end
	end)
	House.ActiveHouseChanged:Connect(function()
		local currentHouse = House:GetCurrentHouse()

		if currentHouse then
			userRadio2 = currentHouse.Model.Server.Shared:FindFirstChild("User Radio")
			userRadio.Adornee = userRadio2.Root
			clone.Parent = userRadio2.Root
			audioFader.Parent = userRadio2.Root
			audioAnalyzer2.Parent = userRadio2
			audioAnalyzer.Parent = userRadio2
			attachment2.Parent = userRadio2.Root
			attachment.Parent = userRadio2.Root

			if CheckPlayerHouseConnectedToRadio() then
				if flag3 then
					flag3 = false
					Network:fire("UpdateRadioListenerCount", -1)
				end

				for _, v7 in v6 do
					v7:Destroy()
				end

				table.clear(v6)

				for _, child in radiosConnected:GetChildren() do
					if child.Value.Value == userRadio2 then
						continue
					end

					local audioListener3 = child.Reference.Value.Attachment.AudioListener
					table.insert(v6, CreateWire(audioListener3, audioFader))
				end
			end
		end
	end)
	local connected = userRadio.Connected

	local function CreateUserImage(name)
		local child = Players:FindFirstChild(name)

		if not child then
			return
		end

		local clone2 = script.ConnectedTemplate:Clone()
		clone2.ProfilePicture.Image = ThumbnailGenerator("AvatarHeadShot", child.UserId, Vector2.new(150, 150))
		clone2.Visible = true
		clone2.Name = name
		clone2.Parent = connected
		return clone2
	end

	local function SetupConnectedUI(instance)
		local connections = {}
		local v7 = false
		local userImage = CreateUserImage(instance.Name)
		local child = Players:WaitForChild(instance.Name)
		local currentInternalMap = child:GetAttribute("CurrentInternalMap")
		local child2 = workspace.Places:WaitForChild(currentInternalMap)
		local v9 = currentInternalMap ~= localPlayer:GetAttribute("CurrentInternalMap")
		local attachment3 = Instance.new("Attachment")
		local audioListener3 = Instance.new("AudioListener")
		audioListener3.Parent = attachment3
		local audioAnalyzer3 = Instance.new("AudioAnalyzer")
		audioAnalyzer3.Parent = attachment3
		CreateWire(audioListener3, audioAnalyzer3) -- equivalent call inferred; original call site unknown
		local part = Instance.new("Part")
		part.Name = "RadioFakePartListenerHolder"
		part.Transparency = 1
		part.Size = createVector(1, 1, 1)
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Anchored = true
		part.Parent = child2
		local objectValue = Instance.new("ObjectValue")
		objectValue.Value = part
		objectValue.Name = "Reference"
		objectValue.Parent = radiosConnected[instance.Name]
		local houseFromPlayer = House:GetHouseFromPlayer(child)
		local userRadio3 = houseFromPlayer and houseFromPlayer.Server.Shared:FindFirstChild("User Radio")

		if userRadio3 then
			part:PivotTo(userRadio3:GetPivot())
		end

		if v9 then
			audioListener3.AudioInteractionGroup = ""
		else
			audioListener3.AudioInteractionGroup = "NOTHING"
		end

		attachment3.Parent = part
		table.insert(connections, child:GetAttributeChangedSignal("CurrentInternalMap"):Connect(function()
			local currentInternalMap2 = child:GetAttribute("CurrentInternalMap")

			if currentInternalMap2 and workspace.Places:FindFirstChild(currentInternalMap2) then
				local houseFromPlayer2 = House:GetHouseFromPlayer(child)
				local userRadio4 = houseFromPlayer2 and houseFromPlayer2.Server.Shared:FindFirstChild("User Radio")

				if userRadio4 then
					part:PivotTo(userRadio4:GetPivot())
				end

				part.Parent = workspace.Places[currentInternalMap2]
				v9 = currentInternalMap2 ~= localPlayer:GetAttribute("CurrentInternalMap")

				if v9 then
					audioListener3.AudioInteractionGroup = ""
				else
					audioListener3.AudioInteractionGroup = "NOTHING"
				end
			end
		end))

		for _, v10 in v6 do
			v10:Destroy()
		end

		table.clear(v6)

		for _, child3 in radiosConnected:GetChildren() do
			if child3:WaitForChild("Value", 10).Value == userRadio2 then
				continue
			end

			local audioListener4 = child3:WaitForChild("Reference", 10).Value.Attachment.AudioListener
			table.insert(v6, CreateWire(audioListener4, audioFader))
		end

		table.insert(connections, userImage.Button.MouseEnter:Connect(function()
			userImage.Hover.Username.Text = instance.Name

			if not v7 then
				TweenService:Create(userImage.Muted.UIScale, tweenInfo, {
					Scale = 1
				}):Play()
			end

			userImage.Muted.TextLabel.Text = v7 and "UNMUTE" or "MUTE"
			TweenService:Create(userImage.Hover.UIScale, tweenInfo, {
				Scale = 1
			}):Play()
		end))
		table.insert(connections, userImage.Button.MouseLeave:Connect(function()
			TweenService:Create(userImage.Hover.UIScale, tweenInfo, {
				Scale = 0
			}):Play()

			if not v7 then
				TweenService:Create(userImage.Muted.UIScale, tweenInfo, {
					Scale = 0
				}):Play()
			end
		end))
		table.insert(connections, userImage.Button.MouseButton1Click:Connect(function()
			local _ = instance:FindFirstChild("Value").Value
			TweenService:Create(userImage.Muted.UIScale, tweenInfo, {
				Scale = v7 and 0 or 1
			}):Play()
			userImage.Muted.TextLabel.Text = v7 and "" or "MUTED"
			audioListener3.AudioInteractionGroup = v7 and "" or "NOTHING"
			v7 = not v7
		end))
		table.insert(connections, instance:GetAttributeChangedSignal("Talking"):Connect(function()
			local talking = instance:GetAttribute("Talking")
			userImage.WallpaperPattern.UIStroke.UIGradient.Transparency = NumberSequence.new(talking and 0 or 1)
		end))
		table.insert(connections, RunService.RenderStepped:Connect(function()
			local _ = instance:FindFirstChild("Value").Value
			local v11

			if v9 then
				v11 = part.Attachment.AudioAnalyzer.RmsLevel > 0.01 or false
			else
				v11 = audioAnalyzer2.RmsLevel > 0.01 or audioAnalyzer.RmsLevel > 0.01 or false
			end

			if v11 and not instance:GetAttribute("Talking") then
				instance:SetAttribute("Talking", true)
				return
			end

			if not instance:GetAttribute("Talking") then
				return
			end

			instance:SetAttribute("Talking", false)
		end))
		local talking = instance:GetAttribute("Talking")
		userImage.WallpaperPattern.UIStroke.UIGradient.Transparency = NumberSequence.new(talking and 0 or 1)
		instance.Destroying:Connect(function()
			userImage:Destroy()

			for _, connection in connections do
				if connection then
					connection:Disconnect()
				end
			end

			part:Destroy()
		end)
	end

	radiosConnected.ChildAdded:Connect(SetupConnectedUI)
	local textLabel = userRadio:WaitForChild("ListeningCount"):WaitForChild("TextLabel")
	workspace:GetAttributeChangedSignal("UsersListeningToRadio"):Connect(function()
		local usersListeningToRadio = workspace:GetAttribute("UsersListeningToRadio")

		if usersListeningToRadio and usersListeningToRadio > 0 then
			textLabel.Visible = true
			textLabel.Text = `Players Listening: {usersListeningToRadio}`
		else
			textLabel.Visible = false
		end
	end)

	for _, child in radiosConnected:GetChildren() do
		if not connected:FindFirstChild(child.Name) then
			task.spawn(SetupConnectedUI, child)
		end
	end

	while task.wait(1) do
		for _, frame2 in connected:GetChildren() do
			if not frame2:IsA("Frame") then
				continue
			end

			local child = radiosConnected:FindFirstChild(frame2.Name)

			if not child then
				continue
			end

			local v7 = child.TimeToEnd.Value - DateTime.now().UnixTimestamp
			frame2.Counter.Text = tostring(v7)
		end
	end
else
	userRadio.Enabled = false
	userRadioFlat.Enabled = false
end