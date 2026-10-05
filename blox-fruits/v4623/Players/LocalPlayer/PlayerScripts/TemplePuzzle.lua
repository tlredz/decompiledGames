local createVector = vector.create
local templeofTime = nil
local total = 0

while not templeofTime do
	templeofTime = game.ReplicatedStorage.MapStash:FindFirstChild("Temple of Time") or workspace.Map:FindFirstChild("Temple of Time")
	total += task.wait()

	if total >= 30 then
		return
	end
end

if not templeofTime then
	return
end

local Realm = require(game.ReplicatedStorage.Util.Realm)

if Realm.getIfCurrentRealmHasTagAsync("IsCelebrationEvent") then
	return
end

local templeHitboxes = workspace:WaitForChild("Map"):WaitForChild("TempleHitboxes", 99999)

for _, part in pairs(templeHitboxes:GetChildren()) do
	if not part:IsA("BasePart") then
		continue
	end

	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Transparency = 1
end

local TweenService = game:GetService("TweenService")
local v = {
	"Human",
	"Skypiea",
	"Fishman",
	"Mink",
	"Cyborg",
	"Ghoul"
}

for _, v2 in pairs(v) do
	templeofTime:WaitForChild(v2 .. "Corridor")
end

local function ActivateMural(p, activated)
	TweenService:Create(p.Mesh, TweenInfo.new(0.5), {
		VertexColor = activated and createVector(3, 0.6, 0) or createVector(1, 1, 1)
	}):Play()
end

for _, child in pairs(templeofTime:WaitForChild("Murals"):GetChildren()) do
	local v2 = child
	child:GetAttributeChangedSignal("Activated"):Connect(function()
		ActivateMural(v2, v2:GetAttribute("Activated"))
	end)
	ActivateMural(child, child:GetAttribute("Activated"))
end

local persistentStuff = templeofTime:WaitForChild("PersistentStuff")
local proximityPrompt = Instance.new("ProximityPrompt", templeofTime:WaitForChild("Lever").Prompt)
proximityPrompt:AddTag("ProximityPrompt")
proximityPrompt.HoldDuration = 2
proximityPrompt.RequiresLineOfSight = false
proximityPrompt.MaxActivationDistance = 8
proximityPrompt.Triggered:Connect(function()
	if game.ReplicatedStorage.Remotes.CommF_:InvokeServer("CheckTempleDoor") then
		proximityPrompt:Destroy()
		local numberValue = Instance.new("NumberValue")
		numberValue.Changed:Connect(function(_)
			templeofTime.Lever.Lever.CFrame = templeofTime.Lever.Mid.CFrame * CFrame.Angles(0, 0, -1.5707963267948966) * CFrame.Angles(
				math.rad(numberValue.Value * 60 - 45),
				0,
				0
			) * CFrame.new(0, 3.6, 0)
		end)
		local Sound = require(game.ReplicatedStorage.Util.Sound)
		Sound:Play("LeverSFX", templeofTime.Lever.Mid)
		local Sound2 = require(game.ReplicatedStorage.Util.Sound)
		Sound2:Play("MainDoorSFX", persistentStuff.MainDoorSound)
		TweenService:Create(numberValue, TweenInfo.new(0.4), {
			Value = 1
		}):Play()
		TweenService:Create(persistentStuff.MainDoor1, TweenInfo.new(4.5, Enum.EasingStyle.Linear), {
			CFrame = persistentStuff.MainDoor1.CFrame * CFrame.new(0, -41.953, 0)
		}):Play()
		local tween = TweenService:Create(persistentStuff.MainDoor2, TweenInfo.new(4.5, Enum.EasingStyle.Linear), {
			CFrame = persistentStuff.MainDoor2.CFrame * CFrame.new(0, -41.953, 0)
		})
		tween:Play()
		tween.Completed:Connect(function()
			persistentStuff.MainDoor1.Transparency = 1
			persistentStuff.MainDoor1.CanCollide = false
			persistentStuff.MainDoor1.CanQuery = false
			persistentStuff.MainDoor2.Transparency = 1
			persistentStuff.MainDoor2.CanCollide = false
			persistentStuff.MainDoor2.CanQuery = false
		end)
		game.Debris:AddItem(numberValue, 2)

		for _, soundId in pairs(templeofTime:GetDescendants()) do
			if soundId:IsA("SoundId") and soundId:GetAttribute("SoundId") then
				soundId.SoundId = soundId:GetAttribute("SoundId")
			end
		end
	else
		local Notification = require(game.ReplicatedStorage.Notification)
		Notification.new("<Color=Red>You lack the strength to move it!<Color=/>"):Display()
	end
end)

function UpdateDoor(instance)
	if instance:GetAttribute("State") == "Open" then
		local numberValue = Instance.new("NumberValue")
		numberValue.Changed:Connect(function()
			instance.Door.RightDoor:SetPrimaryPartCFrame(instance.Door.RightHinge.CFrame * CFrame.Angles(
				0,
				math.rad(numberValue.Value),
				0
			))
			instance.Door.LeftDoor:SetPrimaryPartCFrame(instance.Door.LeftHinge.CFrame * CFrame.Angles(
				0,
				-math.rad(numberValue.Value),
				0
			))
		end)
		TweenService:Create(numberValue, TweenInfo.new(0.4), {
			Value = 110
		}):Play()
		TweenService:Create(instance.Entrance, TweenInfo.new(0.4), {
			Color = Color3.new(1, 1, 1)
		}):Play()
		game.Debris:AddItem(numberValue, 1)
	else
		local numberValue = Instance.new("NumberValue")
		numberValue.Value = 110
		numberValue.Changed:Connect(function()
			instance.Door.RightDoor:SetPrimaryPartCFrame(instance.Door.RightHinge.CFrame * CFrame.Angles(
				0,
				math.rad(numberValue.Value),
				0
			))
			instance.Door.LeftDoor:SetPrimaryPartCFrame(instance.Door.LeftHinge.CFrame * CFrame.Angles(
				0,
				-math.rad(numberValue.Value),
				0
			))
		end)
		TweenService:Create(numberValue, TweenInfo.new(0.4), {
			Value = 0
		}):Play()
		TweenService:Create(instance.Entrance, TweenInfo.new(0.4), {
			Color = Color3.new(0, 0, 0)
		}):Play()
		game.Debris:AddItem(numberValue, 1)
	end
