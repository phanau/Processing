#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

// the texture and the mixing ratio
uniform sampler2D texture1;
uniform float alpha1;

varying vec4 vertColor;
varying vec4 vertTexCoord;

void main() {
  // get texture colors for this pixel from two sub-regions of one texture
  vec4 c1 = texture2D(texture1, vec2(vertTexCoord.s, vertTexCoord.t/2));		// t = 0 to 0.5
  vec4 c2 = texture2D(texture1, vec2(vertTexCoord.s, vertTexCoord.t/2 + 0.5));	// t = 0.5 to 1

  // mix them according to the current mixture ratio
  vec4 c = c1*(1-alpha1) + c2*alpha1;

  // compute the pixel color
  gl_FragColor = c * vertColor;
}
