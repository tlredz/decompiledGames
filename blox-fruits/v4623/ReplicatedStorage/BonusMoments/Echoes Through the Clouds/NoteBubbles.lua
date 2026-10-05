local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
local DISPLAY = CONSTANTS.FONT.FACE.DISPLAY
local v = {
	Melee = "Melee",
	Sword = "Sword",
	Fruit = "Fruit",
	Gun = "Gun"
}
local v2 = {
	Melee = "M",
	Sword = "S",
	Fruit = "F",
	Gun = "G"
}
local v3 = {
	Melee = Color3.fromRGB(255, 146, 146),
	Sword = Color3.fromRGB(173, 255, 106),
	Fruit = Color3.fromRGB(220, 164, 255),
	Gun = Color3.fromRGB(255, 217, 65)
}
local PRIMARY = CONSTANTS.COLOR.PRIMARY
local PURCHASE = CONSTANTS.COLOR.PURCHASE
local DANGER = CONSTANTS.COLOR.DANGER
local BLACK = CONSTANTS.COLOR.PALETTE.BLACK
local WHITE = CONSTANTS.COLOR.PALETTE.WHITE
local TEXT = CONSTANTS.COLOR.PRIMARY.TEXT

local function corner(p: number)
	return createElement("UICorner", {
		CornerRadius = UDim.new(p, 0)
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function deepen(color: Color3, p: number)
	local HSV, v4, v5 = color:ToHSV()
	return Color3.fromHSV(HSV, math.min(1, v4 * 1.3), v5 * p)
end

local function spriteFor(p: string, p2: string)
	local success, result = pcall(function()
		return SpriteMap[p][p2]
	end)

	if success and type(result) == "table" and type(result.Image) == "string" and result.Image ~= "" then
		return result
	end

	return nil
end

local function iconFor(p: string)
	local v4 = v[p]

	if v4 then
		return spriteFor("Stats", v4), (spriteFor("Stats", v4 .. "_Outline"))
	end

	return nil, nil
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function tiltFor(k: number)
	return (k % 2 == 0 and 1 or -1) * (k % 3 * 2 + 3)
end

local v4 = spriteFor("UI", "Shadow")

-- equivalent calls inferred from this helper; original call sites unknown
local function heightAt(value: number)
	return math.clamp(value, -0.15, 1.15) * -0.8 + 0.88
end

local function Bubbles(props)
	local round = props.Round
	local v5 = not round and {} or round.Notes
	local board = props.Board or 30
	local v6 = 7 / board
	local v7 = 1.4 / board
	local v8, v9 = React.useBinding({})
	local ref = React.useRef({})
	ref.current.round = round
	ref.current.marks = props.Marks
	ref.current.early = props.EarlyAt
	React.useEffect(function()
		local renderSteppedConnection = RunService.RenderStepped:Connect(function()
			local current = ref.current
			local round2 = current.round

			if not round2 then
				return
			end

			local serverTimeNow = workspace:GetServerTimeNow()
			local early = current.early
			local shake = not (early and serverTimeNow - early < 0.24) and 0 or 1 - (serverTimeNow - early) / 0.24
			local v11 = math.max(round2.Good, 0.05)
			local v12 = {}

			for i = 1, #round2.Notes do
				local v13 = round2.Start + (i - 1) * round2.Beat
				local v14 = v13 - 1.25
				local v15 = v13 + v11
				local v16 = v15 - v14
				local mark = current.marks[i]

				if mark then
					local v17 = serverTimeNow - mark.At
					local v18 = math.clamp((mark.At - v14) / v16, 0, 1)

					if mark.Verdict == "Miss" then
						local alpha = math.clamp(v17 / 0.6, 0, 1)
						v12[i] = {
							Rise = v18 - alpha * alpha * 0.06,
							Alpha = alpha,
							Scale = 1 - alpha * 0.25,
							Ring = 0,
							Shake = 0,
							Hit = false
						}
					else
						local v19 = math.clamp(v17 / 0.45, 0, 1)
						local v20 = 1 - (1 - v19) * (1 - v19)
						v12[i] = {
							Rise = v18 + v20 * 0.03,
							Alpha = v19 * v19,
							Scale = v20 * 0.62 + 1,
							Ring = 0,
							Shake = 0,
							Hit = true
						}
					end
				elseif v14 <= serverTimeNow and serverTimeNow <= v15 then
					local v17 = math.clamp((serverTimeNow - v14) / 0.22, 0, 1)
					local v18 = 1 - (1 - v17) * (1 - v17) * (1 - v17)
					local v19 = math.clamp((v15 - serverTimeNow) / 0.2, 0, 1)
					local v20 = v13 - v11 <= serverTimeNow
					local v21 = math.clamp((v13 - serverTimeNow) / v11, 0, 1)
					v12[i] = {
						Rise = (serverTimeNow - v14) / v16,
						Alpha = 1 - math.min(v18, v19) * (v20 and 1 or 0.44999999999999996),
						Scale = (v18 * 0.45 + 0.55) * (v19 * 0.45 + 0.55),
						Ring = not (v20 and v21 > 0) and 0 or v21 * 1.6 + 1,
						Shake = shake,
						Hit = false
					}
				end
			end

			v9(v12)
		end)
		return function()
			renderSteppedConnection:Disconnect()
		end
	end, {})
	local v10 = {}

	for k, v11 in v5 do
		local v12 = v[v11]
		local v13, v14

		if v12 then
			v13 = spriteFor("Stats", v12)
			v14 = spriteFor("Stats", v12 .. "_Outline")
		end

		local text = v2[v11] or "?"
		local v16 = v3[v11] or PRIMARY.BACKGROUND
		local color = deepen(v16, 0.52) -- equivalent call inferred; original call site unknown
		local rotation = tiltFor(k)
		-- equivalent calls inferred from this helper; original call sites unknown
		local v18 = k

		local function fn(p)
			local v19 = p[v18]

			if v19 then
				return (math.clamp(v19.Alpha, 0, 1))
			end

			return 1
		end

		local v19 = "Note" .. k
		local v22 = k
		local v23 = k
		local v24 = {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = v8:map(function(p)
				local v25 = p[v22]

				if not v25 then
					return UDim2.fromScale(0.5, 0.88)
				end

				local v26 = math.sin(v25.Rise * 3.141592653589793 * 2) * 0.012
				local v27 = not (v25.Shake > 0) and 0 or math.sin(os.clock() * 60) * 0.02 * v25.Shake
				return UDim2.fromScale(v26 + 0.5 + v27, heightAt(v25.Rise))
			end),
			Rotation = rotation,
			Size = v8:map(function(p)
				local v25 = p[v23]
				local v26 = v6 * (not v25 and 1 or v25.Scale)
				return UDim2.fromScale(v26, v26)
			end)
		}
		local burst

		if v4 then
			local v26 = k
			local v27 = k
			burst = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = v4.Image,
				ImageColor3 = PURCHASE.HIGHLIGHT,
				ImageRectOffset = v4.ImageRectOffset,
				ImageRectSize = v4.ImageRectSize,
				ImageTransparency = v8:map(function(p)
					local v28 = p[v26]

					if v28 and v28.Hit then
						return (math.clamp(v28.Alpha, 0, 1))
					end

					return 1
				end),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = v8:map(function(p)
					local v28 = p[v27]
					local v29 = not (v28 and v28.Hit) and 0 or v28.Scale * 2.4
					return UDim2.fromScale(v29, v29)
				end),
				ZIndex = 1
			})
		end

		local v26 = k
		local v27 = k
		local children = {
			Burst = burst,
			Ring = createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				Rotation = 45,
				Size = v8:map(function(p)
					local v28 = p[v26]
					local v29 = not v28 and 0 or v28.Ring
					return UDim2.fromScale(v29, v29)
				end),
				ZIndex = 2
			}, {
				Corner = createElement("UICorner", {
					CornerRadius = UDim.new(0.22, 0)
				}),
				Stroke = createElement("UIStroke", {
					Color = WHITE,
					Thickness = 3,
					Transparency = v8:map(function(p)
						local v28 = p[v27]

						if v28 and not (v28.Ring <= 0) then
							return (math.clamp(v28.Alpha + 0.25, 0, 1))
						end

						return 1
					end)
				})
			}),
			Shadow = 0,
			Body = 0
		}
		local v28 = k
		children.Shadow = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = BLACK,
			BackgroundTransparency = v8:map(function(p)
				local v29 = fn(p) -- equivalent call inferred; original call site unknown
				return v29 + (1 - v29) * 0.25
			end),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.555, 0.555),
			Size = UDim2.fromScale(1, 1),
			ZIndex = 3
		}, {
			Corner = createElement("UICorner", {
				CornerRadius = UDim.new(0.22, 0)
			})
		})
		local v31 = k
		local v33 = {
			BackgroundColor3 = v8:map(function(p)
				local v34 = p[v31]

				if v34 and v34.Hit then
					return PURCHASE.BORDER
				end

				return color
			end),
			BackgroundTransparency = v8:map(fn),
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 4
		}
		local v34 = k
		local v36 = {
			Corner = createElement("UICorner", {
				CornerRadius = UDim.new(0.22, 0)
			}),
			Stroke = createElement("UIStroke", {
				Color = BLACK,
				Thickness = 4,
				Transparency = v8:map(fn)
			}),
			Face = createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = v8:map(function(p)
					local v37 = p[v34]

					if v37 and v37.Hit then
						return PURCHASE.BACKGROUND
					end

					return v16
				end),
				BackgroundTransparency = v8:map(fn),
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0.5, 0.46),
				Size = UDim2.fromScale(0.78, 0.78)
			}, {
				Corner = createElement("UICorner", {
					CornerRadius = UDim.new(0.16, 0)
				}),
				Gradient = createElement("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
						ColorSequenceKeypoint.new(0.6, Color3.fromRGB(255, 255, 255)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(178, 178, 178))
					}),
					Rotation = 90
				})
			}),
			IconOutline = 0,
			Icon = 0
		}
		local iconOutline

		if v14 then
			iconOutline = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = v14.Image,
				ImageRectOffset = v14.ImageRectOffset,
				ImageRectSize = v14.ImageRectSize,
				ImageTransparency = v8:map(fn),
				Position = UDim2.fromScale(0.5, 0.46),
				Rotation = -rotation,
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.62, 0.62),
				ZIndex = 5
			})
		end

		v36.IconOutline = iconOutline
		local icon

		if v13 then
			icon = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = v13.Image,
				ImageRectOffset = v13.ImageRectOffset,
				ImageRectSize = v13.ImageRectSize,
				ImageTransparency = v8:map(fn),
				Position = UDim2.fromScale(0.5, 0.46),
				Rotation = -rotation,
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.62, 0.62),
				ZIndex = 6
			})
		else
			icon = createElement("TextLabel", {
				BackgroundTransparency = 1,
				FontFace = DISPLAY,
				Position = UDim2.fromScale(0, -0.04),
				Size = UDim2.fromScale(1, 1),
				Text = text,
				TextColor3 = TEXT,
				TextScaled = true,
				TextTransparency = v8:map(fn),
				ZIndex = 6
			}, {
				Stroke = createElement("UIStroke", {
					Color = BLACK,
					Thickness = CONSTANTS.THICKNESS.OUTLINE.THICK,
					Transparency = v8:map(fn)
				})
			})
		end

		v36.Icon = icon
		children.Body = createElement("Frame", v33, v36)
		v10[v19] = createElement("Frame", v24, children)
	end

	for k in v5 do
		local mark = props.Marks[k]
		local v11

		if props.Phase == "Done" then
			v11 = true
		elseif mark == nil then
			v11 = false
		else
			v11 = mark.Verdict ~= "Miss"
		end

		local v12

		if mark == nil then
			v12 = false
		else
			v12 = mark.Verdict == "Miss"
		end

		local count = #v5
		local v13 = v7 * 0.45
		local v14 = v7 * count + v13 * (count - 1)
		local v15 = "Pip" .. k
		local v18 = {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = 0,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Position = 0,
			Rotation = 0,
			Size = 0
		}
		local BORDER

		if v11 then
			BORDER = PURCHASE.BORDER
		elseif v12 then
			BORDER = DANGER.BORDER
		else
			BORDER = PRIMARY.BORDER
		end

		v18.BackgroundColor3 = BORDER
		v18.BackgroundTransparency = (v11 or v12) and 0 or 0.35
		v18.Position = UDim2.fromScale(0.5 - v14 * 0.5 + (v7 + v13) * (k - 0.5), 0.985)
		v18.Rotation = tiltFor(k)
		v18.Size = UDim2.fromScale(v7, v7)
		local v19 = {
			Corner = createElement("UICorner", {
				CornerRadius = UDim.new(0.22, 0)
			}),
			Stroke = createElement("UIStroke", {
				Color = BLACK,
				Thickness = 2,
				Transparency = 0.1
			}),
			Face = 0
		}
		local v22 = {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = 0,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Position = 0,
			Size = 0
		}
		local BACKGROUND

		if v11 then
			BACKGROUND = PURCHASE.BACKGROUND
		elseif v12 then
			BACKGROUND = DANGER.BACKGROUND
		else
			BACKGROUND = PRIMARY.BACKGROUND
		end

		v22.BackgroundColor3 = BACKGROUND
		v22.BackgroundTransparency = (v11 or v12) and 0 or 0.35
		v22.Position = UDim2.fromScale(0.5, 0.46)
		v22.Size = UDim2.fromScale(0.78, 0.78)
		v19.Face = createElement("Frame", v22, {
			Corner = createElement("UICorner", {
				CornerRadius = UDim.new(0.16, 0)
			})
		})
		v10[v15] = createElement("Frame", v18, v19)
	end

	return createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1)
	}, v10)
