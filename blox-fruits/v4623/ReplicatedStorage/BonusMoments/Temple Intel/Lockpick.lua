local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local Sound = require(game.ReplicatedStorage.Util.Sound)
local SimpleButton = require(game.ReplicatedStorage.React.Components.SimpleButton)
local createElement = React.createElement
local rbxassetfontsfamiliesHighwayGothicjson = Font.new(
	"rbxasset://fonts/families/HighwayGothic.json",
	Enum.FontWeight.Bold,
	Enum.FontStyle.Normal
)
local rbxassetfontsfamiliesGothamSSmjson = Font.new(
	"rbxasset://fonts/families/GothamSSm.json",
	Enum.FontWeight.Medium,
	Enum.FontStyle.Normal
)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local v = {
	"BFLab_Metal_Rattle_01",
	"BFLab_Metal_Rattle_02",
	"BFLab_Metal_Rattle_03",
	"BFLab_Metal_Rattle_04",
	"BFLab_Metal_Rattle_05"
}
local color = Color3.fromRGB(58, 52, 46)
local color2 = Color3.fromRGB(24, 21, 19)
local color3 = Color3.fromRGB(18, 16, 15)
local color4 = Color3.fromRGB(96, 87, 76)
local color5 = Color3.fromRGB(132, 102, 62)
local color6 = Color3.fromRGB(66, 50, 30)
local color7 = Color3.fromRGB(190, 152, 94)
local color8 = Color3.fromRGB(216, 221, 230)
local color9 = Color3.fromRGB(238, 122, 96)
local color10 = Color3.fromRGB(56, 42, 30)
local color11 = Color3.fromRGB(20, 16, 13)
local color12 = Color3.fromRGB(255, 206, 110)
local color13 = Color3.fromRGB(228, 231, 238)
local color14 = Color3.fromRGB(150, 152, 160)
local color15 = Color3.fromRGB(236, 238, 245)
local color16 = Color3.fromRGB(255, 198, 78)
local color17 = Color3.fromRGB(104, 236, 132)
local color18 = Color3.fromRGB(74, 58, 38)
local color19 = Color3.fromRGB(122, 96, 56)
local color20 = Color3.fromRGB(46, 42, 38)

local function readout(flag: boolean, p: number)
	if not flag then
		return color15
	end

	if p >= 1 then
		return color17
	end

	return color15:Lerp(color16, (math.clamp(p / 0.92, 0, 1)))
end

local function circle(value: number?)
	return createElement("UICorner", {
		CornerRadius = UDim.new(value or 1, 0)
	})
end

local function getControls()
	local success, result = pcall(function()
		local playerScripts = Players.LocalPlayer:FindFirstChild("PlayerScripts")
		local playerModule

		if playerScripts then
			playerModule = playerScripts:FindFirstChild("PlayerModule")
		end

		if not playerModule then
			return nil
		end

		local module = require(playerModule)
		return (module:GetControls())
	end)

	if success then
		return result
	end

	return nil
end

local function controlHint()
	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
		return "Arrows turn the pick. Hold and drag the lock to turn the wrench."
	end

	if UserInputService.GamepadEnabled and not UserInputService.KeyboardEnabled then
		return "Left stick turns the pick. Hold R2 to lean on the wrench."
	end

	return "A / D turns the pick. Hold and drag to turn the wrench. Green means the pin gives."
end

local function spoke(rotation: number, p2: number, mark)
	return createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		Rotation = rotation,
		Size = UDim2.fromOffset(p2 * 2, p2 * 2)
	}, {
		Mark = mark
	})
end

local function arrowButton(text: string, p2: number, fn, fn2)
	return createElement("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = Color3.fromRGB(58, 52, 46),
		BorderSizePixel = 0,
		FontFace = rbxassetfontsfamiliesHighwayGothicjson,
		Position = UDim2.fromOffset(p2, 0),
		Size = UDim2.new(0, 58, 1, 0),
		Text = text,
		TextColor3 = color13,
		TextSize = 22,
		[React.Event.InputBegan] = function(_, p3)
			if p3.UserInputType == Enum.UserInputType.MouseButton1 or p3.UserInputType == Enum.UserInputType.Touch then
				fn()
			end
		end,
		[React.Event.InputEnded] = function(_, p3)
			if p3.UserInputType == Enum.UserInputType.MouseButton1 or p3.UserInputType == Enum.UserInputType.Touch then
				fn2()
			end
		end,
		[React.Event.MouseLeave] = fn2
	}, {
		Corner = createElement("UICorner", {
			CornerRadius = UDim.new(0.2, 0)
		}),
		Stroke = createElement("UIStroke", {
			Color = Color3.fromRGB(18, 16, 14),
			Thickness = 2
		}),
		Gradient = createElement("UIGradient", {
			Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(172, 172, 172)),
			Rotation = 90
		})
	})
