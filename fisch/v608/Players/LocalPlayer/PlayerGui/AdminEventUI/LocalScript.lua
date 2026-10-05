local mainFrame = script.Parent:WaitForChild("MainFrame")
local run = mainFrame:WaitForChild("run")
local commands = mainFrame:WaitForChild("commands")
local commandlist = commands:WaitForChild("commandlist")
local confirmation = mainFrame:WaitForChild("Confirmation")
local confirm = confirmation:WaitForChild("Confirm")
local cancel = confirmation:WaitForChild("Cancel")
local title = confirmation:WaitForChild("Title")
local search = commands:WaitForChild("search")
local close = mainFrame:FindFirstChild("Close")
local activatedConnection = nil
local activatedConnection2 = nil
local flag = false

-- equivalent calls inferred from this helper; original call sites unknown
local function cleanup()
	if activatedConnection then
		activatedConnection:Disconnect()
	end

	if activatedConnection2 then
		activatedConnection2:Disconnect()
	end

	activatedConnection = nil
	activatedConnection2 = nil
	confirmation.Visible = false
end

if close then
	close.Activated:Connect(function()
		cleanup() -- equivalent call inferred; original call site unknown
		mainFrame.Visible = false
	end)
end

local getEvents = mainFrame:FindFirstChild("GetEvents")

if getEvents then
	local success, result = pcall(function()
		return getEvents:InvokeServer()
	end)

	if success and result then
		local v = {}
		local iconsByIdentity = {}

		for _, v2 in result do
			local identity = string.lower(v2.identity)
			v[identity] = true

			if v2.icon then
				iconsByIdentity[identity] = v2.icon
			end
		end

		for _, button in commandlist:GetChildren() do
			if not (button:IsA("TextButton") or button:IsA("ImageButton")) then
				continue
			end

			local name = string.lower(button.Name)
			local v2 = v[name]
			button.Visible = v2 == true
			button:SetAttribute("Available", v2 == true)
			local image = iconsByIdentity[name]

			if not image or button:FindFirstChild("EventIcon") then
				continue
			end

			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Name = "EventIcon"
			imageLabel.Size = UDim2.new(0, 24, 0, 24)
			imageLabel.Position = UDim2.new(0, 4, 0.5, -12)
			imageLabel.BackgroundTransparency = 1
			imageLabel.Image = image
			imageLabel.ScaleType = Enum.ScaleType.Fit
			imageLabel.ZIndex = button.ZIndex + 1
			imageLabel.Parent = button
			button.Text = "      " .. button.Text
		end
	end
end

for _, button in commandlist:GetChildren() do
	if not (button:IsA("TextButton") or button:IsA("ImageButton")) then
		continue
	end

	local v = button
	button.Activated:Connect(function()
		if flag then
			return
		end

		cleanup() -- equivalent call inferred; original call site unknown
		title.Text = "Run '" .. v.Name .. "'?"
		confirmation.Visible = true
		activatedConnection = confirm.Activated:Once(function()
			if flag then
				return
			end

			flag = true
			cleanup() -- equivalent call inferred; original call site unknown
			run:FireServer(v.Name)
			task.delay(0.5, function()
				flag = false
			end)
		end)
		activatedConnection2 = cancel.Activated:Once(function()
			cleanup() -- equivalent call inferred; original call site unknown
		end)
	end)
end

local function filterButtons(text)
	local v = string.lower(text)

	for _, button in commandlist:GetChildren() do
		if not (button:IsA("TextButton") or button:IsA("ImageButton")) then
			continue
		end

		if button:GetAttribute("Available") ~= false then
			if v == "" then
				button.Visible = true
			else
				local name = string.lower(button.Name)
				local category = string.lower(button:GetAttribute("Category") or "")
				button.Visible = string.find(name, v, 1, true) or string.find(category, v, 1, true)
			end
		else
			button.Visible = false
		end
	end
end

search:GetPropertyChangedSignal("Text"):Connect(function()
	filterButtons(search.Text)
end)
confirmation.Visible = false