local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local chickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local collectibles = chickenOrHero:WaitForChild("Collectibles")
local gemEvent = collectibles:WaitForChild("GemEvent")
local GemConfig = require(collectibles:WaitForChild("GemConfig"))
local gemBillboard = collectibles:WaitForChild("GemBillboard")
local presentationCues = chickenOrHero:WaitForChild("Audio"):WaitForChild("PresentationCues")
local session = chickenOrHero:WaitForChild("Game"):WaitForChild("Session")
local v = {
	GroupRun = true,
	HeroRun = true,
	FinalRun = true
}
local folder = Instance.new("Folder")
folder.Name = "LocalRunnerGems"
folder.Parent = workspace
local v2 = {}
local token = nil

local function eligible()
	return localPlayer:GetAttribute("GameRole") == "Runner" and localPlayer:GetAttribute("RunState") == "Active" and localPlayer:GetAttribute("InMatch") == true and v[session:GetAttribute("Phase")] == true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clear()
	for _, v3 in v2 do
		v3.part:Destroy()
	end

	table.clear(v2)
	token = nil
end

local function refresh()
	local enabled = eligible()

	for _, v4 in v2 do
		v4.gui.Enabled = enabled
	end

	if enabled then
		gemEvent:FireServer("Sync")
	end
end

local function show(p)
	clear() -- equivalent call inferred; original call site unknown
	token = p.token

	for _, point in p.points do
		local part = Instance.new("Part")
		part.Name = "Gem_" .. point.id
		part.Size = createVector(0.1, 0.1, 0.1)
		part.Transparency = 1
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.CastShadow = false
		part.Position = point.position
		part.Parent = folder
		local clone = gemBillboard:Clone()
		clone.Adornee = part
		clone.MaxDistance = GemConfig.MaxVisibleDistance
		clone.Enabled = eligible()
		clone.Parent = part
		clone.Amount.Text = "+" .. point.amount
		clone.StackLeft.Visible = point.amount >= 3
		clone.StackRight.Visible = point.amount >= 6
		clone.Gem.TextColor3 = point.amount >= 6 and Color3.fromRGB(183, 255, 221) or Color3.fromRGB(127, 217, 191)
		local v3 = point.amount >= 6 and 4.2 or point.amount >= 3 and 3.8 or 3.25
		clone.Size = UDim2.fromScale(v3, v3 * 1.15)
		v2[point.id] = {
			part = part,
			gui = clone,
			phase = point.id * 2.1
		}
	end
end

local function collected(data)
	if data.token ~= token then
		return
	end

	local v3 = v2[data.id]

	if not v3 then
		return
	end

	v2[data.id] = nil
	presentationCues:Fire("GemCollect", (math.min(1.3, 1 + (data.amount - 1) * 0.04)))
	v3.gui.Gem.Visible = false
	v3.gui.StackLeft.Visible = false
	v3.gui.StackRight.Visible = false
	v3.gui.Amount.Text = "+" .. data.amount
	v3.gui.Amount.TextColor3 = Color3.fromRGB(215, 255, 236)
	TweenService:Create(v3.gui, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		StudsOffsetWorldSpace = createVector(0, 2.4, 0)
	}):Play()
	TweenService:Create(v3.gui.Amount, TweenInfo.new(0.5), {
		TextTransparency = 1,
		TextStrokeTransparency = 1
	}):Play()
	task.delay(0.55, function()
		v3.part:Destroy()
	end)
end

local onClientEventConnection = gemEvent.OnClientEvent:Connect(function(p, p2)
	if p == "Layout" then
		show(p2)
	elseif p == "Clear" then
		if p2 == nil or p2 == token then
			clear() -- equivalent call inferred; original call site unknown
		end
	elseif p == "Collected" then
		collected(p2)
	end
end)
local renderSteppedConnection = RunService.RenderStepped:Connect(function()
	local now = os.clock()

	for _, v3 in v2 do
		v3.gui.StudsOffsetWorldSpace = Vector3.new(0, math.sin(now * 2 + v3.phase) * 0.23, 0)
	end
end)
local connections = {}

for _, v3 in { "GameRole", "RunState", "InMatch" } do
	table.insert(connections, localPlayer:GetAttributeChangedSignal(v3):Connect(refresh))
end

table.insert(connections, session:GetAttributeChangedSignal("Phase"):Connect(refresh))
table.insert(connections, localPlayer.CharacterRemoving:Connect(clear))
gemEvent:FireServer("Sync")
script.Destroying:Connect(function()
	onClientEventConnection:Disconnect()
	renderSteppedConnection:Disconnect()

	for _, connection in connections do
		connection:Disconnect()
	end

	clear() -- equivalent call inferred; original call site unknown
	folder:Destroy()
end)