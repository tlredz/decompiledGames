game:GetService("ReplicatedStorage")
local debris = game.Debris
local thrown = game.Workspace.Thrown

local function ParseInfo(instance)
	return {
		CFrame = instance.CFrame,
		Transparency = instance.Transparency,
		Size = instance.Size,
		Scale = instance:FindFirstChild("Mesh") and instance.Mesh.Scale,
		Decal = instance:FindFirstChild("Decal") and instance.Decal.Transparency
	}
end

local Auxiliary = {
	Tween = function(p, p2, p3)
		local TweenService = game:GetService("TweenService")
		local tween = TweenService:Create(p, p2, p3)
		tween:Play()
		task.delay(p2.Time, function()
			tween:Destroy()
		end)
		return tween
	end
}

function Auxiliary.VFXTween(instance, p)
	local start = instance:FindFirstChild("Start")
	local firstChild = instance:FindFirstChild("End")
	local parseInfo = ParseInfo(firstChild)
	firstChild:Destroy()
	Auxiliary.Tween(start, p, {
		CFrame = parseInfo.CFrame,
		Transparency = parseInfo.Transparency,
		Size = parseInfo.Size
	})

	if start:FindFirstChild("Decal") then
		Auxiliary.Tween(start.Decal, p, {
			Transparency = parseInfo.Decal
		})
	end

	if start:FindFirstChild("Mesh") then
		Auxiliary.Tween(start.Mesh, p, {
			Scale = parseInfo.Scale
		})
	end

	task.delay(p.Time, function()
		start:Destroy()
	end)
end

function Auxiliary:Emit()
	for _, effect in self:GetDescendants() do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
			continue
		end

		local emitter = effect
		task.spawn(function()
			local emitDuration = emitter:GetAttribute("EmitDuration")
			local emitDelay = emitter:GetAttribute("EmitDelay")
			local emitCount = emitter:GetAttribute("EmitCount")

			if emitDelay and emitDelay ~= 0 then
				task.wait(emitDelay)
			end

			if emitDuration and emitDuration ~= 0 then
				emitter.Enabled = true
				task.delay(emitDuration, function()
					emitter.Enabled = false
				end)
			end

			if emitCount and emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitCount)
			end
		end)
	end
end

function Auxiliary.SpawnGroup(instance, cframe: CFrame?, p: number?)
	local clone = instance:Clone()

	if cframe then
		clone:PivotTo(cframe)
	end

	clone.Parent = thrown

	if p then
		debris:AddItem(clone, p)
	end

	return clone
end

return Auxiliary