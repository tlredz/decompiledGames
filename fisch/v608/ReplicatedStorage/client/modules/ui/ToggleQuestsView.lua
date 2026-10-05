local Players = game:GetService("Players")
game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local Debounce = require(packages.Debounce)
local deviceinset = Players.LocalPlayer.PlayerGui:WaitForChild("hud").deviceinset
local quests = deviceinset.quests
local arrowQuest = deviceinset.arrowQuest
TweenInfo.new(0.5, Enum.EasingStyle.Quint)
local v = true
return {
	init = function()
		task.spawn(function()
			arrowQuest.Visible = false

			local function hasVisibleQuests()
				for _, frame in quests:GetChildren() do
					if frame:IsA("Frame") and frame.Visible then
						return true
					end
				end

				return false
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function updateArrow()
				arrowQuest.Visible = hasVisibleQuests()
			end

			updateArrow() -- equivalent call inferred; original call site unknown
			arrowQuest.Activated:Connect(function()
				if Debounce("QuestViewToggle", 0.6) then
					return
				end

				v = not v
				quests:SetAttribute("Toggle", v)
			end)
			quests.ChildAdded:Connect(updateArrow)
			quests.ChildRemoved:Connect(updateArrow)
			quests.DescendantAdded:Connect(function(frame)
				if frame:IsA("Frame") then
					task.wait()
					updateArrow() -- equivalent call inferred; original call site unknown
				end
			end)
			quests.DescendantRemoving:Connect(updateArrow)

			for _, frame in quests:GetChildren() do
				if frame:IsA("Frame") then
					frame:GetPropertyChangedSignal("Visible"):Connect(updateArrow)
				end
			end

			quests.DescendantAdded:Connect(function(frame)
				if frame:IsA("Frame") then
					frame:GetPropertyChangedSignal("Visible"):Connect(updateArrow)
				end
			end)
		end)
	end
}