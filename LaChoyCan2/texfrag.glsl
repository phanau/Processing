#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D texture;
uniform vec2 noise;

varying vec4 vertColor;
varying vec4 vertTexCoord;


void main() {
  float si = vertTexCoord.s + noise[0];
  float sj = vertTexCoord.t + noise[1];
  gl_FragColor = texture2D(texture, vec2(si, sj)) * vertColor;
}
