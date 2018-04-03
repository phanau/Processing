uniform mat4 transform;
uniform mat4 texMatrix;

uniform float noise;

attribute vec4 position;
attribute vec4 color;
attribute vec2 texCoord;

varying vec4 vertColor;
varying vec4 vertTexCoord;

void main() {
  gl_Position = transform * position;

  vertColor = color;
  vertTexCoord = texMatrix * vec4(texCoord+vec2(0,noise), 1.0, 1.0);
}
