#version 410 core

layout(location = 0) in vec3 position;
layout(location = 1) in vec3 normal;
layout(location = 2) in vec2 texCoord;

// Pass the coarse terrain data to the tessellation stage.
out VS_OUT
{
    vec3 positionOS;
    vec3 normalOS;
    vec2 texCoord;
} vs_out;

void main()
{
    vs_out.positionOS = position;
    vs_out.normalOS = normal;
    vs_out.texCoord = texCoord;

    // gl_Position is not used for final rasterization here,
    // but some drivers still expect it to be written.
    gl_Position = vec4(position, 1.0);
}