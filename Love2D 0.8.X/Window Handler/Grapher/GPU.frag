//By xXxMoNkEyMaNxXx
extern vec4 BackColour;
extern vec4 LineColour;
extern vec4 GridColour;

extern number h;
extern mat2 View;
extern mat2 Window;

extern number RANDOM;
extern number Thickness;

/*/
const int degree=15;
extern number[degree] poly1;
extern number[degree] poly2;
/*/

number tau=2*3.1415926535897932384626433832795;

//Complex numbers plz?

//rtheta -> xy
vec2 rect(number r,number phi)
{
	return r*vec2(cos(phi),sin(phi));
}

//Exponentiation
vec2 Cpow(vec2 a,vec2 b)
{
	highp number r=length(a);
	highp number phi=atan(a.y,a.x);
	return rect(pow(r,b.x)/exp(b.y*phi),b.y*log(r)+b.x*phi);
}

number maxi=1000;
vec2 zeta(vec2 z)
{
	vec2 sum=vec2(1,0)+Cpow(vec2(-1,0),-z);
	for(number n=2;n<maxi;n++)
		sum+=Cpow(vec2(n,0),-z)+Cpow(vec2(-n,0),-z);
	return sum;
}

number function(vec2 p)
{
	//The line will appear where LEFT=RIGHT
	//You can put anything for either side of the equation.

	/******Things to try*******/
	/* y=pow(x,2)             */
	/* x*x+y*y=1              */
	/* sin(x*cos(y))=y*sin(x) */
	/**************************/

	/*
	number LEFT=length(p-vec2(-1,2))+length(p-vec2(0.5,1));
	number RIGHT=1.82;
	*/

	/*/
	number x=p.x;
	number y=p.y;
	number LEFT=1;
	number RIGHT=1;
	for(int i=0;i<degree;i++){
		LEFT*=y-poly1[i];
		RIGHT*=x-poly2[i];
	}
	return abs(LEFT-RIGHT);
	/*/
	return length(zeta(p));
}

const number D=10;//"Accuracy" of local minimum (not a huge difference)
vec4 effect(vec4 _0,Image _1,vec2 _2,vec2 ipixel)
{
	vec2 pixel=vec2(ipixel.x,h-ipixel.y);
	vec2 wv=Window[1]/View[1].y;
	vec2 p=Window[0]+(pixel-View[0]-0.5*View[1])*wv;//Point at pixel on graph
	number o=function(p);
	number total=0;
	number avg=0;
	number theta=RANDOM*tau;
	for(int i=0;i<D;i++){//Determining if the point is a local minimum
		number prx=function(p+Thickness*wv*vec2(cos(theta),sin(theta)));
		avg+=sign(prx-o);
		total+=prx;
		theta+=tau/D;
	}

	//Grid
	number roundTo=pow(10,floor(log(dot(Window[1],Window[1]))/log(100.0))-1);
	vec2 G=abs(p-floor(p/roundTo+0.5)*roundTo)/wv;
	vec4 Colour=mix(BackColour,GridColour,max(0,1-min(G.x,G.y)));

	//Line
	if(avg/D>0.6){//Change this parameter from -1<parameter<1 to adjust fuzzies
		return mix(Colour,LineColour,pow(1-D*o/total,2));
	}
	return Colour;
}
