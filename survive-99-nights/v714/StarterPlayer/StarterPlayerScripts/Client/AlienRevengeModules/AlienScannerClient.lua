local AlienScannerClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local TweenService = game:GetService("TweenService")
local v = {
	5,
	25,
	50,
	90,
	1e999
}
local v2 = {
	{
		Transparency = 0.5,
		Duration = 5
	},
	{
		Transparency = 0.7,
		Duration = 3
	},
	{
		Transparency = 0.85,
		Duration = 2
	},
	{
		Transparency = 0.9,
		Duration = 1
	}
}
local color = Color3.fromRGB(0, 255, 0)
local v3 = {
	Color3.fromRGB(255, 48, 48),
	Color3.fromRGB(255, 140, 0),
	Color3.fromRGB(255, 221, 0),
	Color3.fromRGB(173, 255, 47),
	Color3.fromRGB(60, 220, 60)
}
local v4 = {
	"BAD",
	"OK",
	"GOOD",
	"GREAT",
	"STRONG"
}
local v5 = nil
local v6 = 0
local count = 0
local v7 = nil
local v8 = {}
local flag = false
local count2 = 0
local v9 = false
local v10 = nil
local levelChangedConnection = nil
local childAddedConnection = nil
local v11 = nil
local visible = nil

function UpdateScannerSignal()
	local v12 = math.clamp(v5 and v5:GetAttribute("Level") or 1, 1, 5)
	local mapHolder = Client.Interface.MapHolder
	mapHolder.AliensRevenge.SignalText.TextColor3 = v3[v12]
	mapHolder.AliensRevenge.BatteriesText.TextColor3 = v3[v12]
	mapHolder.AliensRevenge.SignalText.Text = "SIGNAL:\n" .. v4[v12]
	mapHolder.AliensRevenge.BatteriesText.Text = "BATTERIES: " .. v12 .. " / 5"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ScannerKeepVisible(instance, p)
	if p[instance] or instance:FindFirstChild("Radar") then
		return true
	end

	return instance:GetAttribute("StructureName") == "Crashed UFO Repairable"
end

local function HideNonAlienMapIcons()
	local v12 = {}
	local parent = nil

	for _, v13 in pairs(Client.MapDrawClient.GetAlienMapIcons()) do
		v12[v13] = true

		if v13.Parent then
			parent = v13.Parent
		end
	end

	if not parent then
		return
	end

	v11 = parent

	-- equivalent calls inferred from this helper; original call sites unknown
	local function hide(instance, p)
		if ScannerKeepVisible(instance, p) then
			return
		end

		if instance:GetAttribute("ScannerHiddenZ") == nil then
			instance:SetAttribute("ScannerHiddenZ", instance.ZIndex)
			instance.ZIndex = -1
		end
	end

	for _, child in pairs(parent:GetChildren()) do
		if v12[child] or child:FindFirstChild("Radar") or child:GetAttribute("StructureName") == "Crashed UFO Repairable" or child:GetAttribute("ScannerHiddenZ") ~= nil then
			continue
		end

		child:SetAttribute("ScannerHiddenZ", child.ZIndex)
		child.ZIndex = -1
	end

	if childAddedConnection then
		childAddedConnection:Disconnect()
	end

	childAddedConnection = parent.ChildAdded:Connect(function(child)
		task.defer(function()
			if not flag then
				return
			end

			local v13 = {}

			for _, v14 in pairs(Client.MapDrawClient.GetAlienMapIcons()) do
				v13[v14] = true
			end

			hide(child, v13) -- equivalent call inferred; original call site unknown
		end)
	end)
end

local function RestoreNonAlienMapIcons()
	if childAddedConnection then
		childAddedConnection:Disconnect()
		childAddedConnection = nil
	end

	if v11 then
		for _, child in pairs(v11:GetChildren()) do
			local scannerHiddenZ = child:GetAttribute("ScannerHiddenZ")

			if scannerHiddenZ == nil then
				continue
			end

			child.ZIndex = scannerHiddenZ
			child:SetAttribute("ScannerHiddenZ", nil)
		end

		v11 = nil
	end
end

