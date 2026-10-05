local createVector = vector.create
local v = {
	{
		createVector(28733, 14888.381, -65),
		createVector(28733, 14888.381, -65),
		createVector(28733, 14886.381, -18),
		createVector(28771, 14887.381, -13),
		70.41272
	},
	{
		createVector(28771, 14887.381, -13),
		createVector(28786, 14887.381, -9),
		createVector(28851, 14884.381, -18),
		createVector(28852, 14891.381, 19),
		95.8292
	},
	{
		createVector(28852, 14891.381, 19),
		createVector(28855, 14896.381, 43),
		createVector(28902, 14891.381, 34),
		createVector(28906, 14889.381, 27),
		63.4656
	},
	{
		createVector(28906, 14889.381, 27),
		createVector(28925, 14883.381, 8),
		createVector(28906, 14889.381, -49),
		createVector(28936, 14889.381, -80),
		113.7079
	},
	{
		createVector(28936, 14889.381, -80),
		createVector(28953, 14889.381, -99),
		createVector(29000, 14892.381, -87),
		createVector(29045, 14892.381, -86),
		111.7155
	},
	{
		createVector(29045, 14892.381, -86),
		createVector(29079, 14900.381, -86),
		createVector(29321, 15065.381, -86),
		createVector(29379, 15072.381, -86),
		380.2256
	},
	{
		createVector(29379, 15072.381, -86),
		createVector(29429, 15074.381, -86),
		createVector(29545, 15072.381, -86),
		createVector(29545, 15072.381, -86),
		165.5368
	}
}
local v2 = {
	{ createVector(28733, 14885.381, -65), 1, 0 },
	{ createVector(28893.139, 14891.64, 32.895), 3, 0.7 },
	{ createVector(28949.543, 14889.692, -88.016), 5, 0.2 },
	{ createVector(29045.125, 14892.41, -86), 6, 0 },
	{ createVector(29379, 15072.381, -86), 7, 0 },
	{ createVector(29545, 15072.381, -86), 7, 1 }
}
local v3 = {
	{
		createVector(28858.514, 14890.259, -210.975),
		createVector(28866.695, 14888.878, -142.12),
		createVector(28752.143, 14888.377, -115.155),
		createVector(28691.152, 14888.377, -114.108),
		createVector(28707.992, 14887.397, -65.399),
		createVector(28692.783, 14886.476, -19.141),
		createVector(28693.83, 14885.255, 41.837),
		createVector(28744.729, 14887.697, -81.029)
	},
	{
		createVector(28768.291, 14887.313, -13.526),
		createVector(28819.455, 14886.789, -8.878),
		createVector(28792.383, 14886.971, -11.416),
		createVector(28747.533, 14886.949, -24.835),
		createVector(28884.268, 14892.554, 34.297),
		createVector(28737.107, 14887.025, -42.716),
		createVector(28733.004, 14887.376, -64.829),
		createVector(28846.125, 14888.569, 3.551),
		createVector(28857.207, 14893.142, 28.705),
		createVector(28860.984, 14887.376, -67.026),
		createVector(28870.248, 14884.735, 64.807),
		createVector(28860.984, 14887.376, -29.216),
		createVector(28813.799, 14887.376, -39.897),
		createVector(28860.984, 14887.376, -110.174)
	},
	{
		createVector(28900.365, 14890.638, 30.663),
		createVector(28911.463, 14887.676, 18.162),
		createVector(28915.453, 14886.726, -1.401),
		createVector(28917.107, 14887.253, -25.093),
		createVector(28920.605, 14888.392, -49.841),
		createVector(28930.121, 14889.278, -72.573)
	},
	{
		createVector(28966.129, 14890.331, -90.483),
		createVector(28995.238, 14891.429, -89.541),
		createVector(29021.373, 14892.133, -87.317)
	},
	{
		createVector(29277.494, 15026.198, -86),
		createVector(29192.27, 14976.304, -86),
		createVector(29112.273, 14928.18, -86),
		createVector(29080.123, 14909.507, -86),
		createVector(29349.139, 15062.742, -86),
		createVector(29235.406, 15001.975, -86),
		createVector(29150.445, 14951.077, -86),
		createVector(29316.191, 15047.083, -86)
	},
	{
		createVector(29533.184, 15072.384, -86),
		createVector(29399.29, 15072.772, -86),
		createVector(29472.93, 15072.458, -86),
		createVector(29431.545, 15072.594, -86)
	}
}
local v4 = v[1][1] + createVector(0, 30, 0)
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DialoguesList = require(ReplicatedStorage:WaitForChild("DialoguesList"))
local DialogueController = require(ReplicatedStorage:WaitForChild("DialogueController"))
local CameraShaker = require(game.ReplicatedStorage.Util.CameraShaker)
local Main = require(game.ReplicatedStorage.Util.CameraShaker.Main)
local Sound = require(game.ReplicatedStorage.Util.Sound)
local Maid = require(game.ReplicatedStorage.Util.Maid)
local Signal2 = require(game.ReplicatedStorage.Util.Signal2)
local WaitForStream = require(game.ReplicatedStorage.Util.WaitForStream)
local templeofTime = workspace.Map:WaitForChild("Temple of Time", 10)

