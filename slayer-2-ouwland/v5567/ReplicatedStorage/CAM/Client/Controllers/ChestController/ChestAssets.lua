local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local chest_Anims = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Animations"):WaitForChild("Chest_Anims")
local chests = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Sounds"):WaitForChild("Chests")
local effect = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Chests"):WaitForChild("Effect")
local ChestAssets = {
	EffectFolder = effect,
	key = function(instance)
		return instance:GetAttribute("ChestModel") or instance:GetAttribute("ChestId") or instance.Name
	end,
	animator = function(instance)
		local v = instance:QueryDescendants("Animator")[1]

		if v then
			return v
		end

		local animationController = instance:WaitForChild("AnimationController", 5)

		if animationController then
			return (animationController:WaitForChild("Animator", 5))
		end

		return nil
	end
}

function ChestAssets.track(p, animator, p2: string)
	if not animator then
		return nil
	end

	local key = ChestAssets.key(p)
	local v = chest_Anims:FindFirstChild(key) or chest_Anims:FindFirstChild("Common Chest")
	local v2

	if v then
		v2 = v:QueryDescendants((`Animation#{p2}`))[1]
	end

	if not v2 then
		warn((`Chest '{key}' missing {p2}`))
		return nil
	end

	local track = animator:LoadAnimation(v2)
	track.Looped = false
	local v3 = os.clock() + 5

	while track.Length == 0 and os.clock() < v3 do
		task.wait()
	end

	return track
end

function ChestAssets.sound(instance, p: string)
	local primaryPart = instance.PrimaryPart or instance:QueryDescendants("BasePart")[1]

	if not primaryPart then
		return nil
	end

	local v = chests:FindFirstChild((ChestAssets.key(instance))) or chests:FindFirstChild("Common Chest")
	local v2

	if v then
		v2 = v:QueryDescendants((`Sound#{p}`))[1]
	end

	if not v2 then
		return nil
	end

	local clone = v2:Clone()
	clone.Parent = primaryPart
	return clone
end

function ChestAssets:play()
	if not self then
		return
	end

	self:Stop()
	self.TimePosition = 0
	self:Play()
end

function ChestAssets.burst(instance, attributeName: string)
	local attribute = instance:GetAttribute(attributeName)

	if typeof(attribute) ~= "string" then
		return
	end

	local child = effect:FindFirstChild(attribute)

	if not child then
		warn((`Chest effect '{attribute}' not found in Assets.Chests.Effect`))
		return
	end

	local pivot = instance:GetPivot()
	local spawnOffset = instance:GetAttribute("SpawnOffset")

	if typeof(spawnOffset) == "Vector3" then
		pivot *= CFrame.new(-spawnOffset)
	end

	local clone = child:Clone()
	clone.Parent = workspace.Debree
	clone:PivotTo(pivot)
	local raycastResult = workspace:Raycast(
		pivot.Position + createVector(0, 3, 0),
		createVector(0, -20, 0),
		RaycastHelper.Crater
	)
	local v = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
	Ouwmit.Emit(clone, v)
	DebrisModule:AddItem(clone, 5)
end

function ChestAssets.flash(p)
	local highlight = effect:FindFirstChild("Highlight")

	if not (highlight and highlight:IsA("Highlight")) then
		return nil
	end

	local clone = highlight:Clone()
	clone.Adornee = p
	clone.Enabled = false
	clone.Parent = p
	return clone
end

return ChestAssets