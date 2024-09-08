-- draws table of contents to screen
-- chapters describe params
-- page numbers describe values

function draw_interface()
	leading = 8
	margins = 0
	l_edge = margins
	r_edge = 128 - margins
	justify = l

	screen.font_face(1)
	screen.font_size(leading)

	if params:get("sequencer") == 1 then 
		sequencer_name = "On Melody"
	else
		sequencer_name = "On Rythm"
	end

	function write_line(line, w1, w2, indent, dots)
		w1_l = screen.text_extents(w1)
		w2_l = screen.text_extents(w2)
		
		y_pos = leading * line

		if dots then
			screen.level(3)
			screen.move(w1_l + margins + indent + 3, y_pos)
			screen.line(128 - w2_l - margins - 1, y_pos)
			screen.stroke()
		end

		screen.level(15)
		screen.move(l_edge + indent, y_pos)
		screen.text(w1)
		screen.move(r_edge, y_pos)
		screen.text_right(w2)		
	end

	if k1_held == false then
		write_line( 
			1, -- line number
			"Paratext, Volume 1", -- left-aligned words, name of setting
			"", -- right-aligned words, value of setting
			0, -- indent in px
			false -- "dotted" line between left and right words?
		)

		write_line(
			3,
			"On Time",
			math.floor(params:get("fx_postscript_time") * 1000),
			2,
			true
		)

		if k2_held then title = "On Diminished Returns" else title = "On Reccursion" end

		write_line(
			4,
			title,
			math.floor(params:get("fx_postscript_feedback")),
			2,
			true
		)

		if k3_held then title = "On Abundance" else title = "On Quantity" end

		write_line(
			5,
			title,
			math.floor(params:get("fx_postscript_send")),
			2,
			true
		)

	elseif k1_held == true then
		write_line(
			1,
			"Paratext, Volume 2",
			"",
			0,
			false
		)

        write_line(
			3,
			sequencer_name,
			"i",
			2,
			true
		)

		write_line(
			5,
			"On Water",
			math.floor(params:get("fx_postscript_slot_drywet") * 100),
			2,
			true
		)

		write_line(
			6,
			"On Sharpness",
			math.floor(params:get("fx_postscript_lp")),
			2,
			true
		)

		write_line(
			7,
			"On Distance",
			math.floor(params:get("fx_postscript_width")),
			2,
			true
		)
	end
end