function AlienScannerClient.OpenScanner(instance)
	v5 = instance
	flag = true
	Client.MapDrawClient.OpenAlienScanner()
	HideNonAlienMapIcons()
	local alienTV = Client.Interface.MapHolder.AliensRevenge.AlienTV
	alienTV.ImageLabel.Position = UDim2.new(0, 0, -1, 0)
	alienTV.Visible = true

	if v10 then
		v10:Cancel()
	end

	v10 = TweenService:Create(
		alienTV.ImageLabel,
		TweenInfo.new(30, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false, 0),
		{
			Position = UDim2.new(0, 0, 0, 0)
		}
	)
	v10:Play()
	local mapHolder = Client.Interface.MapHolder
	mapHolder.AliensRevenge.SignalText.Visible = true
	mapHolder.AliensRevenge.BatteriesText.Visible = true
	mapHolder.AliensRevenge.AlienScanButton.Visible = true
	visible = mapHolder.Guide.Visible
	mapHolder.Guide.Visible = false
	UpdateScannerSignal()

	if levelChangedConnection then
		levelChangedConnection:Disconnect()
	end

	if v5 then
		levelChangedConnection = v5:GetAttributeChangedSignal("Level"):Connect(UpdateScannerSignal)
	end

	count2 += 1
	local v12 = count2
	task.spawn(function()
		while flag and count2 == v12 do
			local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart and instance and instance:IsDescendantOf(workspace) and (humanoidRootPart.Position - instance:GetPivot().Position).Magnitude > 30 then
				Client.MapDrawClient.CloseMap()
				break
			else
				task.wait(0.25)
			end
		end
	end)

	if not v9 then
		v9 = true
		task.spawn(function()
			local v13 = {
				mapHolder.AliensRevenge.AlienScanButton,
				mapHolder.AliensRevenge.BatteriesText,
				mapHolder.AliensRevenge.SignalText
			}

			for _ = 1, 5 do
				if not flag or count2 ~= v12 then
					break
				end

				for _, v14 in ipairs(v13) do
					v14.Visible = false
				end

				task.wait(0.1)

				if not flag or count2 ~= v12 then
					break
				end

				for _, v14 in ipairs(v13) do
					v14.Visible = true
				end

				task.wait(0.1)
			end

			if flag and count2 == v12 then
				for _, v14 in ipairs(v13) do
					v14.Visible = true
				end
			end
		end)
	end
end

function FadeIcon(p, imageTransparency, p2, p3)
	p.Visible = true
	p.ImageTransparency = imageTransparency

	if p2 == 1e999 then
		Client.MapDrawClient.RevealAlienSpot(p)
		return
	end

	v8[p] = p3
	local backgroundTransparency = math.max(imageTransparency, 0.3)
	p.BackgroundColor3 = color
	p.BackgroundTransparency = backgroundTransparency
	task.spawn(function()
		local v13 = 0

		while v13 < p2 do
			local v14 = task.wait()

			if v8[p] ~= p3 or p3 ~= count then
				return
			end

			if Client.MapDrawClient.IsAlienIconFound(p) then
				p.Visible = true
				p.ImageTransparency = 0
				p.BackgroundTransparency = 1
				v8[p] = nil
				return
			else
				v13 = math.min(v13 + v14, p2)
				p.ImageTransparency = imageTransparency + (1 - imageTransparency) * (v13 / p2)
				p.BackgroundTransparency = backgroundTransparency + (1 - backgroundTransparency) * math.min(
					v13 / 1.5,
					1
				)
			end
		end

		if v8[p] == p3 then
			p.ImageTransparency = 0
			p.BackgroundTransparency = 1
			p.Visible = false
			v8[p] = nil
		end
	end)
end

function ResetRadarIcons()
	for k in pairs(v8) do
		if not k or not k.Parent or Client.MapDrawClient.IsAlienIconFound(k) then
			continue
		end

		k.Visible = false
		k.ImageTransparency = 0
	end

	v8 = {}
end

