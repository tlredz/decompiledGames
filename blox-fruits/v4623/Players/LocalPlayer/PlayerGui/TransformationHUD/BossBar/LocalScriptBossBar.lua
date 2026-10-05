local Maid = require(game.ReplicatedStorage.Util.Maid)
local BossBar = require(script.BossBar)
local notification = game.ReplicatedStorage.Notification

-- equivalent calls inferred from this helper; original call sites unknown
local function FixPadding()
	local offset = notification:GetAttribute("Offset") or 0
	script.Parent.Position = UDim2.new(0.5, 0, 0.06, offset)
end

FixPadding() -- equivalent call inferred; original call site unknown
notification:GetAttributeChangedSignal("Offset"):Connect(FixPadding)

function ChildAdded(instance)
	local fakeHumanoid = instance:FindFirstChild("FakeHumanoid")

	if not fakeHumanoid and instance:GetAttribute("RaidBoss") then
		fakeHumanoid = instance:FindFirstChildWhichIsA("Humanoid") or instance:FindFirstChild("Health")
	end

	if fakeHumanoid then
		if instance.ClassName ~= "Model" or not instance:FindFirstChild("HumanoidRootPart") then
			return
		end

		local Billboard = require(script.Billboard)
		local v, v2 = Billboard(instance.HumanoidRootPart)

		if v2 then
			return
		end

		local maid = Maid.new()

		local function update()
			if not v.Parent then
				return
			end

			v.Visible = instance:GetAttribute("HealthEnabled") ~= false

			if fakeHumanoid:IsA("Humanoid") then
				v.UIGradient.Offset = Vector2.new(fakeHumanoid.Health / fakeHumanoid.MaxHealth - 0.5, 0)

				if fakeHumanoid.Health <= 0 then
					game.Debris:AddItem(v, 2)
				end
			else
				v.UIGradient.Offset = Vector2.new(fakeHumanoid.Value / fakeHumanoid.MaxValue - 0.5, 1)

				if fakeHumanoid.Value <= 0 then
					game.Debris:AddItem(v, 2)
				end
			end
		end

		if fakeHumanoid:IsA("Humanoid") then
			maid:GiveTask(fakeHumanoid:GetPropertyChangedSignal("Health"):Connect(update))
			maid:GiveTask(fakeHumanoid:GetPropertyChangedSignal("MaxHealth"):Connect(update))
		else
			maid:GiveTask(fakeHumanoid:GetPropertyChangedSignal("Value"):Connect(update))
			maid:GiveTask(fakeHumanoid:GetPropertyChangedSignal("MaxValue"):Connect(update))
		end

		maid:GiveTask(BossBar.Changed:Connect(function()
			if BossBar[script.Parent.Subbar] and BossBar[script.Parent.Subbar].Enemy == instance then
				v.BackgroundColor3 = Color3.fromRGB(202, 190, 28)
			elseif fakeHumanoid.Parent:GetAttribute("Armored") then
				v.BackgroundColor3 = Color3.fromRGB(162, 179, 189)
			else
				v.BackgroundColor3 = Color3.fromRGB(39, 202, 28)
			end
		end))

		if BossBar[script.Parent.Subbar] and BossBar[script.Parent.Subbar].Enemy == instance then
			v.BackgroundColor3 = Color3.fromRGB(202, 190, 28)
		elseif fakeHumanoid.Parent:GetAttribute("Armored") then
			v.BackgroundColor3 = Color3.fromRGB(162, 179, 189)
		else
			v.BackgroundColor3 = Color3.fromRGB(39, 202, 28)
		end

		maid:GiveTask(fakeHumanoid.Destroying:Connect(function()
			maid:DoCleaning()
			game.Debris:AddItem(v, 2)
		end))
		maid:GiveTask(instance.Destroying:Connect(function()
			maid:DoCleaning()
			game.Debris:AddItem(v, 2)
		end))
		maid:GiveTask(instance:GetAttributeChangedSignal("HealthEnabled"):Connect(update))
		update()
	end
end

workspace.SeaBeasts.ChildAdded:Connect(ChildAdded)
workspace.Enemies.ChildAdded:Connect(ChildAdded)

for _, child in pairs(workspace.Enemies:GetChildren()) do
	ChildAdded(child)
end

for _, child in pairs(workspace.SeaBeasts:GetChildren()) do
	ChildAdded(child)
end