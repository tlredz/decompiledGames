local createVector = vector.create
local pivot = script.Parent:GetPivot()
local unit = ((script.Parent:GetAttribute("DeathOrigin").Position - pivot.Position) * createVector(1, 0, 1)).Unit
local cframe = CFrame.lookAlong(Vector3.new(), unit.Unit)
script.Parent.Trunk.Attachment.WorldCFrame = CFrame.new(script.Parent.Trunk.Attachment.WorldPosition) * cframe
script.Parent.Trunk.AngularVelocity.Enabled = true
wait(0.5)
script.Parent.Trunk.AngularVelocity.Enabled = false
wait(0.25)
local position = script.Parent.Trunk.Position
script.Parent.Trunk:Destroy()
script.Parent:BreakJoints()

for _, part in pairs(script.Parent:GetChildren()) do
	if not part:IsA("BasePart") or part.Anchored then
		continue
	end

	if part.Name == "TrunkPart2" then
		part:Destroy()
	else
		dir = (part.Position - position).Unit
		part.AssemblyLinearVelocity += dir * -20 + createVector(0, 20, 0)
	end
end