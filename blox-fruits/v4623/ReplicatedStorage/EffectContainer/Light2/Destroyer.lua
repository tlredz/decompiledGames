local createVector = vector.create
local util = game.ReplicatedStorage:WaitForChild("Util")
require(util.Sound)
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local _ = game.ReplicatedStorage.Assets.Models.LightSword
local _WorldOrigin = workspace._WorldOrigin
local _ = workspace.Map

local function ScaleParticle(glare, p)
	local numberSequenceKeypoints = {}

	for _, keypoint in next, glare.Size.Keypoints, nil do
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * p, keypoint.Envelope)
		)
	end

	glare.Speed = NumberRange.new(glare.Speed.Min * p, glare.Speed.Max * p)
	glare.Drag *= p
	return NumberSequence.new(numberSequenceKeypoints)
end

local function func(data)
	local index = data.Index

	if index == 0 then
		local cFrame = data.CFrame
		local length = data.Length or 80
		local scale = data.Scale or 1
		local weak = data.Weak

		if (workspace.CurrentCamera.CFrame.p - cFrame.p).Magnitude > 600 then
			return
		end

		local clone = script.GlarePart.Attachment:Clone()
		clone.Parent = workspace.Terrain
		clone.Position = cFrame.p
		clone.Glare.Size = ScaleParticle(clone.Glare, 3 * scale)

		if scale == 1 then
			clone.Glare.Drag = 0
		end

		if not weak then
			local emitCount = clone.Glare:GetAttribute("EmitCount")
			clone.Glare:Emit(emitCount)
		end

		local part = Instance.new("Part")
		part.Size = createVector(1, 1, 1)
		part.Anchored = true
		part.CanCollide = false
		part.Material = "Neon"
		part.Color = Color3.new(1, 1, 0.5)
		part.CFrame = cFrame
		local specialMesh = Instance.new("SpecialMesh", part)
		specialMesh.MeshType = "Sphere"
		specialMesh.Scale = createVector(25, 25, 25) * scale * (weak and 0.5 or 1)
		part.Parent = _WorldOrigin
		TweenService:Create(part, TweenInfo.new(0.22), {
			Transparency = 1
		}):Play()
		TweenService:Create(specialMesh, TweenInfo.new(0.22, Enum.EasingStyle.Exponential), {
			Scale = Vector3.new(0, 0, length),
			Offset = Vector3.new(0, 0, -length / 2)
		}):Play()

		if not weak then
			for i = 2, 5 do
				local cFrame2 = cFrame * CFrame.new(0, 0, -length / 7 * i) * CFrame.Angles(0, 0, 0)
				local clone2 = script.Container:Clone()
				clone2.CFrame = cFrame2
				clone2.Parent = _WorldOrigin

				for _, child in pairs(clone2.Attachment:GetChildren()) do
					child:Emit((child:GetAttribute("EmitCount")))
				end

				task.delay(2, function()
					clone2:Destroy()
				end)
			end
		end

		task.wait(1)
		clone:Destroy()
		part:Destroy()
	elseif index == 1 then
		local attachment = data.Attachment

		while attachment and attachment.Parent and attachment:IsDescendantOf(workspace) do
			attachment.Star:Emit(1)
			attachment.Star_Inner:Emit(1)
			attachment.Star_Thin:Emit(1)
			attachment.Drops:Emit(1)
			attachment.Lines:Emit(1)
			task.wait(0.1)
		end
	end
end

return func