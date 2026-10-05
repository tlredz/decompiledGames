local createVector = vector.create
local CostumeClosetClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local halloweenCostumesFrame = Client.Interface.HalloweenCostumesFrame
local v = nil
local flag = false
local v2 = 1

function OpenWindow()
	halloweenCostumesFrame.Visible = true
end

function CloseWindow()
	v2 += 1
	local v3 = v2
	halloweenCostumesFrame.Visible = false
	task.delay(0.25, function()
		if v3 == v2 then
			OpenCurtain()
		end
	end)
end

function OpenCurtain()
	Client.Sound.Play("CurtainPull")
	local v3 = v
	local leftCurtain = v3:WaitForChild("Functional"):WaitForChild("Curtains"):WaitForChild("LeftCurtain")
	local rightCurtain = v3:WaitForChild("Functional"):WaitForChild("Curtains"):WaitForChild("RightCurtain")

	if not leftCurtain:GetAttribute("OriginalSize") then
		leftCurtain:SetAttribute("OriginalSize", leftCurtain.Size)
	end

	if not leftCurtain:GetAttribute("OriginalCF") then
		leftCurtain:SetAttribute("OriginalCF", leftCurtain.CFrame)
	end

	if not rightCurtain:GetAttribute("OriginalSize") then
		rightCurtain:SetAttribute("OriginalSize", rightCurtain.Size)
	end

	if not rightCurtain:GetAttribute("OriginalCF") then
		rightCurtain:SetAttribute("OriginalCF", rightCurtain.CFrame)
	end

	leftCurtain.Size = createVector(1.4, 9.6, 0.7)
	leftCurtain.CFrame = leftCurtain:GetAttribute("OriginalCF") * CFrame.new(0, 0, -1.5)
	rightCurtain.Size = createVector(1.4, 9.6, 0.7)
	rightCurtain.CFrame = rightCurtain:GetAttribute("OriginalCF") * CFrame.new(0, 0, 1.5)
end

function CloseCurtain()
	Client.Sound.Play("CurtainPull")
	local v3 = v
	local leftCurtain = v3:WaitForChild("Functional"):WaitForChild("Curtains"):WaitForChild("LeftCurtain")
	local rightCurtain = v3:WaitForChild("Functional"):WaitForChild("Curtains"):WaitForChild("RightCurtain")
	leftCurtain.Size = leftCurtain:GetAttribute("OriginalSize")
	leftCurtain.CFrame = leftCurtain:GetAttribute("OriginalCF")
	rightCurtain.Size = rightCurtain:GetAttribute("OriginalSize")
	rightCurtain.CFrame = rightCurtain:GetAttribute("OriginalCF")
end

halloweenCostumesFrame.CloseButton.MouseButton1Click:Connect(function()
	CloseWindow()
end)

function RequestWearCostume(p)
	if localPlayer.Character then
		flag = true
		task.delay(0.5, function()
			flag = false
		end)
		local v3 = Client.Events.RequestWearCostume:InvokeServer(p)

		if v3 and v3.Success then
			CloseWindow()
			Client.Sound.Play("WearCostume", {
				Volume = 0.2
			})
			flag = true
			task.delay(1, function()
				flag = false
			end)
		end
	end
end

function LoadCostumeButtons()
	local scrollingFrame = halloweenCostumesFrame.Inventory.ScrollingFrameHolder.ScrollingFrame

	for _, button in pairs(scrollingFrame:GetChildren()) do
		if not button:IsA("ImageButton") then
			continue
		end

		local v3 = button
		button.MouseButton1Click:Connect(function()
			if flag then
				return
			end

			RequestWearCostume(v3.Name)
		end)
	end
end

function CostumeClosetAdded(instance)
	if not instance:IsDescendantOf(workspace) then
		return
	end

	v = instance
	OpenCurtain()
	local touchZone = instance:WaitForChild("TouchZone")
	touchZone.Touched:Connect(function(otherPart)
		if flag or halloweenCostumesFrame.Visible then
			return
		end

		if localPlayer.Character and otherPart == localPlayer.Character.PrimaryPart then
			v2 += 1
			local v3 = v2
			CloseCurtain()
			task.wait(0.25)

			if v3 ~= v2 then
				return
			end

			OpenWindow()

			while true do
				task.wait(0.1)

				if not instance.Parent or not localPlayer.Character or v3 ~= v2 then
					break
				end

				local touchingParts = touchZone:GetTouchingParts()

				if not table.find(touchingParts, localPlayer.Character.PrimaryPart) then
					break
				end
			end

			if v3 == v2 then
				CloseWindow()
			end
		end
	end)
end

function CostumeClosetClient.Init()
	Client.Utility.ForAllTagged("CostumeCloset", CostumeClosetAdded)
	task.spawn(function()
		LoadCostumeButtons()
	end)
end

return CostumeClosetClient