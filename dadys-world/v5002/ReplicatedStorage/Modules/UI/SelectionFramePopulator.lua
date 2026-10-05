local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TowerLUT = require(ReplicatedStorage.SharedUtils.TowerLUT)
local v = {
	"Astro",
	"Bassie",
	"Blot",
	"Bobette",
	"Boxten",
	"Brightney",
	"Coal",
	"Cocoa",
	"Connie",
	"Cosmo",
	"Eggson",
	"Finn",
	"Flutter",
	"Flyte",
	"Gigi",
	"Ginger",
	"Glisten",
	"Goob",
	"Looey",
	"Pebble",
	"Poppy",
	"RazzleDazzle",
	"Rodger",
	"Rudie",
	"Scraps"
}
local v2 = {
	"Alarm",
	"BlueBandana",
	"BlushyBat",
	"Bone",
	"Brick",
	"CardboardArmor",
	"ClownHorn",
	"Coal",
	"CoinPurse",
	"CrayonSet",
	"DandyPlush",
	"Diary",
	"DogPlush",
	"EggRadar",
	"FancyPurse",
	"FeatherDuster",
	"FestiveLights",
	"FishingRod",
	"FriendshipBracelet",
	"GhostSnakes"
}
local SelectionFramePopulator = {}

function SelectionFramePopulator.populateToonGrid(parent, p, p2)
	for _, button in pairs(parent:GetChildren()) do
		if button:IsA("GuiButton") and button.Name ~= "Template" then
			button:Destroy()
		end
	end

	local parent2 = parent:FindFirstChild("Template")

	if not parent2 then
		parent2 = Instance.new("TextButton")
		parent2.Name = "Template"
		parent2.Size = UDim2.new(0.173512578, 0, 0.15558739, 0)
		parent2.BackgroundColor3 = Color3.new(1, 1, 1)
		parent2.BackgroundTransparency = 1
		parent2.BorderSizePixel = 0
		parent2.Visible = false
		parent2.Text = ""
		parent2.Parent = parent
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "CharacterName"
		textLabel.Size = UDim2.new(1, 0, 0.3, 0)
		textLabel.Position = UDim2.new(0, 0, 0.7, 0)
		textLabel.BackgroundTransparency = 1
		textLabel.TextColor3 = Color3.new(1, 1, 1)
		textLabel.TextScaled = true
		textLabel.Font = Enum.Font.SourceSans
		textLabel.Parent = parent2
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Name = "CharacterImage"
		imageLabel.Size = UDim2.new(0.8, 0, 0.6, 0)
		imageLabel.Position = UDim2.new(0.1, 0, 0.1, 0)
		imageLabel.BackgroundTransparency = 1
		imageLabel.ScaleType = Enum.ScaleType.Fit
		imageLabel.Parent = parent2
		local imageLabel2 = Instance.new("ImageLabel")
		imageLabel2.Name = "Checkmark"
		imageLabel2.Size = UDim2.new(0.3, 0, 0.3, 0)
		imageLabel2.Position = UDim2.new(0.7, 0, 0, 0)
		imageLabel2.BackgroundTransparency = 1
		imageLabel2.Visible = false
		imageLabel2.Parent = parent2
	end

	for _, childName in ipairs(v) do
		local tower = TowerLUT:GetTower(childName)

		if not tower then
			continue
		end

		local module = require(tower)
		local clone = parent2:Clone()
		clone.Name = childName
		clone.Visible = true
		clone.Parent = parent

		if p and p[childName] or p2.Towers:FindFirstChild(childName) then
			if clone:FindFirstChild("CharacterName") then
				clone.CharacterName.Text = module.Name
			end

			if clone:FindFirstChild("CharacterImage") then
				clone.CharacterImage.Image = module.Icon
			end
		else
			clone.Visible = false
		end
	end
end

