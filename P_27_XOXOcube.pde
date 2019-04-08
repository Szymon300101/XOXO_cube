import peasy.*;
PeasyCam cam;

int size=3;  //numbers of boxes in a row
int grid=40; //size of a box
int toWin=size; //numbers of marks in a row to win
boolean diagonal=true;  //accepting diagonal wins

Cell[][][] cube = new Cell[size][size][size];
color Xcol=color(0,255,0);
color Ocol=color(0,0,255);

//hidden rows in each direction
int ofX=0;
int ofY=0;
int ofZ=0;

boolean cl=false; //mouse is clicked
char playing = 'x';  //active player
Cell chosen=null;  //highlighted box (before pressing space)

void setup()
{
  //size(900,500,P3D);
  fullScreen(P3D);

  cam = new PeasyCam(this, 400);
  cam.lookAt((grid+1)*(size-1)/2,(grid+1)*(size-1)/2,(grid+1)*(size-1)/2); //set center of cam to center of box
  cam.setCenterDragHandler(null); //locking cam center
  //constructing cells 
  for(int x=0;x<size;x++)
    for(int y=0;y<size;y++)
      for(int z=0;z<size;z++)
      cube[x][y][z]=new Cell(x,y,z);
}

void draw()
{
  background(0);
  //translate(-grid,-grid,-grid);
  //drawing a screen border
  cam.beginHUD();
  if(playing=='x')
    stroke(Xcol);
  else 
    stroke(Ocol);
  noFill();
  strokeWeight(2);
  rect(1,1,width-2,height-1);
  cam.endHUD();
  
  //drawing boxes, and checking if someone won
  for(int x=0;x<size;x++)
    for(int y=0;y<size;y++)
      for(int z=0;z<size;z++)
      {
        if(x>=max(0,-ofX) && x<size-max(0,ofX) && y>=max(0,-ofY) && y<size-max(0,ofY) && z>=max(0,-ofZ) && z<size-max(0,ofZ))
          cube[x][y][z].show('n');  //showing in normal mode
        else
          cube[x][y][z].show('h');  //showing as hidden
          
        if(cube[x][y][z].win())  //checking win conditions
        {
          cam.beginHUD();
          textSize(60);
          textAlign(CENTER,CENTER);
          text(cube[x][y][z].marked+" WON!",width/2,height/4);
          cam.endHUD();
          noLoop();  //stoping program
        }
      }
      
  //checkig hitboxes of cells
  int min=1000000;
  Cell c=null;
  for(int x=0;x<size;x++)
    for(int y=0;y<size;y++)
      for(int z=0;z<size;z++)
        if(x>=max(0,-ofX) && x<size-max(0,ofX) && y>=max(0,-ofY) && y<size-max(0,ofY) && z>=max(0,-ofZ) && z<size-max(0,ofZ))
        {
          //finding closest cell, thatis pointed by the mouse
          int d=cube[x][y][z].walls();
          if(d!=-1 && d<min)
          {
            min=d;
            c=cube[x][y][z];
          }
        }
    //if anything have been pointed
    if(c!=null)
    {
      c.show('p'); //show this cell as pointed
      if(cl && c.marked=='c') 
      {
        if(chosen!=null)
          if(chosen.marked=='c') chosen.col=color(255);
        chosen = c;
        if(playing =='x')
          chosen.col=Xcol;
        else
          chosen.col=Ocol;
      }
    }
    cl=false;
}

void keyPressed()
{
  switch(keyCode)
  {
    case 83: if(ofX<size-1) ofX++; //s
    break;
    case 87: if(ofX>-(size-1)) ofX--; //w
    break;
    case 65: if(ofZ<size-1) ofZ++; //a
    break;
    case 68: if(ofZ>-(size-1)) ofZ--;//d
    break;
    case 81: if(ofY<size-1) ofY++; //q
    break;
    case 69: if(ofY>-(size-1)) ofY--; //e
    break;
    case 32: //SPACE
      if(chosen!=null)
      {
        chosen.mark(playing);
        chosen=null;
        if(playing=='x') playing='o';
        else            playing='x';
      }
    break;
  }
}

void mouseClicked()
{
  if(mouseButton==LEFT) cl=true;
}

//a bit strange way to check if a point p is inside a quadrangle
boolean mapP(PVector a, PVector b, PVector c,PVector d, PVector p)  //l up,r up,r down, l down
{
  //rotating quadrangle if it is in wrong position
  while(b.y>d.y)
  {
    PVector t=d.copy();
    d=c.copy();
    c=b.copy();
    b=a.copy();
    a=t.copy();
  }
  while(a.y>c.y)
  {
    PVector t=a.copy();
    a=b.copy();
    b=c.copy();
    c=d.copy();
    d=t.copy();
  }
  boolean state=false;
  
  PVector v=a.copy(); //top edge
  v.lerp(b,map(abs(p.x-a.x),0,abs(b.x-a.x),0,1));
  state=v.y < p.y;
  
  v=d.copy();  //bottom edge
  v.lerp(c,map(abs(p.x-d.x),0,abs(c.x-d.x),0,1));
  state=v.y > p.y && state;
  
  v=a.copy();  //right edge
  v.lerp(d,map(abs(p.y-a.y),0,abs(d.y-a.y),0,1));
  state=v.x < p.x && state;
  
  v=b.copy();  //left edge
  v.lerp(c,map(abs(p.y-b.y),0,abs(c.y-b.y),0,1));
  state=v.x > p.x && state;
  
  return state;
}

PVector proj(PVector p3) //project 3D point to the screen
{
  return new PVector(screenX(p3.x,p3.y,p3.z),screenY(p3.x,p3.y,p3.z));
}

boolean contains(int[] ar, int val)  //function checking if array contains intiger
{
 for(int i=0;i<ar.length;i++)
   if(ar[i]==val) return true;
 return false;
}
