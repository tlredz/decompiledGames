return function(p)
	local head = p.Head
	local cryEffect = script:FindFirstChild("CryEffect")

	if not (head and head:IsA("BasePart") and head:IsDescendantOf(workspace) and cryEffect and cryEffect:IsA("BasePart")) then
		return
	end

	local clone = cryEffect:Clone()
	local weld = clone:FindFirstChild("Weld")

	if not (weld and weld:IsA("Weld")) then
		clone:Destroy()
		return
	end

	clone.Anchored = false
	clone.CanCollide = false
	clone.CanQuery = false
	clone.CanTouch = false
	clone.Massless = true
	clone.CFrame = head.CFrame
	weld.Part0 = head
	clone.Parent = workspace:FindFirstChild("_WorldOrigin") or workspace
	local v = typeof(p.Duration) ~= "number" and 1.5 or math.max(p.Duration, 0)
	local lastTime = os.clock()

	while clone.Parent and head.Parent and os.clock() - lastTime < v do
		task.wait()
	end

	local v2 = 0

	for _, effect in clone:GetDescendants() do
		if effect:IsA("ParticleEmitter") then
			effect.Enabled = false
			v2 = math.max(v2, effect.Lifetime.Max)
		elseif effect:IsA("Beam") or effect:IsA("Trail") then
			effect.Enabled = false
		end
	end

	task.wait(v2)
	clone:Destroy()
end