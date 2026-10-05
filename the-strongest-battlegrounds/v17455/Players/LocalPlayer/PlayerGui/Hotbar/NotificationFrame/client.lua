local parent = script.Parent
local frame = script.Frame
frame.Parent = nil
local TweenService = game:GetService("TweenService")
local quad = Enum.EasingStyle.Quad
local out = Enum.EasingDirection.Out
local states = {}

local function fn(p, p2, _)
	local v = 0

	for i = #states, 1, -1 do
		local v2 = states[i]
		local _ = states[i + 1]
		v -= v2.Object.Size.Y.Offset + 4

		if p then
			if p == i then
				return v
			end
		elseif p2 then
			v2.Object.Position = UDim2.new(0, 0, 1, v)
		else
			TweenService:Create(v2.Object, TweenInfo.new(0.5, quad, out), {
				Position = UDim2.new(0, 0, 1, v)
			}):Play()
		end
	end
end

local function fn2(Y)
	local v = { 64, 78, 92 }
	local v2 = v[1]
	local v3 = math.abs(Y - v[1])

	for i = 2, #v do
		local v4 = math.abs(Y - v[i])

		if not (v4 < v3) then
			continue
		end

		v2 = v[i]
		v3 = v4
	end

	return v2
end

local function fn3(state)
	local v = true

	if state.Stack then
		for _, v2 in pairs(states) do
			if not (v2.Text == state.Text or v2.Text == state.Message or state.ID and v2.ID == state.ID) then
				continue
			end

			v = false

			if v2.Bind then
				v2.Bind:SetAttribute("Extend", state.Duration / 2 + math.random() / 100)
			end

			v2.Object.Notification.NotificationText.Text = state.Message or state.Text
			v2.Object.BackgroundTransparency = 0.8
			TweenService:Create(v2.Object, TweenInfo.new(0.5, quad, out), {
				BackgroundTransparency = 1
			}):Play()
			local glow = v2.Object.Notification.FrameGlow.Glow
			glow.ImageTransparency = 0.3
			TweenService:Create(glow, TweenInfo.new(3, quad, out), {
				ImageTransparency = 1
			}):Play()
			TweenService:Create(glow.Parent.SubtleGlow, TweenInfo.new(0, quad, out), {
				ImageTransparency = 1
			}):Play()
		end

		if not v then
			shared.sfx({
				SoundId = "rbxassetid://87519554692663",
				Parent = game.Players.LocalPlayer.PlayerGui,
				Volume = 0.5
			}):Play()
		end
	end

	if not v then
		return
	end

	local clone = frame:Clone()
	local notificationText = clone.Notification.NotificationText
	local notificationTitle = clone.Notification.NotificationTitle
	local notification = clone.Notification
	local now = tick()
	local fn4
	local flag = nil
	notificationTitle.Text = state.Title or ""
	notificationText.Text = state.Text or ""
	clone.Parent = parent
	state.Object = clone
	table.insert(states, state)
	local v2 = ({
		Good1 = {
			SoundId = "rbxassetid://73507725308522",
			Volume = 1
		},
		Bad1 = {
			SoundId = "rbxassetid://134573167668808",
			Volume = 1
		}
	})[state.SFX or state.Error and "Bad1" or "Good1"]
	v2.Parent = game.Players.LocalPlayer.PlayerGui
	shared.sfx(v2):Play()

	local function fn5()
		local notification2 = clone:FindFirstChild("Notification")

		if not notification2 then
			return
		end

		local parent2 = notification2.Parent
		local button3 = notification2.Button3
		local v3 = button3.AbsolutePosition.Y - parent2.AbsolutePosition.Y + button3.AbsoluteSize.Y

		if not state.Button1 then
			return
		end

		parent2.Size = UDim2.new(1, 0, 0, v3)
		notification2.Parent.Size = UDim2.new(1, 0, 0, notification2.Size.Y.Offset + 34)
	end

	local function fn6(p)
		notificationText.Size = UDim2.new(1, -16, 0, 1000)

		if not p then
			clone.Position = UDim2.new(1.1, 0, 1, fn(table.find(states, state)))
		end

		local Y = notificationText.TextBounds.Y
		fn2(Y)

		if Y >= 28 then
			local v3 = Y - 28
			clone.Size = UDim2.new(1, 0, 0, 64 + v3)
			clone.Notification.Size = UDim2.new(1, 0, 0, 64 + v3)
		end

		local v3 = notificationTitle.AbsolutePosition.Y - notification.AbsolutePosition.Y + notificationTitle.AbsoluteSize.Y
		local v4 = notification.AbsoluteSize.Y - v3
		local v5 = v4 < 0 and 0 or v4
		notificationText.Position = UDim2.new(0.5, 0, 0, v3)
		notificationText.Size = UDim2.new(0.95, 0, 0, v5)

		if p then
			fn5()
			fn(nil, nil, true)
		end
	end

	fn6()
	local v3 = 0
	notificationText:GetPropertyChangedSignal("Text"):Connect(function()
		local text = notificationText.Text

		if #text ~= v3 then
			v3 = #text
			fn6(true)
		end
	end)
	local bind = state.Bind

	if bind then
		bind:GetPropertyChangedSignal("Value"):Connect(function()
			notificationText.Text = bind.Value
		end)
		bind:GetAttributeChangedSignal("Parent"):Connect(function()
			if not bind.Parent then
				fn4()
			end
		end)
		bind:GetAttributeChangedSignal("Dismiss"):Connect(function()
			fn4()
		end)
		bind:GetAttributeChangedSignal("Extend"):Connect(function()
			now += bind:GetAttribute("Extend")
		end)
		bind:GetAttributeChangedSignal("Title"):Connect(function()
			state.Title = bind:GetAttribute("Title")
			notificationTitle.Text = state.Title
			local subtleGlow = clone.Notification.FrameGlow.SubtleGlow
			subtleGlow.ImageTransparency = 0.75
			TweenService:Create(subtleGlow, TweenInfo.new(2, quad, out), {
				ImageTransparency = 1
			}):Play()
		end)
		task.spawn(function()
			repeat
				task.wait()
			until not (bind.Parent and clone.Parent)

			fn4()

			if bind.Parent then
				bind:Destroy()
			end
		end)
	end

	if state.AnimatedTitle then
		task.spawn(function()
			local v4 = 1

			repeat
				task.wait(0.3)
				notificationTitle.Text = state.Title .. string.rep(".", v4)
				local v5 = v4 + 1
				v4 = v5 > 3 and 1 or v5
			until not clone.Parent or bind and bind:GetAttribute("NoAnimation")

			if bind and bind:GetAttribute("NoAnimation") then
				notificationTitle.Text = state.Title
			end
		end)
	end

	if state.Button1 then
		local notification2 = clone.Notification

		if state.Button2 then
			notification2.Button1.Visible = true
			notification2.Button2.Visible = true
			notification2.Button1.Text = state.Button1 or state.Button
			notification2.Button2.Text = state.Button2
		else
			notification2.Button3.Text = state.Button1 or state.Button
			notification2.Button3.Visible = true
		end

		fn5()
	end

	if state.Changing then
		task.spawn(function()
			for _ = 1, math.random(10, 255) do
				notificationText.Text ..= string.char(math.random(97, 122))
				task.wait(math.random() / 25)
			end
		end)
	end

	fn()

	fn4 = function()
		fn4 = function() end

		flag = true
		local v4 = {}

		for _, v5 in pairs(states) do
			if v5 ~= state then
				table.insert(v4, v5)
			end
		end

		states = v4
		fn()
		TweenService:Create(clone, TweenInfo.new(0.5, quad, out), {
			Position = UDim2.new(1.1, 0, 1, clone.Position.Y.Offset)
		}):Play()
		local Debris = game:GetService("Debris")
		Debris:AddItem(clone, 0.7)
	end

	task.spawn(function()
		repeat
			task.wait(0.1)
		until tick() - now > (state.Duration or 5)

		fn4()

		if state.Custom == "Ranked" then
			game.ReplicatedStorage:FindFirstChild("Ranked"):FindFirstChild("QueueHandler"):FireServer({
				Person = state.Person,
				Wanted = "No",
				Type = "InvitationDecision"
			})
		end
	end)
	clone.Notification.FrameGlow.SubtleGlow.ImageTransparency = 0.65
	task.delay(0.75, function()
		TweenService:Create(clone.Notification.FrameGlow.SubtleGlow, TweenInfo.new(2, quad, out), {
			ImageTransparency = 1
		}):Play()
	end)
	local notification2 = clone.Notification
	local custom = state.Custom

	if custom then
		function state.Callback(wanted)
			if custom == "Ranked" then
				game.ReplicatedStorage:FindFirstChild("Ranked"):FindFirstChild("QueueHandler"):FireServer({
					Person = state.Person,
					Wanted = wanted,
					Type = "InvitationDecision"
				})
				state.Custom = nil
			else
				if custom ~= "CataloguePaidItem" or wanted ~= "OPEN" then
					return
				end

				if type(_G.OpenGlobalCatalogueWithSearch) == "function" then
					_G.OpenGlobalCatalogueWithSearch(state.SearchTerm)
				elseif type(_G.OpenGlobalCatalogue) == "function" then
					_G.OpenGlobalCatalogue()
				end

				return false
			end
		end
	end

	for _, v4 in pairs({ notification2.Button1, notification2.Button2, notification2.Button3 }) do
		if not v4.Visible then
			continue
		end

		local v5 = v4
		v4.MouseButton1Click:Connect(function()
			if flag then
				return
			end

			local flag2 = true

			if state.Callback then
				local v6 = nil

				if typeof(state.Callback) == "Instance" then
					if state.Callback:IsA("BindableFunction") then
						v6 = state.Callback:Invoke(v5.Text)
					elseif state.Callback:IsA("BindableEvent") then
						state.Callback:Fire(v5.Text)
					end
				elseif typeof(state.Callback) == "function" then
					v6 = state.Callback(v5.Text)
				end

				if v6 == false then
					flag2 = false
				end
			end

			if flag2 then
				flag = true
				fn4()
			end

			shared.sfx({
				SoundId = "rbxassetid://88442833509532",
				Parent = workspace,
				Volume = 0.5
			}):Play()
		end)
	end
end

shared.createNotification = fn3