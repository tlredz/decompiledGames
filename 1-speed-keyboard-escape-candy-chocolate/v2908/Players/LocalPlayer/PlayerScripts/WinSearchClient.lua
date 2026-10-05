local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local winSearchAction = ReplicatedStorage:WaitForChild("WinSearchAction")
local v = 1000000000
local flag = false

local function getPanel()
	local winSearchPanel = playerGui:FindFirstChild("WinSearchPanel")

	if not winSearchPanel then
		return nil
	end

	local background = winSearchPanel:FindFirstChild("Background")

	if background then
		return background:FindFirstChild("Panel"), winSearchPanel, background
	end

	return nil
end

local function updateSuffixHighlight(instance)
	local suffixFrame = instance:FindFirstChild("SuffixFrame")

	if not suffixFrame then
		return
	end

	for _, button in ipairs(suffixFrame:GetChildren()) do
		if not button:IsA("TextButton") then
			continue
		end

		if button:GetAttribute("Mult") == v then
			button.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
			button.TextColor3 = Color3.fromRGB(0, 0, 0)
		else
			button.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
			button.TextColor3 = Color3.fromRGB(255, 255, 255)
		end
	end
end

local function clearResults(instance)
	local resultsScroll = instance:FindFirstChild("ResultsScroll")

	if not resultsScroll then
		return
	end

	for _, guiObject in ipairs(resultsScroll:GetChildren()) do
		if guiObject:IsA("TextLabel") or guiObject:IsA("TextButton") then
			guiObject:Destroy()
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setStatus(instance, text, color)
	local statusLabel = instance:FindFirstChild("StatusLabel")

	if statusLabel then
		statusLabel.Text = text
		statusLabel.TextColor3 = color or Color3.fromRGB(180, 180, 180)
	end
end

local function populateResults(panel, results, count, range)
	local resultsScroll = panel:FindFirstChild("ResultsScroll")

	if not resultsScroll then
		return
	end

	clearResults(panel)
	setStatus(panel, count .. " joueur(s) trouves | Range: " .. range, Color3.fromRGB(100, 255, 100)) -- equivalent call inferred; original call site unknown

	for _, v3 in ipairs(results) do
		local textLabel = Instance.new("TextLabel", resultsScroll)
		textLabel.Name = "Result_" .. v3.Index
		textLabel.Size = UDim2.new(1, -10, 0, 28)
		textLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
		textLabel.BackgroundTransparency = 0.3
		textLabel.BorderSizePixel = 0
		textLabel.Text = string.format("  #%d | UserId: %s | Wins: %s", v3.Index, tostring(v3.UserId), v3.WinsFormatted)
		textLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
		textLabel.TextScaled = true
		textLabel.Font = Enum.Font.GothamMedium
		textLabel.TextXAlignment = Enum.TextXAlignment.Left
		local uICorner = Instance.new("UICorner", textLabel)
		uICorner.CornerRadius = UDim.new(0, 6)
		local uITextSizeConstraint = Instance.new("UITextSizeConstraint", textLabel)
		uITextSizeConstraint.MaxTextSize = 12
	end

	if count == 0 then
		local textLabel = Instance.new("TextLabel", resultsScroll)
		textLabel.Name = "NoResult"
		textLabel.Size = UDim2.new(1, -10, 0, 40)
		textLabel.BackgroundTransparency = 1
		textLabel.Text = "Aucun joueur trouve dans ce range."
		textLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
		textLabel.TextScaled = true
		textLabel.Font = Enum.Font.GothamMedium
		local uITextSizeConstraint_2 = Instance.new("UITextSizeConstraint", textLabel)
		uITextSizeConstraint_2.MaxTextSize = 13
	end
end

