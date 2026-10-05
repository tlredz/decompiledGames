local createVector = vector.create

if not workspace:WaitForChild("_WorldOrigin"):WaitForChild("Locations"):WaitForChild("Floating Turtle", 10) then
	return
end

local function fn(...) end

local commF_ = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
workspace:WaitForChild("Map")
local TweenService = game:GetService("TweenService")
local WaitFor = require(game.ReplicatedStorage.Util.WaitFor)
local waitFor = WaitFor(workspace.Map, "Turtle", "Cursed")
local cFrame = WaitFor(waitFor, "BossDoor").CFrame
local _ = WaitFor(waitFor, "PlacedGem").CFrame
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DialoguesList = require(game.ReplicatedStorage:WaitForChild("DialoguesList"))
local DialogueController = require(ReplicatedStorage:WaitForChild("DialogueController"))
local InstanceWatch = require(ReplicatedStorage.Util.InstanceWatch)
local v2 = nil

if not game.Players.LocalPlayer.Character then
	game.Players.LocalPlayer.CharacterAdded:Wait()
end

repeat
	task.wait(1)
	pcall(function()
		v2 = commF_:InvokeServer("CDKQuest", "Progress")
	end)
until v2

local v3 = nil
local v4 = {
	Pedestal1 = false,
	Pedestal2 = false,
	Pedestal3 = false,
	GoodScroll = false,
	EvilScroll = false,
	PlacedGem = false,
	Breakable = false,
	EntranceTouch = false,
	WaitForChild = function(self, p)
		return v3[p]
	end
}
coroutine.running()
v3 = InstanceWatch.new(workspace.Map.Turtle, "Cursed"):CollectDictionaryAsync(
	"Pedestal1",
	"Pedestal2",
	"Pedestal3",
	"GoodScroll",
	"EvilScroll",
	"ShatteredGem",
	"BossDoor",
	"PlacedGem",
	"EntranceTouch",
	"HealedGem",
	"WholeGem",
	"Smoke2",
	"Smoke"
)
v4.Breakable = workspace.Map.Turtle.Cursed:FindFirstChild("Breakable")

for k, v5 in pairs(v3) do
	v4[k] = v5
end

fn(v2)

if v2.Finished then
	fn("progress fin")
	local proximityPrompt = v4.Pedestal1:WaitForChild("ProximityPrompt")
	proximityPrompt.Enabled = false
	local proximityPrompt_2 = v4.Pedestal2:WaitForChild("ProximityPrompt")
	proximityPrompt_2.Enabled = false
	local proximityPrompt_3 = v4.Pedestal3:WaitForChild("ProximityPrompt")
	proximityPrompt_3.Enabled = false
	v4.GoodScroll:Destroy()
	v4.EvilScroll:Destroy()
	v4.Pedestal3:Destroy()
	v4.PlacedGem.Transparency = 0

	if v4.Breakable then
		v4.Breakable:Destroy()
	end
