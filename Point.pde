class Point {
  float x, y;
  Point(float _x,float _y){
    x = _x;
    y = _y;
  }
  void add(PVector v){
    x += v.x;
    y += v.y;
  }
}
