local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
local random = Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local lightningBolt3 = Util.LightningBolt3

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

local function AllVFX(clone, enabled2, p2)
	local function Emit(folder, enabled, duration)
		for _, effect in ipairs(folder:GetDescendants()) do
			if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
				continue
			end

			effect.Enabled = enabled
		end

		if duration then
			task.delay(duration, function()
				for _, effect in ipairs(folder:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
						continue
					end

					effect.Enabled = false
				end
			end)
		end
	end

	if typeof(clone) ~= "table" then
		Emit(clone, enabled2, p2)
		return
	end

	for _, item in clone do
		Emit(item, enabled2, p2)
	end
end

function EmitAll(items)
	local function Emit(folder)
		for _, emitter in ipairs(folder:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			if emitter:GetAttribute("EmitDelay") then
				local v = emitter
				task.delay(emitter:GetAttribute("EmitDelay"), function()
					v:Emit(v:GetAttribute("EmitCount"))
				end)
			else
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end
	end

	if typeof(items) ~= "table" then
		Emit(items)
		return
	end

	for _, item in items do
		Emit(item)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fn(p, p2)
	return random:NextNumber(p, p2)
end

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

local v = {
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
return function(data)
	local player = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local parent = hrp.Parent
	local currentCamera = Workspace.CurrentCamera

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 1500 then
		return
	end

	Util.Sound:Play("KiBlastFireShort", hrp)
	Util.Sound:Play("TremorErupt", hrp)
	local parent2 = _WorldOrigin
	local lightningBolt = lightningBolt3
	local unit = (data.MousePos - hrp.Position).Unit
	local v4 = CFrame.lookAt(createVector(0, 0, 0), unit) + hrp.Position
	local v5 = hrp.Position + unit * data.Distance
	local cFrame = CFrame.new(v4.Position, v5) * CFrame.new(0, 0, -5)
	local magnitude = (v4.Position - v5).Magnitude
	Util.Sound:Play("KiBlastFireShort", cFrame)
	Util.Sound:Play("TremorErupt", cFrame)
	local clone = FX:WaitForChild("Koko")["Injection Shot"].ShootEffect:Clone()
	clone.CFrame = cFrame
	clone.Parent = parent2
	EmitAll(clone)
	destroyAfter(clone, 2)
	local clone2 = FX:WaitForChild("Koko")["Injection Shot"].Projectile:Clone()
	clone2.CFrame = cFrame * CFrame.new(0, 0, -2)
	clone2.Parent = parent2
	destroyAfter(clone2, 3)
	AllVFX(clone2, true)
	local clone3 = FX:WaitForChild("Koko")["Injection Shot"].Comet:Clone()
	clone3.CFrame = cFrame * CFrame.Angles(3.141592653589793, 0, 0)
	clone3.Size = createVector(10, 10, 25)
	clone3.Parent = parent2
	destroyAfter(clone3, 3)
	TweenService:Create(clone3, TweenInfo.new(magnitude / 1400, Enum.EasingStyle.Linear), {
		Position = v5
	}):Play()
	local clone4 = FX:WaitForChild("Koko")["Injection Shot"].Comet:Clone()
	clone4.CFrame = cFrame * CFrame.new(0, 0, -magnitude / 1.5) * CFrame.Angles(3.141592653589793, 0, 0)
	clone4.Size = Vector3.new(magnitude / 10, magnitude / 10, magnitude / 2)
	clone4.Parent = parent2
	local tween = TweenService:Create(clone4, TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
		Size = Vector3.new(0, 0, magnitude)
	})
	tween:Play()
	tween:Destroy()
	destroyAfter(clone4, 0.4)
	local clone5 = FX:WaitForChild("Koko").Ring2:Clone()
	clone5.CFrame = cFrame * CFrame.new(0, 0, -40) * CFrame.Angles(1.5707963267948966, 0, 0)
	clone5.Size = Vector3.new(0, magnitude / 2, 0)
	clone5.Parent = _WorldOrigin
	local tween2 = TweenService:Create(clone5, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = createVector(20, 0, 20),
		CFrame = clone5.CFrame * CFrame.new(0, 70, 0)
	})
	tween2:Play()
	tween2:Destroy()
	destroyAfter(clone5, 0.3)
	local tween3 = TweenService:Create(clone2, TweenInfo.new(magnitude / 1400, Enum.EasingStyle.Linear), {
		Position = v5
	})
	tween3:Play()
	local color = Color3.fromRGB(93, 123, 255)

	for _ = 1, 4 do
		local v7 = {
			WorldPosition = v4.Position,
			WorldAxis = createVector(0, 1, 0)
		}
		local v8 = lightningBolt.new(v7, {
			WorldPosition = v5,
			WorldAxis = createVector(0, 0, 0)
		}, 15)
		v8.PulseSpeed = 6
		v8.Frequency = 2
		v8.PulseLength = 1
		v8.FadeLength = 0.3
		v8.MinRadius = 5
		v8.MaxRadius = 10
		v8.Thickness = 1.5
		v8.Color = ColorSequence.new(color, color)
	end

	if player == game.Players.LocalPlayer then
		Util.CameraShaker:ShakeOnce(6, 4, 0.04, 0.8, createVector(1, 1, 1), createVector(1, 1, 5))
	end

	local clone6 = FX:WaitForChild("Koko").Sphere:Clone()
	clone6.CFrame = parent.RightHand.CFrame * CFrame.new(0, -parent.RightHand.Size.Y / 2, 0)
	clone6.CFrame = CFrame.new(clone6.Position, v5)
	clone6.Size = createVector(20, 20, 20)
	clone6.Color = color
	clone6.Parent = parent2
	local tween4 = TweenService:Create(clone6, TweenInfo.new(magnitude / 1400), {
		Size = Vector3.new(0, 0, (clone6.Position - v5).magnitude),
		CFrame = CFrame.new(clone6.Position, v5) * CFrame.new(0, 0, magnitude / -2)
	})
	tween4:Play()
	tween4:Destroy()
	destroyAfter(clone6, magnitude / 1400)
	local v7 = fn(-0.05, 0.05) -- equivalent call inferred; original call site unknown

	for i = 1, 6 do
		local clone7 = FX:WaitForChild("Koko").Crescent:Clone()
		clone7.CFrame = cFrame * CFrame.new(0, 0, -magnitude / 6 * i) * CFrame.Angles(
			math.rad((random:NextNumber(-20, 20))),
			0,
			(math.rad((random:NextNumber(-360, 360))))
		)
		clone7.Parent = _WorldOrigin
		Flipbook(clone7, v, fn(25, 45))
		local tween5 = TweenService:Create(
			clone7:FindFirstChild("Mesh"),
			TweenInfo.new(0.6, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
			{
				Scale = Vector3.new(0.1 + v7, 0.1 + v7, 0.6 + v7)
			}
		)
		tween5:Play()
		tween5:Destroy()
	end

	tween3.Completed:Connect(function()
		AllVFX(clone2, false)
		destroyAfter(clone2, 2)
		TweenService:Create(clone3, TweenInfo.new(magnitude / 1400, Enum.EasingStyle.Linear), {
			Size = createVector(0, 0, 0)
		}):Play()
		destroyAfter(clone3, magnitude / 1400)
	end)
end