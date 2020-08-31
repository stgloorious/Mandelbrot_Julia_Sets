/* Draws a mandelbrot set and allows for some mouse control
 *
 */

import org.qscript.*; //Includes Complex class

Complex min = new Complex(0,0);  //Minimum values that are shown on screen 
Complex max = new Complex(3.44,1.44);  //Maximum values that are shown on screen
Complex res = new Complex(0.01,0.01); //Resolution
Complex range = new Complex(); // Value range on screen

//If the result of the recursive function exceeds this value, 
//it is considered to be not part of the set.
int mag_threshold=500; 

//How many iterations of the recursive functions are done at max.
int max_iterations=50;

double zoom_factor=1;//At beginng soom factor of one is assumed
PVector dragOrigin = new PVector (0,0);//Mouse position when clicked
Complex dragMinimum = new Complex(0,0);//Minimum values before mouse was pressed
Complex dragMovement = new Complex(0,0);//Difference during mouse dragging

void setup () {
  size(3440, 1440);
  noSmooth();// No antialiasing
}

void draw () {
  background(0);//black
  //Resolution is dependant on the visible range 
  res= new Complex((max.imag-min.imag)/width,(max.real-min.real)/height/4);
  
  //Iterate through all complex numbers given the finite resolution
  double real, imaginary;
  for (real=min.real; real<=max.real; real+=res.real) {
    for (imaginary=min.imag; imaginary<=max.imag; imaginary+=res.imag) {
      Complex c = new Complex(real, imaginary);
      paintNumber(c, find_limit(c));//paint the pixel on the screen accordingly
    }
  }
  range=max.sub(min);
  if (mousePressed) {//if mouse is pressed, move the range
    dragMovement=new Complex(map((dragOrigin.x-mouseX), 0, width, 0, (float)range.real),map((dragOrigin.y-mouseY), 0, height, 0, (float)range.imag));
    min = dragMinimum.add(dragMovement);
    max = min.add(range);
  }
  if (keyPressed){
    saveFrame("wallpaper.png");
  }
}

// MATH
float find_limit (Complex c) {
  int iterations=0;
  Complex z = new Complex(0, 0);//starting with z=0
  while (iterations<=max_iterations) {//allow a maximum number of iterations (recursion levels)
    // FUNCTION THAT DETERMINES THE MANDELBROT SET:
    z = z.mult(z); // z -> z^2
    z = z.add(c); // z -> z + c
    iterations++;
    if (z.mag() >= mag_threshold) {
      return iterations;//no limit exists (divergence)
      //return -1;//no limit exists (divergence) (Drawing style)
    }
  }
  //(Choose drawing style)
  //if there is convergence and a limit exists, return the magnitude of the limit (approx.).
  //return (float)z.mag();
  
  //if there is convergence and a limit exists, return the number of iterations.
  return 0;//iterations;
}

// GRAPHICS
void paintNumber (Complex c, float mag) {
  int x=round(map((float)c.real, (float)min.real, (float)max.real, 0.0, (float)width));
  int y=round(map((float)c.imag, (float)min.imag, (float)max.imag, 0.0, (float)height));
  colorMode(RGB);
  if (mag!=-1) {//paint only numbers that converge
   /* colorMode(HSB, 1.2);//map the color scheme to a magnitude from 0 to 1.2
    color clr = color(mag, 1.2, 1.2);
    set(x, y, clr);//draw pixel*/
    //(Drawing style)
    colorMode(HSB, 50);//map the color scheme to a magnitude from 0 to 1.2
    color clr = color(mag);
    set(x, y, clr);//draw pixel
  }
}

// MOUSE CONTROL
//Translation
void mousePressed() {
  dragOrigin.x=mouseX;
  dragOrigin.y=mouseY;
  dragMinimum=min;
}

// Zoom
void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  zoom_factor = e>0?1.1:0.9090909090909090909;//one zoom step is a 10% magnification
  max_iterations = e<0?max_iterations+1:max_iterations-1;//make the maximum iterations a function of the zoom level
  Complex old_range = new Complex(max.sub(min));
  //remember the midpoint, so the zoom origin is always the center
  Complex midpoint = old_range.mult(0.5).add(min);
  //apply zoom factor to old range
  range = range.mult(zoom_factor);
  //calculate end points
  min=midpoint.sub(range.mult(0.5));
  max=midpoint.add(range.mult(0.5));
}
