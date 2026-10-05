local createVector = vector.create
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local color = Color3.fromRGB(128, 128, 128)

local function getReferencePart(folder)
	if folder:IsA("BasePart") then
		return folder
	end

	if not folder:IsA("Model") then
		return nil
	end

	if folder.PrimaryPart then
		return folder.PrimaryPart
	end

	for _, part in ipairs(folder:GetDescendants()) do
		if part:IsA("BasePart") then
			return part
		end
	end

	return nil
end

local function buildExcludeList(instance)
	local result = { instance }

	for _, v in ipairs(Players:GetPlayers()) do
		if v.Character then
			table.insert(result, v.Character)
		end
	end

	local effects = Workspace:FindFirstChild("World") and Workspace.World:FindFirstChild("Effects")

	if effects then
		table.insert(result, effects)
	end

	return result
end

local function getGroundInfo(referencePart, p: number, folder)
	if not referencePart then
		return {
			Color = color,
			Material = Enum.Material.Air,
			Hit = false
		}
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = buildExcludeList(folder)
	local raycastResult = Workspace:Raycast(
		referencePart.Position + createVector(0, -0.25, 0),
		Vector3.new(0, -math.max(p, 1), 0),
		raycastParams
	)

	if raycastResult and raycastResult.Instance then
		return {
			Color = raycastResult.Instance.Color,
			Material = raycastResult.Material,
			Hit = true
		}
	end

	local color2 = color

	if typeof(folder.GetAttribute) == "function" then
		local groundFallbackColor = folder:GetAttribute("GroundFallbackColor")

		if typeof(groundFallbackColor) == "Color3" then
			color2 = groundFallbackColor
		end
	end

	return {
		Color = color2,
		Material = Enum.Material.Air,
		Hit = false
	}
end

local v = {
	Rock = { Enum.Material.Slate, Enum.Material.Concrete, Enum.Material.Rock },
	Grass = { Enum.Material.Grass }
}

local function canPlayParticle(p: string, p2)
	local v2 = v[p]

	if not v2 then
		return true
	end

	for _, v3 in ipairs(v2) do
		if v3 == p2 then
			return true
		end
	end

	return false
end

local function recolorIfSmoke(p, color2: Color3)
	if p.Name ~= "Smoke" then
		return
	end

	p.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, color2), ColorSequenceKeypoint.new(1, color2) })
end

local Particles = {}

function Particles.emitParticles(folder)
	local groundInfo = getGroundInfo(getReferencePart(folder), 20, folder)

	for _, emitter in folder:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local name = emitter.Name
		local material = groundInfo.Material
		local v2 = v[name]
		local flag

		if v2 then
			local flag2 = true

			for _, v3 in ipairs(v2) do
				if v3 ~= material then
					continue
				end

				flag = true
				flag2 = false
				break
			end

			if flag2 then
				flag = false
			end
		else
			flag = true
		end

		if flag then
			recolorIfSmoke(emitter, groundInfo.Color)
			local emitDelay = emitter:GetAttribute("EmitDelay")
			local emitCount = emitter:GetAttribute("EmitCount") or 0
			local emitDuration = emitter:GetAttribute("EmitDuration")

			if emitCount > 0 then
				if emitDelay then
					local v3 = emitter
					local v4 = emitCount
					task.delay(emitDelay, function()
						if v3.Parent then
							v3:Emit(v4)
						end
					end)
				elseif emitter.Parent then
					emitter:Emit(emitCount)
				end
			end

			if emitDuration then
				if emitDelay then
					local v3 = emitter
					local v4 = emitDuration
					task.delay(emitDelay, function()
						if not v3.Parent then
							return
						end

						v3.Enabled = true
						task.wait(v4)

						if v3.Parent then
							v3.Enabled = false
						end
					end)
				else
					emitter.Enabled = true
					local v3 = emitter
					task.delay(emitDuration, function()
						if v3.Parent then
							v3.Enabled = false
						end
					end)
				end
			end
		else
			emitter.Enabled = false
		end
	end
end

function Particles.enableParticles(folder)
	local groundInfo = getGroundInfo(getReferencePart(folder), 20, folder)

	local function enableOne(effect)
		if effect:IsA("ParticleEmitter") then
			local name = effect.Name
			local material = groundInfo.Material
			local v2 = v[name]
			local v3

			if v2 then
				local flag = true

				for _, v4 in ipairs(v2) do
					if v4 ~= material then
						continue
					end

					v3 = true
					flag = false
					break
				end

				if flag then
					v3 = false
				end
			else
				v3 = true
			end

			if not v3 then
				effect.Enabled = false
				return
			end

			recolorIfSmoke(effect, groundInfo.Color)
			effect.Enabled = true
		elseif effect:IsA("Trail") or effect:IsA("Beam") then
			effect.Enabled = true
		end
	end

	enableOne(folder)

	for _, descendant in folder:GetDescendants() do
		enableOne(descendant)
	end
end

function Particles.disableParticles(folder)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function disableOne(effect)
		if effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam") then
			effect.Enabled = false
		end
	end

	disableOne(folder) -- equivalent call inferred; original call site unknown

	for _, descendant in folder:GetDescendants() do
		disableOne(descendant) -- equivalent call inferred; original call site unknown
	end
end

return Particles