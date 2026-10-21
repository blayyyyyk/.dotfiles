-- :checkhealth config
return {
	check = function()
		require("config.doctor").health()
	end,
}
