local RunService = game:GetService("RunService")
local v = nil
local cFrame = nil
local cFrame2 = nil
local v2 = false

local function reset()
	if v and cFrame and v.CFrame == cFrame2 then
		v.CFrame = cFrame
	end

	v = nil
	cFrame = nil
	cFrame2 = nil
end

return {
	apply = function(cframe: CFrame)
		if not v2 then
			RunService:BindToRenderStep("CameraShakeOffsetReset", Enum.RenderPriority.Camera.Value - 1, reset)
			v2 = true
		end

		local currentCamera = workspace.CurrentCamera

		if not currentCamera then
			return
		end

		if v ~= currentCamera or currentCamera.CFrame ~= cFrame2 then
			v = currentCamera
			cFrame = currentCamera.CFrame
		end

		currentCamera.CFrame *= cframe
		cFrame2 = currentCamera.CFrame
	end
}