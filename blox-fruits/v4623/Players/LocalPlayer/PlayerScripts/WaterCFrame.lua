local createVector = vector.create
pcall(function()
	workspace.CurrentCamera:ClearAllChildren()
end)
local map = workspace:WaitForChild("Map")
local TweenService = game:GetService("TweenService")
local Util = require(game.ReplicatedStorage.Util)
local Global = require(game.ReplicatedStorage.Global)
local Water = require(game.ReplicatedStorage.Modules.World.Water)
local cframe = CFrame.Angles(-1.5707963267948966, 0, 0)
local v = -4
local floor = math.floor
local _ = math.sin

local function grid(p)
	return floor(p / 5000 + 0.5) * 5000
end

local v2 = workspace:GetAttribute("MAP") == "Dungeons"
local currentCamera = workspace.CurrentCamera
local _WorldOrigin = workspace._WorldOrigin
local model = Instance.new("Model")
model.Name = "WaterCFrame"
local parent

if not v2 then
	parent = _WorldOrigin
end

model.Parent = parent

if not workspace:WaitForChild("WaterStudio"):WaitForChild(".Water", 30) then
	return
end

local color = workspace:WaitForChild("WaterStudio"):GetChildren()[1].Color
local foam = game.ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Foam;", 30)

if not foam then
	return
end

foam.CanQuery = false
foam.CanTouch = false
foam.CanCollide = false
local water = game.ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Water;")
water.Color = color
water.Mesh.Scale = createVector(5000, 0, 5000)

function SwipeWave(instance, _)
	local cFrameValue = instance:FindFirstChildOfClass("CFrameValue")
	cFrameValue.Value = CFrame.new()
	instance:SetAttribute("Rotation", math.random() * 360)
	TweenService:Create(instance.Texture, TweenInfo.new(2), {
		Transparency = 0.35
	}):Play()
	TweenService:Create(cFrameValue, TweenInfo.new(20), {
		Value = CFrame.Angles(0, math.rad(math.random() * 360), 0) * CFrame.new(0, 0, -80)
	}):Play()
	task.wait(12.5)
	TweenService:Create(instance.Texture, TweenInfo.new(2), {
		Transparency = 1
	}):Play()
end

local v4 = {}
local v5 = {}
local clone = foam:Clone()
clone.Size = createVector(0.05, 2000, 2000)
clone.Texture.ZIndex = 5
clone.Texture.Transparency = 0.5
clone.Texture.Color3 = Color3.fromRGB(255, 255, 255)
clone.Parent = model
local clone2 = clone:Clone()
task.spawn(function()
	while true do
		local v6 = math.random() * 3 + 9
		TweenService:Create(clone.BackOffset, TweenInfo.new(v6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Value = clone.BackOffset.Value * CFrame.Angles(0, math.rad(90 - math.random(-20000, 20000) / 1000), 0) * CFrame.new(
				0,
				0,
				-40
			)
		}):Play()
		task.wait(v6)
	end
end)
task.spawn(function()
	if workspace:GetAttribute("MAP") == "Dungeons" then
		return
	end

	clone:WaitForChild("BackTexture", 60)
	clone.TextureOffset.Value = CFrame.Angles(0, 2.2689280275926285, 0)
	clone.BackTexture.Transparency = 0.93

	while true do
		local v6 = game.Lighting.ClockTime > 17.8 or game.Lighting.ClockTime < 5
		local v7 = math.random() * 3 + 9
		clone.Texture.Transparency = v6 and 0.2 or 0.5
		TweenService:Create(clone.TextureOffset, TweenInfo.new(v7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Value = clone.TextureOffset.Value * CFrame.Angles(0, math.rad(90 - math.random(-20000, 20000) / 1000), 0) * CFrame.new(
				0,
				0,
				-40
			)
		}):Play()
		TweenService:Create(
			clone.Texture,
			TweenInfo.new(v7 / 2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true),
			{
				Transparency = v6 and 0 or 0.3
			}
		):Play()
		task.wait(v7)
	end
end)
task.spawn(function()
	if workspace:GetAttribute("MAP") == "Dungeons" then
		return
	end

	clone:WaitForChild("BackTexture", 60)

	while task.wait() do
		local localTransparencyModifier = math.clamp((workspace.CurrentCamera.CFrame.Y - v - 50) / 300, 0, 1)
		clone.BackTexture.LocalTransparencyModifier = localTransparencyModifier
		clone.Texture.LocalTransparencyModifier = localTransparencyModifier
	end
end)
local v6 = {}

