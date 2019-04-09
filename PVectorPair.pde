
class PVectorPair {
  PVector p0;
  PVector p1;

  public PVectorPair(PVector p0, PVector p1) {
    this.p0 = p0;
    this.p1 = p1;
  }

  public PVectorPair(float x0, float y0, float x1, float y1) {
    this(new PVector(x0, y0), new PVector(x1, y1));
  }
}
