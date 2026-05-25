#version 410 core

layout(vertices = 3) out;

// Input from the vertex shader.
in VS_OUT
{
    vec3 positionOS;
    vec3 normalOS;
    vec2 texCoord;
} tcs_in[];

// Output to the tessellation evaluation shader.
out TCS_OUT
{
    vec3 positionOS;
    vec3 normalOS;
    vec2 texCoord;
} tcs_out[];

uniform mat4 uModelMatrix;
uniform mat4 uViewMatrix;

uniform float uMinTessLevel;
uniform float uMaxTessLevel;
uniform float uMinTessDistance;
uniform float uMaxTessDistance;

// Convert camera distance into a tessellation level.
// Near patches get more detail, far patches get less.
float computeTessLevel(float distanceToCamera)
{
    float t = clamp(
        (distanceToCamera - uMinTessDistance) / (uMaxTessDistance - uMinTessDistance),
        0.0, 1.0
    );

    return mix(uMaxTessLevel, uMinTessLevel, t);
}

void main()
{
    // Pass through the triangle patch control points.
    tcs_out[gl_InvocationID].positionOS = tcs_in[gl_InvocationID].positionOS;
    tcs_out[gl_InvocationID].normalOS = tcs_in[gl_InvocationID].normalOS;
    tcs_out[gl_InvocationID].texCoord = tcs_in[gl_InvocationID].texCoord;

    gl_out[gl_InvocationID].gl_Position = vec4(tcs_in[gl_InvocationID].positionOS, 1.0);

    barrier();

    // Only one invocation needs to set the tessellation levels.
    if(gl_InvocationID == 0)
    {
        vec3 patchCenterOS =
            (tcs_in[0].positionOS + tcs_in[1].positionOS + tcs_in[2].positionOS) / 3.0;

        vec3 patchCenterVS = (uViewMatrix * uModelMatrix * vec4(patchCenterOS, 1.0)).xyz;
        float distanceToCamera = length(patchCenterVS);

        float tessLevel = computeTessLevel(distanceToCamera);

        gl_TessLevelOuter[0] = tessLevel;
        gl_TessLevelOuter[1] = tessLevel;
        gl_TessLevelOuter[2] = tessLevel;
        gl_TessLevelInner[0] = tessLevel;
    }
}