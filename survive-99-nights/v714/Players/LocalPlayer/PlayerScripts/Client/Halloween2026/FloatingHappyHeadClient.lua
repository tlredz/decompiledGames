local createVector = vector.create
local FloatingHappyHeadClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local RunService = game:GetService("RunService")
local clone = nil
local flag = false
local v = 0
local v2 = 0

function GetRoot()
	return localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
end

function ShoulderCFrame(instance)
	local v3 = instance.CFrame.LookVector * createVector(1, 0, 1)
	local v4 = v3.Magnitude < 0.01 and createVector(0, 0, -1) or v3
	local cframe = CFrame.lookAt(createVector(0, 0, 0), v4.Unit)
	local v5 = math.sin(os.clock() * 2) * 0.25
	return CFrame.new(instance.Position) * cframe * CFrame.new(createVector(2.5, 2, 1.5) + Vector3.new(0, v5, 0))
end

function FloatingHappyHeadClient.ShowHead(cframe: CFrame?, p: number?)
	v += 1

	if clone then
		return
	end

	local v3 = cframe and p
	clone = game.ReplicatedStorage.Assets.Halloween.HappyHead:Clone()
	clone:ScaleTo(v3 or 0.85)

	for _, part in pairs(clone:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
	end

	local v4 = GetRoot()

	if cframe then
		clone:PivotTo(cframe)
		v2 = os.clock() + 3.75
	elseif v4 then
		clone:PivotTo(ShoulderCFrame(v4))
	end

	clone.Parent = workspace
	Client.Sound.Play("HappyHeadAppear")

	if not cframe then
		Client.Utility.SpawnParticles("HalloweenHappyHead", clone:GetPivot())
	end

	local lastTime = os.clock()
	flag = true
	RunService:BindToRenderStep("FloatingHappyHead", Enum.RenderPriority.Character.Value, function(p2)
		local v5 = GetRoot()

		if not v5 then
			return
		end

		local v6 = ShoulderCFrame(v5)
		local v7 = (os.clock() - lastTime) / 0.5

		if cframe and v7 < 1 then
			local v8 = 1 - (1 - v7) ^ 2
			local v9 = 16 * v8 * (1 - v8)

			if v3 then
				clone:ScaleTo(v3 + (0.85 - v3) * v8)
			end

			clone:PivotTo(cframe:Lerp(v6, v8) + Vector3.new(0, v9, 0))
		else
			if v3 then
				clone:ScaleTo(0.85)
				v3 = nil
			end

			clone:PivotTo(clone:GetPivot():Lerp(v6, 1 - math.exp(-6 * p2)))
		end
	end)
end

function RemoveHead()
	if flag then
		RunService:UnbindFromRenderStep("FloatingHappyHead")
		flag = false
	end

	if clone then
		Client.Utility.SpawnParticles("HalloweenHappyHead", clone:GetPivot())
		Client.Sound.Play("HappyHeadDisappear")
		clone:Destroy()
		clone = nil
	end
end

function FloatingHappyHeadClient.HideHead(p: number?)
	local v3 = v + 1
	v = v3

	if p then
		task.delay(math.max(p, v2 - os.clock()), function()
			if v == v3 then
				RemoveHead()
			end
		end)
	else
		RemoveHead()
	end
end

return FloatingHappyHeadClient