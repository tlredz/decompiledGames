local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local otherEvent = ReplicatedStorage:WaitForChild("OtherEvent")
local modules = ReplicatedStorage:WaitForChild("Modules")
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
local guiTemplate = ReplicatedStorage:WaitForChild("GuiTemplate")
local sound_Effect = ReplicatedStorage:WaitForChild("Sound_Effect")
local compassAssets = guiTemplate:WaitForChild("CompassAssets")
local miscEvents = otherEvent:WaitForChild("MiscEvents")
local spawnLocations = workspace:WaitForChild("Location"):WaitForChild("SpawnLocations")
local newQuest = miscEvents:WaitForChild("NewQuest")
require(moduleScript:WaitForChild("SetText"))
local Quest_Settings = require(moduleScript:WaitForChild("Quest_Settings"))
local Shiny = require(modules:WaitForChild("Shiny"))
local playerData = localPlayer:WaitForChild("PlayerData", 60)
localPlayer:WaitForChild("PlayerGui", 60)
local quest_Tracker = playerData:WaitForChild("Quest_Tracker")
local island_Tracker = playerData:WaitForChild("Island_Tracker")
local level = playerData:WaitForChild("Level")
local parent = script.Parent
local parent2 = parent.Parent.Parent.Parent
local container = parent.Container
local container2 = parent.Parent.Island.Container
local compass = parent2.Parent.Compass
local questTracker_Template = compassAssets:WaitForChild("QuestTracker_Template")
local islandTracker_Template = compassAssets:WaitForChild("IslandTracker_Template")
local notification = sound_Effect:WaitForChild("Notification")
local levelNeeds = {}
local v = nil
local v2 = {}

for _, quest_Setting in pairs(Quest_Settings) do
	if not (quest_Setting.Unacceptable_Quest or quest_Setting.Special_Quest) then
		table.insert(levelNeeds, quest_Setting.LevelNeed)
	end
end

local v3 = {
	["Floppa Island"] = 1,
	["Snow Island"] = 2,
	["Gorilla Island"] = 3,
	["Sand Island"] = 4,
	["Pumpkin Island"] = 5,
	["Sus Mountain"] = 6,
	["Moai Island"] = 7,
	["Sus Island"] = 8,
	["Noob Arena"] = 9,
	["Forgotten Island"] = 10,
	["Pvp Arena"] = 11,
	["MrBeast Island"] = 12
}

-- equivalent calls inferred from this helper; original call sites unknown
local function OpeningThisFrame()
	return parent2.Visible == true and parent2.Position == UDim2.new(0.5, 0, 0.5, 0)
end

local function findHighestNumber(list)
	local v4 = -1e999

	for _, v5 in ipairs(list) do
		if v4 < v5 then
			v4 = v5
		end
	end

	return v4
end

local function SetColor_State(track, p: string)
	if p == "Normal" then
		track.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(88, 101, 242)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(51, 60, 141))
		})
		track.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(88, 101, 242)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(51, 60, 141))
		})
		track.Textlabel.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(88, 101, 242)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(51, 60, 141))
		})
		track.Normal.Pattern.ImageColor3 = Color3.fromRGB(28, 33, 77)
	elseif p == "Recommended" then
		track.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(63, 240, 148)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 126, 93))
		})
		track.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(63, 240, 148)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 126, 93))
		})
		track.Textlabel.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(63, 240, 148)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 126, 93))
		})
		track.Recommended.Pattern.ImageColor3 = Color3.fromRGB(25, 74, 36)
	elseif p == "Tracked" then
		track.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(229, 92, 92)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(163, 38, 38))
		})
		track.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(229, 92, 92)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(163, 38, 38))
		})
		track.Textlabel.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(229, 92, 92)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(163, 38, 38))
		})
		track.Tracked.Pattern.ImageColor3 = Color3.fromRGB(66, 26, 26)
	end
end

