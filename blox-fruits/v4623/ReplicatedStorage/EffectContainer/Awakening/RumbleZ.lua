local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local sound = Util.Sound
local _ = Util.MasterClock
local Lightning = require(game.ReplicatedStorage.Util.Lightning)
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local inverse = CFrame.new(Vector3.new(), createVector(1, 0, 0)):inverse()
return function(data)
	local model = data.Model
	local width = data.Width or 15
	local shrink = data.Shrink or 0.6
	local modelRoot = model and model:WaitForChild("Root", 10)

	if not modelRoot or (modelRoot.Position - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
		return
	end

	sound:Play("ElectricImpactLong", modelRoot.Position)
	Effect.new("Awakening.RumbleZExplosion"):replicate({
		Position = modelRoot.CFrame * createVector(0, 0, 12),
		Size = 25,
		NoExplode = true,
		NoBurn = true,
		Nerf = true
	})
	local position = modelRoot.Position
	local part = nil
	local v = {}

	while modelRoot and model and model.Parent and modelRoot.Parent do
		local position2 = modelRoot.Position + Vector3.new(
			math.random() - 0.5,
			math.random() - 0.5,
			math.random() - 0.5
		).unit * (width * 0.33 + math.random() * width * 0.33)
		local magnitude = (position - position2).Magnitude

		if part then
			part.CFrame = CFrame.new(0.5 * (position + position2), position2) * inverse
			part.Mesh.Scale = Vector3.new(magnitude, width, width)
		end

		if magnitude > 10 or part == nil then
			local cframe = CFrame.new(0.5 * (position + position2), position2)
			part = Instance.new("Part")
			part.Anchored = true
			part.CanCollide = false
			part.TopSurface = 0
			part.BottomSurface = 0
			part.Size = createVector(1, 1, 1)
			part.Material = "Neon"
			part.CFrame = cframe * inverse
			part.Color = Color3.new(1, 1, 1)
			local specialMesh = Instance.new("SpecialMesh", part)
			specialMesh.Name = "Mesh"
			specialMesh.MeshType = "Cylinder"
			specialMesh.Scale = Vector3.new(magnitude, width, width)
			part.Parent = workspace._WorldOrigin

			if not _G.FastMode then
				local size = width * 0.2
				Lightning.new({
					Lifetime = 0.1 + math.random() * 0.2,
					DrawType = "Singular",
					Colors = {
						ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
						ColorSequenceKeypoint.new(1, data.Color)
					},
					Sizes = {
						{
							Size = size * 0.15,
							Time = 0
						},
						{
							Size = size,
							Time = 0.5
						},
						{
							Size = 0,
							Time = 1
						}
					},
					Transparencies = {
						{
							Transparency = 0,
							Time = 0
						},
						{
							Transparency = 0,
							Time = 1
						}
					},
					Points = {
						Start = {
							Position = position
						},
						End = {
							Position = position2
						}
					},
					ArcSize = {
						Min = 15,
						Max = 30
					},
					ChangesSegmentOffset = true,
					OffsetChangePercent = {
						EqualOrBelow = 0.15,
						Bounds = { 0, 1 }
					}
				})
			end

			v[part] = tick() - math.random() * 0.1
			position = position2
		end

		for k, v3 in pairs(v) do
			local v4 = (tick() - v3) / shrink

			if v4 > 1 then
				v[k] = nil
				k:Destroy()
			else
				k.Mesh.Scale = Vector3.new(k.Mesh.Scale.X, (1 - v4) * width, (1 - v4) * width)
				k.Color = Color3.new(1, 1, 1):Lerp(data.Color, v4)
			end
		end

		RunService.RenderStepped:Wait()
	end

	while true do
		for k, v2 in pairs(v) do
			local v3 = (tick() - v2) / shrink

			if v3 > 1 then
				v[k] = nil
				k:Destroy()
			else
				k.Mesh.Scale = Vector3.new(k.Mesh.Scale.X, (1 - v3) * width, (1 - v3) * width)
				k.Color = Color3.new(1, 1, 1):Lerp(data.Color, v3)
			end
		end

		RunService.RenderStepped:Wait()

		if next(v) ~= nil then
			continue
		end

		for k in pairs(v) do
			k:Destroy()
		end

		break
	end
end