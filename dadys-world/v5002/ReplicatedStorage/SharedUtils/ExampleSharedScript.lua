local ExampleSharedScript = {}

function ExampleSharedScript.sayHello(p)
	return "Hello " .. p .. " from shared script!"
end

function ExampleSharedScript.getVersion()
	return "1.0.0"
end

return ExampleSharedScript