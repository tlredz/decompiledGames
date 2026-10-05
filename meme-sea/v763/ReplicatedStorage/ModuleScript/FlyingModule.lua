local createVector = vector.create
local Setting = require(game.ReplicatedStorage.ModuleScript:WaitForChild("Setting"))
require(game.ReplicatedStorage.Modules:WaitForChild("Mouse"))

local function ClearVelocity(folder)
	for _, descendant in pairs(folder:GetDescendants()) do
		if not (descendant:IsA("BodyVelocity") or descendant:IsA("BodyGyro")) then
			continue
		end

		local Debris = game:GetService("Debris")
		Debris:AddItem(descendant, 0)
	end
end

local FlyingModule = {}

function FlyingModule.StartFlying(...)
	local v, v2, v3, v4, v5, v6, v7, v8, v9 = ...
	local v10 = Setting.Setting.FlySpeed[v3.Name]
	ClearVelocity(v2)

	if v2:GetAttribute("IsFlying") == nil then
		v2:SetAttribute("IsFlying", true)
	end

	if v9.Value ~= v8 then
		v9.Value = v8
	end

	v6.Visible = true
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = createVector(40000, 40000, 40000)
	bodyVelocity.Parent = v2.HumanoidRootPart
	v5:FireServer(1)
	local connectionsByName = {}
	local health = v2.Humanoid.Health
	connectionsByName[v.Name] = v2.Humanoid.HealthChanged:Connect(function(p)
		if not (p < health) then
			return
		end

		if v2:GetAttribute("IsFlying") == true then
			v2:SetAttribute("IsFlying", false)
		end

		v7.Value = true
		v5:FireServer(2)

		if v2 and v2:FindFirstChild("HumanoidRootPart") then
			for _, child in pairs(v2.HumanoidRootPart:GetChildren()) do
				if not (child:IsA("BodyVelocity") or child:IsA("BodyGyro")) then
					continue
				end

				local Debris = game:GetService("Debris")
				Debris:AddItem(child, 0)
			end
		end

		v9.Value = "None"
		local Setting2 = require(game.ReplicatedStorage.ModuleScript:WaitForChild("Setting"))
		Setting2.StopAnimation(v2, v3.Name)
		delay(2.1, function()
			if v2:GetAttribute("IsFlying") == false then
				v2:SetAttribute("IsFlying", nil)
			end
		end)

		if connectionsByName[v.Name] ~= nil then
			connectionsByName[v.Name]:Disconnect()
		end
	end)
	coroutine.resume(coroutine.create(function()
		for _ = 1, 1e999 do
			if v2:GetAttribute("IsFlying") == true then
				v2.HumanoidRootPart.CFrame = CFrame.new(
					v2.HumanoidRootPart.Position,
					(Vector3.new(v4.Hit.p.x, v2.HumanoidRootPart.Position.Y, v4.Hit.p.z))
				)
				bodyVelocity.Velocity = v4.Hit.lookVector * v10
				wait()
			else
				if connectionsByName[v.Name] == nil then
					break
				end

				connectionsByName[v.Name]:Disconnect()
				break
			end
		end
	end))
end

function FlyingModule.StartFlying_Dough(...)
	local v, v2, v3, v4, v5, v6, v7, v8, v9, v10 = ...
	local v11 = Setting.Setting.FlySpeed[v3.Name]
	local mouse = v:GetMouse()
	ClearVelocity(v2)

	if v2:GetAttribute("IsFlying") == nil then
		v2:SetAttribute("IsFlying", true)
	end

	if v9.Value ~= v8 then
		v9.Value = v8
	end

	v6.Visible = true
	local bodyGyro = Instance.new("BodyGyro", v2.HumanoidRootPart)
	bodyGyro.MaxTorque = createVector(100000, 100000, 100000)
	bodyGyro.CFrame = mouse.Hit
	bodyGyro.D = 100
	bodyGyro.P = 20000
	local bodyVelocity = Instance.new("BodyVelocity", v2.HumanoidRootPart)
	bodyVelocity.MaxForce = createVector(10000, 0, 10000)
	bodyVelocity.P = 500000
	v5:FireServer(1)
	local connectionsByName = {}
	local health = v2.Humanoid.Health
	connectionsByName[v.Name] = v2.Humanoid.HealthChanged:Connect(function(p)
		if not (p < health) then
			return
		end

		if v2:GetAttribute("IsFlying") == true then
			v2:SetAttribute("IsFlying", false)
		end

		v7.Value = true
		v5:FireServer(2)

		if v2 and v2:FindFirstChild("HumanoidRootPart") then
			for _, child in pairs(v2.HumanoidRootPart:GetChildren()) do
				if not (child:IsA("BodyVelocity") or child:IsA("BodyGyro")) then
					continue
				end

				local Debris = game:GetService("Debris")
				Debris:AddItem(child, 0)
			end
		end

		v9.Value = "None"
		local Setting2 = require(game.ReplicatedStorage.ModuleScript:WaitForChild("Setting"))
		Setting2.StopAnimation(v2, v3.Name)
		local PlaySound = require(game.ReplicatedStorage.ModuleScript:WaitForChild("PlaySound"))
		PlaySound.DeleteSound(v, v10)
		delay(2.1, function()
			if v2:GetAttribute("IsFlying") == false then
				v2:SetAttribute("IsFlying", nil)
			end
		end)

		if connectionsByName[v.Name] ~= nil then
			connectionsByName[v.Name]:Disconnect()
		end
	end)

	repeat
		wait()
		local lookVector = v4.CFrame.LookVector
		local cframe = CFrame.new(
			v2.HumanoidRootPart.Position,
			v2.HumanoidRootPart.Position + lookVector * createVector(1, 0, 1)
		)
		bodyVelocity.Velocity = cframe.LookVector * v11
		bodyGyro.CFrame = cframe
	until v2:GetAttribute("IsFlying") == false or v2:GetAttribute("IsFlying") == nil or v2.Humanoid.Health <= 0

	if connectionsByName[v.Name] ~= nil then
		connectionsByName[v.Name]:Disconnect()
	end
