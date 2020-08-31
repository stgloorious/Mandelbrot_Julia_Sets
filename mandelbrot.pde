/* Draws a mandelbrot set.
 *
 */

import org.qscript.*;
double min_real=-2.5;
double max_real=1.5;
double real_range = max_real-min_real;
double res_real=0.01;

double min_im=-1;
double max_im=1;
double im_range=max_im-min_im;
double res_im=0.01;

int mag_threshold=3;
int max_iterations=1;

double zoom_factor=1;

float xDragOrigin=0;
float yDragOrigin=0;
boolean oldMousePressed=false;
double real_min_dragging=0;
double im_min_dragging=0;

float real_movement=0;
float im_movement=0;

void setup () {
  size(480, 240);
  noSmooth();
  colorMode(RGB, 255);
  background(0);
}

void draw () {
  background(0);
  res_im=(max_im-min_im)/width/2;
  res_real=(max_real-min_real)/height/2;
  double real, imaginary;
  for (real=min_real; real<=max_real; real+=res_real) {
    for (imaginary=min_im; imaginary<=max_im; imaginary+=res_im) {
      Complex c = new Complex(real, imaginary);
      //print("Calculating... [");
      //println(map((float)real, min_real, max_real, 0, 100), "%]");
      paintNumber(c, find_limit(c));
    }
  }
  real_range=max_real-min_real;
  im_range=max_im-min_im;
  if (mousePressed) {
    real_movement=map((xDragOrigin-mouseX), 0, width, 0, (float)real_range);
    im_movement=map((yDragOrigin-mouseY), 0, height, 0, (float)im_range);
    min_real=real_min_dragging+real_movement;
    min_im=im_min_dragging+im_movement;
    max_real=min_real+real_range;
    max_im=min_im+im_range;
  }

  if (max_iterations<20) {
    max_iterations++;
  }
}
void mousePressed() {
  xDragOrigin=mouseX;
  yDragOrigin=mouseY;
  real_min_dragging=min_real;
  im_min_dragging=min_im;
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  zoom_factor = e>0?1.1:0.9090909090909090909;

  double old_real_range = max_real-min_real;
  double old_im_range = max_im-min_im;

  double real_midpoint = old_real_range/2 + min_real;
  double im_midpoint = old_im_range/2 + min_im;

  real_range = zoom_factor * real_range;
  im_range = zoom_factor * im_range;


  min_real=real_midpoint-real_range/2;
  max_real=real_midpoint+real_range/2;

  min_im=im_midpoint-im_range/2;
  max_im=im_midpoint+im_range/2;

  println(real_range);
}

float find_limit (Complex c) {
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
  return (float)z.mag();
}

void paintNumber (Complex c, float mag) {
  int x=round(map((float)c.real, (float)min_real, (float)max_real, 0.0, (float)width));
  int y=round(map((float)c.imag, (float)min_im, (float)max_im, 0.0, (float)height));
  colorMode(RGB);
  if (mag!=-1) { 
    colorMode(HSB, 1.2);
    color clr = color(mag, 1.2, 1.2);
    set(x, y, clr);
  }
}
