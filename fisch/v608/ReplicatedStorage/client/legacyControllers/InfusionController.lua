local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = game.Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
playerGui:WaitForChild("hud")
local backpack = playerGui:WaitForChild("backpack")
local currentCamera = workspace.CurrentCamera
local packages = ReplicatedStorage.packages
local Net = require(packages.Net)
local Trove = require(packages.Trove)
local UIDialog = require(packages.UIDialog)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local assets = require(ReplicatedStorage.shared.utils.assets)
local FischUtils = require(ReplicatedStorage.shared.utils.FischUtils)
local rarities = require(ReplicatedStorage.shared.modules.library.rarities)
local remoteEvent = Net:RemoteEvent("Infusion/Interact", -1)
local remoteFunction = Net:RemoteFunction("Infusion/Infuse")
local remoteEvent2 = Net:RemoteEvent("Infusion/Exit")
local mermaid = workspace:WaitForChild("world"):WaitForChild("Mermaid", 20)

if not mermaid then
	return {}
end

local mermaidNpc = mermaid:WaitForChild("MermaidNpc")
local pivot = mermaidNpc:GetPivot()
local animations = script:WaitForChild("Animations")
local v = Trove.new()
local v2 = {}
local v3 = nil
local track = nil
local v4 = nil
local v5 = nil
local InfusionController = {}

local function LoadAnimation(childName: string)
	local child = animations:FindFirstChild(childName)

	if not child then
		return
	end

	local humanoid = mermaidNpc:FindFirstChild("Humanoid")

	if not humanoid then
		return
	end

	local animator = humanoid:FindFirstChild("Animator")

	if v2[childName] then
		return v2[childName]
	end

	v2[childName] = animator:LoadAnimation(child)
	return v2[childName]
end

-- equivalent calls inferred from this helper; original call sites unknown
local function DestroyAnimation(p)
	if not v2[p] then
		return
	end

	if v2[p].IsPlaying then
		v2[p]:Stop(0)
	end

	v2[p]:Destroy()
	v2[p] = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function PointCamera(cFrame: CFrame?)
	if cFrame then
		currentCamera.CameraType = Enum.CameraType.Scriptable
		currentCamera.CFrame = cFrame
	else
		currentCamera.CameraType = Enum.CameraType.Custom
		currentCamera.CFrame = CFrame.new()
	end
end

