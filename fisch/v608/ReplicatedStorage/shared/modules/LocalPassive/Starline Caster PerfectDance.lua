local StarlineCasterPerfectDance = {}
game:GetService("RunService")
local module = require("./PassiveHandler")
local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
local tweenInfo2 = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local color = Color3.fromRGB(150, 200, 255)

function StarlineCasterPerfectDance.Morph(p, instance, object)
	task.spawn(function()
		object:WaitUntilReady()
		local config = p.config
		local total = 0
		local flag = false
		local modifier = object:CreateModifier("barSize", "multiply")
		modifier.Value = 1
		local modifier2 = object:CreateModifier("progressefficiency", "force_add")
		modifier2.Value = 0
		local playerbar = instance:FindFirstChild("playerbar")
		local backgroundColor3

		if playerbar then
			backgroundColor3 = playerbar.BackgroundColor3 or nil
		else
			backgroundColor3 = nil
		end

		local function activate()
			if flag then
				return
			end

			flag = true
			object.logicTweens:Create(modifier, tweenInfo, {
				Value = config.BarShrinkFactor
			}):Play()
			object.logicTweens:Create(modifier2, tweenInfo, {
				Value = config.ForcedProgressSpeedBonus / 100
			}):Play()

			if playerbar then
				object.logicTweens:Create(playerbar, tweenInfo, {
					BackgroundColor3 = color
				}):Play()
			end

			local activate2 = script:FindFirstChild("Activate")

			if activate2 then
				activate2:Play()
			end
		end

		local function deactivate()
			if not flag then
				return
			end

			flag = false
			object.logicTweens:Create(modifier, tweenInfo2, {
				Value = 1
			}):Play()
			object.logicTweens:Create(modifier2, tweenInfo2, {
				Value = 0
			}):Play()

			if playerbar and backgroundColor3 then
				object.logicTweens:Create(playerbar, tweenInfo2, {
					BackgroundColor3 = backgroundColor3
				}):Play()
			end
		end

		p.reelTrove:Add(object.OnFishExitBar:Connect(function()
			total = 0

			if flag then
				deactivate()
			end
		end))
		p.reelTrove:Add(object.OnLogicStep:Connect(function(p2)
			if not object.active then
				return
			end

			if object.onbar then
				total += p2

				if total >= config.TimeOnBarThreshold and not flag then
					activate()
				end
			else
				total = 0
			end
		end))
	end)
end

setmetatable(StarlineCasterPerfectDance, module)
return StarlineCasterPerfectDance