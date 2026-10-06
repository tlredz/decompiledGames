script.Parent.Changed:Connect(function(p)
	if script.Parent.Visible and p == "Visible" then
		local v = false

		local function WorkingWaiting(p2)
			local studioGui = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("StudioGui", 9)
			local workingImageLabel1 = studioGui:WaitForChild("WorkingImageLabel1")
			local workingImageLabel2 = studioGui:WaitForChild("WorkingImageLabel2")
			spawn(function()
				v = true

				for _ = 1, p2 do
					if not v then
						break
					end

					if workingImageLabel1.Visible then
						workingImageLabel1.Visible = false
						workingImageLabel2.Visible = true
					else
						workingImageLabel1.Visible = true
						workingImageLabel2.Visible = false
					end

					task.wait(0.1)
				end

				v = false
				workingImageLabel1.Visible = false
				workingImageLabel2.Visible = false
			end)
		end

		WorkingWaiting(20)
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		ReplicatedStorage:WaitForChild("StudioLiteFolder"):WaitForChild("RefreshPublished"):FireServer()
	end
end)