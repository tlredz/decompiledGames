local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local InputHandler = require(ReplicatedStorage.CAM.Client.Components.Client.InputHandler)
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local faye = require(ReplicatedStorage.Packages.faye)
local info = faye.Info(0.2)
local info2 = faye.Info(0.45)
local color = Color3.new(0.15, 0.15, 0.15)
local color2 = Color3.new(0.22, 0.22, 0.22)
local color3 = Color3.new(1, 1, 1)
local color4 = Color3.fromRGB(155, 208, 255)
local color5 = Color3.new(1, 1, 1)
local color6 = Color3.new(0, 0, 0)
local uDim = UDim.new(0.25)
local v = nil
local v2 = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function release()
	v = nil
	v2 = os.clock() + 0.1
end

return function(maid, name2: string, text: string, options)
	local v3 = options or {}
	local canEdit = v3.CanEdit ~= false
	local isGamepad = Platform_Handler.IsGamepad()

	local function keyText()
		local keyBinding, v4 = InputHandler.KeyBinding(name2)

		if keyBinding == nil then
			return "None"
		end

		local prettyInput = InputHandler.PrettyInput(keyBinding.Name)

		if v4 == nil then
			return prettyInput
		end

		return (`{InputHandler.PrettyInput(v4.Name)} + {prettyInput}`)
	end

	local uiScale = v3.uiScale or function()
		return 1
	end
	local value = maid:Value(0)
	local value2 = maid:Value(0)

	local function measure(_, point: Vector2)
		if point.X <= 0 then
			return
		end

		value:Set(point.X / uiScale())
	end

	local value3 = maid:Value(false)
	local text2 = maid:Value("Recording")
	local keyBinding, v4 = InputHandler.KeyBinding(name2)
	local v5

	if keyBinding == nil then
		v5 = "None"
	else
		v5 = InputHandler.PrettyInput(keyBinding.Name)

		if v4 ~= nil then
			v5 = `{InputHandler.PrettyInput(v4.Name)} + {v5}`
		end
	end

	local text3 = maid:Value(v5)
	local value6 = maid:Value(color2)
	local value7 = maid:Value(color5)
	local value8 = maid:Value(0)
	maid:Add(InputHandler.Rebound:Connect(function(p3: string)
		if p3 ~= name2 then
			return
		end

		local keyBinding2, v7 = InputHandler.KeyBinding(name2)
		local v8

		if keyBinding2 == nil then
			v8 = "None"
		else
			v8 = InputHandler.PrettyInput(keyBinding2.Name)

			if v7 ~= nil then
				v8 = `{InputHandler.PrettyInput(v7.Name)} + {v8}`
			end
		end

		text3:Set(v8)
	end))

	local function play(childName: string)
		local assets = ReplicatedStorage:FindFirstChild("Assets")
		local sounds

		if assets ~= nil then
			sounds = assets:FindFirstChild("Sounds") or nil
		end

		local misc

		if sounds ~= nil then
			misc = sounds:FindFirstChild("Misc") or nil
		end

		local sound = misc ~= nil and misc:FindFirstChild(childName) or nil

		if sound == nil or not sound:IsA("Sound") then
			return
		end

		local clone = sound:Clone()
		clone.Parent = script
		clone:Play()
		DebrisModule:AddItem(clone, clone.TimeLength)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function tone(p3: string)
		if v3.Tone ~= nil then
			v3.Tone:Set(p3)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function announce(p3: string)
		if v3.Announce ~= nil then
			v3.Announce:Set(p3)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function control(done, cancel)
		if v3.Controller ~= nil then
			v3.Controller.Done = done
			v3.Controller.Cancel = cancel
		end
	end

	local v6 = nil
	local count = 0
	local v7 = {}
	local done
	local commit
	local count2 = 0

	-- equivalent calls inferred from this helper; original call sites unknown
	local function idle()
		value6:Reset()
		value7:Reset()
		value8:Reset()
	end

	local function stop()
		if v6 ~= nil then
			v6()
			v6 = nil
		end

		value3:Set(false)
		release() -- equivalent call inferred; original call site unknown
		local keyBinding2, v9 = InputHandler.KeyBinding(name2)
		local v10

		if keyBinding2 == nil then
			v10 = "None"
		else
			v10 = InputHandler.PrettyInput(keyBinding2.Name)

			if v9 ~= nil then
				v10 = `{InputHandler.PrettyInput(v9.Name)} + {v10}`
			end
		end

		text3:Set(v10)
		idle() -- equivalent call inferred; original call site unknown
		announce("") -- equivalent call inferred; original call site unknown
		tone("Asking") -- equivalent call inferred; original call site unknown
		control(nil, nil) -- equivalent call inferred; original call site unknown
	end

	local function dropped()
		v6 = nil
		table.clear(v7)
		tone("Asking") -- equivalent call inferred; original call site unknown
		value3:Set(false)
		local keyBinding2, v9 = InputHandler.KeyBinding(name2)
		local v10

		if keyBinding2 == nil then
			v10 = "None"
		else
			v10 = InputHandler.PrettyInput(keyBinding2.Name)

			if v9 ~= nil then
				v10 = `{InputHandler.PrettyInput(v9.Name)} + {v10}`
			end
		end

		text3:Set(v10)
		idle() -- equivalent call inferred; original call site unknown
	end

	local pulse

	pulse = function()
		if not value3:Compare(true) then
			return
		end

		value8:Set(value8:Compare(0) and 0.25 or 0)
		task.delay(0.45, pulse)
	end

	local count3 = 0

	-- equivalent calls inferred from this helper; original call sites unknown
	local function arm()
		count3 += 1
		local v8 = count3
		task.defer(function()
			if count3 ~= v8 or not value3:Compare(true) then
				return
			end

			local function held(list, flag: boolean?)
				v7 = list

				if flag then
					if #list == 1 then
						commit(list[1], nil)
					end
				else
					text2:Set(not (#list > 0) and "Recording" or InputHandler.PrettyInput(list[1].Name) .. " +")
					text3:Set(text2:Get())

					if #list >= 2 then
						commit(list[2], list[1])
					end
				end
			end

			if isGamepad then
				v6 = InputHandler.CapturePad(held, dropped, v3.PadIgnore)
			else
				v6 = InputHandler.Capture(held, dropped)
			end
		end)
	end

	local function finish(flag: boolean)
		v6 = nil
		table.clear(v7)

		if flag then
			tone("Taken") -- equivalent call inferred; original call site unknown
			play("success")
			text2:Set("Recording")
			value3:Set(false)
			release() -- equivalent call inferred; original call site unknown
			control(nil, nil) -- equivalent call inferred; original call site unknown
			announce("") -- equivalent call inferred; original call site unknown
			local keyBinding2, v9 = InputHandler.KeyBinding(name2)
			local v10

			if keyBinding2 == nil then
				v10 = "None"
			else
				v10 = InputHandler.PrettyInput(keyBinding2.Name)

				if v9 ~= nil then
					v10 = `{InputHandler.PrettyInput(v9.Name)} + {v10}`
				end
			end

			text3:Set(v10)
			count += 1
			local v11 = count
			value6:Set(color4)
			value7:Set(color6)
			value8:Reset()
			task.delay(0.45, function()
				if count ~= v11 then
					return
				end

				idle() -- equivalent call inferred; original call site unknown
			end)
		else
			tone("Refused") -- equivalent call inferred; original call site unknown
			play("denied")
			text2:Set("Recording")
			count2 += 1
			local v8 = count2
			task.delay(0.5, function()
				if not (count2 == v8 and value3:Compare(true)) then
					return
				end

				tone("Asking") -- equivalent call inferred; original call site unknown
			end)
			arm() -- equivalent call inferred; original call site unknown
		end
	end

	commit = function(p3, p4)
		if v6 ~= nil then
			v6()
		end

		if p3 == nil then
			stop()
			return
		end

		local v8 = true
		local onRecordPad

		if isGamepad then
			onRecordPad = v3.OnRecordPad
		else
			onRecordPad = v3.OnRecord
		end

		if onRecordPad ~= nil then
			v8 = onRecordPad(p3, p4) ~= false
		end

		finish(v8)
	end

	local function record(p3)
		if not canEdit or v3.CanClick ~= nil and not v3.CanClick() or v ~= nil and v ~= name2 or v == nil and os.clock() < v2 then
			return
		end

		if p3 == nil then
			ScreenEffects.CircleClick()
		else
			ScreenEffects.StrokeClick(p3, uDim)
		end

		if value3:Compare(true) then
			stop()
			return
		end

		value3:Set(true)
		v = name2
		text3:Set("Recording")
		value6:Set(color3)
		value7:Set(color6)
		text2:Set("Recording")
		announce(text) -- equivalent call inferred; original call site unknown

		if value3:Compare(true) then
			value8:Set(value8:Compare(0) and 0.25 or 0)
			task.delay(0.45, pulse)
		end

		control(done, stop) -- equivalent call inferred; original call site unknown
		tone("Asking") -- equivalent call inferred; original call site unknown
		arm() -- equivalent call inferred; original call site unknown
	end

	done = function()
		if not value3:Compare(true) then
			return
		end

		commit(v7[1], nil)
	end

	maid:Add(function()
		if v6 ~= nil then
			v6()
			v6 = nil
		end
	end)

	local function padName()
		local mapping = InputHandler.GetMapping(name2)

		if mapping ~= nil then
			for _, input in mapping do
				if typeof(input) == "table" then
					input = input.Input
				end

				if not (typeof(input) == "EnumItem" and input.EnumType == Enum.KeyCode) then
					continue
				end

				local name = input.Name

				if string.match(name, "^Button") ~= nil or string.match(name, "^DPad") ~= nil or string.match(
					name,
					"^Thumbstick"
				) ~= nil then
					return InputHandler.PrettyInput(name)
				end
			end
		end

		local keyBinding2, v8 = InputHandler.KeyBinding(name2)

		if keyBinding2 == nil then
			return "None"
		end

		local prettyInput = InputHandler.PrettyInput(keyBinding2.Name)

		if v8 == nil then
			return prettyInput
		end

		return (`{InputHandler.PrettyInput(v8.Name)} + {prettyInput}`)
	end

	local function padGlyph()
		local value9 = maid:Value(false)
		local v8 = maid:Create("Frame")({
			Name = name2,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.8, 0.8),
			BackgroundTransparency = 1,
			ZIndex = 2,
			Visible = maid:Do(function(callback)
				return callback(value3) ~= true
			end),
			function(instance)
				instance:AddTag("UIkey")

				-- equivalent calls inferred from this helper; original call sites unknown
				local function look()
					value9:Set(instance:FindFirstChild("KeyLabel") ~= nil)
				end

				maid:Connect(instance.ChildAdded, look)
				maid:Connect(instance.ChildRemoved, look)
				look() -- equivalent call inferred; original call site unknown
			end
		})
		return maid:Create("Frame")({
			Name = "Locked",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			v8,
			maid:Create("TextLabel")({
				Name = "Fallback",
				Text = padName(),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(100, 0.62),
				BackgroundTransparency = 1,
				TextBoundsOnChangedInit = measure,
				Visible = maid:Do(function(callback)
					return callback(value9) ~= true and callback(value3) ~= true
				end),
				TextColor3 = color5,
				Font = Enum.Font.SourceSansBold,
				TextScaled = true
			}),
			maid:Create("TextLabel")({
				Name = "Status",
				Text = text2,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(100, 0.62),
				ZIndex = 3,
				BackgroundTransparency = 1,
				TextBoundsOnChangedInit = measure,
				Visible = maid:Do(function(callback)
					return callback(value3) == true
				end),
				TextColor3 = maid:Animation(value7, info),
				Font = Enum.Font.SourceSansBold,
				TextScaled = true
			})
		})
	end

	local v8

	if isGamepad then
		v8 = padGlyph()
	else
		v8 = maid:Create("TextLabel")({
			Name = "Key",
			Text = text3,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(100, 0.62),
			BackgroundTransparency = 1,
			TextColor3 = maid:Animation(value7, info),
			Font = Enum.Font.SourceSansBold,
			TextScaled = true,
			TextBoundsOnChangedInit = measure
		})
	end

	return maid:Create("Frame")({
		Name = "Recorder",
		Size = v3.Size or UDim2.fromScale(1, 1),
		Position = v3.Position,
		AnchorPoint = v3.AnchorPoint,
		BackgroundColor3 = color,
		AbsoluteSizeOnChangedInit = function(_, point: Vector2)
			if point.Y <= 0 then
				return
			end

			value2:Set(point.Y / uiScale())
		end,
		maid:Create("UIGradient")({
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 0) })
		}),
		maid:Create("UICorner")({
			CornerRadius = UDim.new(0.2)
		}),
		maid:Create("TextLabel")({
			Name = "Label",
			Text = text,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0.08, 0.5),
			Size = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = 1,
			TextColor3 = color5,
			Font = Enum.Font.SourceSansSemibold,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left
		}),
		maid:Create("TextButton")({
			Name = "Box",
			AutoButtonColor = false,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.fromScale(0.975, 0.5),
			Size = maid:Do(function(callback)
				local v9 = callback(value2) * 0.62
				local v10 = math.max(callback(value) + 22, v9)
				return UDim2.new(0, math.ceil(v10), 0.62, 0)
			end),
			BackgroundColor3 = maid:Animation(value6, info),
			BackgroundTransparency = not canEdit and 0.5 or maid:Animation(value8, info2),
			maid:Create("UICorner")({
				CornerRadius = uDim
			}),
			v8,
			MouseButton1Click = function(p3)
				record(p3)
			end
		})
	})
end