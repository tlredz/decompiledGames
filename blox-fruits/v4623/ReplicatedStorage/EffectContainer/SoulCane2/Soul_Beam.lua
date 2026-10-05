local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local soulBeam = FX:WaitForChild("SoulCane").SoulBeam
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local _ = Util.LightningBolt

local function putFolder(parent, name: string)
	local v = parent:FindFirstChild(name)

	if v == nil then
		v = Instance.new("Folder")
		v.Name = name
		v.Parent = parent
	end

	return v
end

local function putValueAsValueObject(parent, name: string, p, value: number)
	local v2 = {
		boolean = "BoolValue",
		CFrame = "CFrameValue",
		Color3 = "Color3Value",
		number = "NumberValue",
		Instance = "ObjectValue",
		Ray = "RayValue",
		string = "StringValue",
		Vector3 = "Vector3Value"
	}
	local instance = parent:FindFirstChild(name)

	if instance == nil then
		instance = Instance.new(v2[typeof(p)])
		instance.Name = name
		instance.Parent = parent
	end

	instance.Value = p
	destroyAfter(instance, value or 60)
end

local function getValueObject(instance, childName)
	return instance:FindFirstChild(childName)
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.FilterDescendantsInstances = { Workspace._WorldOrigin, Workspace.Characters, Workspace.Enemies }

function Flipbook(instance, list, p: number)
	local decal = instance:FindFirstChildOfClass("Decal")

	if decal and list then
		task.spawn(function()
			for i = 1, #list do
				decal.Texture = list[i]
				task.wait(1 / p)
			end

			decal.Parent:Destroy()
		end)
	end
end

function EmitAll(folder)
	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant.ClassName ~= "ParticleEmitter" then
			continue
		end

		if string.find(descendant.Parent.Name, "Ground_") or string.find(descendant.Parent.Name, "Dust") then
			local Workspace2 = game:GetService("Workspace")

			if Workspace2:Raycast(folder.Position, createVector(0, -5, 0), raycastParams) then
				descendant:Emit(descendant:GetAttribute("EmitCount"))
			end
		else
			descendant:Emit(descendant:GetAttribute("EmitCount"))
		end
	end
end

local v = {
	"rbxassetid://12558376366",
	"rbxassetid://12558376101",
	"rbxassetid://12558375916",
	"rbxassetid://12558375736",
	"rbxassetid://12558375599",
	"rbxassetid://12558375321",
	"rbxassetid://12558375128",
	"rbxassetid://12558374890",
	"rbxassetid://12558374679"
}
local v2 = {
	"rbxassetid://12623808865",
	"rbxassetid://12623808643",
	"rbxassetid://12623808232",
	"rbxassetid://12623807857",
	"rbxassetid://12623807574",
	"rbxassetid://12623807260",
	"rbxassetid://12623806846",
	"rbxassetid://12623806521",
	"rbxassetid://12623806264",
	"rbxassetid://12623805856"
}
local Effect = require(game.ReplicatedStorage.Effect)
return function(data)
	local _ = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local _ = hrp.Parent
	local currentCamera = Workspace.CurrentCamera

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 600 then
		return
	end

	local magnitude = (hrp.Position - data.EndPosition).Magnitude
	local part = Instance.new("Part")
	part.TopSurface = 0
	part.BottomSurface = 0
	part.Material = "Neon"
	part.Anchored = true
	part.CanCollide = false
	part.Size = createVector(1, 1, 1)
	part.Color = Color3.fromRGB(200, 255, 255)
	part.CFrame = CFrame.new(hrp.CFrame * createVector(1, 1, -5), data.EndPosition)
	local specialMesh = Instance.new("SpecialMesh")
	specialMesh.MeshType = "Sphere"
	specialMesh.Scale = createVector(3, 3, 80)
	specialMesh.Offset = createVector(0, 0, -40)
	specialMesh.Parent = part
	part.Parent = Workspace._WorldOrigin
	local tween = TweenService:Create(specialMesh, TweenInfo.new(0.3), {
		Scale = createVector(0, 0, 80)
	})
	tween.Completed:Connect(function()
		part:Destroy()
	end)
	tween:Play()
	Effect.new("BasicExplosion"):replicate({
		Position = data.EndPosition,
		Size = { 40, 0 },
		Quality = 3,
		Duration = 0.5,
		Color = {
			Inner = Color3.new(1, 1, 1),
			Outer = Color3.new(0.8, 1, 1)
		}
	})
	Util.Sound:Play("SlightZap", hrp)
	local position = data.CFrame.Position
	local lookVector = data.CFrame.LookVector
	local parent = _WorldOrigin
	local cFrame = CFrame.lookAt(createVector(0, 0, 0), lookVector) + position
	local clone = soulBeam:FindFirstChild("Main"):Clone()
	clone.CFrame = cFrame
	clone.Shockwave.Position = Vector3.new(0, 0, -magnitude + 2.75)
	clone.Parent = parent
	destroyAfter(clone, 5)
	TweenService:Create(clone:FindFirstChild("Moveable"), TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
		Position = createVector(0, 0, -30)
	}):Play()
	task.delay(0.1, function()
		local slashes = clone:FindFirstChild("Moveable"):FindFirstChild("Slashes")
		slashes.Enabled = false
	end)
	EmitAll(clone)
	local clone2 = soulBeam:FindFirstChild("Wind"):Clone()
	clone2.CFrame = cFrame * CFrame.new(0, 0, -15) * CFrame.Angles(
		3.141592653589793,
		0,
		(math.rad((Random.new():NextNumber(-180, 180))))
	)
	clone2.Parent = parent
	destroyAfter(clone2, 5)
	Flipbook(clone2, v, 45)
	local clone3 = soulBeam:FindFirstChild("Swirl"):Clone()
	clone3.CFrame = cFrame * CFrame.new(0, 0, -23) * CFrame.Angles(1.5707963267948966, 0, 0)
	clone3.Parent = parent
	destroyAfter(clone3, 5)
	TweenService:Create(clone3, TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
		Size = createVector(12, 31.52, 12),
		CFrame = clone3.CFrame * CFrame.Angles(0, 4.363323129985824, 0)
	}):Play()
	task.delay(0.2, function()
		TweenService:Create(clone3, TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
	end)
	task.delay(0.4, function()
		clone3:Destroy()
	end)
	local raycastResult = Workspace:Raycast(
		(cFrame * CFrame.new(0, 0, -20)).Position,
		createVector(0, -6, 0),
		raycastParams
	)

	if raycastResult then
		local clone4 = soulBeam:FindFirstChild("GroundWind"):Clone()
		clone4.CFrame = CFrame.new(raycastResult.Position, raycastResult.Position + cFrame.LookVector) * CFrame.Angles(
			0,
			-1.5707963267948966,
			0
		)
		clone4.Parent = parent
		destroyAfter(clone4, 5)
		Flipbook(clone4, v2, 60)
	end

	task.delay(0.8, function()
		clone:Destroy()
	end)
end