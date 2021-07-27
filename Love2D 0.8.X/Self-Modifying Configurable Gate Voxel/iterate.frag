//By xXxMoNkEyMaNxXx
const int N=8;
extern Image[N] states;
extern Image input0;
extern Image input1;

vec4 effect(vec4 _0,Image config,vec2 percent,vec2 _3)
{
	ivec4 rules=ivec4(Texel(config,percent)*255.0);
	vec3 cell0=Texel(input0,percent).xyz;
	vec3 cell1=Texel(input1,percent).xyz;
	vec2 in0=Texel(states[int(floor(cell0.z*N))],cell0.xy).rg;
	vec2 in1=Texel(states[int(floor(cell1.z*N))],cell1.xy).rg;
	int digit=int(in0.x)+int(in0.y)<<1+int(in1.x)<<2;
	if(in1.y<0.5)
		return vec4((rules.xy>>digit)&1,0.0,1.0);
	else
		return vec4((rules.zw>>digit)&1,0.0,1.0);
}