function GetWaveParticle()
	if #v6 > 0 then
		local v7 = v6[1]
		table.remove(v6, 1)
		return v7
	else
		local clone3 = script.wave:Clone()
		clone3.Value.Changed:Connect(function(p)
			clone3.CFrame = CFrame.new(
				p.p + clone3:GetAttribute("Original") * createVector(1, 0, 1),
				currentCamera.CFrame.p
			) * cframe
		end)
		clone3.Parent = model
		return clone3
	end
end

local v7 = 0
task.spawn(function()
	if workspace:GetAttribute("MAP") == "Dungeons" then
		return
	end

	while true do
		local v8 = task.wait(0.5)

		if Global.FastMode or workspace.Terrain:GetAttribute("SeaTheme") ~= "Default" then
			continue
		end

		local cFrame = currentCamera.CFrame
		local p = cFrame.p
		local v9 = math.floor((v8 + v7) * 5)
		v7 = ((v8 + v7) * 5 - v9) / 5

		for _ = 1, v9 do
			local v10 = CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0) * CFrame.new(
				0,
				-5,
				-(math.random() * 1500 + 1100)
			)
			local v11 = v10.p + p * createVector(1, 0, 1)

			if cFrame.LookVector:Dot(v10.LookVector) < 0.5 or Util.Ray(
				p,
				v11 - p,
				{ workspace.Enemies, workspace.Characters }
			) then
				continue
			end

			local v12 = math.random() * 1.25 + 1.25
			local v13 = GetWaveParticle()
			v13:SetAttribute("Original", p)
			v13.Transparency = 1
			v13.Value.Value = v10
			TweenService:Create(
				v13.Value,
				TweenInfo.new(v12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true),
				{
					Value = v13.Value.Value * CFrame.new(0, 10, 0)
				}
			):Play()
			TweenService:Create(v13, TweenInfo.new(v12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true), {
				Transparency = 0.375
			}):Play()
			task.delay(v12 * 2, table.insert, v6, v13)
		end
	end
end)
foam:Destroy()
local part = Instance.new("Part")
part.Name = "Sand"
part.CanQuery = true
part.Anchored = true
part.CanCollide = true
part.CanTouch = false
part.Material = "SmoothPlastic"
part.BrickColor = BrickColor.new("Burlap")
part.Size = createVector(500, 0, 500)
local parent2

if not v2 then
	parent2 = workspace.Map
end

part.Parent = parent2
local blockMesh = Instance.new("BlockMesh")
blockMesh.Scale = createVector(25, 0, 25)
blockMesh.Parent = part
pcall(function()
	workspace.WaterStudio:Destroy()
end)
local part2 = Instance.new("Part", currentCamera)
part2.Transparency = 1
part2.CastShadow = false
part2.CanCollide = false
part2.Anchored = true
part2.CanTouch = false
part2.CanQuery = false
part2.CFrame = CFrame.new(0, v + 0.3, 0)

