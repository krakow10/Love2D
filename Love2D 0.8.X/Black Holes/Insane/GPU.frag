//By xXxMoNkEyMaNxXx xz
extern number u1;
extern number u21;
extern number u31;

extern number rs;

extern number sim;

extern vec2 pos;
extern vec2 m;

extern vec2 vs;
extern vec2 size;

number acc=1000;
number sn(number u,number m)
{
	number sum=0;
	for(number i=0;i<acc;i++){
		sum+=pow(1-m*pow(sin(u*i/acc),2),-0.5);
	}
	return u*sum/acc;
}

/*
number G=6.67398e-11;
number c=299792458;
*/

vec4 effect(vec4 _0,Image _1,vec2 _2,vec2 pixel)
{
	number t=sim*(size.x*pixel.y+pixel.x)/(size.x*size.y);
	number u=u1+u21*pow(sn(0.5*t*sqrt(rs*u31)+atan(vs.y-pos.y,m.x-pos.x),u21/u31),2);
	return vec4(t,u,u,1);
}
