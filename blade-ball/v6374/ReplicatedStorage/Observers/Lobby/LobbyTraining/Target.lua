local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Utils = require(ReplicatedStorage.Common.Utils)
local targets = ReplicatedStorage.Misc.Targets
return Observers.observeTag("LobbyTrainingClientTarget", function(parent)
	parent.Transparency = 1
	local stand = parent.Parent and parent.Parent:FindFirstChild("Stand")
	local clone = stand and stand:Clone()
	local v

	if stand and clone then
		v = Utils.Physics.CreateMotor(clone, stand)
		clone.Anchored = false
		clone.Parent = workspace.Runtime
		stand.Transparency = 1
	else
		v = nil
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function weld(p)
		local createMotor = Utils.Physics.CreateMotor(p, parent)
		createMotor.C0 = p.CFrame:ToObjectSpace(parent.CFrame)
		p.Anchored = false
	end

	local function clone2(instance)
		local clone3 = instance:Clone()
		clone3:PivotTo(parent:GetPivot())

		if clone3:IsA("Model") then
			clone3:ScaleTo(parent.Size.X / 2)
		else
			clone3.Size = parent.Size
		end

		if clone3:IsA("BasePart") then
			weld(clone3) -- equivalent call inferred; original call site unknown
		end

		for _, part in clone3:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			weld(part) -- equivalent call inferred; original call site unknown
		end

		return clone3
	end

	local v2 = clone2(targets.Broken)
	local v3 = clone2(targets.Normal)
	local v4 = clone2(targets.High)
	local v5 = clone2(targets.Mid)
	local sound = v2:FindFirstChildWhichIsA("Sound")
	sound.Parent = ReplicatedStorage
	local parent2 = nil

	local function updateHealth()
		local v7 = parent:GetAttribute("Health") / parent:GetAttribute("MaxHealth")
		local parent3

		if v7 > 0.75 then
			parent3 = v3
		elseif v7 > 0.5 then
			parent3 = v5
		elseif v7 > 0 then
			parent3 = v4
		else
			parent3 = v2
		end

		if parent3 ~= parent2 and clone then
			if v7 > 0 then
				if not v.Enabled then
					v.Enabled = true
					TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
						Transparency = 0
					}):Play()
				end
			elseif v.Enabled then
				task.delay(0.2, function()
					v.Enabled = false
					task.defer(function()
						clone:ApplyImpulse(Random.new():NextUnitVector() * 60 * createVector(1, 0, 1) + createVector(
							0,
							80,
							0
						))
					end)
					task.delay(4, function()
						TweenService:Create(
							clone,
							TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
					end)
				end)
			end
		end

		if parent3 == v2 then
			task.wait(0.2)
		end

		if parent2 and parent3 ~= parent2 then
			local highlight = parent2:FindFirstChildWhichIsA("Highlight")

			if highlight then
				highlight.Parent = parent3
			end

			parent2.Parent = nil
		end

		if parent3 and not parent3.Parent then
			if parent3 == v2 then
				sound.Parent = parent
				v2:PivotTo(parent:GetPivot())

				for _, part in v2:GetChildren() do
					if not part:IsA("BasePart") then
						continue
					end

					local pivot = part:GetPivot()
					part:SetAttribute("DefaultCFrame", pivot)

					for _, motor6D in part:GetDescendants() do
						if motor6D:IsA("Motor6D") then
							motor6D.Enabled = false
						end
					end

					part.CanCollide = true
					local v9 = part
					task.defer(function()
						v9.AssemblyAngularVelocity = Random.new():NextUnitVector() * 10
						v9:ApplyImpulse((pivot.Position - parent.Position).Unit * 60 * createVector(1, 0, 1) + createVector(
							0,
							80,
							0
						))
					end)
					local v11 = part
					task.delay(4, function()
						TweenService:Create(v11, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
							Transparency = 1
						}):Play()
					end)
				end
			else
				sound.Parent = ReplicatedStorage

				for _, part in v2:GetChildren() do
					if not part:IsA("BasePart") then
						continue
					end

					local defaultCFrame = part:GetAttribute("DefaultCFrame")

					if not defaultCFrame then
						continue
					end

					for _, motor6D in part:GetDescendants() do
						if motor6D:IsA("Motor6D") then
							motor6D.Enabled = true
						end
					end

					part.Transparency = 0
					part.CanCollide = false
					part:PivotTo(defaultCFrame)
					part:SetAttribute("DefaultCFrame", nil)
				end
			end

			local parent4

			if parent3 == v2 then
				parent4 = workspace.Runtime
			else
				parent4 = parent
			end

			parent3.Parent = parent4
		end

		parent2 = parent3
	end

	local healthChangedConnection = parent:GetAttributeChangedSignal("Health"):Connect(updateHealth)
	task.spawn(updateHealth)

	local function updateHighlight()
		task.defer(function()
			local highlight = parent:FindFirstChildWhichIsA("Highlight")

			if highlight and parent2 then
				highlight.Parent = parent2
			end
		end)
	end

	local childAddedConnection = parent.ChildAdded:Connect(updateHighlight)
	task.spawn(updateHighlight)
	return function()
		healthChangedConnection:Disconnect()
		childAddedConnection:Disconnect()

		if clone then
			clone:Destroy()
		end

		v2:Destroy()
		v3:Destroy()
		v4:Destroy()
		v5:Destroy()
	end
end, { workspace })