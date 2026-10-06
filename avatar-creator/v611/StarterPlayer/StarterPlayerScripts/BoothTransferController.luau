local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local BoothTransferRules = require(replicatedStorage:WaitForChild("BoothTransferRules"))
local booths = workspace:WaitForChild("BoothPlaza"):WaitForChild("Booths")
local v = nil
local v2 = {}
local updateHeadersByName = {}
replicatedStorage:WaitForChild("BoothOwnershipChanged").OnClientEvent:Connect(function(p, p2)
	v2[p] = p2

	if updateHeadersByName[p] then
		updateHeadersByName[p]()
	end
end)

local function mount(instance)
	local donationSign = instance:WaitForChild("DonationSign")
	local editorPreview = donationSign:FindFirstChild("EditorPreview")

	if editorPreview then
		editorPreview.Enabled = false
	end

	local clone = replicatedStorage:WaitForChild("BoothTransferSurface"):Clone()
	clone.Name = "Transfer_" .. instance.Name
	clone.Adornee = donationSign
	clone.Parent = localPlayer:WaitForChild("PlayerGui")
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "BoothTransferGui_" .. instance.Name
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 550
	screenGui.Parent = localPlayer.PlayerGui

	local function make(className, items, parent)
		local instance2 = Instance.new(className)

		for k, item in items do
			instance2[k] = item
		end

		instance2.Parent = parent
		return instance2
	end

	local v3 = {
		Name = "Confirm",
		Visible = false,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(440, 270),
		BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	}
	local frame = Instance.new("Frame")

	for k, v4 in v3 do
		frame[k] = v4
	end

	frame.Parent = screenGui
	local v4 = {
		CornerRadius = UDim.new(0, 12)
	}
	local uICorner = Instance.new("UICorner")

	for k, v5 in v4 do
		uICorner[k] = v5
	end

	uICorner.Parent = frame
	local uIScale = Instance.new("UIScale")

	for k, v5 in {} do
		uIScale[k] = v5
	end

	uIScale.Parent = frame
	local v5 = {
		Position = UDim2.fromOffset(20, 16),
		Size = UDim2.fromOffset(400, 36),
		BackgroundTransparency = 1,
		Text = "Send Robux",
		TextColor3 = Color3.new(1, 1, 1),
		Font = Enum.Font.GothamBold,
		TextSize = 25
	}
	local textLabel = Instance.new("TextLabel")

	for k, v6 in v5 do
		textLabel[k] = v6
	end

	textLabel.Parent = frame
	local v6 = {
		Position = UDim2.fromOffset(20, 58),
		Size = UDim2.fromOffset(400, 145),
		BackgroundTransparency = 1,
		Text = "",
		TextWrapped = true,
		TextColor3 = Color3.new(1, 1, 1),
		Font = Enum.Font.Gotham,
		TextSize = 18
	}
	local textLabel2 = Instance.new("TextLabel")

	for k, v7 in v6 do
		textLabel2[k] = v7
	end

	textLabel2.Parent = frame

	local function button(name, text, p3)
		local v7 = {
			Name = name,
			Position = UDim2.fromOffset(p3, 215),
			Size = UDim2.fromOffset(190, 36),
			Text = text,
			BackgroundColor3 = Color3.fromRGB(190, 190, 190),
			TextColor3 = Color3.fromRGB(25, 25, 25),
			Font = Enum.Font.GothamBold,
			TextSize = 17
		}
		local textButton = Instance.new("TextButton")

		for k, v9 in v7 do
			textButton[k] = v9
		end

		textButton.Parent = frame
		return textButton
	end

	local v7 = button("Continue", "Continue to Roblox", 20)
	local v8 = button("Cancel", "Cancel", 230)
	local v9 = false
	v7.Visible = false
	v8.Text = "Close"

	-- equivalent calls inferred from this helper; original call sites unknown
	local function showError(error)
		if v and v ~= frame then
			v.Visible = false
		end

		v = frame
		textLabel2.Text = error
		frame.Visible = true
	end

	local function updateHeader()
		local v10 = v2[instance.Name] or instance:GetAttribute("OwnerUserId") or 0
		local playerByUserId = game.Players:GetPlayerByUserId(v10)
		local visible = v10 > 0
		clone.Buttons.Visible = visible
		clone.Left.Visible = visible
		clone.Right.Visible = visible
		clone.Split.Visible = visible
		clone.Heading.Text = not visible and "CLAIM THIS BOOTH TO RECEIVE ROBUX" or playerByUserId and "SEND ROBUX TO @" .. playerByUserId.Name or "SEND ROBUX"

		if not visible then
			frame.Visible = false
			clone.Buttons.CanvasPosition = Vector2.zero
		end
	end

	local function choose(p)
		local v10 = v2[instance.Name] or instance:GetAttribute("OwnerUserId") or 0

		if v9 or v10 == 0 then
			return
		end

		if v10 == localPlayer.UserId then
			showError("Other players can use these buttons to send you Robux.") -- equivalent call inferred; original call site unknown
		else
			v9 = true
			frame.Visible = false
			local success, result = pcall(function()
				return replicatedStorage.BoothTransferRemote:InvokeServer(instance.Name, v10, p)
			end)
			v9 = false

			if success then
				if result.error then
					showError(result.error) -- equivalent call inferred; original call site unknown
				end
			else
				showError("Could not connect. Try again.") -- equivalent call inferred; original call site unknown
			end
		end
	end

	for _, amount in BoothTransferRules.Amounts do
		local v10 = amount
		clone.Buttons["Amount" .. amount].Activated:Connect(function()
			choose(v10)
		end)
	end

	v8.Activated:Connect(function()
		frame.Visible = false
	end)
	updateHeadersByName[instance.Name] = updateHeader
	instance:GetAttributeChangedSignal("OwnerUserId"):Connect(function()
		v2[instance.Name] = instance:GetAttribute("OwnerUserId")
		updateHeader()
	end)
	updateHeader()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function fit()
		local currentCamera = workspace.CurrentCamera

		if currentCamera then
			local viewportSize = currentCamera.ViewportSize
			uIScale.Scale = math.min(1, (viewportSize.X - 24) / 440, (viewportSize.Y - 24) / 270)
		end
	end

	if workspace.CurrentCamera then
		workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fit)
	end

	fit() -- equivalent call inferred; original call site unknown

	local function scrollAmounts(p)
		local buttons = clone.Buttons
		local v10 = math.max(0, buttons.CanvasSize.X.Offset - buttons.AbsoluteWindowSize.X)
		local v11 = math.clamp(buttons.CanvasPosition.X + p * 705, 0, v10)
		local TweenService = game:GetService("TweenService")
		TweenService:Create(buttons, TweenInfo.new(0.25), {
			CanvasPosition = Vector2.new(v11, 0)
		}):Play()
	end

	clone.Left.Activated:Connect(function()
		scrollAmounts(-1)
	end)
	clone.Right.Activated:Connect(function()
		scrollAmounts(1)
	end)
end

local v3 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function add(model)
	if model:IsA("Model") and not v3[model] then
		v3[model] = true
		task.spawn(mount, model)
	end
end

booths.ChildAdded:Connect(add)

for _, child in booths:GetChildren() do
	add(child) -- equivalent call inferred; original call site unknown
end

replicatedStorage.BoothTransferNotice.OnClientEvent:Connect(function(p)
	pcall(function()
		local StarterGui = game:GetService("StarterGui")
		StarterGui:SetCore("SendNotification", {
			Title = "Robux transfer",
			Text = p.message,
			Duration = 6
		})
	end)
end)