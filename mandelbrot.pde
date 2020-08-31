/* Draws a mandelbrot set.
 *
 */

import org.qscript.*;
double min_real=-2.5;
double max_real=1.5;
double res_real=0.01;
double min_im=-1;
double max_im=1;
double res_im=0.01;

int mag_threshold=5;
int max_iterations=1;

double zoom_factor=1;

float xDragOrigin=0;
boolean oldMousePressed=false;

float real_movement=0;

void setup () {
  size(960, 480);
  noSmooth();
}

void draw () {
  colorMode(RGB);
  background(255);
  res_im=(max_im-min_im)/width/2;
  res_real=(max_real-min_real)/height/2;
  double real, imaginary;
  for (real=min_real; real<=max_real; real+=res_real) {
    for (imaginary=min_im; imaginary<=max_im; imaginary+=res_im) {
      Complex c = new Complex(real, imaginary);
      //print("Calculating... [");
      //println(map((float)real, min_real, max_real, 0, 100), "%]");
      paintNumber(c, lim(c));
    }
  }
  if (max_iterations<20) {
    max_iterations++;
  }
}
void mousePressed() {
  xDragOrigin=mouseX;
  real_movement=map((mouseX-xDragOrigin), 0, width, -2.5, 1.5);
  println(real_movement);
}

void mouseReleased(){
   min_real+=real_movement*0.1;
  max_real+=real_movement*0.1;
}

float lim (Complex c) {
  int iterations=0;
  Complex z = new Complex(0, 0);
  while (iterations<=max_iterations) {
    z = z.mult(z);
    z = z.add(c);
    iterations++;
    if (z.mag() >= mag_threshold) {
      return -1;
    }
  }
  //print(c);
  //print(" does converge to ");
  //println(z);
  return (float)z.mag();
}

void paintNumber (Complex c, float mag) {
  int x=round(map((float)c.real, (float)min_real, (float)max_real, 0.0, (float)width));
  int y=round(map((float)c.imag, (float)min_im, (float)max_im, 0.0, (float)height));
  if (mag<0) {  
    colorMode(RGB);
    set(x, y, color(0));
  } else {
    colorMode(HSB, 1.2);
    color clr = color(mag, 1.2, 1.2);
    set(x, y, clr);
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  zoom_factor = zoom_factor+(e/200.0);
  println(zoom_factor);
  min_real=min_real*zoom_factor;
  min_im=min_im*zoom_factor;
  max_real=max_real*zoom_factor;
  max_im=max_im*zoom_factor;
  max_iterations=1;
}
