local BaseOcclusion = {}
BaseOcclusion.__index = BaseOcclusion
setmetatable(BaseOcclusion, {
	__call = function(_, ...)
		return BaseOcclusion.new(...)
	end
})

function BaseOcclusion.new()
	return (setmetatable({}, BaseOcclusion))
end

function BaseOcclusion.CharacterAdded(_, _, _) end

function BaseOcclusion.CharacterRemoving(_, _, _) end

function BaseOcclusion.OnCameraSubjectChanged(_, _) end

function GetOcclusionMode()
	warn("BaseOcclusion GetOcclusionMode must be overridden by derived classes")
	return nil
end

function BaseOcclusion.Enable(_, _)
	warn("BaseOcclusion Enable must be overridden by derived classes")
end

function BaseOcclusion.Update(_, _, p, p2)
	warn("BaseOcclusion Update must be overridden by derived classes")
	return p, p2
end

return BaseOcclusion