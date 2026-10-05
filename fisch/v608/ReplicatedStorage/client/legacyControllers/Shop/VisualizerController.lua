local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
require(ReplicatedStorage.packages.Observers)
local Trove = require(ReplicatedStorage.packages.Trove)
local emit = require(ReplicatedStorage.packages.emit)
local currentCamera = workspace.CurrentCamera
local v = nil
local maid = Trove.new()
local lastTime = nil
local part = Instance.new("Part")
part.Name = "Black"
part.Material = Enum.Material.Neon
part.Color = Color3.new()
part.Transparency = 0.25
part.CanCollide = false
part.CanQuery = false
part.CanTouch = false
part.CastShadow = false
part.Anchored = true
local hud = Players.LocalPlayer.PlayerGui:WaitForChild("hud")
local uiblur = Lighting:WaitForChild("uiblur")
local uicc = Lighting:WaitForChild("uicc")
local VisualizerController = {}

function VisualizerController.Visualize(_, instance)
	if not instance then
		return
	end

	maid:Clean()
	part.Parent = workspace
	hud.Enabled = false
	uiblur.Enabled = false
	uicc.Enabled = false
	local boundingBox, v2 = instance:GetBoundingBox()
	local v3 = math.max(v2.X, v2.Y, v2.Z)
	local viewportSize = currentCamera.ViewportSize
	math.min(viewportSize.X, viewportSize.Y)
	local folder = maid:Add(instance:Clone())

	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
			descendant.Massless = true
			descendant.CastShadow = false
		elseif descendant:IsA("ParticleEmitter") then
			descendant.ZOffset = math.min(descendant.ZOffset, 0)
			descendant.LockedToPart = true
		elseif descendant:IsA("Sound") then
			descendant.Looped = false
		end
	end

	folder:ScaleTo(folder:GetScale() * (0.25 / (v3 * 2)))

	if folder.PrimaryPart then
		folder.PrimaryPart.PivotOffset += Vector3.new(
			0,
			(boundingBox.Position.Y - folder.PrimaryPart.Position.Y) * folder:GetScale(),
			0
		)
	end

	folder.Parent = workspace
	local sphere = folder:FindFirstChild("Sphere")

	if sphere then
		local pointLight = Instance.new("PointLight", sphere)
		pointLight.Brightness = 9
	end

	lastTime = os.clock()
	maid:Add(task.spawn(function()
		task.wait(2)

		while true do
			emit.emit(folder)
			local v4 = 2

			for _, sound in folder:GetDescendants() do
				if not sound:IsA("Sound") then
					continue
				end

				sound:Play()

				if v4 < sound.TimeLength + 1 then
					v4 = sound.TimeLength + 1
				end
			end

			task.wait(v4)
		end
	end))
	v = folder
end

function VisualizerController.Start(_)
	RunService.PreRender:Connect(function()
		if v then
			local cFrame = currentCamera.CFrame
			local position = cFrame.Position
			local lookVector = cFrame.LookVector
			v:PivotTo(CFrame.lookAt(position + lookVector * 0.25, position) * CFrame.fromOrientation(
				-0.1,
				math.rad(os.clock() - lastTime) * 20,
				0
			))
			local fieldOfView = currentCamera.FieldOfView
			local viewportSize = currentCamera.ViewportSize
			local v2 = viewportSize.X / viewportSize.Y
			local v3 = math.tan((math.rad(fieldOfView / 2))) * 2 * 2
			part.Size = Vector3.new(v3 * v2, v3, 1)
			part:PivotTo(CFrame.lookAt(position + lookVector * 2.5, position))
		end
	end)
	UserInputService.InputBegan:Connect(function(input, _)
		if not v then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch or input.KeyCode == Enum.KeyCode.ButtonR2 then
			v = nil
			maid:Clean()
			part.Parent = nil
			hud.Enabled = true
			uiblur.Enabled = true
			uicc.Enabled = true
		end
	end)
end

return VisualizerController