if not templeofTime then
	return
end

local clockRoomExit = WaitForStream[templeofTime].ClockRoomExit()

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function CubicBezier(p, p2, p3, p4, p5)
	return p2 * (1 - p) ^ 3 + p3 * 3 * p * (1 - p) ^ 2 + p4 * 3 * (1 - p) * p ^ 2 + p5 * p ^ 3
end

function CheckNextCheckpoint(p)
	local position = game.Players.LocalPlayer.Character.PrimaryPart.Position
	local v5 = { 1e999 }

	for i = p, #v3 do
		for _, v6 in pairs(v3[i]) do
			local magnitude = (v6 - position).Magnitude

			if magnitude < v5[1] then
				v5 = { magnitude, i }
			end
		end
	end

	for i = p, #v2 do
		local magnitude = (v2[i][1] - position).Magnitude

		if magnitude < 15 then
			if i == p then
				v5[2] += 1
				break
			end
		elseif magnitude < v5[1] then
			v5 = { magnitude, i }
		end
	end

	return v5[2] or p
end

function DespawnMote(instance, maid)
	local maid2 = Maid.new()
	maid:GiveTask(maid2)
	local v5 = Signal2.new()
	local proximityPrompt = Instance.new("ProximityPrompt", instance)
	proximityPrompt:AddTag("ProximityPrompt")
	local validClockRoom = game.Players.LocalPlayer.Character.ValidClockRoom
	maid2:GiveTask(proximityPrompt)
	maid2:GiveTask(proximityPrompt.Triggered:Connect(function()
		v5:Fire(true)
	end))
	maid2:GiveTask(validClockRoom:GetPropertyChangedSignal("Parent"):Connect(function()
		if not validClockRoom.Parent then
			v5:Fire(false)
		end
	end))
	maid2:GiveTask(game.Players.LocalPlayer.CharacterAdded:Connect(function()
		v5:Fire(false)
	end))
	maid2:GiveTask(function()
		clockRoomExit.CanCollide = true
		clockRoomExit.CanTouch = true
	end)

	if v5:Wait() then
		maid2:DoCleaning()
		local clone = game.ReplicatedStorage.Assets.Models.Gear1:Clone()
		clone.CFrame = instance.CFrame
		local RunService = game:GetService("RunService")
		RunService:BindToRenderStep("GearFaceCamera", Enum.RenderPriority.Last.Value + 100, function()
			clone.CFrame = CFrame.new(clone.Position, workspace.CurrentCamera.CFrame.Position) * CFrame.Angles(
				1.5707963267948966,
				0,
				0
			)
		end)
		local tween = TweenService:Create(instance, TweenInfo.new(2), {
			CFrame = instance.CFrame * CFrame.new(0, instance.Size.Y, 0)
		})
		TweenService:Create(instance.BillboardGui.ImageLabel, TweenInfo.new(2), {
			Size = UDim2.fromScale(3, 3)
		}):Play()
		tween:Play()
		tween.Completed:Wait()
		task.wait(0.5)
		clone.Parent = workspace
		pcall(function()
			TweenService:Create(instance.BillboardGui.ImageLabel, TweenInfo.new(0.5), {
				Size = UDim2.fromScale(0, 0)
			}):Play()
		end)
		task.wait(1.5)
		local tween2 = TweenService:Create(clone, TweenInfo.new(1), {
			Transparency = 1,
			Size = clone.Size * 1.5
		})
		tween2:Play()
		tween2.Completed:Wait()
		clone:Destroy()
		pcall(function()
			instance:Destroy()
		end)
		pcall(function()
			local RunService2 = game:GetService("RunService")
			RunService2:UnbindFromRenderStep("GearFaceCamera")
		end)
		workspace.Map["Temple of Time"].Prompt.ProximityPrompt.Enabled = true
		maid:DoCleaning()
	else
		pcall(function()
			instance:Destroy()
		end)
		maid:DoCleaning()
	end
