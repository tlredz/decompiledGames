local VRService = game:GetService("VRService")
local _SpeedChanged = script._SpeedChanged
local _CFrameChanged = script._CFrameChanged
local VRService2 = {}
local v = {
	Previous = CFrame.new(),
	Current = CFrame.new(),
	DeltaTime = 0.0001,
	_Updated = 0
}
VRService2._Changes = {
	LeftHand = table.clone(v),
	RightHand = table.clone(v),
	Head = table.clone(v)
}
VRService2.VREnabled = VRService.VREnabled
VRService2.SpeedChanged = _SpeedChanged.Event
VRService2.CFrameChanged = _CFrameChanged.Event
VRService2.VREnabledChanged = VRService:GetPropertyChangedSignal("VREnabled")
VRService2.VREnabledChanged:Connect(function()
	VRService2.VREnabled = VRService.VREnabled
end)

function VRService2:GetCFrameOf(p2)
	return self._Changes[p2].Current
end

function VRService2:GetCFrameRelativeToHeadOf(p2)
	local _Changes = self._Changes
	return _Changes.Head.Current * _Changes[p2].Current
end

function VRService2:GetSpeedOf(p2)
	local _Change = self._Changes[p2]
	return (_Change.Previous.Position - _Change.Current.Position).Magnitude / _Change.DeltaTime
end

function VRService2:GetDirectionOf(p2)
	local _Change = self._Changes[p2]
	return CFrame.lookAt(_Change.Previous.Position, _Change.Current.Position)
end

VRService.UserCFrameChanged:Connect(function(p, current)
	local name = p.Name
	local _Change = VRService2._Changes[name]

	if not _Change then
		warn((`No Service._Changes found for Tracker '{name}'`))
		return
	end

	local now = os.clock()
	local deltaTime = now - _Change._Updated
	_Change._Updated = now
	_Change.DeltaTime = deltaTime
	_Change.Previous = _Change.Current
	_Change.Current = current
	_CFrameChanged:Fire(name, current, deltaTime)
	_SpeedChanged:Fire(name, VRService2:GetSpeedOf(name))
end)
return VRService2