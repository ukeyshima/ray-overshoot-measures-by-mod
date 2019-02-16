precision mediump float;
uniform float iTime;
uniform vec2 iResolution;
#define PI 3.141592

float random(vec2 p){
  return fract(sin(dot(p.xy,vec2(12.9898,78.233)))*43758.5453123)*2.-1.;
}
float boxDistFunc(vec3 p,vec3 b,vec3 c){
  return length(max(abs(p-c)-b,0.));
}
float distFunc(vec3 p){
  vec3 q=p;
  q.xz=mod(p.xz,1.)-.5;
  return boxDistFunc(q,vec3(.4,2.*sin(1.3*iTime*abs(random(floor(p.xz))))*abs(random(floor(p.xz))),.4),vec3(0.,0.,0.));
}
vec3 getNormal(vec3 p){
  float d=.001;
  return normalize(vec3(
      distFunc(p+vec3(d,0.,0.))-distFunc(p+vec3(-d,0.,0.)),
      distFunc(p+vec3(0.,d,0.))-distFunc(p+vec3(0.,-d,0.)),
      distFunc(p+vec3(0.,0.,d))-distFunc(p+vec3(0.,0.,-d))
    ));
  }
  vec3 getRayColor(float signX,vec3 color,inout vec3 ray,inout vec3 origin){
    float distance=0.;
    float rLen=0.;
    vec3 rPos=origin;
    float marchCount=0.;
    for(int i=0;i<100;i++){
      distance=distFunc(rPos);
      if(abs(distance)<.01){
        color=vec3(.3,.3,.7);
        color+=marchCount/100./pow(rLen,2.);
        vec3 normal=getNormal(rPos);
        origin=rPos+normal*.02;
        ray=normalize(reflect(ray,normal));
        break;
      }
      rLen+=signX<0.?distance:min(min((step(0.,ray.x)-fract(rPos.x))/ray.x,(step(0.,ray.z)-fract(rPos.z))/ray.z)+.01,distance);
      rPos=origin+rLen*ray;
      marchCount++;
    }
    return color;
  }
  void mainImage(out vec4 fragColor,in vec2 fragCoord){
    vec2 p=(fragCoord*2.-iResolution.xy)/min(iResolution.x,iResolution.y);
    float signX=sign(p.x);
    vec2 pMax=iResolution.xy/min(iResolution.x,iResolution.y);
    p.x=p.x/pMax.x+step(p.x/pMax.x,0.);
    vec3 cPos=vec3(5.*sin(iTime/2.),1.5,5.*cos(iTime/2.));
    vec3 cDir=vec3(-cPos.x,0.,-cPos.z);
    vec3 cUp=vec3(0.,1.,0.);
    vec3 cSide=-cross(cDir,cUp);
    float depth=1.;
    vec3 ray=normalize(cSide*p.x+cUp*p.y+cDir*depth);
    vec3 color=vec3(0.);
    float alpha=.7;
    for(int i=0;i<3;i++){
      color+=alpha*getRayColor(signX,color,ray,cPos);
      alpha*=.6;
    }
    fragColor=vec4(color,1.);
  }