end

function FlyingModule.StartFlying_Ice(...)
	local v, v2, v3, v4, v5, v6, v7, v8, v9, v10 = ...
	ClearVelocity(v2)
	local v11 = Setting.Setting.FlySpeed[v3.Name]

	if v2:GetAttribute("IsFlying") == nil then
		v2:SetAttribute("IsFlying", true)
	end

	if v9.Value ~= v8 then
		v9.Value = v8
	end

	v6.Visible = true
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = createVector(10000, 10000, 10000)
	bodyVelocity.Parent = v2.HumanoidRootPart
	v5:FireServer(1)
	local connectionsByName = {}
	local health = v2.Humanoid.Health
	connectionsByName[v.Name] = v2.Humanoid.HealthChanged:Connect(function(p)
		if not (p < health) then
			return
		end

		if v2:GetAttribute("IsFlying") == true then
			v2:SetAttribute("IsFlying", false)
		end

		v7.Value = true
		v5:FireServer(2)

		if v2 and v2:FindFirstChild("HumanoidRootPart") then
			for _, child in pairs(v2.HumanoidRootPart:GetChildren()) do
				if not (child:IsA("BodyVelocity") or child:IsA("BodyGyro")) then
					continue
				end

				local Debris = game:GetService("Debris")
				Debris:AddItem(child, 0)
			end
		end

		v9.Value = "None"
		local Setting2 = require(game.ReplicatedStorage.ModuleScript:WaitForChild("Setting"))
		Setting2.StopAnimation(v2, v3.Name)
		local PlaySound = require(game.ReplicatedStorage.ModuleScript:WaitForChild("PlaySound"))
		PlaySound.DeleteSound(v, v10)
		delay(2.1, function()
			if v2:GetAttribute("IsFlying") == false then
				v2:SetAttribute("IsFlying", nil)
			end
		end)

		if connectionsByName[v.Name] ~= nil then
			connectionsByName[v.Name]:Disconnect()
		end
	end)
	coroutine.resume(coroutine.create(function()
		for _ = 1, 1e999 do
			if v2:GetAttribute("IsFlying") == true then
				local lookVector = v4.CFrame.LookVector
				local cframe = CFrame.new(
					v2.HumanoidRootPart.Position,
					v2.HumanoidRootPart.Position + lookVector * createVector(1, 1, 1)
				)
				local cframe2 = CFrame.new(
					v2.HumanoidRootPart.Position,
					v2.HumanoidRootPart.Position + lookVector * createVector(1, 0, 1)
				)
				bodyVelocity.Velocity = cframe.LookVector * v11
				v2.HumanoidRootPart.CFrame = cframe2
				wait()
			else
				if connectionsByName[v.Name] == nil then
					break
				end

				connectionsByName[v.Name]:Disconnect()
				break
			end
		end
	end))
end

function FlyingModule.StopFlying(...)
	local _, v, _, v2, _, v3, _, v4 = ...

	if v:GetAttribute("IsFlying") == true then
		v:SetAttribute("IsFlying", false)
	end

	v3.Value = true
	v2:FireServer(2)

	for _, child in pairs(v.HumanoidRootPart:GetChildren()) do
		if not (child:IsA("BodyVelocity") or child:IsA("BodyGyro")) then
			continue
		end

		local Debris = game:GetService("Debris")
		Debris:AddItem(child, 0)
	end

	v4.Value = "None"
	delay(2.1, function()
		if v:GetAttribute("IsFlying") == false then
			v:SetAttribute("IsFlying", nil)
		end
	end)
end

return FlyingModule