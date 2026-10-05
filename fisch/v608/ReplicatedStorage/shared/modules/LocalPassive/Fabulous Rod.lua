local FabulousRod = {}
game:GetService("ContentProvider")
game:GetService("RunService")
game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")

function FabulousRod.Morph(p, parent, object)
	object:Preload({ script })
	task.spawn(function()
		object:WaitUntilReady()
		object:GetRandom(5)
		local playerbar = parent.playerbar
		local _ = object.progressefficiency
		local _ = playerbar.Size.X.Scale
		local backgroundColor3 = playerbar.BackgroundColor3
		tick()
		local count = 0

		local function FabulousRevenge()
			script.revenge:Play()
			object:TweenModifier("progressefficiency", "force_add", 2, 0, TweenInfo.new(p.config.RevengeDuration))
			object:TweenModifier("barSize", "multiply", 1.75, 1, TweenInfo.new(p.config.RevengeDuration))
			playerbar.BackgroundColor3 = Color3.fromRGB(217, 184, 255)
			object.logicTweens:Create(playerbar, TweenInfo.new(p.config.RevengeDuration), {
				BackgroundColor3 = backgroundColor3
			}):Play()
			local clone = script.Revengance:Clone()
			clone.Parent = parent
			clone.ImageTransparency = 0.6
			clone.ImageColor3 = Color3.fromRGB(235, 208, 252)
			local v = object.logicTweens:Create(clone, TweenInfo.new(p.config.RevengeDuration), {
				ImageColor3 = Color3.fromRGB(252, 116, 211),
				ImageTransparency = 1
			})
			v:Play()
			v.Completed:Once(function()
				clone:Destroy()
				v:Destroy()
			end)
		end

		object.OnSlash:Connect(function(p2, p3)
			if table.find(p.config.AllowedSlashSources, p2) or table.find(p.config.AllowedSlashSources, p3) then
				count += 1

				if count >= p.config.RequiredSlashCombo then
					count = 0
					FabulousRevenge()
				end
			end
		end)
	end)
end

setmetatable(FabulousRod, module)
return FabulousRod