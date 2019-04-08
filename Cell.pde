class Cell
{
  PVector pos; //position in the grid (not in pixcels)
  color col; //color of box stroke
  char marked= 'c';  //c - clear, x-marked as X, o-marked as O

  Cell(int x, int y, int z)
  {
    pos=new PVector(x,y,z);
    col=color(255);
  }
  
  void show(char mode)
  {
    noFill();
    
    switch(mode)
    {
      case 'n':   //normal
        stroke(col);
        strokeWeight(1);
      break;
      case 'p':   //pointed
        stroke(255,0,0);
        strokeWeight(1.5);
      break;
       case 'h':  //hidden
        stroke(col);
        strokeWeight(0.1);
      break;
    }
    pushMatrix();
    translate(pos.x*grid+pos.x, pos.y*grid+pos.y, pos.z*grid+pos.z);
        box(grid);
    //drawing symbols inside boxes
    if(marked=='o')
    {
      noStroke();
      fill(col);
      sphere(grid/4);
      noFill();
    }
    if(marked=='x')
    {
      noStroke();
      fill(col);
      box(grid*2/5);
      noFill();
    }
    popMatrix();
    
  }
  
  int walls() //checking if box is pointed with a mouse
  {
    int dist=-1;
    //checking if it is even possible to be touched
    if(proj(pos.copy().mult(grid)).dist(new PVector(mouseX,mouseY)) < proj(pos.copy().mult(grid)).dist(proj(new PVector(pos.x*grid+grid,pos.y*grid+grid,pos.z*grid+grid))))
    //checking all walls
    for(int i=0;i<6;i++)
    {
      if(wall(i))
      {
        float[] cpos=cam.getPosition();
        dist=int(pos.dist(new PVector(cpos[0],cpos[1],cpos[2])));
      }
    }
    return dist; //returning distance of the box from camera
  }

  boolean wall(int plane)  //checking particular wall
  {
    PVector[] corn=corners(); //getting positions of all corners of box
    //corners of particular walls
    int[][] planes = {{0,4,3,2},
                      {4,5,6,7},
                      {1,2,6,5},
                      {2,3,7,6},
                      {3,0,4,7},
                      {0,1,5,4}};
    PVector[] rect =new PVector[4]; //positions of rect. corners
    PVector[] Srect =new PVector[4]; //positoins mappec on screen
    for(int i=0;i<4;i++)
    {
      rect[i]=corn[planes[plane][i]]; //setting positions
      Srect[i]=proj(rect[i]);
    }
    if(mapP(Srect[0],Srect[1],Srect[2],Srect[3],new PVector(mouseX,mouseY))) //if mouse i inside return true
      return true;
    else
      return false;
  }

  void mark(char m) //mark cell as x or o
  {
    if(m=='x')
    {
        col=color(0,255,0);
        marked='x';
    }
    else if(m=='o')
    {
      col=color(0,0,255);
      marked='o';
    }
  }
  
  boolean win() //checking if there is winning row starting on this cell
  {
    //coordinations of all neighbours (9 above, 8 next to, 9 below)
    int[][] nbrs = {{-1,-1,-1},
                    {-1,-1,0},
                    {-1,-1,1},
                    {-1,0,-1},
                    {-1,0,0},
                    {-1,0,1},
                    {-1,1,-1},
                    {-1,1,0},
                    {-1,1,1},
                    {0,-1,-1},
                    {0,-1,0},
                    {0,-1,1},
                    {0,0,-1},
                    {0,0,1},
                    {0,1,-1},
                    {0,1,0},
                    {0,1,1},
                    {1,-1,-1},
                    {1,-1,0},
                    {1,-1,1},
                    {1,0,-1},
                    {1,0,0},
                    {1,0,1},
                    {1,1,-1},
                    {1,1,0},
                    {1,1,1}};
                    
    int[] axis = {4,10,12,13,15,21}; //numbers of neghbours plased straight next to (not diagonal)
    
    if(this.marked=='c') return false; //if not marked, it can't be in winning row
    int x=int(pos.x);
    int y=int(pos.y);
    int z=int(pos.z);
    for(int i=0;i<26;i++) //for each neighbour
    {
      if(diagonal || contains(axis,i)) //if not diagonal, we want only axes
        //checking if there are enough cells in given direction to make winning row
        if(!(x+(nbrs[i][0])*toWin<-1 || x+(nbrs[i][0])*toWin>size || y+(nbrs[i][1])*toWin<-1 || y+(nbrs[i][1])*toWin>size || z+(nbrs[i][2])*toWin<-1 || z+(nbrs[i][2])*toWin>size))
        {
        if(cube[x+nbrs[i][0]][y+nbrs[i][1]][z+nbrs[i][2]].marked==this.marked) //if neghbour is marked the sameprogram looks what is further
        {
          boolean wc=true;
          for(int w=0;w<toWin;w++) //checking rest of cells needed for win
          {
            if(cube[x+(nbrs[i][0])*w][y+(nbrs[i][1])*w][z+(nbrs[i][2])*w].marked!=this.marked) wc=false;
          }
         if(wc) return true; //if all were good, we have a win
        }
        }
    }
    return false;
  }
  
  PVector[] corners() //method returning coordinates of all corners of a box
  {
    PVector[] corn=new PVector[8];
    for (int i=0;i<corn.length;i++)
      corn[i]=new PVector(0,0,0);
    int half=grid/2;  
      
    corn[0].x=pos.x*grid+pos.x-half; 
    corn[0].y=pos.y*grid+pos.y-half; 
    corn[0].z=pos.z*grid+pos.z-half;

    corn[1].x=pos.x*grid+pos.x-half; 
    corn[1].y=pos.y*grid+pos.y-half; 
    corn[1].z=pos.z*grid+pos.z+half;

    corn[2].x=pos.x*grid+pos.x+half; 
    corn[2].y=pos.y*grid+pos.y-half; 
    corn[2].z=pos.z*grid+pos.z+half;

    corn[3].x=pos.x*grid+pos.x+half; 
    corn[3].y=pos.y*grid+pos.y-half; 
    corn[3].z=pos.z*grid+pos.z-half;

    corn[4].x=pos.x*grid+pos.x-half; 
    corn[4].y=pos.y*grid+pos.y+half; 
    corn[4].z=pos.z*grid+pos.z-half;

    corn[5].x=pos.x*grid+pos.x-half; 
    corn[5].y=pos.y*grid+pos.y+half; 
    corn[5].z=pos.z*grid+pos.z+half;

    corn[6].x=pos.x*grid+pos.x+half; 
    corn[6].y=pos.y*grid+pos.y+half; 
    corn[6].z=pos.z*grid+pos.z+half;

    corn[7].x=pos.x*grid+pos.x+half; 
    corn[7].y=pos.y*grid+pos.y+half; 
    corn[7].z=pos.z*grid+pos.z-half;

    return corn;
  }
}
