#version 330

layout (location = 0) in vec3 pos;
layout (location = 1) in vec2 tex_pos;

out vec2 tex_coord;

uniform mat4 model;
uniform mat4 view;
uniform mat4 proj;


void main(){
    gl_Position = proj * view  * model * vec4(pos, 1.0f);
    tex_coord   =  vec2(tex_pos.x, 1.0 - tex_pos.y);
}