end

local NoteBubbles = {
	Bubbles = Bubbles
}
local v5 = nil
local adornee = nil
local v7 = {
	Round = nil,
	Marks = {},
	Phase = "Idle",
	EarlyAt = nil,
	Board = 30
}
local count = 0

local function render()
	if not v5 then
		return
	end

	v5.root:render(createElement(Bubbles, {
		Round = v7.Round,
		Marks = v7.Marks,
		Phase = v7.Phase,
		EarlyAt = v7.EarlyAt,
		Board = v7.Board
	}))
end

local function ensure()
	if v5 then
		return true
	end

	local playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")

	if not (playerGui and adornee) then
		return false
	end

	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "EchoesNoteBubbles"
	billboardGui.Adornee = adornee
	billboardGui.AlwaysOnTop = true
	billboardGui.LightInfluence = 0
	billboardGui.MaxDistance = 320
	billboardGui.Size = UDim2.fromScale(v7.Board, v7.Board)
	billboardGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	billboardGui.Parent = playerGui
	v5 = {
		root = ReactRoblox.createRoot(billboardGui),
		gui = billboardGui
	}
	return true
end

function NoteBubbles.isOpen()
	return v5 ~= nil
end

function NoteBubbles.setOrigin(position: Vector3?, value: number?)
	if typeof(position) ~= "Vector3" then
		return
	end

	v7.Board = math.max((value or 12) * 2, 26)
	local adornee2 = adornee

	if not (adornee2 and adornee2.Parent) then
		adornee2 = Instance.new("Part")
		adornee2.Name = "EchoesNoteAnchor"
		adornee2.Anchored = true
		adornee2.CanCollide = false
		adornee2.CanQuery = false
		adornee2.CanTouch = false
		adornee2.CastShadow = false
		adornee2.Transparency = 1
		adornee2.Size = createVector(1, 1, 1)
		adornee2.Parent = workspace.CurrentCamera
		adornee = adornee2
	end

	adornee2.CFrame = CFrame.new(position)

	if v5 then
		v5.gui.Adornee = adornee2
		v5.gui.Size = UDim2.fromScale(v7.Board, v7.Board)
		render()
	end
