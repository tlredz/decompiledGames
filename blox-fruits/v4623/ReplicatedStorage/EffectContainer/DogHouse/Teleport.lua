local createVector = vector.create
game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Util = require(game.ReplicatedStorage.Util)
local FX = require(game.ReplicatedStorage.FX)
local teleport = FX:WaitForChild("DogHouse").Teleport

local function getGateCF(position: Vector3)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = { workspace.Map }
	local raycastResult = workspace:Raycast(position + createVector(0, 15, 0), createVector(0, -60, 0), raycastParams)

	if raycastResult then
		position = raycastResult.Position or position
	end

	local normal = raycastResult and raycastResult.Normal or createVector(0, 1, 0)
	return CFrame.new(position, position + normal) * CFrame.Angles(-1.5707963267948966, 0, 0)
end

return function(instance)
	local position = instance.Position

	if not position then
		if instance.CFrame then
			position = instance.CFrame.Position
		elseif instance.Root then
			position = instance.Root.Position
		end
	end

	if not position then
		return
	end

	local gateCF = getGateCF(position)
	local width = instance.Width or 10
	local Y = instance.Y or 0.2
	local growTime = instance.GrowTime or 0.5
	local partDelay = instance.PartDelay or 0.35
	local holdTime = instance.HoldTime or 1.15
	local shrinkTime = instance.ShrinkTime or 0.4
	local clone = teleport.spell:Clone()
	clone.Parent = workspace._WorldOrigin
	clone.CFrame = gateCF
	clone.Mesh.Scale = createVector(0, 1, 0)

	if clone:FindFirstChild("Attachment") and clone.Attachment:FindFirstChild("sfx2") then
		clone.Attachment.sfx2:Play()
	end

	Util.ReplicatedTween:Create(clone.Mesh, TweenInfo.new(growTime, Enum.EasingStyle.Quad), {
		Scale = Vector3.new(width, 1, width)
	}):Play()
	task.delay(partDelay, function()
		local clone2 = teleport.Part:Clone()
		clone2.Parent = workspace._WorldOrigin
		clone2.CFrame = gateCF
		clone2.Mesh.Scale = createVector(0, 0, 0)
		Util.ReplicatedTween:Create(clone2.Mesh, TweenInfo.new(growTime, Enum.EasingStyle.Quad), {
			Scale = Vector3.new(width - 0.5, Y, width - 0.5)
		}):Play()
		task.delay(holdTime, function()
			if clone and clone.Parent then
				Util.ReplicatedTween:Create(clone.Mesh, TweenInfo.new(shrinkTime, Enum.EasingStyle.Quad), {
					Scale = Vector3.new(0, Y, 0)
				}):Play()
				Debris:AddItem(clone, shrinkTime + 0.05)
			end

			if clone2 and clone2.Parent then
				Util.ReplicatedTween:Create(clone2.Mesh, TweenInfo.new(shrinkTime, Enum.EasingStyle.Quad), {
					Scale = Vector3.new(0, Y, 0)
				}):Play()
				Debris:AddItem(clone2, shrinkTime + 0.05)
			end
		end)
	end)
end