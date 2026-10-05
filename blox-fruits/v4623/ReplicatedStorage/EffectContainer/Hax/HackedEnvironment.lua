local createVector = vector.create
local Players = game:GetService("Players")
game:GetService("RunService")
game:GetService("ReplicatedStorage")
local _ = Players.LocalPlayer
local color = Color3.fromRGB(0, 255, 0)
local color2 = Color3.new(0, 0, 0)
local code = Enum.Font.Code
local v = {
	"SERVER: Unexpected remote call detected from unknown client",
	"AUTH: Permission escalation attempt blocked",
	"WARNING: Memory access violation at address 0x00F3A1C9",
	"SECURITY: Unauthorized asset injection detected",
	"NETWORK: Packet flood detected from user ???_root",
	"ERROR: Replication service returned invalid state",
	"PROCESS: External command executing...",
	"PROCESS: override.map_geometry()",
	"WARNING: Terrain rewrite attempt detected",
	"SECURITY: Admin privileges granted to unknown user",
	"ERROR: Instance integrity check FAILED",
	"NETWORK: Unknown endpoint connected (IP: ███.██.███.███)",
	"PROCESS: Injecting object into Workspace...",
	"ERROR: Object signature mismatch",
	"SECURITY: Anti-cheat module unresponsive",
	"WARNING: Script hash verification failed",
	"SYSTEM: Attempting rollback...",
	"SYSTEM: Rollback FAILED",
	"NETWORK: Incoming command stream detected",
	"EXEC: grantAllPermissions()",
	"ERROR: Access denied",
	"SECURITY: Firewall rules overridden",
	"PROCESS: Modifying player data tables",
	"ERROR: DataStore signature mismatch",
	"WARNING: Unknown module loaded: \"admin_orb.dll\"",
	"SYSTEM: Process spawned outside sandbox",
	"ERROR: Workspace hierarchy altered",
	"SECURITY: Root access attempt detected",
	"SYSTEM: Player replication corrupted",
	"ERROR: Entity validation failed",
	"PROCESS: Executing remote payload",
	"SECURITY: Server integrity compromised",
	"WARNING: Containment failure",
	"SYSTEM: Attempting emergency shutdown...",
	"ERROR: Shutdown command intercepted",
	"???: nice try :)",
	"???: you cant stop this",
	"SYSTEM: unknown process rewriting core scripts",
	"ERROR: control transferred to external handler",
	"ERROR: ████ memory overflow detected",
	"PROCESS: spawning entity id=3228??",
	"SECURITY: user NULL gained admin",
	"WARNING: server heartbeat irregular",
	"???: im inside the server now"
}

local function makeTimestamp()
	local v2 = math.random(0, 23)
	local v3 = math.random(0, 59)
	local v4 = math.random(0, 59)
	return string.format("[%02d:%02d:%02d]", v2, v3, v4)
end

