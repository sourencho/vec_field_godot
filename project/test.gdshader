shader_type canvas_item;

uniform sampler2D NOISE_PATTERN_A;
uniform sampler2D NOISE_PATTERN_B;
uniform sampler2D NOISE_PATTERN_C;

const float squared_threshold = (0.1 * 0.1); //threshold value, squared

varying vec4 custom_data;

float udSegment( in vec2 p, in vec2 a, in vec2 b )
{
    vec2 ba = b-a;
    vec2 pa = p-a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return length(pa-h*ba);
}

void vertex()
{
	custom_data = INSTANCE_CUSTOM;
}

void fragment()
{
	// ====================================
	
	// Get pixel coord
	vec2 st = UV.xy;
	
	float noise_scale = 10.0;
	float speed = 60.0;
	
	// ====================================

	// Break space into parts
    float d = 1.0;
    st *= d;      // Scale up the space by d
    vec2 st_d = fract(st); // Wrap around 1.0
    vec2 st_f = floor(st);
    
	// Transform st_f into unique number
    float box = mod(1.0/(d*d)*(d*st_f.x+st_f.y),1.0);
	
	// ====================================
	
	// Sample texture
	float tex_a = texture(NOISE_PATTERN_A, fract((custom_data.xy) / noise_scale + TIME/speed)).x;
	float tex_b = texture(NOISE_PATTERN_B, fract((custom_data.xy) / noise_scale + TIME/speed)).x;
	float tex_c = texture(NOISE_PATTERN_C, fract((custom_data.xy) / noise_scale + TIME/speed)).x;
	float base = 0.5;
	vec2 dir = normalize(vec2(cos(2.*PI*tex_a), sin(2.*PI*tex_a)))/2.*tex_b;
	vec2 v1 = vec2(base,base);
	vec2 v2 = vec2(base+dir.x, base+dir.y);
	
	// ====================================

	// Draw lines
	vec2 p = st_d;
    
    float th = 0.03 * tex_b;
    
	float s = udSegment(p, v1, v2) - th;
    
	// ====================================

	s = s;

	// Line color
    float r = smoothstep(-0.001, 0.001, -s);
	
	// Mix line with unique instance color
	float c = r; // * box;
	float a = 1.0;

	// ====================================void
	if (c <= 0.1) {
		a = 0.0;
	}

	// ====================================

	// COLOR = vec4(c,0,0,1);
	COLOR = vec4(tex_b*0.1,c*tex_a*tex_b*2.,c*tex_a*2.,a);
}