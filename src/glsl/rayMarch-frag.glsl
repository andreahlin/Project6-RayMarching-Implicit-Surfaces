
#define MAX_GEOMETRY_COUNT 100
#ifdef GL_ES
precision highp float;
#endif

/* This is how I'm packing the data
struct geometry_t {
    vec3 position;
    float type;
};
*/
uniform vec4 u_buffer[MAX_GEOMETRY_COUNT];
uniform int u_count;
uniform float u_cameraFOV;
uniform mat4 u_cameraTransf; 
uniform mat4 u_cameraProjectionInv;
uniform mat4 u_cameraViewInv; 
uniform vec3 u_cameraPosition;
uniform float u_alpha;  
uniform float u_aspect; 
uniform float u_farClip;

varying vec2 f_uv;
varying vec3 f_position; 

//-------------------------------------------------------------------------
float sphereSDF(vec3 p) {
	return length(p) - 1.0; 
}

float cylinderSDF(vec3 p, vec3 c) {
	return length(p.xz - c.xy) - c.z; 
}

float torusSDF(vec3 p, vec2 t) {
	vec2 q = vec2(length(p.xz) - t.x, p.y);
	return length(q) - t.y; 
}

float boxSDF(vec3 p, vec3 b) {
	vec3 d = abs(p) - b;
	return min(max(d.x, max(d.y, d.z)), 0.0) + length(max(d,0.0)); 
}

float coneSDF(vec3 p, vec2 c) {
	// c normalized
	float q = length(p.xy);
	return dot(c, vec2(q, p.z)); 
}

float triPrisSDF(vec3 p, vec2 h)
{
    vec3 q = abs(p);
    return max(q.z - h.y, max(q.x * 0.866025 + p.y * 0.5 , -p.y) -h.x * 0.5);
}

float hexPrisSDF( vec3 p, vec2 h )
{
    vec3 q = abs(p);
    return max(q.z - h.y, max((q.x * 0.866025 + q.y * 0.5), q.y) - h.x);
}

// total scene SDF
float sceneSDF(vec3 p) {
	return sphereSDF(p); 
}

// operators
float opIntersect(float d1, float d2) {
	return max(d1, d2);
}

float opUnion(float d1, float d2) {
	return min(d1, d2);
}

float opSubtract(float d1, float d2) {
	return max(-d1, d2); 
}

// vec3 opTranslate(vec3 p, mat4 m) {
// 	vec3 q = invert(m) * p;
// 	return sceneSDF(q); 
// }

float opScale(vec3 p, float s) {
	return sceneSDF(p/s) * s; 
}

vec3 estNormal(vec3 p) {
	float EPSILON = 0.0001; 
    vec3 toRet = normalize(vec3(
        sceneSDF(vec3(p.x + EPSILON, p.y, p.z)) - sceneSDF(vec3(p.x - EPSILON, p.y, p.z)),
        sceneSDF(vec3(p.x, p.y + EPSILON, p.z)) - sceneSDF(vec3(p.x, p.y - EPSILON, p.z)),
        sceneSDF(vec3(p.x, p.y, p.z  + EPSILON)) - sceneSDF(vec3(p.x, p.y, p.z - EPSILON))
    ));
    return toRet; 
}
//-----------------------------------------------------------------------------------------
void main() {
	// trying to get a sphere to show up... sad 
	float t = 0.1; 
	float EPSILON = 0.001; 
	float end = 100.0; 
	vec3 color = vec3(0.5,0.5,0.5); 

	// uv coordinates in NDC 
	float sx = (2.0 * f_uv.x) - 1.0;
	float sy = 1.0 - (2.0 * f_uv.y); 

	vec3 eye = u_cameraPosition;
	vec3 F = normalize(vec3(0.0,0.0,0.0) - eye); 
	vec3 R = normalize(cross(F, vec3(0.0, 1.0, 0.0)));
	vec3 U = normalize(cross(R, F));

	// screen point to world point
	vec3 ref = eye + t * F;
	vec3 len = abs(ref - eye);
	vec3 V = (U * len * u_alpha);
	vec3 H = (R * len * u_aspect * u_alpha);
	vec3 p = ref + (sx * H) + (sy * V);

	// get a ray from world point
	vec3 ray_direction = normalize(p - eye);
	vec3 point = eye + t * ray_direction; 

	// once more, let us try a different way once more ) : 
	// vec4 p = u_cameraViewInv * u_cameraProjectionInv * vec4(sx, sy, 0.5, 1.0);
	// vec3 eye = u_cameraPosition;
	// vec3 ray_direction = normalize(p.xyz - eye);
	// vec3 point = eye + t * ray_direction; 	

	for (int i = 0; i < 100; i++) {
		point = eye + t * ray_direction; 
		float dist = sphereSDF(point);
		if (dist < EPSILON) {
			// then you're inside the scene surface
			// color the fragment
			color = vec3(0.5,0.5,0.7);  
		} 
		t += dist; 
		if (t >= end) {
			// gone too far, end
			break;  
		}
	} 

	// some lame lambertian lighting, with a light source from the camera
	vec3 normal = estNormal(point); 
	float d = clamp(dot(normal, normalize(u_cameraPosition - f_position)), 0.0, 1.0);

	// color the output 
	gl_FragColor = vec4(d * color * 1.2, 1); // frag with Lambertian shading 
	// gl_FragColor = vec4(color, 1); 

}