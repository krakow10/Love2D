//By xXxMoNkEyMaNxXx
const int fix=1;

extern vec4 BackColour;
extern vec4 PointColour;

extern mat2 View;
extern vec3 camPos;
extern mat3 camRot;
extern number Zoom;

extern vec2 Size;
extern Image[fix] DATA;

const number base=1.1;
vec3 Decode(vec4 data)
{
	return (2.0*data.xyz-1.0)*pow(base,255.0*data.w);
}
vec3 Retrieve(Image[fix] data,vec2 uv,int corrections)
{
	if(corrections>=0){
		vec3 value=Decode(Texel(data[0],uv));
		for(int i=1;i<corrections;i++)
			value+=Decode(Texel(data[i],uv));
		return value;
	}
	return vec3(0);
}

const number radius=0.06;
vec4 effect(vec4 _0,Image _1,vec2 _2,vec2 pixel)
{
	vec3 Ray=normalize(camRot*normalize(vec3((pixel-View[0]-View[1]/2)/View[1].y,exp2(Zoom))));
	for(int x=0;x<Size.x;x++)
	{
		for(int y=0;y<Size.y;y++)
		{
			vec3 point=Retrieve(DATA,vec2(x,y)/Size,fix);
			number r=dot(point-camPos,Ray);
			number dis=length(point-camPos-Ray*r);
			if(r>0&&dis<=radius)
			{
				return mix(PointColour,BackColour,dis/radius);
			}
		}
	}
	return BackColour;
}
