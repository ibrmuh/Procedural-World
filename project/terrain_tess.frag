#version 410 core

in TES_OUT
{
    vec3 worldPos;
    vec3 worldNormal;
    vec2 texCoord;
    float height;
} fs_in;

out vec4 fragmentColor;

uniform vec3 uLightPosition;
uniform vec3 uCameraPosition;

// Simple color bands based on height.
// This also makes the terrain easier to read visually.
vec3 terrainColor(float h)
{
    if(h < -2.0)
        return vec3(0.18, 0.35, 0.16); // dark green low areas

    if(h < 2.0)
        return vec3(0.28, 0.52, 0.22); // grass-like mid areas

    if(h < 5.0)
        return vec3(0.45, 0.38, 0.25); // dirt/rock transition

    return vec3(0.65, 0.65, 0.62); // light rocky high areas
}

void main()
{
    vec3 N = normalize(fs_in.worldNormal);
    vec3 L = normalize(uLightPosition - fs_in.worldPos);
    vec3 V = normalize(uCameraPosition - fs_in.worldPos);
    vec3 H = normalize(L + V);

    float diffuse = max(dot(N, L), 0.0);
    float specular = pow(max(dot(N, H), 0.0), 32.0);

    vec3 baseColor = terrainColor(fs_in.height);

    vec3 color =
        baseColor * (0.25 + 0.75 * diffuse) +
        vec3(0.12) * specular;

    fragmentColor = vec4(color, 1.0);
}