local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "RotatingAlarmLight"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._rotationJanitor = self._Janitor:Add(Janitor.new())
	self._spinAngle = 0
end

function v:_setLightsEnabled(enabled: boolean)
	for _, light in self._main:GetChildren() do
		if light:IsA("SpotLight") then
			light.Enabled = enabled
		elseif light.Name == "Beam" then
			light.Transparency = enabled and 0.75 or 1
		end
	end

	local _main = self._main
	local material

	if enabled then
		material = Enum.Material.Neon
	else
		material = self._originalMainMaterial
	end

	_main.Material = material
	local _cover = self._cover
	local material2

	if enabled then
		material2 = Enum.Material.Neon
	else
		material2 = self._originalCoverMaterial
	end

	_cover.Material = material2
end

function v:_startSpinning()
	self._rotationJanitor:Cleanup()
	self._rotationJanitor:Add(RunService.Heartbeat:Connect(function(dt: number)
		local v2 = math.rad(dt * 270)
		self._spinAngle = (self._spinAngle + v2) % 6.283185307179586
		self._main.CFrame = self._main.CFrame * CFrame.Angles(0, v2, 0)
	end))
end

function v:_stopSpinning()
	self._rotationJanitor:Cleanup()
	self._main.CFrame = self._main.CFrame * CFrame.Angles(0, -self._spinAngle, 0)
	self._spinAngle = 0
end

function v:SetEnabled(flag: boolean)
	self:_setLightsEnabled(flag)

	if flag then
		self:_startSpinning()
	else
		self:_stopSpinning()
	end
end

function v:Start()
	self._main = self.Instance:WaitForChild("Main", 10)
	assert(self._main, "Main part not found")
	self._originalMainMaterial = self._main.Material
	self._cover = self.Instance:WaitForChild("Cover", 10)
	assert(self._cover, "Cover not found")
	self._originalCoverMaterial = self._cover.Material
	self:SetEnabled(self.Instance:GetAttribute("Enabled"))
	self._Janitor:Add(self.Instance:GetAttributeChangedSignal("Enabled"):Connect(function()
		self:SetEnabled(self.Instance:GetAttribute("Enabled"))
	end))
end

function v:Stop()
	self._rotationJanitor:Destroy()
	self._Janitor:Destroy()
end

return v