/**
 A light ray is cast from the anchor point in the direction dictated by the angle.
 Reflection with mirrors can be simluated with the respective function.
 */
class LightRay {
  final float EPS = 1e-4;            // A mostly arbitrarilly chosen small float to compare against instead of zero. Value chosen experimentally.
  final float MIN_MIRROR_DIST = 1; // Mininmum distance between the anchor and an intersection with a mirror for it to count as a reflection. Prevent a ray from getting "stuck" in a mirror.
  final int   MAX_REFLECTIONS = 64;  // Limits the maximum amount of reflections to ensure a finite (and reasonable) runtime of the reflection function.

  private LightRay reflectionChild = null;
  private int reflectionRank = 0;

  public PVector anchor;
  private float angle;
  public float len;


  public LightRay(PVector anchor, float angle, float len) {
    this.anchor = anchor;
    this.setAngle(angle);
    this.len = len;
  }

  public LightRay(float x, float y, float angle, float len) {
    this(new PVector(x, y), angle, len);
  }

  public LightRay(PVector anchor, float angle) {
    this(anchor, angle, Float.POSITIVE_INFINITY);
  }

  public LightRay(float x, float y, float angle) {
    this(new PVector(x, y), angle);
  }


  /**
   Returns the intersection point of the Ray with the line from (x0,y0) to (x1,y1). If the ray does not intersect the line, null is returned.
   */
  public PVector intersectLine(float x0, float y0, float x1, float y1) {

    float a = cos(angle+HALF_PI), b = sin(angle+HALF_PI);
    float a_, b_;
    if (abs(x0 - x1) < abs(y1 - y0)) {
      a_ = 1;
      b_ = (x1-x0)/(y0-y1);
    } else {
      a_ = (y0-y1)/(x1-x0);
      b_ = 1;
    }

    float k = a*anchor.x+b*anchor.y, k_ = a_*x0+b_*y0;
    float d = a*b_-b*a_;

    if (abs(d) < EPS) { // Parallel or almost parallel lines
      return null;
    }

    float x_sol = (b_*k-b*k_)/d, y_sol = (a*k_-a_*k)/d;

    if ( abs(quadrantAngle(y_sol-anchor.y, x_sol-anchor.x)-angle) <= HALF_PI &&
      min(x0, x1)-x_sol < EPS && x_sol-max(x0, x1) < EPS && min(y0, y1)-y_sol < EPS && y_sol-max(y0, y1) < EPS) {
      return new PVector(x_sol, y_sol);
    } else {
      return null;
    }
  }

  public PVector intersectLine(PVector p0, PVector p1) {
    return intersectLine(p0.x, p0.y, p1.x, p1.y);
  }

  public PVector intersectLine(PVectorPair p) {
    return intersectLine(p.p0, p.p1);
  }

  public void reflect(Mirror[] mirrors) {

    final int LEN = mirrors.length;
    PVectorPair[] mirrorCorners = new PVectorPair[LEN];
    for (int i= 0; i < mirrors.length; i++) {
      mirrorCorners[i] = mirrors[i].getCorners();
    }

    PVector[] inters = new PVector[LEN];

    for (int i= 0; i < LEN; i++) {
      inters[i] = intersectLine(mirrorCorners[i]);
    }

    int minIndex = -1;
    float minDist = Float.POSITIVE_INFINITY;
    for (int i = 0; i < LEN; i++) {
      if (inters[i] != null) {
        float currDist = inters[i].dist(anchor);
        if (MIN_MIRROR_DIST <= currDist && currDist < minDist) {
          minIndex = i;
          minDist = currDist;
        }
      }
    }

    if (minIndex == -1) {
      len = Float.POSITIVE_INFINITY;
      reflectionChild = null;
    } else {
      len = anchor.dist(inters[minIndex]);
      if (reflectionRank <= MAX_REFLECTIONS) {
        reflectionChild = new LightRay(inters[minIndex], 2*mirrors[minIndex].angle-angle);
        reflectionChild.setReflectionRank(reflectionRank);
        reflectionChild.reflect(mirrors);
      } else {
        fill(#880000);
        textAlign(RIGHT);
        text("MAX REFLECTIONS!", WIDTH-16, 16);
        textAlign(LEFT);
      }
    }
  }

  /**
   Draws the ray as a line going "to infinity"/out of the screen.
   To achieve this the end point of the line is chosen to always be outside the canvas.
   */
  public void drawMe(color c) {
    stroke(c);
    float endpointScalar = len;//1.5* because 1.5 > sqrt(2)
    if (endpointScalar == Float.POSITIVE_INFINITY) {
      endpointScalar = 1.5*max(WIDTH, HEIGHT);
    }
    line(anchor.x, anchor.y, anchor.x+endpointScalar*cos(angle), anchor.y+endpointScalar*sin(angle));
    if (reflectionRank == 0) {
      pushMatrix();
      fill(c);
      stroke(0);
      translate(anchor.x, anchor.y);
      rotate(angle);
      ellipse(0, 0, 8, 4);
      popMatrix();
    }

    if (reflectionChild != null) {
      reflectionChild.drawMe(c);
    }
  }


  /**
   "Turns" the Ray to go through (x,y).
   */
  public void pointTo(float x, float y) {
    this.angle = atan2(y-anchor.y, x-anchor.x);
  }

  /**
   Sets the angle while ensuring that it's between -PI and PI   
   */
  public void setAngle(float angle) {
    this.angle = (angle+PI)%TWO_PI - PI;
  }

  public float getAngle() {
    return this.angle;
  }

  public void setReflectionRank(int parentRank) {
    reflectionRank = parentRank+1;
  }

  // A very very rough approximation of atan2. Basically rounds to the nearest quadrant.
  // Used for checking whether two vectors are pointing into the same quadrant.
  private float quadrantAngle(float y, float x) {
    if (x >= 0 && y >= 0) {
      return QUARTER_PI;
    } else if (x >= 0 && y <= 0) {
      return -QUARTER_PI;
    } else if (x <= 0 && y >= 0) {
      return 3*QUARTER_PI;
    } else {
      return -3*QUARTER_PI;
    }
  }
}

/*
//First attempt at a line intersection algorithm. Has problems with vertical and horizontal lines
 public PVector intersectLine(float x0, float y0, float x1, float y1) {
 float slope_ray = tan(angle);
 float slope_line = (y1-y0)/(x1-x0);
 
 float offset_ray = anchor.y-slope_ray*anchor.x;
 float offset_line = y0-slope_line*x0;
 
 float solution_x =(offset_line-offset_ray)/(slope_ray-slope_line);
 float solution_y = slope_line*solution_x+offset_line;
 
 //fill(0);
 //text("solution_x = " + round(solution_x) + ", solution_y = " + round(solution_y), 0, 10);
 //text("solution_y = " + round(solution_y) + ", angle = " + angle, 0, 10);
 //circle(solution_x, solution_y, 8);
 
 if ( ((solution_y-anchor.y >= 0 && angle >= 0) || (solution_y-anchor.y <= 0 && angle <= 0)) 
 && min(x0, x1) < solution_x && solution_x < max(x0, x1) && min(y0, y1) < solution_y && solution_y < max(y0, y1)) {
 
 return new PVector(solution_x, solution_y);
 } else {
 return null;
 }
 }
 */

//((y_sol-anchor.y > -eps && angle > -eps) || (y_sol-anchor.y < eps && angle < eps))
