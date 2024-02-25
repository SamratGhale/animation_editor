package main

import imgui "./odin-imgui"
import "./odin-imgui/imgui_impl_glfw"
import "./odin-imgui/imgui_impl_opengl3"
import "core:fmt"
import "core:math/linalg"
import gl "vendor:OpenGL"

AnimFile :: struct {
	file_path: string,
	gl_ctx:    GlContext,
}

AppState :: struct {
	//files:      [dynamic]string,
	anim_index: i32,
	speed:      i32,
	index:      i32,
	play:       bool,
	input:      Input,
	anim_files: [dynamic]AnimFile,
	fonts:      [2]^imgui.Font, //only for ui
	uniforms:   gl.Uniforms,
    program_id : u32,
	initilized: bool,
}

app_state: AppState

GlContext :: struct {
	vao, vbo, tex_id: u32,
	ratio:            [2]f32, //ratio
}

render_app :: proc() {

	if !app_state.initilized {
        
        app_state.program_id, _ = gl.load_shaders_source(#load("./vert.glsl"), #load("./frag.glsl"))
        app_state.uniforms = gl.get_uniforms_from_program(app_state.program_id)
        gl.UseProgram(app_state.program_id)

        proj := linalg.MATRIX4F32_IDENTITY
        gl.UniformMatrix4fv(app_state.uniforms["proj"].location, 1, gl.FALSE, &proj[0, 0])

        app_state.speed = 5

		app_state.initilized = true
	}
	font_only_flags: imgui.WindowFlags = {.NoBackground, .NoTitleBar, .NoResize}
	if imgui.Begin("Main", nil, font_only_flags) {
		imgui.Text("Drag and drop files")
	}
	imgui.End()

	imgui.PushFont(app_state.fonts[1])

	if imgui.Begin("Menu", nil, nil) {

		if imgui.Button("Clear all files") {
			clear_dynamic_array(&app_state.anim_files)
			//clear_dynamic_array(&textures)
		}
		imgui.Text("Loaded files")

		if imgui.TreeNode("Files") {
			for _, n in app_state.anim_files {
				file := app_state.anim_files[n]
				imgui.Selectable(fmt.ctprintf(file.file_path))
			}
			imgui.TreePop()
		}
	}
	imgui.End()


	if imgui.Begin("Images", nil, font_only_flags) {
		for anim_file, i in &app_state.anim_files {
			if i32(i) == i32(app_state.anim_index) {
				imgui.ImageButtonEx(
					fmt.ctprintf(app_state.anim_files[i].file_path),
					rawptr(uintptr(anim_file.gl_ctx.tex_id)),
					{100, 100},
					{},
					{1, 1},
					{1, 1, 1, 1},
					{1, 1, 1, 1},
				)
			} else {
				if imgui.ImageButton(
					   fmt.ctprintf(app_state.anim_files[i].file_path),
					   rawptr(uintptr(anim_file.gl_ctx.tex_id)),
					   {100, 100},
				   ) {
					app_state.anim_index = i32(i)
				}
			}
			imgui.SameLine()

			n := i
			if imgui.BeginDragDropSource(nil) {
				imgui.SetDragDropPayload("DND_DEMO_CELL", &n, size_of(i32), nil)
				imgui.EndDragDropSource()
			}
			if imgui.BeginDragDropTarget() {
				payload := imgui.AcceptDragDropPayload("DND_DEMO_CELL", nil)
				if payload != nil {
					payload_n := (cast(^int)payload.Data)^
					tmp := app_state.anim_files[n]
					app_state.anim_files[n] = app_state.anim_files[payload_n]
					app_state.anim_files[payload_n] = tmp
				}
				imgui.EndDragDropTarget()
			}
		}
	}
	imgui.End()

	if len(app_state.anim_files) > 0 {
		tex := app_state.anim_files[app_state.anim_index]
		using tex.gl_ctx
		gl.BindTexture(gl.TEXTURE_2D, tex_id)
		gl.BindVertexArray(vao)
		model := linalg.matrix4_translate(vec3{0, 0, 0})

		scale := linalg.matrix4_scale_f32(vec3{ratio.x, ratio.y, 0.5})
		transalation := linalg.matrix4_translate(vec3{0, 0, 0})
		view := transalation * scale


		//proj := linalg.matrix4_perspective_f32(1, f32(width)/f32(height), 0, 150)
		gl.UniformMatrix4fv(app_state.uniforms["view"].location, 1, gl.FALSE, &view[0, 0])
		gl.UniformMatrix4fv(app_state.uniforms["model"].location, 1, gl.FALSE, &model[0, 0])

		gl.DrawArrays(gl.TRIANGLES, 0, 6)
	}

	if imgui.Begin("Controls", nil, font_only_flags) {
		imgui.VSliderInt("##", {40, 300}, &app_state.speed, 1, 30)
		imgui.Text("Speed")
	}
	imgui.PopFont()
	imgui.End()

	if is_pressed(.SPACE) {
		app_state.play = !app_state.play
	}
	if is_pressed(.ACTION_DOWN) {
		app_state.speed -= 1
	}
	if is_pressed(.ACTION_UP) {
		app_state.speed += 1
	}
	if is_pressed(.ACTION_LEFT) {
		app_state.anim_index -= 1
	}
	if is_pressed(.ACTION_RIGHT) {
		app_state.anim_index += 1
	}

	if (app_state.play) {
		app_state.index += 1
	}
	if app_state.index >= app_state.speed {
		app_state.anim_index += 1
		app_state.index = 0
	}
	if app_state.anim_index >= i32(len(app_state.anim_files)) {
		app_state.anim_index = 0
	}
	if (app_state.anim_index < 0) {
		app_state.anim_index = i32(len(app_state.anim_files) - 1)
	}


}