function AlienScannerClient.Scan()
	local now = os.clock()

	if now - v6 < 1 then
		return
	end

	v6 = now
	local alienScanButton = Client.Interface.MapHolder.AliensRevenge.AlienScanButton
	alienScanButton.Visible = false
	count += 1
	local v12 = count
	ResetRadarIcons()

	if v7 then
		Client.Events.StopSound:Fire("AlienRadar")
		v7:Destroy()
		v7 = nil
	end

	local v13 = math.clamp(v5 and v5:GetAttribute("Level") or 1, 1, 5)
	local v14 = 7 - v13
	local v15 = {}
	local v16 = {}

	for _, icon in pairs(Client.MapDrawClient.GetAlienMapIcons()) do
		if Client.MapDrawClient.IsAlienIconFound(icon) then
			continue
		end

		local v18 = icon.Position.X.Scale - 0.5
		local v19 = icon.Position.Y.Scale - 0.5
		local iconZone = Client.MapDrawClient.GetIconZone(icon)
		table.insert(v15, {
			Icon = icon,
			Dist = math.sqrt(v18 * v18 + v19 * v19),
			Zone = iconZone
		})
		v16[iconZone] = true
	end

	local v17 = {}

	for k in pairs(v16) do
		table.insert(v17, k)
	end

	table.sort(v17)
	local v18 = {}

	for i = 1, #v17 do
		v18[v17[i]] = i
	end

	for _, v19 in pairs(v15) do
		local v20 = v18[v19.Zone]

		if v20 <= v13 then
			v19.Peak = 0.35
			v19.Duration = v[v13]
		else
			local v21 = math.min(v20 - v13, #v2)
			v19.Peak = v2[v21].Transparency
			v19.Duration = v2[v21].Duration
		end
	end

	local clone = Client.Interface.MapHolder.AliensRevenge.AlienRadar:Clone()
	clone.Size = UDim2.new(0, 0, 0, 0)
	clone.Visible = true
	clone.Parent = Client.Interface.MapHolder.AliensRevenge
	v7 = clone
	local uIStroke = clone:FindFirstChildWhichIsA("UIStroke")
	Client.Sound.Play("AlienRadar")
	task.spawn(function()
		local v19 = 0

		while v19 < v14 do
			local v20 = task.wait()

			if v12 ~= count or v7 ~= clone then
				return
			end

			v19 = math.min(v19 + v20, v14)
			local transparency = v19 / v14
			clone.Size = UDim2.new(transparency, 0, transparency, 0)

			if uIStroke then
				uIStroke.Thickness = 0.015 / math.max(transparency, 0.05)
				uIStroke.Transparency = transparency
			end

			local v22 = transparency / 2

			for i = 1, #v15 do
				local v23 = v15[i]

				if v23.Swept or not (v23.Dist <= v22) then
					continue
				end

				v23.Swept = true
				Client.Sound.Play("AlienRadarFound", {
					Duplicate = true
				})
				FadeIcon(v23.Icon, v23.Peak, v23.Duration, v12)
			end
		end

		if v7 == clone then
			Client.Events.StopSound:Fire("AlienRadar")
			clone:Destroy()
			v7 = nil

			if flag then
				alienScanButton.Visible = true
			end
		end
	end)
end

function AlienScannerClient.CloseScannerView()
	flag = false
	RestoreNonAlienMapIcons()

	if v7 then
		v7:Destroy()
		v7 = nil
	end

	if v10 then
		v10:Cancel()
		v10 = nil
	end

	Client.Interface.MapHolder.AliensRevenge.AlienTV.Visible = false
	Client.Interface.MapHolder.AliensRevenge.SignalText.Visible = false
	Client.Interface.MapHolder.AliensRevenge.BatteriesText.Visible = false

	if visible ~= nil then
		Client.Interface.MapHolder.Guide.Visible = visible
		visible = nil
	end

	if levelChangedConnection then
		levelChangedConnection:Disconnect()
		levelChangedConnection = nil
	end

	Client.Events.StopSound:Fire("AlienRadar")
end

function AlienScannerClient.Init()
	task.spawn(function()
		local mapHolder = Client.Interface.MapHolder
		mapHolder.AliensRevenge:WaitForChild("AlienScanButton").Activated:Connect(function()
			AlienScannerClient.Scan()
		end)
		local alienTV = mapHolder.AliensRevenge:WaitForChild("AlienTV")
		alienTV.ClipsDescendants = true
		alienTV.Visible = false
		alienTV.ZIndex = 30
		alienTV.ImageLabel.ZIndex = 30
		alienTV.ImageLabel.Size = UDim2.new(1, 0, 2, 0)
	end)
end

return AlienScannerClient