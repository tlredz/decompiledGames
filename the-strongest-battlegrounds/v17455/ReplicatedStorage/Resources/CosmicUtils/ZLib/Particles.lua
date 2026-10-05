local createVector = vector.create
local TweenService = game:GetService("TweenService")
local v = {
	Rock = { Enum.Material.Slate, Enum.Material.Concrete, Enum.Material.Rock },
	Grass = { Enum.Material.Grass },
	Smoke = {
		Enum.Material.Grass,
		Enum.Material.Slate,
		Enum.Material.Concrete,
		Enum.Material.Rock
	}
}

local function GroundCast(instance)
	local cFrame

	if instance:IsA("Model") then
		cFrame = instance.PrimaryPart.CFrame
	elseif instance:IsA("BasePart") then
		cFrame = instance.CFrame
	else
		cFrame = instance.WorldCFrame
	end

	local ignore = workspace:FindFirstChild("Ignore")
	local live = workspace:FindFirstChild("Live")
	local thrown = workspace:FindFirstChild("Thrown")
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { ignore, live, thrown }
	local raycastResult = workspace:Raycast(cFrame.Position, createVector(0, -5, 0), raycastParams)

	if raycastResult and raycastResult.Instance then
		return {
			Color = raycastResult.Instance.Color,
			Material = raycastResult.Material
		}
	end
end

local Particles = {}

function Particles:GetEmitCount(instance)
	local gameSettings = UserSettings().GameSettings
	local emitCount = instance:GetAttribute("EmitCount")

	if gameSettings.SavedQualityLevel.Value < 10 then
		emitCount /= gameSettings.SavedQualityLevel.Value <= 5 and 7 or 2
	end

	return emitCount
end

function Particles:Emit(folder)
	local _, result = pcall(function()
		return GroundCast(folder)
	end)

	for _, emitter in folder:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local emitDelay = emitter:GetAttribute("EmitDelay") or 0
		local v2 = emitter
		task.delay(emitDelay, function()
			if v2.Name == "Smoke" or v2.Name == "Rock" or v2.Name == "Grass" then
				if not result then
					return
				end

				v2.Color = ColorSequence.new(result.Color)
			end

			v2:Emit((math.max(self:GetEmitCount(v2), 1)))
		end)
	end
end

function Particles.Enable(_, folder, duration: number?)
	for _, effect in folder:GetDescendants() do
		if effect:IsA("ParticleEmitter") then
			if effect.Name == "Smoke" or effect.Name == "Rock" or effect.Name == "Grass" then
				local v2 = effect
				task.spawn(function()
					while v2 and v2.Parent ~= nil do
						local groundCast = GroundCast(v2.Parent)

						if not groundCast then
							v2.Enabled = false
						end

						if groundCast and v[v2.Name][groundCast.Material] then
							v2.Enabled = true
							v2.Color = groundCast.Color
						end

						task.wait(0.25)
					end
				end)
			else
				effect.Enabled = true

				if duration then
					local v2 = effect
					task.delay(duration, function()
						v2.Enabled = false
					end)
				end
			end
		elseif effect:IsA("Beam") or effect:IsA("Trail") then
			effect.Enabled = true

			if duration then
				local v2 = effect
				task.delay(duration, function()
					v2.Enabled = false
				end)
			end
		end
	end
end

function Particles.Disable(_, folder)
	for _, effect in folder:GetDescendants() do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) then
			continue
		end

		effect.Enabled = false
	end
end

function Particles.Freeze(_, folder, value: number?, duration: boolean?, value2: number?)
	for _, effect in folder:GetDescendants() do
		if effect:IsA("ParticleEmitter") then
			TweenService:Create(effect, TweenInfo.new(value or 1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				TimeScale = 0
			}):Play()

			if duration then
				local v2 = effect
				task.delay(duration, function()
					TweenService:Create(
						v2,
						TweenInfo.new(value2 or 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
						{
							TimeScale = 1
						}
					):Play()
				end)
			end
		elseif effect:IsA("Beam") then
			local textureSpeed = effect.TextureSpeed
			TweenService:Create(effect, TweenInfo.new(value or 1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				TextureSpeed = 0
			}):Play()

			if duration then
				local v2 = effect
				local textureSpeed2 = textureSpeed
				task.delay(duration, function()
					TweenService:Create(
						v2,
						TweenInfo.new(value2 or 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
						{
							TextureSpeed = textureSpeed2
						}
					):Play()
				end)
			end
		end
	end
end

function Particles.Slow(_, folder, value: number?, value2: number?, duration: number?, value3: number?)
	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("PartcileEmitter") then
			TweenService:Create(
				descendant,
				TweenInfo.new(value or 1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
				{
					TimeScale = value2 or 0.5
				}
			):Play()

			if duration then
				local v2 = descendant
				task.delay(duration, function()
					TweenService:Create(
						v2,
						TweenInfo.new(value3 or 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
						{
							TimeScale = 1
						}
					):Play()
				end)
			end
		elseif descendant:IsA("Beam") then
			local textureSpeed = descendant.TextureSpeed
			TweenService:Create(
				descendant,
				TweenInfo.new(value or 1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
				{
					TextureSpeed = value2 or 0.5
				}
			):Play()

			if duration then
				local v2 = descendant
				local textureSpeed2 = textureSpeed
				task.delay(duration, function()
					TweenService:Create(
						v2,
						TweenInfo.new(value3 or 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
						{
							TextureSpeed = textureSpeed2
						}
					):Play()
				end)
			end
		end
	end
end

return Particles