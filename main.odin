package main

import "base:runtime"
import "core:fmt"
import "core:math/linalg"
import "core:strings"
import gl "vendor:OpenGL"
import "vendor:glfw"
import stb "vendor:stb/image"

import imgui "./odin-imgui"
import "./odin-imgui/imgui_impl_glfw"
import "./odin-imgui/imgui_impl_opengl3"


width, height :: 1600, 800

window : glfw.WindowHandle

vertices := []f32 {
	// positions          //texture coords
	0.5,
	0.5,
	0.0,
	1.0,
	1.0, // top right
	0.5,
	-0.5,
	0.0,
	1.0,
	0.0, // bottom right
	-0.5,
	0.5,
	0.0,
	0.0,
	1.0, // top left 
	0.5,
	-0.5,
	0.0,
	1.0,
	0.0, // bottom right
	-0.5,
	-0.5,
	0.0,
	0.0,
	0.0, // bottom left
	-0.5,
	0.5,
	0.0,
	0.0,
	1.0, // top left 
}


add_file :: proc(file_path: cstring) {
	x, y, ch: i32
	data := stb.load(file_path, &x, &y, &ch, 4)
	fmt.printf("x = %d, y = %d, ch = %d \n", x, y, ch)

	anim_file : AnimFile ={}
	anim_file.file_path = strings.clone_from_cstring(file_path)
	//new_ctx: GlContext = {}
	using anim_file.gl_ctx
	if (x > y) {
		ratio.x = 1
		ratio.y = f32(y) / f32(x)
	} else {
		ratio.y = 1
		ratio.x = f32(x) / f32(y)
	}
	fmt.println(ratio)

	using gl
	GenVertexArrays(1, &vao)
	GenBuffers(1, &vbo)
	BindVertexArray(vao)
	BindBuffer(ARRAY_BUFFER, vbo)
	BufferData(ARRAY_BUFFER, size_of(f32) * len(vertices), raw_data(vertices), STATIC_DRAW)
	VertexAttribPointer(0, 3, FLOAT, TRUE, 5 * size_of(f32), 0)
	EnableVertexAttribArray(0)
	VertexAttribPointer(1, 2, FLOAT, TRUE, 5 * size_of(f32), (3 * size_of(f32)))
	EnableVertexAttribArray(1)

	Enable(BLEND)
	GenTextures(1, &tex_id)
	BindTexture(TEXTURE_2D, tex_id)
	TexImage2D(TEXTURE_2D, 0, RGBA, x, y, 0, RGBA, UNSIGNED_BYTE, data)
	TexParameteri(TEXTURE_2D, TEXTURE_MIN_FILTER, LINEAR_MIPMAP_LINEAR)
	TexParameteri(TEXTURE_2D, TEXTURE_MAG_FILTER, LINEAR)
	TexParameteri(TEXTURE_2D, TEXTURE_WRAP_S, MIRRORED_REPEAT)
	TexParameteri(TEXTURE_2D, TEXTURE_WRAP_T, MIRRORED_REPEAT)
	GenerateMipmap(TEXTURE_2D)

	//append(&textures, new_ctx)
	append(&app_state.anim_files, anim_file)

}

drop_callback :: proc "c" (window: glfw.WindowHandle, count: i32, paths: [^]cstring) {
	context = runtime.default_context()
	for i in 0 ..< count {
		fmt.println(paths[i])
		anim_file : AnimFile
		add_file(paths[i])
	}
}

vec3 :: linalg.Vector3f32
vec4 :: linalg.Vector4f32


main :: proc() {

	if !bool(glfw.Init()) {
		fmt.eprintln("GLFW has failed to load")
	}

	window = glfw.CreateWindow(width, height, "Animation editor", nil, nil)

	if window == nil do fmt.eprintln("GLFW has failed to load the window")

	defer glfw.Terminate()
	defer glfw.DestroyWindow(window)


	glfw.MakeContextCurrent(window)
	glfw.SetDropCallback(window, drop_callback)
	gl.load_up_to(4, 4, glfw.gl_set_proc_address)
	glfw.SwapInterval(1)

	imgui.CHECKVERSION()
	imgui.CreateContext(nil)
	style := imgui.GetStyle()
	style.WindowRounding = 10.0
	style.FrameBorderSize = 1.0
	style.GrabRounding = 10.0
	imgui_impl_glfw.InitForOpenGL(window, true)
	imgui_impl_opengl3.Init("#version 330")

	defer imgui_impl_glfw.Shutdown()
	defer imgui_impl_opengl3.Shutdown()

	gl.Viewport(400, 100, 800, 800)


		io := imgui.GetIO()
		app_state.fonts[0] = imgui.FontAtlas_AddFontFromFileTTF(
			io.Fonts,
			"C:/Windows/Fonts/Consola.ttf",
			30,
			nil,
			nil,
		)
		app_state.fonts[1] = imgui.FontAtlas_AddFontFromFileTTF(
			io.Fonts,
			"C:/Windows/Fonts/Consola.ttf",
			15,
			nil,
			nil,
		)
	for !glfw.WindowShouldClose(window) {
		glfw.PollEvents()
		gl.ClearColor(0.5, 0.5, 0.5, 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT)
		process_inputs()

		imgui_impl_opengl3.NewFrame()
		imgui_impl_glfw.NewFrame()
		imgui.NewFrame()

		render_app()


		imgui.Render()
		imgui_impl_opengl3.RenderDrawData(imgui.GetDrawData())
		glfw.SwapBuffers(window)
	}
}
