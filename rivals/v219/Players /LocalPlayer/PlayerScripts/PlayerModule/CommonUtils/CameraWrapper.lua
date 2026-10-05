local ConnectionUtil = require(script.Parent.ConnectionUtil)
local CameraWrapper = {}
CameraWrapper.__index = CameraWrapper

function CameraWrapper.new()
	return (setmetatable({
		_camera = game.Workspace.CurrentCamera,
		_callbacks = {},
		_connectionUtil = ConnectionUtil.new(),
		_enabled = false
	}, CameraWrapper))
end

function CameraWrapper:_connectCallbacks()
	self._camera = game.Workspace.CurrentCamera

	if not self._camera then
		return
	end

	for propertyName, _callback in self._callbacks do
		self._connectionUtil:trackConnection(
			propertyName,
			self._camera:GetPropertyChangedSignal(propertyName):Connect(_callback)
		)
		_callback()
	end
end

function CameraWrapper:Enable()
	if self._enabled then
		return
	end

	self._enabled = true
	self._cameraChangedConnection = game.Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		self:_connectCallbacks()
	end)
	self:_connectCallbacks()
end

function CameraWrapper:Disable()
	if not self._enabled then
		return
	end

	self._enabled = false

	if self._cameraChangedConnection then
		self._cameraChangedConnection:Disconnect()
		self._cameraChangedConnection = nil
	end

	self._connectionUtil:disconnectAll()
end

function CameraWrapper:Connect(propertyName: string, callback)
	self._callbacks[propertyName] = callback

	if not self._camera then
		return
	end

	self._connectionUtil:trackConnection(
		propertyName,
		self._camera:GetPropertyChangedSignal(propertyName):Connect(callback)
	)
end

function CameraWrapper:Disconnect(p2: string)
	self._connectionUtil:disconnect(p2)
	self._callbacks[p2] = nil
end

function CameraWrapper:getCamera()
	return self._camera
end

return CameraWrapper