end

function PathMote(p)
	local maid = Maid.new()
	maid:GiveTask(function()
		TweenService:Create(game.Lighting.TrialDeath, TweenInfo.new(2), {
			Contrast = 0,
			Saturation = 0,
			TintColor = Color3.fromRGB(255, 255, 255)
		}):Play()
		workspace._WorldOrigin.Locations["Temple of Time"].Sound:SetAttribute("SoundId", "rbxassetid://1839022912")
		workspace.Map["Temple of Time"].Prompt.ProximityPrompt.Enabled = true
	end)
	maid:GiveTask(game.Players.LocalPlayer.CharacterAdded:Connect(function()
		maid:DoCleaning()
	end))
	maid:GiveTask(game.Players.LocalPlayer.Character.ChildRemoved:Connect(function(child)
		if child.Name == "ValidClockRoom" then
			maid:DoCleaning()
		end
	end))
	maid:GiveTask(p)
	maid:GiveTask(function()
		clockRoomExit.CanCollide = true
		clockRoomExit.CanTouch = true
		clockRoomExit.Transparency = 0
	end)
	workspace._WorldOrigin.Locations["Temple of Time"].Sound:SetAttribute("SoundId", "rbxassetid://1837252595")
	p.Trail.Enabled = true
	p.CanQuery = true
	clockRoomExit.Transparency = 1
	clockRoomExit.CanCollide = false
	clockRoomExit.CanTouch = false
	local v5 = Sound:Play("WindBlowing", p, 400)
	local tween = TweenService:Create(p, TweenInfo.new(2, Enum.EasingStyle.Linear), {
		CFrame = CFrame.new(v[1][1])
	})
	tween:Play()
	tween.Completed:Wait()
	Sound:FadeOut(v5, 1)
	CameraShaker:StopSustained(1)
	local v6 = 1
	local v7 = { 1, 0 }
	pcall(function()
		local RunService = game:GetService("RunService")
		RunService:UnbindFromRenderStep("FFAPathfinding")
	end)
	local RunService = game:GetService("RunService")
	RunService:BindToRenderStep("FFAPathfinding", Enum.RenderPriority.Last.Value + 100, function(p2)
		if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("ValidClockRoom") then
			local v8 = v2[v6]

			if v8 then
				if v7[1] == v8[2] and v7[2] < v8[3] or v7[1] < v8[2] then
					local v9 = v7[2] + p2 * 1 * (100 / v[v7[1]][5])

					if v7[1] == v8[2] and v8[3] < v9 then
						v9 = v8[3]
					end

					if v9 > 1 then
						if v7[1] + 1 > v8[2] or not v[v7[1] + 1] then
							v9 = 1
						else
							v9 -= 1
							v7[1] += 1
						end
					end

					local v10, v11, v12, v13 = unpack(v[v7[1]])
					local cubicBezier = CubicBezier(v9, v10, v11, v12, v13)
					p.CFrame = CFrame.new(cubicBezier)
					v7[2] = v9
				end

				v6 = CheckNextCheckpoint(v6)
			else
				pcall(function()
					local RunService2 = game:GetService("RunService")
					RunService2:UnbindFromRenderStep("FFAPathfinding")
				end)
				p.CFrame = CFrame.new(29545, 15072.380859375, -86)
				DespawnMote(p, maid)
			end
		else
			task.delay(4, function()
				maid:DoCleaning()
			end)
			pcall(function()
				local RunService2 = game:GetService("RunService")
				RunService2:UnbindFromRenderStep("FFAPathfinding")
			end)
		end
	end)
