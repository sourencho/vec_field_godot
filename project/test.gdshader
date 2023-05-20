shader_type canvas_item;

uniform sampler2D NOISE_PATTERN_A;
uniform sampler2D NOISE_PATTERN_B;

uniform float strength = 0.8;
uniform float noise_scale = 6.0;
uniform float noise_scale_b = 3.0;
uniform float noise_speed = 90.0;
uniform float noise_speed_b = 70.0;

const float squared_threshold = (0.1 * 0.1); //threshold value, squared

varying vec4 custom_data;

//  Function from Iñigo Quiles
//  https://www.shadertoy.com/view/MsS3Wc
vec3 hsb2rgb( in vec3 c ){
    vec3 rgb = clamp(abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),
                             6.0)-3.0)-1.0,
                     0.0,
                     1.0 );
    rgb = rgb*rgb*(3.0-2.0*rgb);
    return c.z * mix( vec3(1.0), rgb, c.y);
}

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
	float tex_a = texture(NOISE_PATTERN_A, fract((custom_data.xy) / noise_scale + TIME/noise_speed)).x;
	float tex_b = texture(NOISE_PATTERN_B, fract((custom_data.xy) / noise_scale_b - TIME/noise_speed_b)).x;
	float base = 0.5;
	float angle = 2.*PI*tex_a;
	vec2 dir = normalize(vec2(cos(angle), sin(angle)))/2.*tex_b*strength;
	vec2 v1 = vec2(base,base);
	vec2 v2 = vec2(base+dir.x, base+dir.y);
	
	// ====================================

	// Draw lines
	vec2 p = st_d;
    
    float th = 0.04 * tex_a;
    
	float s = udSegment(p, v1, v2) - th;
    
	// ====================================

	s = s;

	// Line color
    float r = smoothstep(-0.001, 0.001, -s);
	
	// Mix line with unique instance color
	float c = r; // * box;
	float a = 0.9;

	// ====================================
	// Make black tansparent
	if (c <= 0.1) {
		a = 0.0;
	}
	
	// ====================================
	
	float col_angle = mod(TIME/1., 2.*PI);
	float col_radius = 0.9;
	vec3 color = hsb2rgb(vec3((col_angle/(2.*PI))+0.5,col_radius,1.0));
	color.g = 1.0;
	color.b = 1.0;

	// ====================================
	float amp = 4.;
	vec3 line_color = vec3(c*tex_a*0.1,c*tex_a*tex_b*amp,c*tex_a*amp);
	
	vec3 out_color = mix(line_color, color, 0.);
	COLOR = vec4(out_color,a);
}