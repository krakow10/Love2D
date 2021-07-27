//By xXxMoNkEyMaNxXx
extern number h;
extern mat2 View;
extern mat2 Window;

extern number k;
extern number particleRadius;

extern number pnum;
extern vec2 positions[100];
extern number charges[100];

extern vec4 PlusColour;
extern vec4 MinusColour;

vec4 effect(vec4 BackColour,Image _1,vec2 _2,vec2 ipixel)
{
	vec2 pixel=vec2(ipixel.x,h-ipixel.y);
	vec2 p=Window[0]+Window[1]*(pixel-View[0]-0.5*View[1])/View[1].y;
	number negEdge=0;
	number posEdge=0;
	number Ep=0;
	if(pnum>0){
		for(int n=0;n<pnum;n++){
			vec2 diff=positions[n]-p;
			Ep+=k*charges[n]/length(diff);
			posEdge=max(k*charges[n]/particleRadius,posEdge);
			negEdge=min(k*charges[n]/particleRadius,negEdge);
		}
	}
	posEdge=max(-negEdge,posEdge);
	negEdge=min(-posEdge,negEdge);
	number percent=2*(Ep-negEdge)/(posEdge-negEdge)-1;
	if(percent>0)
		return mix(BackColour,PlusColour,sqrt(percent));//Not technically correct, but it is more visually pleasing than just 'percent'.
	if(percent<0)
		return mix(BackColour,MinusColour,sqrt(-percent));
	return BackColour;
}
