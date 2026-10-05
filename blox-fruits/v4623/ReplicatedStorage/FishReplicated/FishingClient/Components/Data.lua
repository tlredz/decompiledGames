local Data = {
	__components = nil,
	__loadOrder = 0,
	__maid = nil,
	__state = nil,
	state = nil
}
Data.__index = Data

function Data.Construct(p)
	return (setmetatable(p, Data))
end

function Data.Setup() end

return Data