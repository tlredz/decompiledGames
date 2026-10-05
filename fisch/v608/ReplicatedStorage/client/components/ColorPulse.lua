local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages:WaitForChild("Component"))
local Trove = require(packages:WaitForChild("Trove"))
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local localPlayer = Players.LocalPlayer
local v = Component.new({
	Tag = "ColorPulse"
})

function v:Construct()
	self.active = false
	self.far = false
	self.last_distance_check = 0
	self.last_update = 0
	self.trove = Trove.new()

	if self.Instance and self.Instance:IsDescendantOf(game) then
		self.trove:AttachToInstance(self.Instance)
	end

	self.property_sets = {}
	self.time = self.Instance:GetAttribute("PulseTime") or 1
	local v2 = 1

	while self.Instance:GetAttribute((`PulseColor{v2}`)) or self.Instance:GetAttribute((`PulseTrans{v2}`)) do
		local attribute = self.Instance:GetAttribute((`PulseColor{v2}`))
		local attribute2 = self.Instance:GetAttribute((`PulseTrans{v2}`))
		local v3 = {}

		if attribute then
			v3.Color = attribute
		end

		if attribute2 then
			v3.Transparency = attribute2
		end

		table.insert(self.property_sets, v3)
		v2 += 1
	end
end

function v:SetActive(active)
	self.active = active
end

function v:UpdateActive()
	if SettingsController:GetSettingValue("shownVfx") == "HideAll" or self.Instance.Transparency >= 1 or self.Instance.LocalTransparencyModifier >= 1 or not self.Instance:IsDescendantOf(workspace) then
		self:SetActive(false)
		return
	end

	if SettingsController:GetSettingValue("shownVfx") == "LocalOnly" and not (self.Instance:IsDescendantOf(localPlayer.Character or localPlayer) or self.Instance:FindFirstAncestor(localPlayer.Name)) then
		self:SetActive(false)
		return
	end

	local model = self.Instance:FindFirstAncestorWhichIsA("Model")

	while model and model ~= workspace do
		if model:IsA("Tool") then
			self:SetActive(true)
			return
		end

		if model:FindFirstChildWhichIsA("Humanoid") then
			self:SetActive(false)
			return
		else
			model = model:FindFirstAncestorWhichIsA("Model")
		end
	end

	self:SetActive(true)
end

local now = 0
local now2 = 0

function v:Update()
	local now3 = tick()

	if self.last_distance_check + 5 < now3 then
		self.far = (workspace.CurrentCamera.CFrame.Position - self.Instance.Position).Magnitude > 128
		self.last_distance_check = now3
	end

	local v2 = now3 / self.time % #self.property_sets
	local property_set = self.property_sets[v2 < 1 and #self.property_sets or math.floor(v2)]

	for k, v3 in self.property_sets[v2 == 0 and 1 or math.ceil(v2)] do
		local v4 = property_set[k] or v3

		if typeof(v3) == "Color3" then
			self.Instance[k] = v4:Lerp(v3, v2 % 1)
		elseif typeof(v3) == "number" then
			self.Instance[k] = v4 + (v3 - v4) * (v2 % 1)
		end
	end
end

function v:Start()
	self.last_distance_check = 0
	self.trove:Add(self.Instance.AncestryChanged:Connect(function()
		debug.profilebegin("ColorPulse::UpdateActive")
		self:UpdateActive()
		debug.profileend()
	end))
	self:UpdateActive()
	self:Update()
end

function v:Stop()
	if self.trove then
		self.trove:Clean()
		self.trove = nil
	end

	if self.property_sets then
		table.clear(self.property_sets)
	end
end

RunService.PreRender:Connect(function()
	debug.profilebegin("ColorPulse::Update")
	local now3 = tick()
	local v2 = now + 0.5 < now3
	local now4 = tick()
	local v3 = now2 + 0.08333333333333333 < now4

	for _, v4 in v:GetAll() do
		if not v4.active then
			continue
		end

		local v5

		if v4.far then
			v5 = v2
		else
			v5 = v3
		end

		if v5 then
			v4:Update()
		end
	end

	if v2 then
		now = tick()
	end

	if v3 then
		now2 = tick()
	end

	debug.profileend()
end)
SettingsController:GetSettingChangedSignal("shownVfx"):Connect(function()
	debug.profilebegin("ColorPulse::UpdateActive")

	for _, v2 in v:GetAll() do
		v2:UpdateActive()
	end

	debug.profileend()
end)
SettingsController:GetSettingChangedSignal("showHeldFish"):Connect(function()
	task.wait()
	debug.profilebegin("ColorPulse::UpdateActive")

	for _, v2 in v:GetAll() do
		v2:UpdateActive()
	end

	debug.profileend()
end)
return v