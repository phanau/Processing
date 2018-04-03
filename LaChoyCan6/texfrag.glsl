#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

// the two textures and the mixing ratio
uniform sampler2D texture1;
uniform sampler2D texture2;
uniform float alpha2;

varying vec4 vertColor;
varying vec4 vertTexCoord;

void main() {
  // get texture colors for this pixel from the two textures
  vec4 c1 = texture2D(texture1, vertTexCoord.st);
  vec4 c2 = texture2D(texture2, vertTexCoord.st);

  // mix them according to the current mixture ratio
  vec4 c = c1*(1-alpha2) + c2*alpha2;

  // compute the pixel color
  gl_FragColor = c * vertColor;
}
