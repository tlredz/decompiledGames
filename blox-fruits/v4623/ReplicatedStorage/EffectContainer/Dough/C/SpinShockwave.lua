local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(game.ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Misc
local FX = require(game.ReplicatedStorage.FX)
local terrain = workspace.Terrain
workspace:WaitForChild("_WorldOrigin")
local dough = FX:WaitForChild("Dough")
return function(data)
	local cFrame = data.CFrame
	local duration = data.Duration or 1
	local scale = data.Scale or 1
	local enable = data.Enable or 0
	local transparency = data.Transparency or 0
	local buso = data.Buso
	local attachment = Instance.new("Attachment")
	attachment.CFrame = cFrame
	local spin = nil

	if data.Stage == 1 then
		spin = dough.Particles.Buzzcut.Spin
	elseif data.Stage == 2 then
		spin = dough.Particles.Buzzcut.FloorShockwaves
	end

	local color = nil

	if typeof(buso) == "Instance" then
		color = buso.Color
	elseif typeof(buso) == "Color3" then
		color = buso
	end

	local v = enable

	for _, child in pairs(spin:GetChildren()) do
		local clone = child:Clone()

		if color then
			clone.Color = Util.Misc.SwapColorInKeypoints(clone.Color, Color3.new(1, 0, 0), color)
		end

		Util.Misc.ScaleParticle(clone, scale, {
			ZOffset = clone.ZOffset
		})
		clone.Lifetime = NumberRange.new(clone.Lifetime.Min * duration, clone.Lifetime.Max * duration)
		local keypoints = Util.Misc.ScaleKeypoints(child.Transparency, 1 + transparency).Keypoints
		clone.Transparency = NumberSequence.new(keypoints)
		v = math.max(v, clone.Lifetime.Max)
		clone.Parent = attachment
	end

	attachment.Parent = terrain

	for _, child in pairs(attachment:GetChildren()) do
		local emitCount = child:GetAttribute("EmitCount") or 0
		local emitDelay = child:GetAttribute("EmitDelay")
		local v2 = child

		local function fn()
			if enable and enable > 0 then
				v2.Enabled = true
				task.delay(enable, function()
					v2.Enabled = false
				end)
			end

			if emitCount > 0 then
				if spin.Name == "Spin" then
					v2:Emit(emitCount / 2)
				else
					v2:Emit(emitCount)
				end
			end
		end

		if emitDelay and emitDelay > 0 then
			task.delay(emitDelay, fn)
		else
			fn()
		end

		if data.Stage == 2 then
			Effect.new("Dough.Misc.SpriteParticle"):replicate({
				Particle = child,
				Sprite = child.Name,
				Duration = child.Lifetime.Max / 2
			})
		end
	end

	Util.Debris:AddItem(attachment, v + 0.1)
end