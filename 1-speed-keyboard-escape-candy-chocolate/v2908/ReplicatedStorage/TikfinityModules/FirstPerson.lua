local count = 0
local v = false
local classic = Enum.CameraMode.Classic
local cameraMinZoomDistance = 0.5
local cameraMaxZoomDistance = 128
return {
	Run = function(state)
		count += 1
		local v2 = count

		if not v then
			v = true
			classic = state.CameraMode
			cameraMinZoomDistance = state.CameraMinZoomDistance
			cameraMaxZoomDistance = state.CameraMaxZoomDistance
		end

		state.CameraMode = Enum.CameraMode.LockFirstPerson
		task.delay(5, function()
			if count ~= v2 then
				return
			end

			if state.Parent then
				state.CameraMode = classic
				state.CameraMinZoomDistance = cameraMinZoomDistance
				state.CameraMaxZoomDistance = cameraMaxZoomDistance
			end

			v = false
		end)
	end
}