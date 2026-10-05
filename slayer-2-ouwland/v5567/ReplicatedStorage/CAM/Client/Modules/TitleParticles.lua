local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local TitleParticles = {
	TICK = 0.5,
	PROMOTE_DISTANCE = 100,
	Runners = {},
	TemplateFor = function(childName: string)
		local assets = ReplicatedStorage:FindFirstChild("Assets")
		local titleParticles

		if assets ~= nil then
			titleParticles = assets:FindFirstChild("Title Particles")
		end

		if titleParticles == nil then
			return nil
		end

		return (titleParticles:FindFirstChild(childName))
	end
}

local function titleStuds(board, data)
	local parent = data.Parent

	if parent == nil or not parent:IsA("GuiObject") then
		return nil, nil, nil
	end

	local absoluteSize = parent.AbsoluteSize

	if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
		return nil, nil, nil
	end

	local vector2 = Vector2.new(board.Size.X.Scale / absoluteSize.X, board.Size.Y.Scale / absoluteSize.Y)
	local textBounds = data.TextBounds
	local v = data.AbsolutePosition + data.AbsoluteSize / 2 - (parent.AbsolutePosition + absoluteSize / 2)
	return textBounds * vector2, data.AbsoluteSize * vector2, Vector2.new(v.X * vector2.X, -v.Y * vector2.Y)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function drifted(p: number, p2: number)
	return math.abs(p2 - p) > math.max(p, p2) * 0.1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hideLabel(instance, flag: boolean)
	instance.TextTransparency = flag and 1 or 0
	local uIStroke = instance:FindFirstChildWhichIsA("UIStroke")

	if uIStroke ~= nil then
		uIStroke.Enabled = not flag
	end
end

local function newText(instance, board)
	local part = Instance.new("Part")
	part.Name = "TitleText"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Transparency = 1
	part.Size = createVector(0, 0, 0)
	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Face = Enum.NormalId.Front
	surfaceGui.LightInfluence = 0
	surfaceGui.MaxDistance = board.MaxDistance
	surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
	surfaceGui.Parent = part
	local clone = instance:Clone()
	clone.Name = "Title"
	clone.Position = UDim2.new()
	clone.AnchorPoint = Vector2.zero
	clone.Size = UDim2.fromScale(1, 1)
	clone.Visible = true
	clone.Parent = surfaceGui
	hideLabel(clone, false) -- equivalent call inferred; original call site unknown
	return part
end

local function syncText(text, instance, point: Vector2)
	local surfaceGui = text:FindFirstChildOfClass("SurfaceGui")
	local title = surfaceGui:FindFirstChild("Title")

	if drifted(text.Size.X, point.X) then
		text.Size = Vector3.new(point.X, point.Y, 0.05)
		surfaceGui.CanvasSize = Vector2.new(80 * point.X / point.Y, 80)
	elseif drifted(text.Size.Y, point.Y) then
		text.Size = Vector3.new(point.X, point.Y, 0.05)
		surfaceGui.CanvasSize = Vector2.new(80 * point.X / point.Y, 80)
	end

	if title.Text ~= instance.Text then
		title.Text = instance.Text
	end

	local uIGradient = instance:FindFirstChildWhichIsA("UIGradient")
	local uIGradient2 = title:FindFirstChildWhichIsA("UIGradient")

	if uIGradient ~= nil and uIGradient2 ~= nil and uIGradient2.Color ~= uIGradient.Color then
		uIGradient2.Color = uIGradient.Color
	end

	local uIStroke = instance:FindFirstChildWhichIsA("UIStroke")
	local uIStroke2 = title:FindFirstChildWhichIsA("UIStroke")

	if uIStroke ~= nil and uIStroke2 ~= nil and instance.AbsoluteSize.Y > 0 then
		local thickness = uIStroke.Thickness * 80 / instance.AbsoluteSize.Y

		if drifted(uIStroke2.Thickness, thickness) then
			uIStroke2.Thickness = thickness
		end

		if uIStroke2.Transparency ~= uIStroke.Transparency then
			uIStroke2.Transparency = uIStroke.Transparency
		end
	end
