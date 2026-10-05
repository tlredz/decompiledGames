local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
require3(script.Parent._Types)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local v = require3(ReplicatedStorage2.Shared.ShockwaveEffect)
local v2 = require3(ReplicatedStorage2.Shared.PlaceGhost)

local function getMoveDirection(data)
	if not data.RootPart then
		return createVector(0, 0, 0)
	end

	local moveDirection = createVector(0, 0, 0)

	if data.MoveDirection.Magnitude == 0 then
		if data.WalkToPoint.Magnitude ~= 0 then
			moveDirection = data.WalkToPoint - data.RootPart.Position
		end
	else
		moveDirection = data.MoveDirection
	end

	return moveDirection * createVector(1, 0, 1)
end

local Waypoint = {}
Waypoint.iconId = "rbxassetid://14846350280"
Waypoint.cooldown = 3
Waypoint.cooldownReductionPerUpgrade = 0

function Waypoint.getCooldown(instance)
	if instance:FindFirstChild("Waypoint") then
		return 3
	end

	return 0
end

function Waypoint.serverActivationAsync(p, p2)
	p2.clearAllCleaners()
	local waypoint = p.character:FindFirstChild("Waypoint")

	if waypoint then
		local value = waypoint.Value
		p.character:PivotTo(p.character:GetPivot().Rotation + value.Position)
		v2(p.character, {
			color = Color3.fromRGB(81, 0, 255),
			lifetime = 1.5,
			animationDelay = 0.5
		})
		Debris:AddItem(value, 3)
		value.Rocks:Destroy()
		value.boo:Emit(20)
		value.boospecs:Emit(30)
		value.Sound1:Play()
		value.Transparency = 1
		value.Sound:Play()
		value.Attachment.Beam.Enabled = false

		for _, emitter in value:GetDescendants() do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		v({
			cframe = p.rootPart.CFrame,
			diameter = 35,
			color = Color3.fromRGB(81, 0, 255),
			orientation = "Vertical"
		})
		waypoint:Destroy()
	else
		local clone = script.Waypoint:Clone()
		clone.Parent = workspace.Runtime
		clone.CFrame = p.rootPart.CFrame * CFrame.new(0, 1, 0)
		clone.Orientation = createVector(90, 0, 0)
		clone.Sound:Play()
		clone.Sound1:Play()
		clone.Attachment.Beam.Attachment1 = p.rootPart:FindFirstChild("RootAttachment")
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { workspace.Alive, workspace.Dead, clone }
		local raycastResult = workspace:Raycast(p.rootPart.CFrame.Position, createVector(-0, -100, -0), raycastParams)

		if raycastResult then
			TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Position = raycastResult.Position + createVector(0, 2.5, 0)
			}):Play()
			v({
				cframe = p.rootPart.CFrame,
				diameter = 25,
				color = Color3.fromRGB(72, 0, 255),
				orientation = "Vertical"
			})
			local rocks = clone.Rocks
			rocks:MoveTo(raycastResult.Position)

			for _, part in rocks:GetChildren() do
				if not (part.Name == "Wedge" and part:IsA("BasePart")) then
					continue
				end

				local v3 = part
				task.spawn(function()
					v3.Color = raycastResult.Instance.Color
					v3.Material = raycastResult.Material
					local position = v3.Position
					v3.Position = rocks.PrimaryPart.Position
					local size = v3.Size
					v3.Size = createVector(0, 0, 0)
					TweenService:Create(v3, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
						Size = size * 1.2,
						Position = position
					}):Play()
					task.delay(0.25, function()
						TweenService:Create(v3, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
							Size = size
						}):Play()
					end)
				end)
			end
		end

		local objectValue = Instance.new("ObjectValue")
		objectValue.Name = "Waypoint"
		objectValue.Value = clone
		objectValue.Parent = p.character
		p2.addCleaner(function(_)
			clone:Destroy()
			objectValue:Destroy()
		end)
	end
end

return Waypoint