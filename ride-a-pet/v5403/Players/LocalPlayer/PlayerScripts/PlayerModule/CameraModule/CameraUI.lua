local StarterGui = game:GetService("StarterGui")
local v = false
local CameraUI = {}

function CameraUI.setCameraModeToastEnabled(flag: boolean)
	if not (flag or v) then
		return
	end

	if not v then
		v = true
	end

	if not flag then
		CameraUI.setCameraModeToastOpen(false)
	end
end

function CameraUI.setCameraModeToastOpen(flag: boolean)
	assert(v)

	if flag then
		StarterGui:SetCore("SendNotification", {
			Title = "Camera Control Enabled",
			Text = "Right click to toggle",
			Duration = 3
		})
	end
end

return CameraUI