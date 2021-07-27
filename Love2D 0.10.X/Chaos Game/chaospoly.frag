//By Quaternions

uniform int Npoints;
uniform vec2 points[128];

uniform Image randomdata;

vec4 effect(vec4 _0,Image _1,vec2 _2, vec2 pixel){
	vec4 rand=Texel(randomdata,_2);
	return vec4((points[int(rand.r*255+rand.g*65280)%Npoints]+_0.xy)/2,(points[int(rand.b*255+rand.a*65280)%Npoints]+_0.zw)/2);
}