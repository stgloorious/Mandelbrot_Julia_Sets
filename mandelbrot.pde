/* Draws julia set and allows for some mouse control
 *
 */

import org.qscript.*; //Includes Complex class

Complex min = new Complex(-2, -2);  //Minimum values that are shown on screen 
Complex max = new Complex(2, 2);  //Maximum values that are shown on screen
Complex res = new Complex(0.01, 0.01); //Resolution
Complex range = new Complex(); // Value range on screen

Complex c = new Complex (-0.6, 0.6);//Parameter used to iterate through julia sets
Complex c_res = new Complex (0.01, 0.01); //Increment value
Complex c_max = new Complex (1, 1); //Maximum value for parameter c
Complex c_min = new Complex (-1, -1); //Maximum value for parameter c
boolean dirReal = true; //true means increasing
boolean dirImag = true;

//If the result of the recursive function exceeds this value, 
//it is considered to be not part of the set.
double mag_threshold=0.1; 

//How many iterations of the recursive functions are done at max.
int max_iterations=100;

double zoom_factor=1;//At beginng soom factor of one is assumed
PVector dragOrigin = new PVector (0, 0);//Mouse position when clicked
Complex dragMinimum = new Complex(0, 0);//Minimum values before mouse was pressed
Complex dragMovement = new Complex(0, 0);//Difference during mouse dragging

PFont cmu;

void setup () {
  size(480, 480);
  noSmooth();// No antialiasing

  cmu = createFont("cmu.ttf", 48);
  textFont(cmu);
}

void draw () {
  background(0);//black
  //Resolution is dependant on the visible range 
  res= new Complex((max.imag-min.imag)/width, (max.real-min.real)/height/2);

  //Iterate through all complex numbers given the finite resolution
  double real, imaginary;
  for (real=min.real; real<=max.real; real+=res.real) {
    for (imaginary=min.imag; imaginary<=max.imag; imaginary+=res.imag) {
      Complex z = new Complex(real, imaginary);
      paintNumber(z, find_limit(z, c));//paint the pixel on the screen accordingly
    }
  }
  range=max.sub(min);
  if (mousePressed) {//if mouse is pressed, move the range
    dragMovement=new Complex(map((dragOrigin.x-mouseX), 0, width, 0, (float)range.real), map((dragOrigin.y-mouseY), 0, height, 0, (float)range.imag));
    min = dragMinimum.add(dragMovement);
    max = min.add(range);
  }
  //Sweep through all parameters
 /* if (dirReal) {
    if (c.real<c_max.real) {
      c = new Complex(c.real+c_res.real, c.imag);
    } else {
      dirReal=!dirReal;
      if (dirImag) {
        if (c.imag<c_max.imag) {
          c = new Complex(c.real, c.imag+c_res.imag);
        } else {
          dirImag=!dirImag;
        }
      } else {
        if (c.imag>c_min.imag) {
          c = new Complex(c.real, c.imag-c_res.imag);
        } else {
          dirImag=!dirImag;
        }
      }
    }
  } else {
    if (c.real>c_min.real) {
      c = new Complex(c.real-c_res.real, c.imag);
    } else {
      dirReal=!dirReal;
    }
  }*/
  text(nf((float)c.real,0,2)+"+"+nf((float)c.imag,0,2)+"i", 12, 60);
}

// MATH
float find_limit (Complex z, Complex c) {
  int iterations=0;
  while (iterations<=max_iterations) {//allow a maximum number of iterations (recursion levels)
    // FUNCTION THAT DETERMINES THE JULIA SET:
    z = z.mult(z); // z -> z^2
    z = z.add(c); // z -> z + c
    iterations++;
    if (z.mag() <= mag_threshold) {
      //return -1;//no limit exists (divergence)
      return iterations;
    }
  }
  //if there is convergence and a limit exists, return the magnitude of the limit (approx.).
  //return (float)z.mag();
  return -1;
}

// GRAPHICS
void paintNumber (Complex c, float mag) {
  int x=round(map((float)c.real, (float)min.real, (float)max.real, 0.0, (float)width));
  int y=round(map((float)c.imag, (float)min.imag, (float)max.imag, 0.0, (float)height));
  colorMode(RGB);
  if (mag!=-1) {//paint only numbers that converge
    colorMode(HSB, 50);//map the color scheme to a magnitude from 0 to 1.2
    color clr = color(mag, 50, 50);
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
