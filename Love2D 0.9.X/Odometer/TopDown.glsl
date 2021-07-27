vec4 effect(vec4 _0,sampler2D image,vec2 _2,vec2 iPixel)
{
	vec2 p=vec2(iPixel.x-0.5,love_ScreenSize.y-iPixel.y-0.5);
	vec4 c=vec4(0,0,0,0);
	for(int i=0;i<=p.y;i++)
		c+=texture2D(image,vec2(p.x,i)/love_ScreenSize.xy);
	return c;
}