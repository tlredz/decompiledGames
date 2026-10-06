local xml2lua = script:WaitForChild("xml2lua", 999)
local xmlhandler = xml2lua:WaitForChild("xmlhandler", 999)
local module = require(xml2lua)
local tree = require(xmlhandler:WaitForChild("tree", 999))
local parser = module.parser(tree)
return function(p)
	parser:parse(p)
	return tree.root
end