for i = 1, 2 do
	local part3 = Instance.new("Part", part2)
	part3.Name = "Part" .. i
	part3.Color = BrickColor.new("Cyan").Color
	part3.Material = Enum.Material.ForceField
	part3.CastShadow = false
	part3.CanCollide = false
	part3.Anchored = false
	part3.CanTouch = false
	part3.CanQuery = false
	part3.Transparency = 1
	part3.CFrame = part2.CFrame
	part3.Size = createVector(500, 0.05, 500)
	local specialMesh = Instance.new("SpecialMesh", part3)
	specialMesh.Scale = createVector(20, 1, 20)
	specialMesh.MeshType = Enum.MeshType.Brick
	local weld = Instance.new("Weld", part3)
	weld.Part0 = part2
	weld.Part1 = part3

	if i ~= 2 then
		continue
	end

	specialMesh.Scale = createVector(1000, 1, 1000)
	weld.C0 = CFrame.new(0, -0.5, 0)
	part3.Material = Enum.Material.SmoothPlastic
	part3.Transparency = 0
	part3.Color = color
end

workspace.Terrain:SetAttribute("SeaTheme", "Default")
workspace.Terrain:GetAttributeChangedSignal("SeaTheme"):Connect(function()
	local seaTheme = workspace.Terrain:GetAttribute("SeaTheme")
	local color2 = color
	local color3 = color
	local color4 = Color3.fromRGB(255, 255, 255)

	if seaTheme == "Default" then
		color2 = color
		color3 = BrickColor.new("Cyan").Color
		color4 = Color3.fromRGB(255, 255, 255)
	elseif seaTheme == "Cold" then
		color2 = Color3.fromRGB(126, 178, 255)
		color3 = Color3.fromRGB(125, 194, 255)
		color4 = Color3.fromRGB(178, 199, 255)
	elseif seaTheme == "Dark" then
		color2 = Color3.fromRGB(55, 108, 118)
		color3 = Color3.fromRGB(55, 108, 118)
		color4 = Color3.fromRGB(0, 117, 117)
	elseif seaTheme == "Halloween" then
		color2 = Color3.fromRGB(255, 115, 0)
		color3 = Color3.fromRGB(255, 152, 48)
		color4 = Color3.fromRGB(131, 84, 50)
	end

	TweenService:Create(water, TweenInfo.new(5), {
		Color = color2
	}):Play()
	TweenService:Create(part2.Part1, TweenInfo.new(5), {
		Color = color3
	}):Play()
	TweenService:Create(part2.Part2, TweenInfo.new(5), {
		Color = color2
	}):Play()
	TweenService:Create(clone, TweenInfo.new(5), {
		Color = color2
	}):Play()
	TweenService:Create(clone.Texture, TweenInfo.new(5), {
		Color3 = color4
	}):Play()
	TweenService:Create(clone2, TweenInfo.new(5), {
		Color = color2
	}):Play()
	TweenService:Create(clone2.Texture, TweenInfo.new(5), {
		Color3 = color4
	}):Play()
end)
local _ = game.Lighting.FogEnd
local _ = game.Lighting.FogColor
local cube = game.ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Cube")
local flag = false
local cframe2 = CFrame.Angles(0, 0, -1.5707963267948966)
CFrame.Angles(0, 2.7401669256310974, -1.5707963267948966)
local v9 = 0
local GetWaterHeightAtLocation = require(game.ReplicatedStorage.Util.GetWaterHeightAtLocation)
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local texture = clone.Texture
local textureOffset = clone.TextureOffset
local backOffset = clone.BackOffset
local backTexture = clone:FindFirstChild("BackTexture")
local WaterVolumes = require(game.ReplicatedStorage.Util.GetWaterHeightAtLocation.WaterVolumes)
local v10 = false
local v11 = nil
local v12 = 0
local v13 = true
local localCinematicWaterHeight = workspace:GetAttribute("LocalCinematicWaterHeight")
local v14 = 0
local v15 = -1
clone.ChildAdded:Connect(function(texture2)
	if texture2.Name == "BackTexture" and texture2:IsA("Texture") then
		backTexture = clone:FindFirstChild("BackTexture")
	end
end)
clone.ChildRemoved:Connect(function(child)
	if child == backTexture then
		backTexture = nil
	end
end)
workspace:GetAttributeChangedSignal("LocalCinematicWaterHeight"):Connect(function()
	localCinematicWaterHeight = workspace:GetAttribute("LocalCinematicWaterHeight")
	v13 = true
end)

