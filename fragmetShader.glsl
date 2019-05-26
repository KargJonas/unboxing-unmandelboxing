precision mediump float;
uniform float time;

// Good enough
#define PI 3.1415

// calculateColorotate a point around the Z axis
vec3 rotate(vec3 point, float angle) {
  return vec3(
    cos(angle) * point.y + sin(angle) * point.x,
    cos(angle) * point.x - sin(angle) * point.y,
    point.z
  );
}

float F(vec3 P) {
  float B = sin((time + P.z * 0.01) * 3.176) * 0.45 + 0.5, S = 3.4312 - sin(time * 0.1);
  vec4 p = vec4(P, 1);
  vec4 o = p;
  vec4 s = vec4(S, S, S, abs(S)) / B;

  for(int i = 0; i < 24; i ++ ) {
    if (i == 3 || i == 7 || i == 11 || i == 15 || i == 19 || i == 23)
    B = sin((time + P.z * 0.01 + float(i) * 0.25 * sin(time * 0.012211154) * 3.8) * 3.176) * 0.45 + 0.5;
    p.xyz = clamp(p.xyz, - 1.0, 1.0) * 2.0 - p.xyz;
    float r2 = dot(p.xyz, p.xyz);
    if (r2 > 1000.0)break;
    p = p * clamp(max(B / r2, B), 0.0, 1.0) * s + o;
  }

  return ((length(p.xyz) - abs(S - 1.0)) / p.w - pow(abs(S), float(1 - 24)));
}

// Distance probably
float D(vec3 p) {
  // This seems to be another camera position thing..
  vec3 c = vec3(10.0, 10.0, 8.0);

  p = mod(p, c) - 0.5 * c;

  vec3 q = abs(rotate(p, p.z * PI / 10.0 * 4.0));
  float d2 = max(q.z - 10.0, max((q.x * 0.866025 + q.y * 0.5), q.y) - 0.08);

  p = rotate(p, p.z * PI / 10.0 * (length(p.xy) - 3.0) * sin(time * 0.01) * 0.8);

  return max(F(p), - d2);
}

vec3 calculateColor(vec3 origin, vec3 direction) {
  float td = 0.0;
  float rd = 0.0;

  for(int i = 0; i < 80; i ++ )
  {
    rd = D(origin);
    if (rd < pow(td, 1.5) * 0.004)break;

    td += rd;
    origin += direction * rd;
  }

  float md = D(origin), e = 0.0025;
  vec3 n = normalize(vec3(
    D(origin + vec3(e, 0, 0)) - D(origin - vec3(e, 0, 0)),
    D(origin + vec3(0, e, 0))- D(origin - vec3(0, e, 0)),
    D(origin + vec3(0, 0, e))- D(origin - vec3(0, 0, e)))
  );

  e *= 0.5;

  // Occolusion, maybe?
  float occ = 1.0
    + (D(origin + n * 0.02 + vec3(-e, 0, 0))
    + D(origin + n * 0.02 + vec3(+e, 0, 0))
    + D(origin + n * 0.02 + vec3(0, - e, 0))
    + D(origin + n * 0.02 + vec3(0, e, 0))
    + D(origin + n * 0.02 + vec3(0, 0, - e))
    + D(origin + n * 0.02 + vec3(0, 0, e)) - 0.03) * 20.0;

  occ = clamp(occ, 0.0, 1.0);

  float br = (pow(clamp(dot(n, - normalize(direction + vec3(0.3, - 0.9, 0.4))) * 0.6 + 0.4, 0.0, 1.0), 2.7) * 0.8 + 0.2) * occ / (td * 0.5 + 1.0);

  float fog = clamp(
    1.0 / (td * td * 1.8 + 0.4),
    0.0, 1.0
  );

  return mix(
    vec3(
      br,
      br / (td * td * 0.2 + 1.0),
      br / (td + 1.0)
    ),
    vec3(0.0, 0.0, 0.0), 1.0 - fog
  );
}

void main() {
  // The position of the fragment
  vec2 pos = gl_FragCoord.xy;

  // This is needed because of the resolution setting.
  // vec2 screenCenter = vec2(213.0, 120.0);
  vec2 screenCenter = vec2(426.0, 240.0);

  // Distance vector between the fragment and the screen center
  vec3 d = vec3((pos - screenCenter) / screenCenter.y, 1.0);

  // Position of the camera
  vec3 cameraPosition = vec3(5.0, 5.0, time * 10.0);

  // Amount of fisheye effect
  float fisheye = 0.9;

  // Scale (x, y, z) stretches or squishes the scene
  vec3 scale = vec3(1.0, 1.0, 1.0 - (length(d.xy) * fisheye));

  // Color filter/brightness
  vec3 colors = vec3(0.6, 0.6, 0.6);

  // The calculated color of the fragment
  vec3 fragColor = pow(calculateColor(cameraPosition, normalize(d * scale)), colors);

  // Some more color grading (stuff that's further away gets some more color)
  // fragColor = floor(fragColor * vec3(8.0, 8.0, 4.0) + fract(pos.x / 4.0 + pos.y / 2.0) / 2.0) / vec3(7.0, 7.0, 3.0);

  // "Exagerating" colors (dark pixels get darker, bright ones get brighter)
  fragColor = pow(fragColor,vec3(1.5, 1.5, 1.5));

  // Setting the fragment's color.
  gl_FragColor = vec4(fragColor, 1.0);
}