local BufferReader = require(script.BufferReader)
local BufferWriter = require(script.BufferWriter)
return {
	reader = BufferReader.new,
	writer = BufferWriter.new
}