if v2 then
	part.Parent = nil
else
	RunService:BindToRenderStep("Water", Enum.RenderPriority.Camera.Value + 1, function()
		local now = tick()
		currentCamera = workspace.CurrentCamera or currentCamera
		local cFrame = currentCamera.CFrame
		local position = cFrame.Position
		local v16 = typeof(localCinematicWaterHeight) == "number"
		local v17 = not v16 and position.Y < -500

		if v13 or now - v9 > 0.25 then
			v13 = false
			v9 = now
			local v18, v19, _, v20 = GetWaterHeightAtLocation(position)
			v11 = v20
			v12 = v18
			v10 = v19 and v20 == nil

			if v16 then
				v = localCinematicWaterHeight
			elseif v20 then
				v = -4
			elseif v19 then
				v = v18
			elseif v17 then
				v = -920
			else
				v = -4
			end

			for i = #v4, 1, -1 do
				local v21 = v4[i]
				local part3 = v21.Part

				if part3.Parent == nil then
					v5[part3] = nil
					table.remove(v4, i)
				else
					v21.InRange = 1500 + part3.Size.Magnitude * 0.5 > (part3.Position - position).Magnitude
				end
			end

			part2.CFrame = CFrame.new(
				floor(position.X / 5000 + 0.5) * 5000,
				v + 0.3,
				floor(position.Z / 5000 + 0.5) * 5000
			)

			if position.Y < v then
				part.CFrame = CFrame.new(position.X, v, position.Z) + createVector(0, -16, 0)

				if part.Parent ~= map then
					part.Parent = map
				end
			elseif part.Parent ~= nil then
				part.Parent = nil
			end
		end

		local v18 = v11

		if v18 and not WaterVolumes.containsPoint(v18, position) then
			v18 = nil
			v11 = nil
		end

		local v19

		if v18 then
			if v18.HalfSize.Y * 2 >= v18.MinSwimDepth then
				v19 = position.Y < v12
			else
				v19 = false
			end
		elseif position.Y < v then
			v19 = not (v17 or v10)
		else
			v19 = false
		end

		if v19 then
			if not flag then
				flag = true
				pcall(function()
					script.WaterBlur.Parent = Lighting
					script.WaterColorCorrection.Parent = Lighting
				end)
				SoundService.AmbientReverb = "UnderWater"
				cube.Parent = _WorldOrigin
			end

			cube.CFrame = CFrame.new(position.X, position.Y, position.Z, -1, 0, 0, 0, -1, 0, 0, 0, -1)

			if not v18 and part.Parent ~= map then
				part.Parent = map
				part.CFrame = CFrame.new(position.X, v, position.Z) + createVector(0, -16, 0)
			end
		elseif flag then
			flag = false
			pcall(function()
				Lighting.WaterBlur.Parent = script
				Lighting.WaterColorCorrection.Parent = script
			end)
			SoundService.AmbientReverb = "NoReverb"
			cube.Parent = nil
		end

		local v20 = position + cFrame.LookVector * 100
		local X = v20.X
		local Z = v20.Z
		local v21 = backTexture

		if not v21 then
			return
		end

		if now - v14 >= 0.05 then
			v14 = now
			local localTransparencyModifier = math.clamp((position.Y - 50) / 300, 0, 1)

			if math.abs(localTransparencyModifier - v15) >= 0.001 then
				v15 = localTransparencyModifier
				v21.LocalTransparencyModifier = localTransparencyModifier
				texture.LocalTransparencyModifier = localTransparencyModifier
			end
		end

		local cframe3 = CFrame.new(X, v + 0.1, Z)

		if v21.LocalTransparencyModifier == 1 then
			cframe3 *= CFrame.new(0, -1000, 0)
		end

		clone.CFrame = cframe3 * cframe2
		local value = textureOffset.Value
		local value2 = backOffset.Value
		local X2 = value.X
		local Z2 = value.Z
		local X3 = value2.X
		local Z3 = value2.Z
		texture.OffsetStudsU = Z + X2
		texture.OffsetStudsV = -X + Z2
		v21.OffsetStudsU = Z + X3
		v21.OffsetStudsV = -X + Z3
		local transparency = texture.Transparency

		for i = 1, #v4 do
			local v22 = v4[i]

			if not v22.InRange then
				continue
			end

			local X4 = v22.Offset.X
			local Y = v22.Offset.Y
			v22.Texture.OffsetStudsU = X4 + X2
			v22.Texture.OffsetStudsV = Y + Z2
			v22.BackTexture.OffsetStudsU = X4 + X3
			v22.BackTexture.OffsetStudsV = Y + Z3
			v22.Texture.Transparency = transparency
		end
	end)
