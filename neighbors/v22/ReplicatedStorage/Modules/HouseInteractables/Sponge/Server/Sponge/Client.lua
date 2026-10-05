game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Network = require(ReplicatedStorage.Modules.Network)
local House = require(ReplicatedStorage.Modules.Neighbors.House)
local Config = require(script.Parent:WaitForChild("Config"))
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local currentCamera = workspace.CurrentCamera
local mouse = localPlayer:GetMouse()
local parent = script.Parent
local assets = parent:WaitForChild("Assets")
local model = parent:WaitForChild("Model")
local highlight = assets.Highlight
local clone = ReplicatedStorage.Assets.Models.SpongeModel:Clone()
local currentHouse = House:GetCurrentHouse()
local events = script.Parent:WaitForChild("Events")
local attachment = Instance.new("Attachment")
local attachment2 = Instance.new("Attachment")
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { character }
local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include
overlapParams.FilterDescendantsInstances = { currentHouse.Model.Server.Stains }
local v = false
local thread = nil
local position = vector.create(0, 0, 0)
local v2 = 0
local now = -1e999

local function Activate()
	thread = coroutine.create(function()
		while task.wait(Config.UPDATE_RATE) do
			local _ = (mouse.Hit.Position - currentCamera.CFrame.Position).Unit
			local position2 = mouse.Hit.Position
			local v3 = -(humanoidRootPart.Position - position2).Unit
			local raycastResult = workspace:Raycast(humanoidRootPart.Position, v3 * Config.RANGE, raycastParams)
			local cframe

			if raycastResult then
				local _ = (raycastResult.Position - humanoidRootPart.Position).Unit
				cframe = CFrame.lookAt(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
					1.5707963267948966,
					0,
					0
				)
			else
				local position3 = mouse.Hit.Position
				local v4 = -(humanoidRootPart.Position - position3).Unit
				cframe = CFrame.lookAt(humanoidRootPart.Position + v4 * Config.RANGE, humanoidRootPart.Position)
			end

			TweenService:Create(clone.PrimaryPart, TweenInfo.new(Config.UPDATE_RATE), {
				CFrame = cframe
			}):Play()
			v2 = (position - cframe.Position).Magnitude / Config.UPDATE_RATE
			position = cframe.Position

			if not (v2 > Config.MIN_SPEED and now + Config.CLEAN_COOLDOWN < tick()) then
				continue
			end

			local partBoundsInRadius = workspace:GetPartBoundsInRadius(
				cframe.Position,
				Config.DETECTION_RADIUS,
				overlapParams
			)

			if not partBoundsInRadius[1] then
				continue
			end

			now = tick()
			Network:fire("CleanHouseStain", partBoundsInRadius[1])
		end
	end)
	coroutine.resume(thread)
	clone.Parent = workspace
	attachment.Parent = clone.PrimaryPart
	attachment2.Parent = humanoidRootPart
	highlight.Adornee = clone
	highlight.Enabled = true
	model.Sponge0.Transparency = 1
	model.Sponge1.Transparency = 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Deactivate()
	if thread then
		coroutine.close(thread)
	end

	clone.Parent = nil
	attachment.Parent = nil
	attachment2.Parent = nil
	highlight.Enabled = false

	if model.Parent then
		model.Sponge0.Transparency = 0
		model.Sponge1.Transparency = 0
	end
end

assets.Beam.Attachment0 = attachment
assets.Beam.Attachment1 = attachment2
parent.Equipped:Connect(function()
	Activate()
	v = true
end)
parent.Unequipped:Connect(function()
	Deactivate() -- equivalent call inferred; original call site unknown
	v = false
end)
parent.Destroying:Connect(function()
	Deactivate() -- equivalent call inferred; original call site unknown
end)
currentHouse.LeftHouse:Once(function()
	if not script.Parent then
		return
	end

	Deactivate() -- equivalent call inferred; original call site unknown
	events.RemoveTool:FireServer()
end)