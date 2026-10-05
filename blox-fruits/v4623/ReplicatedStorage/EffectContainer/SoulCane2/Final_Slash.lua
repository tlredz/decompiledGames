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
local soulSlashes = FX:WaitForChild("SoulCane").SoulSlashes
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
	"rbxassetid://12873565749",
	"rbxassetid://12873565530",
	"rbxassetid://12873565362",
	"rbxassetid://12873565158",
	"rbxassetid://12873564996",
	"rbxassetid://12873564842",
	"rbxassetid://12873564660",
	"rbxassetid://12873564492",
	"rbxassetid://12873564342",
	"rbxassetid://12873564135",
	"rbxassetid://12873563962",
	"rbxassetid://12873563819",
	"rbxassetid://12873563705",
	"rbxassetid://12873563504",
	"rbxassetid://12873563313",
	"rbxassetid://12873563119",
	"rbxassetid://12873562850",
	"rbxassetid://12873562575",
	"rbxassetid://12873562396",
	"rbxassetid://12873562177",
	"rbxassetid://12873561995",
	"rbxassetid://12873561866"
}
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

	task.wait(0.1)
	Util.Sound:Play("QuickSlice", hrp)
	local origin = data.origin
	local fireDir = data.fireDir
	local parent = _WorldOrigin
	local cFrame = CFrame.lookAt(createVector(0, 0, 0), fireDir) + origin
	local clone = soulSlashes:FindFirstChild("LastParticles"):Clone()
	clone.CFrame = cFrame
	clone.Parent = parent
	destroyAfter(clone, 2)
	EmitAll(clone)
	local clone2 = soulSlashes:FindFirstChild("Slash"):Clone()
	clone2.CFrame = cFrame * CFrame.Angles(0, 0, 0) * CFrame.Angles(0, -1.7453292519943295, 0)
	local mesh = clone2:FindFirstChild("Mesh")
	mesh.Scale = createVector(0.06, 0.06, 0.06)
	clone2.Parent = parent
	destroyAfter(clone2, 5)
	TweenService:Create(clone2, TweenInfo.new(0.55, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
		CFrame = cFrame * CFrame.new(0, 0, -50) * CFrame.Angles(0, 0, 0) * CFrame.Angles(0, -1.7453292519943295, 0)
	}):Play()
	TweenService:Create(
		clone2:FindFirstChild("Mesh"),
		TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{
			Scale = createVector(0.22, 0.22, 0.22)
		}
	):Play()
	Flipbook(clone2, v, 90)
end