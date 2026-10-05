local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local dough = FX:WaitForChild("Dough")
local doughMiscDonut = Effect.new("Dough.Misc.Donut")
local doughMiscArmsExtend = Effect.new("Dough.Misc.Arms.Extend")
local _ = workspace.CurrentCamera
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
return function(state)
	local _ = state.EffectId
	local stage = state.Stage
	local random = Random.new()

	if stage == 1 then
		doughMiscDonut:replicate(state)
	elseif stage == 2 then
		function state.OnExtend(data, duration)
			Effect.new("Dough.Misc.Arms.Extend.Effects.Extend"):replicate({
				CFrame = data.CFrame,
				Width = data.Width,
				Length = data.Length,
				Buso = data.Buso,
				Duration = duration,
				FastMode = state.FastMode,
				LimitSound = state.LimitSound
			})

			if state.RayCastResult then
				task.delay(duration * 0.3, function()
					local alignCFrame = Util.Misc.AlignCFrame(
						CFrame.new(state.RayCastResult.Position) * CFrame.Angles(
							0,
							random:NextNumber(-1, 1) * 3.141592653589793,
							0
						),
						state.RayCastResult.Normal
					)
					Util.Sound:Play(
						"Dough.DoughGroundBreaking",
						alignCFrame.p,
						nil,
						1.326 / ((data.Buso and 1.65 or 1.326) + random:NextNumber(-0.5, 0.5))
					)
					Effect.new("Dough.Misc.Hit.Floor"):replicate({
						CFrame = alignCFrame,
						Duration = 0.75,
						Scale = data.Width * 4 * 2.25,
						FastMode = state.FastMode
					})
					Effect.new("Dough.Misc.FloorExpand"):replicate({
						CFrame = alignCFrame,
						Buso = data.Buso,
						Scale = data.Width * (data.Buso and 5 or 7) * (state.MaximumFloorMultiplier or 1),
						BaseStrength = 0.75,
						Strength = (state.MaximumFloorMultiplier and 2 + state.MaximumFloorMultiplier or 1) * (data.Buso and 1.5 or 1),
						MaximumStrength = (state.MaximumFloorMultiplier or 1) * 15 * (data.Buso and 1.3 or 1),
						FastMode = state.FastMode
					})
				end)
			end

			if typeof(data.Buso) == "Color3" then
				local part = Instance.new("Part")
				part.Transparency = 1
				part.CanTouch = false
				part.Anchored = true
				part.CanCollide = false
				part.CastShadow = false
				part.CanQuery = false
				part.CanTouch = false
				part.CastShadow = false
				part.TopSurface = 0
				part.BottomSurface = 0
				part.Size = Vector3.new(data.Width * 4, data.Width * 4, data.Length * 0)
				part.CFrame = data.CFrame * CFrame.new(0, 0, -data.Length / 2 * 0)
				part.Parent = _WorldOrigin

				if state.FastMode then
					part.Size = Vector3.new(data.Width * 4, data.Width * 4, data.Length)
					part.CFrame = data.CFrame * CFrame.new(0, 0, -data.Length / 2)
				else
					Util.DistributedLoop:add(function(p, _)
						local v = math.min(1, p / duration)
						part.Size = Vector3.new(data.Width * 4, data.Width * 4, data.Length * v)
						part.CFrame = data.CFrame * CFrame.new(0, 0, -data.Length / 2 * v)

						if v == 1 then
							return true
						end
					end)
				end

				local v = 0

				for _, child in pairs(dough.Particles.Buso:GetChildren()) do
					local clone = child:Clone()
					Util.Misc.ScaleParticle(clone, data.Width * 2)
					clone.Color = ColorSequence.new(data.Buso)
					clone.Rate *= state.FastMode and 0.5 or 1
					clone.Parent = part
					clone:Emit(((clone:GetAttribute("Emit") or 10) + data.Length / 2) * (state.FastMode and 0.25 or 1))
					clone.Enabled = true
					v = math.max(v * 2 + duration, child.Lifetime.Max)
					task.delay(duration, function()
						clone.Enabled = false
					end)
				end

				Util.Debris:AddItem(part, v)
			end
		end

		function state.OnRetract(data, duration)
			Effect.new("Dough.Misc.Arms.Extend.Effects.Retract"):replicate({
				CFrame = data.CFrame * CFrame.new(0, 0, -data.Length),
				Width = data.Width,
				Length = data.Length,
				Buso = data.Buso,
				Duration = duration,
				FastMode = state.FastMode,
				LimitSound = state.LimitSound
			})
		end

		doughMiscArmsExtend:replicate(state)
	end
end