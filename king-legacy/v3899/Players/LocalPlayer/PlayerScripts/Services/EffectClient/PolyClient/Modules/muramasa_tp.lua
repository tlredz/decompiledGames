local createVector = vector.create
local replicatedStorage = game.ReplicatedStorage
local _ = game.Players.LocalPlayer
local PeodizService = require(replicatedStorage.Chest.Modules.PeodizService)
return function(data)
	local localPlayer = game.Players.LocalPlayer

	if data.tp == localPlayer then
		local cFrame = CFrame.new(data.tocf.p) * (localPlayer.Character.HumanoidRootPart.CFrame - localPlayer.Character.HumanoidRootPart.CFrame.p)
		game.TweenService:Create(
			localPlayer.Character.HumanoidRootPart,
			TweenInfo.new(0.185, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			{
				CFrame = cFrame
			}
		):Play()
	end

	local rootcf = data.rootcf
	local char = data.char
	local _ = data.root
	local tocf = data.tocf

	local function clone(rootcf2)
		local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

		local function clearweld(clone2)
			for _, child in pairs(clone2:GetChildren()) do
				if not (child:IsA("Motor6D") or child:IsA("Weld") or child:IsA("ManualWeld") or child:IsA("BasePart") or child:IsA("Attachment") or child:IsA("Decal") or child:IsA("ParticleEmitter")) then
					continue
				end

				child:Destroy()
			end
		end

		local model = Instance.new("Model")
		model.Name = "CharModel"
		model.Parent = workspace.Effects
		_G.PU:Dust(model, 2)
		local clones = {}

		for _, part in pairs(char:GetChildren()) do
			if not part:IsA("BasePart") then
				continue
			end

			local clone2 = part:Clone()
			clone2.Anchored = true
			clone2.CanCollide = false
			clone2.Massless = true
			clone2.Transparency = 0
			clone2.Material = Enum.Material.Neon
			clone2.Color = Color3.fromRGB(255, 135, 49)
			clearweld(clone2)
			clone2.CFrame = rootcf2
			clone2.Parent = workspace.Effects
			task.spawn(function()
				wait(0.2)
				local v2 = game.TweenService:Create(clone2, tweenInfo, {
					Transparency = 1
				})
				v2:Play()
				local completedConnection = nil
				completedConnection = v2.Completed:Connect(function()
					_G.PU:Dust(clone2, 1)
					completedConnection:Disconnect()
				end)
			end)
			clones[#clones + 1] = clone2
		end

		task.delay(10, function()
			table.clear(clones)
		end)
		return clones
	end

	local clone2 = replicatedStorage.Chest.SwordEffect.Muramasa.tptrails:Clone()
	clone2.CFrame = rootcf
	clone2.Parent = workspace.Effects
	clone2.Attachment.Ring:Emit(2)
	clone2.Attachment.spark:Emit(1)
	_G.PU:Dust(clone2, 1)
	local v = clone(rootcf)
	game.TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CFrame = tocf
	}):Play()

	for _, v2 in pairs(v) do
		local parent = v2
		task.spawn(function()
			-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
			local function bezier(p, p2, p3, p4)
				return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
			end

			local attachment = Instance.new("Attachment", parent)
			attachment.Name = "at1"
			attachment.Position = createVector(-1, 0, 0)
			local attachment2 = Instance.new("Attachment", parent)
			attachment2.Name = "at2"
			attachment2.Position = createVector(1, 0, 0)
			local clone3 = replicatedStorage.Chest.SwordEffect.Muramasa.tptrails.Trail:Clone()
			clone3.Parent = parent
			clone3.Attachment1 = attachment
			clone3.Attachment0 = attachment2
			clone3.Enabled = true
			local p = parent.CFrame.p
			local p2 = tocf.p
			local v4 = CFrame.new(p, p2) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.new(
				0,
				math.random(-1, 1) * math.random(10, 25),
				-(p - p2).magnitude / 3
			)
			task.spawn(function()
				PeodizService.HeartbeatWait({
					Time = 0.25,
					Tween = {
						EasingStyle = Enum.EasingStyle.Exponential,
						EasingDirection = Enum.EasingDirection.Out
					}
				}, function(p3)
					parent.Position = bezier(math.floor(p3 * 100) / 100, p, v4.p, p2)
				end)
			end)
		end)
	end
end