local TweenService = game:GetService("TweenService")
local value = script.CloneFolder.Value
local blinkemotestuff = game.Players.LocalPlayer.PlayerGui:WaitForChild("blinkemotestuff")
local animFrame = blinkemotestuff.AnimFrame
game:GetService("RunService")
local localPlayer = game.Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local collisionGroupsByPart = {}

for _, part in pairs(character:GetDescendants()) do
	if not (part:IsA("Part") or part:IsA("MeshPart")) then
		continue
	end

	collisionGroupsByPart[part] = part.CollisionGroup
	part.CollisionGroup = "nocol"
end

local v = {
	"rbxassetid://128266708335736",
	"rbxassetid://98480479919802",
	"rbxassetid://83688076191030",
	"rbxassetid://85568483940067",
	"rbxassetid://75629359313261",
	"rbxassetid://140499400846349",
	"rbxassetid://82852810153524",
	"rbxassetid://106430030274684",
	"rbxassetid://110660205183796",
	"rbxassetid://86978776191540",
	"rbxassetid://105073357413530",
	"rbxassetid://81419067295210",
	"rbxassetid://94316417025910",
	"rbxassetid://136059769446133",
	"rbxassetid://134139923878710",
	"rbxassetid://122810312782521",
	"rbxassetid://88817086365029",
	"rbxassetid://117939222804823",
	"rbxassetid://117473392186257",
	"rbxassetid://71492104699033",
	"rbxassetid://118054504721332"
}

for _, image in pairs(v) do
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Size = UDim2.new(0, 1, 0, 1)
	imageLabel.Image = image
	imageLabel.Parent = script.Parent
end

local currentCamera = workspace.CurrentCamera
local fieldOfView = currentCamera.FieldOfView
local folder = Instance.new("Folder")
folder.Parent = workspace.Terrain
folder.Name = localPlayer.Name .. "Clones"
local flag = true
local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
script.Destroying:Connect(function()
	for k, collisionGroup in pairs(collisionGroupsByPart) do
		k.CollisionGroup = collisionGroup
	end

	if colorCorrectionEffect then
		colorCorrectionEffect:Destroy()
	end

	flag = false
	game.Debris:AddItem(folder, 0)
	game.Debris:AddItem(animFrame, 0)
	currentCamera.FieldOfView = fieldOfView
end)

if character:FindFirstChild("Sandevistan") then
	for _, emitter in pairs(character.Sandevistan:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v2 = emitter
		task.delay(0.6, function()
			v2.Enabled = false
			v2:Emit(v2:GetAttribute("EmitCount"))
		end)
	end
end

for k, _ in pairs(v) do
	animFrame.Image = v[k]
	animFrame.ImageTransparency = 0.05
	task.wait(0.03)
end

local TweenService2 = game:GetService("TweenService")
TweenService2:Create(animFrame, TweenInfo.new(0.2), {
	ImageTransparency = 1,
	BackgroundTransparency = 1
}):Play()
game.Debris:AddItem(animFrame.Parent, 1)
TweenService:Create(currentCamera, TweenInfo.new(0.25), {
	FieldOfView = fieldOfView + 35
}):Play()
colorCorrectionEffect.Parent = game.Lighting
TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.25), {
	Brightness = -0.1,
	TintColor = Color3.new(0.670588, 1, 0.694118)
}):Play()
TweenService:Create(animFrame, TweenInfo.new(0.25), {
	ImageTransparency = 1
}):Play()
game.Debris:AddItem(blinkemotestuff, 2)
task.defer(function()
	local WAIT_INTERVAL = 0.7

	while flag do
		-- equivalent calls inferred from this helper; original call sites unknown
		local function changecolor(color)
			TweenService:Create(script.Highlight, TweenInfo.new(0.8), {
				FillColor = color
			}):Play()
		end

		task.wait(1)
		changecolor(Color3.new(0.0313725, 1, 0.917647)) -- equivalent call inferred; original call site unknown
		task.wait(WAIT_INTERVAL)
		changecolor(Color3.new(0.701961, 0.454902, 1)) -- equivalent call inferred; original call site unknown
		task.wait(WAIT_INTERVAL)
		changecolor(Color3.new(1, 0.0784314, 0.909804)) -- equivalent call inferred; original call site unknown
		task.wait(WAIT_INTERVAL)
		changecolor(Color3.new(1, 0.0470588, 0.0627451)) -- equivalent call inferred; original call site unknown
		task.wait(WAIT_INTERVAL)
		changecolor(Color3.new(0.411765, 1, 0.0196078)) -- equivalent call inferred; original call site unknown
		task.wait(WAIT_INTERVAL)
	end
end)

