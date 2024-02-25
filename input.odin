package main

import "vendor:glfw"

/*
    
*/

//NOTE: This could be a standard library code if written properly

ButtonState :: struct{
    //Stores if the key is up or down
    ended_down : bool,


    //Stores if there was change in the key in this frame
    half_trans_count : i32,
    /*
        We can get the pressed and release
        pressed = half_trans_count is > 0 and ended_down = false
        release = half_trans_count is > 0 and ened_down  = true
    */
}


Button :: enum {
		MOVE_UP,
		MOVE_DOWN,
		MOVE_LEFT,
		MOVE_RIGHT,
		ACTION_UP,
		ACTION_DOWN,
		ACTION_LEFT,
		ACTION_RIGHT,
		LEFT_SHOULDER,
		RIGHT_SHOULDER,
		BACK,
		ENTER,
		ESCAPE,
		SPACE,               
		DEL,
		F1,
		F2,
		F3,
		MOUSE_LEFT,
		MOUSE_RIGHT,
		CTRL,
}

//represents one input device, i.e. keyboard, gamepad
ControllerInput :: struct {
    is_connected, is_analog: b32,
    stick_x, stick_y : f32,
    buttons : [Button]ButtonState
}

Input :: struct{
    dt_for_frame : f32,
    mouse : [3]f64,
    mouse_buttons : ButtonState,
    controllers : [2]ControllerInput
}

process_keyboard_input :: proc (button: ^ButtonState, is_down: bool){
	if(button.ended_down != is_down){
		button.ended_down = is_down;
		button.half_trans_count += 1
	}
}

is_pressed :: proc(button: Button, index: int= 0) -> bool{
	input := &app_state.input
	using Button
	keyboard_input := &app_state.input.controllers[index]

	key := keyboard_input.buttons[button]
	return key.ended_down && (key.half_trans_count >0)
}

is_down :: proc(button: Button, index: int= 0) -> bool{
	input := &app_state.input
	keyboard_input := &app_state.input.controllers[index]

	key := keyboard_input.buttons[button]
	return key.ended_down 
}

process_inputs :: proc(){
	keyboard_input := &app_state.input.controllers[0]
	keyboard_input.is_connected = true;
	keyboard_input.is_analog    = false;

	for button in &keyboard_input.buttons{
		button.half_trans_count = 0;
	}
	buttons := &keyboard_input.buttons

	using glfw

	process_keyboard_input(&buttons[.MOVE_UP],GetKey(window, KEY_W) == PRESS)
	process_keyboard_input(&buttons[.MOVE_DOWN], GetKey(window, KEY_S) == PRESS)
	process_keyboard_input(&buttons[.MOVE_LEFT],GetKey(window, KEY_A) == PRESS)
	process_keyboard_input(&buttons[.MOVE_RIGHT],GetKey(window, KEY_D) == PRESS)
	process_keyboard_input(&buttons[.ACTION_UP ],GetKey(window, KEY_UP) == PRESS)
	process_keyboard_input(&buttons[.ACTION_DOWN],GetKey(window, KEY_DOWN) == PRESS)
	process_keyboard_input(&buttons[.ACTION_LEFT],GetKey(window, KEY_LEFT) == PRESS)
	process_keyboard_input(&buttons[.ACTION_RIGHT], GetKey(window, KEY_RIGHT) == PRESS)
	process_keyboard_input(&buttons[.LEFT_SHOULDER],GetKey(window, KEY_Q) == PRESS)
	process_keyboard_input(&buttons[.RIGHT_SHOULDER],GetKey(window, KEY_E) == PRESS)
	process_keyboard_input(&buttons[.BACK],GetKey(window, KEY_BACKSPACE) == PRESS)
	process_keyboard_input(&buttons[.ENTER],GetKey(window, KEY_ENTER) == PRESS)
	process_keyboard_input(&buttons[.ESCAPE],GetKey(window, KEY_ESCAPE) == PRESS)
	process_keyboard_input(&buttons[.SPACE],GetKey(window, KEY_SPACE) == PRESS)
	process_keyboard_input(&buttons[.F1],GetKey(window, KEY_F1) == PRESS)
	process_keyboard_input(&buttons[.F2],GetKey(window, KEY_F2) == PRESS)
	process_keyboard_input(&buttons[.F3],GetKey(window, KEY_F3) == PRESS)
	process_keyboard_input(&buttons[.DEL],GetKey(window, KEY_DELETE) == PRESS)


    process_keyboard_input(&buttons[.MOUSE_LEFT], GetMouseButton(window, MOUSE_BUTTON_LEFT) == PRESS)


	process_keyboard_input(&buttons[.MOUSE_RIGHT], GetMouseButton(window, MOUSE_BUTTON_RIGHT) == PRESS)
	process_keyboard_input(&buttons[.CTRL], GetKey(window, KEY_LEFT_CONTROL) == PRESS)
}





