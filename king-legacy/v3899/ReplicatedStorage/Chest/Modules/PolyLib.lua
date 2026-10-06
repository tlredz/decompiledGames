local PolyLib = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
ReplicatedStorage:FindFirstChild("Assets")

function PolyLib.CallEffect(_, instance)
	local clone = instance:Clone()
	clone.Parent = workspace.Effects
	return clone
end

function PolyLib:ParticleHandler(folder)
	if not folder then
		return
	end

	for _, effect in pairs(folder:GetDescendants()) do
		if effect:IsA("ParticleEmitter") then
			if effect:GetAttribute("EmitCount") then
				local emitCount = effect:GetAttribute("EmitCount")

				if effect:GetAttribute("EmitDelay") then
					local v = effect:GetAttribute("EmitDelay")
					local v2 = effect
					local v3 = emitCount
					task.spawn(function()
						task.wait(v)
						v2:Emit(v3)
					end)
				else
					local v = effect
					local v2 = emitCount
					task.spawn(function()
						v:Emit(v2)
					end)
				end
			end

			if effect:GetAttribute("EmitDuration") then
				local emitDuration = effect:GetAttribute("EmitDuration")

				if effect:GetAttribute("EmitDelay") then
					local v = effect:GetAttribute("EmitDelay")
					local v2 = effect
					local v3 = emitDuration
					task.spawn(function()
						task.wait(v)
						v2.Enabled = true
						task.wait(v3)
						v2.Enabled = false
					end)
				else
					local v = effect
					local v2 = emitDuration
					task.spawn(function()
						v.Enabled = true
						task.wait(v2)
						v.Enabled = false
					end)
				end
			end
		end

		if effect:IsA("Beam") then
			self:EmitBream(effect)
		end
	end
end

function PolyLib.Active(_, folder, enabled, p)
	if not folder then
		return
	end

	local v = {}

	for _, v2 in ipairs(p or { "Beam", "Trail", "ParticleEmitter" }) do
		v[v2] = true
	end

	for _, descendant in pairs(folder:GetDescendants()) do
		if v[descendant.ClassName] then
			descendant.Enabled = enabled
		end
	end
end

function PolyLib:EmitBream(instance)
	local duration = instance:GetAttribute("Duration")
	local width0 = instance:GetAttribute("Width0")
	local width1 = instance:GetAttribute("Width1")

	if duration and width0 and width1 then
		TweenService:Create(instance, TweenInfo.new(0.1), {
			Width1 = width1,
			Width0 = width0
		}):Play()
		task.delay(duration, function()
			TweenService:Create(instance, TweenInfo.new(0.2), {
				Width1 = 0,
				Width0 = 0
			}):Play()
		end)
	end
end

function PolyLib.DecalFlipbook(_, instance, instance2)
	if not (instance:GetAttribute("Flipbook") and instance2) then
		return
	end

	local lifetime = instance:GetAttribute("Lifetime")

	if not lifetime then
		return
	end

	local v = 1
	local v2 = {}

	while instance2:FindFirstChild((tostring(v))) do
		table.insert(v2, instance2:FindFirstChild((tostring(v))))
		v += 1
	end

	local count = #v2

	if count == 0 then
		return
	end

	local v3 = lifetime / count
	task.spawn(function()
		for i = 1, count do
			instance.Texture = v2[i].Texture
			task.wait(v3)
		end
	end)
end

return PolyLib