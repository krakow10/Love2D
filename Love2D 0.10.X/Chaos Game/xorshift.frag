//By Quaternions

vec4 effect(vec4 _0,Image _1,vec2 _2, vec2 pixel){
	uint i=uint(double(_0.r*255+_0.g*65280)+double(_0.b)*16711680+double(_0.a)*4278190080);
	i^=(i<<13);
	i^=(i>>17);
	i^=(i<<5);
	uint r=i%256;
	i=i>>8;
	uint g=i%256;
	i=i>>8;
	uint b=i%256;
	return vec4(r/255.,g/255.,b/255.,(i>>8)/255.);
}