local pivot = script.Parent:GetPivot()
local unit = ((script.Parent:GetAttribute("DeathOrigin").Position - pivot.Position) * vector.create(1, 0, 1)).Unit
local cframe = CFrame.lookAlong(Vector3.new(), unit.Unit)
script.Parent.Trunk.Attachment.WorldCFrame = CFrame.new(script.Parent.Trunk.Attachment.WorldPosition) * cframe
script.Parent.Trunk.AngularVelocity.Enabled = true
wait(0.25)
script.Parent.Trunk.AngularVelocity.Enabled = false
wait(0.5)
script.Parent:BreakJoints()