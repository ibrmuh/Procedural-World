#version 410 core

layout(triangles, fractional_odd_spacing, ccw) in;

// Input from tessellation control shader.
in TCS_OUT
{
    vec3 positionOS;
    vec3 normalOS;
    vec2 texCoord;
} tes_in[];

// Output to the fragment shader.
out TES_OUT
{
    vec3 worldPos;
    vec3 worldNormal;
    vec2 texCoord;
    float height;
} tes_out;

uniform mat4 uModelMatrix;
uniform mat4 uViewMatrix;
uniform mat4 uProjectionMatrix;

// Interpolate a vec3 over the tessellated triangle.
vec3 interpolateVec3(vec3 a, vec3 b, vec3 c)
{
    return gl_TessCoord.x * a +
           gl_TessCoord.y * b +
           gl_TessCoord.z * c;
}

// Interpolate a vec2 over the tessellated triangle.
vec2 interpolateVec2(vec2 a, vec2 b, vec2 c)
{
    return gl_TessCoord.x * a +
           gl_TessCoord.y * b +
           gl_TessCoord.z * c;
}

void main()
{
    vec3 positionOS = interpolateVec3(
        tes_in[0].positionOS,
        tes_in[1].positionOS,
        tes_in[2].positionOS
    );

    vec3 normalOS = normalize(interpolateVec3(
        tes_in[0].normalOS,
        tes_in[1].normalOS,
        tes_in[2].normalOS
    ));

    vec2 texCoord = interpolateVec2(
        tes_in[0].texCoord,
        tes_in[1].texCoord,
        tes_in[2].texCoord
    );

    vec4 worldPos4 = uModelMatrix * vec4(positionOS, 1.0);
    mat3 normalMatrix = mat3(transpose(inverse(uModelMatrix)));

    tes_out.worldPos = worldPos4.xyz;
    tes_out.worldNormal = normalize(normalMatrix * normalOS);
    tes_out.texCoord = texCoord;
    tes_out.height = positionOS.y;

    gl_Position = uProjectionMatrix * uViewMatrix * worldPos4;
}