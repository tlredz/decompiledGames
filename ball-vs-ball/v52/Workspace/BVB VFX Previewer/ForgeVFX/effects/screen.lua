local createVector = vector.create
local RunService = game:GetService("RunService")
local module = require("../mod/attributes")
require("../types")
local module2 = require("../mod/utility")
return {
	emit = function(instance, list)
		if not instance:GetAttribute("Enabled") then
			return
		end

		local partScale = module.get(instance, "PartScale", createVector(1, 1, 1))
		local partDistance = module.get(instance, "PartDistance", 1.5)
		local offsetPosition = module.get(instance, "OffsetPosition", createVector(0, 0, 0))
		local v = module.get(instance, "OffsetRotation", createVector(0, 0, 0)) * module2.DEG_TO_RAD
		local cFrame = instance.CFrame
		local size = instance.Size
		local collisionGroup = instance.CollisionGroup
		instance.CollisionGroup = "ForgeMouseIgnore"
		table.insert(list, function()
			instance.Size = size
			instance.CFrame = cFrame
			instance.CollisionGroup = collisionGroup == "" and "Default" or collisionGroup or "Default"
		end)

		local function frame()
			local currentCamera = workspace.CurrentCamera
			local v2 = math.tan((math.rad(currentCamera.FieldOfView / 2))) * partDistance * 2
			local v3 = currentCamera.ViewportSize.X / currentCamera.ViewportSize.Y * v2
			local v4 = currentCamera.CFrame * CFrame.new(0, 0, -partDistance)
			instance.Size = Vector3.new(v3, v2, instance.Size.Z) * partScale
			instance.CFrame = v4 * CFrame.new(offsetPosition) * CFrame.fromOrientation(v.x, v.y, v.z)
		end

		if RunService:IsRunning() then
			local randomId = module2.getRandomId()
			RunService:BindToRenderStep(randomId, Enum.RenderPriority.Last.Value + 2 + list.depth, frame)
			table.insert(list, function()
				RunService:UnbindFromRenderStep(randomId)
			end)
		else
			table.insert(list, RunService.RenderStepped:Connect(frame))
		end

		return true
	end
}