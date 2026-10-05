local createVector = vector.create
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Gun = {}

function Gun.AddHole(_, raycastResult: RaycastResult)
	local clone = script.BulletHole:Clone()
	clone.Parent = workspace
	clone.Position = raycastResult.Position
	clone.CFrame = CFrame.new(clone.Position, clone.Position + raycastResult.Normal)
	local weldConstraint = Instance.new("WeldConstraint", raycastResult.Instance)
	weldConstraint.Part0 = clone
	weldConstraint.Part1 = raycastResult.Instance
	Debris:AddItem(clone, 7)
end

function Gun.SpawnTracer(_, p, position: Vector3, textureSpeed: number)
	task.spawn(function()
		local tracers = script:WaitForChild("Tracers")
		local clone = tracers.Att0.Attachment:Clone()
		clone.Parent = p
		local clone2 = tracers.Att1:Clone()
		clone2.Parent = workspace.Terrain
		local clone3 = tracers.Att0.Beam:Clone()
		clone3.Parent = p
		clone2.Position = position
		clone3.Attachment0 = p
		clone3.Attachment1 = clone2.Attachment
		clone3.CurveSize1 = textureSpeed / 30 + textureSpeed / 30
		clone3.TextureLength = textureSpeed / 3
		clone3.TextureSpeed = textureSpeed
		clone3.Enabled = true
		task.wait(0.05)
		clone:Destroy()
		clone2:Destroy()
		clone3:Destroy()
	end)
end

function Gun.MakeTracer(_, vector2: Vector3, vector3: Vector3)
	local part = Instance.new("Part")
	part.Material = Enum.Material.Neon
	part.Transparency = 0.2
	part.Parent = workspace
	part.CanCollide = false
	part.Anchored = true
	part.CanQuery = false
	local magnitude = (vector3 - vector2).Magnitude
	part.CFrame = CFrame.new(vector2, vector3) * CFrame.new(0, 0, -magnitude / 2)
	part.Size = Vector3.new(0.1, 0.1, magnitude)
	Debris:AddItem(part, 0.1)
	TweenService:Create(part, TweenInfo.new(0.1), {
		Size = createVector(0.1, 0.1, 0),
		CFrame = CFrame.new(vector2, vector3) * CFrame.new(0, 0, -magnitude)
	}):Play()
end

function Gun.Recoil(p, p2, totalTime)
	local currentCamera = workspace.CurrentCamera

	if not p._recoilState then
		p._recoilState = {
			lastOffset = CFrame.new(),
			timer = 0,
			totalTime = 0,
			h = 0,
			v = 0,
			active = false
		}
		RunService:BindToRenderStep("GunRecoil", Enum.RenderPriority.Camera.Value + 1, function(p3)
			local _recoilState = p._recoilState

			if not _recoilState.active then
				return
			end

			_recoilState.timer += p3
			local halfTotalTime = _recoilState.totalTime / 2
			local v2

			if _recoilState.timer <= halfTotalTime then
				local v3 = _recoilState.timer / halfTotalTime
				v2 = 1 - (1 - v3) * (1 - v3)
			elseif _recoilState.timer <= _recoilState.totalTime then
				local v3 = (_recoilState.timer - halfTotalTime) / halfTotalTime
				v2 = 1 - v3 * v3
			else
				_recoilState.active = false
				v2 = 0
			end

			local cframe = CFrame.Angles(_recoilState.v * v2, _recoilState.h * v2, 0)
			currentCamera.CFrame = currentCamera.CFrame * _recoilState.lastOffset:Inverse() * cframe
			_recoilState.lastOffset = cframe
		end)
	end

	local v = math.rad((math.random(-p2 / 2, p2 / 2)))
	local v2 = math.rad((math.random(p2 * 0.8, p2 * 1.2)))
	local _recoilState = p._recoilState
	_recoilState.h = v
	_recoilState.v = v2
	_recoilState.totalTime = totalTime
	_recoilState.timer = 0
	_recoilState.lastOffset = CFrame.new()
	_recoilState.active = true
end

return Gun