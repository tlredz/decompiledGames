local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local v = Component.new({
	Tag = "HideWhenBehind"
})

function v:Construct()
	self._lastUpdate = 0
	self._waitTime = 0
end

function v:RenderSteppedUpdate()
	local now = os.clock()

	if now - self._lastUpdate < self._waitTime then
		return
	end

	local currentCamera = workspace.CurrentCamera
	local pivot = self.Instance:GetPivot()
	local objectSpace = pivot:ToObjectSpace(currentCamera.CFrame)

	if (pivot.Position - currentCamera.CFrame.Position).Magnitude > 30 then
		self._waitTime = 0.2
	else
		self._waitTime = 0
	end

	self._lastUpdate = now
	self.Instance.Transparency = objectSpace.Z < 0 and 0 or 1
end

return v