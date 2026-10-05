local localPlayer = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Base = require(script.Base)
local Network = require(game.ReplicatedStorage.Modules.Network)
local v = {}
local folder = Instance.new("Folder")
folder.Name = "ProjectileInstances"
folder.Parent = workspace

local function TriggerProjectileEffects(object)
	if not object then
		return
	end

	local hitEffect = object:FindFirstChild("HitEffect")
	local hitSound = object:FindFirstChild("HitSound")

	if hitEffect then
		for _, emitter in hitEffect:GetChildren() do
			if emitter:IsA("ParticleEmitter") and emitter:GetAttribute("EmitCount") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end
	end

	if hitSound and hitSound:IsA("Sound") then
		hitSound:Play()
	end
end

RunService.PostSimulation:Connect(function(dt)
	for _, v2 in v do
		local v3 = v2:Update(dt)

		if not (v3 and v3.Instance and v3.Position) then
			continue
		end

		local v4 = v2
		local v5 = v3
		task.spawn(function()
			local object = v4.Object
			local model = v5.Instance:FindFirstAncestorOfClass("Model")
			local model2, name

			if model and model:FindFirstChild("Humanoid") and game.Players:GetPlayerFromCharacter(model) then
				model2 = v5.Instance:FindFirstAncestorOfClass("Model")
				name = v5.Instance:FindFirstAncestorOfClass("Model").Name
			end

			if localPlayer == v4.Caster then
				local v6 = {
					TargetCharacter = model2,
					HitPosition = v5.Position,
					Velocity = v4.Velocity
				}
				Network:fire("ProjectileCollision", v4.Caster.Name, v4.Type, v6)
			end

			if name then
				local clone = script.HitMarker:Clone()
				local attachment = Instance.new("Attachment")
				clone.HitMarker.UIScale.Scale = 0.5
				clone.HitMarker.ImageTransparency = 0
				clone.HitMarker.Rotation = math.random(-20, 20)
				TweenService:Create(
					clone.HitMarker.UIScale,
					TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{
						Scale = 1.1
					}
				):Play()
				task.delay(0.2, function()
					TweenService:Create(
						clone.HitMarker.UIScale,
						TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
						{
							Scale = 0.8
						}
					):Play()
					TweenService:Create(clone.HitMarker, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
						ImageTransparency = 1
					}):Play()
				end)
				game.Debris:AddItem(clone, 1)
				clone.Parent = attachment
				clone.Sound.Parent = attachment
				attachment.Parent = v5.Instance
				attachment.Sound:Play()
			end

			if v4.HitModule and v4.HitModule.Impact then
				v4.HitModule.Impact(v4, v5, name)
			end

			task.delay(0.5, function()
				if object then
					object.CanCollide = false
				end
			end)
			object.Anchored = v4.Anchor or false
			task.delay(v4.FadeDelay or 0, function()
				TweenService:Create(object, TweenInfo.new(0.25), {
					Transparency = 1
				}):Play()

				for i, descendant in object:GetDescendants() do
					if descendant:IsA("BasePart") then
						TweenService:Create(descendant, TweenInfo.new(0.25), {
							Transparency = 1
						}):Play()
					end

					if descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") then
						descendant.Enabled = false
					end
				end

				if object:FindFirstChild("ProjectileTrail") then
					local projectileTrail = object:FindFirstChild("ProjectileTrail")
					projectileTrail.Enabled = false
				end

				TriggerProjectileEffects(object)
				local Debris = game:GetService("Debris")
				Debris:AddItem(object, v4.DebrisTimer or 2)
				table.remove(v, table.find(v, v4))
				setmetatable(v4, nil)
				table.clear(v4)
			end)
		end)
	end
end)

function _G.ProjectileCast(data)
	if not (data and data.MouseLocation) then
		return
	end

	local tool = data.Tool
	local clone = data.Projectile:Clone()
	clone.Name = tool.Name
	clone.CanCollide = false
	clone.Massless = true
	clone.Anchored = true

	if data.Handle then
		clone.Position = data.Handle.Position
	else
		clone.Position = tool.Handle.Position
	end

	clone.Parent = folder
	local projectileTrail = clone:FindFirstChild("ProjectileTrail")

	if projectileTrail then
		projectileTrail.Enabled = true
	end

	local unit = (data.MouseLocation - clone.Position).Unit
	local v2 = Base.new(data.Caster, clone, tool.Name)
	v2.Anchor = data.Anchor
	v2.FadeDelay = data.FadeDelay
	v2.DebrisTimer = 5
	v2.ProjectileAngle = data.ProjectileAngle

	if tool:GetAttribute("TomatoColor") then
		v2.SplatColor = tool:GetAttribute("TomatoColor")
	end

	for _, moduleScript in script:GetDescendants() do
		if (moduleScript.Name == tool.Name or moduleScript.Name == tool:GetAttribute("ToolOfSkin")) and moduleScript:IsA("ModuleScript") then
			v2.HitModule = require(moduleScript)
		end

		if v2.HitModule then
			break
		end
	end

	v2:ApplyAcceleration(unit * data.ProjectileVelocity)
	table.insert(v, v2)
end

Network:listen("ProjectileCast", function(p, _)
	_G.ProjectileCast(p)
end)