function SelectionFramePopulator.createTeamTemplate(parent)
	local parent2 = parent:FindFirstChild("Template")

	if parent2 then
		return parent2
	end

	parent2 = Instance.new("TextButton")
	parent2.Name = "Template"
	parent2.Size = UDim2.new(1, 0, 0.125, 0)
	parent2.Text = " "
	parent2.Font = Enum.Font.SourceSans
	parent2.BackgroundTransparency = 1
	parent2.Visible = false
	parent2.Parent = parent
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "PlayerName"
	textLabel.Size = UDim2.new(0.5, 0, 1, 0)
	textLabel.Position = UDim2.new(0, 0, 0, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.SourceSans
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.Parent = parent2
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Name = "CharacterName"
	textLabel2.Size = UDim2.new(0.5, 0, 1, 0)
	textLabel2.Position = UDim2.new(0.5, 0, 0, 0)
	textLabel2.BackgroundTransparency = 1
	textLabel2.TextColor3 = Color3.new(1, 1, 1)
	textLabel2.TextScaled = true
	textLabel2.Font = Enum.Font.SourceSans
	textLabel2.TextXAlignment = Enum.TextXAlignment.Left
	textLabel2.Parent = parent2
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "CharacterImage"
	imageLabel.Size = UDim2.new(0.2, 0, 0.8, 0)
	imageLabel.Position = UDim2.new(0.8, 0, 0.1, 0)
	imageLabel.BackgroundTransparency = 1
	imageLabel.ScaleType = Enum.ScaleType.Fit
	imageLabel.Parent = parent2
	return parent2
end

function SelectionFramePopulator.populateTrinketGrid(parent, p, p2)
	for _, button in pairs(parent:GetChildren()) do
		if button:IsA("GuiButton") and button.Name ~= "Template" then
			button:Destroy()
		end
	end

	local parent2 = parent:FindFirstChild("Template")

	if not parent2 then
		parent2 = Instance.new("TextButton")
		parent2.Name = "Template"
		parent2.Size = UDim2.new(0.22, 0, 0.15, 0)
		parent2.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		parent2.BackgroundTransparency = 1
		parent2.BorderSizePixel = 2
		parent2.BorderColor3 = Color3.fromRGB(100, 100, 100)
		parent2.Visible = false
		parent2.Text = ""
		parent2.Parent = parent
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "CharacterName"
		textLabel.Size = UDim2.new(1, 0, 0.3, 0)
		textLabel.Position = UDim2.new(0, 0, 0.7, 0)
		textLabel.BackgroundTransparency = 1
		textLabel.TextColor3 = Color3.new(1, 1, 1)
		textLabel.TextScaled = true
		textLabel.Font = Enum.Font.SourceSans
		textLabel.Parent = parent2
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Name = "CharacterImage"
		imageLabel.Size = UDim2.new(0.8, 0, 0.6, 0)
		imageLabel.Position = UDim2.new(0.1, 0, 0.1, 0)
		imageLabel.BackgroundTransparency = 1
		imageLabel.ScaleType = Enum.ScaleType.Fit
		imageLabel.Parent = parent2
		local imageLabel2 = Instance.new("ImageLabel")
		imageLabel2.Name = "Checkmark"
		imageLabel2.Size = UDim2.new(0.3, 0, 0.3, 0)
		imageLabel2.Position = UDim2.new(0.7, 0, 0, 0)
		imageLabel2.BackgroundTransparency = 1
		imageLabel2.Visible = false
		imageLabel2.Parent = parent2
	end

	for _, childName in ipairs(v2) do
		local child = ReplicatedStorage.TrinketData:FindFirstChild(childName)

		if not child then
			continue
		end

		local module = require(child)
		local clone = parent2:Clone()
		clone.Name = childName
		clone.Visible = true
		clone.Parent = parent

		if p and p[childName] or p2.Trinkets:FindFirstChild(childName) then
			if clone:FindFirstChild("CharacterName") then
				clone.CharacterName.Text = module.Name
			end

			if clone:FindFirstChild("CharacterImage") then
				clone.CharacterImage.Image = module.Icon
			end

			if clone:FindFirstChild("Checkmark") then
				clone.Checkmark.Visible = false
			end
		else
			clone.Visible = false
		end
	end
end

function SelectionFramePopulator:enhanceReadyUpFrame(_)
	self.Size = UDim2.new(0.9, 0, 0.1, 0)
	self.Position = UDim2.new(0.5, 0, 0.03, 0)

	for i = 1, 7 do
		local child = self:FindFirstChild("PlayerSlot" .. i)

		if not child then
			continue
		end

		child.Size = UDim2.new(0.12, 0, 0.9, 0)
		local playerName = child:FindFirstChild("PlayerName")

		if playerName then
			playerName.Position = UDim2.new(0.5, 0, 0.1, 0)
			playerName.Size = UDim2.new(0.9, 0, 0.25, 0)
			playerName.TextScaled = true
		end

		local playerIcon = child:FindFirstChild("PlayerIcon")

		if playerIcon then
			playerIcon.Position = UDim2.new(0.5, 0, 0.6, 0)
			playerIcon.Size = UDim2.new(0.8, 0, 0.5, 0)
			playerIcon.BackgroundTransparency = 1
		end

		local readyIndicator = child:FindFirstChild("ReadyIndicator")

		if not readyIndicator then
			continue
		end

		readyIndicator.Position = UDim2.new(0.8, 0, 0.05, 0)
		readyIndicator.Size = UDim2.new(0.25, 0, 0.25, 0)
	end
end

function SelectionFramePopulator.setupCharacterStats(instance, data)
	if not data then
		return
	end

	local stats = instance:FindFirstChild("Stats")

	if stats then
		for _, guiObject in pairs(stats:GetChildren()) do
			if guiObject:IsA("GuiObject") then
				guiObject:Destroy()
			end
		end

		local v3 = {
			{
				name = "Health",
				value = data.Health or 3,
				max = 4,
				color = Color3.fromRGB(255, 100, 100)
			},
			{
				name = "Stealth",
				value = data.StealthRank or 1,
				max = 5,
				color = Color3.fromRGB(100, 100, 255)
			},
			{
				name = "Stamina",
				value = data.StaminaRank or 1,
				max = 5,
				color = Color3.fromRGB(100, 255, 100)
			},
			{
				name = "Skill Check",
				value = data.SkillCheckRank or 1,
				max = 5,
				color = Color3.fromRGB(255, 255, 100)
			},
			{
				name = "Decode Speed",
				value = data.DecodeRank or 1,
				max = 5,
				color = Color3.fromRGB(255, 150, 100)
			},
			{
				name = "Speed",
				value = data.SpeedRank or 1,
				max = 5,
				color = Color3.fromRGB(150, 255, 150)
			}
		}

		for i, v4 in ipairs(v3) do
			local frame = Instance.new("Frame")
			frame.Name = v4.name .. "Frame"
			frame.Size = UDim2.new(1, 0, 0.15, 0)
			frame.Position = UDim2.new(0, 0, (i - 1) * 0.16, 0)
			frame.BackgroundTransparency = 1
			frame.Parent = stats
			local textLabel = Instance.new("TextLabel")
			textLabel.Size = UDim2.new(0.4, 0, 1, 0)
			textLabel.Position = UDim2.new(0, 0, 0, 0)
			textLabel.Text = v4.name
			textLabel.TextColor3 = Color3.new(1, 1, 1)
			textLabel.TextScaled = true
			textLabel.Font = Enum.Font.SourceSans
			textLabel.BackgroundTransparency = 1
			textLabel.TextXAlignment = Enum.TextXAlignment.Left
			textLabel.Parent = frame
			local frame2 = Instance.new("Frame")
			frame2.Name = "StarBar"
			frame2.Size = UDim2.new(0.55, 0, 1, 0)
			frame2.Position = UDim2.new(0.45, 0, 0, 0)
			frame2.BackgroundTransparency = 1
			frame2.Parent = frame

			for i2 = 1, v4.max do
				local imageLabel = Instance.new("ImageLabel")
				imageLabel.Name = "Star" .. i2
				imageLabel.Size = UDim2.new(0.18, 0, 0.8, 0)
				imageLabel.Position = UDim2.new((i2 - 1) * 0.2, 0, 0.1, 0)
				imageLabel.BackgroundTransparency = 1
				imageLabel.Image = "rbxassetid://6031068426"
				imageLabel.ImageColor3 = i2 <= v4.value and v4.color or Color3.fromRGB(100, 100, 100)
				imageLabel.Parent = frame2
			end
		end
	end
end

return SelectionFramePopulator