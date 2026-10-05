local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local debris = Util.Debris
local boatTween = Util.BoatTween
return function(p)
	local cFrame = p.CFrame

	if cFrame then
		if (workspace.CurrentCamera.CFrame.Position - cFrame.Position).Magnitude > 1500 then
			return
		end

		local clone = script.Particles:Clone()
		debris:AddItem(clone, 5)
		clone.CFrame = cFrame
		clone.Parent = _WorldOrigin
		Util.Sound:Play("SetFireFast", cFrame.Position, nil, 1 + math.random(-20, 20) / 100, 1)
		local descendants = clone:GetDescendants()

		for _, instance in ipairs(descendants) do
			if instance:IsA("ParticleEmitter") then
				instance:Emit(instance:GetAttribute("EmitCount") or 1)
			elseif instance:IsA("Light") then
				local v = boatTween:Create(instance, {
					Time = 0.6,
					EasingStyle = "Sine",
					EasingDirection = "Out",
					DelayTime = 0,
					RepeatCount = 0,
					Reverses = true,
					StepType = "RenderStepped",
					Goal = {
						Brightness = 6,
						Range = 12
					}
				})
				local v2 = instance
				v.Completed:Connect(function()
					if v2 then
						v2:Destroy()
					end

					if v then
						v:Destroy()
					end
				end)
				v:Play()
			end
		end
	end
end