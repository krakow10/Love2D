//By xXxMoNkEyMaNxXx
uniform vec2 size;
uniform float scale=2;
uniform float violence;

float erf(float x)//good to at least two decimal places, (minimum accuracy at about x=1.76140821)
{
	float xx=x*x;
	if(x<0)//erf approximaiton 4 kool ppl only
		return -sqrt(1-exp(-xx*(1.273239544735162+0.1473505*xx)/(1+0.1473505*xx)));//0.886226925452758*
	else
		return sqrt(1-exp(-xx*(1.273239544735162+0.1473505*xx)/(1+0.1473505*xx)));//0.886226925452758*
}

vec4 effect(vec4 _0,sampler2D image,vec2 tex,vec2 _3){
	float lasterf=erf(min(0.5*scale/violence,scale));
	vec4 colour=2*lasterf*texture2D(image,tex);
	for(int i=1;i<ceil(violence-0.5);++i){
		float thiserf=erf(scale*(i+0.5)/violence);
		colour+=(thiserf-lasterf)*(texture2D(image,tex-vec2(0,i)/size)+texture2D(image,tex+vec2(0,i)/size));
		lasterf=thiserf;
	}
	return (colour+(erf(scale)-lasterf)*(texture2D(image,tex-vec2(0,ceil(violence))/size)+texture2D(image,tex+vec2(0,ceil(violence))/size)))/(2*erf(scale));
}
