-- Set up your default NB-voices here!!!
--
-- Go to params and hit "Print voice-numbers".
-- This will print a list to matron, copy this
-- and replace the function below!

function set_voice_nums()
	params:set("voice_keys", 18)
	params:set("voice_drum_1", 2)
	params:set("voice_drum_2", 3)
	params:set("voice_drum_3", 4)
	params:set("voice_drum_4", 5)
end

-- Repeat when you change you voice-stack.

    params:add_trigger("get_voice_nums", "print voice-numbers")
	params:set_action("get_voice_nums",function() print_voice_nums() end)

function print_voice_nums()
	print("\nNumbers for your NB voice-stack.\n")
	print("Copy the text between the lines and replace")
	print("the function at the top of paratext.lua.")
	print("________________________________________________________________")
	print("function set_voice_nums()")
	print("\tparams:set(\"voice_keys\", " .. params:get("voice_keys") .. ")")
	print("\tparams:set(\"voice_drum_1\", " .. params:get("voice_drum_1") .. ")")
	print("\tparams:set(\"voice_drum_2\", " .. params:get("voice_drum_2") .. ")")
	print("\tparams:set(\"voice_drum_3\", " .. params:get("voice_drum_3") .. ")")
	print("\tparams:set(\"voice_drum_4\", " .. params:get("voice_drum_4") .. ")")
	print("end")
	print("________________________________________________________________")
end