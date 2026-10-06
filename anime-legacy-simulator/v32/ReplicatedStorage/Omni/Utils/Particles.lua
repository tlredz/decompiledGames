local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientData = require(ReplicatedStorage.Omni.ClientData)
local isClient = RunService:IsClient()
return table.freeze({
	Emit = function(self, folder)
		if typeof(folder) ~= "Instance" or isClient and ClientData.Ready and ClientData.Data.Settings["Low Mode"] then
			return
		end

		for _, emitter in folder:GetDescendants() do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount") or emitter.Rate)
			end
		end
	end,
	EnableAll = function(_, folder)
		if typeof(folder) ~= "Instance" or isClient and ClientData.Ready and ClientData.Data.Settings["Low Mode"] then
			return
		end

		for _, descendant in folder:GetDescendants() do
			if not (descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("PointLight")) then
				continue
			end

			descendant.Enabled = true
		end
	end,
	DisableAll = function(_, folder)
		if typeof(folder) ~= "Instance" then
			return
		end

		for _, descendant in folder:GetDescendants() do
			if not (descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("PointLight")) then
				continue
			end

			descendant.Enabled = false
		end
	end
})