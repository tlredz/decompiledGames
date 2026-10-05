local parent = script.Parent.Parent
local Enums = require(parent.Enums)
local State = require(parent.State)
local Util = require(parent.Util)
local shared = parent.Parent.Shared
local React = require(shared.React)
local Ripple = require(shared.Ripple)
local hooks = parent.Hooks
local useClock = require(hooks.useClock)
local useSpring = require(hooks.useSpring)
local useSettings = require(hooks.useSettings)
local useStyleSheet = require(hooks.useStyleSheet)
local parent2 = script.Parent
local Button = require(parent2.Button)
local View3D = require(parent2.View3D)
local v = { "Inner", "Middle", "Outer" }
local v2 = {
	{
		Position = UDim2.new(0.5, 0, 0, 2),
		LeftTangent = UDim2.fromScale(-0.27614237491539667, 0),
		RightTangent = UDim2.fromScale(0.27614237491539667, 0)
	},
	{
		Position = UDim2.new(1, -2, 0.5, 0),
		LeftTangent = UDim2.fromScale(0, -0.27614237491539667),
		RightTangent = UDim2.fromScale(0, 0.27614237491539667)
	},
	{
		Position = UDim2.new(0.5, 0, 1, -2),
		LeftTangent = UDim2.fromScale(0.27614237491539667, 0),
		RightTangent = UDim2.fromScale(-0.27614237491539667, 0)
	},
	{
		Position = UDim2.new(0, 2, 0.5, 0),
		LeftTangent = UDim2.fromScale(0, 0.27614237491539667),
		RightTangent = UDim2.fromScale(0, -0.27614237491539667)
	},
	{
		Position = UDim2.new(0.5, 0, 0, 2),
		LeftTangent = UDim2.fromScale(-0.27614237491539667, 0),
		RightTangent = UDim2.fromScale(0.27614237491539667, 0)
	}
}

