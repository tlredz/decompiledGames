local createBasePartCopy = require(script.createBasePartCopy)
return function(instance)
	if instance:IsA("BasePart") and instance.Parent.Name ~= "FalconWings" and instance.Parent.Name ~= "HybridPhoenixBF" and instance.Parent.Name ~= "PhoenixBF" then
		return createBasePartCopy(instance)
	end

	if instance:IsA("Humanoid") then
		local humanoid = Instance.new("Humanoid")
		humanoid:ChangeState(Enum.HumanoidStateType.Physics)
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		humanoid.RigType = Enum.HumanoidRigType.R15
		return humanoid
	elseif instance:IsA("Shirt") or instance:IsA("Pants") or instance:IsA("CharacterMesh") then
		return instance:Clone()
	end
end