local function convert_rgb_to_vertex(data)
	return (Vector3.new(data.R, data.G, data.B))
end

local function TweenModelToCFrame(instance, p, cframe: CFrame)
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = instance:GetPivot()
	cFrameValue:GetPropertyChangedSignal("Value"):Connect(function()
		instance:PivotTo(cFrameValue.Value)
	end)
	local tween = TweenService:Create(cFrameValue, p, {
		Value = cframe
	})
	tween:Play()
	tween.Completed:Connect(function()
		cFrameValue:Destroy()
	end)
end

task.defer(function()
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	while flag do
		if humanoidRootPart.Velocity.Magnitude > 1 then
			local clone = value.Copy:Clone()
			local clone2 = script.Highlight:Clone()
			clone2.Parent = clone
			clone2.Adornee = clone
			game.Debris:AddItem(clone, 0.65)
			task.delay(0.325, function()
				TweenService:Create(clone2, TweenInfo.new(0.325, Enum.EasingStyle.Linear), {
					FillTransparency = 1
				}):Play()
			end)
			clone.Parent = folder
			clone:PivotTo(character.PrimaryPart.CFrame * CFrame.new(0, 0, 0.35))
			clone.HumanoidRootPart:Destroy()

			for _, child in pairs(clone:GetChildren()) do
				for _, part in pairs(character:GetChildren()) do
					if child:IsA("Accessory") then
						for _, descendant in pairs(child:GetDescendants()) do
							if descendant:IsA("BasePart") then
								descendant.CanCollide = false
								descendant.Color = clone2.FillColor
								descendant.Material = Enum.Material.Neon
								descendant.Anchored = true
								descendant.CollisionGroup = "nocol"
								descendant.Transparency = 0
								descendant.CastShadow = false
								local v3 = descendant
								task.delay(0.5, function()
									TweenService:Create(v3, TweenInfo.new(0.25), {
										Transparency = 1
									}):Play()
								end)
							end

							if not (descendant:IsA("FileMesh") or descendant:IsA("SpecialMesh")) then
								continue
							end

							local fillColor = clone2.FillColor
							descendant.VertexColor = Vector3.new(fillColor.R, fillColor.G, fillColor.B)
						end
					end

					if not (child.Name == part.Name and child:IsA("BasePart") and part:IsA("BasePart")) then
						continue
					end

					child.CanCollide = false
					child.CollisionGroup = "nocol"
					child.CFrame = part.CFrame
					child.Color = clone2.FillColor
					child.Material = Enum.Material.Neon
					child.Anchored = true
					child.Transparency = 0
					child.CastShadow = false

					if child.Name == "Head" then
						for _, child2 in pairs(child:GetChildren()) do
							if child2:IsA("Decal") or child2:IsA("Texture") then
								child2:Destroy()
							end
						end
					end

					local v3 = child
					task.delay(0.5, function()
						TweenService:Create(v3, TweenInfo.new(0.25), {
							Transparency = 1
						}):Play()
					end)
				end
			end

			for _, part in pairs(clone:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CollisionGroup = "untouchable"
				end
			end
		end

		task.wait(0.075)
	end
end)