local function StopAllTracks()
	for _, frame in ipairs(container:GetChildren()) do
		if not frame:IsA("Frame") then
			continue
		end

		if frame:GetAttribute("Recommended") then
			if not frame.TrackFrame.Track.Recommended.Visible then
				frame.TrackFrame.Track.Recommended.Visible = true
				SetColor_State(frame.TrackFrame.Track, "Recommended")

				if v == nil then
					v = Shiny.new(frame.TrackFrame, 1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1, false, 0.5)
					v:Play()
				end
			end
		elseif not frame.TrackFrame.Track.Normal.Visible then
			frame.TrackFrame.Track.Normal.Visible = true
			SetColor_State(frame.TrackFrame.Track, "Normal")
		end

		if frame.TrackFrame.Track.Tracked.Visible == true then
			frame.TrackFrame.Track.Tracked.Visible = false
		end

		if frame.Tracking.Visible == true then
			frame.Tracking.Visible = false

			if localPlayer:GetAttribute("TH") then
				frame.TrackFrame.Track.Textlabel.Text = "นำทาง"
			else
				frame.TrackFrame.Track.Textlabel.Text = "Track"
			end
		end

		if frame.Icon.Visible == false then
			frame.Icon.Visible = true
		end
	end

	for _, frame in ipairs(container2:GetChildren()) do
		if not frame:IsA("Frame") then
			continue
		end

		if not frame.TrackFrame.Track.Normal.Visible then
			frame.TrackFrame.Track.Normal.Visible = true
			SetColor_State(frame.TrackFrame.Track, "Normal")
		end

		if frame.TrackFrame.Track.Tracked.Visible == true then
			frame.TrackFrame.Track.Tracked.Visible = false
		end

		if frame.Tracking.Visible == true then
			frame.Tracking.Visible = false

			if localPlayer:GetAttribute("TH") then
				frame.TrackFrame.Track.Textlabel.Text = "นำทาง"
			else
				frame.TrackFrame.Track.Textlabel.Text = "Track"
			end
		end

		if frame.Icon.Visible == false then
			frame.Icon.Visible = true
		end
	end
end

local function Update_Quests()
	table.clear(v2)

	for _, v4 in ipairs(levelNeeds) do
		if v4 <= level.Value then
			table.insert(v2, v4)
		end
	end
end

