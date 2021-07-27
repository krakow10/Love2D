//By xXxMoNkEyMaNxXx
extern Image Map;
extern vec4 Sand;
extern vec2 size;

vec4 effect(vec4 _0,Image data,vec2 _2, vec2 iPixel){
	vec2 pixel=vec2(iPixel.x,size.y-iPixel.y);
	return mix(Texel(Map,pixel/size),Sand,Texel(data,pixel/size).r);
}
