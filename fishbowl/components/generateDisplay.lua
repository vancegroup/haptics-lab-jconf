physical = {
	width = .344,
	height = .194
}

p2vScale = 1

corners = {
	lower_left_corner = {0, 0.8382 --[[ height above ground ]], 0}
}

stereo = false

do 
	-- Compute virtual height and width
	local virtual = {}
	for k, v in pairs(physical) do
		virtual[k] = v * p2vScale
	end

	-- Vector addition function
	local lower_left_corner_plus = function(offset)
		local ret = {}
		for i=1,3 do
			table.insert(ret, corners.lower_left_corner[i] + offset[i])
		end
		return ret
	end

	corners.lower_right_corner = lower_left_corner_plus{virtual.width, 0, 0}
	corners.upper_right_corner = lower_left_corner_plus{virtual.width, virtual.height, 0}
	corners.upper_left_corner = lower_left_corner_plus{0, virtual.height, 0}
end

tag = function(tagname, value)
	return ([[<%s>%s</%s>]]):format(tagname, tostring(value), tagname)
end

outputText = function(text)
	table.insert(lines, text)
end

outputVector = function( tagname, vec)
	for _, coordinate in ipairs(vec) do
		outputText(tag(tagname, coordinate))
	end
end
do
	local i = 1
	outputNextConstantPiece = function()
		if i > #constantPieces then
			error("Mismatched number of constant pieces and calls to outputNextConstantPiece", 2)
		end
		outputText(constantPieces[i])
		i = i + 1
	end
end

main = function()
	lines = {  }
	outputNextConstantPiece()
	outputVector("origin", {0, 0})
	outputVector("size", {1920, 1080})
	outputNextConstantPiece()
	if stereo then
		outputText(tag("stereo", "true"))
	else
		outputText(tag("stereo", "false"))
	end
	outputNextConstantPiece()
	if stereo then
		outputText(tag("view", "Stereo"))
	else
		outputText(tag("view", "Left Eye"))
	end
	for _, cornerName in ipairs{"lower_left_corner","lower_right_corner","upper_right_corner","upper_left_corner"} do
		outputVector(cornerName, corners[cornerName])
	end
	outputNextConstantPiece()
	
	if stereo then
		filename = "display.stereo.jconf"
	else
		filename = "display.mono.jconf"
	end
	local out = assert(io.open(filename, "wb"))
	out:write(table.concat(lines, "\n"))
	out:close()
end

constantPieces = {

[[<?xml version="1.0" encoding="UTF-8"?>
<?org-vrjuggler-jccl-settings configuration.version="3.0"?>
<configuration xmlns="http://www.vrjuggler.org/jccl/xsd/3.0/configuration" name="display.jconf" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.vrjuggler.org/jccl/xsd/3.0/configuration http://www.vrjuggler.org/jccl/xsd/3.0/configuration.xsd">
   <elements>
      <display_system name="Pipe Setup" version="3">
         <number_of_pipes>1</number_of_pipes>
         <pipes>-1</pipes>
         <pipes>-1</pipes>
         <use_swap_group>false</use_swap_group>
      </display_system>
     <display_window name="ImmersiveDisplay" version="6">]]
	 ;
	 [[<pipe>0</pipe>
         <frame_buffer_config>
            <opengl_frame_buffer_config name="frame_buffer_config 0" version="4">
               <visual_id>-1</visual_id>
               <red_size>1</red_size>
               <green_size>1</green_size>
               <blue_size>1</blue_size>
               <alpha_size>1</alpha_size>
               <auxiliary_buffer_count>0</auxiliary_buffer_count>
               <depth_buffer_size>1</depth_buffer_size>
               <stencil_buffer_size>1</stencil_buffer_size>
               <accum_red_size>1</accum_red_size>
               <accum_green_size>1</accum_green_size>
               <accum_blue_size>1</accum_blue_size>
               <accum_alpha_size>1</accum_alpha_size>
               <num_sample_buffers>1</num_sample_buffers>
               <num_samples>2</num_samples>
               <use_create_context_attribs>false</use_create_context_attribs>
               <gl_context_major_version>3</gl_context_major_version>
               <gl_context_minor_version>0</gl_context_minor_version>
               <gl_context_flags>0</gl_context_flags>
            </opengl_frame_buffer_config>
         </frame_buffer_config>]]
		 ;
		 [[         <border>false</border>
         <hide_mouse>true</hide_mouse>
         <full_screen>true</full_screen>
         <always_on_top>false</always_on_top>
         <active>true</active>
         <surface_viewports>
            <surface_viewport name="FrontDesktop" version="3">
               <origin>0.0</origin>
               <origin>0.0</origin>
               <size>1.0</size>
               <size>1.0</size>]]
		;
		[[<user>VJUser</user>
               <active>true</active>
               <tracked>false</tracked>
               <tracker_proxy />
               <auto_corner_update>0</auto_corner_update>
            </surface_viewport>
         </surface_viewports>
         <keyboard_mouse_device_name>Keyboard/Mouse Device</keyboard_mouse_device_name>
         <allow_mouse_locking>true</allow_mouse_locking>
         <lock_key>0</lock_key>
         <start_locked>false</start_locked>
         <sleep_time>75</sleep_time>
      </display_window>
   </elements>
</configuration>]]
}

main()