local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local UserGameSettings = UserSettings():GetService("UserGameSettings")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Packages.Signal)
local v3 = require3(ReplicatedStorage2.Packages.Net)
local v4 = require3(ReplicatedStorage2.Shared.FastUtils)
require3(ReplicatedStorage2.Common.Utils)
local v5 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.Explosions)
local v6 = require3(script.Explosions)
require3(script.Types)
local damageEffect = ReplicatedStorage2.Assets.DamageEffect
local remoteEvent = v3:RemoteEvent("VFXExplode")
local VFXController = {
	EmissionMultiplier = 1,
	OnEmissionMultiplierUpdate = v2.new()
}
local v7 = true
local v8 = false
local numberSequence = NumberSequence.new(1)

local function suppressExplosionSFX(folder)
	for _, sound in folder:GetDescendants() do
		if not sound:IsA("Sound") then
			continue
		end

		sound.SoundId = ""
		sound.Volume = 0
	end
end

local function suppressExplosionVFX(folder)
	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("ParticleEmitter") then
			descendant:SetAttribute("_particleWasEnabled", nil)
			descendant.Enabled = false
			descendant.Lifetime = NumberRange.new(0)
		elseif descendant:IsA("Trail") then
			descendant.Enabled = false
			descendant.Lifetime = 0
		elseif descendant:IsA("Beam") then
			descendant:SetAttribute("_particleWasEnabled", nil)
			descendant.Enabled = false
			descendant.Width0 = 0
			descendant.Width1 = 0
			descendant.Transparency = numberSequence
		elseif descendant:IsA("Light") then
			descendant.Enabled = false
			descendant.Brightness = 0
			descendant.Range = 0
		end
	end
end

function VFXController.DamageVFX(_, instance, p: number, value: number?, value2: number?)
	if not (instance and (instance:IsA("PVInstance") or instance:IsA("Attachment"))) then
		return
	end

	local v9 = value or 35
	local clone = damageEffect:Clone()
	local canvasGroup = clone.BillboardGui.CanvasGroup
	canvasGroup.TextLabel.Text = `-{math.round(p)}`
	local worldCFrame

	if instance:IsA("Attachment") then
		worldCFrame = instance.WorldCFrame
	else
		worldCFrame = instance:GetPivot()
	end

	clone.BillboardGui.AlwaysOnTop = true
	clone:PivotTo(worldCFrame)
	clone.Parent = workspace.Runtime
	local vector2 = Vector3.new((math.random() - 0.5) * v9, value2 or 24, (math.random() - 0.5) * v9)
	canvasGroup.Size = UDim2.fromScale(0, 0)
	canvasGroup.Rotation = math.random(25, 45) * (math.random(0, 1) * 2 - 1)
	v4.fastTween(canvasGroup, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.fromScale(1, 1)
	})
	v4.fastTween(canvasGroup, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0.15), {
		Rotation = 0
	})
	v4.fastTween(canvasGroup, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 0.85), {
		GroupTransparency = 1
	})
	local lastTime = os.clock()
	local postSimulationConnection = nil
	postSimulationConnection = RunService.PostSimulation:Connect(function()
		local v11 = (os.clock() - lastTime) / 1

		if not (v11 > 1) then
			clone.CFrame = CFrame.new(worldCFrame.Position + vector2 * v11 + createVector(0, -24, 0) * v11 ^ 2)
		elseif postSimulationConnection and postSimulationConnection.Connected then
			postSimulationConnection:Disconnect()
			clone:Destroy()
		end
	end)
end

