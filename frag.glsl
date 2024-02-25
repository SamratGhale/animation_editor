#version 330 core

in vec2 tex_coord;
in vec3 color;
out vec4 FragColor;

uniform sampler2D tex;

void main(){
    vec4 tex_color = texture(tex, tex_coord);
    if(tex_color.a < 0.1){
        discard;
    }
    FragColor = tex_color;
}