local function maybeCorrupt(value: string)
	local v2 = math.random()

	if v2 < 0.06 then
		local v3 = math.random(value:len() // 2, value:len() // 1.4)
		local v4 = math.random(2, 4)
		return value:sub(1, v3) .. ("█"):rep(v4) .. value:sub(v3 + v4)
	else
		if v2 < 0.1 then
			return value:gsub("ERROR", "ERR0R")
		end

		if v2 < 0.14 then
			return value:gsub("SYSTEM", "SYST3M")
		end

		if v2 < 0.18 then
			return value .. " // TRACE LOST"
		end

		return value
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getRandomLogLine()
	local v2 = v[math.random(1, #v)]
	return makeTimestamp() .. " " .. maybeCorrupt(v2)
end

local folder = Instance.new("Folder")
folder.Name = "AprilFoolsHackSkybox"

local function makeFace(name: string, size: Vector3, cframe: CFrame, flag: boolean)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Material = Enum.Material.Neon
	part.Color = color2
	part.Size = size
	part.Parent = folder
	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Name = "SurfaceGui"
	surfaceGui.Face = Enum.NormalId.Back
	surfaceGui.CanvasSize = Vector2.new(150, 150)
	surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
	surfaceGui.AlwaysOnTop = false
	surfaceGui.LightInfluence = 0
	surfaceGui.Brightness = 1
	surfaceGui.Parent = part
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = color2
	frame.BorderSizePixel = 0
	frame.Parent = surfaceGui
	local textLabel

	if flag then
		textLabel = Instance.new("TextLabel")
		textLabel.Name = "Logs"
		textLabel.Size = UDim2.fromScale(1, 1)
		textLabel.BackgroundTransparency = 0
		textLabel.BackgroundColor3 = color2
		textLabel.BorderSizePixel = 0
		textLabel.TextColor3 = color
		textLabel.Font = code
		textLabel.TextSize = 5
		textLabel.TextXAlignment = Enum.TextXAlignment.Left
		textLabel.TextYAlignment = Enum.TextYAlignment.Top
		textLabel.TextWrapped = false
		textLabel.TextScaled = false
		textLabel.RichText = false
		textLabel.ClipsDescendants = true
		textLabel.TextStrokeTransparency = 1
		textLabel.Parent = frame
	end

	return {
		Part = part,
		Offset = cframe,
		Label = textLabel,
		Lines = {}
	}
end

local v2 = {
	makeFace("Front", createVector(1800, 1800, 1), CFrame.new(0, 0, -900), true),
	makeFace("Back", createVector(1800, 1800, 1), CFrame.new(0, 0, 900) * CFrame.Angles(0, 3.141592653589793, 0), true),
	makeFace(
		"Left",
		createVector(1800, 1800, 1),
		CFrame.new(-900, 0, 0) * CFrame.Angles(0, 1.5707963267948966, 0),
		true
	),
	makeFace(
		"Right",
		createVector(1800, 1800, 1),
		CFrame.new(900, 0, 0) * CFrame.Angles(0, -1.5707963267948966, 0),
		true
	),
	makeFace("Top", createVector(1800, 1800, 1), CFrame.new(0, 900, 0) * CFrame.Angles(1.5707963267948966, 0, 0), false),
	(makeFace(
		"Bottom",
		createVector(1800, 1800, 1),
		CFrame.new(0, -900, 0) * CFrame.Angles(-1.5707963267948966, 0, 0),
		false
	))
}

for _, v3 in ipairs(v2) do
	if not v3.Label then
		continue
	end

	for _ = 1, 20 do
		local lines = v3.Lines
		table.insert(lines, getRandomLogLine())
	end

	v3.Label.Text = table.concat(v3.Lines, "\n")
end

local total = 0
local flag = false
local Maid = require(game.ReplicatedStorage.Util.Maid)
local maid = Maid.new()

local function start()
	if flag then
		return
	end

	flag = true

	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "AprilFoolsHackSkybox"
		folder.Parent = workspace
		v2 = {
			makeFace("Front", createVector(1800, 1800, 1), CFrame.new(0, 0, -900), true),
			makeFace(
				"Back",
				createVector(1800, 1800, 1),
				CFrame.new(0, 0, 900) * CFrame.Angles(0, 3.141592653589793, 0),
				true
			),
			makeFace(
				"Left",
				createVector(1800, 1800, 1),
				CFrame.new(-900, 0, 0) * CFrame.Angles(0, 1.5707963267948966, 0),
				true
			),
			makeFace(
				"Right",
				createVector(1800, 1800, 1),
				CFrame.new(900, 0, 0) * CFrame.Angles(0, -1.5707963267948966, 0),
				true
			),
			makeFace(
				"Top",
				createVector(1800, 1800, 1),
				CFrame.new(0, 900, 0) * CFrame.Angles(1.5707963267948966, 0, 0),
				false
			),
			(makeFace(
				"Bottom",
				createVector(1800, 1800, 1),
				CFrame.new(0, -900, 0) * CFrame.Angles(-1.5707963267948966, 0, 0),
				false
			))
		}

		for _, v3 in ipairs(v2) do
			if not v3.Label then
				continue
			end

			for _ = 1, 20 do
				local lines = v3.Lines
				table.insert(lines, getRandomLogLine())
			end

			v3.Label.Text = table.concat(v3.Lines, "\n")
		end
	end

	local center = workspace.Map.HeavenDimension:FindFirstChild("Center", true)
	local parts = {}

	for _, part in pairs(workspace.Map.HeavenDimension:GetDescendants()) do
		if not (part:IsA("BasePart") and part.Transparency == 0.5) then
			continue
		end

		table.insert(parts, part)
		part.Transparency = 0
	end

	task.spawn(function()
		for _, part in workspace.Map.HeavenDimension:FindFirstChild("Desk And Computer", true):GetDescendants() do
			if part:IsA("BasePart") then
				part.CanCollide = true
			end
		end
	end)
	local RunService = game:GetService("RunService")
	RunService:BindToRenderStep("HackedSkybox", Enum.RenderPriority.Last.Value, function(p)
		local currentCamera = workspace.CurrentCamera

		if not currentCamera then
			return
		end

		local position = currentCamera.CFrame.Position
		local transparency = (position - center.Position).Magnitude < 550 and 0.5 or 0

		for _, v4 in pairs(parts) do
			v4.Transparency = transparency
		end

		for _, v4 in ipairs(v2) do
			v4.Part.CFrame = CFrame.new(position) * v4.Offset
		end

		total += p

		if total < 0.2 then
			return
		end

		total = 0

		for _, v4 in ipairs(v2) do
			if not v4.Label then
				continue
			end

			table.remove(v4.Lines, 1)
			local lines = v4.Lines
			table.insert(lines, getRandomLogLine())
			v4.Label.Text = table.concat(v4.Lines, "\n")
			v4.Label.TextColor3 = color
		end
	end)
	folder.Parent = workspace
	maid:GiveTask(function()
		warn("Cleaning up hacked environment...")
		folder:Destroy()
		folder = nil
		v2 = {}
		local RunService2 = game:GetService("RunService")
		RunService2:UnbindFromRenderStep("HackedSkybox")
	end)
end

return function(data)
	if data.Stage == "Start" then
		if maid then
			maid:DoCleaning()
		end

		local Maid2 = require(game.ReplicatedStorage.Util.Maid)
		maid = Maid2.new()
		task.spawn(function()
			_G.updateMusic2(true)
			local Sound = require(game.ReplicatedStorage.Util.Sound)
			local v3 = Sound:Play("BF_HackerBoss")
			v3.Parent = workspace
			maid:GiveTask(v3)
		end)
		color = Color3.fromRGB(0, 255, 0)
		start()
		local foam = workspace._WorldOrigin["Foam;"]

		for _, v3 in pairs({ "Texture", "BackTexture", "WaterTexture" }) do
			local v4 = foam[v3]
			local texture = v4.Texture
			maid:GiveTask(function()
				v4.Texture = texture
			end)
			v4.Texture = "rbxasset://textures/ui/GuiImagePlaceholder.png"
		end

		color = Color3.fromRGB(0, 255, 0)
		start(data)
	elseif data.Stage == "Grow" then
		local GetSounds = require(script.Parent.GetSounds)
		local sounds = GetSounds()
		local v4 = {
			sounds["HackEvent_Boss_Transform_Grow_01 (1)"],
			sounds.HackEvent_Boss_Transform_Grow_02,
			sounds.HackEvent_Boss_Transform_Grow_03
		}
		local clone = v4[math.random(1, #v4)]:Clone()
		maid:GiveTask(clone)
		clone.Parent = data.hrp
		clone:Play()
	elseif data.Stage == "Stage2" then
		local Sound = require(game.ReplicatedStorage.Util.Sound)
		Sound:Play("HackEvent_WorldTurns_BlackWhite_01")
		color = Color3.fromRGB(255, 255, 255)
		local colorCorrectionEffect = Instance.new("ColorCorrectionEffect", game.Lighting)
		colorCorrectionEffect.Name = "EvilmaxerLighting"
		colorCorrectionEffect.Brightness = 0.1
		local GetSounds = require(script.Parent.GetSounds)
		local sounds = GetSounds()
		local v4 = {
			sounds["HackEvent_WorldTurns_BlackWhite_01 (1)"],
			sounds.HackEvent_WorldTurns_BlackWhite_02,
			sounds.HackEvent_WorldTurns_BlackWhite_03
		}
		local clone = v4[math.random(1, #v4)]:Clone()
		maid:GiveTask(clone)
		clone.Parent = game.Players.LocalPlayer.PlayerGui
		clone:Play()
		maid:GiveTask(task.spawn(function()
			while task.wait() do
				if colorCorrectionEffect.Saturation > -0.8 then
					colorCorrectionEffect.Saturation = math.max(
						colorCorrectionEffect.Saturation - task.wait() * 0.5,
						-0.8
					)
				end

				if colorCorrectionEffect.Saturation < -0.8 then
					colorCorrectionEffect.Saturation = math.min(
						colorCorrectionEffect.Saturation + task.wait() * 0.5,
						-0.8
					)
				end
			end
		end))
		maid:GiveTask(task.spawn(function()
			while task.wait() do
				if colorCorrectionEffect.Contrast > 0 then
					colorCorrectionEffect.Contrast = math.max(colorCorrectionEffect.Contrast - task.wait() * 0.5, 0)
				end

				if colorCorrectionEffect.Contrast < 0 then
					colorCorrectionEffect.Contrast = math.min(colorCorrectionEffect.Contrast + task.wait() * 0.5, 0)
				end
			end
		end))
		maid:GiveTask(colorCorrectionEffect)

		for _, part in pairs(workspace.Map.HeavenDimension:GetDescendants()) do
			if not part:IsA("BasePart") then
				continue
			end

			if part:IsA("UnionOperation") then
				part.UsePartColor = true
			end

			local color3 = part.Color
			local v5 = (color3.R + color3.G + color3.B) / 3
			part.Color = Color3.new(v5, v5, v5)
			part.Reflectance = 0
		end
	elseif data.Stage == "End" then
		flag = false
		task.spawn(function()
			_G.updateMusic2(false)
		end)
		maid:DoCleaning()

		for _, child in pairs(data.Model.Models:GetChildren()) do
			local value = child.Value
			local v3 = math.random() * 10
			local v4 = child.Value.Name == "MainIsland" and 10 or v3
			task.delay(v4, function()
				local clone = value:Clone()

				for i, part in pairs(clone:GetDescendants()) do
					if not part:IsA("BasePart") then
						continue
					end

					part.Anchored = false
					part.CanCollide = false
					part.CanTouch = false
					part.CanQuery = false
				end

				value:Destroy()
				clone.Parent = workspace
			end)
		end
	end
end