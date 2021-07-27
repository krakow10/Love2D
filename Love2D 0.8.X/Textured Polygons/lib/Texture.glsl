//Made by xXxMoNkEyMaNxXx

extern Image img;
extern vec2 v1;
extern vec2 v2;
extern vec2 v3;
extern vec2 v4;

extern number SIZEY;//So annoying

number c(vec2 v1,vec2 v2)
{
	return v1.x*v2.y-v2.x*v1.y;
}
number intersect(vec2 v1,vec2 d1,vec2 v2,vec2 d2)
{
	//v1+d1*
	return c(v2-v1,d2)/c(d1,d2);
}
vec4 mask(vec4 base,vec4 over)
{
	return vec4(over.rgb*over.a+base.rgb*(1-over.a),over.a+base.a*(1-over.a));
}
vec4 effect(vec4 colour,Image UNUSED1,vec2 UNUSED2,vec2 inverted)
{
	vec2 p=vec2(inverted.x,SIZEY-inverted.y);//SO ANNOYING

	vec2 A1=normalize(v2-v1);
	vec2 A2=normalize(v3-v4);

	vec2 B1=normalize(v2-v3);
	vec2 B2=normalize(v1-v4);

	//Vanishing points
	vec2 A=v1+A1*intersect(v1,A1,v4,A2);
	vec2 B=v3+B1*intersect(v3,B1,v4,B2);

	//Horizon
	vec2 H=normalize(A-B);

	//Unit
	vec2 ab=vec2(intersect(v4,-H,v2,-A1),intersect(v4,H,v2,-B1));

	//Pixel
	vec2 uv=vec2(intersect(v4,-H,A,normalize(p-A)),intersect(v4,H,B,normalize(p-B)));

	return mask(colour,Texel(img,uv/ab));
}
