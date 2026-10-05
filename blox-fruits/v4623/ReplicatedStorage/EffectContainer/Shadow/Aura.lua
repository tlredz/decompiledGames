workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
game:GetService("TweenService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local _ = Util.Debris

local function viewerIsClose(p, p2, callback)
	local character = game.Players.LocalPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - p).magnitude <= p2 then
			callback()
		end
	end
end

return function(data)
	local type = data.Type

	if type == 1 then
		local root = data.Root

		if root then
			if (root.Position - workspace.CurrentCamera.CFrame.p).magnitude > 800 then
				return
			end

			Util.Sound:Play("ShadowAura", root, nil, 1, 2)
			local clone = script.Particles.AuraFlare:Clone()
			Util.Debris:AddItem(clone, 2)
			clone.Parent = root

			for _, child in pairs(clone:GetChildren()) do
				if child.Name == "Wind" then
					child:Emit(5)
				else
					child:Emit(2)
				end
			end
		end
	elseif type == 3 then
		local root = data.Root

		if root:FindFirstChild("ShadowAuraAttachment") then
			root.ShadowAuraAttachment:Destroy()
		end
	elseif type == 2 then
		local root = data.Root
		local level = data.Level
		local shadowAuraAttachment = nil

		if root:FindFirstChild("ShadowAuraAttachment") then
			shadowAuraAttachment = root.ShadowAuraAttachment
		else
			local _, result = pcall(function()
				shadowAuraAttachment = script.Particles.ShadowAuraAttachment:Clone()
				shadowAuraAttachment.Parent = root
			end)

			if result and shadowAuraAttachment ~= nil then
				shadowAuraAttachment:Destroy()
			end
		end

		local v = {
			[0] = function(p, p2, p3, p4, p5, p6)
				p3.Enabled = false
				p2.Enabled = false
				p.Enabled = false
				p4.Enabled = false
				p5.Enabled = false
				p6.Enabled = false
			end,
			[1] = function(p, p2, p3, p4, p5, p6)
				p3.Enabled = false
				p2.Enabled = false
				p.Enabled = true
				p4.Enabled = true
				p5.Enabled = false
				p6.Enabled = false
				p.TimeScale = 0.4
				p.SpreadAngle = NumberRange(-20, 20)
			end,
			[2] = function(p, p2, p3, p4, p5, p6)
				p3.Enabled = false
				p2.Enabled = true
				p.Enabled = false
				p4.Enabled = true
				p5.Enabled = true
				p6.Enabled = false
				p5.LightEmission = 1
				p2.TimeScale = 0.45
				p2.SpreadAngle = NumberRange(-20, 20)
			end,
			[3] = function(p, p2, p3, p4, p5, p6)
				p3.Enabled = true
				p2.Enabled = false
				p.Enabled = false
				p4.Enabled = true
				p5.Enabled = true
				p6.Enabled = true
				p5.LightEmission = 1
				p3.TimeScale = 0.5
				p3.SpreadAngle = NumberRange(-50, 50)
			end
		}
		pcall(function()
			v[level](
				shadowAuraAttachment.Level1Smoke,
				shadowAuraAttachment.Level2Smoke,
				shadowAuraAttachment.Level3Smoke,
				shadowAuraAttachment.LooseSmoke,
				shadowAuraAttachment.Dust,
				shadowAuraAttachment.Wind
			)
		end)
	end
end