local MerlinSStaff = {}
game:GetService("ContentProvider")
game:GetService("RunService")
game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")

function MerlinSStaff.Morph(p, instance, object)
	object:Preload(script:GetChildren())
	task.spawn(function()
		object:WaitUntilReady()
		local playerGui = game.Players.LocalPlayer.PlayerGui
		local playerbar = instance.playerbar
		local _ = instance.Position
		local scale = playerbar.Size.X.Scale
		local backgroundColor3 = playerbar.BackgroundColor3
		local flag = false
		local v = true
		local v2 = nil
		local lastTime = nil
		object:AddModifier("minBarSize", "add", 0.1)
		local modifier = object:CreateModifier("resilience", "multiply")
		local modifier2 = object:CreateModifier("barSize", "add")
		local color = Color3.fromRGB(255, 138, 228)
		local clone = script.Glow:Clone()
		clone.Parent = playerbar
		local onLogicStepConnection = nil
		onLogicStepConnection = object.OnLogicStep:Connect(function(p2)
			if not instance.Parent then
				onLogicStepConnection:Disconnect()
				return
			end

			modifier.Value = object.onbar and object.barSize <= scale / 2 and 2 or 1

			if lastTime and tick() - lastTime >= 5 then
				lastTime = nil
				v = true
			end

			if v2 then
				v2 += p2
			end

			if v2 and v2 >= 1 and v and not lastTime and flag and object.barSize <= object.minBarSize + 0.01 then
				v = false
				flag = false
				v2 = nil
				local over = playerGui:FindFirstChild("over")

				if over then
					local clone2 = script.MerlinVignette:Clone()
					clone2.ImageColor3 = color
					clone2.ImageTransparency = 0.6
					p.reelTrove:Add(clone2)
					local v3 = object.logicTweens:Create(clone2, TweenInfo.new(5), {
						ImageTransparency = 1
					})
					v3.Completed:Once(function()
						v3:Destroy()
						clone2:Destroy()
					end)
					clone2.Parent = over
					v3:Play()
				end

				script.Sound:Play()
				object.fx:SpawnShake(object.reel_bar, 0.5, 1.5, 0.01, true)
				object:AddProgress(30)
				modifier2.Value = 0.15
				object.logicTweens:Create(modifier2, TweenInfo.new(1.5, Enum.EasingStyle.Elastic), {
					Value = 0
				}):Play()
				lastTime = tick()
			end

			if object.onbar and not flag and v then
				flag = true
			elseif not object.onbar and flag then
				flag = false
				v2 = nil
				object.logicTweens:Create(modifier2, TweenInfo.new(0.25, Enum.EasingStyle.Circular), {
					Value = 0
				}):Play()
			end

			if flag then
				modifier2.Value -= p2 / 10
			end

			local v3 = -modifier2.Value * 10 / 10
			playerbar.BackgroundColor3 = backgroundColor3:Lerp(color, v3)
			clone.BackgroundColor3 = playerbar.BackgroundColor3
			clone.BackgroundTransparency = math.lerp(1, 0, v3)

			if object.barSize <= object.minBarSize + 0.01 and not (v2 or lastTime) then
				v2 = 0
			end
		end)
	end)
end

setmetatable(MerlinSStaff, module)
return MerlinSStaff