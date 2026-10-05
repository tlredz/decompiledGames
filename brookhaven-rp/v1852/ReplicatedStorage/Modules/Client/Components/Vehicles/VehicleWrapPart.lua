local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Timer = require(ReplicatedStorage.Packages.Timer)
local WrapsConfig = require(ReplicatedStorage.Modules.Shared.DB.Vehicles.WrapsConfig)
local v = {
	Enum.NormalId.Top,
	Enum.NormalId.Bottom,
	Enum.NormalId.Left,
	Enum.NormalId.Right,
	Enum.NormalId.Front,
	Enum.NormalId.Back
}
local v2 = Component.new({
	Tag = "VehicleWrapPart"
})

function v2:Construct()
	self._Janitor = Janitor.new()
	self._decals = {}
	self._nearestColor = nil
	self._previousColor = nil
end

function v2:Start()
	self:CreateDecals()
	self._Janitor:Add(Timer.simple(0.2, function()
		self:RunRenderCheck()
	end))
	self._Janitor:Add(self.Instance:GetAttributeChangedSignal("Wrap"):Connect(function()
		self:CreateDecals()
	end))
	self._Janitor:Add(self.Instance:GetPropertyChangedSignal("Transparency"):Connect(function()
		self:SetTransparency()
	end))
end

function v2:CreateDecals()
	local wrap = self.Instance:GetAttribute("Wrap")
	local v3 = WrapsConfig.GetConfig()[wrap]

	if not v3 then
		return
	end

	if wrap == "Default" or not v3 then
		self:Reset()
		return
	end

	for _, face in v do
		local v5 = self.Instance:FindFirstChild((`Wrap{face.Name}Decal`)) or self._Janitor:Add(Instance.new("Decal"))
		v5.Name = `Wrap{face.Name}Decal`
		v5.Face = face
		v5.Texture = `rbxassetid://{v3.DecalId}`
		v5.Parent = self.Instance
		self._decals[face] = v5
	end

	self._nearestColor = v3.Color
	self:SetTransparency()
end

function v2:Reset()
	self._decals = {}

	for _, v3 in v do
		local child = self.Instance:FindFirstChild((`Wrap{v3.Name}Decal`))

		if child then
			child:Destroy()
		end
	end

	self:ResetColor()
	self._nearestColor = nil
	self._previousColor = nil
end

function v2:ResetColor()
	local activeColor = self.Instance:GetAttribute("ActiveColor") or self._previousColor or self.Instance.Color
	self.Instance.Color = activeColor
end

function v2:RunRenderCheck()
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	if (currentCamera.CFrame.Position - self.Instance:GetPivot().Position).Magnitude > 500 then
		self:HideWrap()
	else
		self:ShowWrap()
	end
end

function v2:ShowWrap()
	for _, _decal in self._decals do
		_decal.Parent = self.Instance
	end

	self:SetTransparency()
	self:ResetColor()
end

function v2:HideWrap()
	for _, _decal in self._decals do
		_decal.Parent = nil
	end

	if not self._previousColor then
		self._previousColor = self.Instance.Color
	end

	if self._nearestColor then
		self.Instance.Color = self._nearestColor
	end
end

function v2:SetTransparency()
	for _, _decal in self._decals do
		_decal.Transparency = self.Instance.Transparency
	end
end

function v2:Stop()
	self._Janitor:Destroy()
end

return v2