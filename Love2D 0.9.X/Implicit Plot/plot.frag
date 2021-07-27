//By xXxMoNkEyMaNxXx
uniform vec2 ScreenOffset;
uniform vec2 ScreenView;
uniform vec2 WorldOffset;
uniform vec2 WorldView;

uniform vec4 LineColour=vec4(0,0,0,1);

uniform float omg=0.5;

uniform float q1=1;
uniform float q2=-1;
uniform float q3=-2;
uniform vec2 r1=vec2(2,0);
uniform vec2 r2=vec2(0,0);
uniform vec2 r3=vec2(4,0);

float f(vec2 r){//Function to plot
	float x=r.x,y=r.y;
	//return sin(r.x)+r.y*r.y-r.x;
	//return sin(x*cos(y))-y*sin(x);
	vec2 sum=q1*normalize(r-r1)+q2*normalize(r-r2)+q3*normalize(r-r3);
	return abs(sum.x)-omg;
}
//*
vec2 df(vec2 r){//Gradient of f
	float x=r.x,y=r.y;
	//return vec2(cos(r.x)-1,2*r.y);
	//return vec2(cos(y)*cos(x*cos(y))-y*cos(x),x*-sin(y)*cos(x*cos(y))-sin(x));
	float l1=length(r-r1),l2=length(r-r2);
	return vec2(q1/l1+q2/l2-q1*(x-r1.x)*(x-r1.x)/(l1*l1*l1)-q2*(x-r2.x)*(x-r2.x)/(l2*l2*l2),-q1*(x-r1.x)*(y-r1.y)/(l1*l1*l1)-q2*(x-r2.x)*(y-r2.y)/(l2*l2*l2));
}
//*/
vec4 effect(vec4 _0,sampler2D _1,vec2 _2,vec2 pixel){
	vec2 r=WorldOffset+WorldView*(pixel-ScreenOffset)/ScreenView;
	float v=f(r);
	if(v==0)
		return LineColour;
	//float dv=length(df(r)*WorldView/ScreenView);
	float dv=length(vec2(dFdx(v),dFdy(v)));//Lazy way
	if(dv>0)
		return LineColour*max(0,1-abs(v/dv));
	return vec4(0);
}
