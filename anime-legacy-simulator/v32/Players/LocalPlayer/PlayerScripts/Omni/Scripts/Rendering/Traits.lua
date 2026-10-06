local module = require("@game/ReplicatedStorage/Omni")
local traits = module.Assets:WaitForChild("Effects"):WaitForChild("Traits")
local cache = workspace:WaitForChild("Cache")
local v = {}
local folder = nil
local heartbeatConnection = nil
local v2 = 0
local Traits = {}

local function IsLowMode()
	return not (module.Data and module.Data.Settings) or module.Data.Settings["Low Mode"] == true
end

local function IsVisible(data)
	if data.Destroyed or not (data.Model:IsDescendantOf(workspace) and data.HRP.Parent) then
		return false
	end

	local currentCamera = workspace.CurrentCamera
	return currentCamera ~= nil and (currentCamera.CFrame.Position - data.HRP.Position).Magnitude <= 120
end

local function GetScale(p)
	return (math.max(0.01, p.Model:GetScale() / (p.BaseScale or 1)))
end

local function GetRoot()
	if not (folder and folder.Parent) then
		folder = Instance.new("Folder")
		folder.Name = "Traits"
		folder.Parent = cache
	end

	return folder
end

local function ScaleSequence(size, scale: number)
	local numberSequenceKeypoints = {}

	for _, keypoint in size.Keypoints do
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * scale, keypoint.Envelope * scale)
		)
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

local function SetScale(state, scale: number)
	if state.Scale == scale then
		return
	end

	state.Scale = scale

	for _, property in state.Properties do
		local node = property.Node

		if node:IsA("BasePart") then
			node.Size = property.Size * scale
		elseif node:IsA("Attachment") then
			node.Position = property.Position * scale
		elseif node:IsA("ParticleEmitter") then
			node.Size = ScaleSequence(property.Size, scale)
			node.Speed = NumberRange.new(property.Speed.Min * scale, property.Speed.Max * scale)
			node.Acceleration = property.Acceleration * scale
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SetEnabled(state, enabled: boolean)
	if state.Enabled == enabled then
		return
	end

	state.Enabled = enabled

	for k, emitter in state.Emitters do
		k.Enabled = enabled and emitter
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RemoveEffect(p)
	local effect = p.Effect

	if not effect then
		return
	end

	p.Effect = nil
	effect.Holder:Destroy()
end

local function CreateEffect(state)
	local fighter = state.Fighter
	local trait = fighter.Instance:GetAttribute("Trait")
	local part

	if typeof(trait) == "string" then
		part = traits:FindFirstChild(trait)
	else
		part = false
	end

	if not (part and part:IsA("BasePart")) then
		return
	end

	local clone = part:Clone()
	local descendants = clone:GetDescendants()
	table.insert(descendants, clone)
	local effect = {
		Name = trait,
		Holder = clone,
		Properties = {},
		Emitters = {},
		Enabled = true
	}

	for _, instance in descendants do
		local v4 = {
			Node = instance
		}

		if instance:IsA("BasePart") then
			v4.Size = instance.Size
			instance.Anchored = false
			instance.Massless = true
			instance.CanCollide = false
			instance.CanTouch = false
			instance.CanQuery = false
			instance.CastShadow = false
		elseif instance:IsA("Attachment") then
			v4.Position = instance.Position
		else
			if not instance:IsA("ParticleEmitter") then
				continue
			end

			v4.Size = instance.Size
			v4.Speed = instance.Speed
			v4.Acceleration = instance.Acceleration
			effect.Emitters[instance] = instance.Enabled
		end

		table.insert(effect.Properties, v4)
	end

	SetScale(effect, math.max(0.01, fighter.Model:GetScale() / (fighter.BaseScale or 1)))
	SetEnabled(effect, false) -- equivalent call inferred; original call site unknown
	clone.CFrame = fighter.HRP.CFrame
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = fighter.HRP
	weldConstraint.Part1 = clone
	weldConstraint.Parent = clone

	if not (folder and folder.Parent) then
		folder = Instance.new("Folder")
		folder.Name = "Traits"
		folder.Parent = cache
	end

	clone.Parent = folder
	state.Effect = effect
end

local function RefreshRecord(state)
	local fighter = state.Fighter
	local trait = fighter.Instance:GetAttribute("Trait")
	local effect = state.Effect and state.Effect.Name ~= trait and state.Effect

	if effect then
		state.Effect = nil
		effect.Holder:Destroy()
	end

	if not state.Effect then
		CreateEffect(state)
	end

	local effect2 = state.Effect

	if not effect2 then
		return
	end

	local v3 = module.Data and module.Data.Settings and module.Data.Settings["Low Mode"] ~= true and true or false

	if v3 then
		if fighter.Destroyed or not (fighter.Model:IsDescendantOf(workspace) and fighter.HRP.Parent) then
			v3 = false
		else
			local currentCamera = workspace.CurrentCamera

			if currentCamera == nil then
				v3 = false
			else
				v3 = (currentCamera.CFrame.Position - fighter.HRP.Position).Magnitude <= 120
			end
		end
	end

	if v3 then
		SetScale(effect2, math.max(0.01, fighter.Model:GetScale() / (fighter.BaseScale or 1)))
	end

	SetEnabled(effect2, v3) -- equivalent call inferred; original call site unknown
end

local function Step()
	local now = os.clock()

	if now - v2 < 0.25 then
		return
	end

	v2 = now

	for _, v3 in v do
		RefreshRecord(v3)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Start()
	if heartbeatConnection then
		return
	end

	heartbeatConnection = module.Services.RunService.Heartbeat:Connect(Step)
end

function Traits.Attach(fighter)
	local v3 = v[fighter.ID]

	if v3 then
		Traits.Detach(v3.Fighter)
	end

	local v4 = {
		Fighter = fighter
	}
	v[fighter.ID] = v4
	v4.Connection = fighter.Instance.AttributeChanged:Connect(function(p2)
		if p2 == "Trait" or p2 == "FighterSize" then
			RefreshRecord(v4)
		end
	end)
	RefreshRecord(v4)
	Start() -- equivalent call inferred; original call site unknown
end

function Traits.Detach(p)
	local v3 = v[p.ID]

	if not v3 or v3.Fighter ~= p then
		return
	end

	v3.Connection:Disconnect()
	RemoveEffect(v3) -- equivalent call inferred; original call site unknown
	v[p.ID] = nil
end

function Traits.Refresh()
	for _, v3 in v do
		RefreshRecord(v3)
	end
end

function Traits.Destroy()
	for _, v3 in v do
		v3.Connection:Disconnect()
		RemoveEffect(v3) -- equivalent call inferred; original call site unknown
	end

	table.clear(v)

	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	if folder then
		folder:Destroy()
		folder = nil
	end
end

module:OnDataChanged({ "Settings", "Low Mode" }, Traits.Refresh)
script.Destroying:Connect(Traits.Destroy)
return Traits