local function Generate_Quest()
	for _, frame in ipairs(container:GetChildren()) do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end

	Update_Quests()

	for k, quest_Setting in pairs(Quest_Settings) do
		if quest_Setting.Special_Quest or quest_Setting.Unacceptable_Quest then
			continue
		end

		local clone = questTracker_Template:Clone()
		clone.Name = k
		clone.Title.Text = k
		clone:SetAttribute("NeededLevel", quest_Setting.LevelNeed)

		if localPlayer:GetAttribute("TH") then
			clone.Description.Size = UDim2.new(0.542, 0, 0.35, 0)
			clone.Description.Text = `เลเวลที่ต้องการ : {clone:GetAttribute("NeededLevel")}+`
		else
			clone.Description.Text = `Level Required: {clone:GetAttribute("NeededLevel")}+`
		end

		local v5 = -1e999

		for _, v6 in ipairs(v2) do
			if v5 < v6 then
				v5 = v6
			end
		end

		if v5 == clone:GetAttribute("NeededLevel") then
			clone:SetAttribute("Recommended", true)

			if not clone.TrackFrame.Track.Recommended.Visible then
				clone.TrackFrame.Track.Recommended.Visible = true
				SetColor_State(clone.TrackFrame.Track, "Recommended")

				if v == nil and OpeningThisFrame() then
					v = Shiny.new(clone.TrackFrame, 1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1, false, 0.5)
					v:Play()
				end
			end

			if clone.Tracking.Visible == false and clone.TrackFrame.Track.Normal.Visible then
				clone.TrackFrame.Track.Normal.Visible = false
			end
		end

		clone.LayoutOrder = clone:GetAttribute("NeededLevel")
		clone.Parent = container
		clone.Visible = true
		clone.TrackFrame.Track.Activated:Connect(function()
			if quest_Tracker.Value == clone.Name then
				if clone:GetAttribute("Recommended") then
					if not clone.TrackFrame.Track.Recommended.Visible then
						if clone.TrackFrame.Track.Normal.Visible then
							clone.TrackFrame.Track.Normal.Visible = false
						end

						if v == nil then
							v = Shiny.new(
								clone.TrackFrame,
								1,
								Enum.EasingStyle.Quad,
								Enum.EasingDirection.Out,
								-1,
								false,
								0.5
							)
							v:Play()
						end

						clone.TrackFrame.Track.Recommended.Visible = true
						SetColor_State(clone.TrackFrame.Track, "Recommended")
					end
				elseif not clone.TrackFrame.Track.Normal.Visible then
					if clone.TrackFrame.Track.Recommended.Visible then
						clone.TrackFrame.Track.Recommended.Visible = false

						if v then
							v:Cancel()
							v = nil
						end
					end

					clone.TrackFrame.Track.Normal.Visible = true
					SetColor_State(clone.TrackFrame.Track, "Normal")
				end

				clone.TrackFrame.Track.Tracked.Visible = false
				clone.Tracking.Visible = false
				clone.Icon.Visible = true

				if island_Tracker.Value ~= "None" then
					island_Tracker.Value = "None"
				end

				quest_Tracker.Value = "None"

				if localPlayer:GetAttribute("TH") then
					clone.TrackFrame.Track.Textlabel.Text = "นำทาง"
				else
					clone.TrackFrame.Track.Textlabel.Text = "Track"
				end
			else
				StopAllTracks()

				if island_Tracker.Value ~= "None" then
					island_Tracker.Value = "None"
				end

				clone.Icon.Visible = false

				if clone.TrackFrame.Track.Recommended.Visible then
					clone.TrackFrame.Track.Recommended.Visible = false

					if v then
						v:Cancel()
						v = nil
					end
				end

				if clone.TrackFrame.Track.Normal.Visible then
					clone.TrackFrame.Track.Normal.Visible = false
				end

				clone.TrackFrame.Track.Tracked.Visible = true
				SetColor_State(clone.TrackFrame.Track, "Tracked")
				clone.Tracking.Visible = true

				if localPlayer:GetAttribute("TH") then
					clone.TrackFrame.Track.Textlabel.Text = "เลิกนำทาง"
				else
					clone.TrackFrame.Track.Textlabel.Text = "Untrack"
				end

				quest_Tracker.Value = clone.Name
			end
		end)
	end
end

local function Generate_Island()
	for _, frame in ipairs(container2:GetChildren()) do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end

	for _, child in pairs(spawnLocations:GetChildren()) do
		if not v3[child.Name] then
			continue
		end

		local clone = islandTracker_Template:Clone()
		clone.Name = child.Name
		clone.Title.Text = child.Name
		clone.LayoutOrder = v3[child.Name]
		clone.Parent = container2
		clone.Visible = true
		clone.TrackFrame.Track.Activated:Connect(function()
			if island_Tracker.Value == clone.Name then
				if not clone.TrackFrame.Track.Normal.Visible then
					clone.TrackFrame.Track.Normal.Visible = true
					SetColor_State(clone.TrackFrame.Track, "Normal")
				end

				clone.TrackFrame.Track.Tracked.Visible = false
				clone.Tracking.Visible = false
				clone.Icon.Visible = true

				if quest_Tracker.Value ~= "None" then
					quest_Tracker.Value = "None"
				end

				island_Tracker.Value = "None"

				if localPlayer:GetAttribute("TH") then
					clone.TrackFrame.Track.Textlabel.Text = "นำทาง"
				else
					clone.TrackFrame.Track.Textlabel.Text = "Track"
				end
			else
				StopAllTracks()

				if quest_Tracker.Value ~= "None" then
					quest_Tracker.Value = "None"
				end

				if clone.TrackFrame.Track.Normal.Visible then
					clone.TrackFrame.Track.Normal.Visible = false
				end

				clone.Icon.Visible = false
				clone.TrackFrame.Track.Tracked.Visible = true
				SetColor_State(clone.TrackFrame.Track, "Tracked")
				clone.Tracking.Visible = true

				if localPlayer:GetAttribute("TH") then
					clone.TrackFrame.Track.Textlabel.Text = "เลิกนำทาง"
				else
					clone.TrackFrame.Track.Textlabel.Text = "Untrack"
				end

				island_Tracker.Value = clone.Name
			end
		end)
	end