local function wirePanel(panel, child, background)
	local closeBtn = panel:FindFirstChild("CloseBtn")

	if closeBtn then
		closeBtn.MouseButton1Click:Connect(function()
			child:Destroy()
		end)
	end

	background.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local absolutePosition = panel.AbsolutePosition
			local absoluteSize = panel.AbsoluteSize
			local position = input.Position

			if position.X < absolutePosition.X or position.X > absolutePosition.X + absoluteSize.X or position.Y < absolutePosition.Y or position.Y > absolutePosition.Y + absoluteSize.Y then
				child:Destroy()
			end
		end
	end)
	local suffixFrame = panel:FindFirstChild("SuffixFrame")

	if suffixFrame then
		for _, button in ipairs(suffixFrame:GetChildren()) do
			if not button:IsA("TextButton") then
				continue
			end

			local v2 = button
			button.MouseButton1Click:Connect(function()
				local mult = v2:GetAttribute("Mult")

				if mult then
					v = mult
					updateSuffixHighlight(panel)
				end
			end)
		end
	end

	updateSuffixHighlight(panel)
	local okBtn = panel:FindFirstChild("OkBtn")

	if okBtn then
		okBtn.MouseButton1Click:Connect(function()
			if flag then
				return
			end

			local minInputFrame = panel:FindFirstChild("MinInputFrame")
			local maxInputFrame = panel:FindFirstChild("MaxInputFrame")

			if not (minInputFrame and maxInputFrame) then
				return
			end

			local minInput = minInputFrame:FindFirstChild("MinInput")
			local maxInput = maxInputFrame:FindFirstChild("MaxInput")

			if not (minInput and maxInput) then
				return
			end

			local text = tonumber(minInput.Text)
			local text2 = tonumber(maxInput.Text)

			if text and text2 then
				local min = text * v
				local max = text2 * v

				if max <= min then
					setStatus(panel, "Max doit etre superieur a Min", Color3.fromRGB(255, 80, 80)) -- equivalent call inferred; original call site unknown
				else
					flag = true
					clearResults(panel)
					setStatus(panel, "Recherche en cours...", Color3.fromRGB(255, 215, 0)) -- equivalent call inferred; original call site unknown
					okBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
					winSearchAction:FireServer({
						Action = "search",
						Min = min,
						Max = max
					})
					task.delay(15, function()
						if flag then
							flag = false
							okBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 60)
						end
					end)
				end
			else
				setStatus(panel, "Entrez des nombres valides dans Min et Max", Color3.fromRGB(255, 80, 80)) -- equivalent call inferred; original call site unknown
			end
		end)
	end
end

winSearchAction.OnClientEvent:Connect(function(data)
	if type(data) ~= "table" then
		return
	end

	local winSearchPanel = playerGui:FindFirstChild("WinSearchPanel")
	local panel

	if winSearchPanel then
		local background = winSearchPanel:FindFirstChild("Background")

		if background then
			panel = background:FindFirstChild("Panel")
		end
	end

	if not panel then
		return
	end

	if data.Action == "results" then
		flag = false
		local okBtn = panel:FindFirstChild("OkBtn")

		if okBtn then
			okBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 60)
		end

		populateResults(panel, data.Results, data.Count, data.Range)
	elseif data.Action == "error" then
		flag = false
		local okBtn = panel:FindFirstChild("OkBtn")

		if okBtn then
			okBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 60)
		end

		setStatus(panel, data.Message, Color3.fromRGB(255, 80, 80)) -- equivalent call inferred; original call site unknown
	elseif data.Action == "status" then
		setStatus(panel, data.Message, Color3.fromRGB(255, 215, 0)) -- equivalent call inferred; original call site unknown
	end
end)
playerGui.ChildAdded:Connect(function(child)
	if child.Name == "WinSearchPanel" then
		task.spawn(function()
			flag = false
			local background = child:WaitForChild("Background", 5)

			if not background then
				return
			end

			local panel = background:WaitForChild("Panel", 5)

			if not panel then
				return
			end

			panel:WaitForChild("OkBtn", 5)
			local suffixFrame = panel:WaitForChild("SuffixFrame", 5)

			if suffixFrame then
				suffixFrame:WaitForChild("Suffix_K", 5)
			end

			wirePanel(panel, child, background)
		end)
	end
end)