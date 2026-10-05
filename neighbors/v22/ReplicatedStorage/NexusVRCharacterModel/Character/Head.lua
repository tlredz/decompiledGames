local parent = script.Parent.Parent
local NexusAppendage = require(script.Parent.Parent:WaitForChild("Packages"):WaitForChild("NexusAppendage"))
local Settings = require(parent:WaitForChild("State"):WaitForChild("Settings"))
local instance = Settings.GetInstance()
local limb = NexusAppendage.Limb
local Head = {}
Head.__index = Head
setmetatable(Head, limb)

function Head.new(head)
	local self = setmetatable(limb.new(), Head)
	self.Head = head
	return self
end

function Head:GetEyesOffset()
	return self:GetAttachmentCFrame(self.Head, "FaceFrontAttachment") * CFrame.new(0, self.Head.Size.Y / 4, 0)
end

function Head:GetHeadCFrame(cframe: CFrame)
	return cframe * self:GetEyesOffset():Inverse()
end

function Head:GetNeckCFrame(cframe: CFrame, p: number?)
	local v = self:GetHeadCFrame(cframe) * self:GetAttachmentCFrame(self.Head, "NeckRigAttachment")
	local lookVector = v.LookVector
	local lastNeckRotationGlobal2 = math.atan2(lookVector.X, lookVector.Z) + 3.141592653589793
	local v3 = math.asin(lookVector.Y)
	local v4 = 0
	local setting = instance:GetSetting("Appearance.MaxNeckTilt") or 1.0471975511965976

	if setting < v3 then
		v4 = v3 - setting
	elseif v3 < -setting then
		v4 = v3 + setting
	end

	if p then
		local v5 = lastNeckRotationGlobal2 - p

		while v5 > 3.141592653589793 do
			v5 -= 6.283185307179586
		end

		while v5 < -3.141592653589793 do
			v5 += 6.283185307179586
		end

		local setting2 = instance:GetSetting("Appearance.MaxNeckSeatedRotation") or 1.0471975511965976

		if setting2 < v5 then
			lastNeckRotationGlobal2 = v5 - setting2
		elseif v5 < -setting2 then
			lastNeckRotationGlobal2 = v5 + setting2
		else
			lastNeckRotationGlobal2 = 0
		end
	else
		local setting2 = instance:GetSetting("Appearance.MaxNeckRotation") or 0.6108652381980153
		local lastNeckRotationGlobal = self.LastNeckRotationGlobal

		if lastNeckRotationGlobal then
			local v5 = lastNeckRotationGlobal2 - lastNeckRotationGlobal

			while v5 > 3.141592653589793 do
				v5 -= 6.283185307179586
			end

			while v5 < -3.141592653589793 do
				v5 += 6.283185307179586
			end

			if math.abs(v5) < 1.5 * setting2 then
				if setting2 < v5 then
					lastNeckRotationGlobal2 -= setting2
				elseif v5 < -setting2 then
					lastNeckRotationGlobal2 += setting2
				else
					lastNeckRotationGlobal2 = lastNeckRotationGlobal
				end
			end
		end
	end

	self.LastNeckRotationGlobal = lastNeckRotationGlobal2
	return CFrame.new(v.Position) * CFrame.Angles(0, lastNeckRotationGlobal2, 0) * CFrame.Angles(v4, 0, 0)
end

return Head