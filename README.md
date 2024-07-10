# GLOF-SFE
Global Luminescent Oil Film image based Skin friction Field Estimator
![glof_example](/glof.jpg)

## Description
This is an image analysis toolbox for estimation of high-resolution skin friction
field from flow visualization (global luminescent oil film, GLOF) images.

Detail of the method is described in following paper.

Taekjin Lee, Taku Nonomura, Keisuke Asai, and Tianshu Liu, "Linear least-squares
method for global luminescent oil film skin friction field analysis", Review of
Scientific Instruments 89, 065106 (2018).
<https://doi.org/10.1063/1.5001388>

## Requirement
* Minimum
  * MATLAB 2013a or later
  * Image Processing Toolbox
* Optional (GPGPU usage)
  * MATLAB R2016a or later
  * Parallel Computing Toolbox

## Install
1. Unpack the files, if necessary
2. Start MATLAB
3. Within MATLAB, execute install.m

## Examples
Please download sample GLOF image sets from `data/`.

## How to cite
If you use the GLOF-SFE toolbox in your work, please cite the software itself and relevant paper(s).

__General software reference:__
``` bibtex
@misc{GLOFSFE_toolbox,
  author = {Taekjin Lee and Liu, Tianshu},
  title = {Global Luminescent Oil Film image based Skin friction Field Estimator},
  howpublished = {Available online},
  month = aug,
  year = {2018},
  url = {https://github.com/technolojin/GLOFSFE}
}
```
__Linear Least-Squares method:__
``` bibtex
@article{lee2018linear,
  title={Linear least-squares method for global luminescent oil film skin friction field analysis},
  author={Lee, Taekjin and Nonomura, Taku and Asai, Keisuke and Liu, Tianshu},
  journal={Review of Scientific Instruments},
  volume={89},
  number={6},
  pages={065106},
  year={2018},
  publisher={AIP Publishing},
  doi = {10.1063/1.5001388},
  eprint = {https://doi.org/10.1063/1.5001388}
}
```
__Snapshot Solution Averaging method:__
``` bibtex
@article{liu2008global,
  title={Global luminescent oil-film skin-friction meter},
  author={Liu, Tianshu and Montefort, J and Woodiga, S and Merati, Parviz and Shen, Lixin},
  journal={AIAA journal},
  volume={46},
  number={2},
  pages={476--485},
  year={2008}
}
```

## Licence
[MIT](./LICENSE)

## Author
Taekjin LEE

Experimental Aerodynamics Laboratory  
Department of Aerospace Engineering  
Graduate School of Engineering  
TOHOKU University, Sendai, JAPAN  