end

function AbsorbMote(position, instance, p)
	local clone = game.ReplicatedStorage.Assets.Models.Mote:Clone()
	clone.BillboardGui.ImageLabel.Size = UDim2.fromScale(0.3, 0.3)
	clone.CFrame = CFrame.new(position)
	clone.Parent = workspace

	for _, attachment in pairs(clone:GetChildren()) do
		if attachment:IsA("Attachment") then
			attachment.Position *= 0.3
		end
	end

	task.spawn(function()
		local magnitude = (position - instance.Position).Magnitude
		local v5 = position
		local position2 = (CFrame.new(position, instance.Position) * CFrame.new(0, 10, -magnitude * 0.5)).Position
		local position3 = (CFrame.new(instance.Position, position) * CFrame.new(0, 10, -magnitude * 0.5)).Position
		local position4 = instance.Position
		local v6 = 0

		while v6 < 1 do
			v6 = math.min(v6 + task.wait() * 0.6, 1)
			clone.CFrame = CFrame.new(CubicBezier(v6, v5, position2, position3, position4))
		end

		clone:Destroy()
		local total = 0

		while total < 1 do
			local v7 = task.wait()

			if total + v7 > 1 then
				v7 = 1 - total
			end

			if instance and instance:FindFirstChild("MoteSize") then
				instance.MoteSize.Value += v7 / p
				total += v7
			else
				break
			end
		end
	end)
end

function SpawnMote(p)
	workspace.Map["Temple of Time"].Prompt.ProximityPrompt.Enabled = false
	local clone = game.ReplicatedStorage.Assets.Models.Mote:Clone()
	clone.Parent = workspace
	clone.CFrame = CFrame.new(v4)
	clone.BillboardGui.ImageLabel.ImageColor3 = Color3.fromRGB(0, 0, 0)
	clone.Trail.Enabled = false
	clone.MoteSize.Changed:Connect(function(p2)
		clone.BillboardGui.ImageLabel.ImageColor3 = Color3.fromRGB(0, 0, 0):lerp(Color3.fromRGB(255, 255, 255), p2)
	end)
	CameraShaker:ShakeSustain(Main.Presets.Bump2)
	task.delay(3, function()
		CameraShaker:StopSustained(1)
	end)

	while true do
		local v5, v6 = game.ReplicatedStorage.Remotes.Temple.OnClientEvent:Wait()

		if v5 == "End" then
			break
		end

		if v5 == "Kill" then
			AbsorbMote(v6, clone, p)
		elseif v5 == "Winner" then
			CameraShaker:ShakeSustain(Main.Presets.Bump4)
			game.Lighting.TrialDeath.Enabled = true
			game.Lighting.TrialDeath.Contrast = 0
			game.Lighting.TrialDeath.Saturation = 0
			game.Lighting.TrialDeath.TintColor = Color3.fromRGB(255, 255, 255)
			TweenService:Create(game.Lighting.TrialDeath, TweenInfo.new(2), {
				Contrast = -0.3,
				Saturation = 0.3,
				TintColor = Color3.new(1, 1.83, 1.82)
			}):Play()

			if clone.MoteSize.Value < 0.9999 then
				repeat
					clone.MoteSize.Changed:Wait()
				until clone.MoteSize.Value >= 0.9999
			end

			task.wait(1)
			PathMote(clone)
			return
		end
	end

	workspace.Map["Temple of Time"].Prompt.ProximityPrompt.Enabled = true
	clone:Destroy()
end

game.ReplicatedStorage.Remotes.Temple.OnClientEvent:Connect(function(p, p2)
	if p == "Start" then
		local Global = require(game.ReplicatedStorage.Global)
		local encoded = Global.Encode(p2)
		SpawnMote(encoded)
	end
end)
local flag = false
clockRoomExit.Touched:Connect(function(otherPart)
	if flag then
		return
	end

	if otherPart.Parent == game.Players.LocalPlayer.Character then
		flag = true
		DialogueController.start(DialoguesList.ClockRoomExit)
		flag = false
	end
end)