else
	if v2.Good == 4 then
		fn("good 4")
		local proximityPrompt_4 = v4:WaitForChild("Pedestal1"):WaitForChild("ProximityPrompt")
		proximityPrompt_4.Enabled = false
		v4:WaitForChild("GoodScroll"):Destroy()
	end

	if v2.Evil == 4 then
		fn("evil 4")
		local proximityPrompt_5 = v4:WaitForChild("Pedestal2"):WaitForChild("ProximityPrompt")
		proximityPrompt_5.Enabled = false
		v4:WaitForChild("EvilScroll"):Destroy()
	end

	if v2.Good == 4 and v2.Evil == 4 then
		fn("enableprompt 3")
		local proximityPrompt_6 = v4:WaitForChild("Pedestal3"):WaitForChild("ProximityPrompt")
		proximityPrompt_6.Enabled = true
	else
		fn("disableprompt 3")
		local proximityPrompt_7 = v4:WaitForChild("Pedestal3"):WaitForChild("ProximityPrompt")
		proximityPrompt_7.Enabled = false
	end

	if v2.Opened then
		fn("open")
		pcall(function()
			v4:WaitForChild("Breakable", 10):Destroy()
		end)
	end

	v4:WaitForChild("Pedestal1"):WaitForChild("ProximityPrompt").Triggered:Connect(function()
		local proximityPrompt = v4:WaitForChild("Pedestal1"):WaitForChild("ProximityPrompt")
		proximityPrompt.Enabled = false
		DialogueController.start(DialoguesList.TushitaScroll)

		if v4:WaitForChild("Pedestal1"):WaitForChild("ProximityPrompt"):GetAttribute("Enabled") ~= false then
			local proximityPrompt_2 = v4:WaitForChild("Pedestal1"):WaitForChild("ProximityPrompt")
			proximityPrompt_2.Enabled = true
		end
	end)
	v4:WaitForChild("Pedestal2"):WaitForChild("ProximityPrompt").Triggered:Connect(function()
		local proximityPrompt = v4:WaitForChild("Pedestal2"):WaitForChild("ProximityPrompt")
		proximityPrompt.Enabled = false
		DialogueController.start(DialoguesList.YamaScroll)

		if v4:WaitForChild("Pedestal2"):WaitForChild("ProximityPrompt"):GetAttribute("Enabled") ~= false then
			local proximityPrompt_2 = v4:WaitForChild("Pedestal2"):WaitForChild("ProximityPrompt")
			proximityPrompt_2.Enabled = true
		end
	end)
	v4:WaitForChild("Pedestal3"):WaitForChild("ProximityPrompt").Triggered:Connect(function()
		DialogueController.start(DialoguesList.CDKDoor)
	end)
	v4.Pedestal1.ProximityPrompt:GetAttributeChangedSignal("Enabled"):Connect(function()
		if not v4.Pedestal1.ProximityPrompt:GetAttribute("Enabled") then
			v4.GoodScroll.Base.Burning.Enabled = true
			local Sound = require(game.ReplicatedStorage.Util.Sound)
			Sound:Play("ScrollSFX", v4.GoodScroll.Base)
			TweenService:Create(v4.GoodScroll.Base.Mesh, TweenInfo.new(0.3), {
				VertexColor = createVector(0, 0, 0)
			}):Play()
			task.wait(0.3)
			TweenService:Create(v4.GoodScroll.Base, TweenInfo.new(0.5), {
				Transparency = 1
			}):Play()
			task.wait(0.2)
			v4.GoodScroll.Base.Burning.Enabled = false
		end
	end)
	v4.Pedestal2.ProximityPrompt:GetAttributeChangedSignal("Enabled"):Connect(function()
		if not v4.Pedestal2.ProximityPrompt.Enabled then
			v4.EvilScroll.Base.Burning.Enabled = true
			local Sound = require(game.ReplicatedStorage.Util.Sound)
			Sound:Play("ScrollSFX", v4.EvilScroll.Base)
			TweenService:Create(v4.EvilScroll.Base.Mesh, TweenInfo.new(0.3), {
				VertexColor = createVector(0, 0, 0)
			}):Play()
			task.wait(0.3)
			TweenService:Create(v4.EvilScroll.Base, TweenInfo.new(0.5), {
				Transparency = 1
			}):Play()
			task.wait(0.2)
			v4.EvilScroll.Base.Burning.Enabled = false
		end
	end)

	local function UpdatePedestal3()
		if v4.Pedestal3.ProximityPrompt.Enabled then
			return
		end

		local clones = {}

		for i = 1, 6 do
			local clone = v4.ShatteredGem:FindFirstChild("Fragment" .. i):Clone()
			clone.Parent = workspace
			clone.Transparency = 0
			table.insert(clones, clone)
		end

		task.wait(0.4)

		for _, v5 in pairs(clones) do
			TweenService:Create(v5, TweenInfo.new(3, Enum.EasingStyle.Sine), {
				CFrame = v4.HealedGem:FindFirstChild(v5.Name).CFrame
			}):Play()
		end

		task.wait(3)

		for _, v5 in pairs(clones) do
			v5:Destroy()
		end

		local clone = v4.WholeGem:Clone()
		clone.Transparency = 0
		clone.Parent = workspace
		local numberValue = Instance.new("NumberValue")
		TweenService:Create(numberValue, TweenInfo.new(2), {
			Value = 1
		}):Play()
		TweenService:Create(v4.Pedestal3, TweenInfo.new(2, Enum.EasingStyle.Linear), {
			CFrame = v4.Pedestal3.CFrame * CFrame.new(0, -6, 0)
		}):Play()
		local Sound = require(game.ReplicatedStorage.Util.Sound)
		Sound:Play("CDKSFX", v4.Pedestal3)
		v4.Smoke2.Smoke.Enabled = true
		task.delay(1.6, function()
			v4.Smoke2.Smoke.Enabled = false
		end)
		numberValue.Changed:Connect(function()
			clone.CFrame = clone.CFrame * CFrame.Angles(0, math.rad(numberValue.Value * 10), 0) * CFrame.new(
				0,
				numberValue.Value * 0.04,
				0
			)
		end)
		task.wait(2)
		numberValue:Destroy()
		TweenService:Create(clone, TweenInfo.new(0.3), {
			CFrame = CFrame.new(clone.Position, v4.PlacedGem.Position) * CFrame.Angles(0, 0, 3.141592653589793)
		}):Play()
		task.wait(0.3)
		TweenService:Create(clone, TweenInfo.new(0.2), {
			CFrame = v4.PlacedGem.CFrame
		}):Play()
		task.wait(0.2)
		v4.PlacedGem.Attachment.Ring_Extend:Emit(1)
		clone:Destroy()
		v4.PlacedGem.Transparency = 0
		task.wait(1)
		v4.Smoke.Smoke.Enabled = true
		local Sound2 = require(game.ReplicatedStorage.Util.Sound)
		Sound2:Play("CDKSFX", v4.PlacedGem.SFX)
		TweenService:Create(v4.BossDoor, TweenInfo.new(4.7, Enum.EasingStyle.Linear), {
			CFrame = cFrame * CFrame.new(0, -34, 0)
		}):Play()
		task.wait(4.5)
		v4.Smoke.Smoke.Enabled = false
		task.wait(0.1)
	end

	v4.Pedestal3.ProximityPrompt:GetPropertyChangedSignal("Enabled"):Connect(function()
		task.wait(1)
		local success, result = pcall(UpdatePedestal3)

		if not success then
			fn(result)
		end
	end)
	local v5 = 0
	v4.EntranceTouch.Touched:Connect(function(otherPart)
		if v5 > tick() or workspace.Enemies:FindFirstChild("Cursed Skeleton Boss") then
			return
		end

		if otherPart.Parent == game.Players.LocalPlayer.Character then
			v5 = tick() + 3

			if game.ReplicatedStorage.Remotes.CommF_:InvokeServer("CDKQuest", "SpawnBoss") == "Finished" then
				v5 = 1e999
			end
		end
	end)
	game.Players.LocalPlayer.ChildAdded:Connect(function(child)
		if child.Name == "QuestHaze" then
			TweenService:Create(game.Lighting.LightingLayers.Haze.Intensity, TweenInfo.new(2), {
				Value = 1
			}):Play()
			local v6 = {}

			for _, child2 in pairs(child:GetChildren()) do
				local name = child2.Name
				local Util = require(game.ReplicatedStorage.Util)
				v6[name] = Util.Maid.new()
			end

			local function MakeBoard(p, value)
				local billboardGui = Instance.new("BillboardGui")
				billboardGui.Name = "HazeESP"
				billboardGui.Size = UDim2.new(2.5, 10, 2.5, 10)
				billboardGui.AlwaysOnTop = true
				billboardGui.MaxDistance = 300
				local imageLabel = Instance.new("ImageLabel", billboardGui)
				imageLabel.Size = UDim2.new(1, -10, 1, -10)
				imageLabel.Position = UDim2.fromScale(0.5, 0.5)
				imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
				imageLabel.BackgroundTransparency = 1
				imageLabel.Image = "rbxassetid://2091181653"
				imageLabel.ImageTransparency = 0.4
				imageLabel.ImageColor3 = p or Color3.fromRGB(216, 17, 255)
				local uISizeConstraint = Instance.new("UISizeConstraint", imageLabel)
				uISizeConstraint.MinSize = Vector2.new(value or 10, value or 10)
				return billboardGui
			end

			local RunService = game:GetService("RunService")
			RunService:BindToRenderStep("HazeQuestHighlight", Enum.RenderPriority.Last.Value + 100, function()
				local v7 = {}

				for _, child2 in pairs(child:GetChildren()) do
					if child2.Value == 0 then
						continue
					end

					v7[child2:GetAttribute("Island")] = v7[child2:GetAttribute("Island")] or {}
					v7[child2:GetAttribute("Island")][child2.Name] = child2:GetAttribute("Position")
				end

				for _, child2 in pairs(child:GetChildren()) do
					if child2.Value == 0 then
						if v6[child2.Name] then
							v6[child2.Name]:DoCleaning()
							v6[child2.Name] = nil
						end
					else
						for _, child3 in pairs(workspace.Enemies:GetChildren()) do
							if not child3.Name:match("^" .. child2.Name) then
								continue
							end

							v7[child2:GetAttribute("Island")][child2.Name] = false

							if child3:FindFirstChild("HazeESP") then
								continue
							end

							local board = MakeBoard(nil, 3)
							board.Parent = child3
							board.Adornee = child3

							if not v6[child2.Name] then
								local v9 = v6
								local name = child2.Name
								local Util = require(game.ReplicatedStorage.Util)
								v9[name] = Util.Maid.new()
							end

							v6[child2.Name]:GiveTask(board)
						end
					end
				end
			end)
			local v7 = {}

			repeat
				child:GetPropertyChangedSignal("Parent"):Wait()
			until not child.Parent

			child:Destroy()
			local RunService2 = game:GetService("RunService")
			RunService2:UnbindFromRenderStep("HazeQuestHighlight")

			for _, v8 in pairs(v6) do
				v8:DoCleaning()
			end

			TweenService:Create(game.Lighting.LightingLayers.Haze.Intensity, TweenInfo.new(2), {
				Value = 0
			}):Play()

			for k, v8 in pairs(v7) do
				if v8.Part then
					v8.Part:Destroy()
				end

				for _, enemy in pairs(v8.Enemies) do
					enemy:Destroy()
				end

				v7[k] = nil
			end
		end
	end)
	local v6 = {}
	local v7 = {}
	game.ReplicatedStorage.Remotes.CommE.OnClientEvent:Connect(function(p, cFrame2, p2)
		if p == "CDKLightTorch" then
			local part = Instance.new("Part")
			part.Size = createVector(0.502, 0.042, 0.502)
			part.CanCollide = false
			part.Anchored = true
			part.Transparency = 1
			local clone = game.ReplicatedStorage.Assets.Particles.Torch:Clone()
			clone.Parent = part
			clone.Enabled = true
			part.CFrame = cFrame2
			part.Parent = workspace

			if p2 then
				fn("enabled false")
				p2.Enabled = false
				table.insert(v7, p2)
			end

			table.insert(v6, part)
		elseif p == "CDKUnlightTorches" then
			for _, v8 in pairs(v6) do
				v8:Destroy()
			end

			for _, v8 in pairs(v7) do
				v8.Enabled = true
			end

			local v8 = nil
			local thread = coroutine.running()
			task.spawn(function()
				local hellDimension = workspace.Map:WaitForChild("HellDimension", 5)

				if hellDimension then
					v8 = hellDimension
					coroutine.resume(thread)
				end
			end)
			task.spawn(function()
				local heavenlyDimension = workspace.Map:WaitForChild("HeavenlyDimension", 5)

				if heavenlyDimension then
					v8 = heavenlyDimension
					coroutine.resume(thread)
				end
			end)
			coroutine.yield()

			if v8 and v8:FindFirstChild("Exit") then
				local exit = v8:FindFirstChild("Exit")

				if exit.Color == exit:GetAttribute("ActiveColor") then
					task.wait(4)

					if exit.Color == exit:GetAttribute("ActiveColor") then
						exit.Color = Color3.fromRGB(0, 0, 0)
					end
				end
			end
		elseif p == "CDKLightPortal" then
			local Global = require(game.ReplicatedStorage.Global)
			local encoded = Global.Encode(cFrame2)
			TweenService:Create(encoded, TweenInfo.new(0.2), {
				Color = encoded:GetAttribute("ActiveColor")
			}):Play()
			local touchedConnection = nil
			touchedConnection = encoded.Touched:Connect(function(otherPart)
				if otherPart.Parent == game.Players.LocalPlayer.Character then
					touchedConnection:Disconnect()
					task.wait(10)

					if encoded.Color == encoded:GetAttribute("ActiveColor") then
						encoded.Color = Color3.fromRGB(0, 0, 0)
					end
				end
			end)
		elseif p == "CDKCompleteQuest" then
			local backpack = game.Players.LocalPlayer.PlayerGui:FindFirstChild("Backpack")
			local character = game.Players.LocalPlayer.Character
			local localPlayer = game.Players.LocalPlayer
			local backpack2 = localPlayer.Backpack
			local humanoid = character.Humanoid
			local v8 = nil

			for _, tool in pairs(character:GetChildren()) do
				if not ((tool.Name == "Tushita" or tool.Name == "Yama") and tool:IsA("Tool")) then
					continue
				end

				v8 = tool
				break
			end

			local v10 = v8 or backpack2:FindFirstChild("Tushita") or backpack2:FindFirstChild("Yama")

			if v10 then
				if v10.Parent ~= character and v10.Parent ~= game.Lighting then
					humanoid:EquipTool(v10)
				end

				local blade = nil

				while true do
					for _, child in pairs(character:GetChildren()) do
						if not ((child.Name == "Tushita" or child.Name == "Yama") and child.ClassName == "Model" and child.Right.Hidden:FindFirstChild("MeshPart").Transparency == 1) then
							continue
						end

						blade = child.Right.Blade
						break
					end

					wait()

					if not blade then
						continue
					end

					local clone_2 = game.ReplicatedStorage.Assets.Particles.Cursed:Clone()
					clone_2.Parent = blade

					repeat
						task.wait()
					until not v10.Parent

					local screenGui = Instance.new("ScreenGui", localPlayer.PlayerGui)
					screenGui.DisplayOrder = 10
					local frame = Instance.new("Frame", screenGui)
					frame.Size = UDim2.fromScale(4, 4)
					frame.Position = UDim2.fromScale(-0.5, -0.5)
					frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

					repeat
						task.wait()
					until backpack2:FindFirstChild("Cursed Dual Katana") or localPlayer.Character:FindFirstChild("Cursed Dual Katana")

					if not localPlayer.Character:FindFirstChild("Cursed Dual Katana") then
						humanoid:EquipTool(backpack2:FindFirstChild("Cursed Dual Katana"))
					end

					local blade2 = nil

					while true do
						wait()

						for _, child in pairs(character:GetChildren()) do
							if not (child.Name:lower() == "dualcursed" and child.ClassName == "Model" and child.Right.Hidden:FindFirstChild("MeshPart").Transparency == 1) then
								continue
							end

							blade2 = child.Right.Blade
						end

						if not blade2 then
							continue
						end

						TweenService:Create(frame, TweenInfo.new(2, Enum.EasingStyle.Linear), {
							BackgroundTransparency = 1
						}):Play()
						local Util = require(game.ReplicatedStorage.Util)
						Util.Debris:AddItem(screenGui, 3)
						backpack.Enabled = true
						break
					end

					break
				end
			end
		end
	end)
	game.Players.LocalPlayer.ChildAdded:Connect(function(child)
		if child.Name == "HeavenTrialTag" then
			local sound = Instance.new("Sound")
			sound.SoundId = "rbxassetid://10698777007"
			sound.Looped = true
			sound.Volume = 1.2
			local Groups = require(game.ReplicatedStorage.Util.Sound.Groups)
			Groups.assign(sound, "LowPriority")
			local screenGui = Instance.new("ScreenGui", game.Players.LocalPlayer.PlayerGui)
			sound.Parent = screenGui
			sound:Play()
			local Util = require(game.ReplicatedStorage.Util)
			Util.Debris:AddItem(screenGui, 120)
			TweenService:Create(sound, TweenInfo.new(120, Enum.EasingStyle.Linear), {
				Volume = 0
			}):Play()
			child:GetPropertyChangedSignal("Parent"):Connect(function(_)
				if not child.Parent then
					sound:Destroy()
					pcall(function()
						child:Destroy()
					end)
				end
			end)
		end
	end)
end