local function Ring(data)
	local v3, v4 = useStyleSheet("Palette", "Color3")
	local state, setState = React.useState({ Color3.new(), Color3.new() })
	local ref = React.useRef(nil)
	local ref2 = React.useRef(nil)
	local size0 = data.Size0
	local size1 = data.Size1
	local thickness0 = data.Thickness0
	local thickness1 = data.Thickness1
	React.useEffect(function()
		local current = ref2.current

		if current then
			local path2DControlPoints = {}

			for _, v5 in v2 do
				table.insert(
					path2DControlPoints,
					(Path2DControlPoint.new(v5.Position, v5.LeftTangent, v5.RightTangent))
				)
			end

			current:SetControlPoints(path2DControlPoints)
		end
	end, {})
	React.useEffect(function()
		local v5 = data[React.Tag]
		local v6 = nil

		for i = 1, #v do
			if v[i] ~= v5 then
				continue
			end

			v6 = v[i % #v + 1]
			break
		end

		if not (v5 and v6) then
			return
		end

		local v7 = v3((`Color-Ring-{v5}`))
		local v8 = v3((`Color-Ring-{v6}`))

		if v7 and v8 then
			setState({ v7, v8 })
		end
	end, { v4 })
	useClock(40, function(_)
		local v5 = data.Time:getValue() * 2 % 1
		local v6 = size0 + (size1 - size0) * v5
		local lerped = state[1]:Lerp(state[2], v5)
		local v7 = thickness0 + (thickness1 - thickness0) * v5
		local current = ref.current
		local current2 = ref2.current

		if current and current2 then
			current2.Color3 = lerped
			current.GroupTransparency = 1 - v7
			current.Size = UDim2.fromScale(v6 / 2, v6 / 2)
		end
	end, { state })
	return React.createElement("CanvasGroup", {
		[React.Tag] = Util.ClassNames("Ring", data[React.Tag]),
		ref = ref
	}, {
		Corner = React.createElement("UICorner", {
			CornerRadius = UDim.new(1, 0)
		}),
		Ring = React.createElement("Path2D", {
			ref = ref2
		})
	})
end

local function createModel()
	local clone = script.Render:Clone()
	local parts = {}

	for _, part in clone:GetChildren() do
		if not part:IsA("BasePart") then
			continue
		end

		local poses = part:FindFirstChild("Poses")
		local verts = part:FindFirstChild("Verts")
		local v4 = {
			Poses = {},
			Verts = {}
		}

		if poses then
			for _, child in poses:GetChildren() do
				local name = child.Name
				local cFramesByName = {}

				for _, attachment in child:GetChildren() do
					if attachment:IsA("Attachment") then
						cFramesByName[attachment.Name] = attachment.CFrame
					end
				end

				v4.Poses[name] = cFramesByName
			end
		end

		if verts then
			for _, bone in verts:GetChildren() do
				if bone:IsA("Bone") then
					v4.Verts[bone.Name] = bone
				end
			end
		end

		parts[part] = v4
	end

	return {
		Model = clone,
		Parts = parts
	}
end

local function PlayIcon(_)
	local v3 = React.useContext(State.Context)
	local state, setState = React.useState(createModel)

	if #state.Model:GetChildren() == 0 then
		setState(createModel)
	end

	local model = state.Model
	local parts = state.Parts
	local v4 = React.useState(function()
		return Ripple.createMotion(v3.Playing and 0 or 1)
	end)
	v4:spring(v3.Playing and 0 or 1, {
		tension = 400,
		friction = 30
	})
	useClock(30, function(p)
		v4:step(p)
	end, {})
	React.useState(function()
		return (v4:onStep(function(p)
			for _, part in parts do
				local poses = part.Poses
				local verts = part.Verts
				local play = poses.Play
				local pause = poses.Pause

				if not (play and pause) then
					continue
				end

				for k, vert in verts do
					vert.CFrame = pause[k]:Lerp(play[k], p)
				end
			end
		end))
	end, { parts })
	return React.createElement(View3D, {
		[React.Tag] = "PlayIcon",
		Model = model,
		FieldOfView = 1,
		AnchorPoint = Vector2.one / 2
	})
end

local function PlayButton(p)
	local v3 = useStyleSheet("Palette", "Color3")
	local v4 = useStyleSheet("Fonts", "Font")
	local v5 = React.useContext(State.Context)
	local playing = v5.Playing
	local proximityAudio = useSettings().ProximityAudio

	if v5.Status ~= Enums.UserStatus.BoomboxPurchased then
		proximityAudio = false
	end

	local groupTransparency, v7 = useSpring(playing and 0 or 1)
	local textTransparency, v9 = useSpring(playing and proximityAudio and 0 or 1)
	v7:spring(playing and 0 or 1, {
		tension = 200,
		friction = 30
	})
	v9:spring(playing and proximityAudio and 0 or 1, {
		tension = 200,
		friction = 30
	})
	local time, v11 = React.useBinding(0)
	useClock(40, function(p2)
		local spectrogram = v5.GetSpectrogram()

		if spectrogram then
			p2 *= math.clamp(spectrogram.RmsLevel * 20 + spectrogram.PeakLevel * 10, 0, 9) / 3
		end

		v11(time:getValue() + p2)
	end, {})
	return React.createElement("Frame", {
		[React.Tag] = Util.ClassNames("PlayButtonWrapper", p[React.Tag])
	}, {
		ForFriends = React.createElement("TextLabel", {
			BackgroundTransparency = 1,
			FontFace = v4("Font-Bold"),
			Size = textTransparency:map(function(p2: number)
				return UDim2.fromScale(3, (1 - p2) / 5)
			end),
			Position = UDim2.fromScale(0.5, 1.025),
			AnchorPoint = Vector2.new(0.5, 0),
			TextScaled = true,
			TextColor3 = v3("Color-Controls"),
			Text = "playing for others",
			TextStrokeTransparency = textTransparency:map(function(p2: number)
				return p2 / 8 + 0.875
			end),
			TextTransparency = textTransparency,
			ZIndex = 2
		}),
		Button = React.createElement(Button, {
			[React.Tag] = "PlayButton",
			OnActivated = function()
				v5.SetPlaying(not v5.Playing)
			end
		}, {
			Image = React.createElement(PlayIcon),
			Rings = React.createElement("CanvasGroup", {
				[React.Tag] = "RingsContainer",
				GroupTransparency = groupTransparency
			}, {
				Scale = React.createElement("UIScale", {
					Scale = groupTransparency:map(function(p2: number)
						return 1 - p2 / 2
					end)
				}),
				Ring0 = React.createElement(Ring, {
					[React.Tag] = "Inner",
					Size0 = 0.44,
					Size1 = 0.72,
					Thickness0 = 1,
					Thickness1 = 1,
					Time = time
				}),
				Ring1 = React.createElement(Ring, {
					[React.Tag] = "Middle",
					Size0 = 0.72,
					Size1 = 1,
					Thickness0 = 1,
					Thickness1 = 1,
					Time = time
				}),
				Ring2 = React.createElement(Ring, {
					[React.Tag] = "Outer",
					Size0 = 1,
					Size1 = 1.28,
					Thickness0 = 1,
					Thickness1 = 0,
					Time = time
				})
			})
		}),
		MinSize = React.createElement("UISizeConstraint", {
			MinSize = Vector2.new(16, 16)
		})
	})
end

return PlayButton