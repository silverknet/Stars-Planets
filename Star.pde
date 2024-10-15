class Star {
  float x, y, depth;
  int alpha;
  Star(float _x,float _y, float _depth, int _alpha){
    x = _x;
    y = _y;
    depth = _depth;
    alpha = _alpha;
  }
  void add(PVector v){
    x += v.x;
    y += v.y;
  }
}
