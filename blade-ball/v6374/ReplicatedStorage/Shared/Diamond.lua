local createVector = vector.create
local v = {
	A0 = createVector(0, 0.5, 0),
	A1 = createVector(0.5, 0, 0),
	A2 = createVector(0, -0.5, 0),
	A3 = createVector(-0.5, 0, 0)
}
local TweenService = game:GetService("TweenService")
return function(data)
	local cFrame = data.CFrame
	local endCFrame = data.EndCFrame or data.CFrame
	local startSize = data.StartSize
	local endSize = data.EndSize
	local thickness = data.Thickness or 1.5
	local color = data.Color or Color3.new(1, 1, 1)
	local tweenInfo = data.TweenInfo or TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	local stagger = data.Stagger or 0.5
	local faceCamera = data.FaceCamera
	local fades = data.Fades
	local clone = script.Part:Clone()
	clone.CFrame = cFrame
	local v2 = stagger or 0.5

	for k, v3 in next, v, nil do
		clone[k].Position = v3 * startSize
	end

	local v3 = {}
	local beam = Instance.new("Beam")
	beam.Transparency = NumberSequence.new(0)
	beam.LightInfluence = 0
	beam.Attachment0 = clone.A0
	beam.Attachment1 = clone.A1
	beam.Segments = 1
	beam.Width0 = thickness
	beam.Width1 = thickness
	beam.Parent = clone
	beam.Color = ColorSequence.new(color)
	v3[#v3 + 1] = beam
	local beam2 = Instance.new("Beam")
	beam2.Transparency = NumberSequence.new(0)
	beam2.LightInfluence = 0
	beam2.Attachment0 = clone.A1
	beam2.Attachment1 = clone.A2
	beam2.Segments = 1
	beam2.Width0 = thickness
	beam2.Width1 = thickness
	beam2.Parent = clone
	beam2.Color = ColorSequence.new(color)
	v3[#v3 + 1] = beam2
	local beam3 = Instance.new("Beam")
	beam3.Transparency = NumberSequence.new(0)
	beam3.LightInfluence = 0
	beam3.Attachment0 = clone.A2
	beam3.Attachment1 = clone.A3
	beam3.Segments = 1
	beam3.Width0 = thickness
	beam3.Width1 = thickness
	beam3.Parent = clone
	beam3.Color = ColorSequence.new(color)
	v3[#v3 + 1] = beam3
	local beam4 = Instance.new("Beam")
	beam4.Transparency = NumberSequence.new(0)
	beam4.LightInfluence = 0
	beam4.Attachment0 = clone.A3
	beam4.Attachment1 = clone.A0
	beam4.Segments = 1
	beam4.Width0 = thickness
	beam4.Width1 = thickness
	beam4.Parent = clone
	beam4.Color = ColorSequence.new(color)
	v3[#v3 + 1] = beam4
	clone.Parent = workspace.Runtime

	-- equivalent calls inferred from this helper; original call sites unknown
	local function SetScale(p)
		for k, v4 in next, v, nil do
			clone[k].Position = v4 * p
		end
	end

	local function SetTransparency(value)
		for _, v4 in next, v3, nil do
			if fades then
				NumberSequence.new(value)
			end

			v4.Width0 = thickness * (1 - value)
			v4.Width1 = thickness * (1 - value)
		end
	end

	task.spawn(function()
		clone.CFrame = faceCamera and CFrame.lookAt(cFrame.Position, workspace.CurrentCamera.CFrame.Position) or cFrame
		local total = 0

		while total <= tweenInfo.Time do
			total += task.wait()
			local v4 = math.min(1, total / tweenInfo.Time)
			SetTransparency(TweenService:GetValue(
				math.max(0, (v4 - v2) / (1 - v2)),
				tweenInfo.EasingStyle,
				tweenInfo.EasingDirection
			))
			SetScale(startSize + (endSize - startSize) * TweenService:GetValue(
				v4,
				tweenInfo.EasingStyle,
				tweenInfo.EasingDirection
			)) -- equivalent call inferred; original call site unknown
			clone.CFrame = faceCamera and CFrame.lookAt(
				cFrame:Lerp(endCFrame, v4).Position,
				workspace.CurrentCamera.CFrame.Position
			) or cFrame:Lerp(endCFrame, v4)
		end

		clone:Destroy()
	end)
end