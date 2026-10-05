local ExtendedCFrame = {}

function ExtendedCFrame.ApplyGlobalCFrame(_, object, p, p2)
	local objectSpace = object:toObjectSpace(p)
	return object * p2 * objectSpace
end

function ExtendedCFrame.CFrameToTable(_, cframe)
	return { cframe:GetComponents() }
end

function ExtendedCFrame.TableToCFrame(_, list)
	return CFrame.new(table.unpack(list))
end

function ExtendedCFrame.TableToVector3(_, list)
	if type(list) == "table" and #list == 3 then
		return (Vector3.new(list[1], list[2], list[3]))
	end

	error("Invalid table format. Expected a table with three numeric values.")
end

function ExtendedCFrame.Vector3ToTable(_, data)
	if typeof(data) == "Vector3" then
		return { data.X, data.Y, data.Z }
	end

	error("Invalid input. Expected a Vector3 value.")
end

return ExtendedCFrame