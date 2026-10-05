local NatesBlade = {}
game:GetService("ContentProvider")
game:GetService("RunService")
game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")

function NatesBlade.Morph(_, p, object)
	if object.rodSkin == "Scarlet" then
		p.fish.sword.Image = "rbxassetid://116086765852244"
	end

	object:Preload({ script, p })
	task.spawn(function()
		script:WaitForChild("sound"):Play()
		object:WaitUntilReady()
		local modifier = object:CreateModifier("barSize", "add")
		local onLogicStepConnection = nil
		onLogicStepConnection = object.OnLogicStep:Connect(function(p2: number)
			if not p.Parent then
				onLogicStepConnection:Disconnect()
				return
			end

			modifier.Value += p2 / 15
			object:Update(0)
		end)
	end)
end

setmetatable(NatesBlade, module)
return NatesBlade