end

function NoteBubbles.setRound(p, start: number, beat: number, perfect: number, good: number)
	if not ensure() then
		return
	end

	count += 1
	v7.Round = {
		Notes = table.clone(p),
		Start = start,
		Beat = beat,
		Perfect = perfect,
		Good = good,
		Token = count
	}
	v7.Marks = {}
	v7.Phase = "Listen"
	v7.EarlyAt = nil
	render()
end

function NoteBubbles.land(p: number, verdict: string)
	if not v7.Round then
		return
	end

	v7.Marks[p] = {
		Verdict = verdict,
		At = workspace:GetServerTimeNow()
	}
	v7.Phase = "Listen"
	render()
end

function NoteBubbles.fail(p: number?)
	if not v7.Round then
		return
	end

	if p then
		v7.Marks[p] = {
			Verdict = "Miss",
			At = workspace:GetServerTimeNow()
		}
	end

	v7.Phase = "Fail"
	render()
end

function NoteBubbles.early()
	if not v7.Round or v7.Phase ~= "Listen" then
		return
	end

	v7.EarlyAt = workspace:GetServerTimeNow()
	render()
end

function NoteBubbles.finish()
	if not v5 then
		return
	end

	v7.Phase = "Done"
	render()
end

function NoteBubbles.hide()
	local v8 = v5
	v5 = nil
	v7.Round = nil
	v7.Marks = {}
	v7.Phase = "Idle"
	v7.EarlyAt = nil

	if v8 then
		v8.root:unmount()
		v8.gui:Destroy()
	end

	local v9 = adornee
	adornee = nil

	if v9 and v9.Parent then
		v9:Destroy()
	end
end

return NoteBubbles