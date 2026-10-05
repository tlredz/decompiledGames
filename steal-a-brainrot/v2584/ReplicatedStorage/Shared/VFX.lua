local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Timer = require(ReplicatedStorage.Packages.Timer)
local SharedEventUtils = require(ReplicatedStorage.Shared.SharedEventUtils)
local VFX = {
	Library = script.Library,
	copy = function(attachment, cframe, terrain)
		if terrain == nil then
			if attachment:IsA("Attachment") then
				terrain = workspace.Terrain
			else
				terrain = workspace.CurrentCamera
			end
		end

		local clone = attachment:Clone()

		if clone:IsA("Attachment") then
			if typeof(cframe) ~= "CFrame" then
				cframe = CFrame.new(cframe)
			end

			clone.WorldCFrame = cframe
		elseif clone:IsA("PVInstance") then
			if typeof(cframe) ~= "CFrame" then
				cframe = CFrame.new(cframe)
			end

			clone:PivotTo(cframe)
		else
			clone:Destroy()
			error("Can't move Container")
		end

		clone.Parent = terrain
		return clone
	end,
	weld = function(p, part)
		local weld = Instance.new("Weld")
		weld.Part0 = p
		weld.Part1 = part
		weld.Parent = p
		return weld
	end,
	weldPosition = function(instance, instance2)
		instance.Anchored = true
		local postSimulationConnection = RunService.PostSimulation:Connect(function()
			debug.profilebegin("VFX:weldPosition:pushCFrame")
			SharedEventUtils.pushPartCFrame(instance, CFrame.new(instance2:GetPivot().Position))
			debug.profileend()
		end)
		local destroyingConnection = instance.Destroying:Once(function()
			postSimulationConnection:Disconnect()
		end)
		return function()
			postSimulationConnection:Disconnect()
			destroyingConnection:Disconnect()
		end
	end,
	rescale = function(p, p2: number)
		local parent = p.Parent
		local model = Instance.new("Model")
		p.Parent = model
		model:ScaleTo(p2)
		p.Parent = parent
	end,
	enable = function(folder, flag: boolean?)
		for _, descendant in folder:GetDescendants() do
			if descendant:GetAttribute("IgnoreVFXToggle") then
				continue
			end

			if descendant:IsA("ParticleEmitter") then
				descendant.Enabled = true
			elseif descendant:IsA("Beam") then
				descendant.Enabled = true
			elseif flag and descendant:IsA("Light") then
				descendant.Enabled = true
			end
		end
	end,
	disable = function(folder, flag: boolean?)
		for _, descendant in folder:GetDescendants() do
			if descendant:GetAttribute("IgnoreVFXToggle") then
				continue
			end

			if descendant:IsA("ParticleEmitter") then
				descendant.Enabled = false
			elseif descendant:IsA("Beam") then
				descendant.Enabled = false
			elseif flag and descendant:IsA("Light") then
				descendant.Enabled = false
			end
		end
	end
}

local function emit(emitter)
	local emitCount = tonumber(emitter:GetAttribute("EmitCount")) or tonumber(emitter.Name) or 0
	local emitDuration = tonumber(emitter:GetAttribute("EmitDuration")) or 0

	if emitter:IsA("ParticleEmitter") then
		emitter:Emit(emitCount)
	end

	if emitDuration > 0 then
		emitter.Enabled = true
		task.delay(emitDuration, function()
			emitter.Enabled = false
		end)
	end
end

function VFX.emit(effect)
	for _, v in effect:QueryDescendants("ParticleEmitter,Beam") do
		local emitDelay = v:GetAttribute("EmitDelay")

		if emitDelay == nil then
			emit(v)
		else
			task.delay(emitDelay, emit, v)
		end
	end

	if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
		local emitDelay = effect:GetAttribute("EmitDelay")

		if emitDelay == nil then
			emit(effect)
		else
			task.delay(emitDelay, emit, effect)
		end
	end
end

function VFX.emitLoop(instance, loopTimer: number)
	instance:SetAttribute("LoopTimer", loopTimer)
	instance:AddTag("EmitLoop")
end

if RunService:IsClient() then
	Observers.observeTag("EmitLoop", function(p)
		return Observers.observeAttribute(p, "LoopTimer", function(value)
			if type(value) ~= "number" then
				return nil
			end

			local connection = Timer.Simple(value, function()
				VFX.emit(p)
			end, true)
			return function()
				connection:Disconnect()
			end
		end)
	end, { workspace })
end

return VFX