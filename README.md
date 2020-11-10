# Progetto-Reti-Logiche-2019

This repo contains the code for the project of a logic circuit from *Politecnico di Milano*.<br>
<br>
Given:<br>
1. a bidimensional square space (256x256)<br>
2. the coordinates of a point in that space <br>
3. a group of N = 8 centroids in that space<br>
4. a mask of N = 8 bits representing the centroids that need to be considered for the evaluation<br>
<br>
The task is to implement a hardware component written in VHDL that returns a mask representing the valid centroids that are at minimumn Manhattan distance from the input point. <br>