end

local v16 = false
game.Lighting:GetPropertyChangedSignal("ClockTime"):Connect(function()
	local v17 = game.Lighting.ClockTime > 17.8 or game.Lighting.ClockTime < 5

	if v17 and not v16 then
		for _, child in pairs(part2:GetChildren()) do
			if child.Material == Enum.Material.ForceField then
				TweenService:Create(child, TweenInfo.new(5, Enum.EasingStyle.Linear), {
					Transparency = 0.75
				}):Play()
			end
		end
	elseif v16 and not v17 then
		for _, child in pairs(part2:GetChildren()) do
			if child.Material == Enum.Material.ForceField then
				TweenService:Create(child, TweenInfo.new(5, Enum.EasingStyle.Linear), {
					Transparency = 1
				}):Play()
			end
		end
	end

	v16 = v17
end)
local CollectionService = game:GetService("CollectionService")

local function registerWaterEffect(part3)
	if v5[part3] or part3.Parent == nil then
		return
	end

	if not part3:FindFirstChild("Texture") then
		local clone = texture:Clone()
		clone.Parent = part3
	end

	if not part3:FindFirstChild("BackTexture") then
		local v17 = backTexture

		if not v17 then
			return
		end

		local clone_2 = v17:Clone()
		clone_2.Parent = part3
	end

	local texture2 = part3:WaitForChild("Texture")
	local backTexture2 = part3:WaitForChild("BackTexture")
	local vector2 = Vector2.new(texture2.OffsetStudsU, texture2.OffsetStudsV)
	texture2:SetAttribute("Offset", vector2)
	backTexture2:SetAttribute("Offset", Vector2.new(backTexture2.OffsetStudsU, backTexture2.OffsetStudsV))
	v5[part3] = true
	table.insert(v4, {
		Part = part3,
		Texture = texture2,
		BackTexture = backTexture2,
		Offset = vector2,
		InRange = true
	})
end

local v17 = { Water.FOAM_TAG, Water.VOLUME_TAG }

-- equivalent calls inferred from this helper; original call sites unknown
local function wantsFoam(part3)
	return part3:IsA("BasePart") and part3:GetAttribute(Water.FOAM_ATTRIBUTE) ~= false
end

local function unregisterWaterEffect(instance)
	if not v5[instance] then
		return
	end

	for _, tag in v17 do
		if CollectionService:HasTag(instance, tag) then
			return
		end
	end

	v5[instance] = nil

	for i = #v4, 1, -1 do
		if v4[i].Part ~= instance then
			continue
		end

		table.remove(v4, i)
		break
	end
end

for _, tag in v17 do
	for _, part3 in CollectionService:GetTagged(tag) do
		if wantsFoam(part3) then
			registerWaterEffect(part3)
		end
	end

	local v18 = tag
	CollectionService:GetInstanceAddedSignal(tag):Connect(function(part3)
		task.wait(1)

		if CollectionService:HasTag(part3, v18) and wantsFoam(part3) then
			registerWaterEffect(part3)
		end
	end)
	CollectionService:GetInstanceRemovedSignal(tag):Connect(unregisterWaterEffect)
end

local Wind = require(script.Wind)
Wind()
local Fireflies = require(script.Fireflies)
Fireflies()