function Emerge(flag: boolean, p: string, p2)
	local stats = legacyLocalPlayerData.fetch():FindFirstChild("Stats")

	if not stats then
		return
	end

	local character = localPlayer.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local animator = character.Humanoid:FindFirstChild("Animator")

	if not (humanoidRootPart and animator) then
		return
	end

	local loadAnimation = LoadAnimation("Emerge")
	local loadAnimation2 = LoadAnimation("Idle")
	local loadAnimation3 = LoadAnimation("Talk")

	if not (loadAnimation and loadAnimation2 and loadAnimation3) then
		return
	end

	local rod = stats:FindFirstChild("rod")

	if not rod then
		return
	end

	loadAnimation2.Priority = Enum.AnimationPriority.Idle
	loadAnimation.Priority = Enum.AnimationPriority.Action
	loadAnimation3.Priority = Enum.AnimationPriority.Action2
	backpack.Enabled = false
	task.spawn(function()
		PointCamera(pivot * CFrame.new(0, 7, -15) * CFrame.Angles(0.4363323129985824, 3.2288591161895095, 0)) -- equivalent call inferred; original call site unknown
		loadAnimation:Play(0)

		while task.wait() and not loadAnimation.IsPlaying do

		end

		mermaidNpc:PivotTo(pivot * CFrame.new(0, 11, 0))
		task.delay(loadAnimation.Length - 0.25, function()
			loadAnimation2:Play(0.1)
			task.wait(0.1)
			loadAnimation:Stop(0.1)
			task.wait(0.2)
			DestroyAnimation("Emerge") -- equivalent call inferred; original call site unknown
		end)
		task.wait(1)
		local fieldOfView = currentCamera.FieldOfView
		currentCamera.FieldOfView = fieldOfView - 15
		PointCamera(pivot * CFrame.new(-10, 8, -17.5) * CFrame.Angles(0, 4.014257279586958, 0)) -- equivalent call inferred; original call site unknown
		TweenService:Create(currentCamera, TweenInfo.new(3), {
			FieldOfView = fieldOfView
		}):Play()
		task.wait(1.5)
		local v11 = nil
		local v12 = {
			Speaker = "Mella",
			[1] = {
				text = "<font color=\"#6be4ff\"><b><i>Ooooohohoho~!!!</i></b></font>",
				choices = {}
			},
			[10] = {
				text = "<font color=\"#6be4ff\"><b><i>Ooooohhohohohohohooo~!!!</i></b></font>",
				choices = {}
			},
			[11] = {
				text = "......",
				choices = {}
			},
			[12] = {
				text = "I wasn't able to modify your rod...",
				choices = {}
			},
			[13] = {
				text = "<font color=\"#6be4ff\"><b><i>Ta-taaaa~!!!</i></b></font>",
				choices = {}
			},
			[14] = function()
				Exit()
			end
		}

		if p == "hasdivinesecret" then
			table.insert(v12, {
				text = "It seems you are holding a <b><font color=\"#5cb3ff\">divine secret</font></b>.<br/>Are you offering it to me?",
				choices = {
					{
						text = `Give Divine Secret & Enhance {rod.Value}`,
						nextline = #v12 + 2,
						buttonSize = 6,
						buttonColor = Color3.fromRGB(92, 179, 255)
					},
					{
						text = "No",
						nextline = 5,
						buttonSize = 2.8,
						buttonColor = Color3.fromRGB(255, 105, 107)
					}
				}
			})
			table.insert(v12, {
				text = "Are you sure?",
				choices = {
					{
						text = `Give Divine Secret & Enhance {rod.Value}`,
						nextline = #v12 + 2,
						buttonSize = 6,
						buttonColor = Color3.fromRGB(92, 179, 255)
					},
					{
						text = "Nevermind",
						nextline = 5,
						buttonSize = 2.8,
						buttonColor = Color3.fromRGB(255, 105, 107)
					}
				}
			})
			table.insert(v12, {
				text = "Are you REALLY sure? This will PERMANENTLY <font color=\"#ff696b\"><b>DELETE</b></font> the <b>divine secret</b>.",
				choices = {
					{
						text = `Give Divine Secret & Enhance {rod.Value}`,
						nextline = 10,
						buttonSize = 6,
						buttonColor = Color3.fromRGB(92, 179, 255),
						run = function()
							v11 = remoteFunction:InvokeServer("infusedivine")

							if not v11 then
								return
							end

							local v13 = v11 < 0
							local v14 = math.round((math.abs(v11 * 100)))
							v12[12].text = `I've <b><font color="{v13 and "#ff696b\">hindered" or "#5cb3ff\">improved"}</font></b> your rod by <b><font color="#ffc16a">{v14}%</font></b>`
						end
					},
					{
						text = "Nevermind",
						nextline = 5,
						buttonSize = 2.8,
						buttonColor = Color3.fromRGB(255, 105, 107)
					}
				}
			})
			table.insert(v12, {
				text = "Very well.",
				choices = {}
			})
		elseif p == "hastear" then
			table.insert(v12, {
				text = "Is that... a <b><font color=\"#6be4ff\">Siren's Tear</font></b>?<br/>Give it to me and I will strengthen your rod by exactly <b><font color=\"#ffc16a\">30%</font></b>. No risk.",
				choices = {
					{
						text = `Give Siren's Tear & Enhance {rod.Value}`,
						nextline = #v12 + 2,
						buttonSize = 6,
						buttonColor = Color3.fromRGB(92, 179, 255)
					},
					{
						text = "No",
						nextline = 5,
						buttonSize = 2.8,
						buttonColor = Color3.fromRGB(255, 105, 107)
					}
				}
			})
			table.insert(v12, {
				text = "Are you sure?",
				choices = {
					{
						text = `Give Siren's Tear & Enhance {rod.Value}`,
						nextline = #v12 + 2,
						buttonSize = 6,
						buttonColor = Color3.fromRGB(92, 179, 255)
					},
					{
						text = "Nevermind",
						nextline = 5,
						buttonSize = 2.8,
						buttonColor = Color3.fromRGB(255, 105, 107)
					}
				}
			})
			table.insert(v12, {
				text = "Are you REALLY sure? This will PERMANENTLY <font color=\"#ff696b\"><b>DELETE</b></font> the <b>Siren's Tear</b>.",
				choices = {
					{
						text = `Give Siren's Tear & Enhance {rod.Value}`,
						nextline = 10,
						buttonSize = 6,
						buttonColor = Color3.fromRGB(92, 179, 255),
						run = function()
							v11 = remoteFunction:InvokeServer("infusetear")

							if not v11 then
								return
							end

							local v13 = math.round((math.abs(v11 * 100)))
							v12[12].text = `I've <b><font color="#5cb3ff">improved</font></b> your rod by <b><font color="#ffc16a">{v13}%</font></b>`
						end
					},
					{
						text = "Nevermind",
						nextline = 5,
						buttonSize = 2.8,
						buttonColor = Color3.fromRGB(255, 105, 107)
					}
				}
			})
			table.insert(v12, {
				text = "Very well.",
				choices = {}
			})
		end

		local gradientRichText = FischUtils.GradientRichText(p2.Exotic, rarities.Rarities.Exotic.ColorGradient)
		local gradientRichText2 = FischUtils.GradientRichText(p2.Secret, rarities.Rarities.Secret.ColorGradient)
		table.insert(v12, {
			text = not flag and "I require you to place <b>all 3 Essences</b> before I can help you..." or `{#v12 <= 1 and "Welcome back, child.<br/>" or ""}Do you have the <b>Exotic '{gradientRichText}'</b> and the <b>Secret '{gradientRichText2}'</b> for me?<br/>Modifying your rod will void one of each fish in exchange.<br/><font color="#878787"><i>(Must be unfavorited)</i></font>` or "I require you to place <b>all 3 Essences</b> before I can help you...",
			choices = {}
		})

		if flag then
			table.insert(v12[#v12].choices, {
				text = `Modify {rod.Value}`,
				nextline = 10,
				buttonSize = 4.5,
				buttonColor = Color3.fromRGB(92, 179, 255),
				run = function()
					v11 = remoteFunction:InvokeServer("infuse")

					if not v11 then
						return
					end

					local v13 = v11 < 0
					local v14 = math.round((math.abs(v11 * 100)))
					v12[12].text = v11 == 0 and "...Your rod was set to it's default stats." or `I've <b><font color="{v13 and "#ff696b\">hindered" or "#5cb3ff\">improved"}</font></b> your rod by <b><font color="#ffc16a">{v14}%</font></b>` or "...Your rod was set to it's default stats."
				end
			})
		end

		table.insert(v12[#v12].choices, {
			text = "Leave",
			buttonSize = 3.25,
			buttonColor = Color3.fromRGB(255, 105, 107),
			run = function()
				Exit()
			end
		})
		v5:StartDialog(v12)
	end)
	track = animator:LoadAnimation(animations.Float)
	track:Play(0.5)
	v4 = TweenService:Create(humanoidRootPart, TweenInfo.new(3.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		CFrame = mermaid.Prompt.CFrame * CFrame.new(-3.5, 2.25, 0) * CFrame.Angles(0, 1.5707963267948966, 0)
	})
	v4:Play()

	if v5 and v5.Destroy then
		v5:Destroy()
	end

	v5 = nil
	v5 = UIDialog.new({
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.fromScale(0.875, 0.96)
	})
	v5.UI.Parent = playerGui