end

while localPlayer:GetAttribute("LoadedData") == nil do
	task.wait(1)
end

newQuest.OnClientEvent:Connect(function(p: string)
	if p == "NewQuest_Unlocked" then
		for _, frame in ipairs(container:GetChildren()) do
			if not (frame:IsA("Frame") and frame:GetAttribute("Recommended")) then
				continue
			end

			frame:SetAttribute("Recommended", nil)

			if frame.TrackFrame.Track.Recommended.Visible then
				frame.TrackFrame.Track.Recommended.Visible = false

				if v then
					v:Cancel()
					v = nil
				end
			end

			if frame.Tracking.Visible ~= false or frame.TrackFrame.Track.Normal.Visible then
				continue
			end

			frame.TrackFrame.Track.Normal.Visible = true
			SetColor_State(frame.TrackFrame.Track, "Normal")
		end

		if parent2.Visible ~= true or parent2.Position ~= UDim2.new(0.5, 0, 0.5, 0) or not parent.Visible then
			notification:Play()
			compass:SetAttribute("Amount", compass:GetAttribute("Amount") + 1)
		end

		Update_Quests()
		local v4 = nil

		for _, frame in ipairs(container:GetChildren()) do
			if not frame:IsA("Frame") then
				continue
			end

			local v7 = -1e999

			for _, v8 in ipairs(v2) do
				if v7 < v8 then
					v7 = v8
				end
			end

			if v7 ~= frame:GetAttribute("NeededLevel") then
				continue
			end

			frame:SetAttribute("Recommended", true)

			if not frame.TrackFrame.Track.Recommended.Visible and frame.Tracking.Visible == false then
				if frame.Tracking.Visible == false and frame.TrackFrame.Track.Normal.Visible then
					frame.TrackFrame.Track.Normal.Visible = false
				end

				frame.TrackFrame.Track.Recommended.Visible = true

				if v == nil and OpeningThisFrame() then
					v = Shiny.new(frame.TrackFrame, 1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1, false, 0.5)
					v:Play()
				end

				SetColor_State(frame.TrackFrame.Track, "Recommended")
			end

			v4 = frame
			break
		end

		if v4 and (parent2.Visible ~= true or parent2.Position ~= UDim2.new(0.5, 0, 0.5, 0)) then
			container.CanvasPosition = Vector2.new(0, 0)
			local v6 = v4.AbsolutePosition.Y - container.AbsolutePosition.Y - container.AbsoluteSize.Y / 2 + v4.AbsoluteSize.Y / 2
			container.CanvasPosition = Vector2.new(container.CanvasPosition.X, v6)
		end
	end
end)
localPlayer:GetAttributeChangedSignal("TH"):Connect(function()
	for _, frame in ipairs(container:GetChildren()) do
		if not (frame:IsA("Frame") and frame:GetAttribute("NeededLevel")) then
			continue
		end

		if localPlayer:GetAttribute("TH") then
			frame.Description.Size = UDim2.new(0.542, 0, 0.35, 0)
			frame.Description.Text = `เลเวลที่ต้องการ : {frame:GetAttribute("NeededLevel")}+`
		else
			frame.Description.Size = UDim2.new(0.542, 0, 0.3, 0)
			frame.Description.Text = `Level Required: {frame:GetAttribute("NeededLevel")}+`
		end
	end
end)
parent2:GetPropertyChangedSignal("Visible"):Connect(function()
	if parent2.Visible == false then
		if v then
			v:Cancel()
			v = nil
		end
	else
		for _, frame in ipairs(container:GetChildren()) do
			if not (frame:IsA("Frame") and frame:GetAttribute("Recommended")) then
				continue
			end

			if frame.Tracking.Visible ~= false or frame.TrackFrame.Track.Recommended.Visible ~= true or v ~= nil then
				break
			end

			v = Shiny.new(frame.TrackFrame, 1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1, false, 0.5)
			v:Play()
			return
		end
	end
end)
Generate_Quest()
Generate_Island()