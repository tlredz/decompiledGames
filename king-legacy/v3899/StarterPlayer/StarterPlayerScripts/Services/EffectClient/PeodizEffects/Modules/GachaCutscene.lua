local currentCamera = workspace.CurrentCamera
return function(_)
	currentCamera.CameraType = Enum.CameraType.Scriptable
end