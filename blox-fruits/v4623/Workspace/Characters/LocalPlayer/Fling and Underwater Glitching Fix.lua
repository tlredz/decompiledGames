local createVector = vector.create
local character = game.Players.LocalPlayer.Character
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
pcall(function()
	local RunService = game:GetService("RunService")
	RunService:UnbindFromRenderStep("GlitchCheck")
end)
local v = { workspace:WaitForChild("Map") }
local raidMap = workspace.Map:FindFirstChild("RaidMap")
local v2 = { raidMap }
local cFrame = humanoidRootPart.CFrame
local RunService = game:GetService("RunService")
RunService:BindToRenderStep("GlitchCheck", 1, function(_)
	if humanoidRootPart.Velocity.Magnitude > 1500 then
		humanoidRootPart.Velocity = Vector3.new()
	elseif humanoidRootPart.Velocity.Magnitude > 750 and humanoidRootPart.Velocity.Y > -700 then
		humanoidRootPart.Velocity = humanoidRootPart.Velocity.Unit * 100
	elseif humanoidRootPart.RotVelocity.Magnitude > 100 then
		humanoidRootPart.RotVelocity = Vector3.new()
	elseif humanoidRootPart.Position.Y < workspace.FallenPartsDestroyHeight + 100 then
		humanoidRootPart.CFrame = cFrame
	elseif raidMap and humanoidRootPart.Position.Y < -humanoidRootPart.Size.Y - 4.75 then
		if workspace:FindPartOnRayWithWhitelist(Ray.new(humanoidRootPart.Position, createVector(0, 10, 0)), v2) then
			local _, v3, _ = workspace:FindPartOnRayWithWhitelist(
				Ray.new(
					Vector3.new(humanoidRootPart.Position.X, 50, humanoidRootPart.Position.Z),
					(Vector3.new(0, -50 - humanoidRootPart.Size.Y - 2.75, 0))
				),
				v2
			)
			humanoidRootPart.CFrame = CFrame.new(v3) * (humanoidRootPart.CFrame - humanoidRootPart.CFrame.p)
		end
	else
		cFrame = humanoidRootPart.CFrame
	end
end)

while task.wait(0.1) do
	if humanoid:GetState() == Enum.HumanoidStateType.FallingDown then
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end

	if not (raidMap and humanoidRootPart.Position.X > 20000 and humanoid:GetState() == Enum.HumanoidStateType.Freefall and humanoidRootPart.Velocity.Magnitude < 60) then
		continue
	end

	local part = workspace:FindPartOnRayWithWhitelist(
		Ray.new(humanoidRootPart.Position, humanoidRootPart.CFrame.LookVector * (0.1 + humanoidRootPart.Size.Z / 2)),
		v
	)
	local part2 = workspace:FindPartOnRayWithWhitelist(
		Ray.new(humanoidRootPart.Position, -humanoidRootPart.CFrame.LookVector * (0.1 + humanoidRootPart.Size.Z / 2)),
		v
	)

	if not (part and part2 and part.CanCollide and part2.CanCollide) then
		continue
	end

	local _, v3, _ = workspace:FindPartOnRayWithWhitelist(
		Ray.new(humanoidRootPart.Position + createVector(0, 200, 0), createVector(0, -200, 0)),
		v
	)
	humanoidRootPart.CFrame = CFrame.new(v3) * (humanoidRootPart.CFrame - humanoidRootPart.CFrame.p)
end