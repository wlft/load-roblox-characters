local loader = require(script.Parent.loader)
local init = require(script.Parent.init)

type auth = {
	token : string;
	
	identity : {
		name : string;
	};
}

return function(widget, ext)
	ext.loader.open.Event:Connect(function(auth, ...)
		widget.Enabled = true
		init:deploy(widget)
		loader:open(widget, ...)
	end)
end