end

local function run(player)
	local currentCamera = workspace.CurrentCamera

	if currentCamera == nil or player.Root.Parent == nil then
		return
	end

	local label = player.Label()

	if label == nil or label.Parent == nil then
		return
	end

	local v, v2, v3 = titleStuds(player.Board, label)

	if v == nil or v2 == nil or v3 == nil then
		return
	end

	local v4 = player.Part

	if v4 == nil or v4.Parent == nil then
		v4 = Instance.new("Part")
		v4.Name = `TitleParticles_{player.Character.Name}`
		v4.Anchored = true
		v4.CanCollide = false
		v4.CanQuery = false
		v4.Massless = true
		v4.CanTouch = false
		v4.CastShadow = false
		v4.Transparency = 1
		local clone = player.Template:Clone()

		for _, child in clone:GetChildren() do
			child.Parent = v4
		end

		clone:Destroy()
		local v5 = 0

		for _, effect in v4:GetDescendants() do
			if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
				v5 = math.max(v5, effect.ZOffset)
			end
		end

		player.Push = v5 + 1
		v4.Parent = workspace
		player.Part = v4
		Ouwmit.Enable(v4, true, Ouwmit.Owned(player.Character))
	end

	if drifted(v4.Size.X, v.X) then
		v4.Size = Vector3.new(v.X, v.Y, 0.05)
	elseif drifted(v4.Size.Y, v.Y) then
		v4.Size = Vector3.new(v.X, v.Y, 0.05)
	end

	local cFrame = currentCamera.CFrame
	local v5 = player.Root.Position + player.Board.StudsOffsetWorldSpace + cFrame.RightVector * v3.X + cFrame.UpVector * v3.Y

	if player.Board.AlwaysOnTop then
		v4.CFrame = CFrame.lookAt(v5, cFrame.Position)
		return
	end

	local text = player.Text

	if text == nil or text.Parent == nil then
		text = newText(label, player.Board)
		text.Parent = v4
		player.Text = text
	end

	if player.Hidden ~= label then
		if player.Hidden ~= nil then
			hideLabel(player.Hidden, false) -- equivalent call inferred; original call site unknown
		end

		hideLabel(label, true) -- equivalent call inferred; original call site unknown
		player.Hidden = label
	end

	syncText(text, label, v2)
	text.CFrame = CFrame.lookAt(v5, cFrame.Position)
	local v6 = v5 + (v5 - cFrame.Position).Unit * player.Push
	v4.CFrame = CFrame.lookAt(v6, cFrame.Position)
end

function TitleParticles.Add(character, root, board, label, template)
	local runner = TitleParticles.Runners[character]

	if runner ~= nil and runner.Template == template then
		return
	end

	TitleParticles.Remove(character)
	TitleParticles.Runners[character] = {
		Character = character,
		Root = root,
		Board = board,
		Label = label,
		Template = template,
		Part = nil,
		Push = 1,
		Text = nil,
		Hidden = nil,
		Promoted = false,
		Run = run
	}
end

function TitleParticles.Remove(p)
	local runner = TitleParticles.Runners[p]

	if runner == nil then
		return
	end

	TitleParticles.Runners[p] = nil

	if runner.Hidden ~= nil then
		hideLabel(runner.Hidden, false) -- equivalent call inferred; original call site unknown
		runner.Hidden = nil
	end

	if runner.Text ~= nil then
		runner.Text:Destroy()
		runner.Text = nil
	end

	local part = runner.Part

	if part == nil then
		return
	end

	runner.Part = nil
	Ouwmit.Enable(part, false)
	task.delay(1, function()
		part:Destroy()
	end)
end

return TitleParticles