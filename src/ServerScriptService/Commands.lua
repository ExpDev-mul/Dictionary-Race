-->> Constants
local PREFIX = ";"
local SEPARATOR = " "

-->> Functions
function Simplify(message: String)
	-->> Simplifies a string so that the maximal number of spaces in a row possible is 1
	local simplifiedMessage = ""
	for x = 1, string.len(message) do
		if (string.sub(message, x, x) == " ") and (string.sub(message, x + 1, x + 1) == " ") then
			continue
		else
			simplifiedMessage = simplifiedMessage.. string.sub(message, x, x)
		end;
	end;

	return simplifiedMessage
end;

local command = {}
command.__index = command

function command.new(commandCoefficient: String, commandArguments: Int, commandCallback: Function)
	return setmetatable({
		Coefficient = commandCoefficient,
		Arguments = commandArguments,
		Callback = commandCallback,
	}, command)
end;

function command:Verify(message: String, author: Player)
	message = Simplify(message)
	local separation = string.split(message, SEPARATOR)
	if separation[1] == PREFIX.. self.Coefficient then
		if #separation - 1 >= self.Arguments then
			table.remove(separation, 1)
			self.Callback(author, table.unpack(separation))
		end;
	end;
end;

return command