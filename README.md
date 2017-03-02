# HW 6: Ray marching and SDFs

## Project Description 
Implemented a ray marcher with sphere tracing to render various primitives using SDFs and additional operators. 

Implemented SDFs:
  - sphere
  - box
  - cone 
  - torus
  - cylinder
  - triangular prism
  - hexagonal prism

Additional operators: 
  - intersection
  - subtraction
  - union
  - scaling
  - computed normals based on gradients 

  The original RayMarching option in the program now renders a torus with Lambertian shading. The Machine option renders a combination of a few SDFs and union/subtraction operators. I had trouble getting the ray marcher to work properly for awhile, so I couldn't spend as much time playing around with the SDFs to make something cool. The camera controls also don't work anymore I don't really know why lol