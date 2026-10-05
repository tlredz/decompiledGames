local createVector = vector.create
local RunService = game:GetService("RunService")
local module = require("../mod/utility")
return {
	emit = function(instance, list)
		if not instance:GetAttribute("Enabled") then
			return
		end

		local attribute = module.getAttribute(instance, "PartScale", createVector(1, 1, 1))
		local attribute2 = module.getAttribute(instance, "PartDistance", 1.5)
		local attribute3 = module.getAttribute(instance, "OffsetPosition", createVector(0, 0, 0))
		local v = module.getAttribute(instance, "OffsetRotation", createVector(0, 0, 0)) * module.DEG_TO_RAD
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
			local v2 = math.tan((math.rad(currentCamera.FieldOfView / 2))) * attribute2 * 2
			local v3 = currentCamera.ViewportSize.X / currentCamera.ViewportSize.Y * v2
			local v4 = currentCamera.CFrame * CFrame.new(0, 0, -attribute2)
			instance.Size = Vector3.new(v3, v2, instance.Size.Z) * attribute
			instance.CFrame = v4 * CFrame.new(attribute3) * CFrame.fromOrientation(v.x, v.y, v.z)
		end

		if not RunService:IsRunning() then
			table.insert(list, RunService.RenderStepped:Connect(frame))
			return
		end

		local ranomId = module.getRanomId()
		RunService:BindToRenderStep(ranomId, module.RENDER_PRIORITY + list.depth, frame)
		table.insert(list, function()
			RunService:UnbindFromRenderStep(ranomId)
		end)
	end
}