function VFXController:PlayExplosionFromInstance(pVInstance, position: Vector3?, instance, instance2, attributionCharacter, kill: number?)
	local v9 = string.split(pVInstance.Name, " ")
	local v10 = v6.Specific[pVInstance.Name] or v6[v9[1]]

	if not v10 then
		return warn("Failed to locate explosion callback for", pVInstance)
	end

	local humanoidRootPart

	if instance2 then
		humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")
	end

	if not position then
		if instance2 then
			position = humanoidRootPart and humanoidRootPart.Position or instance2:GetPivot().Position
		else
			position = nil
		end

		if not position then
			if instance then
				position = instance:GetPivot().Position
			else
				position = nil
			end

			if not position then
				local v11

				if pVInstance:IsA("PVInstance") then
					v11 = pVInstance:GetPivot().Position
				end

				position = v11 or createVector(0, 0, 0)
			end
		end
	end

	if v7 then
		for _, effect in pVInstance:GetDescendants() do
			if not ((effect:IsA("ParticleEmitter") or effect:IsA("Beam")) and effect:GetAttribute("_particleWasEnabled")) then
				continue
			end

			effect.Enabled = true
		end
	end

	local pVInstance2

	if pVInstance:IsA("PVInstance") then
		pVInstance2 = pVInstance
	else
		pVInstance2 = pVInstance:FindFirstChildWhichIsA("PVInstance", true)
	end

	if pVInstance2 then
		pVInstance2:PivotTo(CFrame.new(position) * pVInstance2:GetPivot().Rotation)
	end

	xpcall(v10, warn, {
		Name = pVInstance.Name,
		Ball = instance,
		Variant = v9[2],
		Instance = pVInstance,
		ExplodePosition = position,
		EmissionMultiplier = self.EmissionMultiplier,
		Character = instance2,
		AttributionCharacter = attributionCharacter,
		Kill = kill
	})
end

function VFXController:UpdateEmissionMultiplier()
	local value = UserGameSettings.SavedQualityLevel.Value
	local emissionMultiplier

	if not v7 then
		emissionMultiplier = 0
	elseif value > 8 then
		emissionMultiplier = 1
	elseif value > 5 then
		emissionMultiplier = 0.75
	elseif value > 3 then
		emissionMultiplier = 0.5
	else
		emissionMultiplier = 0.25
	end

	self.EmissionMultiplier = emissionMultiplier
	self.OnEmissionMultiplierUpdate:Fire(emissionMultiplier)
end

function VFXController:PlayExplosion(name: string, vector2: Vector3?, p, p2, p3, p4: number?)
	local v9 = string.split(name, " ")
	local instance = v5:GetInstance(name) or v9[2] and v5:GetInstance((`{v9[1]} {v9[2]}`)) or v5:GetInstance(v9[1])

	if not instance then
		warn("Explosion not found for", name)
		return
	end

	local v10 = instance:FindFirstChild(name) or v9[2] and instance:FindFirstChild(v9[2])
	local clone

	if v10 then
		clone = v10:Clone()
	else
		clone = instance:Clone()
	end

	clone.Name = name
	clone:AddTag("ExplosionVFX")

	if not v7 then
		suppressExplosionVFX(clone)
	end

	if v8 then
		suppressExplosionSFX(clone)
	end

	clone.Parent = workspace.Runtime
	Debris:AddItem(clone, 25)
	VFXController:PlayExplosionFromInstance(clone, vector2, p, p2, p3, p4)
	return clone
end

function VFXController:Start()
	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateEmissionMultiplier()
		self:UpdateEmissionMultiplier()
	end

	task.spawn(updateEmissionMultiplier)
	UserGameSettings.Changed:Connect(updateEmissionMultiplier)
	remoteEvent.OnClientEvent:Connect(function(...)
		self:PlayExplosion(...)
	end)
	v.Client:AwaitReplion("Data", function(object2)
		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateExplosionVFX(p)
			v7 = p ~= false
			updateEmissionMultiplier() -- equivalent call inferred; original call site unknown
		end

		object2:OnChange({
			"Settings",
			"Misc",
			"Explosion VFX",
			"Enabled"
		}, updateExplosionVFX)
		updateExplosionVFX(object2:Get({
			"Settings",
			"Misc",
			"Explosion VFX",
			"Enabled"
		})) -- equivalent call inferred; original call site unknown

		local function updateExplosionSFX(p)
			v8 = p == true
		end

		object2:OnChange({
			"Settings",
			"Misc",
			"Remove Explosions SFX",
			"Enabled"
		}, updateExplosionSFX)
		v8 = object2:Get({
			"Settings",
			"Misc",
			"Remove Explosions SFX",
			"Enabled"
		}) == true
	end)
end

return VFXController