end

for _, v2 in pairs(v) do
	local child = templeofTime:FindFirstChild(v2 .. "Corridor")

	if not child then
		continue
	end

	local door = child:FindFirstChild("Door")

	if not door then
		continue
	end

	UpdateDoor(door)
	local v4 = door
	door:GetAttributeChangedSignal("State"):Connect(function()
		UpdateDoor(v4)
	end)
end

task.spawn(function()
	local clock = templeofTime:WaitForChild("Clock")
	clock.MinutesAfterNoon.Changed:Connect(function()
		local value = templeofTime.Clock.MinutesAfterNoon.Value
		local v2 = value / 60 % 12
		local v3 = value % 60
		clock.Hour.CFrame = clock.Center.CFrame * CFrame.Angles(0, math.rad(90 + v2 / 12 * 360), 1.5707963267948966) * CFrame.new(
			0,
			clock.Hour.Size.Y / 2 - 1.2625,
			0
		)
		clock.Minute.CFrame = clock.Center.CFrame * CFrame.Angles(0, math.rad(90 + v3 / 60 * 360), 1.5707963267948966) * CFrame.new(
			0,
			clock.Minute.Size.Y / 2 - 1.2625,
			0
		)
	end)
end)
local Maid = require(game.ReplicatedStorage.Util.Maid)
local maid = Maid.new()
game.ReplicatedStorage.Remotes.TempleObby.OnClientEvent:Connect(function(p, p2, position)
	if p == "Stop" then
		pcall(function()
			local RunService = game:GetService("RunService")
			RunService:UnbindFromRenderStep("CloudObby")
		end)
		maid:DoCleaning()
		workspace.Gravity = 196.2
	elseif p == "Start" then
		pcall(function()
			local RunService = game:GetService("RunService")
			RunService:UnbindFromRenderStep("CloudObby")
		end)
		maid:DoCleaning()
		local Global = require(game.ReplicatedStorage.Global)
		local encoded = Global.Encode(p2)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = { encoded[1].Part.Parent }
		raycastParams.FilterType = Enum.RaycastFilterType.Whitelist

		for _, v2 in pairs(encoded) do
			if v2.Moving then
				local clone = v2.Part:Clone()
				v2.Part.CanCollide = false
				v2.Part.Transparency = 1
				maid:GiveTask(clone)
				clone.Parent = v2.Part
				v2.Part = clone
				local realCFrame = v2.Part:GetAttribute("RealCFrame")
				local bodyGyro = Instance.new("BodyGyro", v2.Part)
				bodyGyro.CFrame = realCFrame
				bodyGyro.MaxTorque = createVector(10000000, 10000000, 10000000)
				local bodyPosition = Instance.new("BodyPosition", v2.Part)
				bodyPosition.Position = realCFrame.Position
				bodyPosition.MaxForce = createVector(10000000, 10000000, 10000000)
				v2.Part.Anchored = false
				local TweenService2 = game:GetService("TweenService")
				local tween = TweenService2:Create(
					bodyPosition,
					TweenInfo.new(v2.Moving.Length / 2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{
						Position = (realCFrame * CFrame.new(-v2.Moving.Speed, 0, 0)).Position
					}
				)
				tween:Play()
				local v4 = v2
				maid:GiveTask(tween.Completed:Connect(function()
					local TweenService3 = game:GetService("TweenService")
					TweenService3:Create(
						bodyPosition,
						TweenInfo.new(v4.Moving.Length, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
						{
							Position = (realCFrame * CFrame.new(v4.Moving.Speed, 0, 0)).Position
						}
					):Play()
				end))
			end

			if v2.Vanishes then
				local _ = v2.Part.CFrame
				local TweenService2 = game:GetService("TweenService")
				local tween = TweenService2:Create(
					v2.Part,
					TweenInfo.new(v2.Vanishes.Lifetime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
					{
						Transparency = 1
					}
				)
				local TweenService3 = game:GetService("TweenService")
				local tween2 = TweenService3:Create(
					v2.Part,
					TweenInfo.new(v2.Vanishes.Lifetime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
					{
						Transparency = 0
					}
				)
				tween:Play()
				local v3 = v2
				maid:GiveTask(tween.Completed:Connect(function()
					v3.Part.CanCollide = false
					wait(1)
					v3.Part.CanCollide = true
					tween2:Play()
				end))
				maid:GiveTask(tween2.Completed:Connect(function()
					wait(1.5)
					tween:Play()
				end))
			end

			v2.Position = v2.Part.Position.Y + v2.Part.Size.Y / 2
		end

		local RunService = game:GetService("RunService")
		RunService:BindToRenderStep("CloudObby", 100, function(_)
			local localPlayer = game.Players.LocalPlayer

			if not (localPlayer and localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid")) then
				return
			end

			local humanoidRootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			workspace.Gravity = 137.33999999999997

			if humanoidRootPart.Position.Y < position.Y - 100 then
				humanoidRootPart.CFrame = CFrame.new(position)
				humanoidRootPart.Velocity = createVector(0, 0, 0)
			end
		end)
	end
end)