end

local function tick(udim: UDim2, color21: Color3, value: number?)
	return createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = color21,
		BackgroundTransparency = value or 0,
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.5, 0),
		Size = udim
	}, {
		Corner = createElement("UICorner", {
			CornerRadius = UDim.new(0.4, 0)
		})
	})
end

local function Lockpick(props)
	local state, setState = React.useState(props.Picks or 3)
	local state2, setState2 = React.useState("Picking")
	local state3, setState3 = React.useState(nil)
	local rotation, v3 = React.useBinding(0)
	local rotation2, v5 = React.useBinding(0)
	local backgroundColor, v7 = React.useBinding(color8)
	local size, v9 = React.useBinding(UDim2.fromScale(1, 1))
	local backgroundColor2, v11 = React.useBinding(color15)
	local backgroundColor3, v13 = React.useBinding(color18)
	local v14, v15 = React.useBinding(Vector2.zero)
	local ref = React.useRef(nil)
	local ref2 = React.useRef(props.OnFinish)
	ref2.current = props.OnFinish
	local ref3 = React.useRef(nil)

	if not ref3.current then
		ref3.current = {
			angle = 0,
			lastAngle = 0,
			motion = 0,
			dragging = false,
			dragTouch = nil,
			grabAngle = 0,
			grabCyl = 0,
			lastPoint = nil,
			want = 0,
			padHeld = false,
			padLatch = false,
			notice = 0,
			pin = props.Pin or math.random(-68, 68),
			cyl = 0,
			wear = 0,
			flash = 0,
			picks = props.Picks or 3,
			phase = "Picking",
			aim = {
				left = false,
				right = false,
				pad = 0
			},
			nextRattle = 0,
			done = false
		}
	end

	local current = ref3.current
	React.useEffect(function()
		local connections = {}
		local mouseBehavior = UserInputService.MouseBehavior
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		local success, result = pcall(function()
			local playerScripts = Players.LocalPlayer:FindFirstChild("PlayerScripts")
			local playerModule

			if playerScripts then
				playerModule = playerScripts:FindFirstChild("PlayerModule")
			end

			if not playerModule then
				return nil
			end

			local module = require(playerModule)
			return (module:GetControls())
		end)

		if not success then
			result = nil
		end

		if result then
			pcall(function()
				result:Disable()
			end)
		end

		local function finish(flag: boolean)
			if current.done then
				return
			end

			current.done = true
			local current2 = ref2.current

			if current2 then
				current2(flag)
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function inputPoint(p)
			return Vector2.new(p.Position.X, p.Position.Y) + GuiService:GetGuiInset()
		end

		local function lockCentre()
			local current2 = ref.current

			if current2 and current2.Parent then
				local absoluteSize = current2.AbsoluteSize
				return current2.AbsolutePosition + absoluteSize * 0.5, absoluteSize.X * 0.5
			else
				return nil, 0
			end
		end

		local function grabbed(point: Vector2)
			local current2 = ref.current
			local v16, v17

			if current2 and current2.Parent then
				local absoluteSize = current2.AbsoluteSize
				v16 = current2.AbsolutePosition + absoluteSize * 0.5
				v17 = absoluteSize.X * 0.5
			else
				v17 = 0
			end

			return v16 ~= nil and (point - v16).Magnitude <= v17 * 1.35
		end

		local function wrenchAngle(point: Vector2)
			local current2 = ref.current
			local v16

			if current2 and current2.Parent then
				local absoluteSize = current2.AbsoluteSize
				v16 = current2.AbsolutePosition + absoluteSize * 0.5
				local _ = absoluteSize.X * 0.5
			end

			if not v16 then
				return nil
			end

			local v17 = point - v16

			if v17.Magnitude < 12 then
				return nil
			end

			return (math.deg((math.atan2(-v17.X, v17.Y))))
		end

		local function beginDrag(lastPoint: Vector2)
			local current2 = ref.current
			local v16

			if current2 and current2.Parent then
				local absoluteSize = current2.AbsoluteSize
				v16 = current2.AbsolutePosition + absoluteSize * 0.5
				local _ = absoluteSize.X * 0.5
			end

			local grabAngle

			if v16 then
				local v18 = lastPoint - v16

				if not (v18.Magnitude < 12) then
					grabAngle = math.deg((math.atan2(-v18.X, v18.Y)))
				end
			end

			if not grabAngle then
				return false
			end

			current.grabAngle = grabAngle
			current.grabCyl = current.cyl
			current.lastPoint = lastPoint
			current.want = current.cyl
			return true
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function dragTo(lastPoint: Vector2)
			local current2 = ref.current
			local v16

			if current2 and current2.Parent then
				local absoluteSize = current2.AbsoluteSize
				v16 = current2.AbsolutePosition + absoluteSize * 0.5
				local _ = absoluteSize.X * 0.5
			end

			local v17

			if v16 then
				local v18 = lastPoint - v16

				if not (v18.Magnitude < 12) then
					v17 = math.deg((math.atan2(-v18.X, v18.Y)))
				end
			end

			if not v17 then
				return
			end

			current.lastPoint = lastPoint
			current.want = math.clamp(current.grabCyl + (v17 - current.grabAngle) / 84, 0, 1)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function rattle(p: number)
			local playUI = Sound:PlayUI(v[math.random(#v)], p)
			playUI.PlaybackSpeed = 1.15 + math.random() * 0.35
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function pressure()
			return (math.max(current.want, current.padHeld and 1 or 0))
		end

		local function setPad(flag: boolean)
			if flag then
				if current.phase ~= "Picking" or current.padLatch then
					return
				end

				if not current.padHeld and math.max(current.want, current.padHeld and 1 or 0) <= 0.02 then
					rattle(0.3) -- equivalent call inferred; original call site unknown
				end

				current.padHeld = true
			else
				current.padHeld = false
				current.padLatch = false
			end
		end

		local function say(p: string?, duration: number?)
			current.notice += 1
			local notice = current.notice
			setState3(p)

			if p and duration then
				task.delay(duration, function()
					if current.notice == notice then
						setState3(nil)
					end
				end)
			end
		end

		local function refill()
			if current.done then
				return
			end

			current.pin = props.Pin or math.random(-68, 68)
			current.picks = props.Picks or 3
			current.cyl = 0
			current.wear = 0
			current.want = 0
			current.padLatch = true
			current.dragging = false
			current.dragTouch = nil
			current.phase = "Picking"
			setState(current.picks)
			setState2("Picking")
			v5(0)
			v9(UDim2.fromScale(1, 1))
			v11(color15)
			v13(color18)
			current.notice += 1
			local notice = current.notice
			setState3("A fresh set of picks. The lock has reset.")
			task.delay(1.8, function()
				if current.notice == notice then
					setState3(nil)
				end
			end)
		end

		local function snapPick()
			current.cyl = 0
			current.wear = 0
			current.flash = 1
			current.want = 0
			local lastPoint = current.lastPoint

			if current.dragging and lastPoint then
				local v16 = current
				local current2 = ref.current
				local v17

				if current2 and current2.Parent then
					local absoluteSize = current2.AbsoluteSize
					v17 = current2.AbsolutePosition + absoluteSize * 0.5
					local _ = absoluteSize.X * 0.5
				end

				local v18

				if v17 then
					local v19 = lastPoint - v17

					if not (v19.Magnitude < 12) then
						v18 = math.deg((math.atan2(-v19.X, v19.Y)))
					end
				end

				v16.grabAngle = v18 or current.grabAngle
				current.grabCyl = 0
			else
				current.dragging = false
				current.dragTouch = nil
			end

			current.padLatch = current.padHeld
			current.padHeld = false
			v5(0)
			v9(UDim2.fromScale(1, 1))
			v11(color15)
			v13(color18)
			local playUI = Sound:PlayUI("Snap", 0.75)
			playUI.PlaybackSpeed = 1.3 + math.random() * 0.2
			current.picks -= 1
			setState(current.picks)

			if current.picks > 0 then
				local formatted = `The pick snaps. {current.picks} left.`
				current.notice += 1
				local notice = current.notice
				setState3(formatted)

				if formatted then
					task.delay(1.8, function()
						if current.notice == notice then
							setState3(nil)
						end
					end)
				end
			else
				current.phase = "Spent"
				setState2("Spent")
				current.notice += 1
				local _ = current.notice
				setState3(nil)
				task.delay(1.4, refill)
			end
		end

		local function openLock()
			current.phase = "Opened"
			current.cyl = 1
			current.wear = 0
			current.want = 0
			current.padHeld = false
			current.dragging = false
			current.dragTouch = nil
			setState2("Opened")
			v5(84)
			v9(UDim2.fromScale(1, 1))
			v11(color17)
			v13(color20)
			v7(color8)
			Sound:PlayUI("BFLab_Lab_Activate_01", 0.7)
			task.delay(0.6, finish, true)
		end

		local function step(p: number)
			if current.flash > 0 then
				current.flash = math.max(current.flash - p * 2.6, 0)
				local v16 = current.flash * 4
				v15(Vector2.new(math.round((math.random() - 0.5) * v16), (math.round((math.random() - 0.5) * v16))))
				v7(color8:Lerp(color9, current.flash))
			end

			if current.phase ~= "Picking" then
				return
			end

			local v16 = pressure() -- equivalent call inferred; original call site unknown
			local v17 = v16 > 0.02
			local v18 = math.clamp(
				(current.aim.right and 1 or 0) - (current.aim.left and 1 or 0) + current.aim.pad,
				-1,
				1
			)

			if v18 ~= 0 then
				current.angle = math.clamp(current.angle + v18 * 110 * p, -80, 80)
			end

			local v19 = math.abs(current.angle - current.lastAngle) / math.max(p, 0.004166666666666667)
			current.lastAngle = current.angle
			current.motion = current.motion * 0.82 + v19 * 0.18
			local v20 = math.abs(current.angle - current.pin)
			local v21 = v20 <= 6 and 1 or math.clamp(1 - (v20 - 6) / 56, 0, 1)
			local v22 = v21 ^ 1.6
			local flag = false

			if v17 then
				local v23 = math.min(v16, v22)
				local v24 = p / 0.75

				if current.cyl < v23 then
					current.cyl = math.min(current.cyl + v24, v23)
				elseif v23 < current.cyl then
					current.cyl = math.max(current.cyl - v24 * 3.5, v23)
				end

				if v22 + 0.02 < v16 then
					local cyl = current.cyl
					flag = v22 - 0.02 <= cyl
				else
					flag = false
				end
			else
				current.cyl = math.max(current.cyl - p / 0.75 * 3.5, 0)
			end

			local v23 = math.clamp(1 - current.motion / 30, 0, 1)

			if flag and v23 > 0 then
				current.wear = math.min(current.wear + p / 1.25 * ((1 - v21) * 0.65 + 0.35) * v23, 1)
				local now = os.clock()

				if current.nextRattle <= now then
					current.nextRattle = now + 0.13
					rattle(0.12 + current.wear * 0.2) -- equivalent call inferred; original call site unknown
				end
			else
				current.wear = math.max(current.wear - p * 0.55, 0)
			end

			local v24 = not (flag and v23 > 0) and 0 or (math.random() - 0.5) * 5 * (0.35 + current.wear) * v23
			v3(current.angle + v24)
			v5(current.cyl * 84 + v24 * 0.7)
			v9(UDim2.fromScale(1 - current.wear, 1))
			v11(readout(v17, v21))
			local v26

			if v17 then
				v26 = color19
			else
				v26 = color18
			end

			v13(v26)

			if current.flash <= 0 then
				v7(color8:Lerp(color9, current.wear * 0.8))
			end

			if v17 and v21 >= 1 and current.cyl >= 0.999 then
				openLock()
			elseif current.wear >= 1 then
				snapPick()
			end
		end

		table.insert(connections, UserInputService.InputBegan:Connect(function(dragTouch)
			local userInputType = dragTouch.UserInputType
			local keyCode = dragTouch.KeyCode

			if userInputType == Enum.UserInputType.MouseButton1 or userInputType == Enum.UserInputType.Touch then
				local point = inputPoint(dragTouch) -- equivalent call inferred; original call site unknown
				local current2 = ref.current
				local v16, v17

				if current2 and current2.Parent then
					local absoluteSize = current2.AbsoluteSize
					v16 = current2.AbsolutePosition + absoluteSize * 0.5
					v17 = absoluteSize.X * 0.5
				else
					v17 = 0
				end

				local v18

				if v16 == nil then
					v18 = false
				else
					v18 = (point - v16).Magnitude <= v17 * 1.35
				end

				if v18 then
					local current3 = ref.current
					local v19

					if current3 and current3.Parent then
						local absoluteSize = current3.AbsoluteSize
						v19 = current3.AbsolutePosition + absoluteSize * 0.5
						local _ = absoluteSize.X * 0.5
					end

					local grabAngle

					if v19 then
						local v21 = point - v19

						if not (v21.Magnitude < 12) then
							grabAngle = math.deg((math.atan2(-v21.X, v21.Y)))
						end
					end

					local flag

					if grabAngle then
						current.grabAngle = grabAngle
						current.grabCyl = current.cyl
						current.lastPoint = point
						current.want = current.cyl
						flag = true
					else
						flag = false
					end

					if flag then
						current.dragging = true

						if userInputType == Enum.UserInputType.Touch then
							current.dragTouch = dragTouch
						end
					end
				end
			elseif userInputType == Enum.UserInputType.Keyboard then
				if keyCode == Enum.KeyCode.A or keyCode == Enum.KeyCode.Left then
					current.aim.left = true
				elseif keyCode == Enum.KeyCode.D or keyCode == Enum.KeyCode.Right then
					current.aim.right = true
				end
			elseif userInputType == Enum.UserInputType.Gamepad1 and (keyCode == Enum.KeyCode.ButtonA or keyCode == Enum.KeyCode.ButtonR2) and current.phase == "Picking" then
				if current.padLatch then
					return
				end

				if not current.padHeld and math.max(current.want, current.padHeld and 1 or 0) <= 0.02 then
					rattle(0.3) -- equivalent call inferred; original call site unknown
				end

				current.padHeld = true
			end
		end))
		table.insert(connections, UserInputService.InputEnded:Connect(function(input)
			local userInputType = input.UserInputType
			local keyCode = input.KeyCode

			if userInputType == Enum.UserInputType.Touch then
				if current.dragTouch == input then
					current.dragTouch = nil
					current.dragging = false
					current.want = 0
				end
			elseif userInputType == Enum.UserInputType.MouseButton1 then
				current.dragging = false
				current.want = 0
			elseif userInputType == Enum.UserInputType.Keyboard then
				if keyCode == Enum.KeyCode.A or keyCode == Enum.KeyCode.Left then
					current.aim.left = false
				elseif keyCode == Enum.KeyCode.D or keyCode == Enum.KeyCode.Right then
					current.aim.right = false
				end
			elseif userInputType == Enum.UserInputType.Gamepad1 and (keyCode == Enum.KeyCode.ButtonA or keyCode == Enum.KeyCode.ButtonR2) then
				current.padHeld = false
				current.padLatch = false
			end
		end))
		table.insert(connections, UserInputService.InputChanged:Connect(function(input)
			local userInputType = input.UserInputType

			if userInputType == Enum.UserInputType.Touch then
				if current.dragTouch == input then
					local point = inputPoint(input) -- equivalent call inferred; original call site unknown
					dragTo(point) -- equivalent call inferred; original call site unknown
				end
			elseif userInputType == Enum.UserInputType.MouseMovement then
				if current.dragging then
					local point = inputPoint(input) -- equivalent call inferred; original call site unknown
					dragTo(point) -- equivalent call inferred; original call site unknown
				end
			elseif userInputType == Enum.UserInputType.Gamepad1 and input.KeyCode == Enum.KeyCode.Thumbstick1 then
				local X = input.Position.X
				current.aim.pad = not (math.abs(X) > 0.2) and 0 or X
			end
		end))
		table.insert(connections, RunService.RenderStepped:Connect(function(dt: number)
			step(math.min(dt, 0.1))
		end))
		return function()
			for _, connection in connections do
				connection:Disconnect()
			end

			UserInputService.MouseBehavior = mouseBehavior

			if result then
				pcall(function()
					result:Enable()
				end)
			end
		end
	end, {})
	local children = {
		Rim = createElement("Frame", {
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1)
		}, {
			Corner = createElement("UICorner", {
				CornerRadius = UDim.new(1, 0)
			}),
			Stroke = createElement("UIStroke", {
				Color = color2,
				Thickness = 3
			}),
			Gradient = createElement("UIGradient", {
				Color = ColorSequence.new(Color3.fromRGB(84, 76, 68), color2),
				Rotation = 90
			})
		}),
		Well = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = color3,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.82, 0.82)
		}, {
			Corner = createElement("UICorner", {
				CornerRadius = UDim.new(1, 0)
			}),
			Stroke = createElement("UIStroke", {
				Color = Color3.fromRGB(10, 9, 8),
				Thickness = 2
			}),
			Gradient = createElement("UIGradient", {
				Color = ColorSequence.new(Color3.fromRGB(120, 120, 120), Color3.fromRGB(255, 255, 255)),
				Rotation = 90
			})
		})
	}

	for i = 1, 8 do
		children["Rivet" .. i] = spoke((i - 1) * 45 + 22.5, 107.38000000000001, createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = color4,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.fromOffset(7, 7)
		}, {
			Corner = createElement("UICorner", {
				CornerRadius = UDim.new(1, 0)
			}),
			Stroke = createElement("UIStroke", {
				Color = color2,
				Thickness = 1
			})
		}))
	end

	for k, v16 in {
		-80,
		-40,
		0,
		40,
		80
	} do
		local v17 = math.abs(v16) == 80
		local v18 = "Range" .. k
		local uDim = UDim2.fromOffset(v17 and 3 or 2, v17 and 13 or 8)
		local v22

		if v17 then
			v22 = Color3.fromRGB(126, 116, 102)
		else
			v22 = Color3.fromRGB(88, 81, 72)
		end

		children[v18] = spoke(v16, 90.86, tick(uDim, v22))
	end

	if props.Reveal then
		children.Pin = spoke(current.pin, 90.86, tick(UDim2.fromOffset(3, 15), color17))
	end

	children.Cylinder = createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		Rotation = rotation2,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 2
	}, {
		Disc = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = color5,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.6, 0.6)
		}, {
			Corner = createElement("UICorner", {
				CornerRadius = UDim.new(1, 0)
			}),
			Stroke = createElement("UIStroke", {
				Color = color6,
				Thickness = 3
			}),
			Gradient = createElement("UIGradient", {
				Color = ColorSequence.new(color7, color6),
				Rotation = 118
			})
		}),
		Ward1 = spoke(-52, 57.82, tick(UDim2.fromOffset(2, 10), color6, 0.4)),
		Ward2 = spoke(58, 57.82, tick(UDim2.fromOffset(2, 10), color6, 0.4)),
		Ward3 = spoke(164, 57.82, tick(UDim2.fromOffset(2, 10), color6, 0.4)),
		Notch = spoke(0, 64.9, tick(UDim2.fromOffset(5, 14), color7)),
		Slot = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = color3,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(12, 36),
			ZIndex = 3
		}, {
			Corner = createElement("UICorner", {
				CornerRadius = UDim.new(0.35, 0)
			})
		}),
		Keyhole = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = color3,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(28, 28),
			ZIndex = 3
		}, {
			Corner = createElement("UICorner", {
				CornerRadius = UDim.new(1, 0)
			})
		})
	})
	children.Wrench = createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		Rotation = rotation2,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 3
	}, {
		Body = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(18, 96)
		}, {
			Shaft = createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.fromRGB(150, 154, 162),
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0.5, 0),
				Size = UDim2.fromOffset(7, 62)
			}, {
				Corner = createElement("UICorner", {
					CornerRadius = UDim.new(0.4, 0)
				}),
				Stroke = createElement("UIStroke", {
					Color = Color3.fromRGB(24, 22, 20),
					Thickness = 1,
					Transparency = 0.25
				}),
				Gradient = createElement("UIGradient", {
					Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(120, 124, 132)),
					Rotation = 8
				})
			}),
			Handle = createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 1),
				BackgroundColor3 = Color3.fromRGB(78, 52, 34),
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0.5, 1),
				Size = UDim2.fromOffset(18, 40)
			}, {
				Corner = createElement("UICorner", {
					CornerRadius = UDim.new(0.3, 0)
				}),
				Stroke = createElement("UIStroke", {
					Color = Color3.fromRGB(26, 18, 12),
					Thickness = 2
				}),
				Gradient = createElement("UIGradient", {
					Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(138, 138, 138)),
					Rotation = 8
				}),
				Ferrule = createElement("Frame", {
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundColor3 = color7,
					BorderSizePixel = 0,
					Position = UDim2.new(0.5, 0, 0, 2),
					Size = UDim2.new(1, 3, 0, 6)
				}, {
					Corner = createElement("UICorner", {
						CornerRadius = UDim.new(0.5, 0)
					})
				})
			})
		})
	})
	children.Pick = createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		Rotation = rotation,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 4
	}, {
		Body = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(16, 104)
		}, {
			Shaft = createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 1),
				BackgroundColor3 = backgroundColor,
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0.5, 1),
				Size = UDim2.fromOffset(5, 104)
			}, {
				Corner = createElement("UICorner", {
					CornerRadius = UDim.new(0.5, 0)
				}),
				Stroke = createElement("UIStroke", {
					Color = Color3.fromRGB(26, 24, 22),
					Thickness = 1,
					Transparency = 0.3
				}),
				Gradient = createElement("UIGradient", {
					Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(138, 144, 154)),
					Rotation = 12
				})
			}),
			Grip = createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = color10,
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0.5, 0),
				Size = UDim2.fromOffset(13, 34)
			}, {
				Corner = createElement("UICorner", {
					CornerRadius = UDim.new(0.32, 0)
				}),
				Stroke = createElement("UIStroke", {
					Color = color11,
					Thickness = 2
				}),
				Gradient = createElement("UIGradient", {
					Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(146, 146, 146)),
					Rotation = 12
				}),
				Band1 = createElement("Frame", {
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundColor3 = color7,
					BorderSizePixel = 0,
					Position = UDim2.new(0.5, 0, 0, 7),
					Size = UDim2.new(1, 3, 0, 3)
				}, {
					Corner = createElement("UICorner", {
						CornerRadius = UDim.new(0.5, 0)
					})
				}),
				Band2 = createElement("Frame", {
					AnchorPoint = Vector2.new(0.5, 1),
					BackgroundColor3 = color7,
					BorderSizePixel = 0,
					Position = UDim2.new(0.5, 0, 1, -7),
					Size = UDim2.new(1, 3, 0, 3)
				}, {
					Corner = createElement("UICorner", {
						CornerRadius = UDim.new(0.5, 0)
					})
				})
			})
		})
	})
	children.Hub = createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(34, 30, 27),
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(18, 18),
		ZIndex = 5
	}, {
		Corner = createElement("UICorner", {
			CornerRadius = UDim.new(1, 0)
		}),
		Stroke = createElement("UIStroke", {
			Color = Color3.fromRGB(14, 12, 11),
			Thickness = 2
		})
	})
	local v16 = {
		Layout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0, 12),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center
		})
	}

	for i = 1, props.Picks or 3 do
		local v17 = i <= state
		local v18 = "Pick" .. i
		local backgroundColor4

		if v17 then
			backgroundColor4 = color8
		else
			backgroundColor4 = Color3.fromRGB(58, 54, 50)
		end

		local v21 = {
			BackgroundColor3 = backgroundColor4,
			BackgroundTransparency = v17 and 0 or 0.3,
			BorderSizePixel = 0,
			LayoutOrder = i,
			Rotation = -26,
			Size = UDim2.fromOffset(5, 26)
		}
		local v23 = {
			Corner = createElement("UICorner", {
				CornerRadius = UDim.new(0.5, 0)
			}),
			Grip = 0
		}
		local v26 = {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = 0,
			BorderSizePixel = 0,
			Position = 0,
			Size = 0
		}
		local backgroundColor5

		if v17 then
			backgroundColor5 = color10
		else
			backgroundColor5 = Color3.fromRGB(44, 41, 38)
		end

		v26.BackgroundColor3 = backgroundColor5
		v26.Position = UDim2.fromScale(0.5, 0)
		v26.Size = UDim2.new(1, 3, 0, 10)
		v23.Grip = createElement("Frame", v26, {
			Corner = createElement("UICorner", {
				CornerRadius = UDim.new(0.4, 0)
			})
		})
		v16[v18] = createElement("Frame", v21, v23)
	end

	local text = state2 == "Opened" and "The shackle springs open." or state2 == "Spent" and "Your last pick snapped off in the barrel." or state3 or UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and "Arrows turn the pick. Hold and drag the lock to turn the wrench." or UserInputService.GamepadEnabled and not UserInputService.KeyboardEnabled and "Left stick turns the pick. Hold R2 to lean on the wrench." or "A / D turns the pick. Hold and drag to turn the wrench. Green means the pin gives."
	local text2 = state2 == "Opened" and "UNLOCKED" or state2 == "Spent" and "OUT OF PICKS" or "HOLD & DRAG WRENCH"
	local children2 = {
		Header = createElement("Frame", {
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			AutomaticSize = Enum.AutomaticSize.None,
			Size = UDim2.fromOffset(360, 44),
			Position = UDim2.fromOffset(0, 0)
		}, {
			UICorner = createElement("UICorner", {
				CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.MD
			}),
			UIStroke = createElement("UIStroke", {
				Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
			}),
			UIGradient = createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, CONSTANTS.COLOR.HEADER.BACKGROUND),
					ColorSequenceKeypoint.new(0.509499, CONSTANTS.COLOR.PALETTE.GOLD_450),
					ColorSequenceKeypoint.new(1, CONSTANTS.COLOR.HEADER.BACKGROUND)
				})
			}),
			TextLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.TITLE,
				Position = UDim2.fromScale(0.5, 0.55),
				Size = UDim2.fromScale(0.8, 0.8),
				Text = "RUSTED PADLOCK",
				TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				TextScaled = true
			}, {
				UIStroke = createElement("UIStroke", {
					Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
				}),
				TextLabel = createElement("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					FontFace = CONSTANTS.FONT.FACE.TITLE,
					Position = UDim2.fromScale(0.5, 0.45),
					Size = UDim2.fromScale(1, 1),
					Text = "RUSTED PADLOCK",
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					TextScaled = true
				}, {
					UIStroke = createElement("UIStroke", {
						Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
					})
				})
			}),
			Close = createElement(SimpleButton, {
				BackgroundColor3 = CONSTANTS.COLOR.DANGER.BACKGROUND,
				BorderColor3 = CONSTANTS.COLOR.DANGER.BORDER,
				HighlightColor3 = CONSTANTS.COLOR.DANGER.HIGHLIGHT,
				AnchorPoint = Vector2.new(1, 0.5),
				HighlightVariant = "Centered",
				Icon = {
					Image = "rbxassetid://127503254560275",
					ImageRectSize = Vector2.new(100, 100),
					ImageRectOffset = Vector2.zero
				},
				IconSize = UDim2.fromScale(1, 1),
				LayoutOrder = -999,
				Position = UDim2.fromScale(0.99, 0.5),
				Size = UDim2.fromScale(0.084927385, 0.748107),
				ZIndex = CONSTANTS.LAYER.RAISED,
				[React.Event.Activated] = function()
					local current2 = ref2.current

					if current2 and not current.done then
						current.done = true
						current2(false)
					end
				end
			})
		}),
		Lock = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			Position = v14:map(function(point: Vector2)
				return UDim2.new(0.5, point.X, 0, 62 + point.Y)
			end),
			Size = UDim2.fromOffset(236, 236),
			ref = ref
		}, children),
		BarTrack = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = Color3.fromRGB(26, 24, 22),
			BorderSizePixel = 0,
			Position = UDim2.new(0.5, 0, 0, 314),
			Size = UDim2.fromOffset(236, 14)
		}, {
			Corner = createElement("UICorner", {
				CornerRadius = UDim.new(0.5, 0)
			}),
			Stroke = createElement("UIStroke", {
				Color = Color3.fromRGB(12, 11, 10),
				Thickness = 2
			}),
			Fill = createElement("Frame", {
				BackgroundColor3 = backgroundColor2,
				BorderSizePixel = 0,
				Size = size
			}, {
				Corner = createElement("UICorner", {
					CornerRadius = UDim.new(0.5, 0)
				}),
				Gradient = createElement("UIGradient", {
					Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(186, 186, 186)),
					Rotation = 90
				})
			})
		}),
		Picks = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			Position = UDim2.new(0.5, 0, 0, 340),
			Size = UDim2.fromOffset(236, 28)
		}, v16),
		Hint = 0,
		Controls = 0
	}
	local v27 = {
		BackgroundTransparency = 1,
		FontFace = rbxassetfontsfamiliesGothamSSmjson,
		Position = UDim2.fromOffset(19, 372),
		Size = UDim2.new(1, -38, 0, 38),
		Text = text,
		TextColor3 = 0,
		TextSize = 15,
		TextWrapped = true
	}
	local textColor

	if state2 == "Spent" then
		textColor = color9
	else
		textColor = color14
	end

	v27.TextColor3 = textColor
	children2.Hint = createElement("TextLabel", v27)
	local v31 = {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 0, 416),
		Size = UDim2.fromOffset(338, 52)
	}
	local v32 = {
		Left = arrowButton("◀", 0, function()
			current.aim.left = true
		end, function()
			current.aim.left = false
		end),
		Right = arrowButton("▶", 66, function()
			current.aim.right = true
		end, function()
			current.aim.right = false
		end),
		Wrench = 0
	}
	local v35 = {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = 0,
		BorderSizePixel = 0,
		Position = 0,
		Size = 0
	}

	if state2 ~= "Picking" then
		backgroundColor3 = color20
	end

	v35.BackgroundColor3 = backgroundColor3
	v35.Position = UDim2.fromScale(1, 0)
	v35.Size = UDim2.new(1, -140, 1, 0)
	local v36 = {
		Corner = createElement("UICorner", {
			CornerRadius = UDim.new(0.16, 0)
		}),
		Stroke = createElement("UIStroke", {
			Color = Color3.fromRGB(18, 16, 14),
			Thickness = 2
		}),
		Gradient = createElement("UIGradient", {
			Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(176, 176, 176)),
			Rotation = 90
		}),
		Label = 0
	}
	local v39 = {
		BackgroundTransparency = 1,
		FontFace = rbxassetfontsfamiliesHighwayGothicjson,
		Size = UDim2.fromScale(1, 1),
		Text = text2,
		TextColor3 = 0,
		TextSize = 19
	}
	local textColor2

	if state2 == "Opened" then
		textColor2 = color12
	else
		textColor2 = color13
	end

	v39.TextColor3 = textColor2
	v36.Label = createElement("TextLabel", v39, {
		Stroke = createElement("UIStroke", {
			Color = Color3.new(0, 0, 0),
			Thickness = 2
		})
	})
	v32.Wrench = createElement("Frame", v35, v36)
	children2.Controls = createElement("Frame", v31, v32)
	return createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1)
	}, {
		Backdrop = createElement("Frame", {
			Active = true,
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.4,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1)
		}),
		Panel = createElement("Frame", {
			BackgroundTransparency = CONSTANTS.ALPHA.LIGHT,
			BackgroundColor3 = CONSTANTS.COLOR.PANEL.BACKGROUND,
			AutomaticSize = Enum.AutomaticSize.None,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(360, 482)
		}, children2)
	})
end

local Lockpick2 = {
	Lockpick = Lockpick,
	PickCount = 3
}
local v2 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyHandle(p)
	p.root:unmount()
	p.gui:Destroy()
end

function Lockpick2.isOpen()
	return v2 ~= nil
end

function Lockpick2.close()
	local v3 = v2

	if not v3 then
		return
	end

	v2 = nil
	destroyHandle(v3) -- equivalent call inferred; original call site unknown

	if v3.onClose then
		v3.onClose()
	end
end

function Lockpick2.open(callback, onClose)
	if v2 then
		return
	end

	local playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		return
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "TempleIntelLockpick"
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.IgnoreGuiInset = true
	screenGui.ScreenInsets = Enum.ScreenInsets.None
	screenGui.DisplayOrder = 60
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui
	local root = ReactRoblox.createRoot(screenGui)
	local v3 = {
		root = root,
		gui = screenGui,
		onClose = onClose
	}
	v2 = v3

	local function finish(flag: boolean)
		if v2 ~= v3 then
			return
		end

		v2 = nil

		if flag then
			callback()
		else
			onClose()
		end

		task.defer(destroyHandle, v3)
	end

	root:render(createElement(Lockpick, {
		OnFinish = finish
	}))
end

return Lockpick2