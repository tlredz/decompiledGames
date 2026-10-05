local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("SoundService")
local packages = ReplicatedStorage:WaitForChild("packages")
local Net = require(packages:WaitForChild("Net"))
local Trove = require(packages:WaitForChild("Trove"))
local main = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Fillionaire"):WaitForChild("Main")
local template = main:WaitForChild("Template")
local FillionaireController = {
	Create = function(self, p)
		local maid = Trove.new()
		local clone = template:Clone()
		clone.Parent = main
		maid:Add(clone)
		main.Visible = true
		local count = 0

		for _, image in clone.GameNumbers:GetChildren() do
			if not image:IsA("ImageLabel") then
				continue
			end

			local v = p.default[tonumber(image.Name)]
			local reward = image:WaitForChild("reward")
			reward.Text = ("%sC$"):format(v)

			if v == 0 then
				continue
			end

			image.reward.TextColor3 = Color3.fromRGB(255, 255, 0)
			image.text.TextColor3 = Color3.fromRGB(255, 255, 0)
		end

		local v = {}

		for _, button in clone.PlayerNumbers:GetChildren() do
			if not button:IsA("ImageButton") then
				continue
			end

			local v2 = button
			maid:Add(button.MouseButton1Click:Connect(function()
				if not v2:GetAttribute("Strached") then
					v2:SetAttribute("Strached", true)
					v2.text.Text = p.player[tonumber(v2.Name)]
					count += 1
					local v3 = p.default[p.player[tonumber(v2.Name)]]

					if v3 == 0 then
						script.Click:Play()
					elseif not table.find(v, p.player[tonumber(v2.Name)]) then
						table.insert(v, p.player[tonumber(v2.Name)])
						script.End:Play()
						Net:RemoteEvent("Fillionaire/AskReward"):FireServer(v3)
						v2.text.TextColor3 = Color3.fromRGB(255, 255, 0)
					end

					if count >= 4 then
						clone.Close.Visible = true
						maid:Add(clone.Close.MouseButton1Click:Connect(function()
							script.Click:Play()
							maid:Destroy()

							if #main:GetChildren() <= 3 then
								main.Visible = false
							end
						end))
					end
				end
			end))
		end

		clone.Visible = true
	end
}

function FillionaireController.Start(_)
	Net:RemoteEvent("Fillionaire/Prompt", -1).OnClientEvent:Connect(function(p)
		FillionaireController:Create(p)
	end)
end

return FillionaireController