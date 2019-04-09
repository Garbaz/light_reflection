/**
Mirrors have an anchor (The point at which it is "attached") which is either on the end or in the middle of the length of the mirror (`anchorType`).
Light rays can reflect of mirrors using the function in the LightRay class.
*/
class Mirror {

  MirrorAnchorType anchorType;

  public PVector anchor;
  public float len;
  private float angle;

  public Mirror(PVector anchor, float len, float angle, MirrorAnchorType anchorType) {
    this.anchor = anchor;
    this.len = len;
    setAngle(angle);
    this.anchorType = anchorType;
  }

  public Mirror(float x, float y, float len, float angle, MirrorAnchorType anchorType) {
    this(new PVector(x, y), len, angle, anchorType);
  }
  public Mirror(PVector anchor, float len, float angle) {
    this(anchor, len, angle, MirrorAnchorType.MID);
  }
  public Mirror(float x, float y, float len, float angle) {
    this(new PVector(x, y), len, angle);
  }
  
  public Mirror(PVector p0, PVector p1) {
    anchorType = MirrorAnchorType.END0;
    anchor = p0;
    len = p0.dist(p1);
    setAngle(atan2(p1.y-p0.y, p1.x-p0.x));
  }

  void drawMe() {
    PVectorPair corners = getCorners();
    noFill();
    stroke(128);
//    circle(anchor.x, anchor.y, 4);
    stroke(200);
    line(corners.p0.x, corners.p0.y, corners.p1.x, corners.p1.y);
  }

  public PVectorPair getCorners() {
    if (anchorType == MirrorAnchorType.MID) {
      float rad = len/2;
      float radCosAngle = rad*cos(angle), radSinAngle = rad*sin(angle);
      return new PVectorPair(anchor.x - radCosAngle, anchor.y - radSinAngle, anchor.x + radCosAngle, anchor.y + radSinAngle);
    } else if (anchorType == MirrorAnchorType.END0) {
      return new PVectorPair(anchor.x, anchor.y, anchor.x + len*cos(angle), anchor.y + len*sin(angle));
    } else if (anchorType == MirrorAnchorType.END1) {
      return new PVectorPair(anchor.x, anchor.y, anchor.x - len*cos(angle), anchor.y - len*sin(angle));
    }
    println("ERROR <Mirror.getCorners()>: Unhandled achor type: " + anchorType);
    return null;
  }

  /**
   Sets the angle while ensuring that it's between 0 and 2*PI   
   */
  public void setAngle(float angle) {
    this.angle = (angle+ceil(abs(angle/TWO_PI))*TWO_PI)%TWO_PI;
  }

  public float getAngle() {
    return this.angle;
  }
}