end

function Exit()
	currentCamera.CameraType = Enum.CameraType.Custom
	currentCamera.CFrame = CFrame.new()

	if track then
		track:Stop(0.1)
		track:Destroy()
	end

	v4:Cancel()
	v4:Destroy()
	local loadAnimation = LoadAnimation("Emerge")
	loadAnimation.Priority = Enum.AnimationPriority.Action
	loadAnimation:Play(0.1)
	loadAnimation:AdjustSpeed(-1)
	task.delay(loadAnimation.Length - 0.05, function()
		DestroyAnimation("Idle") -- equivalent call inferred; original call site unknown
		mermaidNpc:PivotTo(pivot * CFrame.new(0, -100, 0))
	end)
	backpack.Enabled = true
	remoteEvent2:FireServer()
	v:Clean()

	if v5 then
		v5:Destroy()
	end

	task.wait(3.5)
	v3.Enabled = true
end

local function FindNextAvailablePodium()
	local podiums = mermaid:WaitForChild("Podiums", 30)

	if not podiums then
		return nil
	end

	local v6 = nil

	for i = 1, 3 do
		local child = podiums:WaitForChild(`Podium{i}`, 15)

		if not child or child:FindFirstChild("Visual") then
			continue
		end

		v6 = child
	end

	return v6
end

local v6 = {}

local function UpdateEssenceVisuals(p, options)
	local count = 0

	for k in p or options or {} do
		count += 1

		if table.find(v6, k) then
			continue
		end

		table.insert(v6, k)
		local async = assets.getAsync("item", k)

		if not async then
			continue
		end

		local clone = async:FindFirstChildOfClass("Model"):Clone()
		clone.Name = "Visual"

		for _, part in clone:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			part.CanCollide = false
			part.Anchored = true
		end

		local parent = FindNextAvailablePodium()

		if not parent then
			continue
		end

		local position = parent:FindFirstChildOfClass("Attachment").WorldCFrame.Position
		clone.Parent = parent
		clone:PivotTo(CFrame.new(position.X, position.Y, position.Z))
	end

	if count <= 0 then
		if not mermaid:WaitForChild("Podiums", 15) then
			return
		end

		for i = 1, 3 do
			local child = mermaid:WaitForChild("Podiums"):WaitForChild(`Podium{i}`, 15)

			if child and child:FindFirstChild("Visual") then
				child:FindFirstChild("Visual"):Destroy()
			end
		end

		v6 = {}
		local placePrompt = mermaid:WaitForChild("PlacePrompt", 1e999)
		placePrompt.ProximityPrompt.Enabled = true
	elseif count >= 3 then
		local placePrompt_2 = mermaid:WaitForChild("PlacePrompt", 1e999)
		placePrompt_2.ProximityPrompt.Enabled = false
	end
end

function InfusionController.Start(_)
	task.spawn(ContentProvider.PreloadAsync, ContentProvider, animations:GetChildren())
	mermaidNpc:PivotTo(pivot * CFrame.new(0, -100, 0))
	remoteEvent.OnClientEvent:Connect(function(flag: boolean, flag2: boolean, p, p2: string, p3)
		if p then
			v3 = p
		end

		if not flag then
			Exit()
			return
		end

		v3.Enabled = false
		Emerge(flag2, p2, p3)
	end)
	DataController.PlayerDataReplicator:Observe(
		{ "Tidefall", "InfusionMermaid", "EssencesPlaced" },
		UpdateEssenceVisuals
	)
end

return InfusionController