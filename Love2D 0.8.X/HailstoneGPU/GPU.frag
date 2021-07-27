//By xXxMoNkEyMaNxXx
extern vec4 C0;//Failure
extern vec4 C1;//Success

extern vec2 r;//Screen resolution
extern number o;

const uint maxi=10000;
vec4 effect(vec4 _0,Image _1,vec2 _2,vec2 p)
{
	uint c=uint(o+p.x+p.y*r.x)<<1;
	uint n=c+1;
	uint i=0;
	while(c<n&&i<maxi){
		if(n&1)
			n=n*3+1;
		n>>1;
		i++;
	}
	if(i==maxi)
		return C0;
	return mix(C1,C0,float(i)/float(maxi));
}
