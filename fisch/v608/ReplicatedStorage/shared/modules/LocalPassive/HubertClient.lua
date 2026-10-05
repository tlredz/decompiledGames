local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = game.Players.LocalPlayer
local Trove = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Trove"))
require(ReplicatedStorage.packages.Net)
local module = require("./PassiveHandler")
local v = {
	["Meh.."] = "miau..",
	["Fine."] = "Meow.",
	["Good!"] = "Mreow!",
	["Great!"] = "Miauu!",
	["Amazing!!"] = "Mriauuu!",
	["PERFECT!"] = "MREOW!! :3"
}
local HubertClient = {
	new = function(p, config, env)
		local object = setmetatable({}, {
			__index = p
		})
		object.config = config
		object.trove = Trove.new()
		object.reelTrove = object.trove:Extend()
		object.env = env
		object.uid = game.HttpService:GenerateGUID(false)

		local function characterAdded(character)
			if not character then
				return
			end

			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			object.trove:Add(humanoidRootPart.ChildAdded:Connect(function(child)
				if child.Name ~= "powerfeedback" then
					return
				end

				pcall(function()
					local title = child.title

					if not title then
						return
					end

					title.TextColor3 = Color3.fromRGB(255, 183, 221)

					while title.Text == "" do
						task.wait()
					end

					title.Text = v[title.Text] or "Mreow"
				end)
			end))
		end

		characterAdded(localPlayer.Character)
		object.trove:Add(localPlayer.CharacterAdded:Connect(characterAdded))
		return object
	end
}
setmetatable(HubertClient, module)
return HubertClient