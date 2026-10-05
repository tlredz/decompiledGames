game:GetService("RunService")
game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")
local CreamsicleFreeze = {
	Morph = function(p, _, object)
		local reel_bar = object.reel_bar

		if not reel_bar then
			return
		end

		local slipperiness = p.config.Slipperiness or 0.35
		local freezeTime = p.config.FreezeTime or 8
		local rod = object.core and object.core.rod

		if rod and slipperiness > 0 then
			rod.MaxAcceleration = 4 / slipperiness
		end

		if object.core and object.core.ui then
			object.core.ui.OnBarEffects_Enabled = false
		end

		local clone = script.Frost:Clone()
		clone.Parent = reel_bar
		local cryogenicFlash = reel_bar:FindFirstChild("CryogenicFlash") or clone and clone:FindFirstChild("CryogenicFlash")

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setFreezeAlpha(p2: number)
			if clone then
				clone.BackgroundTransparency = 1 - p2
			end

			if cryogenicFlash then
				cryogenicFlash.BackgroundTransparency = 1 - p2
			end
		end

		if clone then
			clone.BackgroundTransparency = 1
		end

		if cryogenicFlash then
			cryogenicFlash.BackgroundTransparency = 1
		end

		local v = 0
		local creamsicleFrozen = false
		p.reelTrove:Add(object.BuildEndingData:Bind(function(p2)
			p2.CreamsicleFrozen = creamsicleFrozen
			return p2
		end))
		p.reelTrove:Add(object.OnLogicStep:Connect(function(p2)
			if not object.active or creamsicleFrozen then
				return
			end

			if object.onbar then
				v = math.clamp(v + p2 / freezeTime, 0, 1)
			end

			setFreezeAlpha(v) -- equivalent call inferred; original call site unknown

			if v >= 1 then
				creamsicleFrozen = true
				object:FreezeFish(1e999)
				object.fx:SpawnShake(object.reel_bar, 0.4, 4, 0.01, true)

				if clone then
					clone.BackgroundTransparency = 0
				end

				if cryogenicFlash then
					cryogenicFlash.BackgroundTransparency = 0
				end
			end
		end))
	end
}
setmetatable(CreamsicleFreeze, module)
return CreamsicleFreeze